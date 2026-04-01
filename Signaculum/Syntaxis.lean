-- Signaculum.Syntaxis
-- ゴーストDSL構文擴張にゃん♪
-- varia / eventum / excita(ident形) / insere(ident形) / construe の構文擴張を提供するにゃ
-- 環境拡張 GhostAccumulatio に variae・eventa・lazyEventa を累積するにゃ

import Lean
import Signaculum.Memoria.Citationes
import Signaculum.Memoria.StatusPermanens
import Signaculum.Nucleus.Exporta
import Signaculum.Nucleus.Circulus
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
  /-- Some ならラムダ形にゃ。construe がここから def を生成するにゃ -/
  lambdaStx?  : Option Syntax := none

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
  ⟨{ declNomen := .anonymous, nomenEventi := "", paramCount := 0, lambdaStx? := none }⟩

instance : Inhabited GhostAccumulatio := ⟨{}⟩

/-- 環境拡張のエントリ型にゃん。永続化用の和型にゃ -/
inductive GhostEntry
  | varia (decl : GhostVarDecl)
  | eventum (decl : GhostEventDecl)
  | lazium (decl : LazyEventDecl)

private def addGhostEntry (acc : GhostAccumulatio) (entry : GhostEntry) : GhostAccumulatio :=
  match entry with
  | .varia d => { acc with variae := acc.variae.push d }
  | .eventum d => { acc with eventa := acc.eventa.push d }
  | .lazium d => { acc with lazyEventa := acc.lazyEventa.push d }

/-- 環境拡張の登錄にゃん♪ ファイル境界を越えて状態が伝搬するにゃ -/
initialize ghostAccumulatioExt : SimplePersistentEnvExtension GhostEntry GhostAccumulatio ←
  registerSimplePersistentEnvExtension {
    addImportedFn := fun imported =>
      imported.foldl (fun acc entries =>
        entries.foldl addGhostEntry acc) {}
    addEntryFn := addGhostEntry
  }

-- ═══════════════════════════════════════════════════
-- varia 構文擴張にゃん
-- ═══════════════════════════════════════════════════

/-- 永続化變數を宣言するにゃん♪ -/
elab "varia" "perpetua" n:ident ":" t:term ":=" v:term : command => do
  elabCommand (← `(initialize $n : IO.Ref $t ← IO.mkRef $v))
  modifyEnv fun env =>
    ghostAccumulatioExt.addEntry env (.varia {
      nomen := n.getId, typusSyntax := t, permanet := true })

/-- 一時變數を宣言するにゃん -/
elab "varia" "temporaria" n:ident ":" t:term ":=" v:term : command => do
  elabCommand (← `(initialize $n : IO.Ref $t ← IO.mkRef $v))
  modifyEnv fun env =>
    ghostAccumulatioExt.addEntry env (.varia {
      nomen := n.getId, typusSyntax := t, permanet := false })

-- ═══════════════════════════════════════════════════
-- eventum 構文擴張にゃん
-- ═══════════════════════════════════════════════════

