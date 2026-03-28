-- Signaculum.Sakura.Signum.Morae
-- 待機シグヌムにゃん♪ テンポを制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura.Signum

/-- 待機・タイミングのシグヌムにゃん。\_w / \w / \x 等に對應するにゃ -/
inductive SignumMorae where
  | mora (ms : Nat)                                        -- \_w[ms]（ミリ秒待機にゃ）
  | moraCeler (n : Nat) (h : 1 ≤ n ∧ n ≤ 9 := by omega)   -- \w{n}（簡易待機にゃ）
  | moraAbsoluta (ms : Nat)                                -- \__w[ms]（絕對時間待機にゃ）
  | moraAnimationem (animId : Nat)                         -- \__w[animation,id]（アニマーティオ待機にゃ）
  | reseraTimerSynchrinae                                  -- \__w[clear]（タイマー同期解除にゃ）
  | expecta                                                -- \x（打鍵待ちにゃ）
  | expectaSine                                            -- \x[noclear]（打鍵待ち・淸掃なしにゃ）
  deriving Repr

def SignumMorae.adCatenam : SignumMorae → String
  | .mora ms              => s!"\\_w[{ms}]"
  | .moraCeler n ..       => s!"\\w{n}"
  | .moraAbsoluta ms      => s!"\\__w[{ms}]"
  | .moraAnimationem id   => s!"\\__w[animation,{id}]"
  | .reseraTimerSynchrinae => "\\__w[clear]"
  | .expecta              => "\\x"
  | .expectaSine          => "\\x[noclear]"

end Signaculum.Sakura.Signum
