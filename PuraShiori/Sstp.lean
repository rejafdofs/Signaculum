-- PuraShiori.Sstp
-- ディレクトゥム SSTP — WM_COPYDATA ヴィアー SSP ニ スクリプトゥムヲ ミッテレ スルニャン
-- ソケットゥムヲ ツカハズニ ウィンドウズ IPC ヲ ツカフニャン

namespace PuraShiori.Sstp

/-- FFI — sstpDirectum.c ノ sstp_directum_mittere ヲ ヨブニャン -/
@[extern "sstp_directum_mittere"]
opaque sstpDirectumMittere (request : @& String) : IO Unit

/-- SakuraScript ヲ SSTP/1.4 Execute デ SSP ニ ソウシン スルニャン -/
def mitteSstpScriptum (scriptum : String) : IO Unit :=
  let req := s!"SSTP/1.4\r\nCommand: Execute\r\nCharset: UTF-8\r\nSender: uka-lean\r\nScript: {scriptum}\r\n\r\n"
  sstpDirectumMittere req

/-- SHIORI イヴェントゥムヲ SSTP/1.4 Notify デ SSP ニ ソウシン スルニャン -/
def excitaEventum (nomenEventi : String) (citationes : List String := []) : IO Unit :=
  let refs := citationes.mapIdx fun i v =>
    s!"Reference{i}: {v}\r\n"
  let req := "SSTP/1.4\r\nCommand: Notify\r\nCharset: UTF-8\r\nSender: uka-lean\r\nEvent: "
      ++ nomenEventi ++ "\r\n" ++ String.join refs ++ "\r\n"
  sstpDirectumMittere req

end PuraShiori.Sstp
