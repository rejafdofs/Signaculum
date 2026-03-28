-- Signaculum.Sakura.Signum.Fenestrae
-- 窓制御シグヌムにゃん♪ ウィンドウの移動・ロック・設定・開閉をまとめたにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura.Signum

/-- 窓制御のシグヌムにゃん。移動・ロック・設定・開閉等ぜんぶ入つてるにゃ -/
inductive SignumFenestrae where
  -- 移動 (Motus) にゃん
  | movere (sx sy kx ky : Int)
  | movereAsync (sx sy kx ky : Int)
  | cancellaMotumAsync
  -- ロック・アンロック (Sera) にゃん
  | seraRepictura
  | reseraRepictura
  | seraRepicturaBullae
  | reseraRepicturaBullae
  | seraRepicturaManualiter
  | seraRepicturaBullaeManualiter
  | seraMotusBullae
  | reseraMotusBullae
  -- 可視性 (Visibilitas) にゃん
  | vanesco
  | restituere (nomen : Option String)
  -- 設定 (Configuratio) にゃん
  | configuraAutoScroll (b : Bool)
  | configuraBullaeOffset (scopus : ScopusBullae) (x y : Int)
  | sessioRapida (b : Bool)
  | zoom (n : Nat)
  | allineatioBullae (directio : DirectioAllineatioBullae)
  | tempusBullae (ms : Nat)
  | moraTextus (proportio : Nat)
  | configuraSerikoOs (b : Bool)
  | ostendeMarcam
  | renovaPositionemBullae
  | signatumBullae (signum : String)
  | ordoFenestrarum (scopiId : List Nat)
  | margosBullae (l t r b : Int)
  -- 動作設定 (Configuratio Operationis) にゃん
  | nictatus (b : Bool)
  | semperSupra (b : Bool)
  | tabellaTascae (monstrum : Bool)
  | tractusWindowae (b : Bool)
  -- 開閉 (Apertio) にゃん
  | aperi (fenestra : FenestraAperibilis)
  | claude (fenestra : FenestraClaudibilis)
  -- 窓状態 (Status Fenestrae) にゃん
  | configuraStatusFenestrae (status : StatusFenestrae)
  | allineatioDesktop (directio : DirectioDesktop)
  | configuratioScalae (proportio : Int)
  | configuratioAlphae (valor : Nat) (h : valor ≤ 100 := by omega)
  | configuraPositionem (x y : Int) (scopus : Nat)
  | reseraPositionem
  | reseraOrdoFenestrarum
  | configuraStickyWindow (scopiId : List Nat)
  | resetStickyWindow
  | renovaPositionemWindowae
  -- トレイ・エディタ (Extensio) にゃん
  | configuraTascamIcon (via textus optiones : String)
  | configuraTascamBullam (optiones : String)
  | aperiEditorem (via : String) (linea : Nat)
  -- スケーリング・透明度拡張 にゃん
  | configuraScalamDualem (x y : Int)
  | configuraScalamAnimatam (x y : Int) (optiones : String)
  | configuraAlphamAnimatam (valor : Nat) (h : valor ≤ 100 := by omega) (optiones : String)
  -- 吹出し拡張2 にゃん
  | configuraBullaeNumerum (nomen : String) (numerus maximus : Nat)
  -- 壁紙 にゃん
  | configuraTapete (via : String) (optio : Option ModusTapetis)
  deriving Repr

