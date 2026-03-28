-- Signaculum.Memoria.Lemma
-- StatusPermanens 型クラスの基本型インスタンティアと關連補題にゃん♪
-- （旧 InstantiaStatusPermanens と旧 LemmaStatusPermanens を統合したものにゃ）

import Signaculum.Memoria.Auxilia

namespace Signaculum.Memoria

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
  eBytes  b := if h : b.size = 0 then none else some (b[0]'(by omega) ≠ 0)
  roundtrip b := by cases b <;> native_decide

instance : StatusPermanens UInt8 where
  typusTag := "UInt8"
  adBytes n := .mk #[n]
  eBytes  b := if h : b.size = 0 then none else some (b[0]'(by omega))
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
    if h : b.size = 0 then none
    else if b[0]'(by omega) = 0 then some none
    else (StatusPermanens.eBytes (b.extract 1 b.size)).map some
  roundtrip
    | none   => rfl
    | some v => by
        have hsize : (.mk #[1] ++ StatusPermanens.adBytes v).size ≠ 0 := by
          rw [ByteArray.size_append, show (ByteArray.mk #[1]).size = 1 from rfl]
          omega
        simp only [hsize]
        have h0 : (.mk #[1] ++ StatusPermanens.adBytes v)[0]'(by omega) = 1 := by rfl
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

-- ═══════════════════════════════════════════════════
-- serializeMappam 關連の補題にゃん
-- ═══════════════════════════════════════════════════

/-- プラエフィクスムを前置しても lebDecode の結果は位置だけずれるにゃん -/
theorem lebDecodeAdPraefixum (pre : ByteArray) (n : Nat) (rest : ByteArray) :
    lebDecode (pre ++ lebEncode n ++ rest) pre.size =
      some (n, pre.size + (lebEncode n).size) := by
  rw [show pre.size = pre.size + 0 from by omega]
  rw [ByteArray.append_assoc]
  rw [lebDecodeAdPraefixumGen pre (lebEncode n ++ rest) 0]
  simp only [Nat.add_zero]
  rw [lebDecodeEncodeRecursus n rest]
  simp [Option.map]

/-- プラエフィクスムを前置しても legereParia の結果は位置だけずれるにゃん -/
theorem legereParia_at_prefix (cnt pos : Nat) (pre dat : ByteArray) :
    legereParia (pre ++ dat) cnt (pre.size + pos) =
      (legereParia dat cnt pos).map (fun (ps, q) => (ps, pre.size + q)) := by
  induction cnt generalizing pos with
  | zero => simp [legereParia]
  | succ n ih =>
    simp only [legereParia, bind, Option.bind]
    rw [lebDecodeAdPraefixumGen pre dat pos]
    rcases lebDecode dat pos with _ | ⟨longitudoNominis, pos1⟩
    · simp [Option.map]
    · simp only [Option.map_some]
      simp only [ByteArray.size_append]
      by_cases hbnd : pos1 + longitudoNominis > dat.size
      · have hbnd' : pre.size + pos1 + longitudoNominis > pre.size + dat.size := by omega
        simp [hbnd, hbnd', Option.map]
      · have hbnd' : ¬ (pre.size + pos1 + longitudoNominis > pre.size + dat.size) := by omega
        simp only [if_neg hbnd, if_neg hbnd']
        rw [show pre.size + pos1 + longitudoNominis = pre.size + (pos1 + longitudoNominis) from by omega]
        rw [extractioPraefixo pre dat pos1 (pos1 + longitudoNominis)]
        rcases String.fromUTF8? (dat.extract pos1 (pos1 + longitudoNominis)) with _ | nomenEntriae
        · simp [Option.map]
        · rw [lebDecodeAdPraefixumGen pre dat (pos1 + longitudoNominis)]
          rcases lebDecode dat (pos1 + longitudoNominis) with _ | ⟨longitudoTypi, pos3⟩
          · simp [Option.map]
          · simp only [Option.map_some]
            by_cases hbnd2 : pos3 + longitudoTypi > dat.size
            · have hbnd2' : pre.size + pos3 + longitudoTypi > pre.size + dat.size := by omega
              simp [hbnd2, hbnd2', Option.map]
            · have hbnd2' : ¬ (pre.size + pos3 + longitudoTypi > pre.size + dat.size) := by omega
              simp only [if_neg hbnd2, if_neg hbnd2']
              rw [show pre.size + pos3 + longitudoTypi = pre.size + (pos3 + longitudoTypi) from by omega]
              rw [extractioPraefixo pre dat pos3 (pos3 + longitudoTypi)]
              rcases String.fromUTF8? (dat.extract pos3 (pos3 + longitudoTypi)) with _ | tag
              · simp [Option.map]
              · rw [lebDecodeAdPraefixumGen pre dat (pos3 + longitudoTypi)]
                rcases lebDecode dat (pos3 + longitudoTypi) with _ | ⟨longitudoValorum, pos5⟩
                · simp [Option.map]
                · simp only [Option.map_some]
                  by_cases hbnd3 : pos5 + longitudoValorum > dat.size
                  · have hbnd3' : pre.size + pos5 + longitudoValorum > pre.size + dat.size := by omega
                    simp [hbnd3, hbnd3', Option.map]
                  · have hbnd3' : ¬ (pre.size + pos5 + longitudoValorum > pre.size + dat.size) := by omega
                    simp only [if_neg hbnd3, if_neg hbnd3']
                    rw [show pre.size + pos5 + longitudoValorum = pre.size + (pos5 + longitudoValorum) from by omega]
                    rw [extractioPraefixo pre dat pos5 (pos5 + longitudoValorum)]
                    rw [ih (pos5 + longitudoValorum)]
                    rcases legereParia dat n (pos5 + longitudoValorum) with _ | ⟨residuum, positioFinalis⟩
                    · simp [Option.map]
                    · simp [Option.map]

/-- serializeEntrada を一つ讀んで残りに legereParia を適用すると正しく復元するにゃん -/
private theorem legereParia_cons
    (k tag : String) (v : ByteArray) (rest' : List (String × String × ByteArray))
    (rest : ByteArray)
    (ih : legereParia (serializeParia rest' ++ rest) rest'.length 0 =
          some (rest', (serializeParia rest').size)) :
    legereParia (serializeEntrada k tag v ++ serializeParia rest' ++ rest)
      (rest'.length + 1) 0 =
      some ((k, tag, v) :: rest',
            (serializeEntrada k tag v).size + (serializeParia rest').size) := by
  simp only [serializeEntrada]
  simp only [legereParia]
  have hread1 : lebDecode (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
      lebEncode v.size ++ v ++ serializeParia rest' ++ rest) 0 =
      some (k.toUTF8.size, (lebEncode k.toUTF8.size).size) := by
    rw [show (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest) =
        lebEncode k.toUTF8.size ++ (k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    exact lebDecodeEncodeRecursus k.toUTF8.size _
  rw [hread1]
  simp only [bind, Option.bind]
  have hbound1 : ¬ ((lebEncode k.toUTF8.size).size + k.toUTF8.size >
      (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
       lebEncode v.size ++ v ++ serializeParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound1]
  have hextract1 : (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
      lebEncode v.size ++ v ++ serializeParia rest' ++ rest).extract
      (lebEncode k.toUTF8.size).size ((lebEncode k.toUTF8.size).size + k.toUTF8.size) = k.toUTF8 := by
    rw [show (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest) =
        lebEncode k.toUTF8.size ++ k.toUTF8 ++
        (lebEncode tag.toUTF8.size ++ tag.toUTF8 ++ lebEncode v.size ++ v ++ serializeParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    exact byteArray_extract_middle (lebEncode k.toUTF8.size) k.toUTF8
      (lebEncode tag.toUTF8.size ++ tag.toUTF8 ++ lebEncode v.size ++ v ++ serializeParia rest' ++ rest)
  rw [hextract1, String.fromUTF8?_toUTF8]
  have hread2 : lebDecode (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
      lebEncode v.size ++ v ++ serializeParia rest' ++ rest)
      ((lebEncode k.toUTF8.size).size + k.toUTF8.size) =
      some (tag.toUTF8.size, (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size) := by
    have hpre2_size : (lebEncode k.toUTF8.size ++ k.toUTF8).size = (lebEncode k.toUTF8.size).size + k.toUTF8.size := by
      simp [ByteArray.size_append]
    rw [show (lebEncode k.toUTF8.size).size + k.toUTF8.size =
        (lebEncode k.toUTF8.size ++ k.toUTF8).size from hpre2_size.symm]
    rw [show (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest) =
        (lebEncode k.toUTF8.size ++ k.toUTF8) ++ (lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    rw [show (lebEncode k.toUTF8.size ++ k.toUTF8).size = (lebEncode k.toUTF8.size ++ k.toUTF8).size + 0 from by omega]
    rw [lebDecodeAdPraefixumGen]
    rw [show (lebEncode tag.toUTF8.size ++ tag.toUTF8 ++ lebEncode v.size ++ v ++ serializeParia rest' ++ rest) =
        lebEncode tag.toUTF8.size ++ (tag.toUTF8 ++ lebEncode v.size ++ v ++ serializeParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    rw [lebDecodeEncodeRecursus tag.toUTF8.size]
    simp [Option.map]
  rw [hread2]
  have hbound2 : ¬ ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size >
      (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound2]
  have hextract2 : (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
      lebEncode v.size ++ v ++ serializeParia rest' ++ rest).extract
      ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size)
      ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size) = tag.toUTF8 := by
    have hpre3_size : (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size).size =
        (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size := by
      simp [ByteArray.size_append]
    rw [show (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size =
        (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size).size from hpre3_size.symm]
    rw [show (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest) =
        lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        (lebEncode v.size ++ v ++ serializeParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    exact byteArray_extract_middle (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size) tag.toUTF8
      (lebEncode v.size ++ v ++ serializeParia rest' ++ rest)
  rw [hextract2, String.fromUTF8?_toUTF8]
  have hread3 : lebDecode (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
      lebEncode v.size ++ v ++ serializeParia rest' ++ rest)
      ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size) =
      some (v.size,
            (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
            (lebEncode v.size).size) := by
    have hpre4_size : (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8).size =
        (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size := by
      simp [ByteArray.size_append]
    rw [show (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size =
        (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8).size from hpre4_size.symm]
    rw [show (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++ lebEncode v.size ++ v ++
        serializeParia rest' ++ rest) =
        (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8) ++
        (lebEncode v.size ++ v ++ serializeParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    rw [show (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8).size =
        (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8).size + 0 from by omega]
    rw [lebDecodeAdPraefixumGen]
    rw [show (lebEncode v.size ++ v ++ serializeParia rest' ++ rest) =
        lebEncode v.size ++ (v ++ serializeParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    rw [lebDecodeEncodeRecursus v.size]
    simp [Option.map]
  rw [hread3]
  have hbound3 : ¬ ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
      (lebEncode v.size).size + v.size >
      (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound3]
  have hextract3 : (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
      lebEncode v.size ++ v ++ serializeParia rest' ++ rest).extract
      ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
        (lebEncode v.size).size)
      ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
        (lebEncode v.size).size + v.size) = v := by
    have hpre5_size : (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size).size =
        (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
        (lebEncode v.size).size := by
      simp [ByteArray.size_append]
    rw [show (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
        (lebEncode v.size).size =
        (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++ lebEncode v.size).size
        from hpre5_size.symm]
    rw [show (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest) =
        lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ (serializeParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    exact byteArray_extract_middle
      (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++ lebEncode v.size) v
      (serializeParia rest' ++ rest)
  rw [hextract3]
  have hse_size : (serializeEntrada k tag v).size =
      (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
      (lebEncode v.size).size + v.size := by
    simp [serializeEntrada, ByteArray.size_append]
  rw [show (lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
      (lebEncode v.size).size + v.size = (serializeEntrada k tag v).size
      from hse_size.symm]
  rw [show (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
      lebEncode v.size ++ v ++ serializeParia rest' ++ rest) =
      serializeEntrada k tag v ++ (serializeParia rest' ++ rest) from by
    simp [serializeEntrada, ByteArray.append_assoc]]
  rw [show (serializeEntrada k tag v).size = (serializeEntrada k tag v).size + 0 from by omega]
  rw [legereParia_at_prefix]
  rw [ih]
  simp [Option.map]
  exact hse_size

/-- legereParia が serializeParia を正しく復元するにゃん -/
theorem legereParia_serializeParia
    (paria : List (String × String × ByteArray)) (rest : ByteArray) :
    legereParia (serializeParia paria ++ rest) paria.length 0 =
      some (paria, (serializeParia paria).size) := by
  induction paria with
  | nil => simp [legereParia, serializeParia, ByteArray.size]
  | cons entry rest' ih =>
    obtain ⟨k, tag, v⟩ := entry
    simp only [serializeParia, List.length_cons]
    simp only [ByteArray.size_append]
    exact legereParia_cons k tag v rest' rest ih

/-- セリアーリザーティオーしてデセリアーリザーティオーすると元のデータに戻るにゃん♪ -/
theorem serializeMappam_roundtrip (paria : List (String × String × ByteArray)) :
    deserializeMappam (serializeMappam paria) = some paria := by
  have hsize : ¬ ((magicBytes ++ lebEncode paria.length ++ serializeParia paria).size < 5) := by
    simp only [ByteArray.size_append]
    have h1 : magicBytes.size = 4 := rfl
    have h2 : 0 < (lebEncode paria.length).size := longitudoLebEncodePositiva paria.length
    omega
  have hmagic : (magicBytes ++ lebEncode paria.length ++ serializeParia paria).extract 0 4 =
      magicBytes := by
    rw [ByteArray.append_assoc]; exact ByteArray.extract_append_eq_left rfl
  have hbne : ((magicBytes ++ lebEncode paria.length ++ serializeParia paria).extract 0 4
      != magicBytes) = false := by rw [hmagic]; native_decide
  have h_read := lebDecodeAdPraefixum magicBytes paria.length (serializeParia paria)
  simp only [show magicBytes.size = 4 from rfl] at h_read
  have h_pre_sz : (magicBytes ++ lebEncode paria.length).size =
      4 + (lebEncode paria.length).size := by
    simp only [ByteArray.size_append]; have h1 : magicBytes.size = 4 := rfl; omega
  have h_legere := legereParia_at_prefix paria.length 0
    (magicBytes ++ lebEncode paria.length) (serializeParia paria)
  simp only [h_pre_sz, Nat.add_zero] at h_legere
  have h_sp := legereParia_serializeParia paria .empty
  simp only [ByteArray.append_empty] at h_sp
  simp only [deserializeMappam, serializeMappam]
  rw [if_neg hsize, hbne, if_neg (by decide)]
  simp [h_read, h_legere, h_sp, Option.map_some]

end Signaculum.Memoria
