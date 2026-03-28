-- Signaculum.Notatio.Expande.Textus
-- テクストゥス・基本サクラスクリプトゥム・タグのディスパッチ關數にゃん♪
-- 舊い syntax + macro_rules を統一的な elaboration 型に置き換へるにゃ

import Lean
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio.Expande

open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentVal (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some s.getId.toString
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

/-- 數値リテラルかどうか確認して取り出すにゃん -/
private def expectaNatLit (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `num) := do
  if s.isNatLit? then
    pure ⟨s⟩
  else
    throwErrorAt s s!"{nomenSigni}: []の中には数字が期待されてゐますにゃ"

/-- 文字列リテラルかどうか確認して取り出すにゃん -/
private def expectaStrLit (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `str) := do
  if s.isStrLit? then
    pure ⟨s⟩
  else
    throwErrorAt s s!"{nomenSigni}: []の中には文字列が期待されてゐますにゃ"

/-- -1 パターンを檢出するにゃん。ident "-1" またはアトム "-" + numLit "1" の兩方に對應にゃ -/
private def estNegativusUnus (args : Array Lean.Syntax) : Bool :=
  -- パターン1: 單一の ident/atom "-1"
  if args.size == 1 then
    match extractIdentVal args[0]! with
    | some s => s == "-1"
    | none   => false
  -- パターン2: atom "-" に續いて numLit "1"
  else if args.size == 2 then
    match extractIdentVal args[0]! with
    | some "-" =>
      match args[1]!.isNatLit? with
      | true  =>
        match args[1]!.isNatLit?, args[1]!.raw.isLit `num with
        | true, true => args[1]!.raw.getAtomVal == "1"
        | _, _       => false
      | false => false
    | _ => false
  else false

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

  | "\\h" => pure <| some (← `(Signaculum.Sakura.sakura))
  | "\\u" => pure <| some (← `(Signaculum.Sakura.kero))
  | "\\0" => pure <| some (← `(Signaculum.Sakura.sakura))
  | "\\1" => pure <| some (← `(Signaculum.Sakura.kero))

  | "\\p" =>
    if args.size != 1 then
      throwErrorAt stx "\\p: 引數が1つ必要にゃ"
    let n ← expectaNatLit args[0]! "\\p"
    pure <| some (← `(Signaculum.Sakura.persona $n))

  -- ════════════════════════════════════════════════════
  --  表面制御 (Imperium Superficiei)
  -- ════════════════════════════════════════════════════

  | "\\s" =>
    if estNegativusUnus args then
      pure <| some (← `(Signaculum.Sakura.superficiesAbsconde))
    else if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\s"
      pure <| some (← `(Signaculum.Sakura.superficies $n))
    else
      throwErrorAt stx "\\s: 引數が不正にゃ"

  | "\\i" =>
    if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\i"
      pure <| some (← `(Signaculum.Sakura.animatio $n))
    else if args.size == 2 then
      let n ← expectaNatLit args[0]! "\\i"
      match extractIdentVal args[1]! with
      | some "wait" => pure <| some (← `(Signaculum.Sakura.animatioExpecta $n))
      | _           => throwErrorAt stx "\\i: 第2引數は 'wait' が期待されてゐますにゃ"
    else
      throwErrorAt stx "\\i: 引數が不正にゃ"

  -- ════════════════════════════════════════════════════
  --  改行 (Lineae)
  -- ════════════════════════════════════════════════════

  | "\\n" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.linea))
    else if args.size == 1 then
      match extractIdentVal args[0]! with
      | some "half" => pure <| some (← `(Signaculum.Sakura.dimidiaLinea))
      | _           => throwErrorAt stx "\\n: 不明な引數にゃ"
    else if args.size == 2 then
      match extractIdentVal args[0]! with
      | some "percent" =>
        let n ← expectaNatLit args[1]! "\\n"
        pure <| some (← `(Signaculum.Sakura.lineaProportionalis $n))
      | _ => throwErrorAt stx "\\n: 不明な引數にゃ"
    else
      throwErrorAt stx "\\n: 引數が多すぎるにゃ"

  | "\\_n" => pure <| some (← `(Signaculum.Sakura.linearisAbrogatur))

  -- ════════════════════════════════════════════════════
  --  清掃 (Purgatio)
  -- ════════════════════════════════════════════════════

  | "\\c" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.purga))
    else if args.size == 2 then
      match extractIdentVal args[0]! with
      | some "char" =>
        let n ← expectaNatLit args[1]! "\\c"
        pure <| some (← `(Signaculum.Sakura.purgaCharacterem $n))
      | some "line" =>
        let n ← expectaNatLit args[1]! "\\c"
        pure <| some (← `(Signaculum.Sakura.purgaLineam $n))
      | _ => throwErrorAt stx "\\c: 不明な引數にゃ"
    else if args.size == 3 then
      match extractIdentVal args[0]! with
      | some "char" =>
        let n ← expectaNatLit args[1]! "\\c"
        let i ← expectaNatLit args[2]! "\\c"
        pure <| some (← `(Signaculum.Sakura.purgaCharacteremAb $n $i))
      | some "line" =>
        let n ← expectaNatLit args[1]! "\\c"
        let i ← expectaNatLit args[2]! "\\c"
        pure <| some (← `(Signaculum.Sakura.purgaLineamAb $n $i))
      | _ => throwErrorAt stx "\\c: 不明な引數にゃ"
    else
      throwErrorAt stx "\\c: 引數が不正にゃ"

  | "\\C" => pure <| some (← `(Signaculum.Sakura.adscribe))

  -- ════════════════════════════════════════════════════
  --  待機 (Mora)
  -- ════════════════════════════════════════════════════

  | "\\w" =>
    if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\w"
      pure <| some (← `(Signaculum.Sakura.moraCeler $n))
    else
      throwErrorAt stx "\\w: 數値引數が1つ必要にゃ"

  | "\\_w" =>
    if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\_w"
      pure <| some (← `(Signaculum.Sakura.mora $n))
    else
      throwErrorAt stx "\\_w: 數値引數が1つ必要にゃ"

  | "\\__w" =>
    if args.size == 1 then
      match extractIdentVal args[0]! with
      | some "clear" => pure <| some (← `(Signaculum.Sakura.reseraTimerSynchrinae))
      | _ =>
        let n ← expectaNatLit args[0]! "\\__w"
        pure <| some (← `(Signaculum.Sakura.moraAbsoluta $n))
    else if args.size == 2 then
      match extractIdentVal args[0]! with
      | some "animation" =>
        let n ← expectaNatLit args[1]! "\\__w"
        pure <| some (← `(Signaculum.Sakura.moraAnimationem $n))
      | _ => throwErrorAt stx "\\__w: 不明な引數にゃ"
    else
      throwErrorAt stx "\\__w: 引數が不正にゃ"

  | "\\x" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.expecta))
    else if args.size == 1 then
      match extractIdentVal args[0]! with
      | some "noclear" => pure <| some (← `(Signaculum.Sakura.expectaSine))
      | _              => throwErrorAt stx "\\x: 不明な引數にゃ"
    else
      throwErrorAt stx "\\x: 引數が不正にゃ"

  | "\\t" => pure <| some (← `(Signaculum.Sakura.tempusCriticum))

  -- ════════════════════════════════════════════════════
  --  制御 (Imperium)
  -- ════════════════════════════════════════════════════

  | "\\e"  => pure <| some (← `(Signaculum.Sakura.finis))
  | "\\_q" => pure <| some (← `(Signaculum.Sakura.celer))
  | "\\-"  => pure <| some (← `(Signaculum.Sakura.exitus))
  | "\\+"  => pure <| some (← `(Signaculum.Sakura.mutaGhost))
  | "\\*"  => pure <| some (← `(Signaculum.Sakura.prohibeTempus))
  | "\\_+" => pure <| some (← `(Signaculum.Sakura.mutaGhostSequens))
  | "\\v"  => pure <| some (← `(Signaculum.Sakura.togglaSupra))
  | "\\4"  => pure <| some (← `(Signaculum.Sakura.recede))
  | "\\5"  => pure <| some (← `(Signaculum.Sakura.accede))
  | "\\6"  => pure <| some (← `(Signaculum.Sakura.syncTempus))
  | "\\7"  => pure <| some (← `(Signaculum.Sakura.eventumTempus))
  | "\\_?" => pure <| some (← `(Signaculum.Sakura.inhibeTagas))
  | "\\_V" => pure <| some (← `(Signaculum.Sakura.expectaSonum))

  -- ════════════════════════════════════════════════════
  --  同期 (Synchronia)
  -- ════════════════════════════════════════════════════

  | "\\_s" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.synchrona))
    else
      -- 可變長數値リストにゃん
      let mut termElems : Array (TSyntax `term) := #[]
      for h : idx in [:args.size] do
        let n ← expectaNatLit args[idx] "\\_s"
        termElems := termElems.push (← `(term| $n))
      pure <| some (← `(Signaculum.Sakura.synchronaScopi [$termElems,*]))

  -- ════════════════════════════════════════════════════
  --  吹出し (Bulla)
  -- ════════════════════════════════════════════════════

  | "\\b" =>
    if estNegativusUnus args then
      pure <| some (← `(Signaculum.Sakura.bullaAbsconde))
    else if args.size == 1 then
      let n ← expectaNatLit args[0]! "\\b"
      pure <| some (← `(Signaculum.Sakura.bulla $n))
    else
      throwErrorAt stx "\\b: 引數が不正にゃ"

  -- ════════════════════════════════════════════════════
  --  跳躍 (Saltum)
  -- ════════════════════════════════════════════════════

  | "\\j" =>
    if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\j"
      pure <| some (← `(Signaculum.Sakura.saltum $s))
    else
      throwErrorAt stx "\\j: 文字列引數が1つ必要にゃ"

  -- ════════════════════════════════════════════════════
  --  錨 (Ancora)
  -- ════════════════════════════════════════════════════

  | "\\_a" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.fineAncora))
    else if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\_a"
      pure <| some (← `(Signaculum.Sakura.ancora $s))
    else
      throwErrorAt stx "\\_a: 引數が不正にゃ"

  -- ════════════════════════════════════════════════════
  --  選擇肢 (Optiones)
  -- ════════════════════════════════════════════════════

  | "\\q" =>
    if args.size == 2 then
      let t ← expectaStrLit args[0]! "\\q"
      -- script: プレフィクスの特別處理にゃん
      match extractIdentVal args[1]! with
      | some idVal =>
        if idVal.startsWith "script:" then
          -- "script:..." 形式の場合、ident として來てゐるかもにゃ
          -- ただし通常はパーサーが分離するので strLit を先に試すにゃん
          throwErrorAt stx "\\q: script: 形式は專用構文を使つてにゃ"
        else
          let id ← expectaStrLit args[1]! "\\q"
          pure <| some (← `(Signaculum.Sakura.optio $t $id))
      | none =>
        -- 第2引數が strLit の場合にゃん
        let id ← expectaStrLit args[1]! "\\q"
        pure <| some (← `(Signaculum.Sakura.optio $t $id))
    else if args.size >= 3 then
      let t ← expectaStrLit args[0]! "\\q"
      -- script: プレフィクスの檢出にゃん
      if args.size == 2 then
        -- ここには來ないにゃ（上で處理濟み）
        pure none
      else
        -- \\q[t, e, rs...] — イヴェントゥム附き選擇肢にゃん
        let e ← expectaStrLit args[1]! "\\q"
        let mut termElems : Array (TSyntax `term) := #[]
        for h : idx in [2:args.size] do
          let r ← expectaStrLit args[idx] "\\q"
          termElems := termElems.push (← `(term| $r))
        pure <| some (← `(Signaculum.Sakura.optioEventum $t $e [$termElems,*]))
    else
      throwErrorAt stx "\\q: 引數が不足してゐますにゃ"

  | "\\__q" =>
    if args.size == 0 then
      pure <| some (← `(Signaculum.Sakura.fineOptioScopus))
    else if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\__q"
      pure <| some (← `(Signaculum.Sakura.optioScopus $s))
    else
      throwErrorAt stx "\\__q: 引數が不正にゃ"

  -- ════════════════════════════════════════════════════
  --  文字 (Characteres)
  -- ════════════════════════════════════════════════════

  | "\\_u" =>
    if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\_u"
      pure <| some (← `(Signaculum.Sakura.characterUnicode $s))
    else
      throwErrorAt stx "\\_u: 文字列引數が1つ必要にゃ"

  | "\\_m" =>
    if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\_m"
      pure <| some (← `(Signaculum.Sakura.characterMessage $s))
    else
      throwErrorAt stx "\\_m: 文字列引數が1つ必要にゃ"

  | "\\_l" =>
    if args.size == 2 then
      let x ← expectaStrLit args[0]! "\\_l"
      let y ← expectaStrLit args[1]! "\\_l"
      pure <| some (← `(Signaculum.Sakura.cursor $x $y))
    else
      throwErrorAt stx "\\_l: 文字列引數が2つ必要にゃ"

  -- ════════════════════════════════════════════════════
  --  資源 (Resourcea)
  -- ════════════════════════════════════════════════════

  | "\\&" =>
    if args.size == 1 then
      let s ← expectaStrLit args[0]! "\\&"
      pure <| some (← `(Signaculum.Sakura.referentiaResourcei $s))
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
