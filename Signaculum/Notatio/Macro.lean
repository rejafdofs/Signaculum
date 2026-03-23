-- Signaculum.Notatio.Macro
-- scriptum! マクロ本體にゃん♪ 裸テクストゥスパーサもこゝにゐるにゃ

import Signaculum.Notatio.Categoria
import Signaculum.Notatio.Textus
import Signaculum.Notatio.Fons
import Signaculum.Notatio.Fenestra
import Signaculum.Notatio.Systema

namespace Signaculum.Notatio

open Lean

-- ════════════════════════════════════════════════════
--  文字列リテラルス → loqui (Textus Citatus)
-- ════════════════════════════════════════════════════

-- 「"..."」で圍まれた文字列をテクストゥスとして表示にゃん
syntax (priority := 50) str : sakuraSignum
macro_rules | `(expandSignum $s:str) => `(Signaculum.Sakura.loqui $s)

-- ════════════════════════════════════════════════════
--  式埋込 (Expressio Inserta) — (expr)
-- ════════════════════════════════════════════════════

-- 括弧で圍んだ Lean の式を直接埋め込むにゃん
syntax (priority := 50) "(" term ")" : sakuraSignum
macro_rules | `(expandSignum ($e)) => `($e)

-- ════════════════════════════════════════════════════
--  scriptum! マクロ本體 (Corpus Macri)
-- ════════════════════════════════════════════════════

/-- SakuraScript を原形タグ記法で書けるマクロにゃん。
    `scriptum! \h \s[0] "こんにちは" \e` のやうに使ふにゃ♪
    型チェッカが引數の妥當性を自動檢證してくれるにゃん -/
syntax (name := scriptumMacro) withPosition("scriptum!" (colGt sakuraSignum)*) : term

macro_rules
  | `(scriptum! $[$ss:sakuraSignum]*) => do
    if ss.isEmpty then
      `(pure ())
    else
      let mut body ← `(expandSignum $(ss[0]!))
      for s in ss[1:] do
        body ← `(Bind.bind $body fun () => expandSignum $s)
      return body

end Signaculum.Notatio