/-- 事象處理器を宣言するにゃん♪ -/
elab "eventum" nomenEventi:str body:term : command => do
  let nomen := nomenEventi.getString
  let nomenBasisTractatorum := "_tractator_" ++ nomen
  let identTractatorum := mkIdent (Name.mkSimple nomenBasisTractatorum)
  elabCommand (← `(def $identTractatorum : Signaculum.Nucleus.Tractator := $body))
  let ns ← getCurrNamespace
  let nomenPlenumTractatorum := ns ++ Name.mkSimple nomenBasisTractatorum
  modifyEnv fun env =>
    ghostAccumulatioExt.addEntry env (.eventum {
      nomen, tractatorNomen := nomenPlenumTractatorum })

-- ═══════════════════════════════════════════════════
-- def ベース事象の補助にゃん
-- ═══════════════════════════════════════════════════

/-- Expr の先頭にある明示的 forall の数を数えるにゃん♪ -/
private partial def countExplicitParams : Lean.Expr → MetaM Nat
  | .forallE _ _ body .default => return 1 + (← countExplicitParams body)
  | .forallE _ _ body _        => countExplicitParams body
  | _                          => return 0

/-- ident を項として展開して const 名と引數リストを取り出すにゃん♪ -/
def resolveToConst (f : Ident) : TermElabM Name := do
  let fExpr ← elabTerm f none
  let fExpr ← instantiateMVars fExpr
  match fExpr with
  | .const n _ => return n
  | _ => throwError "excita/insere: 関数定数の識別子を渡してにゃ: {f}"

/-- def ベース事象を lazyEventa に登録する共通処理にゃん -/
def registraLazium (f : Ident) : TermElabM String := do
  let fname ← resolveToConst f
  let env ← getEnv
  let some info := env.find? fname |
    throwError "excita/insere: {fname} が見つからにゃいにゃ"
  let paramCount ← countExplicitParams info.type
  let nomenEventi := fname.toString
  unless (ghostAccumulatioExt.getState env).lazyEventa.any (·.declNomen == fname) do
    modifyEnv (ghostAccumulatioExt.addEntry · (.lazium {
      declNomen := fname, nomenEventi, paramCount }))
  return nomenEventi

/-- ラムダ式（Tractator 型の term）を lazyEventa にソース位置ベースの新鮮な名前で登録するにゃ -/
def registraLaziumLambda (lamStx : Syntax) (posIdx : Nat) (pc : Nat := 0) : TermElabM String := do
  let freshName := Name.mkSimple s!"_excitaLambda_{posIdx}"
  let nomenEventi := freshName.toString
  modifyEnv (ghostAccumulatioExt.addEntry · (.lazium {
      declNomen := freshName
      nomenEventi
      paramCount := pc
      lambdaStx? := some lamStx }))
  return nomenEventi

-- ═══════════════════════════════════════════════════
-- excita / insere の識別子形 elab にゃん
-- ═══════════════════════════════════════════════════

/-- checkColGt で同インデント・次行の do-item を飲み込まないにゃん -/
def excitaArgParser : Lean.Parser.Parser :=
  Lean.Parser.many
    (Lean.Parser.checkColGt "expected argument" >>
     Lean.Parser.termParser Lean.Parser.maxPrec)

@[combinator_formatter Signaculum.excitaArgParser]
def excitaArgParser.formatter : Lean.PrettyPrinter.Formatter := pure ()

@[combinator_parenthesizer Signaculum.excitaArgParser]
def excitaArgParser.parenthesizer : Lean.PrettyPrinter.Parenthesizer := pure ()

/-- `excita f arg1 arg2 ...` — def ベース事象を raise するにゃん♪
    f は `def f (p1 : T1) ... : SakuraIO Unit` の形で定義された關數にゃ。
    引數は Citatio.toRef で文字列に変換されて Reference に渡されるにゃ。
    SSP 組み込み事象には `excita "OnBoot"` の文字列形を使ふにゃ -/
@[term_parser]
def excitaTermParser : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `excitaSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "excita" >> Lean.Parser.ident >> excitaArgParser)

@[term_elab excitaSyntax]
def elabExcitaTerm : TermElab := fun stx _ => do
  -- ident 形: stx[1]=ident, stx[2]=null(args)
  -- lambda 形: stx[1]="(", stx[2]=lambda, stx[3]=")", stx[4]=null(args)
  let (fStx, args) :=
    if stx[1].isIdent then (stx[1], stx[2].getArgs)
    else (stx[2], stx[4].getArgs)
  let nomenEventi ←
    if stx[1].isIdent
    then registraLazium ⟨fStx⟩
    else registraLaziumLambda fStx (stx.getPos?.getD ⟨0⟩).byteIdx args.size
  let argTerms ← args.mapM fun a => do
    let t : TSyntax `term := ⟨a⟩
    `(Signaculum.Memoria.Citatio.toRef $t)
  elabTerm (← `(Signaculum.Sakura.Systema.excita $(Syntax.mkStrLit nomenEventi) [$argTerms,*])) none

/-- `excita ( term ) args*` — ラムダ式（Tractator 型）を直接渡しにゃ♪
    args は Reference 経由でイベントに渡されるにゃ -/
@[term_parser]
def excitaTermParserLambda : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `excitaSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "excita" >>
     Lean.Parser.symbol "(" >>
     Lean.Parser.termParser 0 >>
     Lean.Parser.symbol ")" >>
     excitaArgParser)

