-- Signaculum.Nucleus.Circulus
-- ゴースト本體（ghost.exe）として標準入出力で中繼器と通信する小循環（loop）にゃん。

import Signaculum.Nucleus.Exporta
import Signaculum.Protocollum.Responsum
import Signaculum.Memoria.Auxilia

namespace Signaculum.Nucleus
open Signaculum.Protocollum

-- ═══════════════════════════════════════════════════
-- I/O 通信構造體にゃん
-- ═══════════════════════════════════════════════════

/-- 標準入出力のストリームスをまとめた通信構造體にゃん -/
structure Communicatio where
  rivusIngressus : IO.FS.Stream
  rivusEgressus  : IO.FS.Stream

/-- リトルエンディアン 4バイトを發信するにゃん。Memoria.u32LE を使ふにゃ -/
def Communicatio.scribeU32 (c : Communicatio) (numerus : UInt32) : IO Unit :=
  c.rivusEgressus.write (Memoria.u32LE numerus)

/-- リトルエンディアン 4バイトを讀信するにゃん。Memoria.legeU32LE を使ふにゃ -/
def Communicatio.legeU32 (c : Communicatio) : IO (Option UInt32) := do
  let o ← c.rivusIngressus.read 4
  match Memoria.legeU32LE o 0 with
  | some (v, _) => return some v
  | none        => return none

/-- 指定されたバイト數を完全に讀み切る遞歸關數にゃん。
    EOF の場合は讀めた分だけ返すにゃ -/
partial def Communicatio.legeExactus (c : Communicatio) (magnitudo : Nat)
    (accumulatum : ByteArray := ByteArray.empty) : IO ByteArray := do
  if accumulatum.size >= magnitudo then
    return accumulatum
  let reliquum := magnitudo - accumulatum.size
  let o ← c.rivusIngressus.read reliquum.toUSize
  if o.size == 0 then
    -- EOF か讀取エラーにゃ
    return accumulatum
  c.legeExactus magnitudo (accumulatum ++ o)

/-- バイト列をレスポンスムとして送信するにゃん（長さプレーフィクスム + 本體 + flush）-/
def Communicatio.scribeResponsum (c : Communicatio) (octeti : ByteArray) : IO Unit := do
  c.scribeU32 octeti.size.toUInt32
  c.rivusEgressus.write octeti
  c.rivusEgressus.flush

-- ═══════════════════════════════════════════════════
-- コマンド處理關數にゃん
-- ═══════════════════════════════════════════════════

/-- LOAD 命令を處理するにゃん: [1u8] [4bytes:len] [bytes:path] -> [1u8] を返すにゃ -/
private partial def tractaOnerare (c : Communicatio) : IO Unit := do
  match ← c.legeU32 with
  | none =>
    registrareVestigium "[PERNICIES] LOAD: longitudo を讀めなかつたにゃ"
  | some longitudoViae =>
    if longitudoViae == 0 then
      registrareVestigium "[PERNICIES] longitudoViae est 0"
      c.rivusEgressus.write ⟨#[0]⟩
      c.rivusEgressus.flush
    else
      let octetiViae ← c.legeExactus longitudoViae.toNat
      match String.fromUTF8? octetiViae with
      | none =>
        registrareVestigium "[PERNICIES] LOAD: via non est UTF-8 validus"
        c.rivusEgressus.write ⟨#[0]⟩
        c.rivusEgressus.flush
      | some catenaViae =>
        registrareVestigium s!"[LOAD] via={catenaViae}, len={longitudoViae}"
        let resSecunda ← exportaLoad catenaViae
        c.rivusEgressus.write ⟨#[resSecunda.toUInt8]⟩
        c.rivusEgressus.flush

/-- UNLOAD 命令を處理するにゃん: [2u8] -> 終了 -/
private def tractaExonerare : IO Unit := do
  registrareVestigium "[UNLOAD] vocatus"
  let _ ← exportaUnload
  registrareVestigium "[UNLOAD] perfectus"

/-- REQUEST 命令を處理するにゃん: [3u8] [4bytes:len] [bytes:req] -> [4bytes:len] [bytes:res] を返すにゃ -/
private partial def tractaRogationem (c : Communicatio) : IO Unit := do
  match ← c.legeU32 with
  | none =>
    registrareVestigium "[PERNICIES] REQUEST: longitudo を讀めなかつたにゃ"
  | some longitudoRogationis =>
    if longitudoRogationis == 0 then
      registrareVestigium "[PERNICIES] longitudoRogationis est 0"
      c.scribeResponsum (Responsum.malaRogatio.adProtocollum.toUTF8)
    else
      registrareVestigium s!"[REQUEST] longitudoRogationis={longitudoRogationis}"
      let octetiRogationis ← c.legeExactus longitudoRogationis.toNat
      if octetiRogationis.size.toUInt32 < longitudoRogationis then
        registrareVestigium s!"[PERNICIES] parum lectum! expectatum {longitudoRogationis}, obtentum {octetiRogationis.size}"
      match String.fromUTF8? octetiRogationis with
      | none =>
        registrareVestigium "[PERNICIES] REQUEST: rogatio non est UTF-8 valida"
        c.scribeResponsum (Responsum.malaRogatio.adProtocollum.toUTF8)
      | some catenaRogationis =>
        let catenaResponsi ← exportaRequest catenaRogationis
        let octetiResponsi := catenaResponsi.toUTF8
        registrareVestigium s!"[REQUEST] PERFECTUM, magnitudoResponsi={octetiResponsi.size}"
        c.scribeResponsum octetiResponsi

-- ═══════════════════════════════════════════════════
-- メインループにゃん
-- ═══════════════════════════════════════════════════

/-- 要求を讀取つて應答を返す中繼循環（loop）にゃん。
    Rust 側の procurator32_host.exe の代はりを完全に機能させるにゃ！
    - コマンド 1: LOAD (路徑讀取＋初期化後 [1] を返す)
    - コマンド 2: UNLOAD (終了處理後ループ拔ける。Rust 側は應答を待たずパイプを閉ぢるにゃ)
    - コマンド 3: REQUEST (要求讀取＋長さと應答を返す) -/
@[export uka_lean_loop_principalis]
partial def loopPrincipalis : IO Unit := do
  let c : Communicatio := {
    rivusIngressus := ← IO.getStdin
    rivusEgressus  := ← IO.getStdout
  }
  -- コマンドを表す1バイトを讀むにゃん
  let mandatum ← c.rivusIngressus.read 1
  if h : 1 ≤ mandatum.size then
    match mandatum[0]'(by omega) with
    | 1 => tractaOnerare c;  loopPrincipalis
    | 2 => tractaExonerare
    | 3 => tractaRogationem c; loopPrincipalis
    | m =>
      registrareVestigium s!"[IGNOTUM] mandatum: {m}"
      loopPrincipalis
  else
    return () -- EOF にゃ

end Signaculum.Nucleus
