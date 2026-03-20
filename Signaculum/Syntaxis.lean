-- Signaculum.Syntaxis
-- ゴーストDSL構文擴張にゃん♪
-- varia / eventum / excita(ident形) / insere(ident形) / construe の構文擴張を提供するにゃ
-- 環境拡張 GhostAccumulatio に variae・eventa・lazyEventa を累積するにゃ

import Lean
import Signaculum.Memoria.Citationes
import Signaculum.Memoria.StatusPermanens
import Signaculum.Exporta
import Signaculum.Loop
import Signaculum.Sstp

open Lean Elab Command Term Meta

namespace Signaculum

-- ═══════════════════════════════════════════════════
-- 環境拡張の定義にゃん
-- ═══════════════════════════════════════════════════

/-- varia 宣言の情報にゃん -/
structure GhostVarDecl where
  /-- 變數名にゃ（例: `greetCount）-/
  nomen       : Name
  /-- 型の構文木にゃ。永続化の型クラス解決に使ふにゃ -/
  typusSyntax : Syntax
  /-- true なら ghost_status.bin に永続化するにゃん -/
  permanet    : Bool

/-- eventum 宣言の情報にゃん -/
structure GhostEventDecl where
  /-- イベント名にゃ（例: "OnBoot"）-/
  nomen          : String
  /-- 生成した處理器の完全修飾名にゃ -/
  tractatorNomen : Name

/-- def ベースの遅延登録事象にゃん。excita/insere の識別子形で積まれるにゃ -/
structure LazyEventDecl where
  /-- 元の def の完全修飾名にゃ -/
  declNomen   : Name
  /-- 派生したイベント名（完全修飾文字列）にゃ -/
  nomenEventi : String
  /-- 明示的パラメータ数にゃ（Reference 抽出数に使ふにゃ）-/
  paramCount  : Nat

/-- ゴーストの累積宣言にゃん。construe 時に全部參照するにゃ -/
structure GhostAccumulatio where
  variae     : Array GhostVarDecl   := #[]
  eventa     : Array GhostEventDecl := #[]
  lazyEventa : Array LazyEventDecl  := #[]

-- Inhabited インスタンスにゃん♪
instance : Inhabited GhostVarDecl :=
  ⟨{ nomen := .anonymous, typusSyntax := .missing, permanet := false }⟩

instance : Inhabited GhostEventDecl :=
  ⟨{ nomen := "", tractatorNomen := .anonymous }⟩

instance : Inhabited LazyEventDecl :=
  ⟨{ declNomen := .anonymous, nomenEventi := "", paramCount := 0 }⟩

instance : Inhabited GhostAccumulatio := ⟨{}⟩

/-- 環境拡張の登錄にゃん♪ -/
initialize ghostAccumulatioExt : EnvExtension GhostAccumulatio ←
  registerEnvExtension (pure {})

-- ═══════════════════════════════════════════════════
-- varia 構文擴張にゃん
-- ═══════════════════════════════════════════════════

/-- 永続化變數を宣言するにゃん♪ -/
elab "varia" "perpetua" n:ident ":" t:term ":=" v:term : command => do
  elabCommand (← `(initialize $n : IO.Ref $t ← IO.mkRef $v))
  modifyEnv fun env =>
    ghostAccumulatioExt.modifyState env fun acc =>
      { acc with variae := acc.variae.push {
          nomen := n.getId, typusSyntax := t, permanet := true } }

/-- 一時變數を宣言するにゃん -/
elab "varia" "temporaria" n:ident ":" t:term ":=" v:term : command => do
  elabCommand (← `(initialize $n : IO.Ref $t ← IO.mkRef $v))
  modifyEnv fun env =>
    ghostAccumulatioExt.modifyState env fun acc =>
      { acc with variae := acc.variae.push {
          nomen := n.getId, typusSyntax := t, permanet := false } }

-- ═══════════════════════════════════════════════════
-- eventum 構文擴張にゃん
-- ═══════════════════════════════════════════════════

/-- 事象處理器を宣言するにゃん♪ -/
elab "eventum" nomenEventi:str body:term : command => do
  let nomen := nomenEventi.getString
  let nomenBasisTractatorum := "_tractator_" ++ nomen
  let identTractatorum := mkIdent (Name.mkSimple nomenBasisTractatorum)
  elabCommand (← `(def $identTractatorum : Signaculum.Tractator := $body))
  let ns ← getCurrNamespace
  let nomenPlenumTractatorum := ns ++ Name.mkSimple nomenBasisTractatorum
  modifyEnv fun env =>
    ghostAccumulatioExt.modifyState env fun acc =>
      { acc with eventa := acc.eventa.push {
          nomen, tractatorNomen := nomenPlenumTractatorum } }

