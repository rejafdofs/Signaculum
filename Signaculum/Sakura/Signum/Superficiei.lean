-- Signaculum.Sakura.Signum.Superficiei
-- 表面制御シグヌムにゃん♪ 表情やアニマーティオを切り替へるにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura.Signum

/-- 表面制御のシグヌムにゃん。\\s[n] / \\i[n] に對應するにゃ -/
inductive SignumSuperficiei where
  | superficies (n : Nat)     -- \\s[n]（表面IDにゃ）
  | superficiesAbsconde       -- \\s[-1]（表面を隱すにゃ）
  | animatio (n : Nat)        -- \\i[n]（アニマーティオ再生にゃ）
  | animatioExpecta (n : Nat) -- \\i[n,wait]（アニマーティオ再生して待つにゃ）
  deriving Repr

def SignumSuperficiei.adCatenam : SignumSuperficiei → String
  | .superficies n       => s!"\\s[{n}]"
  | .superficiesAbsconde => "\\s[-1]"
  | .animatio n          => s!"\\i[{n}]"
  | .animatioExpecta n   => s!"\\i[{n},wait]"

end Signaculum.Sakura.Signum
