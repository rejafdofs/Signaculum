-- Signaculum.Notatio.Verificatio
-- scriptum! マクロ固有の動作檢證にゃん♪
-- ランタイム函數の正しさは Sakura/Theoremata.lean の全稱證明で保證してるにゃ
-- 此處にはマクロ展開でしか檢證できにゃい性質だけ殘すにゃん

import Signaculum.Notatio.Macro

namespace Signaculum.Notatio.Verificatio

open Signaculum.Sakura Signaculum.Sakura.Textus Signaculum.Sakura.Systema

-- ════════════════════════════════════════════════════
--  式埋込の檢證にゃん（マクロの {expr} 構文にゃ）
-- ════════════════════════════════════════════════════

-- SakuraM Unit 式の埋込にゃん
example : Id.run (currereScriptum (scriptum! {Signaculum.Sakura.Textus.sakura})) = "\\h" := by native_decide

-- String 自動 loqui の埋込にゃん
example : Id.run (currereScriptum (scriptum! {"こんにちは"})) = "こんにちは" := by native_decide

-- ════════════════════════════════════════════════════
--  行跨ぎ改行自動挿入の檢證にゃん（マクロの行情報處理にゃ）
-- ════════════════════════════════════════════════════

-- 同一行不變性 — 單行なら \n は入らにゃいにゃん
example : Id.run (currereScriptum (scriptum! \h \s[0] "hello" \e)) = "\\h\\s[0]hello\\e" := by native_decide

-- 行跨ぎ改行 — 異なる行の要素間に \n が插入されるにゃん
example : Id.run (currereScriptum (scriptum!
  \h \s[0]
  "hello"
  \e)) = "\\h\\s[0]\\nhello\\n\\e" := by native_decide

-- 先頭不挿入 — 最初の要素の前には \n が入らにゃいにゃん
example : Id.run (currereScriptum (scriptum!
  \h
  \e)) = "\\h\\n\\e" := by native_decide

-- 複數行混在にゃん
example : Id.run (currereScriptum (scriptum!
  \h \s[0]
  \u \s[10]
  \e)) = "\\h\\s[0]\\n\\u\\s[10]\\n\\e" := by native_decide

-- 裸テクストゥスの後にタグが續く場合（rawTextusFn 後續空白消費にゃん）
example : Id.run (currereScriptum (scriptum!
  \h \s[0] こんにちは
  \u \s[10] よろしく \e)) = "\\h\\s[0]こんにちは\\n\\u\\s[10]よろしく\\e" := by native_decide

-- ════════════════════════════════════════════════════
--  舊形式スコープの檢證にゃん（マクロの糖衣構文にゃ）
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \0)) = "\\h" := by native_decide
example : Id.run (currereScriptum (scriptum! \1)) = "\\u" := by native_decide

-- ════════════════════════════════════════════════════
--  裸テクストゥス・シングルクォートの檢證にゃん（マクロのパーサ擧動にゃ）
-- ════════════════════════════════════════════════════

-- 裸の數値リテラルもテクストゥスとして表示にゃん
example : Id.run (currereScriptum (scriptum! \h \s[0] 844424930131960 \e)) = "\\h\\s[0]844424930131960\\e" := by native_decide

-- シングルクォートを含む裸テクストゥスが分斷されずに讀めるにゃん
example : Id.run (currereScriptum (scriptum! \h it's \e))
        = "\\hit's\\e" := by native_decide

-- ════════════════════════════════════════════════════
--  %property[...] の檢證にゃん（マクロのパーサ擧動にゃ）
-- ════════════════════════════════════════════════════

-- ドット記法にゃん
example : Id.run (currereScriptum (scriptum! %property[.systemAnnus])) =
  "%property[system.year]" := by native_decide

-- SakuraScript プロパティ名（abbrev 經由）にゃん
example : Id.run (currereScriptum (scriptum! %property[system.year])) =
  "%property[system.year]" := by native_decide

-- ghostlist.count にゃん
example : Id.run (currereScriptum (scriptum! %property[ghostlist.count])) =
  "%property[ghostlist.count]" := by native_decide

-- shiori ヘルパーにゃん
example : Id.run (currereScriptum (scriptum! %property[shiori "myvar"])) =
  "%property[shiori.myvar]" := by native_decide

-- 裸テクストゥスとの混在にゃん
example : Id.run (currereScriptum (scriptum! \h \s[0] 今は%property[system.year]年にゃ)) =
  "\\h\\s[0]今は%property[system.year]年にゃ" := by native_decide

-- 環境變數との共存にゃん
example : Id.run (currereScriptum (scriptum! %username %property[system.month])) =
  "%username%property[system.month]" := by native_decide

end Signaculum.Notatio.Verificatio
