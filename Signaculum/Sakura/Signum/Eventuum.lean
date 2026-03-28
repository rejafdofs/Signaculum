-- Signaculum.Sakura.Signum.Eventuum
-- 事象シグヌムにゃん♪ イヴェントゥムの發生や通知を制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 事象制御のシグヌムにゃん。raise / embed / notify 等のイヴェントゥム系タグに對應するにゃ -/
inductive SignumEventuum where
  | excita (eventum : String) (citationes : List String)
    -- \![raise,ev,r0,...]（事象を發生させるにゃ）
  | insere (eventum : String) (citationes : List String)
    -- \![embed,ev,r0,...]（事象の結果を埋め込むにゃ）
  | notifica (eventum : String) (citationes : List String)
    -- \![notify,ev,r0,...]（通知事象にゃ）
  | excitaPostTempus (tempus repetitio : Nat) (eventum : String) (citationes : List String)
    -- \![timerraise,ms,repeat,ev,r0,...]（一定時間後に事象を發生させるにゃ）
  | excitaAlium (ghostNomen eventum : String) (citationes : List String)
    -- \![raiseother,ghost,ev,r0,...]（他ゴーストに事象を發生させるにゃ）
  | excitaAliumPostTempus (tempus repetitio : Nat) (ghostNomen eventum : String) (citationes : List String)
    -- \![timerraiseother,ms,repeat,ghost,ev,r0,...]（一定時間後に他ゴーストの事象にゃ）
  | notificaPostTempus (tempus repetitio : Nat) (eventum : String) (citationes : List String)
    -- \![timernotify,ms,repeat,ev,r0,...]（一定時間後に通知するにゃ）
  | notificaAlium (ghostNomen eventum : String) (citationes : List String)
    -- \![notifyother,ghost,ev,r0,...]（他ゴーストに通知するにゃ）
  | notificaAliumPostTempus (tempus repetitio : Nat) (ghostNomen eventum : String) (citationes : List String)
    -- \![timernotifyother,ms,repeat,ghost,ev,r0,...]（一定時間後に他ゴーストに通知するにゃ）
  | notificaPlugin (pluginNomen eventum : String) (citationes : List String)
    -- \![notifyplugin,plugin,ev,r0,...]（プラグインに通知するにゃ）
  | excitaPluginPostTempus (tempus repetitio : Nat) (pluginNomen eventum : String) (citationes : List String)
    -- \![timerraiseplugin,ms,repeat,plugin,ev,r0,...]（一定時間後にプラグイン事象にゃ）
  | notificaPluginPostTempus (tempus repetitio : Nat) (pluginNomen eventum : String) (citationes : List String)
    -- \![timernotifyplugin,ms,repeat,plugin,ev,r0,...]（一定時間後にプラグインに通知するにゃ）
  | vocaShiori (eventum : String) (citationes : List String)
    -- \![call,shiori,ev,r0,...]（SHIORI を呼び出すにゃ）
  | vocaSaori (dllPath functio : String) (citationes : List String)
    -- \![call,saori,dll,func,r0,...]（SAORI を呼び出すにゃ）
  | vocaPlugin (pluginNomen eventum : String) (citationes : List String)
    -- \![raiseplugin,plugin,ev,r0,...]（プラグインにイヴェントゥムを送るにゃ）
  | vocaGhost (nomen : String) (optiones : OptionesMutationis)
    -- \![call,ghost,name,options]（ゴーストを呼び出すにゃ）
  deriving Repr

/-- 事象シグヌムをさくらスクリプトゥム文字列に變換するにゃん -/
def SignumEventuum.adCatenam : SignumEventuum → String
  | .excita ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![raise,{evadeArgumentum ev}{ccat}]"
  | .insere ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![embed,{evadeArgumentum ev}{ccat}]"
  | .notifica ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![notify,{evadeArgumentum ev}{ccat}]"
  | .excitaPostTempus t r ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![timerraise,{t},{r},{evadeArgumentum ev}{ccat}]"
  | .excitaAlium gn ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![raiseother,{evadeArgumentum gn},{evadeArgumentum ev}{ccat}]"
  | .excitaAliumPostTempus t r gn ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![timerraiseother,{t},{r},{evadeArgumentum gn},{evadeArgumentum ev}{ccat}]"
  | .notificaPostTempus t r ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![timernotify,{t},{r},{evadeArgumentum ev}{ccat}]"
  | .notificaAlium gn ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![notifyother,{evadeArgumentum gn},{evadeArgumentum ev}{ccat}]"
  | .notificaAliumPostTempus t r gn ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![timernotifyother,{t},{r},{evadeArgumentum gn},{evadeArgumentum ev}{ccat}]"
  | .notificaPlugin pn ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![notifyplugin,{evadeArgumentum pn},{evadeArgumentum ev}{ccat}]"
  | .excitaPluginPostTempus t r pn ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![timerraiseplugin,{t},{r},{evadeArgumentum pn},{evadeArgumentum ev}{ccat}]"
  | .notificaPluginPostTempus t r pn ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![timernotifyplugin,{t},{r},{evadeArgumentum pn},{evadeArgumentum ev}{ccat}]"
  | .vocaShiori ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![call,shiori,{evadeArgumentum ev}{ccat}]"
  | .vocaSaori dp fn cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![call,saori,{evadeArgumentum dp},{evadeArgumentum fn}{ccat}]"
  | .vocaPlugin pn ev cc =>
    let ccat := match cc with
      | [] => "" | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\![raiseplugin,{evadeArgumentum pn},{evadeArgumentum ev}{ccat}]"
  | .vocaGhost nm opt =>
    let o := opt.toString
    let o := if o.isEmpty then "" else s!",{o}"
    s!"\\![call,ghost,{evadeArgumentum nm}{o}]"

end Signaculum.Sakura
