-- PuraShiori.StatusPermanens
-- 永続化（persistentia）の型クラスと補助關數にゃん♪
-- ghost_status.bin への讀み書きを擔ふにゃ

import Std.Tactic.BVDecide
import PuraShiori.Lemma
import PuraShiori.Axiom
import Aesop
namespace PuraShiori

-- ═══════════════════════════════════════════════════
-- 型クラスにゃん
-- ═══════════════════════════════════════════════════

/-- 永続化できる型の型クラスにゃん。
    `typusTag` で型の文字列識別子を提供するにゃ。
    ゴーストの更新で變數の型が變はった時でも、タグが不一致なら讀み飛ばすにゃ♪
    `adBytes` で ByteArray に直列化、`eBytes` で復元するにゃ。
    自作構造體も `encodeField`/`decodeField` を使へばインスタンスを書けるにゃん♪ -/
class StatusPermanens (α : Type) where
  /-- 型の文字列識別子にゃん。バージョン更新時の型チェックに使ふにゃ。
      例: `"Nat"`, `"String"`, `"List(Nat)"` 等にゃ -/
  typusTag : String
  /-- 値を ByteArray に直列化するにゃん -/
  adBytes  : α → ByteArray
  /-- ByteArray から値を復元するにゃん。失敗したら `none` を返すにゃ -/
  eBytes   : ByteArray → Option α
  /-- 直列化の正しさにゃん: 直列化して復元すると元の値に戻るにゃ。
      eBytes (adBytes v) = some v が全 v で保証されるにゃ -/
  roundtrip : ∀ (v : α), eBytes (adBytes v) = some v

-- ═══════════════════════════════════════════════════
-- 内部補助: リトルエンディアン(LE)のエンコード/デコードにゃん
-- ═══════════════════════════════════════════════════

private def u16LE (n : UInt16) : ByteArray :=
  .mk #[(n &&& 0xFF).toUInt8,
        ((n >>> 8) &&& 0xFF).toUInt8]

private def u32LE (n : UInt32) : ByteArray :=
  .mk #[(n &&& 0xFF).toUInt8,
        ((n >>> 8)  &&& 0xFF).toUInt8,
        ((n >>> 16) &&& 0xFF).toUInt8,
        ((n >>> 24) &&& 0xFF).toUInt8]

def u64LE (n : UInt64) : ByteArray :=
  .mk #[(n &&& 0xFF).toUInt8,
        ((n >>> 8)  &&& 0xFF).toUInt8,
        ((n >>> 16) &&& 0xFF).toUInt8,
        ((n >>> 24) &&& 0xFF).toUInt8,
        ((n >>> 32) &&& 0xFF).toUInt8,
        ((n >>> 40) &&& 0xFF).toUInt8,
        ((n >>> 48) &&& 0xFF).toUInt8,
        ((n >>> 56) &&& 0xFF).toUInt8]

-- (値, 次の位置) を返すにゃ
private def readU16LE (b : ByteArray) (positio : Nat) : Option (UInt16 × Nat) :=
  if positio + 2 > b.size then none
  else some (
    b[positio]!.toUInt16 |||
    (b[positio+1]!.toUInt16 <<< 8),
    positio + 2)

private def readU32LE (b : ByteArray) (positio : Nat) : Option (UInt32 × Nat) :=
  if positio + 4 > b.size then none
  else some (
    b[positio]!.toUInt32 |||
    (b[positio+1]!.toUInt32 <<< 8)  |||
    (b[positio+2]!.toUInt32 <<< 16) |||
    (b[positio+3]!.toUInt32 <<< 24),
    positio + 4)

def readU64LE (b : ByteArray) (positio : Nat) : Option (UInt64 × Nat) :=
  if positio + 8 > b.size then none
  else some (
    b[positio]!.toUInt64 |||
    (b[positio+1]!.toUInt64 <<< 8)  |||
    (b[positio+2]!.toUInt64 <<< 16) |||
    (b[positio+3]!.toUInt64 <<< 24) |||
    (b[positio+4]!.toUInt64 <<< 32) |||
    (b[positio+5]!.toUInt64 <<< 40) |||
    (b[positio+6]!.toUInt64 <<< 48) |||
    (b[positio+7]!.toUInt64 <<< 56),
    positio + 8)

