-- Signaculum.Sakura.Status
-- サクラスクリプト構築モナドの狀態型にゃん♪
-- Signum 型を使ふので Typi と Signum の両方をインポルトするにゃ

import Signaculum.Sakura.Typi
import Signaculum.Sakura.Signum

namespace Signaculum.Sakura

/-- サクラスクリプト構築モナドの狀態にゃん。
    スクリプトゥムをシグヌムのリストゥスとして蓄積するにゃ。
    SHIORI/3.0 レスポンスムの附加ヘッダーも一緖に保持するにゃん♪ -/
structure StatusSakurae where
  /-- 蓄積中のサクラスクリプトゥム（構造化シグヌムのリストゥスにゃ） -/
  scriptum         : List Signum := []
  /-- Marker ヘッダー: バルーン下部の附加情報文字列にゃ -/
  marker           : Option String := none
  /-- BalloonOffset ヘッダー: バルーン位置の補正 (X, Y) にゃ -/
  balloonOffset    : Option (Int × Int) := none
  /-- ErrorLevel ヘッダーにゃ -/
  errorLevel       : Option GradusErroris := none
  /-- ErrorDescription ヘッダー: エラーの詳細にゃ -/
  errorDescription : Option String := none
  /-- MarkerSend ヘッダー: SSTP 送信先へのマーカーにゃ -/
  markerSend       : Option String := none
  /-- ValueNotify ヘッダー: NOTIFY でもスクリプトゥムを實行するにゃ -/
  valorNotifica    : Option String := none
  /-- Age ヘッダー: 通信世代カウンタにゃ -/
  age              : Option Nat := none
  /-- SecurityLevel ヘッダー: "local"|"external" にゃ -/
  securitas        : Option String := none
  /-- 其の他の任意ヘッダー（X-SSTP-PassThru-* 等）にゃ -/
  cappitta         : List (String × String) := []
  deriving Repr, Inhabited

/-- サクラスクリプト構築モナドにゃん。
    StatusSakurae を蓄積する StateT で、基底モナド m を自由に選べるにゃ。
    純粹な構築には `SakuraPura`、IO が要る時は `SakuraIO` を使ふにゃん -/
abbrev SakuraM (m : Type → Type) [Monad m] (α : Type) :=
  StateT StatusSakurae m α

/-- IO 附きサクラスクリプト・モナドにゃん。お嬢樣の處理器はこれを使ふにゃ -/
abbrev SakuraIO (α : Type) := SakuraM IO α

/-- 純粹サクラスクリプト・モナドにゃん。副作用が要らにゃい時に使ふにゃ -/
abbrev SakuraPura (α : Type) := SakuraM Id α

end Signaculum.Sakura
