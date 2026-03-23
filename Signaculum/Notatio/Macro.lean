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

-- クォートなし識別子をテクストゥスとして表示にゃん（例: scriptum! こんにちは）
syntax (priority := 40) ident : sakuraSignum
macro_rules | `(expandSignum $i:ident) => `(Signaculum.Sakura.loqui $(Lean.Syntax.mkStrLit i.getId.toString))

-- ════════════════════════════════════════════════════
--  式埋込 (Expressio Inserta) — (expr)
-- ════════════════════════════════════════════════════

-- 中括弧で圍んだ Lean の式を直接埋め込むにゃん
syntax (priority := 50) "{" term "}" : sakuraSignum
macro_rules | `(expandSignum {$e}) => `($e)

-- \{ \} で中括弧文字をエスケープにゃん
syntax (priority := 60) "\\{" : sakuraSignum
macro_rules | `(expandSignum \{) => `(Signaculum.Sakura.loqui "{")
syntax (priority := 60) "\\}" : sakuraSignum
macro_rules | `(expandSignum \}) => `(Signaculum.Sakura.loqui "}")

-- ════════════════════════════════════════════════════
--  scriptum! マクロ本體 (Corpus Macri)
-- ════════════════════════════════════════════════════

/-- SakuraScript を原形タグ記法で書けるマクロにゃん。
    `scriptum! \h \s[0] "こんにちは" \e` のやうに使ふにゃ♪
    型チェッカが引數の妥當性を自動檢證してくれるにゃん -/
syntax (name := scriptumMacro) withPosition("scriptum!" (colGt sakuraSignum)*) : term

macro_rules
  | `(scriptum! $[$ss:sakuraSignum]*) => do
    if h : 0 < ss.size then
      let mut body ← `(expandSignum $(ss[0]'h))
      for s in ss[1:] do
        body ← `(Bind.bind $body fun () => expandSignum $s)
      return body
    else
      `(pure ())

end Signaculum.Notatio
