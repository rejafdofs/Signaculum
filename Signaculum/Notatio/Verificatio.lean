-- Signaculum.Notatio.Verificatio
-- rfl 検證にゃん♪ scriptum! の出力が正しいか確かめるにゃ

import Signaculum.Notatio.Macro

namespace Signaculum.Notatio.Verificatio

open Signaculum.Sakura

-- 基本タグの出力検證にゃん
example : Id.run (currere (scriptum! \h)) = "\\h" := by native_decide

example : Id.run (currere (scriptum! \u)) = "\\u" := by native_decide

example : Id.run (currere (scriptum! \e)) = "\\e" := by native_decide

example : Id.run (currere (scriptum! \n)) = "\\n" := by native_decide

example : Id.run (currere (scriptum! \c)) = "\\c" := by native_decide

-- 複合タグの出力検證にゃん
example : Id.run (currere (scriptum! \h \s[0] "こんにちは" \e)) = "\\h\\s[0]こんにちは\\e" := by native_decide

-- 表面制御の検證にゃん
example : Id.run (currere (scriptum! \s[0])) = "\\s[0]" := by native_decide

example : Id.run (currere (scriptum! \s[-1])) = "\\s[-1]" := by native_decide

-- 待機の検證にゃん
example : Id.run (currere (scriptum! \w 5)) = "\\w5" := by native_decide

example : Id.run (currere (scriptum! \x)) = "\\x" := by native_decide

-- 吹出しの検證にゃん
example : Id.run (currere (scriptum! \b[0])) = "\\b[0]" := by native_decide

example : Id.run (currere (scriptum! \b[-1])) = "\\b[-1]" := by native_decide

-- 書體の検證にゃん
example : Id.run (currere (scriptum! \f[bold, true])) = "\\f[bold,true]" := by native_decide

example : Id.run (currere (scriptum! \f[default])) = "\\f[default]" := by native_decide

-- 式埋込の検證にゃん
example : Id.run (currere (scriptum! (Signaculum.Sakura.sakura))) = "\\h" := by native_decide

-- ════════════════════════════════════════════════════
--  colorisLiteral の検證にゃん
-- ════════════════════════════════════════════════════

-- RGB リテラル
example : Id.run (currere (scriptum! \f[color, 255,0,0]))
        = "\\f[color,255,0,0]" := by native_decide

-- 名前リテラル
example : Id.run (currere (scriptum! \f[color, red]))
        = "\\f[color,red]" := by native_decide

-- none リテラル
example : Id.run (currere (scriptum! \f[color, none]))
        = "\\f[color,none]" := by native_decide

-- 後方互換（Lean 式の括弧包み形式）
example : Id.run (currere (scriptum! \f[color, (.rgb 255 0 0)]))
        = "\\f[color,255,0,0]" := by native_decide

-- ════════════════════════════════════════════════════
--  directioAllineatioLiteral の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currere (scriptum! \f[align, left]))
        = "\\f[align,left]" := by native_decide

example : Id.run (currere (scriptum! \f[align, center]))
        = "\\f[align,center]" := by native_decide

-- ════════════════════════════════════════════════════
--  directioVerticalisLiteral の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currere (scriptum! \f[valign, top]))
        = "\\f[valign,top]" := by native_decide

example : Id.run (currere (scriptum! \f[valign, bottom]))
        = "\\f[valign,bottom]" := by native_decide

end Signaculum.Notatio.Verificatio