-- ═══════════════════════════════════════════════════
-- LEB128: 任意精度 Nat のバイト列エンコードにゃん
-- u64LE と違い 2^64 超の値も正確に往復するにゃ♪
-- ═══════════════════════════════════════════════════

/-- LEB128 エンコード: 7 ビットずつ、続きあり = 最上位ビット 1 にゃ -/
def lebEncode (n : Nat) : ByteArray :=
  if n < 128 then .mk #[n.toUInt8]
  else .mk #[((n % 128 + 128).toUInt8)] ++ lebEncode (n / 128)
termination_by n
decreasing_by
  apply Nat.div_lt_self
  · omega
  · decide

/-- LEB128 デコード補助（燃料付き）にゃ -/
private def lebDecodeLoop : Nat → ByteArray → Nat → Nat → Nat → Option (Nat × Nat)
  | 0,        _, _,   _,   _    => none
  | fuel + 1, b, pos, acc, mult =>
    if pos < b.size then
      let byte := b[pos]!.toNat
      if byte < 128 then some (acc + byte * mult, pos + 1)
      else lebDecodeLoop fuel b (pos + 1) (acc + (byte - 128) * mult) (mult * 128)
    else none

/-- LEB128 デコード: `pos` から読み出して `(値, 次の位置)` を返すにゃ -/
def lebDecode (b : ByteArray) (pos : Nat) : Option (Nat × Nat) :=
  lebDecodeLoop (b.size - pos + 1) b pos 0 1

/-- lebDecode と lebEncode は往復するにゃん（証明可能だが後回し）-/
private theorem lebDecode_lebEncode (n : Nat) (rest : ByteArray) :
    lebDecode (lebEncode n ++ rest) 0 = some (n, (lebEncode n).size) := by
  sorry

/-- lebEncode は必ず 1 バイト以上を返すにゃん -/
theorem lebEncode_size_pos (n : Nat) : 0 < (lebEncode n).size := by
  sorry

-- ═══════════════════════════════════════════════════
-- 公開補助: 自作構造體のインスタンス實裝に使ふにゃん♪
-- ═══════════════════════════════════════════════════

/-- 1フィールドを「8バイト長 + 本體」の形でエンコードするにゃん。
    自作構造體の `adBytes` 實裝に使ふにゃ:
    ```
    adBytes s := encodeField s.gradus ++ encodeField s.nomen
    ```
    -/
def encodeField {α : Type} [StatusPermanens α] (v : α) : ByteArray :=
  let b := StatusPermanens.adBytes v
  lebEncode b.size ++ b

/-- `positio` 位置から1フィールドを復元して `(値, 次の位置)` を返すにゃん。
    自作構造體の `eBytes` 實裝に使ふにゃ:
    ```
    eBytes b := do
      let (gradus, pos1) ← decodeField b 0
      let (nomen,  pos2) ← decodeField b pos1
      return { gradus, nomen }
    ```
    -/
def decodeField {α : Type} [StatusPermanens α]
    (b : ByteArray) (positio : Nat) : Option (α × Nat) := do
  let (longitudo, pos') ← lebDecode b positio
  let sectio := b.extract pos' (pos' + longitudo)
  let v ← StatusPermanens.eBytes sectio
  return (v, pos' + longitudo)

-- ═══════════════════════════════════════════════════
-- LE 往復補題にゃん（インスタンスより前に定義するにゃ）
-- ═══════════════════════════════════════════════════

-- UInt16 ──────────────────────────────────────────

private theorem uint16_byte_roundtrip (n : UInt16) :
    (n &&& 0xFF).toUInt8.toUInt16 |||
    (((n >>> 8) &&& 0xFF).toUInt8.toUInt16 <<< 8) = n := by
  bv_decide

private theorem readU16LE_u16LE (n : UInt16) (rest : ByteArray) :
    readU16LE (u16LE n ++ rest) 0 = some (n, 2) := by
  unfold readU16LE u16LE
  have hsize : (ByteArray.mk #[(n &&& 0xFF).toUInt8,
      ((n >>> 8) &&& 0xFF).toUInt8] ++ rest).size = 2 + rest.size := by
    rw [ByteArray.size_append]; rfl
  have hsz : ¬ (0 + 2 > (ByteArray.mk #[(n &&& 0xFF).toUInt8,
      ((n >>> 8) &&& 0xFF).toUInt8] ++ rest).size) := by
    omega
  simp only [show 0 + 2 = 2 from rfl, hsz, ite_false]
  exact congrArg (fun x => some (x, 2)) (uint16_byte_roundtrip n)