-- ═══════════════════════════════════════════════════
-- def ベース事象の補助にゃん
-- ═══════════════════════════════════════════════════

/-- Expr の先頭にある明示的 forall の数を数えるにゃん♪ -/
private partial def countExplicitParams : Lean.Expr → MetaM Nat
  | .forallE _ _ body .default => return 1 + (← countExplicitParams body)
  | .forallE _ _ body _        => countExplicitParams body
  | _                          => return 0

/-- ident を項として展開して const 名と引數リストを取り出すにゃん♪ -/
private def resolveToConst (f : Ident) : TermElabM Name := do
  let fExpr ← elabTerm f none
  let fExpr ← instantiateMVars fExpr
  match fExpr with
  | .const n _ => return n
  | _ => throwError "excita/insere: 関数定数の識別子を渡してにゃ: {f}"

/-- def ベース事象を lazyEventa に登録する共通処理にゃん -/
private def registraLazium (f : Ident) : TermElabM String := do
  let fname ← resolveToConst f
  let env ← getEnv
  let some info := env.find? fname |
    throwError "excita/insere: {fname} が見つからにゃいにゃ"
  let paramCount ← countExplicitParams info.type
  let nomenEventi := fname.toString
  unless (ghostAccumulatioExt.getState env).lazyEventa.any (·.declNomen == fname) do
    modifyEnv (ghostAccumulatioExt.modifyState · fun a =>
      { a with lazyEventa := a.lazyEventa.push {
          declNomen := fname, nomenEventi, paramCount } })
  return nomenEventi

-- ═══════════════════════════════════════════════════
-- excita / insere の識別子形 elab にゃん
-- ═══════════════════════════════════════════════════

/-- `excita f arg1 arg2 ...` — def ベース事象を raise するにゃん♪
    f は `def f (p1 : T1) ... : SakuraIO Unit` の形で定義された關數にゃ。
    引數は ToRef で文字列に変換されて Reference に渡されるにゃ。
    SSP 組み込み事象には `excita "OnBoot"` の文字列形を使ふにゃ -/
