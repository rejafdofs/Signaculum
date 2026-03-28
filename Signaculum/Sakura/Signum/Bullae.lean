-- Signaculum.Sakura.Signum.Bullae
-- 吹出しシグヌムにゃん♪ バルーンの表示や畫像埋め込みを制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 吹出し制御のシグヌムにゃん。\b[n] / \_b[...] に對應するにゃ -/
inductive SignumBullae where
  | bulla (n : Nat)                          -- \b[n]（吹出しIDにゃ）
  | bullaAbsconde                            -- \b[-1]（吹出しを隱すにゃ）
  | imagoBullae (via : String) (x y : Nat)   -- \_b[via,x,y]（吹出し畫像にゃ）
  | imagoBullaeOpaca (via : String) (x y : Nat) -- \_b[via,x,y,opaque]（不透明吹出し畫像にゃ）
  | imagoBullaeInlineata (via : String)      -- \_b[via,inline]（インライン吹出し畫像にゃ）
  | imagoBullaeInlineataOpaca (via : String)  -- \_b[via,inline,opaque]（不透明インライン吹出し畫像にゃ）
  deriving Repr

/-- シグヌム・ブッラエをさくらスクリプトゥム文字列に變換するにゃん -/
def SignumBullae.adCatenam : SignumBullae → String
  | .bulla n                       => s!"\\b[{n}]"
  | .bullaAbsconde                 => "\\b[-1]"
  | .imagoBullae via x y           => s!"\\_b[{evadeArgumentum via},{x},{y}]"
  | .imagoBullaeOpaca via x y      => s!"\\_b[{evadeArgumentum via},{x},{y},opaque]"
  | .imagoBullaeInlineata via      => s!"\\_b[{evadeArgumentum via},inline]"
  | .imagoBullaeInlineataOpaca via => s!"\\_b[{evadeArgumentum via},inline,opaque]"

end Signaculum.Sakura
