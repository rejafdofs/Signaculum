-- Signaculum.Memoria.Citationes
-- Citatio 型クラスの各型へのインスタンティアにゃん♪
-- fromRef (toRef a) = a がすべてのインスタンティアで保証されるにゃ

import Signaculum.Memoria.Citatio
namespace Signaculum.Memoria

-- ═══════════════════════════════════════════════════
-- 基本型のインスタンティアにゃん
-- ═══════════════════════════════════════════════════

instance : Citatio String where
  toRef s     := s
  fromRef s   := s
  roundtrip _ := rfl

instance : Citatio Bool where
  toRef b   := if b then "true" else "false"
  fromRef s := s == "true"
  roundtrip b := by cases b <;> rfl

instance : Citatio Nat where
  toRef n   := toString n
  fromRef s := s.toNat?.getD 0
  roundtrip n := by
    show (toString n).toNat?.getD 0 = n
    simp [Nat.toNat?_repr]

instance : Citatio Int where
  toRef n   := toString n
  fromRef s := s.toInt?.getD 0
  roundtrip n := by
    show (toString n).toInt?.getD 0 = n
    simp [Int.toInt?_toString]

-- Char: String.data パターンマッチでレクルススするにゃ（rfl で証明可能）
instance : Citatio Char where
  toRef c   := String.singleton c
  fromRef s := match s.toList with
    | c :: _ => c
    | []     => ' '
  roundtrip c := by
    change (match (String.singleton c).toList with
      | c' :: _ => c'
      | []      => ' ') = c
    simp

-- ═══════════════════════════════════════════════════
-- UInt 型共通のレクルスス補題にゃん
-- ═══════════════════════════════════════════════════

/-- 無符號整數型の Citatio レクルスス共通補題にゃん。
    `ofNat (toNat n) = n` を滿たす型なら toRef/fromRef が往復するにゃ -/
-- UInt8/16/32/64: 十進數文字列にゃん。共通タクティクスで證明するにゃ♪
private theorem citatioUIntRecursus {α : Type}
    (toNat : α → Nat) (ofNat : Nat → α)
    (n : α)
    (recursus : ofNat (toNat n) = n)
    : ofNat ((toString (toNat n)).toNat?.getD 0) = n := by
  have h1 : (toString (toNat n)).toNat?.getD 0 = toNat n := by
    simp [Nat.toNat?_repr]
  rw [h1]; exact recursus

instance : Citatio UInt8 where
  toRef n   := toString n.toNat
  fromRef s := UInt8.ofNat (s.toNat?.getD 0)
  roundtrip n := citatioUIntRecursus UInt8.toNat UInt8.ofNat n UInt8.ofNat_toNat

instance : Citatio UInt16 where
  toRef n   := toString n.toNat
  fromRef s := UInt16.ofNat (s.toNat?.getD 0)
  roundtrip n := citatioUIntRecursus UInt16.toNat UInt16.ofNat n UInt16.ofNat_toNat

instance : Citatio UInt32 where
  toRef n   := toString n.toNat
  fromRef s := UInt32.ofNat (s.toNat?.getD 0)
  roundtrip n := citatioUIntRecursus UInt32.toNat UInt32.ofNat n UInt32.ofNat_toNat

instance : Citatio UInt64 where
  toRef n   := toString n.toNat
  fromRef s := UInt64.ofNat (s.toNat?.getD 0)
  roundtrip n := citatioUIntRecursus UInt64.toNat UInt64.ofNat n UInt64.ofNat_toNat

-- ═══════════════════════════════════════════════════
-- 複合型のインスタンティアにゃん
-- ═══════════════════════════════════════════════════

/-- Option α: none → ""、some a → "1" ++ toRef a にゃん。
    fromRef は String.data パターンマッチで實裝するにゃ。
    これにより startsWith の証明問題を回避できるにゃん。 -/
instance {α : Type} [inst : Citatio α] : Citatio (Option α) where
  toRef
    | none   => ""
    | some a => "1" ++ inst.toRef a
  fromRef s := match s.toList with
    | '1' :: rest => some (inst.fromRef (String.ofList rest))
    | _           => none
  roundtrip
    | none   => rfl
    | some a => by
        show (match ("1" ++ inst.toRef a).toList with
              | '1' :: rest => some (inst.fromRef (String.ofList rest))
              | _           => none) = some a
        simp [inst.roundtrip]

