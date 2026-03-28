-- Signaculum.Notatio.Expande.Fenestra
-- 窓制御・UI タグの派遣關數にゃん♪
-- \![...] と \_b[...], \z[...] をまとめて捌くにゃ
-- 大きいので Fenestra/Aperitio.lean と Fenestra/Configuratio.lean に分けたにゃん

import Lean
import Signaculum.Sakura.Scriptum
import Signaculum.Notatio.Expande.Fenestra.Aperitio
import Signaculum.Notatio.Expande.Fenestra.Configuratio

namespace Signaculum.Notatio.Expande

open Signaculum.Notatio.Expande.Fenestra
open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助：識別子を文字列にするにゃん
-- ════════════════════════════════════════════════════

/-- 引數が ident なら getId.toString (false) で名前を取るにゃ。
    str リテラルなら中身を返すにゃん -/
private def argAdNomen (arg : Syntax) : Option String :=
  if arg.isIdent then
    some (arg.getId.toString false)
  else match arg with
  | Syntax.node _ ``Lean.Parser.Term.str #[Syntax.atom _ v] =>
    -- 文字列リテラルから引用符を剥ぐにゃ
    let s := (v.drop 1 |>.dropEnd 1).toString
    some s
  | _ => none

-- ════════════════════════════════════════════════════
--  移動・可視性・速度・操作にゃん (Motus / Visibilitas / Velocitas)
-- ════════════════════════════════════════════════════

