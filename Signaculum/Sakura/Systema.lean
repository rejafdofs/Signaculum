-- Signaculum.Sakura.Systema
-- イベント・音響・HTTP・プロパティ・ゴースト管理 にゃん♪

import Signaculum.Sakura.Fundamentum

namespace Signaculum.Sakura

-- ════════════════════════════════════════════════════
--  音聲 (Sonus)
-- ════════════════════════════════════════════════════

/-- 音聲を再生する（\\_v[file]）にゃん -/
def sonus {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte (.soni (.sonus via))

/-- 音聲の終了を待つ（\\_V）にゃん -/
def expectaSonum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.soni .expectaSonum)

-- ════════════════════════════════════════════════════
--  事象 (Eventum)
-- ════════════════════════════════════════════════════

/-- 事象を發生させる（\\![raise,event,r0,...]）にゃん -/
def excita {m : Type → Type} [Monad m]
    (eventum : String) (citationes : List String := []) : SakuraM m Unit :=
  emitte (.eventuum (.excita eventum citationes))

/-- 事象の結果をその場に埋め込む（\\![embed,event,r0,...]）にゃん -/
def insere {m : Type → Type} [Monad m]
    (eventum : String) (citationes : List String := []) : SakuraM m Unit :=
  emitte (.eventuum (.insere eventum citationes))

/-- 通知事象（\\![notify,event,r0,...]）にゃん -/
def notifica {m : Type → Type} [Monad m]
    (eventum : String) (citationes : List String := []) : SakuraM m Unit :=
  emitte (.eventuum (.notifica eventum citationes))

-- ════════════════════════════════════════════════════
--  表面拡張 (Extensio Superficiei)
-- ════════════════════════════════════════════════════

