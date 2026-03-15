-- PuraShiori.AuxiliaStatusPermanens
-- StatusPermanens クラスに關聯する補助關數・コーディフィカーティオー・シリアーリザーティオーにゃん♪
-- LE/LEB128 エンコード、encodeField/decodeField、ビーナーリウム讀み書きを提供するにゃ

import Std.Tactic.BVDecide
import LemmaGeneralis
import Aesop
import PuraShiori.StatusPermanens
namespace PuraShiori

-- ═══════════════════════════════════════════════════
-- 内部補助: リトルエンディアン(LE)のコーディフィカーティオー/デコーディフィカーティオーにゃん
-- ═══════════════════════════════════════════════════

def u16LE (n : UInt16) : ByteArray :=
  .mk #[(n &&& 0xFF).toUInt8,
        ((n >>> 8) &&& 0xFF).toUInt8]

def u32LE (n : UInt32) : ByteArray :=
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
def readU16LE (b : ByteArray) (positio : Nat) : Option (UInt16 × Nat) :=
  if positio + 2 > b.size then none
  else some (
    b[positio]!.toUInt16 |||
    (b[positio+1]!.toUInt16 <<< 8),
    positio + 2)

def readU32LE (b : ByteArray) (positio : Nat) : Option (UInt32 × Nat) :=
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
-- LEB128: 任意精度 Nat のオクテートゥス列コーディフィカーティオーにゃん
-- u64LE と違ひ 2^64 超の値も正確にレクルススするにゃ♪
-- ═══════════════════════════════════════════════════

/-- LEB128 コーディフィカーティオー: 7 ビットずつ、続きあり = 最上位ビット 1 にゃ -/
def lebEncode (n : Nat) : ByteArray :=
  if n < 128 then .mk #[n.toUInt8]
  else .mk #[((n % 128 + 128).toUInt8)] ++ lebEncode (n / 128)
termination_by n
decreasing_by
  apply Nat.div_lt_self
  · omega
  · decide

/-- LEB128 デコーディフィカーティオー補助（燃料附き）にゃ -/
private def lebDecodeLoop : Nat → ByteArray → Nat → Nat → Nat → Option (Nat × Nat)
  | 0,        _, _,   _,   _    => none
  | fuel + 1, b, pos, acc, mult =>
    if pos < b.size then
      let byte := b[pos]!.toNat
      if byte < 128 then some (acc + byte * mult, pos + 1)
      else lebDecodeLoop fuel b (pos + 1) (acc + (byte - 128) * mult) (mult * 128)
    else none

/-- LEB128 デコーディフィカーティオー: `pos` から読み出して `(値, 次の位置)` を返すにゃ -/
def lebDecode (b : ByteArray) (pos : Nat) : Option (Nat × Nat) :=
  lebDecodeLoop (b.size - pos + 1) b pos 0 1

-- ═══════════════════════════════════════════════════
-- LEB128 証明補題にゃん
-- ═══════════════════════════════════════════════════

