-- Signaculum.Notatio.Expande.Textus
-- テクストゥス・基本サクラスクリプトゥム・タグのディスパッチ關數にゃん♪
-- 舊い syntax + macro_rules を統一的な elaboration 型に置き換へるにゃ

import Lean
import Signaculum.Sakura.Scriptum
import Signaculum.Syntaxis

namespace Signaculum.Notatio.Expande

open Lean Elab Term Meta

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentVal (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some (s.getId.toString (escape := false))
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

/-- 數値リテラルかどうか確認して取り出すにゃん -/
private def expectaNatLit (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `num) := do
  match s.isNatLit? with
  | some _ => pure ⟨s⟩
  | none   => throwErrorAt s s!"{nomenSigni}: []の中には数字が期待されてゐますにゃ"

/-- 文字列リテラルかどうか確認して取り出すにゃん -/
private def expectaStrLit (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `str) := do
  match s.isStrLit? with
  | some _ => pure ⟨s⟩
  | none   =>
    match extractIdentVal s with
    | some v => pure ⟨Syntax.mkStrLit v⟩
    | none   => throwErrorAt s s!"{nomenSigni}: []の中には文字列が期待されてゐますにゃ"

/-- -1 パターンを檢出するにゃん。ident "-1" またはアトム "-" + numLit "1" の兩方に對應にゃ -/
private def estNegativusUnus (args : Array Lean.Syntax) : Bool :=
  if args.size == 1 then
    match extractIdentVal args[0]! with
    | some s => s == "-1"
    | none   => false
  else if args.size == 2 then
    match extractIdentVal args[0]! with
    | some "-" =>
      match args[1]!.isNatLit? with
      | some 1 => true
      | _      => false
    | _ => false
  else false

/-- cb からイヴェント名 term とパラメータ型配列を作るにゃ（選擇肢用）。
    strLit → そのまま（型情報なし）、ident → registraLazium（型取得）、
    項 → elaborate して型取得 → registraLaziumLambda -/
private def resolveCallbackumOptionis (cb : Syntax) (paramCount : Nat := 0)
    : TermElabM (TSyntax `term × Array Lean.Expr) := do
  if cb.isStrLit?.isSome then
    let stx : TSyntax `term := ⟨cb⟩
    return (stx, #[])
  else if cb.isIdent then
    let ev ← Signaculum.registraLazium ⟨cb⟩
    let fname ← Signaculum.resolveToConst ⟨cb⟩
    let some info := (← getEnv).find? fname |
      throwError "resolveCallbackumOptionis: {cb} が見つからにゃいにゃ"
    let paramTypes ← Signaculum.getExplicitParamTypes info.type
    return (← `($(Syntax.mkStrLit ev)), paramTypes)
  else
    let cbExpr ← elabTerm cb none
    let cbType ← inferType cbExpr
    let paramTypes ← Signaculum.getExplicitParamTypes (← whnf cbType)
    let posIdx := (cb.getPos?.getD ⟨0⟩).byteIdx
    let ev ← Signaculum.registraLaziumLambda cb posIdx paramCount
    return (← `($(Syntax.mkStrLit ev)), paramTypes)

-- ════════════════════════════════════════════════════
--  主ディスパッチ函數 (Functio Principalis Dispatchonis)
-- ════════════════════════════════════════════════════

/-- 基本サクラスクリプトゥム・タグのディスパッチにゃん♪
    `nomen` はタグ名（例："\\h"）、`args` はブラケット內の引數配列、
    `stx` は元の構文ノードにゃ。處理できたら `some term` を返すにゃん -/
def expandeSignumTextus (nomen : String) (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match nomen with

  -- ════════════════════════════════════════════════════
  --  範圍制御 (Imperium Scopi)
  -- ════════════════════════════════════════════════════

  | "\\h" => pure <| some (← `(Signaculum.Sakura.Textus.sakura))
  | "\\u" => pure <| some (← `(Signaculum.Sakura.Textus.kero))
  | "\\0" => pure <| some (← `(Signaculum.Sakura.Textus.sakura))
  | "\\1" => pure <| some (← `(Signaculum.Sakura.Textus.kero))

  | "\\p" =>
    if args.size != 1 then
      throwErrorAt stx "\\p: 引數が1つ必要にゃ"
    let n ← expectaNatLit args[0]! "\\p"
    pure <| some (← `(Signaculum.Sakura.Textus.persona $n))

  -- ════════════════════════════════════════════════════
  --  表面制御 (Imperium Superficiei)
  -- ════════════════════════════════════════════════════

  | "\\s" =>
    if estNegativusUnus args then
      pure <| some (← `(Signaculum.Sakura.Systema.superficiesAbsconde))
    else if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\s"
      pure <| some (← `(Signaculum.Sakura.Textus.superficies $n))
    else
      throwErrorAt stx "\\s: 引數が不正にゃ"

  | "\\i" =>
    if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\i"
      pure <| some (← `(Signaculum.Sakura.Textus.animatio $n))
    else if args.size == 2 then
      let n ← expectaNatLit args[0]! "\\i"
      match extractIdentVal args[1]! with
      | some "wait" => pure <| some (← `(Signaculum.Sakura.Systema.animatioExpecta $n))
      | _           => throwErrorAt stx "\\i: 第2引數は 'wait' が期待されてゐますにゃ"
    else
      throwErrorAt stx "\\i: 引數が不正にゃ"

  -- ════════════════════════════════════════════════════
  --  改行 (Lineae)
  -- ════════════════════════════════════════════════════

  | "\\n" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.Textus.linea))
    else if args.size == 1 then
      match extractIdentVal args[0]! with
      | some "half" => pure <| some (← `(Signaculum.Sakura.Textus.dimidiaLinea))
      | _           => throwErrorAt stx "\\n: 不明な引數にゃ"
    else if args.size == 2 then
      match extractIdentVal args[0]! with
      | some "percent" =>
        let n ← expectaNatLit args[1]! "\\n"
        pure <| some (← `(Signaculum.Sakura.Textus.lineaProportionalis $n))
      | _ => throwErrorAt stx "\\n: 不明な引數にゃ"
    else
      throwErrorAt stx "\\n: 引數が多すぎるにゃ"

  | "\\_n" => pure <| some (← `(Signaculum.Sakura.Textus.linearisAbrogatur))

  -- ════════════════════════════════════════════════════
  --  清掃 (Purgatio)
  -- ════════════════════════════════════════════════════

  | "\\c" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.Textus.purga))
    else if args.size == 2 then
      match extractIdentVal args[0]! with
      | some "char" =>
        let n ← expectaNatLit args[1]! "\\c"
        pure <| some (← `(Signaculum.Sakura.Textus.purgaCharacterem $n))
      | some "line" =>
        let n ← expectaNatLit args[1]! "\\c"
        pure <| some (← `(Signaculum.Sakura.Textus.purgaLineam $n))
      | _ => throwErrorAt stx "\\c: 不明な引數にゃ"
    else if args.size == 3 then
      match extractIdentVal args[0]! with
      | some "char" =>
        let n ← expectaNatLit args[1]! "\\c"
        let i ← expectaNatLit args[2]! "\\c"
        pure <| some (← `(Signaculum.Sakura.Textus.purgaCharacteremAb $n $i))
      | some "line" =>
        let n ← expectaNatLit args[1]! "\\c"
        let i ← expectaNatLit args[2]! "\\c"
        pure <| some (← `(Signaculum.Sakura.Textus.purgaLineamAb $n $i))
      | _ => throwErrorAt stx "\\c: 不明な引數にゃ"
    else
      throwErrorAt stx "\\c: 引數が不正にゃ"

  | "\\C" => pure <| some (← `(Signaculum.Sakura.Textus.adscribe))

  -- ════════════════════════════════════════════════════
  --  待機 (Mora)
  -- ════════════════════════════════════════════════════

  | "\\w" =>
    if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\w"
      pure <| some (← `(Signaculum.Sakura.Textus.moraCeler $n))
    else
      throwErrorAt stx "\\w: 數値引數が1つ必要にゃ"

  | "\\_w" =>
    if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\_w"
      pure <| some (← `(Signaculum.Sakura.Textus.mora $n))
    else
      throwErrorAt stx "\\_w: 數値引數が1つ必要にゃ"

  | "\\__w" =>
    if args.size == 1 then
      match extractIdentVal args[0]! with
      | some "clear" => pure <| some (← `(Signaculum.Sakura.Systema.reseraTimerSynchrinae))
      | _ =>
        let n ← expectaNatLit args[0]! "\\__w"
        pure <| some (← `(Signaculum.Sakura.Textus.moraAbsoluta $n))
    else if args.size == 2 then
      match extractIdentVal args[0]! with
      | some "animation" =>
        let n ← expectaNatLit args[1]! "\\__w"
        pure <| some (← `(Signaculum.Sakura.Systema.moraAnimationem $n))
      | _ => throwErrorAt stx "\\__w: 不明な引數にゃ"
    else
      throwErrorAt stx "\\__w: 引數が不正にゃ"

  | "\\x" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.Textus.expecta))
    else if args.size == 1 then
      match extractIdentVal args[0]! with
      | some "noclear" => pure <| some (← `(Signaculum.Sakura.Textus.expectaSine))
      | _              => throwErrorAt stx "\\x: 不明な引數にゃ"
    else
      throwErrorAt stx "\\x: 引數が不正にゃ"

  | "\\t" => pure <| some (← `(Signaculum.Sakura.Textus.tempusCriticum))

  -- ════════════════════════════════════════════════════
  --  制御 (Imperium)
  -- ════════════════════════════════════════════════════

  | "\\e"  => pure <| some (← `(Signaculum.Sakura.Textus.finis))
  | "\\_q" => pure <| some (← `(Signaculum.Sakura.Textus.celer))
  | "\\-"  => pure <| some (← `(Signaculum.Sakura.Textus.exitus))
  | "\\+"  => pure <| some (← `(Signaculum.Sakura.Textus.mutaGhost))
  | "\\*"  => pure <| some (← `(Signaculum.Sakura.Textus.prohibeTempus))
  | "\\_+" => pure <| some (← `(Signaculum.Sakura.Systema.mutaGhostSequens))
  | "\\v"  => pure <| some (← `(Signaculum.Sakura.Systema.togglaSupra))
  | "\\4"  => pure <| some (← `(Signaculum.Sakura.Textus.recede))
  | "\\5"  => pure <| some (← `(Signaculum.Sakura.Textus.accede))
  | "\\6"  => pure <| some (← `(Signaculum.Sakura.Systema.syncTempus))
  | "\\7"  => pure <| some (← `(Signaculum.Sakura.Systema.eventumTempus))
  | "\\_?" => pure <| some (← `(Signaculum.Sakura.Systema.inhibeTagas))
  | "\\_V" => pure <| some (← `(Signaculum.Sakura.Systema.expectaSonum))

  -- ════════════════════════════════════════════════════
  --  同期 (Synchronia)
  -- ════════════════════════════════════════════════════

  | "\\_s" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.Textus.synchrona))
    else
      -- 可變長數値リストにゃん
      let mut termElems : Array (TSyntax `term) := #[]
      for h : idx in [:args.size] do
        let n ← expectaNatLit args[idx] "\\_s"
        termElems := termElems.push (← `(term| $n))
      pure <| some (← `(Signaculum.Sakura.Systema.synchronaScopi [$termElems,*]))

  -- ════════════════════════════════════════════════════
  --  吹出し (Bulla)
  -- ════════════════════════════════════════════════════

  | "\\b" =>
    if estNegativusUnus args then
      pure <| some (← `(Signaculum.Sakura.bullaAbsconde))
    else if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\b"
      pure <| some (← `(Signaculum.Sakura.Textus.bulla $n))
    else
      throwErrorAt stx "\\b: 引數が不正にゃ"

  -- ════════════════════════════════════════════════════
  --  跳躍 (Saltum)
  -- ════════════════════════════════════════════════════

  | "\\j" =>
    if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\j"
      pure <| some (← `(Signaculum.Sakura.Textus.saltum $s))
    else
      throwErrorAt stx "\\j: 文字列引數が1つ必要にゃ"

  -- ════════════════════════════════════════════════════
  --  錨 (Ancora)
  -- ════════════════════════════════════════════════════

  | "\\_a" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.Textus.fineAncora))
    else
      let cb := args[0]!
      let (evStx, paramTypes) ← resolveCallbackumOptionis cb (args.size - 1)
      if args.size == 1 then
        pure <| some (← `(Signaculum.Sakura.Textus.ancora $evStx))
      else
        let refArgs ← Signaculum.toRefCumTypo (args.extract 1 args.size) paramTypes
        pure <| some (← `(Signaculum.Sakura.Textus.ancora $evStx [$refArgs,*]))

  -- ════════════════════════════════════════════════════
  --  選擇肢 (Optiones)
  -- ════════════════════════════════════════════════════

  | "\\q" =>
    if args.size == 2 then
      let t ← expectaStrLit args[0]! "\\q"
      let cb := args[1]!
      if cb.isStrLit?.isSome then
        -- 文字列形: optio title id（從來互換にゃ）
        pure <| some (← `(Signaculum.Sakura.Textus.optio $t $(⟨cb⟩)))
      else
        -- 關數形: registraLazium/Lambda → optioEventum にゃ
        let (evStx, _) ← resolveCallbackumOptionis cb 0
        pure <| some (← `(Signaculum.Sakura.Textus.optioEventum $t $evStx))
    else if args.size >= 3 then
      let t ← expectaStrLit args[0]! "\\q"
      -- script: キーワード附き選擇肢にゃん (\q[t, script: sc])
      if args.size == 3 then
        match extractIdentVal args[1]! with
        | some "script:" =>
          let sc ← expectaStrLit args[2]! "\\q"
          pure <| some (← `(Signaculum.Sakura.Textus.optioScriptum $t $sc))
        | _ =>
          -- \\q[t, f, rs...] — 關數/文字列附き選擇肢にゃん
          let cb := args[1]!
          let (evStx, paramTypes) ← resolveCallbackumOptionis cb (args.size - 2)
          let refArgs ← Signaculum.toRefCumTypo (args.extract 2 args.size) paramTypes
          pure <| some (← `(Signaculum.Sakura.Textus.optioEventum $t $evStx [$refArgs,*]))
      else
        -- \\q[t, f, rs...] — 關數/文字列附き選擇肢にゃん
        let cb := args[1]!
        let (evStx, paramTypes) ← resolveCallbackumOptionis cb (args.size - 2)
        let refArgs ← Signaculum.toRefCumTypo (args.extract 2 args.size) paramTypes
        pure <| some (← `(Signaculum.Sakura.Textus.optioEventum $t $evStx [$refArgs,*]))
    else
      throwErrorAt stx "\\q: 引數が不足してゐますにゃ"

  | "\\__q" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.Textus.fineOptioScopus))
    else
      let cb := args[0]!
      let (evStx, paramTypes) ← resolveCallbackumOptionis cb (args.size - 1)
      if args.size == 1 then
        pure <| some (← `(Signaculum.Sakura.Textus.optioScopus $evStx))
      else
        let refArgs ← Signaculum.toRefCumTypo (args.extract 1 args.size) paramTypes
        pure <| some (← `(Signaculum.Sakura.Textus.optioScopus $evStx [$refArgs,*]))

  -- ════════════════════════════════════════════════════
  --  文字 (Characteres)
  -- ════════════════════════════════════════════════════

  | "\\_u" =>
    if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\_u"
      pure <| some (← `(Signaculum.Sakura.Textus.characterUnicode $s))
    else
      throwErrorAt stx "\\_u: 文字列引數が1つ必要にゃ"

  | "\\_m" =>
    if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\_m"
      pure <| some (← `(Signaculum.Sakura.Textus.characterMessage $s))
    else
      throwErrorAt stx "\\_m: 文字列引數が1つ必要にゃ"

  | "\\_l" =>
    if args.size == 2 then
      let x ← expectaStrLit args[0]! "\\_l"
      let y ← expectaStrLit args[1]! "\\_l"
      pure <| some (← `(Signaculum.Sakura.Textus.cursor $x $y))
    else
      throwErrorAt stx "\\_l: 文字列引數が2つ必要にゃ"

  -- ════════════════════════════════════════════════════
  --  資源 (Resourcea)
  -- ════════════════════════════════════════════════════

  | "\\&" =>
    if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\&"
      pure <| some (← `(Signaculum.Sakura.Systema.referentiaResourcei $s))
    else
      throwErrorAt stx "\\&: 文字列引數が1つ必要にゃ"

  -- ════════════════════════════════════════════════════
  --  エスケープ (Evasiones)
  -- ════════════════════════════════════════════════════

  | "\\{" => pure <| some (← `(Signaculum.Sakura.loqui "{"))
  | "\\}" => pure <| some (← `(Signaculum.Sakura.loqui "}"))

  -- ════════════════════════════════════════════════════
  --  未處理 (Non Tractatum)
  -- ════════════════════════════════════════════════════

  -- 此のモジュールで處理できないタグは none を返して次のディスパッチへ委ねるにゃん
  | _ => pure none

end Signaculum.Notatio.Expande