-- UInt32 ──────────────────────────────────────────

private theorem uint32_byte_roundtrip (n : UInt32) :
    (n &&& 0xFF).toUInt8.toUInt32 |||
    (((n >>> 8) &&& 0xFF).toUInt8.toUInt32 <<< 8) |||
    (((n >>> 16) &&& 0xFF).toUInt8.toUInt32 <<< 16) |||
    (((n >>> 24) &&& 0xFF).toUInt8.toUInt32 <<< 24) = n := by
  bv_decide

private theorem readU32LE_u32LE (n : UInt32) (rest : ByteArray) :
    readU32LE (u32LE n ++ rest) 0 = some (n, 4) := by
  unfold readU32LE u32LE
  have hsize : (ByteArray.mk #[(n &&& 0xFF).toUInt8,
      ((n >>> 8) &&& 0xFF).toUInt8, ((n >>> 16) &&& 0xFF).toUInt8,
      ((n >>> 24) &&& 0xFF).toUInt8] ++ rest).size = 4 + rest.size := by
    rw [ByteArray.size_append]; rfl
  have hsz : ¬ (0 + 4 > (ByteArray.mk #[(n &&& 0xFF).toUInt8,
      ((n >>> 8) &&& 0xFF).toUInt8, ((n >>> 16) &&& 0xFF).toUInt8,
      ((n >>> 24) &&& 0xFF).toUInt8] ++ rest).size) := by
    omega
  simp only [show 0 + 4 = 4 from rfl, hsz, ite_false]
  exact congrArg (fun x => some (x, 4)) (uint32_byte_roundtrip n)

-- UInt64 ──────────────────────────────────────────

private theorem uint64_byte_roundtrip (n : UInt64) :
    (n &&& 0xFF).toUInt8.toUInt64 |||
    (((n >>> 8)  &&& 0xFF).toUInt8.toUInt64 <<< 8)  |||
    (((n >>> 16) &&& 0xFF).toUInt8.toUInt64 <<< 16) |||
    (((n >>> 24) &&& 0xFF).toUInt8.toUInt64 <<< 24) |||
    (((n >>> 32) &&& 0xFF).toUInt8.toUInt64 <<< 32) |||
    (((n >>> 40) &&& 0xFF).toUInt8.toUInt64 <<< 40) |||
    (((n >>> 48) &&& 0xFF).toUInt8.toUInt64 <<< 48) |||
    (((n >>> 56) &&& 0xFF).toUInt8.toUInt64 <<< 56) = n := by
  bv_decide

private theorem readU64LE_u64LE (n : UInt64) (rest : ByteArray) :
    readU64LE (u64LE n ++ rest) 0 = some (n, 8) := by
  unfold readU64LE u64LE
  have hsize : (ByteArray.mk #[(n &&& 0xFF).toUInt8,
      ((n >>> 8) &&& 0xFF).toUInt8, ((n >>> 16) &&& 0xFF).toUInt8,
      ((n >>> 24) &&& 0xFF).toUInt8, ((n >>> 32) &&& 0xFF).toUInt8,
      ((n >>> 40) &&& 0xFF).toUInt8, ((n >>> 48) &&& 0xFF).toUInt8,
      ((n >>> 56) &&& 0xFF).toUInt8] ++ rest).size = 8 + rest.size := by
    rw [ByteArray.size_append]; rfl
  have hsz : ¬ (0 + 8 > (ByteArray.mk #[(n &&& 0xFF).toUInt8,
      ((n >>> 8) &&& 0xFF).toUInt8, ((n >>> 16) &&& 0xFF).toUInt8,
      ((n >>> 24) &&& 0xFF).toUInt8, ((n >>> 32) &&& 0xFF).toUInt8,
      ((n >>> 40) &&& 0xFF).toUInt8, ((n >>> 48) &&& 0xFF).toUInt8,
      ((n >>> 56) &&& 0xFF).toUInt8] ++ rest).size) := by
    omega
  simp only [show 0 + 8 = 8 from rfl, hsz, ite_false]
  exact congrArg (fun x => some (x, 8)) (uint64_byte_roundtrip n)