@[simp] private theorem longitudoMk1 (x : UInt8) : (ByteArray.mk #[x]).size = 1 := rfl
@[simp] private theorem longitudoStruct1 (x : UInt8) :
    ({ data := #[x] } : ByteArray).size = 1 := rfl

private theorem elementumInPrefixo (pre : ByteArray) (x : UInt8) (suf : ByteArray) :
    (pre ++ ByteArray.mk #[x] ++ suf)[pre.size]! = x := by
  have hlt : pre.size < (pre ++ ByteArray.mk #[x] ++ suf).size := by
    simp [ByteArray.size_append]; omega
  rw [show (pre ++ ByteArray.mk #[x] ++ suf)[pre.size]! =
        (pre ++ ByteArray.mk #[x] ++ suf)[pre.size] from
      getElem!_pos (pre ++ ByteArray.mk #[x] ++ suf) pre.size hlt]
  rw [ByteArray.getElem_append_left (h := by simp [ByteArray.size_append]; omega)
        (hlt := by simp [ByteArray.size_append])]
  rw [ByteArray.getElem_append_right (hle := Nat.le_refl _) (h := by simp)]
  simp only [Nat.sub_self]
  change (ByteArray.mk #[x])[0]'(by simp [ByteArray.size, Array.size]) = x; rfl

private theorem elementumInPrefixo2 (pre : ByteArray) (x : UInt8) (mid suf : ByteArray) :
    (pre ++ (ByteArray.mk #[x] ++ mid) ++ suf)[pre.size]! = x := by
  rw [show pre ++ (ByteArray.mk #[x] ++ mid) = pre ++ ByteArray.mk #[x] ++ mid from
      ByteArray.append_assoc.symm, ByteArray.append_assoc]
  exact elementumInPrefixo pre x (mid ++ suf)

private theorem uInt8AdNat (n : Nat) (h : n < 256) : n.toUInt8.toNat = n := by
  show (UInt8.ofNat n).toNat = n; simp [UInt8.ofNat, UInt8.toNat]; omega

/-- lebEncode は必ず 1 バイト以上を返すにゃん -/
theorem longitudoLebEncodePositiva (n : Nat) : 0 < (lebEncode n).size := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
  cases Nat.lt_or_ge n 128 with
  | inl h => rw [lebEncode, if_pos h]; simp
  | inr h =>
    rw [lebEncode, if_neg (Nat.not_lt.mpr h), ByteArray.size_append]
    have := ih (n / 128) (Nat.div_lt_self (by omega) (by decide)); simp; omega

private theorem arithmeticaMultipla (acc n mult : Nat) :
    acc + n % 128 * mult + n / 128 * (mult * 128) = acc + n * mult := by
  have key : 128 * (n / 128) + n % 128 = n := Nat.div_add_mod n 128
  have e1 : n / 128 * (mult * 128) = mult * (128 * (n / 128)) := by
    simp [Nat.mul_comm, Nat.mul_left_comm]
  rw [e1, show n % 128 * mult = mult * (n % 128) from Nat.mul_comm _ _]
  suffices h : mult * (n % 128) + mult * (128 * (n / 128)) = n * mult by omega
  rw [show mult * (n % 128) + mult * (128 * (n / 128)) =
        mult * (n % 128 + 128 * (n / 128)) from (Nat.mul_add mult _ _).symm,
      Nat.add_comm, key, Nat.mul_comm]

private theorem lebDecodeIteratioRecta (n : Nat) :
    forall (fuel : Nat) (pre suf : ByteArray) (acc mult : Nat),
    (lebEncode n).size <= fuel ->
    lebDecodeLoop fuel (pre ++ lebEncode n ++ suf) pre.size acc mult =
      some (Prod.mk (acc + n * mult) (pre.size + (lebEncode n).size)) := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    intro fuel pre suf acc mult hfuel
    cases fuel with
    | zero => exfalso; have := longitudoLebEncodePositiva n; omega
    | succ fuel' =>
    simp only [lebDecodeLoop]
    cases Nat.lt_or_ge n 128 with
    | inl hn =>
      have henc : lebEncode n = ByteArray.mk #[n.toUInt8] := by
        rw [lebEncode]; simp only [if_pos hn]
      rw [henc]
      simp only [if_pos (show pre.size < (pre ++ ByteArray.mk #[n.toUInt8] ++ suf).size by
        simp [ByteArray.size_append]; omega)]
      rw [show (pre ++ ByteArray.mk #[n.toUInt8] ++ suf)[pre.size]!.toNat = n from by
        rw [elementumInPrefixo]; exact uInt8AdNat n (by omega)]
      simp only [if_pos hn, longitudoMk1]
    | inr hn =>
      have henc : lebEncode n =
          ByteArray.mk #[((n % 128 + 128).toUInt8)] ++ lebEncode (n / 128) := by
        rw [lebEncode]; simp only [if_neg (Nat.not_lt.mpr hn)]
      rw [henc]
      have henc_sz : (lebEncode n).size = 1 + (lebEncode (n / 128)).size := by
        rw [henc, ByteArray.size_append]; simp
      have hfuel' : (lebEncode (n / 128)).size <= fuel' := by omega
      simp only [if_pos (show pre.size <
            (pre ++ (ByteArray.mk #[((n % 128 + 128).toUInt8)] ++ lebEncode (n / 128)) ++ suf).size by
          simp [ByteArray.size_append]
          have := longitudoLebEncodePositiva (n / 128); omega)]
      rw [show (pre ++ (ByteArray.mk #[((n % 128 + 128).toUInt8)] ++ lebEncode (n / 128)) ++ suf)[pre.size]!.toNat
          = n % 128 + 128 from by
        rw [elementumInPrefixo2]; exact uInt8AdNat _ (by omega)]
      simp only [if_neg (show Not (n % 128 + 128 < 128) by omega)]
      rw [show n % 128 + 128 - 128 = n % 128 from by omega]
      rw [show pre ++ (ByteArray.mk #[((n % 128 + 128).toUInt8)] ++ lebEncode (n / 128)) ++ suf =
            (pre ++ ByteArray.mk #[((n % 128 + 128).toUInt8)]) ++ lebEncode (n / 128) ++ suf from by
        rw [show pre ++ (ByteArray.mk #[((n % 128 + 128).toUInt8)] ++ lebEncode (n / 128)) =
              pre ++ ByteArray.mk #[((n % 128 + 128).toUInt8)] ++ lebEncode (n / 128) from
          ByteArray.append_assoc.symm]]
      rw [show pre.size + 1 = (pre ++ ByteArray.mk #[((n % 128 + 128).toUInt8)]).size from by
        simp [ByteArray.size_append]]
      rw [ih (n / 128) (Nat.div_lt_self (by omega) (by decide)) fuel'
             (pre ++ ByteArray.mk #[((n % 128 + 128).toUInt8)]) suf
             (acc + n % 128 * mult) (mult * 128) hfuel']
      simp only [Option.some.injEq, Prod.mk.injEq]
      constructor
      · exact arithmeticaMultipla acc n mult
      · simp only [ByteArray.size_append, longitudoMk1]; omega

private theorem elementumDextriObliquum (pre dat : ByteArray) (pos : Nat)
    (hpos : pos < dat.size) :
    (pre ++ dat)[pre.size + pos]! = dat[pos]! := by
  have hlt : pre.size + pos < (pre ++ dat).size := by simp [ByteArray.size_append]; omega
  have h1 : (pre ++ dat)[pre.size + pos]! = (pre ++ dat)[pre.size + pos] :=
    getElem!_pos (pre ++ dat) (pre.size + pos) hlt
  have h2 : dat[pos]! = dat[pos] := getElem!_pos dat pos hpos
  rw [h1, h2]
  rw [ByteArray.getElem_append_right (hle := Nat.le_add_right _ _)
        (h := by simp [ByteArray.size_append]; omega)]
  simp [Nat.add_sub_cancel_left]

private theorem lebDecodeIteratioPraefixo (fuel : Nat) (pre dat : ByteArray) (pos acc mult : Nat) :
    lebDecodeLoop fuel (pre ++ dat) (pre.size + pos) acc mult =
      (lebDecodeLoop fuel dat pos acc mult).map (fun p => Prod.mk p.1 (pre.size + p.2)) := by
  induction fuel generalizing pos acc mult with
  | zero => simp [lebDecodeLoop]
  | succ fuel' ih =>
    simp only [lebDecodeLoop]
    cases Nat.lt_or_ge pos dat.size with
    | inl hpos =>
      have hpos' : pre.size + pos < (pre ++ dat).size := by simp [ByteArray.size_append]; omega
      simp only [if_pos hpos', if_pos hpos]
      rw [elementumDextriObliquum pre dat pos hpos]
      cases Nat.lt_or_ge (dat[pos]!.toNat) 128 with
      | inl hbyte =>
        simp only [if_pos hbyte, Option.map_some]; simp [Nat.add_assoc]
      | inr hbyte =>
        simp only [if_neg (Nat.not_lt.mpr hbyte)]
        rw [show pre.size + pos + 1 = pre.size + (pos + 1) from by omega]
        exact ih (pos + 1) _ _
    | inr hpos =>
      have hpos' : Not (pre.size + pos < (pre ++ dat).size) := by
        simp [ByteArray.size_append]; omega
      simp only [if_neg hpos', if_neg (Nat.not_lt.mpr hpos), Option.map_none]

theorem lebDecodeAdPraefixumGen (pre dat : ByteArray) (pos : Nat) :
    lebDecode (pre ++ dat) (pre.size + pos) =
      (lebDecode dat pos).map (fun p => Prod.mk p.1 (pre.size + p.2)) := by
  unfold lebDecode
  rw [show (pre ++ dat).size - (pre.size + pos) + 1 = dat.size - pos + 1 from by
    simp [ByteArray.size_append]; omega]
  exact lebDecodeIteratioPraefixo (dat.size - pos + 1) pre dat pos 0 1

private theorem extractioArrayPraefixo (pre dat : Array UInt8) (a b : Nat) :
    (pre ++ dat).extract (pre.size + a) (pre.size + b) = dat.extract a b := by
  simp [Array.ext_iff, Array.size_extract, Array.getElem_extract]

theorem extractioPraefixo (pre dat : ByteArray) (a b : Nat) :
    (pre ++ dat).extract (pre.size + a) (pre.size + b) = dat.extract a b := by
  apply ByteArray.ext
  simp only [ByteArray.extract, ByteArray.copySlice, ByteArray.data_append]
  have hemp : ByteArray.empty.data = #[] := rfl
  rw [hemp]
  have h_empty : forall (s e : Nat), (#[] : Array UInt8).extract s e = #[] := by
    intro s e; simp
  simp only [h_empty, Array.empty_append, Array.append_empty]
  cases Nat.lt_or_ge a b with
  | inl hab =>
    have h1 : pre.size + a + (pre.size + b - (pre.size + a)) = pre.size + b := by omega
    have h2 : a + (b - a) = b := by omega
    rw [h1, h2, show pre.size = pre.data.size from rfl]
    exact extractioArrayPraefixo pre.data dat.data a b
  | inr hab =>
    have h1 : pre.size + b - (pre.size + a) = 0 := by omega
    have h2 : b - a = 0 := by omega
    simp only [h1, h2, Nat.add_zero]
    simp [Array.ext_iff, Array.size_extract]

/-- lebDecode と lebEncode はレクルススするにゃん -/
theorem lebDecodeEncodeRecursus (n : Nat) (rest : ByteArray) :
    lebDecode (lebEncode n ++ rest) 0 = some (n, (lebEncode n).size) := by
  simp only [lebDecode]
  have hfuel : (lebEncode n).size <= (lebEncode n ++ rest).size - 0 + 1 := by
    rw [ByteArray.size_append]; omega
  have key := lebDecodeIteratioRecta n _ ByteArray.empty rest 0 1 hfuel
  simp only [ByteArray.empty_append, ByteArray.size_empty, Nat.zero_add, Nat.mul_one] at key
  exact key


-- ═══════════════════════════════════════════════════
-- 公開補助: 自作構造體のインスタンティア實裝に使ふにゃん♪
-- ═══════════════════════════════════════════════════

/-- 1フィールドを「LEB128 長 + 本體」の形でコーディフィカーティオーするにゃん。
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
-- LE レクルスス補題にゃん
-- ═══════════════════════════════════════════════════

-- UInt16 ──────────────────────────────────────────

private theorem uint16OctetiRecursus (n : UInt16) :
    (n &&& 0xFF).toUInt8.toUInt16 |||
    (((n >>> 8) &&& 0xFF).toUInt8.toUInt16 <<< 8) = n := by
  bv_decide

theorem legereU16LERecursus (n : UInt16) (rest : ByteArray) :
    readU16LE (u16LE n ++ rest) 0 = some (n, 2) := by
  unfold readU16LE u16LE
  have hsize : (ByteArray.mk #[(n &&& 0xFF).toUInt8,
      ((n >>> 8) &&& 0xFF).toUInt8] ++ rest).size = 2 + rest.size := by
    rw [ByteArray.size_append]; rfl
  have hsz : ¬ (0 + 2 > (ByteArray.mk #[(n &&& 0xFF).toUInt8,
      ((n >>> 8) &&& 0xFF).toUInt8] ++ rest).size) := by
    omega
  simp only [show 0 + 2 = 2 from rfl, hsz, ite_false]
  exact congrArg (fun x => some (x, 2)) (uint16OctetiRecursus n)

-- UInt32 ──────────────────────────────────────────

private theorem uint32OctetiRecursus (n : UInt32) :
    (n &&& 0xFF).toUInt8.toUInt32 |||
    (((n >>> 8) &&& 0xFF).toUInt8.toUInt32 <<< 8) |||
    (((n >>> 16) &&& 0xFF).toUInt8.toUInt32 <<< 16) |||
    (((n >>> 24) &&& 0xFF).toUInt8.toUInt32 <<< 24) = n := by
  bv_decide

theorem legereU32LERecursus (n : UInt32) (rest : ByteArray) :
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
  exact congrArg (fun x => some (x, 4)) (uint32OctetiRecursus n)

-- UInt64 ──────────────────────────────────────────

private theorem uint64OctetiRecursus (n : UInt64) :
    (n &&& 0xFF).toUInt8.toUInt64 |||
    (((n >>> 8)  &&& 0xFF).toUInt8.toUInt64 <<< 8)  |||
    (((n >>> 16) &&& 0xFF).toUInt8.toUInt64 <<< 16) |||
    (((n >>> 24) &&& 0xFF).toUInt8.toUInt64 <<< 24) |||
    (((n >>> 32) &&& 0xFF).toUInt8.toUInt64 <<< 32) |||
    (((n >>> 40) &&& 0xFF).toUInt8.toUInt64 <<< 40) |||
    (((n >>> 48) &&& 0xFF).toUInt8.toUInt64 <<< 48) |||
    (((n >>> 56) &&& 0xFF).toUInt8.toUInt64 <<< 56) = n := by
  bv_decide

theorem legereU64LERecursus (n : UInt64) (rest : ByteArray) :
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
  exact congrArg (fun x => some (x, 8)) (uint64OctetiRecursus n)


-- ═══════════════════════════════════════════════════
-- ビーナーリウムファスキクルス(ghost_status.bin)の讀み書きにゃん
-- 形式 v4: マーギクム(4) | 項目數(LEB128) | [鍵長(LEB128)|鍵|typusTag長(LEB128)|typusTag|値長(LEB128)|値]...
-- ═══════════════════════════════════════════════════

-- マーギクムバイト: "UKA\x04"（v4: LEB128 長さフィールド形式にゃ）
def magicBytes : ByteArray := .mk #[0x55, 0x4B, 0x41, 0x04]

-- 1エントリ (鍵, タグ, 値) をセリアーリザーティオーするにゃ
def serializeEntrada (k tag : String) (v : ByteArray) : ByteArray :=
  let ok := k.toUTF8; let ot := tag.toUTF8
  lebEncode ok.size ++ ok
  ++ lebEncode ot.size ++ ot
  ++ lebEncode v.size ++ v

-- エントリ列を再帰的にセリアーリザーティオーするにゃ（証明のための再帰形）
def serializeParia : List (String × String × ByteArray) → ByteArray
  | []              => .empty
  | (k, tag, v) :: rest => serializeEntrada k tag v ++ serializeParia rest

-- ビーナーリウムから (名前, 型タグ, オクテートゥス列) の三つ組を再帰的に讀むにゃ
def legereParia
    (b : ByteArray) (n : Nat) (positio : Nat)
    : Option (List (String × String × ByteArray) × Nat) :=
  match n with
  | 0     => some ([], positio)
  | n + 1 => do
    -- キー名にゃ
    let (longitudoNominis, pos1) ← lebDecode b positio
    if pos1 + longitudoNominis > b.size then none
    else do
      let octetiNominis := b.extract pos1 (pos1 + longitudoNominis)
      let nomenEntriae  ← String.fromUTF8? octetiNominis
      let pos2          := pos1 + longitudoNominis
      -- 型タグにゃ
      let (longitudoTypi, pos3) ← lebDecode b pos2
      if pos3 + longitudoTypi > b.size then none
      else do
        let octetiTypi := b.extract pos3 (pos3 + longitudoTypi)
        let tag        ← String.fromUTF8? octetiTypi
        let pos4       := pos3 + longitudoTypi
        -- 値にゃ
        let (longitudoValorum, pos5) ← lebDecode b pos4
        if pos5 + longitudoValorum > b.size then none
        else do
          let valor      := b.extract pos5 (pos5 + longitudoValorum)
          let pos6       := pos5 + longitudoValorum
          let (residuum, positioFinalis) ← legereParia b n pos6
          return ((nomenEntriae, tag, valor) :: residuum, positioFinalis)

-- ─────────────────────────────────────────────────────────────────────────
-- レクルスス補題と serializeMappam_roundtrip は LemmaStatusPermanens.lean にあるにゃ
-- ─────────────────────────────────────────────────────────────────────────

/-- `(名前, 型タグ, ByteArray)` の三つ組のリストをビーナーリウムにセリアーリザーティオーするにゃん（純粋）♪ -/
def serializeMappam (paria : List (String × String × ByteArray)) : ByteArray :=
  magicBytes ++ lebEncode paria.length ++ serializeParia paria

/-- ビーナーリウムから `(名前, 型タグ, ByteArray)` の三つ組を復元するにゃん（純粋）♪
    不正なオクテートゥス列の場合は `none` を返すにゃ -/
def deserializeMappam (b : ByteArray) : Option (List (String × String × ByteArray)) := do
  -- 最低5バイト必要にゃ（マーギクム4 + LEB128 最低1バイト）
  if b.size < 5 then failure
  if b.extract 0 4 != magicBytes then failure
  let (numerus, positio) ← lebDecode b 4
  let (paria, _)         ← legereParia b numerus positio
  return paria

/-- `ghost_status.bin` から `(名前, 型タグ, ByteArray)` の三つ組を讀み込むにゃん♪
    ファスキクルスが存在しにゃい・形式が不正にゃ場合は空リストを返すにゃ -/
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
    保存データに含まれる項目のうち **typusTag が一致するもの** だけを復元するにゃ♪
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