/-- `insere f arg1 arg2 ...` — def ベース事象を embed するにゃん♪
    f は `def f (p1 : T1) ... : SakuraIO Unit` の形で定義された關數にゃ。
    引數は Citatio.toRef で文字列に変換されて Reference に渡されるにゃ -/
@[term_parser]
def insereTermParser : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `insereSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "insere" >> Lean.Parser.ident >> excitaArgParser)

@[term_elab insereSyntax]
def elabInsereTerm : TermElab := fun stx _ => do
  -- ident 形: stx[1]=ident, stx[2]=null(args)
  -- lambda 形: stx[1]="(", stx[2]=lambda, stx[3]=")", stx[4]=null(args)
  let (fStx, args) :=
    if stx[1].isIdent then (stx[1], stx[2].getArgs)
    else (stx[2], stx[4].getArgs)
  let nomenEventi ←
    if stx[1].isIdent
    then registraLazium ⟨fStx⟩
    else registraLaziumLambda fStx (stx.getPos?.getD ⟨0⟩).byteIdx args.size
  let argTerms ← args.mapM fun a => do
    let t : TSyntax `term := ⟨a⟩
    `(Signaculum.Memoria.Citatio.toRef $t)
  elabTerm (← `(Signaculum.Sakura.Systema.insere $(Syntax.mkStrLit nomenEventi) [$argTerms,*])) none

/-- `insere ( term ) args*` — ラムダ式（Tractator 型）を直接渡しにゃ♪ -/
@[term_parser]
def insereTermParserLambda : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `insereSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "insere" >>
     Lean.Parser.symbol "(" >>
     Lean.Parser.termParser 0 >>
     Lean.Parser.symbol ")" >>
     excitaArgParser)

-- ═══════════════════════════════════════════════════
-- A: 事象発火拡張形 elab にゃん
-- ═══════════════════════════════════════════════════

/-- `notifica f arg1 arg2 ...` — def ベース通知事象を發生させるにゃん♪
    f は `def f (p1 : T1) ... : SakuraIO Unit` の形で定義された關數にゃ。
    引數は Citatio.toRef で文字列に変換されて Reference に渡されるにゃ -/
@[term_parser]
def notificaTermParser : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `notificaSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "notifica" >> Lean.Parser.ident >> excitaArgParser)

@[term_elab notificaSyntax]
def elabNotificaTerm : TermElab := fun stx _ => do
  -- ident 形: stx[1]=ident, stx[2]=null(args)
  -- lambda 形: stx[1]="(", stx[2]=lambda, stx[3]=")", stx[4]=null(args)
  let (fStx, args) :=
    if stx[1].isIdent then (stx[1], stx[2].getArgs)
    else (stx[2], stx[4].getArgs)
  let nomenEventi ←
    if stx[1].isIdent
    then registraLazium ⟨fStx⟩
    else registraLaziumLambda fStx (stx.getPos?.getD ⟨0⟩).byteIdx args.size
  let argTerms ← args.mapM fun a => do
    let t : TSyntax `term := ⟨a⟩
    `(Signaculum.Memoria.Citatio.toRef $t)
  elabTerm (← `(Signaculum.Sakura.Systema.notifica $(Syntax.mkStrLit nomenEventi) [$argTerms,*])) none

/-- `notifica ( term ) args*` — ラムダ式（Tractator 型）を直接渡しにゃ♪ -/
@[term_parser]
def notificaTermParserLambda : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `notificaSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "notifica" >>
     Lean.Parser.symbol "(" >>
     Lean.Parser.termParser 0 >>
     Lean.Parser.symbol ")" >>
     excitaArgParser)

/-- `excitaPostTempus ms repeat f arg1 arg2 ...` — def ベース事象を遅延発火させるにゃん♪
    ms はミリ秒、repeat は繰返し回數（0=無限）にゃ -/
