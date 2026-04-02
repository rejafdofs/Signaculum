-- Signaculum.Sakura.Textus.Catena
-- チェイントーク（連鎖對話）支援にゃん♪
-- 複數の對話を順番に再生する仕組みにゃ。OnAITalk で通常トークと混ぜて使へるにゃん

import Signaculum.Sakura.Fundamentum

namespace Signaculum.Sakura.Textus

-- ═══════════════════════════════════════════════════
-- 型定義 (Typi) にゃん
-- ═══════════════════════════════════════════════════

/-- チェイントークの定義にゃん。名前・話の配列・位置の參照を持つにゃ -/
structure Catena where
  /-- チェインの識別名にゃ。永續化時のキーに使ふにゃん -/
  nomen     : String
  /-- 順番に再生する話の配列にゃ -/
  colloquia : Array (SakuraIO Unit)
  /-- 現在位置にゃん。永續化對象の IO.Ref にゃ -/
  positio   : IO.Ref Nat

/-- 混合プールの選擇肢にゃん。通常トークかチェイントークかを區別するにゃ -/
inductive OptioPiscinae
  /-- 通常の單發トークにゃん -/
  | simplex (actio : SakuraIO Unit)
  /-- チェイントーク（Catena への參照）にゃん -/
  | catena (c : Catena)

-- ═══════════════════════════════════════════════════
-- グローバル状態 (Status Globalis) にゃん
-- ═══════════════════════════════════════════════════

/-- 活動中のチェイントーク名にゃん。none なら通常選擇モードにゃ -/
initialize catenaActiva : IO.Ref (Option String) ← IO.mkRef none

-- ═══════════════════════════════════════════════════
-- チェイン實行 (Executio Catenae) にゃん
-- ═══════════════════════════════════════════════════

/-- チェインの現在位置の話を實行して位置を進めるにゃん。
    末尾到達時はリセットして catenaActiva を none にするにゃ。
    空チェインは何もしないにゃん♪ -/
def exequiCatenam (c : Catena) : SakuraIO Unit := do
  let pos ← liftM c.positio.get
  let n := c.colloquia.size
  if h : n = 0 then
    pure ()
  else if h2 : pos < n then
    c.colloquia[pos]'h2
    if pos + 1 < n then
      liftM (c.positio.set (pos + 1))
    else
      -- チェイン完了にゃ。リセットするにゃん
      liftM (c.positio.set 0)
      liftM (catenaActiva.set none)
  else
    -- 位置が範圍外にゃ。リセットするにゃん
    liftM (c.positio.set 0)
    liftM (catenaActiva.set none)

-- ═══════════════════════════════════════════════════
-- 混合プール選擇 (Electio Piscinae) にゃん
-- ═══════════════════════════════════════════════════

/-- 混合プールの中からチェイン優先でランダム選擇するにゃん。
    活動中のチェインがあればそれを續行し、なければランダムに選ぶにゃ。
    チェインが選ばれたら第一話を再生して次回のために狀態を更新するにゃん♪ -/
def eligeVelCatena (optiones : Array OptioPiscinae) : SakuraIO Unit := do
  let activa ← liftM catenaActiva.get
  match activa with
  | some nomen =>
    -- 活動中チェインを探すにゃん
    let mut inventa := false
    for opt in optiones do
      match opt with
      | .catena c =>
        if c.nomen == nomen then
          exequiCatenam c
          inventa := true
          break
      | _ => pure ()
    -- 見つからなかったらリセットしてランダム選擇にフォールバックにゃ
    unless inventa do
      liftM (catenaActiva.set none)
      eligeExOptionibus optiones
  | none =>
    eligeExOptionibus optiones
where
  /-- オプション配列からランダムに一つ選んで實行するにゃん -/
  eligeExOptionibus (optiones : Array OptioPiscinae) : SakuraIO Unit := do
    let n := optiones.size
    if h : n = 0 then pure ()
    else
      let idx ← liftM (IO.rand 0 (n - 1))
      let i := idx % n
      have hi : i < n := Nat.mod_lt idx (by omega)
      match optiones[i]'hi with
      | .simplex actio => actio
      | .catena c =>
        -- チェイン開始にゃん♪
        liftM (catenaActiva.set (some c.nomen))
        exequiCatenam c

-- ═══════════════════════════════════════════════════
-- ユーティリティ (Utilitates) にゃん
-- ═══════════════════════════════════════════════════

/-- 活動中のチェイントークを強制リセットするにゃん -/
def resiceCatenam : IO Unit :=
  catenaActiva.set none

end Signaculum.Sakura.Textus