def SignumFenestrae.adCatenam : SignumFenestrae → String
  -- 移動にゃん
  | .movere sx sy kx ky           => s!"\\![move,{sx},{sy},{kx},{ky}]"
  | .movereAsync sx sy kx ky      => s!"\\![moveasync,{sx},{sy},{kx},{ky}]"
  | .cancellaMotumAsync           => "\\![moveasync,cancel]"
  -- ロック・アンロックにゃん
  | .seraRepictura                => "\\![lock,repaint]"
  | .reseraRepictura              => "\\![unlock,repaint]"
  | .seraRepicturaBullae          => "\\![lock,balloonrepaint]"
  | .reseraRepicturaBullae        => "\\![unlock,balloonrepaint]"
  | .seraRepicturaManualiter      => "\\![lock,repaint,manual]"
  | .seraRepicturaBullaeManualiter => "\\![lock,balloonrepaint,manual]"
  | .seraMotusBullae              => "\\![lock,balloonmove]"
  | .reseraMotusBullae            => "\\![unlock,balloonmove]"
  -- 可視性にゃん
  | .vanesco                      => "\\![vanish]"
  | .restituere none              => "\\![restore]"
  | .restituere (some n)          => s!"\\![restore,{evadeArgumentum n}]"
  -- 設定にゃん
  | .configuraAutoScroll b        => s!"\\![set,autoscroll,{if b then "on" else "off"}]"
  | .configuraBullaeOffset sc x y => s!"\\![set,balloonoffset,{sc.toString},{x},{y}]"
  | .sessioRapida b               => s!"\\![quicksession,{if b then "true" else "false"}]"
  | .zoom n                       => s!"\\z[{n}]"
  | .allineatioBullae d           => s!"\\![set,balloonalign,{d.toString}]"
  | .tempusBullae ms              => s!"\\![set,balloontimeout,{ms}]"
  | .moraTextus proportio         => s!"\\![set,balloonwait,{proportio}]"
  | .configuraSerikoOs b          => s!"\\![set,serikotalk,{if b then "true" else "false"}]"
  | .ostendeMarcam                => "\\![*]"
  | .renovaPositionemBullae       => "\\![execute,resetballoonpos]"
  | .signatumBullae sig           => s!"\\![set,balloonmarker,{evadeArgumentum sig}]"
  | .ordoFenestrarum ids          => s!"\\![set,zorder,{",".intercalate (ids.map toString)}]"
  | .margosBullae l t r b         => s!"\\![set,balloonpadding,{l},{t},{r},{b}]"
  -- 動作設定にゃん
  | .nictatus b                   => s!"\\![set,blink,{if b then "on" else "off"}]"
  | .semperSupra b                => s!"\\![set,alwaysontop,{if b then "true" else "false"}]"
  | .tabellaTascae m              => s!"\\![set,taskbar,{if m then "show" else "hide"}]"
  | .tractusWindowae b            => s!"\\![set,windowdragging,{if b then "on" else "off"}]"
  -- 開閉にゃん
  | .aperi f                      => s!"\\![open,{f.toString}]"
  | .claude f                     => s!"\\![close,{f.toString}]"
  -- 窓状態にゃん
  | .configuraStatusFenestrae st  => s!"\\![set,windowstate,{st.toString}]"
  | .allineatioDesktop d          => s!"\\![set,alignmentondesktop,{d.toString}]"
  | .configuratioScalae p         => s!"\\![set,scaling,{p}]"
  | .configuratioAlphae v ..      => s!"\\![set,alpha,{v}]"
  | .configuraPositionem x y sc   => s!"\\![set,position,{x},{y},{sc}]"
  | .reseraPositionem             => "\\![reset,position]"
  | .reseraOrdoFenestrarum        => "\\![reset,zorder]"
  | .configuraStickyWindow ids    => s!"\\![set,sticky-window,{",".intercalate (ids.map toString)}]"
  | .resetStickyWindow            => "\\![reset,sticky-window]"
  | .renovaPositionemWindowae     => "\\![execute,resetwindowpos]"
  -- トレイ・エディタにゃん
  | .configuraTascamIcon v t o    => s!"\\![set,tasktrayicon,{evadeArgumentum v},{evadeArgumentum t},{evadeArgumentum o}]"
  | .configuraTascamBullam o      => s!"\\![set,trayballoon,{evadeArgumentum o}]"
  | .aperiEditorem v l            => s!"\\![open,editor,{evadeArgumentum v},{l}]"
  -- スケーリング・透明度拡張にゃん
  | .configuraScalamDualem x y    => s!"\\![set,scaling,{x},{y}]"
  | .configuraScalamAnimatam x y o => s!"\\![set,scaling,{x},{y},{evadeArgumentum o}]"
  | .configuraAlphamAnimatam v _ o => s!"\\![set,alpha,{v},{evadeArgumentum o}]"
  -- 吹出し拡張2にゃん
  | .configuraBullaeNumerum n nu mx => s!"\\![set,balloonnum,{evadeArgumentum n},{nu},{mx}]"
  -- 壁紙にゃん
  | .configuraTapete v none       => s!"\\![set,wallpaper,{evadeArgumentum v}]"
  | .configuraTapete v (some m)   => s!"\\![set,wallpaper,{evadeArgumentum v},{m.toString}]"

end Signaculum.Sakura.Signum
