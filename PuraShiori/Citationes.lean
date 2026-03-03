-- PuraShiori.Citationes
-- SHIORI Reference の型安全な相互変換クラスにゃん♪
-- fromRef (toRef a) = a が型クラスの法則として保証されるにゃ

namespace PuraShiori

/-- 値を SHIORI Reference 文字列に変換し、逆変換も保証される型クラスにゃん。
    `toRef` で直列化・`fromRef` で復元。
    `roundtrip : ∀ a, fromRef (toRef a) = a` が法則として要求されるにゃ。
    `insere`/`excita` の引數変換と、処理器ラッパーの Reference 復元に使ふにゃ -/
class Citatio (α : Type) where
  toRef     : α → String
  fromRef   : String → α
  roundtrip : ∀ (a : α), fromRef (toRef a) = a

-- ═══════════════════════════════════════════════════
-- StatusPermanens 対応型のインスタンスにゃん
-- ═══════════════════════════════════════════════════

instance : Citatio String where
  toRef s     := s
  fromRef s   := s
  roundtrip _ := rfl

instance : Citatio Nat where
  toRef n   := toString n
  fromRef s := s.toNat?.getD 0
  roundtrip _ :=
    -- (toString n).toNat? = some n は Batteries の補題で示せるにゃん
    -- TODO: Batteries の String.toNat?_toString（または同等の補題）が必要にゃ
    sorry

instance : Citatio Int where
  toRef n   := toString n
  fromRef s := s.toInt?.getD 0
  roundtrip _ :=
    -- TODO: String.toInt?_toString が必要にゃ
    sorry

instance : Citatio Bool where
  toRef b   := if b then "true" else "false"
  fromRef s := s == "true"
  roundtrip b := by cases b <;> rfl

-- Float: toString/parseFloat? の往復は浮動小数精度の問題で sorry にゃん
-- （IEEE 754 の有限値は十進数文字列で完全に往復できるが、形式証明は重いにゃ）
private def parseFloat? (s : String) : Option Float :=
  let s : String := s.trimAscii.toString
  let (neg, s) : Bool × String :=
    if s.startsWith "-" then (true,  s.drop 1 |>.toString)
    else if s.startsWith "+" then (false, s.drop 1 |>.toString)
    else (false, s)
  match s.splitOn "." with
  | [intPart] =>
    intPart.toNat?.map fun n => if neg then -Float.ofNat n else Float.ofNat n
  | [intPart, fracPart] =>
    match intPart.toNat? with
    | none => none
    | some n =>
      let frac := match fracPart.toNat? with
        | none   => 0.0
        | some f => Float.ofNat f / Float.ofNat (Nat.pow 10 fracPart.length)
      let v := Float.ofNat n + frac
      some (if neg then -v else v)
  | _ => none

instance : Citatio Float where
  toRef f   := toString f
  fromRef s := (parseFloat? s).getD 0.0
  roundtrip _ :=
    -- TODO: Float.toString の精度保証と parseFloat? の往復証明にゃ
    sorry

-- Char: 一文字の文字列として往復するにゃん
-- roundtrip は String.singleton c の front が c を返すことから導けるにゃ
instance : Citatio Char where
  toRef c   := String.singleton c
  fromRef s := if s.isEmpty then ' ' else s.front
  roundtrip _ :=
    -- TODO: (String.singleton c).isEmpty = false と .front = c の補題が必要にゃ
    sorry

-- UInt8 〜 UInt64: 十進数文字列にゃ
-- roundtrip は toString n.toNat の往復定理と UInt*.ofNat_toNat が必要にゃ
instance : Citatio UInt8 where
  toRef n   := toString n.toNat
  fromRef s := UInt8.ofNat (s.toNat?.getD 0)
  roundtrip _ := sorry

instance : Citatio UInt16 where
  toRef n   := toString n.toNat
  fromRef s := UInt16.ofNat (s.toNat?.getD 0)
  roundtrip _ := sorry

instance : Citatio UInt32 where
  toRef n   := toString n.toNat
  fromRef s := UInt32.ofNat (s.toNat?.getD 0)
  roundtrip _ := sorry

instance : Citatio UInt64 where
  toRef n   := toString n.toNat
  fromRef s := UInt64.ofNat (s.toNat?.getD 0)
  roundtrip _ := sorry

-- ═══════════════════════════════════════════════════
-- 複合型のインスタンスにゃん
-- ═══════════════════════════════════════════════════

/-- Option α: none → ""、some a → "1" ++ toRef a
    "1" プレフィクスを使ふことで `some ""` の曖昧さを排除するにゃ。
    元の設計（some a → toRef a）は `toRef "" = ""` のとき roundtrip が壊れるにゃ -/
instance {α : Type} [inst : Citatio α] : Citatio (Option α) where
  toRef
    | none   => ""
    | some a => "1" ++ inst.toRef a
  fromRef s :=
    if s.isEmpty then none
    else if s.startsWith "1" then some (inst.fromRef (s.drop 1 |>.toString))
    else none
  roundtrip
    | none   => rfl
    | some _ =>
        -- "1" ++ inst.toRef a は非空・"1" で始まり・drop 1 = inst.toRef a にゃ
        -- inst.roundtrip a で内側の往復が保証されるにゃ
        sorry

end PuraShiori
