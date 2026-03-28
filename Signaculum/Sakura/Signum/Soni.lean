-- Signaculum.Sakura.Signum.Soni
-- 音聲シグヌムにゃん♪ 音の再生や停止、CD トラック等を制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 音聲制御のシグヌムにゃん。\_v / \8 / \![sound,...] / \__v に對應するにゃ -/
inductive SignumSoni where
  | sonus (via : String)                                    -- \_v[via]（音聲再生にゃ）
  | expectaSonum                                            -- \_V（音聲完了待ちにゃ）
  | sonus8 (via : String)                                   -- \8[via]（波形簡易再生にゃ）
  | sonusPulsus (via : String) (optiones : OptionesSoni)    -- \![sound,play,via,opts]（音聲パルススにゃ）
  | sonusOrbitans (via : String)                            -- \![sound,loop,via]（ループ再生にゃ）
  | sonusInterrumpit (via : String)                         -- \![sound,stop,via]（停止にゃ）
  | sonusPausat (via : String)                              -- \![sound,pause,via]（一時停止にゃ）
  | sonusContinuat (via : String)                           -- \![sound,resume,via]（再開にゃ）
  | sonusOneratur (via : String) (optiones : OptionesSoni)  -- \![sound,load,via,opts]（事前讀込にゃ）
  | expectaSonumPulsus                                      -- \![sound,wait]（パルスス完了待ちにゃ）
  | sonusCD (track : Nat)                                   -- \![sound,cdplay,track]（CD トラック再生にゃ）
  | sonusOptio (via : String) (optiones : OptionesSoni)     -- \![sound,option,via,opts]（オプション變更にゃ）
  | synthesisVocis (optiones : String)                      -- \__v[opts]（音聲合成にゃ）
  deriving Repr

/-- シグヌム・ソーニーをさくらスクリプトゥム文字列に變換するにゃん -/
def SignumSoni.adCatenam : SignumSoni → String
  | .sonus via              => s!"\\_v[{evadeArgumentum via}]"
  | .expectaSonum           => "\\_V"
  | .sonus8 via             => s!"\\8[{evadeArgumentum via}]"
  | .sonusPulsus via opt    =>
    let s := opt.toString
    if s.isEmpty then s!"\\![sound,play,{evadeArgumentum via}]"
    else s!"\\![sound,play,{evadeArgumentum via},{s}]"
  | .sonusOrbitans via      => s!"\\![sound,loop,{evadeArgumentum via}]"
  | .sonusInterrumpit via   => s!"\\![sound,stop,{evadeArgumentum via}]"
  | .sonusPausat via        => s!"\\![sound,pause,{evadeArgumentum via}]"
  | .sonusContinuat via     => s!"\\![sound,resume,{evadeArgumentum via}]"
  | .sonusOneratur via opt  =>
    let s := opt.toString
    if s.isEmpty then s!"\\![sound,load,{evadeArgumentum via}]"
    else s!"\\![sound,load,{evadeArgumentum via},{s}]"
  | .expectaSonumPulsus     => "\\![sound,wait]"
  | .sonusCD track          => s!"\\![sound,cdplay,{track}]"
  | .sonusOptio via opt     =>
    let s := opt.toString
    if s.isEmpty then s!"\\![sound,option,{evadeArgumentum via}]"
    else s!"\\![sound,option,{evadeArgumentum via},{s}]"
  | .synthesisVocis opt     => s!"\\__v[{evadeArgumentum opt}]"

end Signaculum.Sakura
