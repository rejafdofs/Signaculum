-- Signaculum.Sakura.Fenestra
-- ウィンドウ・UI 管理・モード制御 にゃん♪

import Signaculum.Sakura.Fundamentum

namespace Signaculum.Sakura

-- ════════════════════════════════════════════════════
--  窓制御 (Imperium Fenestrae)
-- ════════════════════════════════════════════════════

/-- 近づく（\\5）にゃん -/
def accede {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\5"

/-- 離れる（\\4）にゃん -/
def recede {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\4"

-- ════════════════════════════════════════════════════
--  位置 (Positio) — ゴーストの移動
-- ════════════════════════════════════════════════════

/-- ゴーストを畫面座標 (sx,sy,kx,ky) に移動するにゃん（\\![move,sx,sy,kx,ky]）。
    sx/sy が主人格、kx/ky が副人格の座標にゃ -/
def movere {m : Type → Type} [Monad m] (sx sy kx ky : Int) : SakuraM m Unit :=
  emitte s!"\\![move,{sx},{sy},{kx},{ky}]"

/-- ゴーストを畫面座標に非同期で移動するにゃん（\\![moveasync,sx,sy,kx,ky]）。
    スクリプトの實行を止めずに移動するにゃ -/
def movereAsync {m : Type → Type} [Monad m] (sx sy kx ky : Int) : SakuraM m Unit :=
  emitte s!"\\![moveasync,{sx},{sy},{kx},{ky}]"

-- ════════════════════════════════════════════════════
--  可視性 (Visibilitas) — 表示/非表示
-- ════════════════════════════════════════════════════

/-- ゴーストを一時的に非表示にするにゃん（\\![vanish]）。
    `restituere` で復元できるにゃ -/
def vanesco {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![vanish]"

/-- 非表示のゴーストを復元するにゃん（\\![restore] / \\![restore,name]）。
    nomen を省略すると自ゴーストを復元するにゃ -/
def restituere {m : Type → Type} [Monad m] (nomen : String := "") : SakuraM m Unit :=
  if nomen.isEmpty then emitte "\\![restore]"
  else emitte s!"\\![restore,{evadeArgumentum nomen}]"

-- ════════════════════════════════════════════════════
--  再描畫制御 (Imperium Repicturae)
-- ════════════════════════════════════════════════════

/-- 畫面の再描畫をロックするにゃん（\\![lock,repaint]）。
    `reseraRepictura` と對で使ふにゃ -/
def seraRepictura {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![lock,repaint]"

/-- 畫面の再描畫ロックを解除するにゃん（\\![unlock,repaint]）-/
def reseraRepictura {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![unlock,repaint]"

-- ════════════════════════════════════════════════════
--  設定 (Configuratio)
-- ════════════════════════════════════════════════════

/-- 吹出しの自動スクロールを設定するにゃん（\\![set,autoscroll,on/off]）-/
def configuraAutoScroll {m : Type → Type} [Monad m] (b : Bool) : SakuraM m Unit :=
  emitte s!"\\![set,autoscroll,{if b then "on" else "off"}]"

/-- 吹出しのオフセットを設定するにゃん（\\![set,balloonoffset,target,x,y]）。
    scopus に `ScopusBullae.sakura` か `ScopusBullae.kero` を指定するにゃ -/
def configuraBullaeOffset {m : Type → Type} [Monad m]
    (scopus : ScopusBullae) (x y : Int) : SakuraM m Unit :=
  emitte s!"\\![set,balloonoffset,{scopus.toString},{x},{y}]"

/-- クイックセッションの有效/無效を設定するにゃん（\\![quicksession,true/false]）-/
def sessioRapida {m : Type → Type} [Monad m] (b : Bool) : SakuraM m Unit :=
  emitte s!"\\![quicksession,{if b then "true" else "false"}]"

-- ════════════════════════════════════════════════════
--  入力 (Ingressus)
-- ════════════════════════════════════════════════════

/-- テキスト入力ボックスを開くにゃん（\\![open,inputbox/passwordinput,event,caption,text,options]）。
    modus: `ModusInputiTextus.simplex`（通常）か `.sigillum`（パスワード）、
    eventum: 結果を受け取る事象名、titulus: ボックスの表題、
    textus: 初期文字列、optiones: オプション群にゃ -/
def aperiInputum {m : Type → Type} [Monad m]
    (modus : ModusInputiTextus := .simplex)
    (eventum titulus textus : String)
    (optiones : OptionesInputi := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![open,{modus.toString},{evadeArgumentum eventum},{evadeArgumentum titulus},{evadeArgumentum textus}{opt}]"

/-- 日付入力ボックスを開くにゃん（\\![open,dateinput,...]）。
    annus/mensis/dies は年/月(1〜12)/日(1〜月の日数) にゃ。
    閏年も考慮するにゃん♪ -/
def aperiInputumDiei {m : Type → Type} [Monad m]
    (eventum titulus : String) (annus mensis dies : Nat)
    (_hm : 1 ≤ mensis ∧ mensis ≤ 12 := by omega)
    (_hd : 1 ≤ dies ∧ dies ≤ diesInMense annus mensis := by omega)
    (optiones : OptionesInputi := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![open,dateinput,{evadeArgumentum eventum},{evadeArgumentum titulus},{annus},{mensis},{dies}{opt}]"

/-- 時刻入力ボックスを開くにゃん（\\![open,timeinput,...]）。
    hora(0〜23)/minutum(0〜59)/secundum(0〜59) にゃ -/
def aperiInputumTemporis {m : Type → Type} [Monad m]
    (eventum titulus : String) (hora minutum secundum : Nat)
    (_hh : hora ≤ 23 := by omega)
    (_hmin : minutum ≤ 59 := by omega)
    (_hs : secundum ≤ 59 := by omega)
    (optiones : OptionesInputi := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![open,timeinput,{evadeArgumentum eventum},{evadeArgumentum titulus},{hora},{minutum},{secundum}{opt}]"

/-- スライダー入力ボックスを開くにゃん（\\![open,sliderinput,...]）。
    minimum ≤ initium ≤ maximum の制約があるにゃ -/
def aperiInputumGradus {m : Type → Type} [Monad m]
    (eventum titulus : String) (minimum maximum initium : Nat)
    (_h : minimum ≤ initium ∧ initium ≤ maximum := by omega)
    (optiones : OptionesInputi := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![open,sliderinput,{evadeArgumentum eventum},{evadeArgumentum titulus},{minimum},{maximum},{initium}{opt}]"

-- ════════════════════════════════════════════════════
--  擴張 (Extensio) — SSP 固有
-- ════════════════════════════════════════════════════

/-- ゴーストの表示倍率を設定するにゃん（\\z[n]）。
    n は整數パーセント（100 = 等倍）にゃ。SSP 固有にゃ♪ -/
def zoom {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte s!"\\z[{n}]"

-- ════════════════════════════════════════════════════
--  吹出し拡張 (Extensio Bullae)
-- ════════════════════════════════════════════════════

/-- 吹出しを非表示にするにゃん（\\b[-1]）-/
def bullaAbsconde {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\b[-1]"

/-- パーセント指定改行にゃん（\\n[percent,n]）。負値や100超も指定可にゃ -/
def lineaProportionalis {m : Type → Type} [Monad m] (n : Int) : SakuraM m Unit :=
  emitte s!"\\n[percent,{n}]"

/-- 自動改行を禁止するにゃん（\\_n）-/
def linearisAbrogatur {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\_n"

/-- 吹出しの方向IDを設定するにゃん（\\![set,balloonalign,id]）-/
def allineatioBullae {m : Type → Type} [Monad m] (id : Nat) : SakuraM m Unit :=
  emitte s!"\\![set,balloonalign,{id}]"

/-- 吹出しを一定時間後に消すにゃん（\\![set,balloontimeout,ms]）-/
def tempusBullae {m : Type → Type} [Monad m] (ms : Nat) : SakuraM m Unit :=
  emitte s!"\\![set,balloontimeout,{ms}]"

/-- テキストスクロール速度を設定するにゃん（\\![set,balloonwait,比率]）-/
def moraTextus {m : Type → Type} [Monad m] (proportio : Nat) : SakuraM m Unit :=
  emitte s!"\\![set,balloonwait,{proportio}]"

/-- SERIKO の口パクを設定するにゃん（\\![set,serikotalk,true/false]）-/
def configuraSerikoOs {m : Type → Type} [Monad m] (b : Bool) : SakuraM m Unit :=
  emitte s!"\\![set,serikotalk,{if b then "true" else "false"}]"

/-- 吹出しの再描畫をロックするにゃん（\\![lock,balloonrepaint]）-/
def seraRepicturaBullae {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![lock,balloonrepaint]"

/-- 吹出しの再描畫ロックを解除するにゃん（\\![unlock,balloonrepaint]）-/
def reseraRepicturaBullae {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![unlock,balloonrepaint]"

/-- 吹出しの移動をロックするにゃん（\\![lock,balloonmove]）-/
def seraMotusBullae {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![lock,balloonmove]"

/-- 吹出しの移動ロックを解除するにゃん（\\![unlock,balloonmove]）-/
def reseraMotusBullae {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![unlock,balloonmove]"

/-- マーカーを表示するにゃん（\\![*]）-/
def ostendeMarcam {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![*]"

/-- 吹出し位置をリセットするにゃん（\\![execute,resetballoonpos]）-/
def renovaPositionemBullae {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![execute,resetballoonpos]"

/-- 吹出しの SSTP マーカー文字列を設定するにゃん（\\![set,balloonmarker,文字列]）-/
def signatumBullae {m : Type → Type} [Monad m] (signum : String) : SakuraM m Unit :=
  emitte s!"\\![set,balloonmarker,{evadeArgumentum signum}]"

-- ════════════════════════════════════════════════════
--  重ね順 (Ordo Stratorum) — Zオーダー
-- ════════════════════════════════════════════════════

/-- スコープのウィンドウZ順序を設定するにゃん（\\![set,zorder,s0,s1,...]）。
    先頭が最前面にゃ。
    例：`ordoFenestrarum [0, 1]` → `\\![set,zorder,0,1]` にゃ♪ -/
def ordoFenestrarum {m : Type → Type} [Monad m] (scopiId : List Nat) : SakuraM m Unit :=
  let catenula := ",".intercalate (scopiId.map toString)
  emitte s!"\\![set,zorder,{catenula}]"

-- ════════════════════════════════════════════════════
--  吹出し詳細設定 (Configuratio Bullae)
-- ════════════════════════════════════════════════════

/-- 吹出しの内側余白を設定するにゃん（\\![set,balloonpadding,l,t,r,b]）。
    l/t/r/b は左/上/右/下の余白（ピクセル）にゃ -/
def margosBullae {m : Type → Type} [Monad m] (l t r b : Int) : SakuraM m Unit :=
  emitte s!"\\![set,balloonpadding,{l},{t},{r},{b}]"

-- ════════════════════════════════════════════════════
--  動作設定 (Configuratio Operationis)
-- ════════════════════════════════════════════════════

/-- まばたきの有效/無效を設定するにゃん（\\![set,blink,on/off]）-/
def nictatus {m : Type → Type} [Monad m] (b : Bool) : SakuraM m Unit :=
  emitte s!"\\![set,blink,{if b then "on" else "off"}]"

/-- 常に最前面表示の有效/無效を設定するにゃん（\\![set,alwaysontop,true/false]）-/
def semperSupra {m : Type → Type} [Monad m] (b : Bool) : SakuraM m Unit :=
  emitte s!"\\![set,alwaysontop,{if b then "true" else "false"}]"

/-- タスクバーへの表示/非表示を設定するにゃん（\\![set,taskbar,show/hide]）-/
def tabellaTascae {m : Type → Type} [Monad m] (monstrum : Bool) : SakuraM m Unit :=
  emitte s!"\\![set,taskbar,{if monstrum then "show" else "hide"}]"

/-- ウィンドウドラッグの有效/無效を設定するにゃん（\\![set,windowdragging,on/off]）-/
def tractusWindowae {m : Type → Type} [Monad m] (b : Bool) : SakuraM m Unit :=
  emitte s!"\\![set,windowdragging,{if b then "on" else "off"}]"

-- ════════════════════════════════════════════════════
--  モード制御 (Imperium Modorum)
-- ════════════════════════════════════════════════════

/-- パッシブモードに入るにゃん（\\![enter,passivemode]）。
    パッシブモード中はユーザー操作を受け付けにゃいにゃ -/
def ingredereModumPassivum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![enter,passivemode]"

/-- パッシブモードから出るにゃん（\\![leave,passivemode]）-/
def egrediereModumPassivum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![leave,passivemode]"

/-- スティッキー（固定）モードに入るにゃん（\\![enter,sticky,name]）。
    nomen に固定点名を指定するにゃ。空の場合は無名固定にゃ -/
def ingredereSticky {m : Type → Type} [Monad m] (nomen : String := "") : SakuraM m Unit :=
  if nomen.isEmpty then emitte "\\![enter,sticky]"
  else emitte s!"\\![enter,sticky,{evadeArgumentum nomen}]"

/-- スティッキーモードから出るにゃん（\\![leave,sticky]）-/
def egrediereSticky {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![leave,sticky]"

/-- ホームポジションモードに入るにゃん（\\![enter,homeposition]）-/
def ingrederePositionemDomesticam {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![enter,homeposition]"

/-- ホームポジションモードから出るにゃん（\\![leave,homeposition]）-/
def egredierePositionemDomesticam {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![leave,homeposition]"

-- ════════════════════════════════════════════════════
--  開閉 (Apertio) — 各種ウィンドウの開閉
-- ════════════════════════════════════════════════════

/-- `FenestraAperibilis` で指定されたウィンドウを開くにゃん（\\![open,X]）-/
def aperi {m : Type → Type} [Monad m] (fenestra : FenestraAperibilis) : SakuraM m Unit :=
  emitte s!"\\![open,{fenestra.toString}]"

/-- `FenestraClaudibilis` で指定されたウィンドウを閉ぢるにゃん（\\![close,X]）-/
def claude {m : Type → Type} [Monad m] (fenestra : FenestraClaudibilis) : SakuraM m Unit :=
  emitte s!"\\![close,{fenestra.toString}]"

-- ════════════════════════════════════════════════════
--  窓状態 (Status Fenestrae)
-- ════════════════════════════════════════════════════

/-- ウィンドウ状態を設定するにゃん（\\![set,windowstate,状態]）-/
def configuraStatusFenestrae {m : Type → Type} [Monad m] (status : StatusFenestrae) : SakuraM m Unit :=
  emitte s!"\\![set,windowstate,{status.toString}]"

/-- デスクトップへの吸着方向を設定するにゃん（\\![set,alignmentondesktop,方向]）-/
def allineatioDesktop {m : Type → Type} [Monad m] (directio : DirectioDesktop) : SakuraM m Unit :=
  emitte s!"\\![set,alignmentondesktop,{directio.toString}]"

/-- 表面の拡大率を設定するにゃん（\\![set,scaling,比率]）。
    比率はパーセント整數にゃ。SSP 固有にゃん -/
def configuratioScalae {m : Type → Type} [Monad m] (proportio : Nat) : SakuraM m Unit :=
  emitte s!"\\![set,scaling,{proportio}]"

/-- 透明度を設定するにゃん（\\![set,alpha,值]）。0=完全透明、100=不透明にゃ -/
def configuratioAlphae {m : Type → Type} [Monad m] (valor : Nat) (_h : valor ≤ 100 := by omega) : SakuraM m Unit :=
  emitte s!"\\![set,alpha,{valor}]"

/-- ゴーストの位置を固定するにゃん（\\![set,position,x,y,scopeId]）-/
def configuraPositionem {m : Type → Type} [Monad m] (x y : Int) (scopus : Nat) : SakuraM m Unit :=
  emitte s!"\\![set,position,{x},{y},{scopus}]"

/-- 固定位置を解除するにゃん（\\![reset,position]）-/
def reseraPositionem {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![reset,position]"

/-- Z順序をリセットするにゃん（\\![reset,zorder]）-/
def reseraOrdoFenestrarum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![reset,zorder]"

/-- 複數スコープのウィンドウを連動移動するにゃん（\\![set,sticky-window,s0,s1,...]）-/
def configuraStickyWindow {m : Type → Type} [Monad m] (scopiId : List Nat) : SakuraM m Unit :=
  emitte s!"\\![set,sticky-window,{",".intercalate (scopiId.map toString)}]"

/-- スティッキーウィンドウをリセットするにゃん（\\![reset,sticky-window]）-/
def resetStickyWindow {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![reset,sticky-window]"

/-- ウィンドウ位置をリセットするにゃん（\\![execute,resetwindowpos]）-/
def renovaPositionemWindowae {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![execute,resetwindowpos]"

/-- システムトレイアイコンを設定するにゃん（\\![set,tasktrayicon,file,text,options]）-/
def configuraTascamIcon {m : Type → Type} [Monad m]
    (via textus optiones : String) : SakuraM m Unit :=
  emitte s!"\\![set,tasktrayicon,{evadeArgumentum via},{evadeArgumentum textus},{evadeArgumentum optiones}]"

/-- トレイのバルーン通知を表示するにゃん（\\![set,trayballoon,options]）-/
def configuraTascamBullam {m : Type → Type} [Monad m] (optiones : String) : SakuraM m Unit :=
  emitte s!"\\![set,trayballoon,{evadeArgumentum optiones}]"

-- ════════════════════════════════════════════════════
--  開閉拡張 (Extensio Aperitionis)
-- ════════════════════════════════════════════════════

/-- テキストエディタでファイルを開くにゃん（\\![open,editor,file,line]）-/
def aperiEditorem {m : Type → Type} [Monad m]
    (via : String) (linea : Nat := 0) : SakuraM m Unit :=
  emitte s!"\\![open,editor,{evadeArgumentum via},{linea}]"

/-- IP アドレス入力ボックスを開くにゃん（\\![open,ipinput,event,caption,ip1,ip2,ip3,ip4,options]）-/
def aperiInputumIP {m : Type → Type} [Monad m]
    (eventum titulus : String) (ip1 ip2 ip3 ip4 : Nat)
    (_h1 : ip1 ≤ 255 := by omega) (_h2 : ip2 ≤ 255 := by omega)
    (_h3 : ip3 ≤ 255 := by omega) (_h4 : ip4 ≤ 255 := by omega)
    (optiones : OptionesInputi := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![open,ipinput,{evadeArgumentum eventum},{evadeArgumentum titulus},{ip1},{ip2},{ip3},{ip4}{opt}]"


/-- ダイアローグスを開くにゃん（\\![open,dialog,modus,options]）。
    modus で種類を選ぶにゃ（`aperire`/`servare`/`directorium`/`color`）にゃ -/
def aperiDialogum {m : Type → Type} [Monad m]
    (modus : ModusDialogi) (optiones : OptionesDialogi := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![open,dialog,{modus.toString}{opt}]"

/-- ダイアログを閉ぢるにゃん（\\![close,dialog,ID]）-/
def claudeDialogum {m : Type → Type} [Monad m] (dialogId : String) : SakuraM m Unit :=
  emitte s!"\\![close,dialog,{evadeArgumentum dialogId}]"

-- ════════════════════════════════════════════════════
--  拡張モード (Modi Extensi)
-- ════════════════════════════════════════════════════

/-- 誘導モードに入るにゃん（\\![enter,inductionmode]）-/
def ingredereModumInductivum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![enter,inductionmode]"

/-- 誘導モードから出るにゃん（\\![leave,inductionmode]）-/
def egrediereModumInductivum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![leave,inductionmode]"

/-- 衝突モードに入るにゃん（\\![enter,collisionmode]）。
    rectus=true で矩形衝突にゃ -/
def ingredereModumCollisionis {m : Type → Type} [Monad m]
    (rectus : Bool := false) : SakuraM m Unit :=
  if rectus then emitte "\\![enter,collisionmode,rect]"
  else emitte "\\![enter,collisionmode]"

/-- 衝突モードから出るにゃん（\\![leave,collisionmode]）-/
def egrediereModumCollisionis {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![leave,collisionmode]"

/-- 選擇モードに入るにゃん（\\![enter,selectmode,mode,coords|name]）-/
def ingredereModumSelectionis {m : Type → Type} [Monad m]
    (modus coordsVelNomen : String) : SakuraM m Unit :=
  emitte s!"\\![enter,selectmode,{evadeArgumentum modus},{evadeArgumentum coordsVelNomen}]"

/-- 選擇モードから出るにゃん（\\![leave,selectmode]）-/
def egrediereModumSelectionis {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![leave,selectmode]"

-- ════════════════════════════════════════════════════
--  吹出し畫像拡張 (Extensio Imaginis Bullae)
-- ════════════════════════════════════════════════════

/-- 吹出しに不透明畫像を埋め込むにゃん（\\_b[path,x,y,opaque]）-/
def imagoBullaeOpaca {m : Type → Type} [Monad m]
    (via : String) (x y : Nat) : SakuraM m Unit :=
  emitte s!"\\_b[{evadeArgumentum via},{x},{y},opaque]"

/-- 吹出しにインライン畫像を埋め込むにゃん（\\_b[path,inline]）-/
def imagoBullaeInlineata {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte s!"\\_b[{evadeArgumentum via},inline]"

/-- 吹出しに不透明インライン畫像を埋め込むにゃん（\\_b[path,inline,opaque]）-/
def imagoBullaeInlineataOpaca {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte s!"\\_b[{evadeArgumentum via},inline,opaque]"

-- ════════════════════════════════════════════════════
--  移動拡張 (Extensio Motus)
-- ════════════════════════════════════════════════════

/-- 非同期移動をキャンセルするにゃん（\\![moveasync,cancel]）-/
def cancellaMotumAsync {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![moveasync,cancel]"

-- ════════════════════════════════════════════════════
--  ロック拡張 (Extensio Serae)
-- ════════════════════════════════════════════════════

/-- 再描畫を手動ロックするにゃん（\\![lock,repaint,manual]）。
    明示的に unlock するまでロックが續くにゃ -/
def seraRepicturaManualiter {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![lock,repaint,manual]"

/-- 吹出し再描畫を手動ロックするにゃん（\\![lock,balloonrepaint,manual]）-/
def seraRepicturaBullaeManualiter {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![lock,balloonrepaint,manual]"

-- ════════════════════════════════════════════════════
--  スケーリング・透明度拡張 (Extensio Scalae et Alphae)
-- ════════════════════════════════════════════════════

/-- 縱横別々にスケーリングするにゃん（\\![set,scaling,x,y]）-/
def configuraScalamDualem {m : Type → Type} [Monad m] (x y : Nat) : SakuraM m Unit :=
  emitte s!"\\![set,scaling,{x},{y}]"

/-- アニメーション付きスケーリングにゃん（\\![set,scaling,x,y,options]）-/
def configuraScalamAnimatam {m : Type → Type} [Monad m]
    (x y : Nat) (optiones : String) : SakuraM m Unit :=
  emitte s!"\\![set,scaling,{x},{y},{evadeArgumentum optiones}]"

/-- オプション付き透明度設定にゃん（\\![set,alpha,value,options]）-/
def configuraAlphamAnimatam {m : Type → Type} [Monad m]
    (valor : Nat) (_h : valor ≤ 100 := by omega) (optiones : String) : SakuraM m Unit :=
  emitte s!"\\![set,alpha,{valor},{evadeArgumentum optiones}]"

-- ════════════════════════════════════════════════════
--  吹出し拡張2 (Extensio Bullae II)
-- ════════════════════════════════════════════════════

/-- ファイル受信表示をカスタマイズするにゃん（\\![set,balloonnum,name,count,max]）-/
def configuraBullaeNumerum {m : Type → Type} [Monad m]
    (nomen : String) (numerus maximus : Nat) : SakuraM m Unit :=
  emitte s!"\\![set,balloonnum,{evadeArgumentum nomen},{numerus},{maximus}]"

end Signaculum.Sakura
