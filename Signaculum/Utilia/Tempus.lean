-- Signaculum.Utilia.Tempus
-- 日時ユーティリティーにゃん♪
-- Std.Time を活用してゴースト開發向け便利關數を提供するにゃ

import Std.Time

namespace Signaculum.Utilia

open Std.Time

-- ═══════════════════════════════════════════════════
-- 現在時刻取得 (Obtentio Temporis) にゃん
-- ═══════════════════════════════════════════════════

/-- 現在時刻を PlainDateTime（UTC）として取得するにゃん♪
    ゴーストの時間帶判定やログのタイムスタンプに使ふにゃ -/
def obtineTempus : IO PlainDateTime := do
  let ts ← Timestamp.now
  return PlainDateTime.ofTimestampAssumingUTC ts

/-- 現在の Unix タイムスタンプを取得するにゃん -/
def obtineTimestamp : IO Timestamp := Timestamp.now

-- ═══════════════════════════════════════════════════
-- 時間帶判定 (Iudicium Temporis) にゃん
-- ═══════════════════════════════════════════════════

/-- 時 (hora) を Int として取得するヘルパーにゃん -/
private def horaAdInt (dt : PlainDateTime) : Int :=
  dt.hour.val

/-- 朝かどうか判定するにゃん（6 ≤ hora < 12）-/
def estMane (dt : PlainDateTime) : Bool :=
  let h := horaAdInt dt
  6 ≤ h && h < 12

/-- 晝かどうか判定するにゃん（12 ≤ hora < 18）-/
def estMeridies (dt : PlainDateTime) : Bool :=
  let h := horaAdInt dt
  12 ≤ h && h < 18

/-- 夕方かどうか判定するにゃん（18 ≤ hora < 24）-/
def estVespera (dt : PlainDateTime) : Bool :=
  let h := horaAdInt dt
  18 ≤ h && h < 24

/-- 夜かどうか判定するにゃん（0 ≤ hora < 6）-/
def estNox (dt : PlainDateTime) : Bool :=
  let h := horaAdInt dt
  0 ≤ h && h < 6

-- ═══════════════════════════════════════════════════
-- 書式化 (Formatio) にゃん
-- ═══════════════════════════════════════════════════

/-- 2桁にゼロ埋めするにゃん -/
private def padZero (n : Int) : String :=
  let abs := if n < 0 then -n else n
  let digits := Nat.toDigits 10 abs.toNat
  if digits.length < 2 then String.mk ('0' :: digits) else String.mk digits

/-- PlainDateTime を "YYYY-MM-DD HH:MM:SS" 形式の文字列にするにゃん -/
def tempusAdTextum (dt : PlainDateTime) : String :=
  s!"{dt.year}-{padZero dt.month.val}-{padZero dt.day.val} {padZero dt.hour.val}:{padZero dt.minute.val}:{padZero dt.second.val}"

end Signaculum.Utilia