-- (a ++ b) から b の部分を取り出す補題にゃん（インスタンスで使ふにゃ）
private theorem byteArray_extract_after_prefix (a b : ByteArray) :
    (a ++ b).extract a.size (a.size + b.size) = b :=
  ByteArray.extract_append_eq_right rfl rfl

theorem encodeField_size {α : Type} [StatusPermanens α] (v : α) :
    (encodeField v).size =
      (lebEncode (StatusPermanens.adBytes v).size).size + (StatusPermanens.adBytes v).size := by
  change (lebEncode (StatusPermanens.adBytes v).size ++ StatusPermanens.adBytes v).size = _
  rw [ByteArray.size_append]

theorem option_bind_pure_some {α β : Type} (x : α) (y : β) :
  (some x >>= fun v_1 => pure (v_1, y)) = some (x, y) := rfl

-- decodeField 補題にゃん（インスタンスより前に定義するにゃ）

/-- prefix を前置しても decodeField の結果は位置だけずれるにゃん
    readU64LE の Array.getElem!_append_right 等から証明可能だが複雑にゃ -/
private theorem decodeField_at_prefix {α : Type} [StatusPermanens α]
    (pre dat : ByteArray) (pos : Nat) :
    decodeField (pre ++ dat) (pre.size + pos) =
      ((decodeField dat pos : Option (α × Nat)).map (fun vp => (vp.1, pre.size + vp.2))) := by
  sorry

/-- encodeField した後すぐ decodeField すると元の値に戻るにゃん -/
private theorem decodeField_encodeField {α : Type} [StatusPermanens α]
    (v : α) (rest : ByteArray) :
    decodeField (encodeField v ++ rest) 0 = some (v, (encodeField v).size) := by
  unfold decodeField encodeField
  -- lebDecode (lebEncode sz ++ adBytes v ++ rest) 0 = some (sz, (lebEncode sz).size)
  have h_leb := lebDecode_lebEncode (StatusPermanens.adBytes v).size
                  (StatusPermanens.adBytes v ++ rest)
  rw [← ByteArray.append_assoc] at h_leb
  simp only [h_leb, bind, Option.bind]
  -- extract (lebEncode sz).size ((lebEncode sz).size + sz) = adBytes v
  have hext : (lebEncode (StatusPermanens.adBytes v).size ++
               StatusPermanens.adBytes v ++ rest).extract
               (lebEncode (StatusPermanens.adBytes v).size).size
               ((lebEncode (StatusPermanens.adBytes v).size).size +
                (StatusPermanens.adBytes v).size) =
              StatusPermanens.adBytes v :=
    byteArray_extract_middle (lebEncode _) (StatusPermanens.adBytes v) rest
  rw [hext, StatusPermanens.roundtrip v]
  simp [ByteArray.size_append]

-- ═══════════════════════════════════════════════════
-- 基本型のインスタンスにゃん
-- ═══════════════════════════════════════════════════

-- String: UTF-8 バイト列そのままにゃ
instance : StatusPermanens String where
  typusTag := "String"
  adBytes s := s.toUTF8
  eBytes  b := String.fromUTF8? b
  roundtrip s := String.fromUTF8?_toUTF8 s

-- Nat: 十進文字列の UTF-8（任意精度・損失なし）にゃ
-- 旧設計 (UInt64截断) を廃止。n ≥ 2^64 でも roundtrip が保たれるにゃ
instance : StatusPermanens Nat where
  typusTag := "Nat"
  adBytes n := (Nat.repr n).toUTF8
  eBytes  b := (String.fromUTF8? b) >>= (·.toNat?)
  roundtrip n := by
    have h1 := Nat.toNat?_repr n
    have h2 := String.fromUTF8?_toUTF8 (Nat.repr n)
    simp_all only [Option.bind_eq_bind, Option.bind_some]



