-- Signaculum.Notatio.Fenestra
-- 窓制御・UI・モード・設定・開閉の構文規則にゃん♪

import Signaculum.Notatio.Categoria
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio

open Lean Signaculum.Sakura

-- 移動にゃん
syntax "\\!" "[move," term "," term "," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![move, $sx, $sy, $kx, $ky]) => `(Signaculum.Sakura.movere $sx $sy $kx $ky)

syntax "\\!" "[moveasync," term "," term "," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![moveasync, $sx, $sy, $kx, $ky]) => `(Signaculum.Sakura.movereAsync $sx $sy $kx $ky)

-- 可視性にゃん
syntax "\\!" "[vanish]" : sakuraSignum
macro_rules | `(expandSignum \![vanish]) => `(Signaculum.Sakura.vanesco)

syntax "\\!" "[restore]" : sakuraSignum
macro_rules | `(expandSignum \![restore]) => `(Signaculum.Sakura.restituere)

syntax "\\!" "[restore," str "]" : sakuraSignum
macro_rules | `(expandSignum \![restore, $n]) => `(Signaculum.Sakura.restituere $n)

syntax "\\!" "[reboot]" : sakuraSignum
macro_rules | `(expandSignum \![reboot]) => `(Signaculum.Sakura.renovaGhost)

-- ロックにゃん
syntax "\\!" "[lock,repaint]" : sakuraSignum
macro_rules | `(expandSignum \![lock,repaint]) => `(Signaculum.Sakura.seraRepictura)

syntax "\\!" "[unlock,repaint]" : sakuraSignum
macro_rules | `(expandSignum \![unlock,repaint]) => `(Signaculum.Sakura.reseraRepictura)

syntax "\\!" "[lock,balloonrepaint]" : sakuraSignum
macro_rules | `(expandSignum \![lock,balloonrepaint]) => `(Signaculum.Sakura.seraRepicturaBullae)

syntax "\\!" "[unlock,balloonrepaint]" : sakuraSignum
macro_rules | `(expandSignum \![unlock,balloonrepaint]) => `(Signaculum.Sakura.reseraRepicturaBullae)

syntax "\\!" "[lock,balloonmove]" : sakuraSignum
macro_rules | `(expandSignum \![lock,balloonmove]) => `(Signaculum.Sakura.seraMotusBullae)

syntax "\\!" "[unlock,balloonmove]" : sakuraSignum
macro_rules | `(expandSignum \![unlock,balloonmove]) => `(Signaculum.Sakura.reseraMotusBullae)

-- モードにゃん
syntax "\\!" "[enter,passivemode]" : sakuraSignum
macro_rules | `(expandSignum \![enter,passivemode]) => `(Signaculum.Sakura.ingredereModumPassivum)

syntax "\\!" "[leave,passivemode]" : sakuraSignum
macro_rules | `(expandSignum \![leave,passivemode]) => `(Signaculum.Sakura.egrediereModumPassivum)

syntax "\\!" "[enter,sticky]" : sakuraSignum
macro_rules | `(expandSignum \![enter,sticky]) => `(Signaculum.Sakura.ingredereSticky)

syntax "\\!" "[leave,sticky]" : sakuraSignum
macro_rules | `(expandSignum \![leave,sticky]) => `(Signaculum.Sakura.egrediereSticky)

syntax "\\!" "[enter,homeposition]" : sakuraSignum
macro_rules | `(expandSignum \![enter,homeposition]) => `(Signaculum.Sakura.ingrederePositionemDomesticam)

syntax "\\!" "[leave,homeposition]" : sakuraSignum
macro_rules | `(expandSignum \![leave,homeposition]) => `(Signaculum.Sakura.egredierePositionemDomesticam)

syntax "\\!" "[enter,inductionmode]" : sakuraSignum
macro_rules | `(expandSignum \![enter,inductionmode]) => `(Signaculum.Sakura.ingredereModumInductivum)

syntax "\\!" "[leave,inductionmode]" : sakuraSignum
macro_rules | `(expandSignum \![leave,inductionmode]) => `(Signaculum.Sakura.egrediereModumInductivum)

syntax "\\!" "[enter,collisionmode]" : sakuraSignum
macro_rules | `(expandSignum \![enter,collisionmode]) => `(Signaculum.Sakura.ingredereModumCollisionis)

