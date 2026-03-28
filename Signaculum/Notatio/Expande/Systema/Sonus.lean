-- Signaculum.Notatio.Expande.Systema.Sonus
-- 音響タグのディスパッチにゃん♪
-- sound 系サブコマンド・\_v・\8・\__v を扱ふにゃ

import Lean
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio.Expande

open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares Soni)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentValSonus (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some s.getId.toString
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

/-- 文字列リテラルを期待して取り出すにゃん -/
private def expectaStrLitSonus (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `str) := do
  match s.isStrLit? with
  | some _ => pure ⟨s⟩
  | none   => throwErrorAt s s!"{nomenSigni}: 文字列が期待されてゐますにゃ"

-- ════════════════════════════════════════════════════
--  sound サブコマンドディスパッチ (Dispatch Soni)
-- ════════════════════════════════════════════════════

/-- `\![sound,...]` のサブコマンドを展開するにゃん♪
    `args[0]` がサブコマンド名（"play"/"loop" 等）、殘りが引數にゃ -/
def expandeSonus (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  if args.size < 1 then
    throwErrorAt stx "\\![sound,...]: サブコマンドが必要にゃ"
  let sub := match extractIdentValSonus args[0]! with
    | some v => v
    | none   => ""
  match sub with

  | "play" =>
    if args.size < 2 then
      throwErrorAt stx "\\![sound,play,...]: ファイル名が必要にゃ"
    let s ← expectaStrLitSonus args[1]! "\\![sound,play]"
    pure <| some (← `(Signaculum.Sakura.sonusPulsus $s))

  | "loop" =>
    if args.size < 2 then
      throwErrorAt stx "\\![sound,loop,...]: ファイル名が必要にゃ"
    let s ← expectaStrLitSonus args[1]! "\\![sound,loop]"
    pure <| some (← `(Signaculum.Sakura.sonusOrbitans $s))

  | "stop" =>
    if args.size < 2 then
      throwErrorAt stx "\\![sound,stop,...]: ファイル名が必要にゃ"
    let s ← expectaStrLitSonus args[1]! "\\![sound,stop]"
    pure <| some (← `(Signaculum.Sakura.sonusInterrumpit $s))

  | "pause" =>
    if args.size < 2 then
      throwErrorAt stx "\\![sound,pause,...]: ファイル名が必要にゃ"
    let s ← expectaStrLitSonus args[1]! "\\![sound,pause]"
    pure <| some (← `(Signaculum.Sakura.sonusPausat $s))

  | "resume" =>
    if args.size < 2 then
      throwErrorAt stx "\\![sound,resume,...]: ファイル名が必要にゃ"
    let s ← expectaStrLitSonus args[1]! "\\![sound,resume]"
    pure <| some (← `(Signaculum.Sakura.sonusContinuat $s))

  | "wait" =>
    pure <| some (← `(Signaculum.Sakura.expectaSonumPulsus))

  | "load" =>
    if args.size < 2 then
      throwErrorAt stx "\\![sound,load,...]: ファイル名が必要にゃ"
    let s ← expectaStrLitSonus args[1]! "\\![sound,load]"
    pure <| some (← `(Signaculum.Sakura.sonusOneratur $s))

  | "cdplay" =>
    if args.size < 2 then
      throwErrorAt stx "\\![sound,cdplay,...]: トラック番號が必要にゃ"
    let n : TSyntax `term := ⟨args[1]!⟩
    pure <| some (← `(Signaculum.Sakura.sonusCD $n))

  | "option" =>
    if args.size < 3 then
      throwErrorAt stx "\\![sound,option,...]: ファイル名とオプションが必要にゃ"
    let s ← expectaStrLitSonus args[1]! "\\![sound,option]"
    let o : TSyntax `term := ⟨args[2]!⟩
    pure <| some (← `(Signaculum.Sakura.sonusOptio $s $o))

  | other =>
    throwErrorAt stx s!"\\![sound,{other},...]: 未知のサブコマンドにゃ"

end Signaculum.Notatio.Expande
