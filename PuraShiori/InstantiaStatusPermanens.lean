-- PuraShiori.InstantiaStatusPermanens
-- StatusPermanens 型クラスの基本型に對するインスタンティア宣言にゃん♪
-- String/Nat/Int/Bool 等の標準型の永續化インスタンティアを提供するにゃ

import PuraShiori.AuxiliaStatusPermanens

namespace PuraShiori

-- ═══════════════════════════════════════════════════
-- インスタンティア証明用の私的補題にゃん
-- ═══════════════════════════════════════════════════

private theorem byteArrayExtractionPostPraefixum (a b : ByteArray) :
    (a ++ b).extract a.size (a.size + b.size) = b :=
  ByteArray.extract_append_eq_right rfl rfl

private theorem decodeCampiAdPraefixum {α : Type} [StatusPermanens α]
    (pre dat : ByteArray) (pos : Nat) :
    decodeField (pre ++ dat) (pre.size + pos) =
      ((decodeField dat pos : Option (α × Nat)).map (fun vp => (vp.1, pre.size + vp.2))) := by
  rcases h_leb : lebDecode dat pos with _ | ⟨longitudo, pos'⟩
  · have h_pre : lebDecode (pre ++ dat) (pre.size + pos) = none := by
      rw [lebDecodeAdPraefixumGen, h_leb]; rfl
    simp [decodeField, bind, Option.bind, h_pre, h_leb, Option.map]
  · have h_pre : lebDecode (pre ++ dat) (pre.size + pos) = some (longitudo, pre.size + pos') := by
      rw [lebDecodeAdPraefixumGen, h_leb]; rfl
    simp only [decodeField, bind, Option.bind, h_pre, h_leb]
    rw [show pre.size + pos' + longitudo = pre.size + (pos' + longitudo) from by omega]
    rw [extractioPraefixo pre dat pos' (pos' + longitudo)]
    rcases StatusPermanens.eBytes (dat.extract pos' (pos' + longitudo)) with _ | v
    · simp [Option.map]
    · simp [Option.map_some]

private theorem decodeCampiCodicampi {α : Type} [StatusPermanens α]
    (v : α) (rest : ByteArray) :
    decodeField (encodeField v ++ rest) 0 = some (v, (encodeField v).size) := by
  unfold decodeField encodeField
  have h_leb := lebDecodeEncodeRecursus (StatusPermanens.adBytes v).size
                  (StatusPermanens.adBytes v ++ rest)
  rw [← ByteArray.append_assoc] at h_leb
  simp only [h_leb, bind, Option.bind]
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
-- 基本型のインスタンティアにゃん
-- ═══════════════════════════════════════════════════

instance : StatusPermanens String where
  typusTag := "String"
  adBytes s := s.toUTF8
  eBytes  b := String.fromUTF8? b
  roundtrip s := String.fromUTF8?_toUTF8 s

instance : StatusPermanens Nat where
  typusTag := "Nat"
  adBytes n := (Nat.repr n).toUTF8
  eBytes  b := (String.fromUTF8? b) >>= (·.toNat?)
  roundtrip n := by
    have h1 := Nat.toNat?_repr n
    have h2 := String.fromUTF8?_toUTF8 (Nat.repr n)
    simp_all only [Option.bind_eq_bind, Option.bind_some]

instance : StatusPermanens Int where
  typusTag := "Int"
  adBytes n := (toString n).toUTF8
  eBytes  b := (String.fromUTF8? b) >>= (·.toInt?)
  roundtrip n := by
    have h1 := Int.toInt?_toString n
    have h2 := String.fromUTF8?_toUTF8 (toString n)
    simp_all only [Option.bind_eq_bind, Option.bind_some]

instance : StatusPermanens Bool where
  typusTag := "Bool"
  adBytes b := .mk #[if b then 1 else 0]
  eBytes  b := if b.size = 0 then none else some (b[0]! ≠ 0)
  roundtrip b := by cases b <;> native_decide

instance : StatusPermanens UInt8 where
  typusTag := "UInt8"
  adBytes n := .mk #[n]
  eBytes  b := if b.size = 0 then none else some b[0]!
  roundtrip _ := rfl

instance : StatusPermanens UInt16 where
  typusTag := "UInt16"
  adBytes n := u16LE n
  eBytes  b := readU16LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := legereU16LERecursus n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

instance : StatusPermanens UInt32 where
  typusTag := "UInt32"
  adBytes n := u32LE n
  eBytes  b := readU32LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := legereU32LERecursus n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

instance : StatusPermanens UInt64 where
  typusTag := "UInt64"
  adBytes n := u64LE n
  eBytes  b := readU64LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := legereU64LERecursus n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

instance : StatusPermanens Char where
  typusTag := "Char"
  adBytes c := u32LE c.val
  eBytes  b := do
    let (n, _) ← readU32LE b 0
    if h : n.isValidChar then some ⟨n, h⟩ else none
  roundtrip c := by
    have h := legereU32LERecursus c.val .empty
    simp [ByteArray.append_empty] at h
    simp_all only [Option.bind_eq_bind, Option.bind_some, dif_pos c.valid]