syntax "\\!" "[leave,collisionmode]" : sakuraSignum
macro_rules | `(expandSignum \![leave,collisionmode]) => `(Signaculum.Sakura.egrediereModumCollisionis)

syntax "\\!" "[enter,onlinemode]" : sakuraSignum
macro_rules | `(expandSignum \![enter,onlinemode]) => `(Signaculum.Sakura.ingredereModumOnline)

syntax "\\!" "[leave,onlinemode]" : sakuraSignum
macro_rules | `(expandSignum \![leave,onlinemode]) => `(Signaculum.Sakura.egrediereModumOnline)

syntax "\\!" "[enter,nouserbreakmode]" : sakuraSignum
macro_rules | `(expandSignum \![enter,nouserbreakmode]) => `(Signaculum.Sakura.ingredereModumNonInterruptum)

syntax "\\!" "[leave,nouserbreakmode]" : sakuraSignum
macro_rules | `(expandSignum \![leave,nouserbreakmode]) => `(Signaculum.Sakura.egrediereModumNonInterruptum)

-- 設定にゃん
syntax "\\!" "[set,autoscroll," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,autoscroll, $b]) => `(Signaculum.Sakura.configuraAutoScroll $b)

syntax "\\!" "[set,windowstate," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,windowstate, $s]) => `(Signaculum.Sakura.configuraStatusFenestrae $s)

syntax "\\!" "[set,alignmentondesktop," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,alignmentondesktop, $d]) => `(Signaculum.Sakura.allineatioDesktop $d)

syntax "\\!" "[set,balloonalign," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,balloonalign, $d]) => `(Signaculum.Sakura.allineatioBullae $d)

