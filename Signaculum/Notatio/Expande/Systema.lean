-- Signaculum.Notatio.Expande.Systema
-- システムサクラスクリプトゥム `\![]` タグのディスパッチ函數にゃん♪
-- 事象・音響・動畫・HTTP・呼出・設定等を統一的に elaboration 型で處理するにゃ
--
-- 構造:
--   Systema/Eventum.lean  — raise/embed/notify/timer 事象にゃん
--   Systema/Sonus.lean    — sound 系・\_v・\8 音響にゃん
--   Systema/Animatio.lean — anim 系動畫制御にゃん
--   Systema/Rete.lean     — execute 系 HTTP/ネットワークにゃん
--   Systema/Reliqua.lean  — call/change/bind/effect/set/get 等の殘餘にゃん

import Lean
import Signaculum.Sakura.Scriptum
import Signaculum.Notatio.Expande.Systema.Eventum
import Signaculum.Notatio.Expande.Systema.Sonus
import Signaculum.Notatio.Expande.Systema.Animatio
import Signaculum.Notatio.Expande.Systema.Rete
import Signaculum.Notatio.Expande.Systema.Reliqua

namespace Signaculum.Notatio.Expande

open Signaculum.Notatio.Expande.Systema
open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentValSystema (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some (s.getId.toString (escape := false))
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

/-- 文字列リテラルを期待して取り出すにゃん -/
private def expectaStrLitSys (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `str) := do
  match s.isStrLit? with
  | some _ => pure ⟨s⟩
  | none   => throwErrorAt s s!"{nomenSigni}: 文字列が期待されてゐますにゃ"

-- ════════════════════════════════════════════════════
--  主ディスパッチ函數 (Functio Principalis Dispatchonis Systematis)
-- ════════════════════════════════════════════════════

/-- `\![imperium, args...]` のディスパッチにゃん♪
    カスタムパーサーから受け取る `imperium` は `[]` 內の最初のカンマ區切り部分にゃ。
    例: `\![raise, e]` → imperium="raise", args=#[e]
        `\![sound,play, s]` → imperium="sound", args=#["play", s]
    處理できたら `some term` を返し、未知のタグは `none` を返すにゃん -/
def expandeSignumSystematis (imperium : String) (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match imperium with

  -- ────────────────────────────────────────────────
  --  事象系にゃん（raise/embed/notify/timer/raiseother 等）
  -- ────────────────────────────────────────────────

  | "raise" | "embed" | "notify"
  | "timerraise" | "timernotify"
  | "raiseother" | "notifyother"
  | "timerraiseother" | "timernotifyother"
  | "raiseplugin" | "notifyplugin"
  | "timerraiseplugin" | "timernotifyplugin"
  | "async" =>
    expandeEventum imperium args stx

  -- ────────────────────────────────────────────────
  --  音響系にゃん（sound サブコマンドにゃ）
  -- ────────────────────────────────────────────────

  | "sound" =>
    expandeSonus args stx

  -- ────────────────────────────────────────────────
  --  動畫系にゃん（anim サブコマンドにゃ）
  -- ────────────────────────────────────────────────

  | "anim" =>
    expandeAnimatio args stx

  -- ────────────────────────────────────────────────
  --  HTTP/ネットワーク/實行系にゃん（execute サブコマンドにゃ）
  -- ────────────────────────────────────────────────

  | "execute" =>
    expandeExecutio args stx

  -- ────────────────────────────────────────────────
  --  殘餘にゃん（call/change/bind/effect/set/get/filter 等）
  -- ────────────────────────────────────────────────

  | "call" | "change"
  | "updatebymyself" | "vanishbymyself" | "executesntp" | "reloadsurface"
  | "reload" | "unload" | "load"
  | "bind" | "effect" | "effect2"
  | "biff"
  | "set" | "get"
  | "filter"
  | "wait" | "update" =>
    expandeReliqua imperium args stx

  -- ────────────────────────────────────────────────
  --  未處理にゃん
  -- ────────────────────────────────────────────────

  | _ => pure none

-- ════════════════════════════════════════════════════
--  非 \! 系タグのディスパッチ (Dispatch Basicum)
-- ════════════════════════════════════════════════════

/-- `\!` 以外のシステムタグのディスパッチにゃん♪
    `\_v[s]`、`\8[s]`、`\m[u,w,l]`、`\__v[o]` を扱ふにゃ。
    `nomen` はタグ名（例: "\\_v"）、`args` はブラケット內の引數配列にゃ。
    處理できたら `some term` を返すにゃん -/
def expandeSignumSystematisBasicum (nomen : String) (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match nomen with

  -- ────────────────────────────────────────────────
  --  \_v — 音聲再生にゃん
  -- ────────────────────────────────────────────────

  | "\\_v" =>
    if args.size < 1 then
      throwErrorAt stx "\\_v: ファイル名が必要にゃ"
    let s ← expectaStrLitSys args[0]! "\\_v"
    pure <| some (← `(Signaculum.Sakura.sonus $s))

  -- ────────────────────────────────────────────────
  --  \8 — 簡易波形再生にゃん
  -- ────────────────────────────────────────────────

  | "\\8" =>
    if args.size < 1 then
      throwErrorAt stx "\\8: ファイル名が必要にゃ"
    let s ← expectaStrLitSys args[0]! "\\8"
    pure <| some (← `(Signaculum.Sakura.sonus8 $s))

  -- ────────────────────────────────────────────────
  --  \m — Windows メッセージにゃん
  -- ────────────────────────────────────────────────

  | "\\m" =>
    if args.size < 3 then
      throwErrorAt stx "\\m: umsg, wparam, lparam の3引數が必要にゃ"
    let u ← expectaStrLitSys args[0]! "\\m"
    let w ← expectaStrLitSys args[1]! "\\m"
    let l ← expectaStrLitSys args[2]! "\\m"
    pure <| some (← `(Signaculum.Sakura.nuntiumWindowae $u $w $l))

  -- ────────────────────────────────────────────────
  --  \__v — 音聲合成にゃん
  -- ────────────────────────────────────────────────

  | "\\__v" =>
    if args.size < 1 then
      throwErrorAt stx "\\__v: オプションが必要にゃ"
    let o ← expectaStrLitSys args[0]! "\\__v"
    pure <| some (← `(Signaculum.Sakura.synthesisVocis $o))

  -- ────────────────────────────────────────────────
  --  未處理にゃん — 次のディスパッチへ委ねるにゃ
  -- ────────────────────────────────────────────────

  | _ => pure none

end Signaculum.Notatio.Expande
