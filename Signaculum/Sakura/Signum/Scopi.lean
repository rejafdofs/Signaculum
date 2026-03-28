-- Signaculum.Sakura.Signum.Scopi
-- 範圍制御シグヌムにゃん♪ 誰が喋るかを決めるにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 範圍制御のシグヌムにゃん。\\h / \\u / \\p[n] に對應するにゃ -/
inductive SignumScopi where
  | sakura              -- \\h（主人格にゃ）
  | kero                -- \\u（副人格にゃ）
  | persona (n : Nat)   -- \\p[n]（第n人格にゃ）
  deriving Repr

def SignumScopi.adCatenam : SignumScopi → String
  | .sakura    => "\\h"
  | .kero      => "\\u"
  | .persona n => s!"\\p[{n}]"

end Signaculum.Sakura