syntax "\\!" "[set,balloontimeout," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,balloontimeout, $n]) => `(Signaculum.Sakura.tempusBullae $n)

-- リセットにゃん
syntax "\\!" "[reset,position]" : sakuraSignum
macro_rules | `(expandSignum \![reset,position]) => `(Signaculum.Sakura.reseraPositionem)

syntax "\\!" "[reset,zorder]" : sakuraSignum
macro_rules | `(expandSignum \![reset,zorder]) => `(Signaculum.Sakura.reseraOrdoFenestrarum)

syntax "\\!" "[reset,sticky-window]" : sakuraSignum
macro_rules | `(expandSignum \![reset,sticky-window]) => `(Signaculum.Sakura.resetStickyWindow)

-- 開閉にゃん
syntax "\\!" "[open,console]" : sakuraSignum
macro_rules | `(expandSignum \![open,console]) => `(Signaculum.Sakura.aperi .console)

syntax "\\!" "[close,inputum]" : sakuraSignum
macro_rules | `(expandSignum \![close,inputum]) => `(Signaculum.Sakura.claude .inputum)

-- 拡大にゃん
syntax "\\z" "[" num "]" : sakuraSignum
macro_rules | `(expandSignum \z[$n]) => `(Signaculum.Sakura.zoom $n)

-- 速度にゃん
syntax "\\!" "[quicksession," term "]" : sakuraSignum
macro_rules | `(expandSignum \![quicksession, $b]) => `(Signaculum.Sakura.sessioRapida $b)

syntax "\\!" "[quicksection," term "]" : sakuraSignum
macro_rules | `(expandSignum \![quicksection, $b]) => `(Signaculum.Sakura.sectionCeler $b)

-- 操作にゃん
syntax "\\!" "[create,shortcut]" : sakuraSignum
macro_rules | `(expandSignum \![create,shortcut]) => `(Signaculum.Sakura.creaViam)

syntax "\\!" "[*]" : sakuraSignum
macro_rules | `(expandSignum \![*]) => `(Signaculum.Sakura.ostendeMarcam)

-- ════════════════════════════════════════════════════
--  ウィンドウ開閉拡張 (Extensio Aperitionis)
-- ════════════════════════════════════════════════════

-- 固定名ウィンドウ open にゃん
syntax "\\!" "[open,communicatebox]" : sakuraSignum
macro_rules | `(expandSignum \![open,communicatebox]) => `(Signaculum.Sakura.aperi .arcaCommunicationis)

syntax "\\!" "[open,teachbox]" : sakuraSignum
macro_rules | `(expandSignum \![open,teachbox]) => `(Signaculum.Sakura.aperi .arcaDoctrinae)

syntax "\\!" "[open,makebox]" : sakuraSignum
macro_rules | `(expandSignum \![open,makebox]) => `(Signaculum.Sakura.aperi .arcaFabricationis)

syntax "\\!" "[open,ghostexplorer]" : sakuraSignum
macro_rules | `(expandSignum \![open,ghostexplorer]) => `(Signaculum.Sakura.aperi .exploratorFantasmatis)

syntax "\\!" "[open,shellexplorer]" : sakuraSignum
macro_rules | `(expandSignum \![open,shellexplorer]) => `(Signaculum.Sakura.aperi .exploratorTegumenti)

syntax "\\!" "[open,balloonexplorer]" : sakuraSignum
macro_rules | `(expandSignum \![open,balloonexplorer]) => `(Signaculum.Sakura.aperi .exploratorBullae)

syntax "\\!" "[open,surfacetest]" : sakuraSignum
macro_rules | `(expandSignum \![open,surfacetest]) => `(Signaculum.Sakura.aperi .probatioSuperficiei)

syntax "\\!" "[open,headlinesensorexplorer]" : sakuraSignum
macro_rules | `(expandSignum \![open,headlinesensorexplorer]) => `(Signaculum.Sakura.aperi .exploratorHeadlineae)

syntax "\\!" "[open,pluginexplorer]" : sakuraSignum
macro_rules | `(expandSignum \![open,pluginexplorer]) => `(Signaculum.Sakura.aperi .exploratorModulorum)

syntax "\\!" "[open,rateofusegraph]" : sakuraSignum
macro_rules | `(expandSignum \![open,rateofusegraph]) => `(Signaculum.Sakura.aperi .graphumUsus)

syntax "\\!" "[open,rateofusegraphballoon]" : sakuraSignum
macro_rules | `(expandSignum \![open,rateofusegraphballoon]) => `(Signaculum.Sakura.aperi .graphumUsusBullae)

syntax "\\!" "[open,rateofusegraphtotal]" : sakuraSignum
macro_rules | `(expandSignum \![open,rateofusegraphtotal]) => `(Signaculum.Sakura.aperi .graphumUsusTotal)

syntax "\\!" "[open,calendar]" : sakuraSignum
macro_rules | `(expandSignum \![open,calendar]) => `(Signaculum.Sakura.aperi .calendarium)

syntax "\\!" "[open,messenger]" : sakuraSignum
macro_rules | `(expandSignum \![open,messenger]) => `(Signaculum.Sakura.aperi .nuntium)

syntax "\\!" "[open,readme]" : sakuraSignum
macro_rules | `(expandSignum \![open,readme]) => `(Signaculum.Sakura.aperi .readme)

syntax "\\!" "[open,terms]" : sakuraSignum
macro_rules | `(expandSignum \![open,terms]) => `(Signaculum.Sakura.aperi .conditiones)

syntax "\\!" "[open,aigraph]" : sakuraSignum
macro_rules | `(expandSignum \![open,aigraph]) => `(Signaculum.Sakura.aperi .graphumAI)

syntax "\\!" "[open,developer]" : sakuraSignum
macro_rules | `(expandSignum \![open,developer]) => `(Signaculum.Sakura.aperi .palettaDeveloper)

syntax "\\!" "[open,shiorirequest]" : sakuraSignum
macro_rules | `(expandSignum \![open,shiorirequest]) => `(Signaculum.Sakura.aperi .petitioShiori)

syntax "\\!" "[open,dressupexplorer]" : sakuraSignum
macro_rules | `(expandSignum \![open,dressupexplorer]) => `(Signaculum.Sakura.aperi .exploratorDressupi)

-- 引數付き open にゃん
syntax "\\!" "[open,browser," str "]" : sakuraSignum
macro_rules | `(expandSignum \![open,browser, $u]) => `(Signaculum.Sakura.aperi (.navigator $u))

syntax "\\!" "[open,mailer," str "]" : sakuraSignum
macro_rules | `(expandSignum \![open,mailer, $a]) => `(Signaculum.Sakura.aperi (.nuntiatorem $a))

syntax "\\!" "[open,explorer," str "]" : sakuraSignum
macro_rules | `(expandSignum \![open,explorer, $v]) => `(Signaculum.Sakura.aperi (.explorator $v))

syntax "\\!" "[open,configurationdialog," str "]" : sakuraSignum
macro_rules | `(expandSignum \![open,configurationdialog, $i]) => `(Signaculum.Sakura.aperi (.configuratio $i))

syntax "\\!" "[open,file," str "]" : sakuraSignum
macro_rules | `(expandSignum \![open,file, $v]) => `(Signaculum.Sakura.aperi (.fasciculum $v))

syntax "\\!" "[open,help," str "]" : sakuraSignum
macro_rules | `(expandSignum \![open,help, $i]) => `(Signaculum.Sakura.aperi (.auxilium $i))

-- close にゃん
syntax "\\!" "[close,console]" : sakuraSignum
macro_rules | `(expandSignum \![close,console]) => `(Signaculum.Sakura.claude .console)

syntax "\\!" "[close,communicatebox]" : sakuraSignum
macro_rules | `(expandSignum \![close,communicatebox]) => `(Signaculum.Sakura.claude .arcaCommunicationis)

syntax "\\!" "[close,teachbox]" : sakuraSignum
macro_rules | `(expandSignum \![close,teachbox]) => `(Signaculum.Sakura.claude .arcaDoctrinae)

syntax "\\!" "[close,dialog," str "]" : sakuraSignum
macro_rules | `(expandSignum \![close,dialog, $i]) => `(Signaculum.Sakura.claudeDialogum $i)

-- ════════════════════════════════════════════════════
--  入力ダイアログ拡張 (Extensio Ingressuum)
-- ════════════════════════════════════════════════════

syntax "\\!" "[open,dateinput," term:max "," term "," term "," term "," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![open,dateinput, $cb, $title, $y, $m, $d]) =>
  `(Signaculum.Sakura.aperiInputumDiei (show String from $cb) (show String from $title) $y $m $d)

