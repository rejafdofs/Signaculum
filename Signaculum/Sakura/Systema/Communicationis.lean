-- Signaculum.Sakura.Systema.Communicationis
-- ゴースト間通信（コムニカーティオー）にゃん♪
-- SSTP COMMUNICATE で他ゴーストにスクリプトゥムやテクストゥムを送信するにゃ

import Signaculum.Sakura.Fundamentum
import Signaculum.Sstp

namespace Signaculum.Sakura.Systema

/-- 他ゴーストにスクリプトゥムを非同期送信するにゃん（SSTP SEND 經由）。
    ghostNomen にゴースト名、scriptum に SakuraScript を指定するにゃ -/
def communicaScriptum (ghostNomen scriptum : String) (mittens : String := Signaculum.Sstp.mittensDefectus) : SakuraIO Unit :=
  liftM (show IO Unit from Signaculum.Sstp.communicaSstpScriptum ghostNomen scriptum mittens)

/-- 他ゴーストにテクストゥムを非同期送信するにゃん（SSTP SEND 經由）。
    ghostNomen にゴースト名、sentence にテクストゥムを指定するにゃ -/
def communicaSentence (ghostNomen sentence : String) (mittens : String := Signaculum.Sstp.mittensDefectus) : SakuraIO Unit :=
  liftM (show IO Unit from Signaculum.Sstp.communicaSstpSentence ghostNomen sentence mittens)

end Signaculum.Sakura.Systema