elab "excita" f:ident args:term* : term => do
  let nomenEventi ← registraLazium f
  let argTerms ← args.mapM fun a => `(Signaculum.Citatio.toRef $a)
  elabTerm
    (← `(Signaculum.Sakura.excita $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
    none

/-- `insere f arg1 arg2 ...` — def ベース事象を embed するにゃん♪
    f は `def f (p1 : T1) ... : SakuraIO Unit` の形で定義された關數にゃ。
    引數は Citatio.toRef で文字列に変換されて Reference に渡されるにゃ -/
elab "insere" f:ident args:term* : term => do
  let nomenEventi ← registraLazium f
  let argTerms ← args.mapM fun a => `(Signaculum.Citatio.toRef $a)
  elabTerm
    (← `(Signaculum.Sakura.insere $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
    none

-- ═══════════════════════════════════════════════════
-- A: 事象発火拡張形 elab にゃん
-- ═══════════════════════════════════════════════════

/-- `notifica f arg1 arg2 ...` — def ベース通知事象を發生させるにゃん♪
    f は `def f (p1 : T1) ... : SakuraIO Unit` の形で定義された關數にゃ。
    引數は Citatio.toRef で文字列に変換されて Reference に渡されるにゃ -/
elab "notifica" f:ident args:term* : term => do
  let nomenEventi ← registraLazium f
  let argTerms ← args.mapM fun a => `(Signaculum.Citatio.toRef $a)
  elabTerm
    (← `(Signaculum.Sakura.notifica $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
    none

/-- `excitaPostTempus ms repeat f arg1 arg2 ...` — def ベース事象を遅延発火させるにゃん♪
    ms はミリ秒、repeat は繰返し回數（0=無限）にゃ -/
elab "excitaPostTempus" ms:term repetitio:term f:ident args:term* : term => do
  let nomenEventi ← registraLazium f
  let argTerms ← args.mapM fun a => `(Signaculum.Citatio.toRef $a)
  elabTerm
    (← `(Signaculum.Sakura.excitaPostTempus $ms $repetitio $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
    none

/-- `notificaPostTempus ms repetitio f arg1 arg2 ...` — def ベース通知事象を遅延発火させるにゃん♪ -/
elab "notificaPostTempus" ms:term repetitio:term f:ident args:term* : term => do
  let nomenEventi ← registraLazium f
  let argTerms ← args.mapM fun a => `(Signaculum.Citatio.toRef $a)
  elabTerm
    (← `(Signaculum.Sakura.notificaPostTempus $ms $repetitio $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
    none

/-- `optioEventum titulus f arg1 arg2 ...` — def ベース事象附き選擇肢にゃん♪
    titulus は表示文字列にゃ。f は def で定義されたコールバックにゃ -/
elab "optioEventum" titulus:term f:ident args:term* : term => do
  let nomenEventi ← registraLazium f
  let argTerms ← args.mapM fun a => `(Signaculum.Citatio.toRef $a)
  elabTerm
    (← `(Signaculum.Sakura.optioEventum $titulus $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
    none

-- ═══════════════════════════════════════════════════
-- B: コールバック登録形 elab にゃん
-- ═══════════════════════════════════════════════════

/-- `aperiInputum modus f titulus textus` — def ベースのテキスト入力ボックスを開くにゃん♪
    f は入力結果を受け取る def にゃ。SSP がランタイムで Reference に値を渡すにゃ -/
elab "aperiInputum" modus:term f:ident titulus:term textus:term : term => do
  let nomenEventi ← registraLazium f
  elabTerm
    (← `(Signaculum.Sakura.aperiInputum $modus $(Syntax.mkStrLit nomenEventi) $titulus $textus))
    none

/-- `aperiInputumNumerale modus f titulus a b c` — def ベースの數値入力ボックスを開くにゃん♪
    a/b/c は年月日・時分秒・值最小最大に對應するにゃ -/
elab "aperiInputumNumerale" modus:term f:ident titulus:term a:term b:term c:term : term => do
  let nomenEventi ← registraLazium f
  elabTerm
    (← `(Signaculum.Sakura.aperiInputumNumerale $modus $(Syntax.mkStrLit nomenEventi) $titulus $a $b $c))
    none

/-- `aperiInputumIP f titulus ip1 ip2 ip3 ip4` — def ベースの IP アドレス入力ボックスを開くにゃん♪ -/
elab "aperiInputumIP" f:ident titulus:term ip1:term ip2:term ip3:term ip4:term : term => do
  let nomenEventi ← registraLazium f
  elabTerm
    (← `(Signaculum.Sakura.aperiInputumIP $(Syntax.mkStrLit nomenEventi) $titulus $ip1 $ip2 $ip3 $ip4))
    none

/-- `legeProprietatem f proprietates` — def ベースのプロパティ取得にゃん♪
    f は結果を受け取る def にゃ。proprietates は `List Proprietas` にゃ -/
elab "legeProprietatem" f:ident proprietates:term : term => do
  let nomenEventi ← registraLazium f
  elabTerm
    (← `(Signaculum.Sakura.legeProprietatem $(Syntax.mkStrLit nomenEventi) $proprietates))
    none

-- ═══════════════════════════════════════════════════
-- 非同期起動 elab にゃん
-- ═══════════════════════════════════════════════════

/-- `spawna f arg1 arg2 ...` — IO Unit アクシオーをバックグラウンドで起動するにゃん♪
    f は `def f (p1 : T1) ... : IO Unit` の形で定義された關數にゃ。
    引數は直接渡す（同一プロセス内にゃ）。
    SakuraIO の蓄積スクリプトは變化しにゃいにゃ -/
elab "spawna" f:ident args:term* : term => do
  let callTerm ← `($f $args*)
  elabTerm
    (← `(liftM (Signaculum.spawnaMunitus $callTerm)))
    none

/-- `spawnaScriptum f arg1 arg2 ...` — SakuraIO Unit アクシオーをバックグラウンドで起動するにゃん♪
    f は `def f (p1 : T1) ... : SakuraIO Unit` の形で定義された關數にゃ。
    バックグラウンドで Sakura.currere して SSTP 経由で SSP にスクリプトを送信するにゃ -/
elab "spawnaScriptum" f:ident args:term* : term => do
  let callTerm ← `($f $args*)
  elabTerm
    (← `(liftM (Signaculum.spawnaMunitus do
      let _s ← Signaculum.Sakura.currere $callTerm
      Signaculum.Sstp.mitteSstpScriptum _s)))
    none

-- ═══════════════════════════════════════════════════
-- construe 構文擴張にゃん
-- ═══════════════════════════════════════════════════

/-- ゴーストを組み立てて SSP に登錄するにゃん♪ -/
set_option hygiene false in
elab "construe" : command => do
  let env ← getEnv
  let acc := ghostAccumulatioExt.getState env
  let variaePermanentes := acc.variae.filter (·.permanet)
  let eventa := acc.eventa

  -- eventa からペアを組み立てるにゃ
  let mut pariaTractatorum : Array (TSyntax `term) ← eventa.mapM fun e => do
    let identTractatorum := mkIdent e.tractatorNomen
    let signumNominis : TSyntax `term := ⟨Syntax.mkStrLit e.nomen⟩
    `(($signumNominis, $identTractatorum))

  -- lazyEventa のラッパーを生成してペアを追加するにゃ♪
  for e in acc.lazyEventa do
    let declIdent := mkIdent e.declNomen
    -- ラッパー名: .を_に変換して衝突回避するにゃ
    let tractorNome := Name.mkSimple
      ("_tractator_lazy_" ++ e.nomenEventi.map (fun c => if c == '.' then '_' else c))
    let tractorIdent := mkIdent tractorNome

    -- 各 Reference を FromRef で抽出して直接引數に渡すにゃ
    -- def _tractator_lazy_... : Tractator := fun req =>
    --   onGreet (FromRef.fromRef ((req.referentiam 0).getD ""))
    --           (FromRef.fromRef ((req.referentiam 1).getD ""))
    let argExprs : Array (TSyntax `term) ← (Array.range e.paramCount).mapM fun i => do
      let idx := Syntax.mkNumLit (toString i)
      `(Signaculum.Citatio.fromRef ((req.referentiam $idx).getD ""))

    elabCommand (← `(
      def $tractorIdent : Signaculum.Tractator := fun req => $declIdent $argExprs*))

    let signumNominis : TSyntax `term := ⟨Syntax.mkStrLit e.nomenEventi⟩
    pariaTractatorum := pariaTractatorum.push (← `(($signumNominis, $tractorIdent)))

  if variaePermanentes.isEmpty then
    elabCommand (← `(def servaStatum : IO Unit := pure ()))
    elabCommand (← `(
      initialize (Signaculum.registraShiori [$pariaTractatorum,*])
    ))
  else
    let elementaOnerandi : Array (TSyntax `term) ← variaePermanentes.mapM fun v => do
      let identVariae := mkIdent v.nomen
      let signumNominis : TSyntax `term := ⟨Syntax.mkStrLit v.nomen.toString⟩
      let syntaxisTypi : TSyntax `term := ⟨v.typusSyntax⟩
      `(($signumNominis, fun _tag _s => do
          if _tag == Signaculum.StatusPermanens.typusTag (α := $syntaxisTypi) then
            if let (some _v : Option $syntaxisTypi) :=
                Signaculum.StatusPermanens.eBytes _s then
              ($identVariae).set _v))

    let elementaServandi : Array (TSyntax `term) ← variaePermanentes.mapM fun v => do
      let identVariae := mkIdent v.nomen
      let signumNominis : TSyntax `term := ⟨Syntax.mkStrLit v.nomen.toString⟩
      let syntaxisTypi : TSyntax `term := ⟨v.typusSyntax⟩
      `(($signumNominis, do
          let _v ← ($identVariae).get
          return (Signaculum.StatusPermanens.typusTag (α := $syntaxisTypi),
                  Signaculum.StatusPermanens.adBytes _v)))

    let terminusTractatorum ← `([$pariaTractatorum,*])
    let terminusOnerandi    ← `([$elementaOnerandi,*])
    let terminusServandi    ← `([$elementaServandi,*])

    elabCommand (← `(
      def servaStatum : IO Unit := do
        let _domus ← Signaculum.domusObtinere
        let _via := _domus ++ "/ghost_status.bin"
        let _paria ← Signaculum.executareScripturam $terminusServandi
        Signaculum.scribeMappam _via _paria))

    elabCommand (← `(
      initialize (Signaculum.registraShioriEx
        $terminusTractatorum
        (some (fun _domus => do
          let _via := _domus ++ "/ghost_status.bin"
          try
            let _paria ← Signaculum.legereMappam _via
            Signaculum.executareLecturam _paria $terminusOnerandi
          catch _ => pure ()))
        (some servaStatum))
    ))

end Signaculum