/-- α × β: 長さプラエフィクスム形式にゃ。
    `toRef (a, b) = Nat.repr (toRef a).length ++ ":" ++ toRef a ++ toRef b` にゃん。
    `fromRef` は `String.data.span Char.isDigit` で長さを解析するにゃ。
    Nat.repr の文字はすべて digit なので最初の `:` が確実に區切りになるにゃ -/
instance {α β : Type} [Citatio α] [Citatio β] : Citatio (α × β) where
  toRef  :=fun ⟨a, b⟩=>
    let sa := Citatio.toRef a
    Nat.repr sa.length ++ ":" ++ sa ++ Citatio.toRef b
  fromRef s :=
    let (digits, rest) := s.toList.span Char.isDigit
    match rest with
    | ':' :: afterColon =>
      match (String.ofList digits).toNat? with
      | none   => (Citatio.fromRef "", Citatio.fromRef "")
      | some n =>
          (Citatio.fromRef (String.ofList (afterColon.take n)),
           Citatio.fromRef (String.ofList (afterColon.drop n)))
    | _ => (Citatio.fromRef "", Citatio.fromRef "")
  roundtrip p := by
    rcases p with ⟨a, b⟩
    simp only []
    -- span の計算にゃ
    have hspan : ((Nat.repr (Citatio.toRef a).length ++ ":" ++ Citatio.toRef a ++ Citatio.toRef b).toList.span Char.isDigit) =
        ((Nat.repr (Citatio.toRef a).length).toList, ':' :: (Citatio.toRef a ++ Citatio.toRef b).toList) := by
      simp only [String.toList_append, show (":" : String).toList = [':'] from rfl]
      rw [show (Nat.repr (Citatio.toRef a).length).toList ++ [':'] ++ (Citatio.toRef a).toList ++ (Citatio.toRef b).toList =
          (Nat.repr (Citatio.toRef a).length).toList ++ [':'] ++ ((Citatio.toRef a).toList ++ (Citatio.toRef b).toList) from by
        simp [List.append_assoc]]
      rw [List.span_isDigit_repr]; rfl
    rw [hspan, String.ofList_toList, Nat.toNat?_repr]
    simp only []
    -- take / drop にゃ
    have htake : ((Citatio.toRef a ++ Citatio.toRef b).toList.take (Citatio.toRef a).length) =
        (Citatio.toRef a).toList := by
      rw [String.toList_append]
      have h : (Citatio.toRef a).length = (Citatio.toRef a).toList.length := String.length_toList.symm
      rw [List.take_append_of_le_length (by omega), h, List.take_length]
    have hdrop : ((Citatio.toRef a ++ Citatio.toRef b).toList.drop (Citatio.toRef a).length) =
        (Citatio.toRef b).toList := by
      rw [String.toList_append]
      have h : (Citatio.toRef a).length = (Citatio.toRef a).toList.length := String.length_toList.symm
      rw [List.drop_append_of_le_length (by omega), h, List.drop_length]; simp
    rw [htake, hdrop, String.ofList_toList, String.ofList_toList]
    simp [Citatio.roundtrip]

-- ═══════════════════════════════════════════════════
-- List 型のインスタンティアにゃん
-- ═══════════════════════════════════════════════════

/-- 一要素を長さプラエフィクスム形式で List Char にエンコードするにゃ -/
private def encodeElemL {α : Type} [Citatio α] (a : α) : List Char :=
  let s := Citatio.toRef a
  (Nat.repr s.length).toList ++ [':'] ++ s.toList

/-- n 個の要素を List Char からデコードするにゃ -/
private def decodeElems {α : Type} [Citatio α] : Nat → List Char → List α
  | 0, _ => []
  | n + 1, data =>
    let (digits, rest) := data.span Char.isDigit
    match rest with
    | ':' :: afterColon =>
      match (String.ofList digits).toNat? with
      | none => []
      | some len =>
        Citatio.fromRef (String.ofList (afterColon.take len)) ::
        decodeElems n (afterColon.drop len)
    | _ => []

