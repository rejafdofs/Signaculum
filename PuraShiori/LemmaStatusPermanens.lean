-- PuraShiori.LemmaStatusPermanens
-- StatusPermanens 関連の sorry 補題にゃん
-- Lemma.lean と同じ位置づけだが、StatusPermanens の内部定義を参照するため
-- import 順の都合でここに分離してゐるにゃ

import PuraShiori.StatusPermanens

namespace PuraShiori

-- ═══════════════════════════════════════════════════
-- sorry 領域（理論上証明可能だが後回し）にゃん
-- ═══════════════════════════════════════════════════

/-- prefix を前置しても lebDecode の結果は位置だけずれるにゃん -/
theorem lebDecode_at_prefix (pre : ByteArray) (n : Nat) (rest : ByteArray) :
    lebDecode (pre ++ lebEncode n ++ rest) pre.size =
      some (n, pre.size + (lebEncode n).size) := by sorry

/-- prefix を前置しても legereParia の結果は位置だけずれるにゃん -/
theorem legereParia_at_prefix (cnt pos : Nat) (pre dat : ByteArray) :
    legereParia (pre ++ dat) cnt (pre.size + pos) =
      (legereParia dat cnt pos).map (fun (ps, q) => (ps, pre.size + q)) := by sorry

/-- legereParia が serializeParia を正しく復元するにゃん -/
theorem legereParia_serializeParia
    (paria : List (String × String × ByteArray)) (rest : ByteArray) :
    legereParia (serializeParia paria ++ rest) paria.length 0 =
      some (paria, (serializeParia paria).size) := by sorry

-- ═══════════════════════════════════════════════════
-- 証明領域にゃん
-- ═══════════════════════════════════════════════════

/-- シリアライズしてデシリアライズすると元のデータに戻るにゃん♪
    sorry 補題（lebDecode_at_prefix, legereParia_at_prefix, legereParia_serializeParia）を使ふにゃ -/
theorem serializeMappam_roundtrip (paria : List (String × String × ByteArray)) :
    deserializeMappam (serializeMappam paria) = some paria := by
  -- Step 1: 補助事実にゃ
  have hsize : ¬ ((magicBytes ++ lebEncode paria.length ++ serializeParia paria).size < 5) := by
    simp only [ByteArray.size_append]
    have h1 : magicBytes.size = 4 := rfl
    have h2 : 0 < (lebEncode paria.length).size := lebEncode_size_pos paria.length
    omega
  have hmagic : (magicBytes ++ lebEncode paria.length ++ serializeParia paria).extract 0 4 =
      magicBytes := by
    rw [ByteArray.append_assoc]; exact ByteArray.extract_append_eq_left rfl
  have hbne : ((magicBytes ++ lebEncode paria.length ++ serializeParia paria).extract 0 4
      != magicBytes) = false := by rw [hmagic]; native_decide
  have h_read := lebDecode_at_prefix magicBytes paria.length (serializeParia paria)
  simp only [show magicBytes.size = 4 from rfl] at h_read
  have h_pre_sz : (magicBytes ++ lebEncode paria.length).size =
      4 + (lebEncode paria.length).size := by
    simp only [ByteArray.size_append]; have h1 : magicBytes.size = 4 := rfl; omega
  have h_legere := legereParia_at_prefix paria.length 0
    (magicBytes ++ lebEncode paria.length) (serializeParia paria)
  simp only [h_pre_sz, Nat.add_zero] at h_legere
  have h_sp := legereParia_serializeParia paria .empty
  simp only [ByteArray.append_empty] at h_sp
  -- Step 2: 展開 + if ガード除去にゃ
  simp only [deserializeMappam, serializeMappam]
  rw [if_neg hsize, hbne, if_neg (by decide)]
  -- Step 3: bind チェーンを simp で整理にゃ
  simp [h_read, h_legere, h_sp, Option.map_some]

end PuraShiori