-- Int: 十進文字列の UTF-8（任意精度・損失なし）にゃ
instance : StatusPermanens Int where
  typusTag := "Int"
  adBytes n := (toString n).toUTF8
  eBytes  b := (String.fromUTF8? b) >>= (·.toInt?)
  roundtrip n := by
    have h1 := Int.toInt?_toString n
    have h2 := String.fromUTF8?_toUTF8 (toString n)
    simp_all only [Option.bind_eq_bind, Option.bind_some]

-- Bool: 1バイト (0 = false, 1 = true) にゃ
instance : StatusPermanens Bool where
  typusTag := "Bool"
  adBytes b := .mk #[if b then 1 else 0]
  eBytes  b := if b.size = 0 then none else some (b[0]! ≠ 0)
  roundtrip b := by cases b <;> native_decide


-- UInt8: 1バイトにゃ
instance : StatusPermanens UInt8 where
  typusTag := "UInt8"
  adBytes n := .mk #[n]
  eBytes  b := if b.size = 0 then none else some b[0]!
  roundtrip _ := rfl

-- UInt16: 2バイト LE にゃ
instance : StatusPermanens UInt16 where
  typusTag := "UInt16"
  adBytes n := u16LE n
  eBytes  b := readU16LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := readU16LE_u16LE n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

-- UInt32: 4バイト LE にゃ
instance : StatusPermanens UInt32 where
  typusTag := "UInt32"
  adBytes n := u32LE n
  eBytes  b := readU32LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := readU32LE_u32LE n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

-- UInt64: 8バイト LE にゃ
instance : StatusPermanens UInt64 where
  typusTag := "UInt64"
  adBytes n := u64LE n
  eBytes  b := readU64LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := readU64LE_u64LE n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

-- Char: UInt32 として Unicode 符號點をエンコードするにゃ
instance : StatusPermanens Char where
  typusTag := "Char"
  adBytes c := u32LE c.val
  eBytes  b := do
    let (n, _) ← readU32LE b 0
    if h : n.isValidChar then some ⟨n, h⟩ else none
  roundtrip c := by
    have h := readU32LE_u32LE c.val .empty
    simp [ByteArray.append_empty] at h
    simp_all only [Option.bind_eq_bind, Option.bind_some, dif_pos c.valid]

-- ByteArray: 中身をそのまま保存するにゃ
instance : StatusPermanens ByteArray where
  typusTag := "ByteArray"
  adBytes b := b
  eBytes  b := some b
  roundtrip _ := rfl