@[term_parser]
def excitaPostTempusTermParser : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `excitaPostTempusSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "excitaPostTempus" >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.ident >> excitaArgParser)

@[term_elab excitaPostTempusSyntax]
def elabExcitaPostTempusTerm : TermElab := fun stx _ => do
  -- ident 形: stx[1]=ms, stx[2]=rep, stx[3]=ident, stx[4]=null(args)
  -- lambda 形: stx[1]=ms, stx[2]=rep, stx[3]="(", stx[4]=lambda, stx[5]=")", stx[6]=null(args)
  let ms : TSyntax `term := ⟨stx[1]⟩
  let rep : TSyntax `term := ⟨stx[2]⟩
  let (fStx, args) :=
    if stx[3].isIdent then (stx[3], stx[4].getArgs)
    else (stx[4], stx[6].getArgs)
  let nomenEventi ←
    if stx[3].isIdent
    then registraLazium ⟨fStx⟩
    else registraLaziumLambda fStx (stx.getPos?.getD ⟨0⟩).byteIdx args.size
  let argTerms ← args.mapM fun a => do
    let t : TSyntax `term := ⟨a⟩
    `(Signaculum.Memoria.Citatio.toRef $t)
  elabTerm
    (← `(Signaculum.Sakura.Systema.excitaPostTempus $ms $rep $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
    none

/-- `excitaPostTempus ms rep ( term ) args*` — ラムダ式（Tractator 型）を遅延発火させるにゃ♪ -/
@[term_parser]
def excitaPostTempusTermParserLambda : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `excitaPostTempusSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "excitaPostTempus" >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.symbol "(" >> Lean.Parser.termParser 0 >> Lean.Parser.symbol ")" >>
     excitaArgParser)

/-- `notificaPostTempus ms repetitio f arg1 arg2 ...` — def ベース通知事象を遅延発火させるにゃん♪ -/
@[term_parser]
def notificaPostTempusTermParser : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `notificaPostTempusSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "notificaPostTempus" >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.ident >> excitaArgParser)

@[term_elab notificaPostTempusSyntax]
def elabNotificaPostTempusTerm : TermElab := fun stx _ => do
  -- ident 形: stx[1]=ms, stx[2]=rep, stx[3]=ident, stx[4]=null(args)
  -- lambda 形: stx[1]=ms, stx[2]=rep, stx[3]="(", stx[4]=lambda, stx[5]=")", stx[6]=null(args)
  let ms : TSyntax `term := ⟨stx[1]⟩
  let rep : TSyntax `term := ⟨stx[2]⟩
  let (fStx, args) :=
    if stx[3].isIdent then (stx[3], stx[4].getArgs)
    else (stx[4], stx[6].getArgs)
  let nomenEventi ←
    if stx[3].isIdent
    then registraLazium ⟨fStx⟩
    else registraLaziumLambda fStx (stx.getPos?.getD ⟨0⟩).byteIdx args.size
  let argTerms ← args.mapM fun a => do
    let t : TSyntax `term := ⟨a⟩
    `(Signaculum.Memoria.Citatio.toRef $t)
  elabTerm
    (← `(Signaculum.Sakura.Systema.notificaPostTempus $ms $rep $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
    none

/-- `notificaPostTempus ms rep ( term ) args*` — ラムダ式（Tractator 型）を遅延通知するにゃ♪ -/
@[term_parser]
def notificaPostTempusTermParserLambda : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `notificaPostTempusSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "notificaPostTempus" >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.symbol "(" >> Lean.Parser.termParser 0 >> Lean.Parser.symbol ")" >>
     excitaArgParser)

/-- `optioEventum titulus f arg1 arg2 ...` — def ベース事象附き選擇肢にゃん♪
    titulus は表示文字列にゃ。f は def で定義されたコールバックにゃ -/
