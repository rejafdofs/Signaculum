-- Signaculum.Sakura.Signum.Modorum
-- モード制御シグヌムにゃん♪ 各種モードの出入りを表すにゃ。ボクが全部やるにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura.Signum

/-- モード制御のシグヌムにゃん。\\![enter,...] / \\![leave,...] 等に對應するにゃ。
    パッシヴモードやスティッキーやら、ボクが全部まとめたにゃ♪ -/
inductive SignumModorum where
  | ingredereModumPassivum                                                           -- \![enter,passivemode]
  | egrediereModumPassivum                                                           -- \![leave,passivemode]
  | ingredereModumOnline                                                             -- \![enter,onlinemode]
  | egrediereModumOnline                                                             -- \![leave,onlinemode]
  | ingredereSticky (nomen : Option String)                                          -- \![enter,sticky] / \![enter,sticky,nomen]
  | egrediereSticky                                                                  -- \![leave,sticky]
  | ingrederePositionemDomesticam                                                    -- \![enter,homeposition]
  | egredierePositionemDomesticam                                                    -- \![leave,homeposition]
  | ingredereModumInductivum                                                         -- \![enter,inductionmode]
  | egrediereModumInductivum                                                         -- \![leave,inductionmode]
  | ingredereModumCollisionis (rectus : Bool)                                        -- \![enter,collisionmode] / \![enter,collisionmode,rect]
  | egrediereModumCollisionis                                                        -- \![leave,collisionmode]
  | ingredereModumSelectionis (modus : ModusSelectionis) (coordsVelNomen : String)   -- \![enter,selectmode,mode,coords]
  | egrediereModumSelectionis                                                        -- \![leave,selectmode]
  | ingredereModumNonInterruptum                                                     -- \![enter,nouserbreakmode]
  | egrediereModumNonInterruptum                                                     -- \![leave,nouserbreakmode]
  deriving Repr

def SignumModorum.adCatenam : SignumModorum → String
  | .ingredereModumPassivum           => "\\![enter,passivemode]"
  | .egrediereModumPassivum           => "\\![leave,passivemode]"
  | .ingredereModumOnline             => "\\![enter,onlinemode]"
  | .egrediereModumOnline             => "\\![leave,onlinemode]"
  | .ingredereSticky none             => "\\![enter,sticky]"
  | .ingredereSticky (some n)         => s!"\\![enter,sticky,{evadeArgumentum n}]"
  | .egrediereSticky                  => "\\![leave,sticky]"
  | .ingrederePositionemDomesticam    => "\\![enter,homeposition]"
  | .egredierePositionemDomesticam    => "\\![leave,homeposition]"
  | .ingredereModumInductivum         => "\\![enter,inductionmode]"
  | .egrediereModumInductivum         => "\\![leave,inductionmode]"
  | .ingredereModumCollisionis false  => "\\![enter,collisionmode]"
  | .ingredereModumCollisionis true   => "\\![enter,collisionmode,rect]"
  | .egrediereModumCollisionis        => "\\![leave,collisionmode]"
  | .ingredereModumSelectionis m c    => s!"\\![enter,selectmode,{m.toString},{evadeArgumentum c}]"
  | .egrediereModumSelectionis        => "\\![leave,selectmode]"
  | .ingredereModumNonInterruptum     => "\\![enter,nouserbreakmode]"
  | .egrediereModumNonInterruptum     => "\\![leave,nouserbreakmode]"

end Signaculum.Sakura.Signum
