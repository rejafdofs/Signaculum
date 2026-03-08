-- PuraShiori.Lemma
-- 証明可能だが後回しの補題（sorry）と、証明済み補題を置く場所にゃん
-- StatusPermanens 関連の sorry 補題は import 順の都合で
-- LemmaStatusPermanens.lean に置いてあるにゃ
import Aesop
import PuraShiori.Axiom

-- ═══════════════════════════════════════════════════
-- ちゃんと証明領域にゃん
-- ═══════════════════════════════════════════════════

/-- String は UTF-8 バイト列への往復が保証されるにゃ -/
theorem String.fromUTF8?_toUTF8 (s : String) : String.fromUTF8? s.toUTF8 = some s:=by
  simp_all only [toUTF8_eq_toByteArray]
  have h:=s.isValidUTF8
  rw[fromUTF8?]
  simp_all only [↓reduceDIte, Option.some.injEq]
  rfl

/-- n < 2^64 なら n.toUInt64.toNat = n にゃ -/
theorem Nat.toUInt64_toNat_of_lt {n : Nat} (h : n < 2^64) : n.toUInt64.toNat = n := by
  simp only [Nat.toUInt64, UInt64.toNat]
  exact Nat.mod_eq_of_lt h

-- ═══════════════════════════════════════════════════
-- sorry 領域（理論上証明可能だが後回し）にゃん
-- ═══════════════════════════════════════════════════

/-- Nat.repr は toNat? で往復するにゃ（Lean 4 ソースに `-- todo: lemmas` とある）-/
theorem Nat.toNat?_repr (n : Nat) : (Nat.repr n).toNat? = some n:=by
  sorry

/-- toString は toInt? で往復するにゃ（Lean 4 ソースに `-- todo: lemmas` とある）-/
theorem Int.toInt?_toString (n : Int) : (toString n).toInt? = some n:=by
  sorry

/-- (a ++ b ++ c).extract a.size (a.size + b.size) = b にゃん
    Array.extract の補題から証明可能だが複雑にゃ -/
theorem byteArray_extract_middle (a b c : ByteArray) :
    (a ++ b ++ c).extract a.size (a.size + b.size) = b := by
  sorry

/-- Nat.repr の各文字は isDigit にゃん（帰納法で証明可能）-/
theorem Nat.repr_isDigit (n : Nat) : ∀ c ∈ (Nat.repr n).toList, c.isDigit := by
  sorry

/-- Nat.repr の文字はコロン (:) を含まないにゃ（repr_isDigit から導出）-/
theorem Nat.repr_not_colon (n : Nat) : ':' ∉ (Nat.repr n).toList := by
  intro hmem
  have hdig := Nat.repr_isDigit n ':' hmem
  simp [Char.isDigit] at hdig

theorem List.span_isDigit_repr (n : Nat) (rest : List Char) :
    (((Nat.repr n).toList ++ [':'] ++ rest).span Char.isDigit) =
      ((Nat.repr n).toList, [':'] ++ rest) := by
  sorry