/-- List のラウンドトリップ補題にゃ -/
private theorem decodeElems_eq {α : Type} [inst : Citatio α] :
    ∀ (l : List α),
    decodeElems l.length (List.flatten (l.map (@encodeElemL α inst))) = l := by
  intro l
  induction l with
  | nil => simp [decodeElems]
  | cons a as ih =>
    simp only [List.length_cons, List.map_cons, List.flatten]
    -- Nat.succ as.length = as.length + 1 にゃ
    show decodeElems (as.length + 1)
        (encodeElemL a ++ List.flatten (as.map (@encodeElemL α inst))) = a :: as
    -- decodeElems の定義展開にゃ
    simp only [decodeElems]
    -- span の計算にゃ
    have hspan : (encodeElemL a ++ List.flatten (as.map (@encodeElemL α inst))).span Char.isDigit =
        ((Nat.repr (Citatio.toRef a).length).toList,
         [':'] ++ ((Citatio.toRef a).toList ++ List.flatten (as.map (@encodeElemL α inst)))) := by
      simp only [encodeElemL]
      rw [show (Nat.repr (Citatio.toRef a).length).toList ++ [':'] ++ (Citatio.toRef a).toList ++
              List.flatten (as.map (@encodeElemL α inst)) =
              (Nat.repr (Citatio.toRef a).length).toList ++ [':'] ++
              ((Citatio.toRef a).toList ++ List.flatten (as.map (@encodeElemL α inst))) from by
        simp [List.append_assoc]]
      exact List.span_isDigit_repr _ _
    rw [hspan, String.ofList_toList, Nat.toNat?_repr]
    simp only [List.singleton_append]
    -- take / drop にゃ
    have h : (Citatio.toRef a).length = (Citatio.toRef a).toList.length :=
      String.length_toList.symm
    have htake : ((Citatio.toRef a).toList ++ List.flatten (as.map (@encodeElemL α inst))).take
        (Citatio.toRef a).length = (Citatio.toRef a).toList := by
      rw [List.take_append_of_le_length (by omega), h, List.take_length]
    have hdrop : ((Citatio.toRef a).toList ++ List.flatten (as.map (@encodeElemL α inst))).drop
        (Citatio.toRef a).length = List.flatten (as.map (@encodeElemL α inst)) := by
      rw [List.drop_append_of_le_length (by omega), h, List.drop_length]; simp
    rw [htake, hdrop, String.ofList_toList, inst.roundtrip, ih]

/-- List α: 個数プラエフィクスム + 各要素を長さプラエフィクスム形式にゃ。
    `toRef [] = "0:"`,
    `toRef (a :: as) = Nat.repr (a :: as).length ++ ":" ++ Nat.repr (toRef a).length ++ ":" ++ toRef a ++ …`
    `fromRef` は個数を解析し `decodeElems` で各要素を復元するにゃ。
    `roundtrip : fromRef (toRef l) = l` が保証されるにゃ。 -/
instance {α : Type} [inst : Citatio α] : Citatio (List α) where
  toRef l :=
    Nat.repr l.length ++ ":" ++ String.ofList (List.flatten (l.map (@encodeElemL α inst)))
  fromRef s :=
    let (digits, rest) := s.toList.span Char.isDigit
    match rest with
    | ':' :: afterColon =>
      match (String.ofList digits).toNat? with
      | none => []
      | some n => decodeElems n afterColon
    | _ => []
  roundtrip l := by
    simp only []
    have hspan : ((Nat.repr l.length ++ ":" ++
        String.ofList (List.flatten (l.map (@encodeElemL α inst)))).toList.span Char.isDigit) =
        ((Nat.repr l.length).toList,
         [':'] ++ (String.ofList (List.flatten (l.map (@encodeElemL α inst)))).toList) := by
      simp only [String.toList_append, show (":" : String).toList = [':'] from rfl]
      exact List.span_isDigit_repr _ _
    rw [hspan, String.ofList_toList, Nat.toNat?_repr]
    simp only []
    show decodeElems l.length (String.ofList (List.flatten (l.map (@encodeElemL α inst)))).toList = l
    simp only [String.toList_ofList]
    exact decodeElems_eq l

end Signaculum.Memoria
