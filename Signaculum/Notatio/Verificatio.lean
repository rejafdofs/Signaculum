-- Signaculum.Notatio.Verificatio
-- rfl 検證にゃん♪ scriptum! の出力が正しいか確かめるにゃ

import Signaculum.Notatio.Macro

namespace Signaculum.Notatio.Verificatio

open Signaculum.Sakura

-- 基本タグの出力検證にゃん
example : Id.run (currereScriptum (scriptum! \h)) = "\\h" := by native_decide

example : Id.run (currereScriptum (scriptum! \u)) = "\\u" := by native_decide

example : Id.run (currereScriptum (scriptum! \e)) = "\\e" := by native_decide

example : Id.run (currereScriptum (scriptum! \n)) = "\\n" := by native_decide

example : Id.run (currereScriptum (scriptum! \c)) = "\\c" := by native_decide

-- 複合タグの出力検證にゃん
example : Id.run (currereScriptum (scriptum! \h \s[0] "こんにちは" \e)) = "\\h\\s[0]こんにちは\\e" := by native_decide

-- 表面制御の検證にゃん
example : Id.run (currereScriptum (scriptum! \s[0])) = "\\s[0]" := by native_decide

example : Id.run (currereScriptum (scriptum! \s[-1])) = "\\s[-1]" := by native_decide

-- 待機の検證にゃん
example : Id.run (currereScriptum (scriptum! \w 5)) = "\\w5" := by native_decide

example : Id.run (currereScriptum (scriptum! \x)) = "\\x" := by native_decide

-- 吹出しの検證にゃん
example : Id.run (currereScriptum (scriptum! \b[0])) = "\\b[0]" := by native_decide

example : Id.run (currereScriptum (scriptum! \b[-1])) = "\\b[-1]" := by native_decide

-- 書體の検證にゃん
example : Id.run (currereScriptum (scriptum! \f[bold, true])) = "\\f[bold,true]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[default])) = "\\f[default]" := by native_decide

-- 式埋込の検證にゃん（SakuraM Unit）
example : Id.run (currereScriptum (scriptum! {Signaculum.Sakura.sakura})) = "\\h" := by native_decide

-- 式埋込の檢證にゃん（String 自動 loqui）
example : Id.run (currereScriptum (scriptum! {"こんにちは"})) = "こんにちは" := by native_decide

-- ════════════════════════════════════════════════════
--  colorisLiteral の検證にゃん
-- ════════════════════════════════════════════════════

-- RGB リテラル
example : Id.run (currereScriptum (scriptum! \f[color, 255,0,0]))
        = "\\f[color,255,0,0]" := by native_decide

-- 名前リテラル
example : Id.run (currereScriptum (scriptum! \f[color, red]))
        = "\\f[color,red]" := by native_decide

-- nullus リテラル
example : Id.run (currereScriptum (scriptum! \f[color, nullus]))
        = "\\f[color,none]" := by native_decide

-- 後方互換（Lean 式の括弧包み形式）
example : Id.run (currereScriptum (scriptum! \f[color, (.rgb 255 0 0)]))
        = "\\f[color,255,0,0]" := by native_decide

-- ════════════════════════════════════════════════════
--  directioAllineatioLiteral の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \f[align, left]))
        = "\\f[align,left]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[align, center]))
        = "\\f[align,center]" := by native_decide

-- ════════════════════════════════════════════════════
--  directioVerticalisLiteral の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \f[valign, top]))
        = "\\f[valign,top]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[valign, bottom]))
        = "\\f[valign,bottom]" := by native_decide

-- ════════════════════════════════════════════════════
--  行跨ぎ改行自動挿入の検證にゃん
-- ════════════════════════════════════════════════════

-- 條件1: 同一行不變性 — 單行なら \n は入らにゃいにゃん
example : Id.run (currereScriptum (scriptum! \h \s[0] "hello" \e)) = "\\h\\s[0]hello\\e" := by native_decide

-- 條件2: 行跨ぎ改行 — 異なる行の要素間に \n が插入されるにゃん
example : Id.run (currereScriptum (scriptum!
  \h \s[0]
  "hello"
  \e)) = "\\h\\s[0]\\nhello\\n\\e" := by native_decide

-- 條件3: 先頭不挿入 — 最初の要素の前には \n が入らにゃいにゃん
example : Id.run (currereScriptum (scriptum!
  \h
  \e)) = "\\h\\n\\e" := by native_decide

end Signaculum.Notatio.Verificatio