instance : StatusPermanens ByteArray where
  typusTag := "ByteArray"
  adBytes b := b
  eBytes  b := some b
  roundtrip _ := rfl

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
          simp_all only [ByteArray.size_append, ne_eq, Nat.add_eq_zero_iff,
                         ByteArray.size_eq_zero_iff, not_and]
          rfl
        have hne : (1 : UInt8) ≠ 0 := by decide
        simp only [h0, hne, ite_false]
        have hext : (.mk #[1] ++ StatusPermanens.adBytes v).extract 1
            (.mk #[1] ++ StatusPermanens.adBytes v).size =
            StatusPermanens.adBytes v := by
          simp only [ByteArray.size_append]
          exact byteArrayExtractionPostPraefixum (.mk #[1]) (StatusPermanens.adBytes v)
        rw [hext, StatusPermanens.roundtrip v]
        simp

private def decodePluraIteratio {α : Type} [StatusPermanens α]
    (b : ByteArray) (n : Nat) (positio : Nat) : Option (List α × Nat) :=
  match n with
  | 0     => some ([], positio)
  | n + 1 => do
    let (v, pos') ← decodeField b positio
    let (residuum, positioFinalis) ← decodePluraIteratio b n pos'
    return (v :: residuum, positioFinalis)

private def encodePluraIteratio {α : Type} [StatusPermanens α]
    (xs : List α) : ByteArray :=
  match xs with
  | []      => .empty
  | x :: xs => encodeField x ++ encodePluraIteratio xs

private theorem decodePluraIteratioIgnoraPraefixum (α : Type) [StatusPermanens α]
    (n pos : Nat) (pre dat : ByteArray) :
    (decodePluraIteratio (pre ++ dat) n (pre.size + pos) : Option (List α × Nat)) =
      (decodePluraIteratio dat n pos : Option (List α × Nat)).map
        (fun pair => (pair.1, pre.size + pair.2)) := by
  induction n generalizing pos with
  | zero => simp [decodePluraIteratio]
  | succ n ih =>
    simp [decodePluraIteratio]
    rw [decodeCampiAdPraefixum (α := α) pre dat pos]
    cases hdf : (decodeField dat pos : Option (α × Nat)) with
    | none => simp
    | some vp =>
      rcases vp with ⟨v, pos'⟩
      simp
      rw [ih pos']
      cases hml : (decodePluraIteratio (α := α) dat n pos' : Option (List α × Nat)) <;>
        simp [Option.map, Function.comp]

private theorem decodePluraIteratioEncodeRecursus (α : Type) [StatusPermanens α]
    (xs : List α) (rest : ByteArray) :
    decodePluraIteratio (encodePluraIteratio xs ++ rest) xs.length 0 =
      some (xs, (encodePluraIteratio xs).size) := by
  induction xs with
  | nil => simp [decodePluraIteratio, encodePluraIteratio, ByteArray.size]
  | cons x xs ih =>
    simp only [encodePluraIteratio, List.length_cons]
    rw [ByteArray.append_assoc]
    simp [decodePluraIteratio]
    rw [decodeCampiCodicampi x (encodePluraIteratio xs ++ rest)]
    simp
    have hpfx := decodePluraIteratioIgnoraPraefixum α xs.length 0
                   (encodeField x) (encodePluraIteratio xs ++ rest)
    simp only [Nat.add_zero] at hpfx
    rw [hpfx, ih]
    simp only [Option.map_some]
    rfl

instance {α : Type} [StatusPermanens α] : StatusPermanens (List α) where
  typusTag := "List(" ++ StatusPermanens.typusTag (α := α) ++ ")"
  adBytes xs := lebEncode xs.length ++ encodePluraIteratio xs
  eBytes b := do
    let (numerus, positio) ← lebDecode b 0
    let (xs, _) ← decodePluraIteratio b numerus positio
    return xs
  roundtrip xs := by
    simp only []
    have h_leb := lebDecodeEncodeRecursus xs.length (encodePluraIteratio xs)
    simp only [bind, Option.bind, h_leb]
    have hml := decodePluraIteratioIgnoraPraefixum α xs.length 0
      (lebEncode xs.length) (encodePluraIteratio xs)
    simp only [Nat.add_zero] at hml
    rw [hml]
    have henc := decodePluraIteratioEncodeRecursus α xs .empty
    simp only [ByteArray.append_empty] at henc
    rw [henc]
    rfl

instance {α : Type} [StatusPermanens α] : StatusPermanens (Array α) where
  typusTag := "Array(" ++ StatusPermanens.typusTag (α := α) ++ ")"
  adBytes xs := StatusPermanens.adBytes xs.toList
  eBytes  b  := (StatusPermanens.eBytes b : Option (List α)).map List.toArray
  roundtrip xs := by
    rw [StatusPermanens.roundtrip xs.toList]
    simp_all only [Option.map_some, Array.toArray_toList]

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
    have ha := decodeCampiCodicampi a (encodeField b)
    simp only [ha, bind, Option.bind]
    have hbe : decodeField (encodeField b) 0 = some (b, (encodeField b).size) := by
      have h := decodeCampiCodicampi b ByteArray.empty
      simp only [ByteArray.append_empty] at h
      exact h
    have hb : decodeField (encodeField a ++ encodeField b) (encodeField a).size =
              some (b, (encodeField a).size + (encodeField b).size) := by
      have h := (decodeCampiAdPraefixum (α := β) (encodeField a) (encodeField b) 0)
      simp only [Nat.add_zero] at h
      rw [h, hbe]
      simp [Option.map]
    simp [hb]

end PuraShiori
