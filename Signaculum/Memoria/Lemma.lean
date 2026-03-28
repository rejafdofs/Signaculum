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
    decodificaAgrum (pre ++ dat) (pre.size + pos) =
      ((decodificaAgrum dat pos : Option (α × Nat)).map (fun vp => (vp.1, pre.size + vp.2))) := by
  rcases h_leb : lebDecodifica dat pos with _ | ⟨longitudo, pos'⟩
  · have h_pre : lebDecodifica (pre ++ dat) (pre.size + pos) = none := by
      rw [lebDecodificaAdPraefixumGen, h_leb]; rfl
    simp [decodificaAgrum, bind, Option.bind, h_pre, h_leb, Option.map]
  · have h_pre : lebDecodifica (pre ++ dat) (pre.size + pos) = some (longitudo, pre.size + pos') := by
      rw [lebDecodificaAdPraefixumGen, h_leb]; rfl
    simp only [decodificaAgrum, bind, Option.bind, h_pre, h_leb]
    rw [show pre.size + pos' + longitudo = pre.size + (pos' + longitudo) from by omega]
    rw [extractioPraefixo pre dat pos' (pos' + longitudo)]
    rcases StatusPermanens.eBytes (dat.extract pos' (pos' + longitudo)) with _ | v
    · simp [Option.map]
    · simp [Option.map_some]

private theorem decodeCampiCodicampi {α : Type} [StatusPermanens α]
    (v : α) (rest : ByteArray) :
    decodificaAgrum (codificaAgrum v ++ rest) 0 = some (v, (codificaAgrum v).size) := by
  unfold decodificaAgrum codificaAgrum
  have h_leb := lebDecodificaCodificaRecursus (StatusPermanens.adBytes v).size
                  (StatusPermanens.adBytes v ++ rest)
  rw [← ByteArray.append_assoc] at h_leb
  simp only [h_leb, bind, Option.bind]
  have hext : (lebCodifica (StatusPermanens.adBytes v).size ++
               StatusPermanens.adBytes v ++ rest).extract
               (lebCodifica (StatusPermanens.adBytes v).size).size
               ((lebCodifica (StatusPermanens.adBytes v).size).size +
                (StatusPermanens.adBytes v).size) =
              StatusPermanens.adBytes v :=
    byteArray_extract_middle (lebCodifica _) (StatusPermanens.adBytes v) rest
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
  eBytes  b := legeU16LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := legereU16LERecursus n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

instance : StatusPermanens UInt32 where
  typusTag := "UInt32"
  adBytes n := u32LE n
  eBytes  b := legeU32LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := legereU32LERecursus n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

instance : StatusPermanens UInt64 where
  typusTag := "UInt64"
  adBytes n := u64LE n
  eBytes  b := legeU64LE b 0 |>.map (fun (v, _) => v)
  roundtrip n := by
    have h := legereU64LERecursus n .empty
    simp [ByteArray.append_empty] at h
    simp [h]

