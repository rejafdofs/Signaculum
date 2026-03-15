-- PuraShiori.LemmaStatusPermanens
-- StatusPermanens 關連の sorry 補題にゃん
-- Lemma.lean と同じ位置づけだが、StatusPermanens の内部定義を參照するため
-- インポート順の都合でここに分離してゐるにゃ

import PuraShiori.AuxiliaStatusPermanens

namespace PuraShiori

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
  -- lebDecode で鍵長を讀むにゃん
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
  -- 境界チェック 1 にゃん
  have hbound1 : ¬ ((lebEncode k.toUTF8.size).size + k.toUTF8.size >
      (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
       lebEncode v.size ++ v ++ serializeParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound1]
  -- extract で鍵を取り出すにゃん（byteArray_extract_middle を使ふにゃ）
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
  -- lebDecode でタグ長を讀むにゃん
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
  -- 境界チェック 2 にゃん
  have hbound2 : ¬ ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size >
      (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound2]
  -- extract でタグを取り出すにゃん
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
  -- lebDecode で値長を讀むにゃん
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
  -- 境界チェック 3 にゃん
  have hbound3 : ¬ ((lebEncode k.toUTF8.size).size + k.toUTF8.size + (lebEncode tag.toUTF8.size).size + tag.toUTF8.size +
      (lebEncode v.size).size + v.size >
      (lebEncode k.toUTF8.size ++ k.toUTF8 ++ lebEncode tag.toUTF8.size ++ tag.toUTF8 ++
        lebEncode v.size ++ v ++ serializeParia rest' ++ rest).size) := by
    simp only [ByteArray.size_append]; omega
  simp only [if_neg hbound3]
  -- extract で値を取り出すにゃん
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
  -- legereParia_at_prefix で帰納仮説を適用するにゃん
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

-- ═══════════════════════════════════════════════════
-- 証明領域にゃん
-- ═══════════════════════════════════════════════════

/-- セリアーリザーティオーしてデセリアーリザーティオーすると元のデータに戻るにゃん♪ -/
theorem serializeMappam_roundtrip (paria : List (String × String × ByteArray)) :
    deserializeMappam (serializeMappam paria) = some paria := by
  -- Step 1: 補助事實にゃ
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
  -- Step 2: 展開 + if ガード除去にゃん
  simp only [deserializeMappam, serializeMappam]
  rw [if_neg hsize, hbne, if_neg (by decide)]
  -- Step 3: bind チェーンを simp で整理にゃん
  simp [h_read, h_legere, h_sp, Option.map_some]

end PuraShiori
