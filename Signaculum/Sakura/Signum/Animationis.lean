-- Signaculum.Sakura.Signum.Animationis
-- 動畫シグヌムにゃん♪ アニマーティオの開始・停止・追加を制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 動畫制御のシグヌムにゃん。\![anim,...] に對應するにゃ -/
inductive SignumAnimationis where
  | animaIncepit (scopus id : Nat)                -- \![anim,start,scopus,id]（開始にゃ）
  | animaDesinit (scopus id : Nat)                -- \![anim,stop,scopus,id]（停止にゃ）
  | animaPausat (scopus id : Nat)                 -- \![anim,pause,scopus,id]（一時停止にゃ）
  | animaContinuat (scopus id : Nat)              -- \![anim,resume,scopus,id]（再開にゃ）
  | animaPurgat (scopus id : Nat)                 -- \![anim,clear,scopus,id]（消去にゃ）
  | animaOperatur (scopus id : Nat)               -- \![anim,playing,scopus,id]（再生中確認にゃ）
  | animaTranslatio (scopus id : Nat) (x y : Int) -- \![anim,offset,scopus,id,x,y]（位置補正にゃ）
  | animaAddOverlay (animId : Nat)                -- \![anim,add,overlay,id]（オーヴァーレイ追加にゃ）
  | animaAddOverlayPos (animId : Nat) (x y : Int) -- \![anim,add,overlay,id,x,y]（座標附きオーヴァーレイにゃ）
  | animaAddBase (animId : Nat)                   -- \![anim,add,base,id]（ベース變更にゃ）
  | animaAddMove (x y : Int)                      -- \![anim,add,move,x,y]（移動にゃ）
  | animaAddOverlayFast (animId : Nat)            -- \![anim,add,overlayfast,id]（高速オーヴァーレイにゃ）
  | animaAddTextum (x y latitudo altitudo : Int) (textus : String)
      (tempus : Nat) (r g b magnitudo : Nat) (fons : String)
    -- \![anim,add,text,x,y,w,h,text,time,r,g,b,size,font]（テクストゥス表示にゃ）
  | animaAddOverlayAnimatum (animId : Nat) (x y : Int)
      (tempus : Nat) (optiones : String)
    -- \![anim,add,overlay,id,x,y,time,opts]（タイミング附きオーヴァーレイにゃ）
  deriving Repr

/-- シグヌム・アニマーティオニスをさくらスクリプトゥム文字列に變換するにゃん -/
def SignumAnimationis.adCatenam : SignumAnimationis → String
  | .animaIncepit scopus id          => s!"\\![anim,start,{scopus},{id}]"
  | .animaDesinit scopus id          => s!"\\![anim,stop,{scopus},{id}]"
  | .animaPausat scopus id           => s!"\\![anim,pause,{scopus},{id}]"
  | .animaContinuat scopus id        => s!"\\![anim,resume,{scopus},{id}]"
  | .animaPurgat scopus id           => s!"\\![anim,clear,{scopus},{id}]"
  | .animaOperatur scopus id         => s!"\\![anim,playing,{scopus},{id}]"
  | .animaTranslatio scopus id x y   => s!"\\![anim,offset,{scopus},{id},{x},{y}]"
  | .animaAddOverlay animId          => s!"\\![anim,add,overlay,{animId}]"
  | .animaAddOverlayPos animId x y   => s!"\\![anim,add,overlay,{animId},{x},{y}]"
  | .animaAddBase animId             => s!"\\![anim,add,base,{animId}]"
  | .animaAddMove x y                => s!"\\![anim,add,move,{x},{y}]"
  | .animaAddOverlayFast animId      => s!"\\![anim,add,overlayfast,{animId}]"
  | .animaAddTextum x y w h textus tempus r g b mag fons =>
    let fontPars := if fons.isEmpty then "" else s!",{evadeArgumentum fons}"
    s!"\\![anim,add,text,{x},{y},{w},{h},{evadeArgumentum textus},{tempus},{r},{g},{b},{mag}{fontPars}]"
  | .animaAddOverlayAnimatum animId x y tempus optiones =>
    let optPars := if optiones.isEmpty then "" else s!",{evadeArgumentum optiones}"
    s!"\\![anim,add,overlay,{animId},{x},{y},{tempus}{optPars}]"

end Signaculum.Sakura
