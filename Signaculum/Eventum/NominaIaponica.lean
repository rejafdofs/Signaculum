-- Signaculum.Eventum.NominaIaponica
-- イヴェントゥム名の日本語エイリアスにゃん♪
-- 里々のやうに日本語名でイヴェントゥムを書けるにゃ

namespace Signaculum.Eventum

/-- SHIORI イヴェントゥム名の日本語→英語マッピングテーブルにゃん♪
    里々の「＊起動」→「OnBoot」のやうな變換をコンパイル時に行ふにゃ -/
def tabulaEventorum : List (String × String) :=
  [ -- 起動・終了にゃん
    ("初回起動",       "OnFirstBoot"),
    ("起動",           "OnBoot"),
    ("終了",           "OnClose"),
    ("全終了",         "OnCloseAll"),
    -- ゴースト切替にゃん
    ("切り替わり",     "OnGhostChanged"),
    ("切り替わる",     "OnGhostChanging"),
    ("呼ばれた",       "OnGhostCalled"),
    ("呼ぶ",           "OnGhostCalling"),
    ("他起動",         "OnOtherGhostBooted"),
    ("他終了",         "OnOtherGhostClosed"),
    ("消滅から",       "OnVanished"),
    -- マウスにゃん
    ("クリック",       "OnMouseClick"),
    ("ダブルクリック", "OnMouseDoubleClick"),
    ("マウス移動",     "OnMouseMove"),
    ("ホイール",       "OnMouseWheel"),
    ("マウスホバー",   "OnMouseHover"),
    ("マウスジェスチャー", "OnMouseGesture"),
    -- 時間にゃん
    ("毎秒",           "OnSecondChange"),
    ("毎分",           "OnMinuteChange"),
    ("毎時",           "OnHourTimeSignal"),
    -- トークにゃん
    ("ランダムトーク", "OnAITalk"),
    -- 選択肢にゃん
    ("選択肢選択",     "OnChoiceSelect"),
    ("アンカー選択",   "OnAnchorSelect"),
    ("選択肢タイムアウト", "OnChoiceTimeout"),
    -- 通信にゃん
    ("コミュニケート", "OnCommunicate"),
    -- 入力にゃん
    ("入力",           "OnUserInput"),
    ("入力キャンセル", "OnUserInputCancel"),
    ("教えて",         "OnTeach"),
    -- シェル・表示にゃん
    ("シェル変更",     "OnShellChanged"),
    ("着せ替え変更",   "OnDressupChanged"),
    ("サーフェス変更", "OnSurfaceChange"),
    ("バルーン変更",   "OnBalloonChange"),
    -- バルーンにゃん
    ("バルーン閉じ",   "OnBalloonClose"),
    ("バルーンタイムアウト", "OnBalloonTimeout"),
    ("バルーン中断",   "OnBalloonBreak"),
    -- ファイルドロップにゃん
    ("ファイルドロップ", "OnFileDropped"),
    ("ファイルドロップ中", "OnFileDropping"),
    -- ネットワーク更新にゃん
    ("更新完了",       "OnUpdateComplete"),
    ("更新失敗",       "OnUpdateFailure"),
    ("HTTP完了",       "OnExecuteHTTPComplete"),
    ("HTTP失敗",       "OnExecuteHTTPFailure"),
    -- OS狀態にゃん
    ("スクリーンセーバー開始", "OnScreenSaverStart"),
    ("スクリーンセーバー終了", "OnScreenSaverEnd"),
    ("セッションロック", "OnSessionLock"),
    ("セッションアンロック", "OnSessionUnlock"),
    ("ダークテーマ",   "OnDarkTheme"),
    ("バッテリー低",   "OnBatteryLow"),
    ("バッテリー危機", "OnBatteryCritical"),
    -- 消滅にゃん
    ("消滅選択中",     "OnVanishSelecting"),
    ("消滅選択",       "OnVanishSelected"),
    ("消滅キャンセル", "OnVanishCancel"),
    -- キーにゃん
    ("キー入力",       "OnKeyPress"),
    -- 音聲にゃん
    ("音声認識",       "OnVoiceRecognitionWord"),
    ("音声合成",       "OnSpeechSynthesisStatus"),
    -- インストールにゃん
    ("インストール完了", "OnInstallComplete"),
    ("インストール失敗", "OnInstallFailure")
  ]

/-- 日本語イヴェントゥム名を SHIORI/3.0 イヴェントゥム名に變換するにゃん♪
    テーブルに無い名前はそのまま返すにゃ（カスタムイヴェントゥム名として使へるにゃん）-/
def resolveNomenEventi (nomen : String) : String :=
  match tabulaEventorum.lookup nomen with
  | some shioriNomen => shioriNomen
  | none => nomen

end Signaculum.Eventum
