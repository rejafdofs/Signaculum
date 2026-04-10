-- Signaculum.Utilia.Registrum
-- エラー通知・ログ機能にゃん♪
-- YAYA の LOGGING 相當 + ライブラリ内部エラーの可視化にゃ
-- ghost_log.txt にタイムスタンプ附きでメッセージを記錄するにゃん

import Signaculum.Utilia.Tempus
import Signaculum.Sakura.Status
import Signaculum.Sakura.Typi

namespace Signaculum.Utilia

open Signaculum.Sakura
open Std.Time

-- ═══════════════════════════════════════════════════
-- ログ等級 (Gradus Registri) にゃん
-- ═══════════════════════════════════════════════════

/-- ログの等級にゃん。SSP の ErrorLevel とも對應するにゃ -/
inductive GradusRegistri where
  /-- 情報にゃ（通常のデバッグメッセージにゃん）-/
  | indicium
  /-- 警告にゃ（問題があるけど動くにゃん）-/
  | monitum
  /-- エラーにゃ（深刻な問題にゃん）-/
  | error
  deriving Repr, DecidableEq, Inhabited

/-- 等級を文字列に變換するにゃん -/
def GradusRegistri.adTextum : GradusRegistri → String
  | .indicium => "INFO"
  | .monitum  => "WARN"
  | .error    => "ERROR"

-- ═══════════════════════════════════════════════════
-- グローバル狀態 (Status Globalis) にゃん
-- ═══════════════════════════════════════════════════

/-- ログ出力の有效/無效にゃん。SSP の enable_log 通知と連動するにゃ -/
initialize registrumActivum : IO.Ref Bool ← IO.mkRef true

/-- ゴーストの家ディレクトーリウムにゃん。exportaLoad で設定されるにゃ -/
initialize domusRegistri : IO.Ref String ← IO.mkRef ""

/-- ログ出力を有效にするにゃん -/
def activaRegistrum : IO Unit := registrumActivum.set true

/-- ログ出力を無效にするにゃん -/
def inactivaRegistrum : IO Unit := registrumActivum.set false

/-- ログの家ディレクトーリウムを設定するにゃん（exportaLoad から呼ばれるにゃ）-/
def statuereDomusRegistri (domus : String) : IO Unit := domusRegistri.set domus

-- ═══════════════════════════════════════════════════
-- ログ出力 (Registratio) にゃん
-- ═══════════════════════════════════════════════════

/-- ログファイルのパスを取得するにゃん -/
private def viaRegistri : IO String := do
  let domus ← domusRegistri.get
  if domus.isEmpty then return "ghost_log.txt"
  else return (domus ++ "/ghost_log.txt")

/-- ログにメッセージを書き込むにゃん♪
    `[2026-04-10 12:34:56] [INFO] メッセージ` 形式にゃ -/
def registra (gradus : GradusRegistri) (nuntius : String) : IO Unit := do
  let activum ← registrumActivum.get
  unless activum do return
  let dt ← obtineTempus
  let linea := s!"[{tempusAdTextum dt}] [{gradus.adTextum}] {nuntius}\n"
  let via ← viaRegistri
  try
    let h ← IO.FS.Handle.mk via .append
    h.putStr linea
  catch _ =>
    -- ログファイルへの書き込み自體が失敗した場合は靜かに無視するにゃ
    -- （ファイルシステムの問題でゴーストを止めたくにゃいにゃん）
    pure ()

/-- 情報ログにゃん -/
def registraIndicium (nuntius : String) : IO Unit :=
  registra .indicium nuntius

/-- 警告ログにゃん -/
def registraMonitum (nuntius : String) : IO Unit :=
  registra .monitum nuntius

/-- エラーログにゃん -/
def registraErrorem (nuntius : String) : IO Unit :=
  registra .error nuntius

-- ═══════════════════════════════════════════════════
-- SakuraM 版 (Versio Monadica) にゃん
-- ═══════════════════════════════════════════════════

/-- SakuraIO コンテクスト内でログを書くにゃん -/
def registraM (gradus : GradusRegistri) (nuntius : String) : SakuraIO Unit :=
  liftM (show IO Unit from registra gradus nuntius)

/-- SakuraIO コンテクスト内でログ + SSP ErrorLevel/ErrorDescription に設定するにゃん♪
    SHIORI 應答にエラー情報が含まれ、SSP もログに記錄するにゃ -/
def registraEtNotifica (gradus : GradusRegistri) (nuntius : String) : SakuraIO Unit := do
  -- 1. ファイルログに書き込むにゃん
  liftM (show IO Unit from registra gradus nuntius)
  -- 2. StatusSakurae の errorLevel / errorDescription に設定するにゃん
  let sakuraGradus := match gradus with
    | .indicium => GradusErroris.informatio
    | .monitum  => GradusErroris.admonitio
    | .error    => GradusErroris.error
  modify fun st => { st with
    errorLevel := some sakuraGradus
    errorDescription := some nuntius }

end Signaculum.Utilia
