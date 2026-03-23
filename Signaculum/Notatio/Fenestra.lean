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
macro_rules | `(expandSignum \![set,balloonalign, $n]) => `(Signaculum.Sakura.allineatioBullae $n)

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

end Signaculum.Notatio