-- Option α: 1バイトタグ(0=none, 1=some) + 中身にゃ
instance {α : Type} [StatusPermanens α] : StatusPermanens (Option α) where
  typusTag := "Option(" ++ StatusPermanens.typusTag (α := α) ++ ")"
  adBytes
    | none   => .mk #[0]
    | some v => .mk #[1] ++ StatusPermanens.adBytes v
  eBytes b :=
    if b.size = 0 then none
    else if b[0]! = 0 then some none
    else (StatusPermanens.eBytes (b.extract 1 b.size)).map some
  roundtrip
    | none   => rfl
    | some v => by
        have hsize : (.mk #[1] ++ StatusPermanens.adBytes v).size ≠ 0 := by
          rw [ByteArray.size_append, show (ByteArray.mk #[1]).size = 1 from rfl]
          omega
        simp only [hsize, ite_false]
        have h0 : (.mk #[1] ++ StatusPermanens.adBytes v)[0]! = 1 := by
          simp_all only [ByteArray.size_append, ne_eq, Nat.add_eq_zero_iff, ByteArray.size_eq_zero_iff, not_and]
          rfl
        have hne : (1 : UInt8) ≠ 0 := by decide
        simp only [h0, hne, ite_false]
        have hext : (.mk #[1] ++ StatusPermanens.adBytes v).extract 1
            (.mk #[1] ++ StatusPermanens.adBytes v).size =
            StatusPermanens.adBytes v := by
          simp only [ByteArray.size_append]
          exact byteArray_extract_after_prefix (.mk #[1]) (StatusPermanens.adBytes v)
        rw [hext, StatusPermanens.roundtrip v]
        simp

private def decodeManyLoop {α : Type} [StatusPermanens α]
    (b : ByteArray) (n : Nat) (positio : Nat) : Option (List α × Nat) :=
  match n with
  | 0     => some ([], positio)
  | n + 1 => do
    let (v, pos') ← decodeField b positio
    let (residuum, positioFinalis) ← decodeManyLoop b n pos'
    return (v :: residuum, positioFinalis)

private def encodeManyLoop {α : Type} [StatusPermanens α]
    (xs : List α) : ByteArray :=
  match xs with
  | []      => .empty
  | x :: xs => encodeField x ++ encodeManyLoop xs

/-- decodeManyLoop ignores data at smaller indexes than `pos`. (axiom から theorem に変換にゃ) -/
private theorem decodeManyLoop_ignore_prefix (α : Type) [StatusPermanens α]
    (n pos : Nat) (pre dat : ByteArray) :
    (decodeManyLoop (pre ++ dat) n (pre.size + pos) : Option (List α × Nat)) =
      (decodeManyLoop dat n pos : Option (List α × Nat)).map (fun pair => (pair.1, pre.size + pair.2)) := by
  induction n generalizing pos with
  | zero =>
    simp [decodeManyLoop]
  | succ n ih =>
    simp [decodeManyLoop]
    rw [decodeField_at_prefix (α := α) pre dat pos]
    cases hdf : (decodeField dat pos : Option (α × Nat)) with
    | none =>
      simp
    | some vp =>
      rcases vp with ⟨v, pos'⟩
      simp
      rw [ih pos']
      cases hml : (decodeManyLoop (α := α) dat n pos' : Option (List α × Nat)) <;> simp [Option.map, Function.comp]

/-- decodeManyLoop は encodeManyLoop が作ったバイト列を正しく復元するにゃん
    (pos = 0 固定版、List roundtrip に使ふにゃ) -/
private theorem decodeManyLoop_encodeManyLoop (α : Type) [StatusPermanens α]
    (xs : List α) (rest : ByteArray) :
    decodeManyLoop (encodeManyLoop xs ++ rest) xs.length 0 =
      some (xs, (encodeManyLoop xs).size) := by
  induction xs with
  | nil =>
    simp [decodeManyLoop, encodeManyLoop, ByteArray.size]
  | cons x xs ih =>
    simp only [encodeManyLoop, List.length_cons]
    rw [ByteArray.append_assoc]
    simp [decodeManyLoop]
    -- decodeField (encodeField x ++ encodeManyLoop xs ++ rest) 0 = some (x, (encodeField x).size)
    rw [decodeField_encodeField x (encodeManyLoop xs ++ rest)]
    simp
    -- decodeManyLoop (encodeField x ++ encodeManyLoop xs ++ rest) xs.length (encodeField x).size
    -- = (decodeManyLoop (encodeManyLoop xs ++ rest) xs.length 0).map (...)
    have hpfx := decodeManyLoop_ignore_prefix α xs.length 0
                   (encodeField x) (encodeManyLoop xs ++ rest)
    simp only [Nat.add_zero] at hpfx
    rw [hpfx, ih]
    simp only [Option.map_some]
    rfl

instance {α : Type} [StatusPermanens α] : StatusPermanens (List α) where
  typusTag := "List(" ++ StatusPermanens.typusTag (α := α) ++ ")"
  adBytes xs :=
    lebEncode xs.length ++ encodeManyLoop xs
  eBytes b := do
    let (numerus, positio) ← lebDecode b 0
    let (xs, _) ← decodeManyLoop b numerus positio
    return xs
  roundtrip xs := by
    simp only []
    -- lebDecode (lebEncode xs.length ++ encodeManyLoop xs) 0 = some (xs.length, ...)
    have h_leb := lebDecode_lebEncode xs.length (encodeManyLoop xs)
    simp only [bind, Option.bind, h_leb]
    -- decodeManyLoop (lebEncode ... ++ encodeManyLoop xs) xs.length (lebEncode ...).size
    -- = decodeManyLoop (encodeManyLoop xs) xs.length 0 にゃ（prefix 無視）
    have hml := decodeManyLoop_ignore_prefix α xs.length 0
      (lebEncode xs.length) (encodeManyLoop xs)
    simp only [Nat.add_zero] at hml
    rw [hml]
    have henc := decodeManyLoop_encodeManyLoop α xs .empty
    simp only [ByteArray.append_empty] at henc
    rw [henc]
    rfl

-- Array α: List α と同じ形式にゃ
instance {α : Type} [StatusPermanens α] : StatusPermanens (Array α) where
  typusTag := "Array(" ++ StatusPermanens.typusTag (α := α) ++ ")"
  adBytes xs := StatusPermanens.adBytes xs.toList
  eBytes  b  := (StatusPermanens.eBytes b : Option (List α)).map List.toArray
  roundtrip xs := by
    rw [StatusPermanens.roundtrip xs.toList]
    simp_all only [Option.map_some, Array.toArray_toList]

-- α × β: encodeField の組合せにゃ
instance {α β : Type} [StatusPermanens α] [StatusPermanens β]
    : StatusPermanens (α × β) where
  typusTag := "Prod(" ++ StatusPermanens.typusTag (α := α) ++ "," ++
              StatusPermanens.typusTag (α := β) ++ ")"
  adBytes p := encodeField p.1 ++ encodeField p.2
  eBytes b := do
    let (a, positio) ← decodeField b 0
    let (secundum, _) ← decodeField b positio
    return (a, secundum)
  roundtrip p := by
    obtain ⟨a, b⟩ := p
    simp only []
    -- decodeField at 0 gives (a, (encodeField a).size)にゃ
    have ha := decodeField_encodeField a (encodeField b)
    simp only [ha, bind, Option.bind]
    -- decodeField at (encodeField a).size gives (b, ...)にゃ
    have hbe : decodeField (encodeField b) 0 = some (b, (encodeField b).size) := by
      have h := decodeField_encodeField b ByteArray.empty
      simp only [ByteArray.append_empty] at h
      exact h
    have hb : decodeField (encodeField a ++ encodeField b) (encodeField a).size =
              some (b, (encodeField a).size + (encodeField b).size) := by
      -- decodeField_at_prefix: prefix=encodeField a, dat=encodeField b, pos=0
      have h := (decodeField_at_prefix (α := β) (encodeField a) (encodeField b) 0)
      simp only [Nat.add_zero] at h
      rw [h, hbe]
      simp [Option.map]
    simp [hb]

-- ═══════════════════════════════════════════════════
-- バイナリファスキクルス(ghost_status.bin)の讀み書きにゃん
-- 形式 v3: magic(4) | 項目數(u64) | [鍵長(u64)|鍵|typusTag長(u64)|typusTag|値長(u64)|値]...
-- v1（magic=UKA\x01）は型タグなし・舊形式にゃ。
-- v2（magic=UKA\x02）は u32 長さフィールド（2^32 制限あり）にゃ。
-- v3（magic=UKA\x03）は u64 長さフィールド（制限なし）にゃ♪
-- ═══════════════════════════════════════════════════

-- マジックバイト: "UKA\x03"（v3: u64 長さフィールド形式にゃ）
def magicBytes : ByteArray := .mk #[0x55, 0x4B, 0x41, 0x03]

-- 1エントリ (鍵, タグ, 値) をシリアライズするにゃ
private def serializeEntrada (k tag : String) (v : ByteArray) : ByteArray :=
  let ok := k.toUTF8; let ot := tag.toUTF8
  u64LE ok.size.toUInt64 ++ ok
  ++ u64LE ot.size.toUInt64 ++ ot
  ++ u64LE v.size.toUInt64 ++ v

-- エントリ列を再帰的にシリアライズするにゃ（証明のための再帰形）
def serializeParia : List (String × String × ByteArray) → ByteArray
  | []              => .empty
  | (k, tag, v) :: rest => serializeEntrada k tag v ++ serializeParia rest

-- バイナリから (名前, 型タグ, バイト列) の三つ組を再帰的に讀むにゃ
def legereParia
    (b : ByteArray) (n : Nat) (positio : Nat)
    : Option (List (String × String × ByteArray) × Nat) :=
  match n with
  | 0     => some ([], positio)
  | n + 1 => do
    -- キー名にゃ
    let (longitudoNominis, pos1) ← readU64LE b positio
    if pos1 + longitudoNominis.toNat > b.size then none
    else do
      let octetiNominis := b.extract pos1 (pos1 + longitudoNominis.toNat)
      let nomenEntriae  ← String.fromUTF8? octetiNominis
      let pos2          := pos1 + longitudoNominis.toNat
      -- 型タグにゃ
      let (longitudoTypi, pos3) ← readU64LE b pos2
      if pos3 + longitudoTypi.toNat > b.size then none
      else do
        let octetiTypi := b.extract pos3 (pos3 + longitudoTypi.toNat)
        let tag        ← String.fromUTF8? octetiTypi
        let pos4       := pos3 + longitudoTypi.toNat
        -- 値にゃ
        let (longitudoValorum, pos5) ← readU64LE b pos4
        if pos5 + longitudoValorum.toNat > b.size then none
        else do
          let valor      := b.extract pos5 (pos5 + longitudoValorum.toNat)
          let pos6       := pos5 + longitudoValorum.toNat
          let (residuum, positioFinalis) ← legereParia b n pos6
          return ((nomenEntriae, tag, valor) :: residuum, positioFinalis)

-- ─────────────────────────────────────────────────────────────────────────
-- roundtrip 補題と serializeMappam_roundtrip は LemmaStatusPermanens.lean にあるにゃ
-- ─────────────────────────────────────────────────────────────────────────

/-- `(名前, 型タグ, ByteArray)` の三つ組のリストをバイナリに直列化するにゃん（純粋）♪ -/
def serializeMappam (paria : List (String × String × ByteArray)) : ByteArray :=
  magicBytes ++ lebEncode paria.length ++ serializeParia paria

/-- バイナリから `(名前, 型タグ, ByteArray)` の三つ組を復元するにゃん（純粋）♪
    不正なバイト列の場合は `none` を返すにゃ -/
def deserializeMappam (b : ByteArray) : Option (List (String × String × ByteArray)) := do
  -- 最低5バイト必要にゃ（マジック4 + LEB128 最低1バイト）
  if b.size < 5 then failure
  if b.extract 0 4 != magicBytes then failure
  let (numerus, positio) ← lebDecode b 4
  let (paria, _)         ← legereParia b numerus positio
  return paria

/-- `ghost_status.bin` から `(名前, 型タグ, ByteArray)` の三つ組を讀み込むにゃん♪
    ファスキクルスが存在しにゃい・形式が不正にゃ場合は空の一覽を返すにゃ -/
def legereMappam (via : String) : IO (List (String × String × ByteArray)) :=
  try
    IO.FS.readBinFile via >>= fun b =>
      return (deserializeMappam b).getD []
  catch _ =>
    return []

/-- `(名前, 型タグ, ByteArray)` の三つ組を `ghost_status.bin` に書き出すにゃん♪ -/
def scribeMappam
    (via : String)
    (paria : List (String × String × ByteArray)) : IO Unit :=
  IO.FS.writeBinFile via (serializeMappam paria)

/-- 名前→設定器の一覽を使って一括復元するにゃん。
    保存ダータに含まれる項目のうち **typusTag が一致するもの** だけを復元するにゃ♪
    型が變はった變數は安全に讀み飛ばされるにゃ -/
def executareLecturam
    (paria     : List (String × String × ByteArray))
    (tractores : List (String × (String → ByteArray → IO Unit))) : IO Unit := do
  for elementum in paria do
    let (nomen, tag, valor) := elementum
    match tractores.lookup nomen with
    | some actio => actio tag valor
    | none       => pure ()  -- 知らにゃい名前は無視するにゃ

/-- 名前→取得器の一覽を使って一括保存するにゃん♪
    各項目は `(型タグ, ByteArray)` の形で保存されるにゃ -/
def executareScripturam
    (tractores : List (String × IO (String × ByteArray)))
    : IO (List (String × String × ByteArray)) := do
  let mut paria : List (String × String × ByteArray) := []
  for (nomen, actio) in tractores do
    let (tag, valor) ← actio
    paria := (nomen, tag, valor) :: paria
  return paria.reverse
end PuraShiori
