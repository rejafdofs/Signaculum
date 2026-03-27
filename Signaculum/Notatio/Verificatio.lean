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
example : Id.run (currereScriptum (scriptum! \f[bold, Bool.true])) = "\\f[bold,true]" := by native_decide

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

-- none リテラル（SakuraScript 仕樣通り none をそのまま書けるにゃん）
example : Id.run (currereScriptum (scriptum! \f[color, none]))
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

-- ════════════════════════════════════════════════════
--  舊形式スコープの検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \0)) = "\\h" := by native_decide
example : Id.run (currereScriptum (scriptum! \1)) = "\\u" := by native_decide

-- ════════════════════════════════════════════════════
--  文字・行淸掃拡張の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \c[char, 3])) = "\\c[char,3]" := by native_decide
example : Id.run (currereScriptum (scriptum! \c[char, 5, 2])) = "\\c[char,5,2]" := by native_decide
example : Id.run (currereScriptum (scriptum! \c[line, 1])) = "\\c[line,1]" := by native_decide
example : Id.run (currereScriptum (scriptum! \c[line, 2, 0])) = "\\c[line,2,0]" := by native_decide

-- ════════════════════════════════════════════════════
--  選擇肢拡張の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \q["hello", script: "\\h"])) = "\\q[hello,script:\\\\h]" := by native_decide
example : Id.run (currereScriptum (scriptum! \__q["sel1"])) = "\\__q[sel1]" := by native_decide
example : Id.run (currereScriptum (scriptum! \__q)) = "\\__q" := by native_decide

-- ════════════════════════════════════════════════════
--  同期拡張の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \_s[0])) = "\\_s[0]" := by native_decide
example : Id.run (currereScriptum (scriptum! \_s[0, 1])) = "\\_s[0,1]" := by native_decide
example : Id.run (currereScriptum (scriptum! \_s[0, 1, 2])) = "\\_s[0,1,2]" := by native_decide

-- イヴェントゥム附き選擇肢の可變長引數にゃん
example : Id.run (currereScriptum (scriptum! \q["hello", "OnYes", "r0"])) = "\\q[hello,OnYes,r0]" := by native_decide
example : Id.run (currereScriptum (scriptum! \q["hello", "OnYes", "r0", "r1"])) = "\\q[hello,OnYes,r0,r1]" := by native_decide

-- ════════════════════════════════════════════════════
--  移動・ロック拡張の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \![moveasync,cancel])) = "\\![moveasync,cancel]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![lock,repaint,manual])) = "\\![lock,repaint,manual]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![lock,balloonrepaint,manual])) = "\\![lock,balloonrepaint,manual]" := by native_decide

-- ════════════════════════════════════════════════════
--  ウィンドウ開閉の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \![open,ghostexplorer])) = "\\![open,ghostexplorer]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![open,browser, "https://example.com"])) = "\\![open,browser,https://example.com]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![close,console])) = "\\![close,console]" := by native_decide

-- ════════════════════════════════════════════════════
--  他ゴースト・プラグイン事象の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \![raiseother, "Ghost", "OnEvent"])) = "\\![raiseother,Ghost,OnEvent]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![notifyother, "Ghost", "OnEvent"])) = "\\![notifyother,Ghost,OnEvent]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![raiseplugin, "Plugin", "OnEvent"])) = "\\![raiseplugin,Plugin,OnEvent]" := by native_decide

-- ════════════════════════════════════════════════════
--  音響・動畫拡張の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \![sound,load, "bgm.mp3"])) = "\\![sound,load,bgm.mp3]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![filter])) = "\\![filter]" := by native_decide

-- ════════════════════════════════════════════════════
--  實行系の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \![execute,createupdatedata])) = "\\![execute,createupdatedata]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![execute,emptyrecyclebin])) = "\\![execute,emptyrecyclebin]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![execute,createnar])) = "\\![execute,createnar]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![execute,resetballoonpos])) = "\\![execute,resetballoonpos]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![execute,resetwindowpos])) = "\\![execute,resetwindowpos]" := by native_decide

