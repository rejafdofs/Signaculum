-- Signaculum.Sakura.Signum.Optionum
-- 選擇肢・錨シグヌムにゃん♪ 使用者の選擇を受け付けるにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura.Signum

/-- 選擇肢・錨のシグヌムにゃん。\q / \_a / \__q 等に對應するにゃ -/
inductive SignumOptionum where
  | optio (titulus signum : String)                                      -- \q[t,s]
  | optioEventum (titulus eventum : String) (citationes : List String)   -- \q[t,ev,r0,...]
  | optioScriptum (titulus scriptum : String)                            -- \q[t,script:c]
  | optioMultiplex (titulus : String) (signa : List String)              -- \q[t,ID1,ID2,...]
  | optioScopus (signum : String) (citationes : List String)             -- \__q[ID,...]
  | fineOptioScopus                                                       -- \__q
  | ancora (id : String)                                                  -- \_a[id]
  | fineAncora                                                            -- \_a
  | tempusOptionum (ms : Nat)                                             -- \![set,choicetimeout,ms]
  deriving Repr

def SignumOptionum.adCatenam : SignumOptionum → String
  | .optio t s => s!"\\q[{evadeArgumentum t},{evadeArgumentum s}]"
  | .optioEventum t ev cc =>
    let ccat := match cc with
      | [] => ""
      | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\q[{evadeArgumentum t},{evadeArgumentum ev}{ccat}]"
  | .optioScriptum t sc => s!"\\q[{evadeArgumentum t},script:{evadeArgumentum sc}]"
  | .optioMultiplex t ss => s!"\\q[{evadeArgumentum t},{",".intercalate (ss.map evadeArgumentum)}]"
  | .optioScopus sig cc =>
    let ccat := match cc with
      | [] => ""
      | res => "," ++ ",".intercalate (res.map evadeArgumentum)
    s!"\\__q[{evadeArgumentum sig}{ccat}]"
  | .fineOptioScopus => "\\__q"
  | .ancora id => s!"\\_a[{evadeArgumentum id}]"
  | .fineAncora => "\\_a"
  | .tempusOptionum ms => s!"\\![set,choicetimeout,{ms}]"

end Signaculum.Sakura.Signum
