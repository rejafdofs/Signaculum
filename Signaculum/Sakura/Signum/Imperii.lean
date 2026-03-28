-- Signaculum.Sakura.Signum.Imperii
-- 制御シグヌムにゃん♪ スクリプトゥムの流れを制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 制御のシグヌムにゃん。\e / \_q / \- 等に對應するにゃ -/
inductive SignumImperii where
  | finis                            -- \e（終了にゃ）
  | celer                            -- \_q（即時表示にゃ）
  | exitus                           -- \-（ゴースト退出にゃ）
  | synchrona                        -- \_s（同期切替にゃ）
  | synchronaScopi (ids : List Nat)  -- \_s[ID1,ID2,...]（スコープス同期にゃ）
  | mutaGhost                        -- \+（隨機ゴースト切替にゃ）
  | mutaGhostSequens                 -- \_+（次のゴーストにゃ）
  | prohibeTempus                    -- \*（時間切れ防止にゃ）
  | tempusCriticum                   -- \t（時間制約區劃にゃ）
  | accede                           -- \5（前面にゃ）
  | recede                           -- \4（背面にゃ）
  | syncTempus                       -- \6（時間同期にゃ）
  | eventumTempus                    -- \7（時間イヴェントゥムにゃ）
  | togglaSupra                      -- \v（最前面切替にゃ）
  | inhibeTagas                      -- \_?（タグ抑制にゃ）
  | sectionCeler (b : Bool)          -- \![quicksection,b]（クイックセクションにゃ）
  deriving Repr

def SignumImperii.adCatenam : SignumImperii → String
  | .finis            => "\\e"
  | .celer            => "\\_q"
  | .exitus           => "\\-"
  | .synchrona        => "\\_s"
  | .synchronaScopi ids => s!"\\_s[{",".intercalate (ids.map toString)}]"
  | .mutaGhost        => "\\+"
  | .mutaGhostSequens => "\\_+"
  | .prohibeTempus    => "\\*"
  | .tempusCriticum   => "\\t"
  | .accede           => "\\5"
  | .recede           => "\\4"
  | .syncTempus       => "\\6"
  | .eventumTempus    => "\\7"
  | .togglaSupra      => "\\v"
  | .inhibeTagas      => "\\_?"
  | .sectionCeler b   => s!"\\![quicksection,{if b then "true" else "false"}]"

end Signaculum.Sakura