syntax "\\!" "[open,timeinput," term:max "," term "," term "," term "," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![open,timeinput, $cb, $title, $h, $m, $s]) =>
  `(Signaculum.Sakura.aperiInputumTemporis (show String from $cb) (show String from $title) $h $m $s)

syntax "\\!" "[open,sliderinput," term:max "," term "," term "," term "," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![open,sliderinput, $cb, $title, $min, $max, $init]) =>
  `(Signaculum.Sakura.aperiInputumGradus (show String from $cb) (show String from $title) $min $max $init)

syntax "\\!" "[open,ipinput," term:max "," term "," term "," term "," term "," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![open,ipinput, $cb, $title, $a, $b, $c, $d]) =>
  `(Signaculum.Sakura.aperiInputumIP (show String from $cb) (show String from $title) $a $b $c $d)

syntax "\\!" "[open,dialog," term "]" : sakuraSignum
macro_rules | `(expandSignum \![open,dialog, $m]) => `(Signaculum.Sakura.aperiDialogum $m)

syntax "\\!" "[open,editor," str "]" : sakuraSignum
macro_rules | `(expandSignum \![open,editor, $v]) => `(Signaculum.Sakura.aperiEditorem $v)

syntax "\\!" "[open,editor," str "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![open,editor, $v, $l]) => `(Signaculum.Sakura.aperiEditorem $v $l)

-- ════════════════════════════════════════════════════
--  設定拡張 (Extensio Configurationis)
-- ════════════════════════════════════════════════════

syntax "\\!" "[set,balloonoffset," term "," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,balloonoffset, $s, $x, $y]) => `(Signaculum.Sakura.configuraBullaeOffset $s $x $y)

syntax "\\!" "[set,balloonwait," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,balloonwait, $p]) => `(Signaculum.Sakura.moraTextus $p)

syntax "\\!" "[set,serikotalk," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,serikotalk, $b]) => `(Signaculum.Sakura.configuraSerikoOs $b)

syntax "\\!" "[set,balloonpadding," term "," term "," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,balloonpadding, $l, $t, $r, $b]) => `(Signaculum.Sakura.margosBullae $l $t $r $b)

syntax "\\!" "[set,blink," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,blink, $b]) => `(Signaculum.Sakura.nictatus $b)

syntax "\\!" "[set,alwaysontop," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,alwaysontop, $b]) => `(Signaculum.Sakura.semperSupra $b)

