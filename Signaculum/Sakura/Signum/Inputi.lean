-- Signaculum.Sakura.Signum.Inputi
-- 入力ダイアローグスシグヌムにゃん♪ テクストゥス・日付・時刻・スライダー・IP 入力を扱ふにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 入力ダイアローグスのシグヌムにゃん。各種入力ボックスの開閉に對應するにゃ -/
inductive SignumInputi where
  | aperiInputum
      (modus : ModusInputiTextus)
      (eventum titulus textus : String)
      (optiones : OptionesInputi)
  | aperiInputumDiei
      (eventum titulus : String)
      (annus mensis dies : Nat)
      (hm : 1 ≤ mensis ∧ mensis ≤ 12 := by omega)
      (hd : 1 ≤ dies ∧ dies ≤ diesInMense annus mensis := by omega)
      (optiones : OptionesInputi)
  | aperiInputumTemporis
      (eventum titulus : String)
      (hora : Nat) (hh : hora ≤ 23 := by omega)
      (minutum : Nat) (hmi : minutum ≤ 59 := by omega)
      (secundum : Nat) (hs : secundum ≤ 59 := by omega)
      (optiones : OptionesInputi)
  | aperiInputumGradus
      (eventum titulus : String)
      (minimum maximum initium : Nat)
      (h : minimum ≤ initium ∧ initium ≤ maximum := by omega)
      (optiones : OptionesInputi)
  | aperiInputumIP
      (eventum titulus : String)
      (ip1 : Nat) (h1 : ip1 ≤ 255 := by omega)
      (ip2 : Nat) (h2 : ip2 ≤ 255 := by omega)
      (ip3 : Nat) (h3 : ip3 ≤ 255 := by omega)
      (ip4 : Nat) (h4 : ip4 ≤ 255 := by omega)
      (optiones : OptionesInputi)
  | aperiDialogum
      (modus : ModusDialogi)
      (optiones : OptionesDialogi)
  | claudeDialogum (dialogId : String)
  deriving Repr

def SignumInputi.adCatenam : SignumInputi → String
  | .aperiInputum modus eventum titulus textus optiones =>
    let opt := optiones.toString
    let opt := if opt.isEmpty then "" else s!",{opt}"
    s!"\\![open,{modus.toString},{evadeArgumentum eventum},{evadeArgumentum titulus},{evadeArgumentum textus}{opt}]"
  | .aperiInputumDiei eventum titulus annus mensis dies _ _ optiones =>
    let opt := optiones.toString
    let opt := if opt.isEmpty then "" else s!",{opt}"
    s!"\\![open,dateinput,{evadeArgumentum eventum},{evadeArgumentum titulus},{annus},{mensis},{dies}{opt}]"
  | .aperiInputumTemporis eventum titulus hora _ minutum _ secundum _ optiones =>
    let opt := optiones.toString
    let opt := if opt.isEmpty then "" else s!",{opt}"
    s!"\\![open,timeinput,{evadeArgumentum eventum},{evadeArgumentum titulus},{hora},{minutum},{secundum}{opt}]"
  | .aperiInputumGradus eventum titulus minimum maximum initium _ optiones =>
    let opt := optiones.toString
    let opt := if opt.isEmpty then "" else s!",{opt}"
    s!"\\![open,sliderinput,{evadeArgumentum eventum},{evadeArgumentum titulus},{minimum},{maximum},{initium}{opt}]"
  | .aperiInputumIP eventum titulus ip1 _ ip2 _ ip3 _ ip4 _ optiones =>
    let opt := optiones.toString
    let opt := if opt.isEmpty then "" else s!",{opt}"
    s!"\\![open,ipinput,{evadeArgumentum eventum},{evadeArgumentum titulus},{ip1},{ip2},{ip3},{ip4}{opt}]"
  | .aperiDialogum modus optiones =>
    let opt := optiones.toString
    let opt := if opt.isEmpty then "" else s!",{opt}"
    s!"\\![open,dialog,{modus.toString}{opt}]"
  | .claudeDialogum dialogId =>
    s!"\\![close,dialog,{evadeArgumentum dialogId}]"

end Signaculum.Sakura
