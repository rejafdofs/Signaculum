-- Signaculum.Protocollum.Responsum
-- SHIORI/3.0 應答の構築にゃん

import Signaculum.Protocollum.Typi
import Signaculum.Sakura.Typi

namespace Signaculum

/-- SHIORI/3.0 應答を表す構造體にゃん。
    Value 以外のレスポンスムヘッダーも型安全に設定できるにゃ♪ -/
structure Responsum where
  /-- 狀態符號 -/
  status           : StatusCodis
  /-- Value 頭部（SakuraScript）にゃん。pete の應答に入れるにゃ -/
  valor            : Option String := none
  /-- Sender 頭部: SHIORI 名を返すにゃ -/
  sender           : Option String := none
  /-- ErrorLevel 頭部にゃ -/
  errorLevel       : Option Sakura.GradusErroris := none
  /-- ErrorDescription 頭部: エラーの詳細にゃ -/
  errorDescription : Option String := none
  /-- Marker 頭部: バルーン下部の附加情報文字列にゃ -/
  marker           : Option String := none
  /-- BalloonOffset 頭部: バルーン位置の補正 (X, Y) にゃ -/
  balloonOffset    : Option (Int × Int) := none
  /-- Age 頭部: 通信世代カウンタにゃ -/
  age              : Option Nat := none
  /-- SecurityLevel 頭部: "local"|"external" にゃ -/
  securitas        : Option String := none
  /-- MarkerSend 頭部: SSTP 送信先へのマーカーにゃ -/
  markerSend       : Option String := none
  /-- ValueNotify 頭部: NOTIFY でもスクリプトゥムを實行するにゃ -/
  valorNotifica    : Option String := none
  /-- 其の他の任意頭部（X-SSTP-PassThru-* 等）にゃん -/
  cappitta         : List (String × String) := []
  deriving Repr

namespace Responsum

/-- 成功應答（200 OK）を作るにゃん。SakuraScript を Value に入れるにゃ -/
def ok (scriptum : String) : Responsum :=
  { status := .ok, valor := some scriptum }

/-- 內容にゃし應答（204 No Content）にゃん。處理器が見つからにゃい時とかに使ふにゃ -/
def nihil : Responsum :=
  { status := .inanis }

/-- 不正要求應答（400 Bad Request）にゃん -/
def malaRogatio : Responsum :=
  { status := .malaRogatio }

/-- 內部異常應答（500 Internal Server Error）にゃん -/
def errorInternus : Responsum :=
  { status := .errorInternus }

/-- SHIORI/3.0 プロトコッルム文字列に整形するにゃん。
    これが實際に SSP に返される文字列にゃ -/
def adProtocollum (r : Responsum) : String :=
  let lineaStatus := r.status.lineaStatus ++ crlf
  let forma       := "Charset: UTF-8" ++ crlf
  -- 全ヘッダー値に purgaCrlf を適用して CR/LF 混入によるパケットゥム破損を防ぐにゃん
  let senderStr   := match r.sender with
    | some s => s!"Sender: {purgaCrlf s}" ++ crlf | none => ""
  let valorStr    := match r.valor with
    | some v => s!"Value: {purgaCrlf v}" ++ crlf | none => ""
  let errorLvl    := match r.errorLevel with
    | some l => s!"ErrorLevel: {l.adCatenam}" ++ crlf | none => ""
  let errorDesc   := match r.errorDescription with
    | some d => s!"ErrorDescription: {purgaCrlf d}" ++ crlf | none => ""
  let markerStr   := match r.marker with
    | some m => s!"Marker: {purgaCrlf m}" ++ crlf | none => ""
  let offsetStr   := match r.balloonOffset with
    | some (x, y) => s!"BalloonOffset: {x},{y}" ++ crlf | none => ""
  let ageStr      := match r.age with
    | some a => s!"Age: {a}" ++ crlf | none => ""
  let secStr      := match r.securitas with
    | some s => s!"SecurityLevel: {purgaCrlf s}" ++ crlf | none => ""
  let mSendStr    := match r.markerSend with
    | some m => s!"MarkerSend: {purgaCrlf m}" ++ crlf | none => ""
  let vNotifStr   := match r.valorNotifica with
    | some v => s!"ValueNotify: {purgaCrlf v}" ++ crlf | none => ""
  let extra := r.cappitta.foldl
    (fun acc (k, v) => acc ++ s!"{purgaCrlf k}: {purgaCrlf v}" ++ crlf) ""
  lineaStatus ++ forma ++ senderStr ++ valorStr
    ++ errorLvl ++ errorDesc ++ markerStr ++ offsetStr
    ++ ageStr ++ secStr ++ mSendStr ++ vNotifStr
    ++ extra ++ crlf

end Responsum

end Signaculum
