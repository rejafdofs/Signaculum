-- Signaculum.Saori
-- SAORI（外部 DLL）呼出しにゃん♪
-- procurator32 經由で SAORI-universal DLL を呼び出すにゃ
-- SAORI-basic (.exe) は IO.Process で直接起動するにゃん

import Signaculum.Sakura.Fundamentum
import Signaculum.Protocollum.Typi
import Signaculum.Memoria.Auxilia

namespace Signaculum.Saori

open Signaculum.Protocollum
open Signaculum.Memoria (u32LE legeU32LE)

-- ═══════════════════════════════════════════════════
-- パイプ通信（procurator32 經由 SAORI-universal）にゃん
-- ═══════════════════════════════════════════════════

/-- SAORI DLL をロードするにゃん（procurator32 に 0x04 コマンドを送信）。
    via は SAORI DLL のパス（ghost ディレクトーリウムからの相對パスまたは絶對パス）にゃ。
    directorium は ghost のホームディレクトーリウムにゃん。
    成功なら true を返すにゃん -/
def onerareSaori (via : String) (directorium : String) : IO Bool := do
  -- パイプ通信は stdout に書いて stdin から應答を讀むにゃん
  -- procurator32 の tractare_saori_circulum が讀み取るにゃ
  let stdout ← IO.getStdout
  let stdin ← IO.getStdin
  let viaOcteti := via.toUTF8
  let hdirOcteti := directorium.toUTF8
  -- [0x04][pathLen:u32LE][path][hdirLen:u32LE][hdir]
  stdout.write ⟨#[0x04]⟩
  stdout.write (u32LE viaOcteti.size.toUInt32)
  stdout.write viaOcteti
  stdout.write (u32LE hdirOcteti.size.toUInt32)
  stdout.write hdirOcteti
  stdout.flush
  -- 應答: [0/1: u8]
  let resp ← stdin.read 1
  if h : resp.size > 0 then
    return resp[0]'h == 1
  else
    return false

/-- SAORI DLL に request を送信するにゃん（procurator32 に 0x05 コマンドを送信）。
    via は SAORI DLL のパス、argumenta は SAORI/1.0 の Argument 配列にゃ。
    Result と Value の配列を返すにゃん -/
def vocareSaori (via : String) (argumenta : Array String) : IO (Array String) := do
  -- SAORI/1.0 リクエストゥムを組み立てるにゃん
  let mut corpus := s!"EXECUTE SAORI/1.0{crlf}Charset: UTF-8{crlf}"
  for h : i in [:argumenta.size] do
    corpus := corpus ++ s!"Argument{i}: {argumenta[i]}{crlf}"
  corpus := corpus ++ crlf
  let stdout ← IO.getStdout
  let stdin ← IO.getStdin
  let viaOcteti := via.toUTF8
  let rogOcteti := corpus.toUTF8
  -- [0x05][pathLen:u32LE][path][reqLen:u32LE][req]
  stdout.write ⟨#[0x05]⟩
  stdout.write (u32LE viaOcteti.size.toUInt32)
  stdout.write viaOcteti
  stdout.write (u32LE rogOcteti.size.toUInt32)
  stdout.write rogOcteti
  stdout.flush
  -- 應答: [respLen:u32LE][resp]
  let lenOcteti ← stdin.read 4
  match legeU32LE lenOcteti 0 with
  | none => return #[]
  | some (respLongitudo, _) =>
    if respLongitudo == 0 then return #[]
    let resp ← stdin.read respLongitudo.toNat.toUSize
    -- SAORI/1.0 應答をパースして Value 配列を返すにゃん
    match String.fromUTF8? resp with
    | none => return #[]
    | some catenaResponsi => return parsaSaoriResponsum catenaResponsi
where
  /-- SAORI/1.0 應答文字列をパースして Result + Value の配列を返すにゃん。
      Result が最初の要素、Value0, Value1, ... が續くにゃ -/
  parsaSaoriResponsum (resp : String) : Array String :=
    let lineae := resp.splitOn "\r\n"
    -- まづ Result を探すにゃん
    let valores := lineae.foldl (fun acc linea =>
      if linea.startsWith "Result: " then acc.push (linea.drop 8 |>.toString) else acc) #[]
    -- 次に Value0, Value1, ... を順番に探すにゃん
    let rec colligeValores (i : Nat) (acc : Array String) (fuel : Nat) : Array String :=
      match fuel with
      | 0 => acc
      | fuel' + 1 =>
        let praefixum := s!"Value{i}: "
        match lineae.find? (·.startsWith praefixum) with
        | some linea => colligeValores (i + 1) (acc.push (linea.drop praefixum.length |>.toString)) fuel'
        | none => acc
    colligeValores 0 valores 128

/-- SAORI DLL をアンロードするにゃん（procurator32 に 0x06 コマンドを送信）-/
def exonerareSaori (via : String) : IO Unit := do
  let stdout ← IO.getStdout
  let viaOcteti := via.toUTF8
  -- [0x06][pathLen:u32LE][path]
  stdout.write ⟨#[0x06]⟩
  stdout.write (u32LE viaOcteti.size.toUInt32)
  stdout.write viaOcteti
  stdout.flush

-- ═══════════════════════════════════════════════════
-- SAORI-basic (.exe) — IO.Process 經由にゃん
-- ═══════════════════════════════════════════════════

/-- SAORI-basic (.exe) を起動して結果を得るにゃん。
    IO.Process で外部プロセスを起動し stdin/stdout で通信するにゃ -/
def vocareSaoriBasic (exeVia : String) (argumenta : Array String) : IO (Option String) := do
  try
    let output ← IO.Process.output {
      cmd := exeVia
      args := argumenta
    }
    if output.exitCode == 0 then
      return some output.stdout
    else
      return none
  catch _ =>
    return none

-- ═══════════════════════════════════════════════════
-- SakuraIO ラッパーにゃん
-- ═══════════════════════════════════════════════════

open Signaculum.Sakura in
/-- SakuraIO 內から SAORI-universal を呼び出すにゃん -/
def vocareSaoriM (via : String) (argumenta : Array String) : SakuraIO (Array String) :=
  liftM (vocareSaori via argumenta)

end Signaculum.Saori
