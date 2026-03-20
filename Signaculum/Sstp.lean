-- Signaculum.Sstp
-- ディレクトゥム SSTP — WM_COPYDATA ヴィアー SSP にスクリプトゥムをミッテレするにゃん
-- ソケットゥムを使はずにウィンドウズ IPC を使ふにゃん

namespace Signaculum.Sstp

/-- FFI — sstpDirectum.c の sstp_directum_mittere を呼ぶにゃん -/
@[extern "sstp_directum_mittere"]
opaque sstpDirectumMittere (request : @& String) : IO Unit

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