@[term_parser]
def optioEventumTermParser : Lean.Parser.Parser :=
  Lean.Parser.leadingNode `optioEventumSyntax Lean.Parser.maxPrec
    (Lean.Parser.symbol "optioEventum" >>
     Lean.Parser.termParser Lean.Parser.maxPrec >>
     Lean.Parser.ident >> excitaArgParser)

@[term_elab optioEventumSyntax]
def elabOptioEventumTerm : TermElab := fun stx _ => do
  let titulus : TSyntax `term := ⟨stx[1]⟩
  let f : Ident := ⟨stx[2]⟩
  let args := stx[3].getArgs
  let nomenEventi ← registraLazium f
  let argTerms ← args.mapM fun a => do
    let t : TSyntax `term := ⟨a⟩
    `(Signaculum.Memoria.Citatio.toRef $t)
  elabTerm
    (← `(Signaculum.Sakura.Textus.optioEventum $titulus $(Syntax.mkStrLit nomenEventi) [$argTerms,*]))
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

/-- `aperiInputum modus ( lam ) titulus` — ラムダ式を直接渡すにゃん♪
    lam は `String → SakuraM m Unit` 型にゃ -/
elab "aperiInputum" modus:term "(" lam:term ")" titulus:term : term => do
  let posIdx := (lam.raw.getPos?.getD ⟨0⟩).byteIdx
  let nomenEventi ← registraLaziumLambda lam.raw posIdx 1
  elabTerm
    (← `(Signaculum.Sakura.aperiInputum $modus $(Syntax.mkStrLit nomenEventi) $titulus ""))
    none

/-- `aperiInputumDiei f titulus annus mensis dies` — def ベースの日付入力ボックスを開くにゃん♪
    annus/mensis(1〜12)/dies(1〜31) にゃ -/
elab "aperiInputumDiei" f:ident titulus:term annus:term mensis:term dies:term : term => do
  let nomenEventi ← registraLazium f
  elabTerm
    (← `(Signaculum.Sakura.aperiInputumDiei $(Syntax.mkStrLit nomenEventi) $titulus $annus $mensis $dies))
    none

/-- `aperiInputumTemporis f titulus hora minutum secundum` — def ベースの時刻入力ボックスを開くにゃん♪
    hora(0〜23)/minutum(0〜59)/secundum(0〜59) にゃ -/
elab "aperiInputumTemporis" f:ident titulus:term hora:term minutum:term secundum:term : term => do
  let nomenEventi ← registraLazium f
  elabTerm
    (← `(Signaculum.Sakura.aperiInputumTemporis $(Syntax.mkStrLit nomenEventi) $titulus $hora $minutum $secundum))
    none

/-- `aperiInputumGradus f titulus minimum maximum initium` — def ベースのスライダー入力ボックスを開くにゃん♪
    minimum ≤ initium ≤ maximum の制約があるにゃ -/
