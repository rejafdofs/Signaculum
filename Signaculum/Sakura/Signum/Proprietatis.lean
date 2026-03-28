-- Signaculum.Sakura.Signum.Proprietatis
-- プロパティ・環境・更新系シグヌムにゃん♪ ゴーストの設定や參照を表すにゃ。ボクに任せるにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- プロパティ・環境・更新系のシグヌムにゃん。\\![set,property,...] / %property[...] 等に對應するにゃ。
    設定も取得も效果もぜんぶボクがまとめてあげたにゃん♪ -/
inductive SignumProprietatis where
  | configuraProprietatem (proprietas : Proprietas) (valor : String)              -- \![set,property,prop,val]
  | legeProprietatem (eventum : String) (proprietates : List Proprietas)          -- \![get,property,ev,prop1,prop2,...]
  | proprietasCitata (proprietas : Proprietas)                                    -- %property[prop]
  | variabilisAmbientis (nomen : String)                                          -- %nomen
  | configuraAliosGhostes (modus : ModusGhostAlieni)                              -- \![set,otherghosttalk,modus]
  | configuraAliasSuperficies (b : Bool)                                          -- \![set,othersurfacechange,b]
  | nexaDressup (categoria pars : String) (valor : Option Bool)                   -- \![bind,cat,part,val]
  | applicaEffectum (plugin : String) (speed : Nat) (parametrum : String)         -- \![effect,plugin,speed,param]
  | applicaFiltratum (plugin : String) (tempus : Nat) (parametrum : String)       -- \![filter,plugin,time,param]
  | applicaEffectum2 (animId : Nat) (plugin : String) (speed : Nat) (parametrum : String) -- \![effect2,animId,plugin,speed,param]
  | exploraPostam (account : String)                                              -- \![biff,account]
  | referentiaResourcei (resourceId : String)                                     -- \&[resourceId]
  | nuntiumWindowae (umsg wparam lparam : String)                                 -- \m[umsg,wparam,lparam]
  | expectaSyncObjectum (nomen : String) (tempus : Nat)                           -- \![wait,syncobject,name,time]
  | renovaPlatformam                                                              -- \![update,platform]
  | renovaScopum (scopus : String) (optiones : String)                            -- \![update,scopus,opts]
  | renovaAlium (optiones : String)                                               -- \![updateother,opts]
  | renovaSeIpsum (optiones : String)                                             -- \![updatebymyself,opts]
  | evanesceSeIpsum (optiones : String)                                           -- \![vanishbymyself,opts]
  | creaViam                                                                      -- \![create,shortcut]
  deriving Repr

def SignumProprietatis.adCatenam : SignumProprietatis → String
  | .configuraProprietatem p v =>
    s!"\\![set,property,{evadeArgumentum p.toString},{evadeArgumentum v}]"
  | .legeProprietatem ev ps =>
    let catenaProprieta := ",".intercalate (ps.map (evadeArgumentum ∘ Proprietas.toString))
    s!"\\![get,property,{evadeArgumentum ev},{catenaProprieta}]"
  | .proprietasCitata p =>
    s!"%property[{escapePropNomen p.toString}]"
  | .variabilisAmbientis n =>
    s!"%{n}"
  | .configuraAliosGhostes m =>
    s!"\\![set,otherghosttalk,{m.toString}]"
  | .configuraAliasSuperficies b =>
    s!"\\![set,othersurfacechange,{if b then "true" else "false"}]"
  | .nexaDressup cat pars (some true)  => s!"\\![bind,{evadeArgumentum cat},{evadeArgumentum pars},1]"
  | .nexaDressup cat pars (some false) => s!"\\![bind,{evadeArgumentum cat},{evadeArgumentum pars},0]"
  | .nexaDressup cat pars none         => s!"\\![bind,{evadeArgumentum cat},{evadeArgumentum pars},0]"
  | .applicaEffectum pl sp pa =>
    s!"\\![effect,{evadeArgumentum pl},{sp},{evadeArgumentum pa}]"
  | .applicaFiltratum pl t pa =>
    if pl.isEmpty then "\\![filter]"
    else s!"\\![filter,{evadeArgumentum pl},{t},{evadeArgumentum pa}]"
  | .applicaEffectum2 aid pl sp pa =>
    s!"\\![effect2,{aid},{evadeArgumentum pl},{sp},{evadeArgumentum pa}]"
  | .exploraPostam acc =>
    s!"\\![biff,{evadeArgumentum acc}]"
  | .referentiaResourcei rid =>
    s!"\\&[{evadeArgumentum rid}]"
  | .nuntiumWindowae u w l =>
    s!"\\m[{evadeArgumentum u},{evadeArgumentum w},{evadeArgumentum l}]"
  | .expectaSyncObjectum n t =>
    s!"\\![wait,syncobject,{evadeArgumentum n},{t}]"
  | .renovaPlatformam =>
    "\\![update,platform]"
  | .renovaScopum sc op =>
    if op.isEmpty then s!"\\![update,{evadeArgumentum sc}]"
    else s!"\\![update,{evadeArgumentum sc},{evadeArgumentum op}]"
  | .renovaAlium op =>
    s!"\\![updateother,{evadeArgumentum op}]"
  | .renovaSeIpsum op =>
    if op.isEmpty then "\\![updatebymyself]"
    else s!"\\![updatebymyself,{evadeArgumentum op}]"
  | .evanesceSeIpsum op =>
    if op.isEmpty then "\\![vanishbymyself]"
    else s!"\\![vanishbymyself,{evadeArgumentum op}]"
  | .creaViam =>
    "\\![create,shortcut]"

end Signaculum.Sakura
