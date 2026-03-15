-- PuraShiori.Sstp
-- SSTP/1.4 クラエンス（SstpCliens ラッパー）にゃん
-- バックグラウンドタスクから SSP にスクリプトやイヴェントゥムを送信するにゃ

import SstpCliens

namespace PuraShiori.Sstp

/-- SakuraScript を SSTP/1.4 Execute で SSP（127.0.0.1:9801）に送信するにゃん -/
def mitteSstpScriptum (scriptum : String) : IO Unit :=
  SstpCliens.mitteSstpScriptum scriptum

/-- SHIORI イヴェントゥムを SSTP/1.4 Notify で SSP に送信するにゃん -/
def excitaEventum (nomenEventi : String) (citationes : List String := []) : IO Unit :=
  SstpCliens.notificaEventum nomenEventi citationes.toArray

end PuraShiori.Sstp
