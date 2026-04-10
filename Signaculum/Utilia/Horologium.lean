-- Signaculum.Utilia.Horologium
-- タイマー/スケジューラー（ホロロギウム）にゃん♪
-- OnSecondChange 用の高レヴェルタイマー抽象を提供するにゃ

namespace Signaculum.Utilia

/-- タイマーの狀態にゃん。名前・間隔・殘り秒數を保持するにゃ -/
structure Horologium where
  /-- タイマーの識別名にゃ -/
  nomen       : String
  /-- 發火間隔（秒）にゃ -/
  intervallum : Nat
  /-- 殘り秒數にゃん -/
  residuum    : IO.Ref Nat

/-- タイマーを作成するにゃん。intervallum 秒後に最初に發火するにゃ -/
def creandum (nomen : String) (intervallum : Nat) : IO Horologium := do
  let residuum ← IO.mkRef intervallum
  return { nomen, intervallum, residuum }

/-- タイマーを1秒進めるにゃん。發火時刻に達したら true を返してリセットするにゃ -/
def pulsaHorologium (h : Horologium) : IO Bool := do
  let r ← h.residuum.get
  if r ≤ 1 then
    h.residuum.set h.intervallum
    return true
  else
    h.residuum.set (r - 1)
    return false

/-- タイマーをリセットするにゃん -/
def reinitia (h : Horologium) : IO Unit :=
  h.residuum.set h.intervallum

/-- 複數のタイマーを一括パルスするにゃん。發火したタイマーの名前を返すにゃ -/
def pulsaOmnia (horologia : Array Horologium) : IO (Array String) := do
  let mut accensae := #[]
  for h in horologia do
    let ignitum ← pulsaHorologium h
    if ignitum then
      accensae := accensae.push h.nomen
  return accensae

end Signaculum.Utilia