-- ════════════════════════════════════════════════════
--  設定系の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \![set,shioridebugmode])) = "\\![set,shioridebugmode]" := by native_decide
example : Id.run (currereScriptum (scriptum! \![set,balloonmarker, "test"])) = "\\![set,balloonmarker,test]" := by native_decide

-- ════════════════════════════════════════════════════
--  バルーン畫像の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \_b["img.png", 0, 0])) = "\\_b[img.png,0,0]" := by native_decide
example : Id.run (currereScriptum (scriptum! \_b["img.png", 0, 0, opaque])) = "\\_b[img.png,0,0,opaque]" := by native_decide
example : Id.run (currereScriptum (scriptum! \_b["img.png", inline])) = "\\_b[img.png,inline]" := by native_decide
example : Id.run (currereScriptum (scriptum! \_b["img.png", inline, opaque])) = "\\_b[img.png,inline,opaque]" := by native_decide

-- ════════════════════════════════════════════════════
--  環境變數の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! %month)) = "%month" := by native_decide
example : Id.run (currereScriptum (scriptum! %username)) = "%username" := by native_decide

-- ════════════════════════════════════════════════════
--  Windows メッセージ・音聲合成の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \m["0x0400", "0", "0"])) = "\\m[0x0400,0,0]" := by native_decide
example : Id.run (currereScriptum (scriptum! \__v["speed=100"])) = "\\__v[speed=100]" := by native_decide

-- ════════════════════════════════════════════════════
--  フォント拡張の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \f[anchor.font.color, red])) = "\\f[anchor.font.color,red]" := by native_decide

-- ════════════════════════════════════════════════════
--  colorisLiteral 擴張の検證にゃん（default/disable 系）
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \f[color, default]))
        = "\\f[color,default]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[color, disable]))
        = "\\f[color,disable]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[color, default.anchor]))
        = "\\f[color,default.anchor]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[color, default.cursor]))
        = "\\f[color,default.cursor]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[color, default.plain]))
        = "\\f[color,default.plain]" := by native_decide

-- ════════════════════════════════════════════════════
--  stylusUmbraeLiteral の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \f[shadowstyle, offset]))
        = "\\f[shadowstyle,offset]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[shadowstyle, outline]))
        = "\\f[shadowstyle,outline]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[shadowstyle, default]))
        = "\\f[shadowstyle,default]" := by native_decide

-- ════════════════════════════════════════════════════
--  statusContorniLiteral の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \f[outline, true]))
        = "\\f[outline,true]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[outline, false]))
        = "\\f[outline,false]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[outline, disable]))
        = "\\f[outline,disable]" := by native_decide

-- ════════════════════════════════════════════════════
--  magnitudoLitterarumLiteral の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \f[height, 15]))
        = "\\f[height,15]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[height, default]))
        = "\\f[height,default]" := by native_decide

-- ════════════════════════════════════════════════════
--  directioAllineatioBullaeLiteral の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \![set,balloonalign, .sinistrum]))
        = "\\![set,balloonalign,left]" := by native_decide

example : Id.run (currereScriptum (scriptum! \![set,balloonalign, .centrum]))
        = "\\![set,balloonalign,center]" := by native_decide

example : Id.run (currereScriptum (scriptum! \![set,balloonalign, .nullus]))
        = "\\![set,balloonalign,none]" := by native_decide

-- ════════════════════════════════════════════════════
--  selectmode の検證にゃん
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \![enter,selectmode, rect, "collision_area"]))
        = "\\![enter,selectmode,rect,collision_area]" := by native_decide

-- ════════════════════════════════════════════════════
--  methodusMarciLiteral 擴張の検證にゃん（ROP2 モード）
-- ════════════════════════════════════════════════════

example : Id.run (currereScriptum (scriptum! \f[cursormethod, copypen]))
        = "\\f[cursormethod,copypen]" := by native_decide

example : Id.run (currereScriptum (scriptum! \f[cursormethod, notmaskpen]))
        = "\\f[cursormethod,notmaskpen]" := by native_decide

end Signaculum.Notatio.Verificatio