instance : StatusPermanens Char where
  typusTag := "Char"
  adBytes c := u32LE c.val
  eBytes  b := do
    let (n, _) ← legeU32LE b 0
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
    let (v, pos') ← decodificaAgrum b positio
    let (residuum, positioFinalis) ← decodePluraIteratio b n pos'
    return (v :: residuum, positioFinalis)

private def encodePluraIteratio {α : Type} [StatusPermanens α]
    (xs : List α) : ByteArray :=
  match xs with
  | []      => .empty
  | x :: xs => codificaAgrum x ++ encodePluraIteratio xs

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
    cases hdf : (decodificaAgrum dat pos : Option (α × Nat)) with
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
                   (codificaAgrum x) (encodePluraIteratio xs ++ rest)
    simp only [Nat.add_zero] at hpfx
    rw [hpfx, ih]
    simp only [Option.map_some]
    rfl

instance {α : Type} [StatusPermanens α] : StatusPermanens (List α) where
  typusTag := "List(" ++ StatusPermanens.typusTag (α := α) ++ ")"
  adBytes xs := lebCodifica xs.length ++ encodePluraIteratio xs
  eBytes b := do
    let (numerus, positio) ← lebDecodifica b 0
    let (xs, _) ← decodePluraIteratio b numerus positio
    return xs
  roundtrip xs := by
    simp only []
    have h_leb := lebDecodificaCodificaRecursus xs.length (encodePluraIteratio xs)
    simp only [bind, Option.bind, h_leb]
    have hml := decodePluraIteratioIgnoraPraefixum α xs.length 0
      (lebCodifica xs.length) (encodePluraIteratio xs)
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
  adBytes p := codificaAgrum p.1 ++ codificaAgrum p.2
  eBytes b := do
    let (a, positio) ← decodificaAgrum b 0
    let (secundum, _) ← decodificaAgrum b positio
    return (a, secundum)
  roundtrip p := by
    obtain ⟨a, b⟩ := p
    simp only []
    have ha := decodeCampiCodicampi a (codificaAgrum b)
    simp only [ha, bind, Option.bind]
    have hbe : decodificaAgrum (codificaAgrum b) 0 = some (b, (codificaAgrum b).size) := by
      have h := decodeCampiCodicampi b ByteArray.empty
      simp only [ByteArray.append_empty] at h
      exact h
    have hb : decodificaAgrum (codificaAgrum a ++ codificaAgrum b) (codificaAgrum a).size =
              some (b, (codificaAgrum a).size + (codificaAgrum b).size) := by
      have h := (decodeCampiAdPraefixum (α := β) (codificaAgrum a) (codificaAgrum b) 0)
      simp only [Nat.add_zero] at h
      rw [h, hbe]
      simp [Option.map]
    simp [hb]

-- ═══════════════════════════════════════════════════
-- ordinaMappam 關連の補題にゃん
-- ═══════════════════════════════════════════════════

/-- プラエフィクスムを前置しても lebDecodifica の結果は位置だけずれるにゃん -/
theorem lebDecodificaAdPraefixum (pre : ByteArray) (n : Nat) (rest : ByteArray) :
    lebDecodifica (pre ++ lebCodifica n ++ rest) pre.size =
      some (n, pre.size + (lebCodifica n).size) := by
  rw [show pre.size = pre.size + 0 from by omega]
  rw [ByteArray.append_assoc]
  rw [lebDecodificaAdPraefixumGen pre (lebCodifica n ++ rest) 0]
  simp only [Nat.add_zero]
  rw [lebDecodificaCodificaRecursus n rest]
  simp [Option.map]

/-- プラエフィクスムを前置しても legereParia の結果は位置だけずれるにゃん -/
theorem legereParia_at_prefix (cnt pos : Nat) (pre dat : ByteArray) :
    legereParia (pre ++ dat) cnt (pre.size + pos) =
      (legereParia dat cnt pos).map (fun (ps, q) => (ps, pre.size + q)) := by
  induction cnt generalizing pos with
  | zero => simp [legereParia]
  | succ n ih =>
    simp only [legereParia, bind, Option.bind]
    rw [lebDecodificaAdPraefixumGen pre dat pos]
    rcases lebDecodifica dat pos with _ | ⟨longitudoNominis, pos1⟩
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
        · rw [lebDecodificaAdPraefixumGen pre dat (pos1 + longitudoNominis)]
          rcases lebDecodifica dat (pos1 + longitudoNominis) with _ | ⟨longitudoTypi, pos3⟩
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
              · rw [lebDecodificaAdPraefixumGen pre dat (pos3 + longitudoTypi)]
                rcases lebDecodifica dat (pos3 + longitudoTypi) with _ | ⟨longitudoValorum, pos5⟩
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

/-- ordinaIntroitum を一つ讀んで残りに legereParia を適用すると正しく復元するにゃん -/
private theorem legereParia_cons
    (k tag : String) (v : ByteArray) (rest' : List (String × String × ByteArray))
    (rest : ByteArray)
    (ih : legereParia (ordinaParia rest' ++ rest) rest'.length 0 =
          some (rest', (ordinaParia rest').size)) :
    legereParia (ordinaIntroitum k tag v ++ ordinaParia rest' ++ rest)
      (rest'.length + 1) 0 =
      some ((k, tag, v) :: rest',
            (ordinaIntroitum k tag v).size + (ordinaParia rest').size) := by
  simp only [ordinaIntroitum]
  simp only [legereParia]
  have hread1 : lebDecodifica (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
      lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) 0 =
      some (k.toUTF8.size, (lebCodifica k.toUTF8.size).size) := by
    rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) =
        lebCodifica k.toUTF8.size ++ (k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    exact lebDecodificaCodificaRecursus k.toUTF8.size _
  rw [hread1]
  simp only [bind, Option.bind]
  have hbound1 : ¬ ((lebCodifica k.toUTF8.size).size + k.toUTF8.size >
      (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
       lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound1]
  have hextract1 : (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
      lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest).extract
      (lebCodifica k.toUTF8.size).size ((lebCodifica k.toUTF8.size).size + k.toUTF8.size) = k.toUTF8 := by
    rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) =
        lebCodifica k.toUTF8.size ++ k.toUTF8 ++
        (lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++ lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    exact byteArray_extract_middle (lebCodifica k.toUTF8.size) k.toUTF8
      (lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++ lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest)
  rw [hextract1, String.fromUTF8?_toUTF8]
  have hread2 : lebDecodifica (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
      lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest)
      ((lebCodifica k.toUTF8.size).size + k.toUTF8.size) =
      some (tag.toUTF8.size, (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size) := by
    have hpre2_size : (lebCodifica k.toUTF8.size ++ k.toUTF8).size = (lebCodifica k.toUTF8.size).size + k.toUTF8.size := by
      simp [ByteArray.size_append]
    rw [show (lebCodifica k.toUTF8.size).size + k.toUTF8.size =
        (lebCodifica k.toUTF8.size ++ k.toUTF8).size from hpre2_size.symm]
    rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) =
        (lebCodifica k.toUTF8.size ++ k.toUTF8) ++ (lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8).size = (lebCodifica k.toUTF8.size ++ k.toUTF8).size + 0 from by omega]
    rw [lebDecodificaAdPraefixumGen]
    rw [show (lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++ lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) =
        lebCodifica tag.toUTF8.size ++ (tag.toUTF8 ++ lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    rw [lebDecodificaCodificaRecursus tag.toUTF8.size]
    simp [Option.map]
  rw [hread2]
  have hbound2 : ¬ ((lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size >
      (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound2]
  have hextract2 : (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
      lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest).extract
      ((lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size)
      ((lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size) = tag.toUTF8 := by
    have hpre3_size : (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size).size =
        (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size := by
      simp [ByteArray.size_append]
    rw [show (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size =
        (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size).size from hpre3_size.symm]
    rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) =
        lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        (lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    exact byteArray_extract_middle (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size) tag.toUTF8
      (lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest)
  rw [hextract2, String.fromUTF8?_toUTF8]
  have hread3 : lebDecodifica (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
      lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest)
      ((lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size) =
      some (v.size,
            (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size +
            (lebCodifica v.size).size) := by
    have hpre4_size : (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8).size =
        (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size := by
      simp [ByteArray.size_append]
    rw [show (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size =
        (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8).size from hpre4_size.symm]
    rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++ lebCodifica v.size ++ v ++
        ordinaParia rest' ++ rest) =
        (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8) ++
        (lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8).size =
        (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8).size + 0 from by omega]
    rw [lebDecodificaAdPraefixumGen]
    rw [show (lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) =
        lebCodifica v.size ++ (v ++ ordinaParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    rw [lebDecodificaCodificaRecursus v.size]
    simp [Option.map]
  rw [hread3]
  have hbound3 : ¬ ((lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size +
      (lebCodifica v.size).size + v.size >
      (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound3]
  have hextract3 : (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
      lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest).extract
      ((lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size +
        (lebCodifica v.size).size)
      ((lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size +
        (lebCodifica v.size).size + v.size) = v := by
    have hpre5_size : (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size).size =
        (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size +
        (lebCodifica v.size).size := by
      simp [ByteArray.size_append]
    rw [show (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size +
        (lebCodifica v.size).size =
        (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++ lebCodifica v.size).size
        from hpre5_size.symm]
    rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) =
        lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
        lebCodifica v.size ++ v ++ (ordinaParia rest' ++ rest) from by
      simp [ByteArray.append_assoc]]
    exact byteArray_extract_middle
      (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++ lebCodifica v.size) v
      (ordinaParia rest' ++ rest)
  rw [hextract3]
  have hse_size : (ordinaIntroitum k tag v).size =
      (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size +
      (lebCodifica v.size).size + v.size := by
    simp [ordinaIntroitum, ByteArray.size_append]
  rw [show (lebCodifica k.toUTF8.size).size + k.toUTF8.size + (lebCodifica tag.toUTF8.size).size + tag.toUTF8.size +
      (lebCodifica v.size).size + v.size = (ordinaIntroitum k tag v).size
      from hse_size.symm]
  rw [show (lebCodifica k.toUTF8.size ++ k.toUTF8 ++ lebCodifica tag.toUTF8.size ++ tag.toUTF8 ++
      lebCodifica v.size ++ v ++ ordinaParia rest' ++ rest) =
      ordinaIntroitum k tag v ++ (ordinaParia rest' ++ rest) from by
    simp [ordinaIntroitum, ByteArray.append_assoc]]
  rw [show (ordinaIntroitum k tag v).size = (ordinaIntroitum k tag v).size + 0 from by omega]
  rw [legereParia_at_prefix]
  rw [ih]
  simp [Option.map]
  exact hse_size

/-- legereParia が ordinaParia を正しく復元するにゃん -/
theorem legereParia_ordinaParia
    (paria : List (String × String × ByteArray)) (rest : ByteArray) :
    legereParia (ordinaParia paria ++ rest) paria.length 0 =
      some (paria, (ordinaParia paria).size) := by
  induction paria with
  | nil => simp [legereParia, ordinaParia, ByteArray.size]
  | cons entry rest' ih =>
    obtain ⟨k, tag, v⟩ := entry
    simp only [ordinaParia, List.length_cons]
    simp only [ByteArray.size_append]
    exact legereParia_cons k tag v rest' rest ih

/-- セリアーリザーティオーしてデセリアーリザーティオーすると元のデータに戻るにゃん♪ -/
theorem ordinaMappam_roundtrip (paria : List (String × String × ByteArray)) :
    resolveMappam (ordinaMappam paria) = some paria := by
  have hsize : ¬ ((octetiMagici ++ lebCodifica paria.length ++ ordinaParia paria).size < 5) := by
    simp only [ByteArray.size_append]
    have h1 : octetiMagici.size = 4 := rfl
    have h2 : 0 < (lebCodifica paria.length).size := longitudoLebEncodePositiva paria.length
    omega
  have hmagic : (octetiMagici ++ lebCodifica paria.length ++ ordinaParia paria).extract 0 4 =
      octetiMagici := by
    rw [ByteArray.append_assoc]; exact ByteArray.extract_append_eq_left rfl
  have hbne : ((octetiMagici ++ lebCodifica paria.length ++ ordinaParia paria).extract 0 4
      != octetiMagici) = false := by rw [hmagic]; native_decide
  have h_read := lebDecodificaAdPraefixum octetiMagici paria.length (ordinaParia paria)
  simp only [show octetiMagici.size = 4 from rfl] at h_read
  have h_pre_sz : (octetiMagici ++ lebCodifica paria.length).size =
      4 + (lebCodifica paria.length).size := by
    simp only [ByteArray.size_append]; have h1 : octetiMagici.size = 4 := rfl; omega
  have h_legere := legereParia_at_prefix paria.length 0
    (octetiMagici ++ lebCodifica paria.length) (ordinaParia paria)
  simp only [h_pre_sz, Nat.add_zero] at h_legere
  have h_sp := legereParia_ordinaParia paria .empty
  simp only [ByteArray.append_empty] at h_sp
  simp only [resolveMappam, ordinaMappam]
  rw [if_neg hsize, hbne, if_neg (by decide)]
  simp [h_read, h_legere, h_sp, Option.map_some]

end Signaculum.Memoria
