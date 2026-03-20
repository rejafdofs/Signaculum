-- Signaculum.Sstp
-- SSTP/1.4 ヴィアー TCP (port 9801) で SSP にスクリプトゥムをミッテレするにゃん
-- Pure Lean 實裝（C コード不要にゃ）

import Std.Internal.UV.TCP
import Std.Net

namespace Signaculum.Sstp

open Std.Net
open Std.Internal.UV.TCP

/-- SSTP 標準ポートゥスにゃん -/
def sstpPortus : UInt16 := 9801

/-- SSTP リクエストゥムを TCP で SSP に送信するにゃん。
    接續失敗時は靜かに無視するにゃ（Direct SSTP と同じ振舞ひにゃ） -/
def sstpDirectumMittere (request : String) : IO Unit := do
  try
    let sock ← Socket.new
    let addr : SocketAddress := .v4 ⟨.ofParts 127 0 0 1, sstpPortus⟩
    let connectPromise ← sock.connect addr
    IO.ofExcept connectPromise.result!.get
    let sendPromise ← sock.send #[request.toUTF8]
    IO.ofExcept sendPromise.result!.get
    let shutdownPromise ← sock.shutdown
    IO.ofExcept shutdownPromise.result!.get
  catch _ =>
    pure ()  -- SSP 未起動 or 接續拒否: 靜かに無視にゃ

/-- ヘッダー値から CR・LF を除去して SSTP パケットゥムの破損を防ぐにゃん -/
private def purgaCrlf (s : String) : String :=
  s.foldl (fun acc c => if c != '\r' && c != '\n' then acc.push c else acc) ""

/-- SakuraScript を SSTP/1.4 Execute で SSP に送信するにゃん -/
def mitteSstpScriptum (scriptum : String) : IO Unit :=
  let req := s!"EXECUTE SSTP/1.4\r\nCharset: UTF-8\r\nSender: uka-lean\r\nScript: {purgaCrlf scriptum}\r\n\r\n"
  sstpDirectumMittere req

/-- SHIORI イヴェントゥムを SSTP/1.4 Notify で SSP に送信するにゃん -/
def excitaEventum (nomenEventi : String) (citationes : List String := []) : IO Unit :=
  let refs := citationes.mapIdx fun i v =>
    s!"Reference{i}: {purgaCrlf v}\r\n"
  let req := "NOTIFY SSTP/1.4\r\nCharset: UTF-8\r\nSender: uka-lean\r\nEvent: "
      ++ purgaCrlf nomenEventi ++ "\r\n" ++ String.join refs ++ "\r\n"
  sstpDirectumMittere req

end Signaculum.Sstp