/-- 表面を非表示にするにゃん（\\s[-1]）-/
def superficiesAbsconde {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\s[-1]"

/-- 表面動畫を再生して完了まで待つにゃん（\\i[id,wait]）-/
def animatioExpecta {m : Type → Type} [Monad m] (animId : Nat) : SakuraM m Unit :=
  emitte s!"\\i[{animId},wait]"

/-- 指定スコープのアニメーションパターンを再開するにゃん（\\![anim,resume,scopus,id]）-/
def animaContinuat {m : Type → Type} [Monad m] (scopus animId : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,resume,{scopus},{animId}]"

/-- 指定スコープのアニメーションパターンを消去するにゃん（\\![anim,clear,scopus,id]）-/
def animaPurgat {m : Type → Type} [Monad m] (scopus animId : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,clear,{scopus},{animId}]"

/-- 指定スコープのアニメーション位置をオフセットするにゃん（\\![anim,offset,scopus,id,x,y]）-/
def animaTranslatio {m : Type → Type} [Monad m] (scopus animId : Nat) (x y : Int) : SakuraM m Unit :=
  emitte s!"\\![anim,offset,{scopus},{animId},{x},{y}]"

/-- 着せ替えパーツを切り替へるにゃん（\\![bind,category,part,value]）。
    valor: `some true`=着衣(1)、`some false`=脱衣(0)、`none`=トグル（省略）にゃ -/
def nexaDressup {m : Type → Type} [Monad m]
    (categoria pars : String) (valor : Option Bool := none) : SakuraM m Unit :=
  match valor with
  | some true  => emitte s!"\\![bind,{evadeArgumentum categoria},{evadeArgumentum pars},1]"
  | some false => emitte s!"\\![bind,{evadeArgumentum categoria},{evadeArgumentum pars},0]"
  | none       => emitte s!"\\![bind,{evadeArgumentum categoria},{evadeArgumentum pars}]"

/-- 效果プラグインを適用するにゃん（\\![effect,plugin,speed,parameter]）-/
def applicaEffectum {m : Type → Type} [Monad m]
    (plugin : String) (speed : Nat) (parametrum : String) : SakuraM m Unit :=
  emitte s!"\\![effect,{evadeArgumentum plugin},{speed},{evadeArgumentum parametrum}]"

/-- フィルタを適用するにゃん（\\![filter,plugin,time,parameter]）。
    plugin を空にすると除去にゃ -/
def applicaFiltratum {m : Type → Type} [Monad m]
    (plugin : String) (tempus : Nat) (parametrum : String) : SakuraM m Unit :=
  if plugin.isEmpty then emitte "\\![filter]"
  else emitte s!"\\![filter,{evadeArgumentum plugin},{tempus},{evadeArgumentum parametrum}]"

-- ════════════════════════════════════════════════════
--  音響拡張 (Extensio Soni)
-- ════════════════════════════════════════════════════

/-- 波形ファイルを簡易再生するにゃん（\\8[filename]）-/
def sonus8 {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte s!"\\8[{evadeArgumentum via}]"

/-- 音聲ファイルを再生するにゃん（\\![sound,play,file,options]）。
    optiones は `OptionesSoni` で指定するにゃ -/
def sonusPulsus {m : Type → Type} [Monad m]
    (via : String) (optiones : OptionesSoni := {}) : SakuraM m Unit :=
  let s := optiones.toString
  if s.isEmpty then emitte s!"\\![sound,play,{evadeArgumentum via}]"
  else emitte s!"\\![sound,play,{evadeArgumentum via},{s}]"

/-- 音聲ファイルをループ再生するにゃん（\\![sound,loop,file]）-/
def sonusOrbitans {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte s!"\\![sound,loop,{evadeArgumentum via}]"

/-- 音聲ファイルを停止するにゃん（\\![sound,stop,file]）-/
def sonusInterrumpit {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte s!"\\![sound,stop,{evadeArgumentum via}]"

/-- 音聲ファイルを一時停止するにゃん（\\![sound,pause,file]）-/
def sonusPausat {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte s!"\\![sound,pause,{evadeArgumentum via}]"

/-- 音聲ファイルを再開するにゃん（\\![sound,resume,file]）-/
def sonusContinuat {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte s!"\\![sound,resume,{evadeArgumentum via}]"

/-- 音聲ファイルを事前讀込みするにゃん（\\![sound,load,file,options]）。
    optiones は `OptionesSoni` で指定するにゃ。`solusAudio` も使へるにゃ -/
def sonusOneratur {m : Type → Type} [Monad m]
    (via : String) (optiones : OptionesSoni := {}) : SakuraM m Unit :=
  let s := optiones.toString
  if s.isEmpty then emitte s!"\\![sound,load,{evadeArgumentum via}]"
  else emitte s!"\\![sound,load,{evadeArgumentum via},{s}]"

-- ════════════════════════════════════════════════════
--  変更 (Mutatio) — ゴースト/シェル/吹出し変更
-- ════════════════════════════════════════════════════

/-- ゴーストを名前で切り替へるにゃん（\\![change,ghost,name,options]）。
    nomen にゴーストのディレクトリ名、optiones で raise-event を指定できるにゃ -/
def mutaGhostNomen {m : Type → Type} [Monad m]
    (nomen : String) (optiones : OptionesMutationis := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![change,ghost,{evadeArgumentum nomen}{opt}]"

/-- シェルを名前で切り替へるにゃん（\\![change,shell,name,options]）。
    nomen にシェル名、optiones で raise-event を指定できるにゃ -/
def mutaShell {m : Type → Type} [Monad m]
    (nomen : String) (optiones : OptionesMutationis := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![change,shell,{evadeArgumentum nomen}{opt}]"

/-- 吹出しを名前で切り替へるにゃん（\\![change,balloon,name,options]）。
    nomen に吹出し名、optiones で raise-event を指定できるにゃ -/
def mutaBullam {m : Type → Type} [Monad m]
    (nomen : String) (optiones : OptionesMutationis := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![change,balloon,{evadeArgumentum nomen}{opt}]"

/-- ゴーストを再起動するにゃん（\\![reboot]）。
    SAKURA スクリプトを完全にリロードするにゃ♪ -/
def renovaGhost {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![reboot]"

-- ════════════════════════════════════════════════════
--  動畫パターン制御 (Imperium Animationis Exemplarium)
-- ════════════════════════════════════════════════════

/-- 指定スコープのアニメーションパターンを開始するにゃん（\\![anim,start,scopus,id]）-/
def animaIncepit {m : Type → Type} [Monad m] (scopus id : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,start,{scopus},{id}]"

/-- 指定スコープのアニメーションパターンを停止するにゃん（\\![anim,stop,scopus,id]）-/
def animaDesinit {m : Type → Type} [Monad m] (scopus id : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,stop,{scopus},{id}]"

/-- 指定スコープのアニメーションパターンを一時停止するにゃん（\\![anim,pause,scopus,id]）-/
def animaPausat {m : Type → Type} [Monad m] (scopus id : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,pause,{scopus},{id}]"

/-- 指定スコープのアニメーションが再生中か確認するにゃん（\\![anim,playing,scopus,id]）。
    SSP 固有にゃん -/
def animaOperatur {m : Type → Type} [Monad m] (scopus id : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,playing,{scopus},{id}]"

-- ════════════════════════════════════════════════════
--  呼出し (Vocatio) — SHIORI/SAORI/プラグイン呼出し
-- ════════════════════════════════════════════════════

/-- SHIORI イベントを呼び出すにゃん（\\![call,shiori,eventum,r0,...]）。
    eventum に呼び出すイベント名、citationes に参照引数を渡すにゃ -/
def vocaShiori {m : Type → Type} [Monad m]
    (eventum : String) (citationes : List String := []) : SakuraM m Unit :=
  let catenaCitationis := match citationes with
    | [] => ""
    | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![call,shiori,{evadeArgumentum eventum}{catenaCitationis}]"

/-- SAORI を呼び出すにゃん（\\![call,saori,dll,functio,r0,...]）。
    dllPath に DLL パス、functio に関数名、citationes に参照引数を渡すにゃ -/
def vocaSaori {m : Type → Type} [Monad m]
    (dllPath functio : String) (citationes : List String := []) : SakuraM m Unit :=
  let catenaCitationis := match citationes with
    | [] => ""
    | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![call,saori,{evadeArgumentum dllPath},{evadeArgumentum functio}{catenaCitationis}]"

/-- プラグインにイベントを送るにゃん（\\![raiseplugin,pluginNomen,eventum,r0,...]）。
    SSP 固有にゃん -/
def vocaPlugin {m : Type → Type} [Monad m]
    (pluginNomen eventum : String) (citationes : List String := []) : SakuraM m Unit :=
  let catenaCitationis := match citationes with
    | [] => ""
    | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![raiseplugin,{evadeArgumentum pluginNomen},{evadeArgumentum eventum}{catenaCitationis}]"

-- ════════════════════════════════════════════════════
--  事象拡張 (Extensio Eventuum)
-- ════════════════════════════════════════════════════

/-- 時刻同期を實行するにゃん（\\6）-/
def syncTempus {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\6"

/-- 時刻同期事象を開始するにゃん（\\7）-/
def eventumTempus {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\7"

/-- 一定時間後に事象を發生させるにゃん（\\![timerraise,ms,repeat,event,r0,...]）。
    repetitio は繰返し回數（0=無限）にゃ -/
def excitaPostTempus {m : Type → Type} [Monad m]
    (tempus repetitio : Nat) (eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![timerraise,{tempus},{repetitio},{evadeArgumentum eventum}{cc}]"

/-- 他ゴーストに事象を發生させるにゃん（\\![raiseother,ghost,event,r0,...]）-/
def excitaAlium {m : Type → Type} [Monad m]
    (ghostNomen eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![raiseother,{evadeArgumentum ghostNomen},{evadeArgumentum eventum}{cc}]"

/-- 一定時間後に他ゴーストの事象を發生させるにゃん（\\![timerraiseother,ms,repeat,ghost,event,r0,...]）-/
def excitaAliumPostTempus {m : Type → Type} [Monad m]
    (tempus repetitio : Nat) (ghostNomen eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![timerraiseother,{tempus},{repetitio},{evadeArgumentum ghostNomen},{evadeArgumentum eventum}{cc}]"

/-- 一定時間後に通知事象を發生させるにゃん（\\![timernotify,ms,repeat,event,r0,...]）-/
def notificaPostTempus {m : Type → Type} [Monad m]
    (tempus repetitio : Nat) (eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![timernotify,{tempus},{repetitio},{evadeArgumentum eventum}{cc}]"

/-- 他ゴーストに通知事象を發生させるにゃん（\\![notifyother,ghost,event,r0,...]）-/
def notificaAlium {m : Type → Type} [Monad m]
    (ghostNomen eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![notifyother,{evadeArgumentum ghostNomen},{evadeArgumentum eventum}{cc}]"

/-- 一定時間後に他ゴーストに通知するにゃん（\\![timernotifyother,ms,repeat,ghost,event,r0,...]）-/
def notificaAliumPostTempus {m : Type → Type} [Monad m]
    (tempus repetitio : Nat) (ghostNomen eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![timernotifyother,{tempus},{repetitio},{evadeArgumentum ghostNomen},{evadeArgumentum eventum}{cc}]"

/-- プラグインに通知事象を發生させるにゃん（\\![notifyplugin,plugin,event,r0,...]）-/
def notificaPlugin {m : Type → Type} [Monad m]
    (pluginNomen eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![notifyplugin,{evadeArgumentum pluginNomen},{evadeArgumentum eventum}{cc}]"

/-- 一定時間後にプラグインの事象を發生させるにゃん（\\![timerraiseplugin,ms,repeat,plugin,event,r0,...]）-/
def excitaPluginPostTempus {m : Type → Type} [Monad m]
    (tempus repetitio : Nat) (pluginNomen eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![timerraiseplugin,{tempus},{repetitio},{evadeArgumentum pluginNomen},{evadeArgumentum eventum}{cc}]"

/-- 一定時間後にプラグインに通知するにゃん（\\![timernotifyplugin,ms,repeat,plugin,event,r0,...]）-/
def notificaPluginPostTempus {m : Type → Type} [Monad m]
    (tempus repetitio : Nat) (pluginNomen eventum : String)
    (citationes : List String := []) : SakuraM m Unit :=
  let cc := match citationes with
    | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\![timernotifyplugin,{tempus},{repetitio},{evadeArgumentum pluginNomen},{evadeArgumentum eventum}{cc}]"

/-- オンラインモードに入るにゃん（\\![enter,onlinemode]）-/
def ingredereModumOnline {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![enter,onlinemode]"

/-- オンラインモードから出るにゃん（\\![leave,onlinemode]）-/
def egrediereModumOnline {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![leave,onlinemode]"

/-- ユーザー中断禁止モードに入るにゃん（\\![enter,nouserbreakmode]）-/
def ingredereModumNonInterruptum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![enter,nouserbreakmode]"

/-- ユーザー中断禁止モードから出るにゃん（\\![leave,nouserbreakmode]）-/
def egrediereModumNonInterruptum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![leave,nouserbreakmode]"

-- ════════════════════════════════════════════════════
--  再讀込 (Renovatio)
-- ════════════════════════════════════════════════════

/-- 表面を再讀込するにゃん（\\![reloadsurface]）-/
def renovaSuperficiem {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![reloadsurface]"

/-- `ScopusRenovationis` で指定された對象を再讀込するにゃん（\\![reload,X]）。
    ※ ゴースト全體の再起動は `renovaGhost`（\\![reboot]）で別にゃん -/
def renova {m : Type → Type} [Monad m] (scopus : ScopusRenovationis) : SakuraM m Unit :=
  emitte s!"\\![reload,{scopus.toString}]"

-- ════════════════════════════════════════════════════
--  同期拡張 (Extensio Synchroniae)
-- ════════════════════════════════════════════════════

/-- 特定スコープのみ同期するにゃん（\\_s[ID1,ID2,...]）-/
def synchronaScopi {m : Type → Type} [Monad m] (scopiId : List Nat) : SakuraM m Unit :=
  emitte s!"\\_s[{",".intercalate (scopiId.map toString)}]"

/-- 同期タイマーをリセットするにゃん（\\__w[clear]）-/
def reseraTimerSynchrinae {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\__w[clear]"

/-- 特定アニメーションの完了を待つにゃん（\\__w[animation,id]）-/
def moraAnimationem {m : Type → Type} [Monad m] (animId : Nat) : SakuraM m Unit :=
  emitte s!"\\__w[animation,{animId}]"

/-- クイックセクションの有效/無效を設定するにゃん（\\![quicksection,true/false]）。
    `celer`（\\_q）のブール版にゃ -/
def sectionCeler {m : Type → Type} [Monad m] (b : Bool) : SakuraM m Unit :=
  emitte s!"\\![quicksection,{if b then "true" else "false"}]"

/-- 次のゴーストに順番に切り替へるにゃん（\\_+）-/
def mutaGhostSequens {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\_+"

/-- 常に最前面トグル（\\v）にゃん -/
def togglaSupra {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\v"

-- ════════════════════════════════════════════════════
--  動畫追加 (Additio Animationis) — anim add 系
-- ════════════════════════════════════════════════════

/-- アニメーションにオーバーレイを追加するにゃん（\\![anim,add,overlay,id]）-/
def animaAddOverlay {m : Type → Type} [Monad m] (animId : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,add,overlay,{animId}]"

/-- アニメーションにオーバーレイを座標指定で追加するにゃん（\\![anim,add,overlay,id,x,y]）-/
def animaAddOverlayPos {m : Type → Type} [Monad m] (animId : Nat) (x y : Int) : SakuraM m Unit :=
  emitte s!"\\![anim,add,overlay,{animId},{x},{y}]"

/-- アニメーションのベース表面を変更するにゃん（\\![anim,add,base,id]）-/
def animaAddBase {m : Type → Type} [Monad m] (animId : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,add,base,{animId}]"

/-- アニメーションを移動するにゃん（\\![anim,add,move,x,y]）-/
def animaAddMove {m : Type → Type} [Monad m] (x y : Int) : SakuraM m Unit :=
  emitte s!"\\![anim,add,move,{x},{y}]"

/-- 高速オーバーレイを追加するにゃん（\\![anim,add,overlayfast,id]）-/
def animaAddOverlayFast {m : Type → Type} [Monad m] (animId : Nat) : SakuraM m Unit :=
  emitte s!"\\![anim,add,overlayfast,{animId}]"

-- ════════════════════════════════════════════════════
--  他ゴースト設定 (Configuratio Aliorum)
-- ════════════════════════════════════════════════════

/-- 他ゴーストのトーク連携を設定するにゃん（\\![set,otherghosttalk,false/before/after]）。
    `ModusGhostAlieni.inactivus/ante/post` で指定するにゃ -/
def configuraAliosGhostes {m : Type → Type} [Monad m] (modus : ModusGhostAlieni) : SakuraM m Unit :=
  emitte s!"\\![set,otherghosttalk,{modus.toString}]"

/-- 他ゴーストの表面変更連携を設定するにゃん（\\![set,othersurfacechange,true/false]）-/
def configuraAliasSuperficies {m : Type → Type} [Monad m] (b : Bool) : SakuraM m Unit :=
  emitte s!"\\![set,othersurfacechange,{if b then "true" else "false"}]"

/-- 壁紙を設定するにゃん（\\![set,wallpaper,file,option]）。
    optio: `center`/`tile`/`stretch`/`stretch-x`/`stretch-y`/`span` にゃ -/
def configuraTapete {m : Type → Type} [Monad m]
    (via : String) (optio : Option ModusTapetis := none) : SakuraM m Unit :=
  match optio with
  | none   => emitte s!"\\![set,wallpaper,{evadeArgumentum via}]"
  | some m => emitte s!"\\![set,wallpaper,{evadeArgumentum via},{m.toString}]"

-- ════════════════════════════════════════════════════
--  音響拡張2 (Extensio Soni II)
-- ════════════════════════════════════════════════════

/-- 音聲の完了を待つにゃん（\\![sound,wait]）-/
def expectaSonumPulsus {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![sound,wait]"

/-- CD トラックを再生するにゃん（\\![sound,cdplay,track]）-/
def sonusCD {m : Type → Type} [Monad m] (track : Nat) : SakuraM m Unit :=
  emitte s!"\\![sound,cdplay,{track}]"

/-- 音聲のオプションを変更するにゃん（\\![sound,option,file,options]）。
    optiones は `OptionesSoni` で指定するにゃ -/
def sonusOptio {m : Type → Type} [Monad m]
    (via : String) (optiones : OptionesSoni) : SakuraM m Unit :=
  emitte s!"\\![sound,option,{evadeArgumentum via},{optiones.toString}]"

-- ════════════════════════════════════════════════════
--  再讀込拡張 (Extensio Renovationis)
-- ════════════════════════════════════════════════════

/-- SHIORI をアンロードするにゃん（\\![unload,shiori]）-/
def expelleShiori {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![unload,shiori]"

/-- makoto をアンロードするにゃん（\\![unload,makoto]）-/
def expelleMakoto {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![unload,makoto]"

/-- SHIORI をロードするにゃん（\\![load,shiori]）-/
def oneraSHIORI {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![load,shiori]"

/-- makoto をロードするにゃん（\\![load,makoto]）-/
def oneraMakoto {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![load,makoto]"

/-- SHIORI のデバッグモードを設定するにゃん（\\![set,shioridebugmode]）-/
def configuraShioriDebug {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![set,shioridebugmode]"

-- ════════════════════════════════════════════════════
--  HTTP 拡張 (Extensio HTTP)
-- ════════════════════════════════════════════════════

/-- HTTP GET リクエストゥムを實行するにゃん（\\![execute,http-get,URL,options]）-/
def executaHttpGet {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,http-get,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,http-get,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

/-- HTTP POST リクエストゥムを實行するにゃん（\\![execute,http-post,URL,options]）-/
def executaHttpPost {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,http-post,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,http-post,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

/-- HTTP HEAD リクエストゥムを實行するにゃん（\\![execute,http-head,URL,options]）-/
def executaHttpHead {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,http-head,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,http-head,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

/-- HTTP PUT リクエストを實行するにゃん（\\![execute,http-put,URL,options]）-/
def executaHttpPut {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,http-put,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,http-put,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

/-- HTTP DELETE リクエストを實行するにゃん（\\![execute,http-delete,URL,options]）-/
def executaHttpDelete {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,http-delete,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,http-delete,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

/-- HTTP PATCH リクエストを實行するにゃん（\\![execute,http-patch,URL,options]）-/
def executaHttpPatch {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,http-patch,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,http-patch,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

/-- RSS GET リクエストを實行するにゃん（\\![execute,rss-get,URL,options]）-/
def executaRssGet {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,rss-get,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,rss-get,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

/-- ヘッドラインを實行するにゃん（\\![execute,headline,name]）-/
def executaHeadline {m : Type → Type} [Monad m] (nomen : String) : SakuraM m Unit :=
  emitte s!"\\![execute,headline,{evadeArgumentum nomen}]"

/-- DNS 解決を實行するにゃん（\\![execute,nslookup,param,...]）-/
def executaNslookup {m : Type → Type} [Monad m] (parametra : List String) : SakuraM m Unit :=
  let cc := ",".intercalate (parametra.map evadeArgumentum)
  emitte s!"\\![execute,nslookup,{cc}]"

/-- PING を實行するにゃん（\\![execute,ping,param,...]）-/
def executaPing {m : Type → Type} [Monad m] (parametra : List String) : SakuraM m Unit :=
  let cc := ",".intercalate (parametra.map evadeArgumentum)
  emitte s!"\\![execute,ping,{cc}]"

/-- SNTP 時刻同期を實行するにゃん（\\![executesntp]）-/
def executaSNTP {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![executesntp]"

/-- 表面をダンプするにゃん（\\![execute,dumpsurface,dir,scope,list,prefix,event,zero]）-/
def executaDumpSuperficiei {m : Type → Type} [Monad m]
    (directum : String) (scopus : Nat) (lista praefixum eventum : String) (zero : Bool) : SakuraM m Unit :=
  emitte s!"\\![execute,dumpsurface,{evadeArgumentum directum},{scopus},{evadeArgumentum lista},{evadeArgumentum praefixum},{evadeArgumentum eventum},{if zero then "1" else "0"}]"

/-- URL からゴーストをインストールするにゃん（\\![execute,install,url,URL,type]）-/
def executaInstallationemUrl {m : Type → Type} [Monad m]
    (nexus typus : String) : SakuraM m Unit :=
  emitte s!"\\![execute,install,url,{evadeArgumentum nexus},{evadeArgumentum typus}]"

/-- 更新データを作成するにゃん（\\![execute,createupdatedata]）-/
def executaCreationemUpdateData {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![execute,createupdatedata]"

/-- ゴーストをアップデートするにゃん（\\![updatebymyself,options]）-/
def renovaSeIpsum {m : Type → Type} [Monad m] (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte "\\![updatebymyself]"
  else emitte s!"\\![updatebymyself,{evadeArgumentum optiones}]"

/-- ゴーストをアンインストールするにゃん（\\![vanishbymyself,options]）-/
def evanesceSeIpsum {m : Type → Type} [Monad m] (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte "\\![vanishbymyself]"
  else emitte s!"\\![vanishbymyself,{evadeArgumentum optiones}]"

/-- ショートカットを作成するにゃん（\\![create,shortcut]）-/
def creaViam {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![create,shortcut]"

/-- 副表面に效果を適用するにゃん（\\![effect2,id,plugin,speed,parameter]）-/
def applicaEffectum2 {m : Type → Type} [Monad m]
    (animId : Nat) (plugin : String) (speed : Nat) (parametrum : String) : SakuraM m Unit :=
  emitte s!"\\![effect2,{animId},{evadeArgumentum plugin},{speed},{evadeArgumentum parametrum}]"

/-- タグ實行を禁止するにゃん（\\_?）-/
def inhibeTagas {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\_?"

/-- メールを確認するにゃん（\\![biff,account]）。
    account にメールアカウント名を指定するにゃ -/
def exploraPostam {m : Type → Type} [Monad m] (account : String) : SakuraM m Unit :=
  emitte s!"\\![biff,{evadeArgumentum account}]"

/-- リソース参照文字列を埋め込むにゃん（\\&[ID]）。
    ID にリソース ID を指定するにゃ -/
def referentiaResourcei {m : Type → Type} [Monad m] (resourceId : String) : SakuraM m Unit :=
  emitte s!"\\&[{evadeArgumentum resourceId}]"

/-- Windows メッセージを直接送るにゃん（\\m[umsg,wparam,lparam]）。
    低水準操作にゃ。umsg/wparam/lparam は 16 進數文字列にゃ -/
def nuntiumWindowae {m : Type → Type} [Monad m] (umsg wparam lparam : String) : SakuraM m Unit :=
  emitte s!"\\m[{evadeArgumentum umsg},{evadeArgumentum wparam},{evadeArgumentum lparam}]"

-- ════════════════════════════════════════════════════
--  設定システム (Systema Proprietatis)
-- ════════════════════════════════════════════════════

/-- プロパティを設定するにゃん（\\![set,property,name,value]）-/
def configuraProprietatem {m : Type → Type} [Monad m]
    (proprietas : Proprietas) (valor : String) : SakuraM m Unit :=
  emitte s!"\\![set,property,{evadeArgumentum proprietas.toString},{evadeArgumentum valor}]"

/-- プロパティを取得するにゃん（\\![get,property,event,name,...]）。
    eventum に結果を受け取る事象名を渡すにゃ -/
def legeProprietatem {m : Type → Type} [Monad m]
    (eventum : String) (proprietates : List Proprietas) : SakuraM m Unit :=
  let catenaProprieta := ",".intercalate (proprietates.map (evadeArgumentum ∘ Proprietas.toString))
  emitte s!"\\![get,property,{evadeArgumentum eventum},{catenaProprieta}]"

/-- プロパティ値をその場に埋め込むにゃん（%property[name]）。
    `loqui` は % をエスケープするため使へにゃい。この關數を使ふにゃ♪ -/
def proprietasCitata {m : Type → Type} [Monad m] (proprietas : Proprietas) : SakuraM m Unit :=
  emitte s!"%property[{escapePropNomen proprietas.toString}]"

-- ════════════════════════════════════════════════════
--  同期拡張2 (Extensio Synchroniae II)
-- ════════════════════════════════════════════════════

/-- 名前付き同期オブジェクトゥムの完了を待つにゃん（\\![wait,syncobject,name,timeout]）-/
def expectaSyncObjectum {m : Type → Type} [Monad m]
    (nomen : String) (tempus : Nat) : SakuraM m Unit :=
  emitte s!"\\![wait,syncobject,{evadeArgumentum nomen},{tempus}]"

-- ════════════════════════════════════════════════════
--  ゴースト管理拡張 (Extensio Administrationis)
-- ════════════════════════════════════════════════════

/-- ゴーストを呼び出すにゃん（\\![call,ghost,name,options]）。
    change と違って自ゴーストは終了しにゃいにゃ -/
def vocaGhost {m : Type → Type} [Monad m]
    (nomen : String) (optiones : OptionesMutationis := {}) : SakuraM m Unit :=
  let opt := optiones.toString
  let opt := if opt.isEmpty then "" else s!",{opt}"
  emitte s!"\\![call,ghost,{evadeArgumentum nomen}{opt}]"

/-- プラットフォームの更新を開始するにゃん（\\![update,platform]）-/
def renovaPlatformam {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![update,platform]"

/-- 指定對象の更新を實行するにゃん（\\![update,target,options]）-/
def renovaScopum {m : Type → Type} [Monad m]
    (scopus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![update,{evadeArgumentum scopus}]"
  else emitte s!"\\![update,{evadeArgumentum scopus},{evadeArgumentum optiones}]"

/-- 他者の更新を實行するにゃん（\\![updateother,options]）-/
def renovaAlium {m : Type → Type} [Monad m] (optiones : String) : SakuraM m Unit :=
  emitte s!"\\![updateother,{evadeArgumentum optiones}]"

-- ════════════════════════════════════════════════════
--  ファイル操作 (Operationes Fasciculorum)
-- ════════════════════════════════════════════════════

/-- アーカイブを展開するにゃん（\\![execute,extractarchive,file,folder,options]）-/
def extraheArchivum {m : Type → Type} [Monad m]
    (via directum : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,extractarchive,{evadeArgumentum via},{evadeArgumentum directum}]"
  else emitte s!"\\![execute,extractarchive,{evadeArgumentum via},{evadeArgumentum directum},{evadeArgumentum optiones}]"

/-- フォルダを壓縮するにゃん（\\![execute,compressarchive,file,folder,options]）-/
def comprimeArchivum {m : Type → Type} [Monad m]
    (via directum : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,compressarchive,{evadeArgumentum via},{evadeArgumentum directum}]"
  else emitte s!"\\![execute,compressarchive,{evadeArgumentum via},{evadeArgumentum directum},{evadeArgumentum optiones}]"

/-- ファイルからインストールするにゃん（\\![execute,install,path,file]）-/
def executaInstallationemVia {m : Type → Type} [Monad m] (via : String) : SakuraM m Unit :=
  emitte s!"\\![execute,install,path,{evadeArgumentum via}]"

/-- NAR ファイルを作成するにゃん（\\![execute,createnar]）-/
def executaCreationemNar {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![execute,createnar]"

/-- ゴミ箱を空にするにゃん（\\![execute,emptyrecyclebin]）-/
def evacuaRecyclatorium {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\![execute,emptyrecyclebin]"

-- ════════════════════════════════════════════════════
--  HTTP 拡張2 (Extensio HTTP II)
-- ════════════════════════════════════════════════════

/-- HTTP OPTIONS リクエストゥムを實行するにゃん（\\![execute,http-options,URL,options]）-/
def executaHttpOptions {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,http-options,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,http-options,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

/-- RSS POST リクエストゥムを實行するにゃん（\\![execute,rss-post,URL,options]）-/
def executaRssPost {m : Type → Type} [Monad m]
    (nexus : String) (optiones : String := "") : SakuraM m Unit :=
  if optiones.isEmpty then emitte s!"\\![execute,rss-post,{evadeArgumentum nexus}]"
  else emitte s!"\\![execute,rss-post,{evadeArgumentum nexus},{evadeArgumentum optiones}]"

-- ════════════════════════════════════════════════════
--  動畫拡張2 (Extensio Animationis II)
-- ════════════════════════════════════════════════════

/-- サーフェス上にテクストゥスを表示するにゃん（\\![anim,add,text,x,y,w,h,text,time,r,g,b,size,font]）-/
def animaAddTextum {m : Type → Type} [Monad m]
    (x y latitudo altitudo : Int) (textus : String) (tempus : Nat)
    (r g b : Nat) (_hr : r ≤ 255 := by omega) (_hg : g ≤ 255 := by omega) (_hb : b ≤ 255 := by omega)
    (magnitudo : Nat) (fons : String := "") : SakuraM m Unit :=
  let fontPars := if fons.isEmpty then "" else s!",{evadeArgumentum fons}"
  emitte s!"\\![anim,add,text,{x},{y},{latitudo},{altitudo},{evadeArgumentum textus},{tempus},{r},{g},{b},{magnitudo}{fontPars}]"

/-- タイミング付きオーバーレイ動畫にゃん（\\![anim,add,overlay,ID,x,y,time,options]）-/
def animaAddOverlayAnimatum {m : Type → Type} [Monad m]
    (animId : Nat) (x y : Int) (tempus : Nat) (optiones : String := "") : SakuraM m Unit :=
  let optPars := if optiones.isEmpty then "" else s!",{evadeArgumentum optiones}"
  emitte s!"\\![anim,add,overlay,{animId},{x},{y},{tempus}{optPars}]"

-- ════════════════════════════════════════════════════
--  音聲合成 (Synthesis Vocis)
-- ════════════════════════════════════════════════════

/-- 音聲合成の發聲を調整するにゃん（\\__v[options]）-/
def synthesisVocis {m : Type → Type} [Monad m] (optiones : String) : SakuraM m Unit :=
  emitte s!"\\__v[{evadeArgumentum optiones}]"

-- ════════════════════════════════════════════════════
--  環境變數參照 (Variabiles Ambientis)
-- ════════════════════════════════════════════════════

/-- SSP が展開する環境變數をそのまま出力するにゃん（%nomen）。
    `loqui` は `%` をエスケープするため使へにゃいから、この關數を使ふにゃん♪
    例: `variabilisAmbientis "month"` → `%month` にゃ -/
def variabilisAmbientis {m : Type → Type} [Monad m] (nomen : String) : SakuraM m Unit :=
  emitte s!"%{nomen}"

end Signaculum.Sakura
