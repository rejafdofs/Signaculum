-- Signaculum.Eventum.Involucra
-- イヴェントゥムラッパーにゃん♪
-- 生の SHIORI イヴェントゥムを加工して高レヴェルな抽象を提供するにゃ
-- 里々の「つつかれ」「なでられ」「ころころ」や YAYA のシステム辭書相當にゃん

import Signaculum.Sakura.Status
import Signaculum.Protocollum.Rogatio
import Signaculum.Nucleus.Nuculum
import Signaculum.Utilia.Tempus

namespace Signaculum.Eventum

open Signaculum.Sakura
open Signaculum.Protocollum
open Signaculum.Nucleus
open Std.Time

-- ═══════════════════════════════════════════════════
-- なでられ判定 (Iudicium Tactus) にゃん
-- ═══════════════════════════════════════════════════

/-- なでられ判定の設定にゃん -/
structure ConfiguratioTactus where
  /-- なでられ判定の閾値（OnMouseMove の連續囘數にゃ）-/
  limen : Nat := 10
  /-- リセットまでの最大間隔（ミリ秒にゃ）-/
  intervallumMaximum : Nat := 2000
  deriving Repr, Inhabited

/-- なでられ判定の狀態にゃん（scope+area ごとにゃ）-/
structure StatusTactus where
  /-- 現在のカウンタにゃ -/
  computator : Nat := 0
  /-- 最後の OnMouseMove のタイムスタンプにゃん -/
  ultimumTempus : Nat := 0
  deriving Repr, Inhabited

/-- なでられ判定のグローバル設定にゃん -/
initialize configuratioTactusGlobalis : IO.Ref ConfiguratioTactus ← IO.mkRef {}

/-- なでられカウンタにゃん（"scope:area" → StatusTactus）-/
initialize tabulaTactus : IO.Ref (List (String × StatusTactus)) ← IO.mkRef []

/-- なでられ判定の閾値を設定するにゃん -/
def configuraNaderareLimen (limen : Nat) : IO Unit :=
  configuratioTactusGlobalis.modify fun c => { c with limen }

/-- なでられ判定の間隔を設定するにゃん（ミリ秒にゃ）-/
def configuraNaderareIntervallum (ms : Nat) : IO Unit :=
  configuratioTactusGlobalis.modify fun c => { c with intervallumMaximum := ms }

/-- OnMouseMove から「なでられ」判定をするにゃん♪
    連續移動が閾値を超えたら true を返すにゃ。
    scope + area をキーにしてカウントするにゃん -/
def iudicaNaderare (scopeId areaName : String) : IO Bool := do
  let clavis := scopeId ++ ":" ++ areaName
  let config ← configuratioTactusGlobalis.get
  let nunc ← Timestamp.now
  let nuncMs := nunc.toMillisecondsSinceUnixEpoch.toNat
  let tabula ← tabulaTactus.get
  let status := match tabula.lookup clavis with
    | some s => s
    | none => {}
  -- 前囘から時間が經ちすぎてゐたらリセットにゃん
  let elapsed := nuncMs - status.ultimumTempus
  let novusStatus : StatusTactus :=
    if elapsed > config.intervallumMaximum then
      { computator := 1, ultimumTempus := nuncMs }
    else
      { computator := status.computator + 1, ultimumTempus := nuncMs }
  -- テーブル更新にゃん
  let tabulaNova := tabula.filter (fun (k, _) => k != clavis) ++ [(clavis, novusStatus)]
  tabulaTactus.set tabulaNova
  -- 閾値判定にゃん
  if novusStatus.computator ≥ config.limen then
    -- 發火後リセットにゃ
    let tabulaReset := tabulaNova.filter (fun (k, _) => k != clavis)
    tabulaTactus.set tabulaReset
    return true
  else
    return false

-- ═══════════════════════════════════════════════════
-- マウスイヴェントゥム分配 (Distributio Muris) にゃん
-- ═══════════════════════════════════════════════════

/-- OnMouseDoubleClick 等のマウスイヴェントゥムから
    "{scopeId}{areaName}{suffix}" 形式のイヴェントゥム名を生成するにゃん♪
    里々の「＊0HEADつつかれ」に相當するにゃ -/
def nomenEventumMusis (rogatio : Rogatio) (suffix : String) : String :=
  let scopeId := (rogatio.referentiam 3).getD ""
  let areaName := (rogatio.referentiam 4).getD ""
  s!"{scopeId}{areaName}{suffix}"

-- ═══════════════════════════════════════════════════
-- ランダムトークタイマー (Horologium Colloquii) にゃん
-- ═══════════════════════════════════════════════════

/-- ランダムトーク間隔（秒にゃ）-/
initialize intervallumColloquii : IO.Ref Nat ← IO.mkRef 180

/-- ランダムトークカウンタ（殘り秒數にゃ）-/
initialize computatorColloquii : IO.Ref Nat ← IO.mkRef 180

/-- ランダムトーク間隔を設定するにゃん -/
def configuraIntervallumColloquii (secundae : Nat) : IO Unit := do
  intervallumColloquii.set secundae
  computatorColloquii.set secundae

/-- OnSecondChange でランダムトークタイマーをパルスするにゃん♪
    0 に達したら true を返すにゃ（ランダムトーク發火するにゃん）-/
def pulsaTimerColloquii (status : Option String) : IO Bool := do
  -- ゴーストが話し中/選擇肢提示中なら發火しにゃいにゃ
  match status with
  | some "talking" | some "choosing" => return false
  | _ => pure ()
  let residuum ← computatorColloquii.get
  if residuum ≤ 1 then
    -- タイマーリセットにゃん
    let intervallum ← intervallumColloquii.get
    computatorColloquii.set intervallum
    return true
  else
    computatorColloquii.set (residuum - 1)
    return false

end Signaculum.Eventum
