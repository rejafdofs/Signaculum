-- Signaculum.Notatio.Expande.Systema.Animatio
-- 動畫制御タグのディスパッチにゃん♪
-- anim 系サブコマンドを扱ふにゃ

import Lean
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio.Expande

open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares Animationis)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentValAnimatio (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some (s.getId.toString (escape := false))
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

-- ════════════════════════════════════════════════════
--  anim サブコマンドディスパッチ (Dispatch Animationis)
-- ════════════════════════════════════════════════════

/-- `\![anim,...]` のサブコマンドを展開するにゃん♪
    `args[0]` がサブコマンド名（"start"/"stop" 等）、殘りが引數にゃ -/
def expandeAnimatio (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  if args.size < 1 then
    throwErrorAt stx "\\![anim,...]: サブコマンドが必要にゃ"
  let sub := match extractIdentValAnimatio args[0]! with
    | some v => v
    | none   => ""
  match sub with

  -- ────────────────────────────────────────────────
  --  基本制御にゃん
  -- ────────────────────────────────────────────────

  | "start" =>
    if args.size < 3 then
      throwErrorAt stx "\\![anim,start,...]: scopus, id の2引數が必要にゃ"
    let s : TSyntax `term := ⟨args[1]!⟩
    let i : TSyntax `term := ⟨args[2]!⟩
    pure <| some (← `(Signaculum.Sakura.animaIncepit $s $i))

  | "stop" =>
    if args.size < 3 then
      throwErrorAt stx "\\![anim,stop,...]: scopus, id の2引數が必要にゃ"
    let s : TSyntax `term := ⟨args[1]!⟩
    let i : TSyntax `term := ⟨args[2]!⟩
    pure <| some (← `(Signaculum.Sakura.animaDesinit $s $i))

  | "pause" =>
    if args.size < 3 then
      throwErrorAt stx "\\![anim,pause,...]: scopus, id の2引數が必要にゃ"
    let s : TSyntax `term := ⟨args[1]!⟩
    let i : TSyntax `term := ⟨args[2]!⟩
    pure <| some (← `(Signaculum.Sakura.animaPausat $s $i))

  | "resume" =>
    if args.size < 3 then
      throwErrorAt stx "\\![anim,resume,...]: scopus, id の2引數が必要にゃ"
    let s : TSyntax `term := ⟨args[1]!⟩
    let i : TSyntax `term := ⟨args[2]!⟩
    pure <| some (← `(Signaculum.Sakura.animaContinuat $s $i))

  | "clear" =>
    if args.size < 3 then
      throwErrorAt stx "\\![anim,clear,...]: scopus, id の2引數が必要にゃ"
    let s : TSyntax `term := ⟨args[1]!⟩
    let i : TSyntax `term := ⟨args[2]!⟩
    pure <| some (← `(Signaculum.Sakura.animaPurgat $s $i))

  -- ────────────────────────────────────────────────
  --  オフセットにゃん
  -- ────────────────────────────────────────────────

  | "offset" =>
    if args.size < 5 then
      throwErrorAt stx "\\![anim,offset,...]: scopus, id, x, y の4引數が必要にゃ"
    let s : TSyntax `term := ⟨args[1]!⟩
    let i : TSyntax `term := ⟨args[2]!⟩
    let x : TSyntax `term := ⟨args[3]!⟩
    let y : TSyntax `term := ⟨args[4]!⟩
    pure <| some (← `(Signaculum.Sakura.animaTranslatio $s $i $x $y))

  -- ────────────────────────────────────────────────
  --  add 系にゃん（args[1] がさらにサブコマンドにゃ）
  -- ────────────────────────────────────────────────

  | "add" =>
    if args.size < 2 then
      throwErrorAt stx "\\![anim,add,...]: サブコマンドが必要にゃ"
    let addSub := match extractIdentValAnimatio args[1]! with
      | some v => v
      | none   => ""
    match addSub with

    | "overlay" =>
      if args.size == 3 then
        -- \![anim,add,overlay, id]
        let i : TSyntax `term := ⟨args[2]!⟩
        pure <| some (← `(Signaculum.Sakura.animaAddOverlay $i))
      else if args.size >= 5 then
        -- \![anim,add,overlay, id, x, y]
        let i : TSyntax `term := ⟨args[2]!⟩
        let x : TSyntax `term := ⟨args[3]!⟩
        let y : TSyntax `term := ⟨args[4]!⟩
        pure <| some (← `(Signaculum.Sakura.animaAddOverlayPos $i $x $y))
      else
        throwErrorAt stx "\\![anim,add,overlay,...]: id (または id, x, y) が必要にゃ"

    | "overlayfast" =>
      if args.size < 3 then
        throwErrorAt stx "\\![anim,add,overlayfast,...]: id が必要にゃ"
      let i : TSyntax `term := ⟨args[2]!⟩
      pure <| some (← `(Signaculum.Sakura.animaAddOverlayFast $i))

    | "base" =>
      if args.size < 3 then
        throwErrorAt stx "\\![anim,add,base,...]: id が必要にゃ"
      let i : TSyntax `term := ⟨args[2]!⟩
      pure <| some (← `(Signaculum.Sakura.animaAddBase $i))

    | "move" =>
      if args.size < 4 then
        throwErrorAt stx "\\![anim,add,move,...]: x, y の2引數が必要にゃ"
      let x : TSyntax `term := ⟨args[2]!⟩
      let y : TSyntax `term := ⟨args[3]!⟩
      pure <| some (← `(Signaculum.Sakura.animaAddMove $x $y))

    | other =>
      throwErrorAt stx s!"\\![anim,add,{other},...]: 未知のサブコマンドにゃ"

  | other =>
    throwErrorAt stx s!"\\![anim,{other},...]: 未知のサブコマンドにゃ"

end Signaculum.Notatio.Expande