/-- `\![move,sx,sy,kx,ky]` 等の移動系を捌くにゃ -/
private def expandeMoveEtc (imperium : String) (args : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match imperium with
  | "move" =>
    if h : args.size = 4 then
      let sx := args[0]; let sy := args[1]; let kx := args[2]; let ky := args[3]
      some <$> `(Signaculum.Sakura.movere $(⟨sx⟩) $(⟨sy⟩) $(⟨kx⟩) $(⟨ky⟩))
    else
      throwErrorAt stx "\\![move,...] は引數4つ (sx,sy,kx,ky) が必要にゃ"
  | "moveasync" =>
    -- \![moveasync,cancel] の場合 args=["cancel"]
    if args.size == 1 then
      match argAdNomen args[0]! with
      | some "cancel" => some <$> `(Signaculum.Sakura.cancellaMotumAsync)
      | _ =>
        throwErrorAt stx "\\![moveasync,...] は 4引數 か cancel にゃ"
    else if h : args.size = 4 then
      let sx := args[0]; let sy := args[1]; let kx := args[2]; let ky := args[3]
      some <$> `(Signaculum.Sakura.movereAsync $(⟨sx⟩) $(⟨sy⟩) $(⟨kx⟩) $(⟨ky⟩))
    else
      throwErrorAt stx "\\![moveasync,...] は引數4つ (sx,sy,kx,ky) か cancel にゃ"
  | "vanish" =>
    if args.size == 0 then some <$> `(Signaculum.Sakura.vanesco)
    else throwErrorAt stx "\\![vanish] は引數不要にゃ"
  | "restore" =>
    if args.size == 0 then some <$> `(Signaculum.Sakura.restituere)
    else if args.size == 1 then
      let n := args[0]!
      some <$> `(Signaculum.Sakura.restituere $(⟨n⟩))
    else throwErrorAt stx "\\![restore] は引數0か1にゃ"
  | "reboot" =>
    if args.size == 0 then some <$> `(Signaculum.Sakura.renovaGhost)
    else throwErrorAt stx "\\![reboot] は引數不要にゃ"
  | "quicksession" =>
    if args.size == 1 then
      let b := args[0]!
      some <$> `(Signaculum.Sakura.sessioRapida $(⟨b⟩))
    else throwErrorAt stx "\\![quicksession,...] は引數1つにゃ"
  | "quicksection" =>
    if args.size == 1 then
      let b := args[0]!
      some <$> `(Signaculum.Sakura.sectionCeler $(⟨b⟩))
    else throwErrorAt stx "\\![quicksection,...] は引數1つにゃ"
  | "create" =>
    if args.size == 1 then
      match argAdNomen args[0]! with
      | some "shortcut" => some <$> `(Signaculum.Sakura.creaViam)
      | _ => return none
    else return none
  | "*" =>
    -- 特殊記号：args は空のはずにゃ
    some <$> `(Signaculum.Sakura.ostendeMarcam)
  | _ => return none

-- ════════════════════════════════════════════════════
--  ロック・アンロックにゃん (Sera)
-- ════════════════════════════════════════════════════

/-- `\![lock,repaint]` 系のロック・アンロックを捌くにゃん -/
private def expandeSeraEtc (imperium : String) (args : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  let primusArg := if args.size ≥ 1 then argAdNomen args[0]! else none
  let secundusArg := if args.size ≥ 2 then argAdNomen args[1]! else none
  match imperium, primusArg, secundusArg with
  | "lock", some "repaint", some "manual" =>
    some <$> `(Signaculum.Sakura.seraRepicturaManualiter)
  | "lock", some "repaint", none =>
    some <$> `(Signaculum.Sakura.seraRepictura)
  | "unlock", some "repaint", none =>
    some <$> `(Signaculum.Sakura.reseraRepictura)
  | "lock", some "balloonrepaint", some "manual" =>
    some <$> `(Signaculum.Sakura.seraRepicturaBullaeManualiter)
  | "lock", some "balloonrepaint", none =>
    some <$> `(Signaculum.Sakura.seraRepicturaBullae)
  | "unlock", some "balloonrepaint", none =>
    some <$> `(Signaculum.Sakura.reseraRepicturaBullae)
  | "lock", some "balloonmove", none =>
    some <$> `(Signaculum.Sakura.seraMotusBullae)
  | "unlock", some "balloonmove", none =>
    some <$> `(Signaculum.Sakura.reseraMotusBullae)
  | _, _, _ => return none

-- ════════════════════════════════════════════════════
--  モード制御にゃん (Modi)
-- ════════════════════════════════════════════════════

/-- `\![enter,passivemode]` 等のモード系を捌くにゃん -/
private def expandeModusEtc (imperium : String) (args : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  let primusArg := if args.size ≥ 1 then argAdNomen args[0]! else none
  let secundusArg := if args.size ≥ 2 then argAdNomen args[1]! else none
  match imperium, primusArg with
  | "enter", some "passivemode"     => some <$> `(Signaculum.Sakura.ingredereModumPassivum)
  | "leave", some "passivemode"     => some <$> `(Signaculum.Sakura.egrediereModumPassivum)
  | "enter", some "sticky"          => some <$> `(Signaculum.Sakura.ingredereSticky)
  | "leave", some "sticky"          => some <$> `(Signaculum.Sakura.egrediereSticky)
  | "enter", some "homeposition"    => some <$> `(Signaculum.Sakura.ingrederePositionemDomesticam)
  | "leave", some "homeposition"    => some <$> `(Signaculum.Sakura.egredierePositionemDomesticam)
  | "enter", some "inductionmode"   => some <$> `(Signaculum.Sakura.ingredereModumInductivum)
  | "leave", some "inductionmode"   => some <$> `(Signaculum.Sakura.egrediereModumInductivum)
  | "enter", some "collisionmode"   => some <$> `(Signaculum.Sakura.ingredereModumCollisionis)
  | "leave", some "collisionmode"   => some <$> `(Signaculum.Sakura.egrediereModumCollisionis)
  | "enter", some "onlinemode"      => some <$> `(Signaculum.Sakura.ingredereModumOnline)
  | "leave", some "onlinemode"      => some <$> `(Signaculum.Sakura.egrediereModumOnline)
  | "enter", some "nouserbreakmode" => some <$> `(Signaculum.Sakura.ingredereModumNonInterruptum)
  | "leave", some "nouserbreakmode" => some <$> `(Signaculum.Sakura.egrediereModumNonInterruptum)
  | "enter", some "selectmode" =>
    -- \![enter,selectmode, rect, collision] にゃん
    match secundusArg with
    | some "rect" =>
      if args.size ≥ 3 then
        let c := args[2]!
        some <$> `(Signaculum.Sakura.ingredereModumSelectionis .rectus $(⟨c⟩))
      else throwErrorAt stx "\\![enter,selectmode,rect,...] はコリジョン名が必要にゃ"
    | _ => throwErrorAt stx "\\![enter,selectmode,...] は rect のみ對應にゃ"
  | "leave", some "selectmode" => some <$> `(Signaculum.Sakura.egrediereModumSelectionis)
  | _, _ => return none

-- ════════════════════════════════════════════════════
--  リセット・實行にゃん (Renovatio)
-- ════════════════════════════════════════════════════

/-- `\![reset,position]` 等のリセット系を捌くにゃん -/
private def expandeResetEtc (imperium : String) (args : Array Syntax) (_ : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  let primusArg := if args.size ≥ 1 then argAdNomen args[0]! else none
  match imperium, primusArg with
  | "reset", some "position"      => some <$> `(Signaculum.Sakura.reseraPositionem)
  | "reset", some "zorder"        => some <$> `(Signaculum.Sakura.reseraOrdoFenestrarum)
  | "reset", some "sticky-window" => some <$> `(Signaculum.Sakura.resetStickyWindow)
  | "execute", some "resetballoonpos" => some <$> `(Signaculum.Sakura.renovaPositionemBullae)
  | "execute", some "resetwindowpos" => some <$> `(Signaculum.Sakura.renovaPositionemWindowae)
  | _, _ => return none

-- ════════════════════════════════════════════════════
--  主派遣關數にゃん♪ (Functio Dispatchonis Principalis)
-- ════════════════════════════════════════════════════

/-- `\![command, args...]` タグの派遣關數にゃん。
    imperium はカンマ區切りの最初の部分（"move", "set" 等）、
    args は殘りの引數配列、stx は元の構文ノードにゃ。
    處理できたら `some term`、未知なら `none` を返すにゃん♪ -/
def expandeSignumFenestrae (imperium : String) (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : Lean.Elab.Term.TermElabM (Option (Lean.TSyntax `term)) := do
  -- 移動・可視性・速度・操作にゃん
  if let some r ← expandeMoveEtc imperium args stx then return some r
  -- ロック・アンロックにゃん
  if let some r ← expandeSeraEtc imperium args stx then return some r
  -- モード制御にゃん
  if let some r ← expandeModusEtc imperium args stx then return some r
  -- リセット・實行にゃん
  if let some r ← expandeResetEtc imperium args stx then return some r
  -- 開閉（open/close）にゃん — Aperitio.lean
  if let some r ← expandeApertioEtc imperium args stx then return some r
  -- 設定（set/bind/wallpaper/balloonalign）にゃん — Configuratio.lean
  if let some r ← expandeConfiguratioEtc imperium args stx then return some r
  -- 未知のタグにゃ…
  return none

-- ════════════════════════════════════════════════════
--  基本タグ派遣にゃん（\z, \_b 等の非 \! タグ）
-- ════════════════════════════════════════════════════

/-- `\z[n]`, `\_b[...]` 等の非 `\!` 窓タグの派遣關數にゃん。
    nomen はタグ名（"z", "_b" 等）にゃ -/
def expandeSignumFenestraeBasicum (nomen : String) (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : Lean.Elab.Term.TermElabM (Option (Lean.TSyntax `term)) := do
  match nomen with
  | "\\z" =>
    -- \z[n] → zoom n にゃん
    if args.size == 1 then
      let n := args[0]!
      some <$> `(Signaculum.Sakura.zoom $(⟨n⟩))
    else
      throwErrorAt stx "\\z[n] は引數1つ（倍率）が必要にゃ"
  | "\\_b" =>
    -- \_b[v, x, y] / \_b[v, x, y, opaque] / \_b[v, inline] / \_b[v, inline, opaque]
    match args.size with
    | 2 =>
      -- \_b[v, inline] にゃん
      let v := args[0]!
      match argAdNomen args[1]! with
      | some "inline" => some <$> `(Signaculum.Sakura.imagoBullaeInlineata $(⟨v⟩))
      | _ => throwErrorAt stx "\\_b[v,...] の第2引數は座標か inline にゃ"
    | 3 =>
      let v := args[0]!
      match argAdNomen args[1]! with
      | some "inline" =>
        -- \_b[v, inline, opaque] にゃん
        match argAdNomen args[2]! with
        | some "opaque" => some <$> `(Signaculum.Sakura.imagoBullaeInlineataOpaca $(⟨v⟩))
        | _ => throwErrorAt stx "\\_b[v, inline, ...] は opaque のみにゃ"
      | _ =>
        -- \_b[v, x, y] にゃん
        let x := args[1]!; let y := args[2]!
        some <$> `(Signaculum.Sakura.imagoBullae $(⟨v⟩) $(⟨x⟩) $(⟨y⟩))
    | 4 =>
      -- \_b[v, x, y, opaque] にゃん
      let v := args[0]!; let x := args[1]!; let y := args[2]!
      match argAdNomen args[3]! with
      | some "opaque" => some <$> `(Signaculum.Sakura.imagoBullaeOpaca $(⟨v⟩) $(⟨x⟩) $(⟨y⟩))
      | _ => throwErrorAt stx "\\_b[v, x, y, ...] の第4引數は opaque のみにゃ"
    | _ => throwErrorAt stx "\\_b[...] は引數2〜4つにゃ"
  | _ => return none

end Signaculum.Notatio.Expande