syntax "\\!" "[set,taskbar," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,taskbar, $b]) => `(Signaculum.Sakura.tabellaTascae $b)

syntax "\\!" "[set,windowdragging," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,windowdragging, $b]) => `(Signaculum.Sakura.tractusWindowae $b)

syntax "\\!" "[set,scaling," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,scaling, $p]) => `(Signaculum.Sakura.configuratioScalae $p)

syntax "\\!" "[set,alpha," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,alpha, $v]) => `(Signaculum.Sakura.configuratioAlphae $v)

syntax "\\!" "[set,position," term "," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![set,position, $x, $y, $s]) => `(Signaculum.Sakura.configuraPositionem $x $y $s)

syntax "\\!" "[set,balloonmarker," str "]" : sakuraSignum
macro_rules | `(expandSignum \![set,balloonmarker, $s]) => `(Signaculum.Sakura.signatumBullae $s)

syntax "\\!" "[set,tasktrayicon," str "," str "," str "]" : sakuraSignum
macro_rules | `(expandSignum \![set,tasktrayicon, $v, $t, $o]) => `(Signaculum.Sakura.configuraTascamIcon $v $t $o)

syntax "\\!" "[set,trayballoon," str "]" : sakuraSignum
macro_rules | `(expandSignum \![set,trayballoon, $o]) => `(Signaculum.Sakura.configuraTascamBullam $o)

-- ════════════════════════════════════════════════════
--  モード拡張 (Extensio Modorum)
-- ════════════════════════════════════════════════════

syntax "\\!" "[enter,selectmode," "rect" "," str "]" : sakuraSignum
macro_rules | `(expandSignum \![enter,selectmode, rect, $c]) => `(Signaculum.Sakura.ingredereModumSelectionis .rectus $c)

syntax "\\!" "[leave,selectmode]" : sakuraSignum
macro_rules | `(expandSignum \![leave,selectmode]) => `(Signaculum.Sakura.egrediereModumSelectionis)

-- ════════════════════════════════════════════════════
--  バルーン畫像 (Imago Bullae)
-- ════════════════════════════════════════════════════

syntax "\\_b" "[" str "," num "," num "]" : sakuraSignum
macro_rules | `(expandSignum \_b[$v, $x, $y]) => `(Signaculum.Sakura.imagoBullae $v $x $y)

syntax "\\_b" "[" str "," num "," num "," "opaque" "]" : sakuraSignum
macro_rules | `(expandSignum \_b[$v, $x, $y, opaque]) => `(Signaculum.Sakura.imagoBullaeOpaca $v $x $y)

syntax "\\_b" "[" str "," "inline" "]" : sakuraSignum
macro_rules | `(expandSignum \_b[$v, inline]) => `(Signaculum.Sakura.imagoBullaeInlineata $v)

syntax "\\_b" "[" str "," "inline" "," "opaque" "]" : sakuraSignum
macro_rules | `(expandSignum \_b[$v, inline, opaque]) => `(Signaculum.Sakura.imagoBullaeInlineataOpaca $v)

-- ════════════════════════════════════════════════════
--  リセット・實行拡張 (Extensio Renovationis)
-- ════════════════════════════════════════════════════

syntax "\\!" "[execute,resetballoonpos]" : sakuraSignum
macro_rules | `(expandSignum \![execute,resetballoonpos]) => `(Signaculum.Sakura.renovaPositionemBullae)

syntax "\\!" "[execute,resetwindowpos]" : sakuraSignum
macro_rules | `(expandSignum \![execute,resetwindowpos]) => `(Signaculum.Sakura.renovaPositionemWindowae)

syntax "\\!" "[moveasync,cancel]" : sakuraSignum
macro_rules | `(expandSignum \![moveasync,cancel]) => `(Signaculum.Sakura.cancellaMotumAsync)

syntax "\\!" "[lock,repaint,manual]" : sakuraSignum
macro_rules | `(expandSignum \![lock,repaint,manual]) => `(Signaculum.Sakura.seraRepicturaManualiter)

syntax "\\!" "[lock,balloonrepaint,manual]" : sakuraSignum
macro_rules | `(expandSignum \![lock,balloonrepaint,manual]) => `(Signaculum.Sakura.seraRepicturaBullaeManualiter)

end Signaculum.Notatio
