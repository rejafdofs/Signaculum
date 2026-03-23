-- Signaculum.Notatio.Macro
-- scriptum! マクロ本體にゃん♪ 裸テクストゥスパーサもこゝにゐるにゃ

import Signaculum.Notatio.Categoria
import Signaculum.Notatio.Textus
import Signaculum.Notatio.Fons
import Signaculum.Notatio.Fenestra
import Signaculum.Notatio.Systema

namespace Signaculum.Notatio

open Lean Elab Term

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

-- ════════════════════════════════════════════════════
--  String → SakuraM 强制型變換 (Coercio)
-- ════════════════════════════════════════════════════

-- String を SakuraM に強制型変換にゃん。{}の中が String 型なら自動で loqui にくるむにゃん
instance (m : Type → Type) [Monad m] : Coe String (Signaculum.Sakura.SakuraM m Unit) where
  coe := Signaculum.Sakura.loqui

-- 中括弧で圍んだ Lean の式を直接埋め込むにゃん
syntax (priority := 50) "{" term "}" : sakuraSignum
macro_rules | `(expandSignum {$e}) => `($e)

-- \{ \} で中括弧文字をエスケープにゃん
syntax (priority := 60) "\\{" : sakuraSignum
macro_rules | `(expandSignum \{) => `(Signaculum.Sakura.loqui "{")
syntax (priority := 60) "\\}" : sakuraSignum
macro_rules | `(expandSignum \}) => `(Signaculum.Sakura.loqui "}")

-- ════════════════════════════════════════════════════
--  行先頭位置コンビナートル (Combinatrix Initii Lineae)
-- ════════════════════════════════════════════════════

-- withPosition と同じ構造で、行先頭位置を savedPos? に入れるにゃん
-- 型注釋を避けて s.pos から型推論させるにゃ
def withInitioLineae : Lean.Parser.Parser → Lean.Parser.Parser :=
  Lean.Parser.withFn fun f c s =>
    let leadPos := Id.run do
      let input := c.fileMap.source
      let pos   := s.pos
      -- fileMap から行頭位置を取得にゃ（後退スキャン不要にゃ）
      let lineNum  := (c.fileMap.toPosition pos).line
      let lineStart :=
        if h : lineNum - 1 < c.fileMap.positions.size
        then c.fileMap.positions[lineNum - 1]
        else pos
      -- 行頭から最初の非空白文字まで進むにゃ
      let mut p := lineStart
      while p.byteIdx < pos.byteIdx do
        let ch := p.get input
        if ch != ' ' && ch != '\t' then break
        p := p.next input
      return p
    Lean.Parser.adaptCacheableContextFn
      ({ · with savedPos? := leadPos }) f c s

-- ════════════════════════════════════════════════════
--  非 ASCII 裸テクストゥスパーサ (Parser Textus non ASCII)
-- ════════════════════════════════════════════════════

-- ひらがな・漢字等の非 ASCII 文字を「裸テクストゥス」として讀むにゃん
-- Char.isAlpha は ASCII 専用ゆゑ日本語は ident パーサに弾かれるにゃ
-- ASCII 文字（Lean トークン・演算子・括弧等）は全て停止→他パーサに任せるにゃ
-- @[sakuraSignum_parser] は使はず scriptumParserCore から <|> で呼ぶにゃ
private def rawTextusFn
    (c : Lean.Parser.ParserContext) (s : Lean.Parser.ParserState)
    : Lean.Parser.ParserState :=
  let startPos := s.pos
  let input    := c.fileMap.source
  -- String.Pos.Raw で積むにゃ（endPos は String.Pos 別型ゆゑ使はぬ）
  let (endPos, str) := Id.run do
    let mut p   := startPos
    let mut acc : String := ""
    while p.byteIdx < input.utf8ByteSize do
      let ch := p.get input
      -- ASCII（U+0000–U+007F）は全て停止にゃ（括弧・タグ文字・空白等をすべて回避）
      if ch.val.toNat < 128 then break
      acc := acc.push ch
      p   := p.next input
    return (p, acc)
  if endPos == startPos then
    s.mkError "expected text"
  else
    -- ident ノードとして push するにゃ（$i:ident パターンで既存ルールに乗れるにゃ）
    -- Syntax.ident で偽 ident ノードを作るにゃ（mkIdent は TSyntax ゆゑ直接 ctor を使ふにゃ）
    let identNode : Lean.Syntax :=
      Lean.Syntax.ident Lean.SourceInfo.none str.toRawSubstring (Lean.Name.mkSimple str) []
    { s with pos := endPos, stxStack := s.stxStack.push identNode }

-- @[combinator_formatter/parenthesizer] で no-op 登録にゃ
-- （@[term_parser] がフォーマッタ生成を要求するゆゑ必要にゃ）
def rawTextusSignumParser : Lean.Parser.Parser where
  info := {}
  fn   := rawTextusFn

@[combinator_formatter Signaculum.Notatio.rawTextusSignumParser]
def rawTextusSignumParser.formatter : Lean.PrettyPrinter.Formatter := pure ()

@[combinator_parenthesizer Signaculum.Notatio.rawTextusSignumParser]
def rawTextusSignumParser.parenthesizer : Lean.PrettyPrinter.Parenthesizer := pure ()

-- ════════════════════════════════════════════════════
--  scriptum! マクロ本體 (Corpus Macri)
-- ════════════════════════════════════════════════════

end Signaculum.Notatio

-- ════════════════════════════════════════════════════
--  scriptum! パーサー + エラボレーター (ネームスペース外で宣言にゃん)
-- ════════════════════════════════════════════════════

open Lean Elab Term Signaculum.Notatio

/-- SakuraScript を原形タグ記法で書けるパーサにゃん。
    行の先頭列より深いトークンだけ取り込むにゃ♪
    感嘆符あり・なし両方受け付けるにゃ（scriptum! / scriptum）-/
private def scriptumParserCore (kw : String) : Lean.Parser.Parser :=
  withInitioLineae <|
    Lean.Parser.leadingNode `scriptumMacro Lean.Parser.maxPrec <|
      Lean.Parser.symbol kw >>
      Lean.Parser.many (Lean.Parser.checkColGt "expected indent" >>
                        (Lean.Parser.categoryParser `sakuraSignum 0 <|>
                         Signaculum.Notatio.rawTextusSignumParser))

@[term_parser 1001] def scriptumTermParser  : Lean.Parser.Parser := scriptumParserCore "scriptum!"
@[term_parser 1001] def scriptumTermParser2 : Lean.Parser.Parser := scriptumParserCore "scriptum"

-- scriptumMacro ノードを展開するエラボレーターにゃん（カインドは flat `scriptumMacro にゃ）
-- stx[1] が sakuraSignum* の null ノードにゃ
@[term_elab scriptumMacro]
def elabScriptum : TermElab := fun stx expectedType? => do
  let ss := stx[1].getArgs
  if h : 0 < ss.size then
    let s0 : TSyntax `sakuraSignum := ⟨ss[0]'h⟩
    let mut body ← `(expandSignum $s0)
    for s in ss[1:] do
      let ts : TSyntax `sakuraSignum := ⟨s⟩
      body ← `(Bind.bind $body fun () => expandSignum $ts)
    elabTerm body expectedType?
  else
    elabTerm (← `(pure ())) expectedType?