elab "aperiInputumGradus" f:ident titulus:term minimum:term maximum:term initium:term : term => do
  let nomenEventi ← registraLazium f
  elabTerm
    (← `(Signaculum.Sakura.aperiInputumGradus $(Syntax.mkStrLit nomenEventi) $titulus $minimum $maximum $initium))
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
    (← `(Signaculum.Sakura.Systema.legeProprietatem $(Syntax.mkStrLit nomenEventi) $proprietates))
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
    (← `(liftM (Signaculum.Nucleus.spawnaMunitus $callTerm)))
    none

/-- `spawnaScriptum f arg1 arg2 ...` — SakuraIO Unit アクシオーをバックグラウンドで起動するにゃん♪
    f は `def f (p1 : T1) ... : SakuraIO Unit` の形で定義された關數にゃ。
    バックグラウンドで Sakura.currere して SSTP 経由で SSP にスクリプトを送信するにゃ -/
elab "spawnaScriptum" f:ident args:term* : term => do
  let callTerm ← `($f $args*)
  elabTerm
    (← `(liftM (Signaculum.Nucleus.spawnaMunitus do
      let _st ← Signaculum.Sakura.Textus.currere $callTerm
      Signaculum.Sstp.mitteSstpScriptum (Signaculum.Sakura.adCatenamLista _st.scriptum))))
    none

-- ═══════════════════════════════════════════════════
-- construe 構文擴張にゃん
-- ═══════════════════════════════════════════════════

set_option hygiene false in
/-- ゴーストを組み立てて SSP に登錄するにゃん♪ -/
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

    match e.lambdaStx? with
    | some lamStx =>
      let lamTerm : TSyntax `term := ⟨lamStx⟩
      if e.paramCount == 0 then
        -- 引數なしにゃ: ラムダを Tractator として直接定義するにゃ
        elabCommand (← `(def $tractorIdent : Signaculum.Nucleus.Tractator := $lamTerm))
      else
        -- 引數ありにゃ: Reference 抽出ラッパーを生成するにゃ
        -- fun req => $lamTerm (fromRef (req.referentiam 0)) ...
        let argExprs : Array (TSyntax `term) ← (Array.range e.paramCount).mapM fun i => do
          let idx := Syntax.mkNumLit (toString i)
          `(Signaculum.Memoria.Citatio.fromRef ((req.referentiam $idx).getD ""))
        elabCommand (← `(
          def $tractorIdent : Signaculum.Nucleus.Tractator := fun req => $lamTerm $argExprs*))
    | none =>
      -- ident 形にゃ: Reference 抽出ラッパーを生成するにゃ
      -- def _tractator_lazy_... : Tractator := fun req =>
      --   onGreet (FromRef.fromRef ((req.referentiam 0).getD ""))
      --           (FromRef.fromRef ((req.referentiam 1).getD ""))
      let argExprs : Array (TSyntax `term) ← (Array.range e.paramCount).mapM fun i => do
        let idx := Syntax.mkNumLit (toString i)
        `(Signaculum.Memoria.Citatio.fromRef ((req.referentiam $idx).getD ""))
      elabCommand (← `(
        def $tractorIdent : Signaculum.Nucleus.Tractator := fun req => $declIdent $argExprs*))

    let signumNominis : TSyntax `term := ⟨Syntax.mkStrLit e.nomenEventi⟩
    pariaTractatorum := pariaTractatorum.push (← `(($signumNominis, $tractorIdent)))

  if variaePermanentes.isEmpty then
    elabCommand (← `(def servaStatum : IO Unit := pure ()))
    elabCommand (← `(
      initialize (Signaculum.Nucleus.registraShiori [$pariaTractatorum,*])
    ))
    -- ゴーストの主循環エントリーポイントを自動定義するにゃ
    elabCommand (← `(def main : IO Unit := Signaculum.Nucleus.loopPrincipalis))
  else
    let elementaOnerandi : Array (TSyntax `term) ← variaePermanentes.mapM fun v => do
      let identVariae := mkIdent v.nomen
      let signumNominis : TSyntax `term := ⟨Syntax.mkStrLit v.nomen.toString⟩
      let syntaxisTypi : TSyntax `term := ⟨v.typusSyntax⟩
      `(($signumNominis, fun _tag _s => do
          if _tag == Signaculum.Memoria.StatusPermanens.typusTag (α := $syntaxisTypi) then
            if let (some _v : Option $syntaxisTypi) :=
                Signaculum.Memoria.StatusPermanens.eBytes _s then
              ($identVariae).set _v))

    let elementaServandi : Array (TSyntax `term) ← variaePermanentes.mapM fun v => do
      let identVariae := mkIdent v.nomen
      let signumNominis : TSyntax `term := ⟨Syntax.mkStrLit v.nomen.toString⟩
      let syntaxisTypi : TSyntax `term := ⟨v.typusSyntax⟩
      `(($signumNominis, do
          let _v ← ($identVariae).get
          return (Signaculum.Memoria.StatusPermanens.typusTag (α := $syntaxisTypi),
                  Signaculum.Memoria.StatusPermanens.adBytes _v)))

    let terminusTractatorum ← `([$pariaTractatorum,*])
    let terminusOnerandi    ← `([$elementaOnerandi,*])
    let terminusServandi    ← `([$elementaServandi,*])

    elabCommand (← `(
      def servaStatum : IO Unit := do
        let _domus ← Signaculum.Nucleus.domusObtinere
        let _via := _domus ++ "/ghost_status.bin"
        let _paria ← Signaculum.Memoria.executareScripturam $terminusServandi
        Signaculum.Memoria.scribeMappam _via _paria))

    elabCommand (← `(
      initialize (Signaculum.Nucleus.registraShioriEx
        $terminusTractatorum
        (some (fun _domus => do
          let _via := _domus ++ "/ghost_status.bin"
          try
            let _paria ← Signaculum.Memoria.legereMappam _via
            Signaculum.Memoria.executareLecturam _paria $terminusOnerandi
          catch _ => pure ()))
        (some servaStatum))
    ))
    -- ゴーストの主循環エントリーポイントを自動定義するにゃ
    elabCommand (← `(def main : IO Unit := Signaculum.Nucleus.loopPrincipalis))

end Signaculum
