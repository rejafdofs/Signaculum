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
--  表示可能型クラス (Classis Exhibibilis)
-- ════════════════════════════════════════════════════

-- SakuraM に埋め込み可能な型のクラスにゃん♪
-- {expr} で使へる型はぜんぶこゝに集まるにゃ
universe u in
class Exhibibilis (α : Type u) (m : Type → Type) [Monad m] where
  exhibe : α → Signaculum.Sakura.SakuraM m Unit

-- String → loqui にゃん
instance (priority := 100) {m : Type → Type} [Monad m] : Exhibibilis String m where
  exhibe := Signaculum.Sakura.loqui

-- m String → 實行して loqui にゃん
instance (priority := 90) {m : Type → Type} [Monad m] : Exhibibilis (m String) m where
  exhibe action := do
    let v ← liftM action
    Signaculum.Sakura.loqui v

-- IO.Ref α → ref.get して toString して loqui にゃん（IO 專用）
instance (priority := 85) {α : Type} [ToString α] : Exhibibilis (IO.Ref α) IO where
  exhibe (ref : IO.Ref α) := do
    let v : α ← liftM (show IO α from ST.Ref.get ref)
    Signaculum.Sakura.loqui (toString v)

-- m α [ToString α] → 實行して toString して loqui にゃん
instance (priority := 80) {α : Type} {m : Type → Type} [Monad m] [ToString α] : Exhibibilis (m α) m where
  exhibe action := do
    let v ← liftM action
    Signaculum.Sakura.loqui (toString v)

-- α [ToString α] → toString して loqui にゃん（最汎用、最低優先）
instance (priority := 70) {α : Type} {m : Type → Type} [Monad m] [ToString α] : Exhibibilis α m where
  exhibe a := Signaculum.Sakura.loqui (toString a)

-- Array α → ランダムに1要素選んで exhibe にゃん（IO.rand が要るから IO 專用）
universe u in
instance (priority := 95) {α : Type u} [Exhibibilis α IO] : Exhibibilis (Array α) IO where
  exhibe (a : Array α) := do
    if h : a.size = 0 then pure ()
    else
      let n := a.size
      let idx ← liftM (IO.rand 0 (n - 1))
      let i : Fin n := ⟨idx % n, Nat.mod_lt idx (by omega)⟩
      Exhibibilis.exhibe (m := IO) a[i]

-- List α → toArray してランダムに1要素選んで exhibe にゃん（IO 專用）
universe u in
instance (priority := 95) {α : Type u} [Exhibibilis α IO] : Exhibibilis (List α) IO where
  exhibe (l : List α) := do
    let a : Array α := List.toArray l
    if h : a.size = 0 then pure ()
    else
      let n := a.size
      let idx ← liftM (IO.rand 0 (n - 1))
      let i : Fin n := ⟨idx % n, Nat.mod_lt idx (by omega)⟩
      Exhibibilis.exhibe (m := IO) a[i]

-- Exhibibilis 經由の CoeDep にゃん。{expr} の型強制はぜんぶこゝを通るにゃ
universe u in
instance {α : Type u} {m : Type → Type} [Monad m] [Exhibibilis α m] (a : α) :
    CoeDep α a (Signaculum.Sakura.SakuraM m Unit) where
  coe := Exhibibilis.exhibe a

-- 中括弧で圍んだ Lean の式を直接埋め込むにゃん
-- show で期待型を明示することで IO α 等のモナド値の CoeDep 強制変換を起動するにゃ
syntax (priority := 50) "{" term "}" : sakuraSignum
macro_rules | `(expandSignum {$e}) => `(($e : Signaculum.Sakura.SakuraM _ Unit))

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
    -- Syntax.ident で偽 ident ノードを作るにゃ（ソース位置を付けてホバー情報が出るにゃ）
    let identNode : Lean.Syntax :=
      Lean.Syntax.ident (Lean.SourceInfo.synthetic startPos endPos) str.toRawSubstring (Lean.Name.mkSimple str) []
    { s with pos := endPos, stxStack := s.stxStack.push identNode }

-- @[combinator_formatter/parenthesizer] で no-op 登録にゃ
-- （@[term_parser] がフォーマッタ生成を要求するゆゑ必要にゃ）
def rawTextusSignumParser : Lean.Parser.Parser where
  info := {}
  fn   := rawTextusFn

-- many 後の trailing 空白を讀み飛ばして pos を次の非空白文字の先頭に進めるにゃ
-- stxStack には何も積まないにゃ（scriptumMacro ノードの構造を變へないにゃ）
-- many が終はった後 pos が \n（行末・高カラム）に留まるせゐで
-- doIfThenElse の else カラムチェックが失敗するのを防ぐにゃ
private def skipTrailingWsFn : Lean.Parser.ParserFn :=
  fun c s =>
    let input  := c.fileMap.source
    let newPos := Id.run do
      let mut p := s.pos
      while p.byteIdx < input.utf8ByteSize do
        let ch := p.get input
        if ch != ' ' && ch != '\t' && ch != '\n' && ch != '\r' then break
        p := p.next input
      return p
    { s with pos := newPos }

def skipTrailingWsParser : Lean.Parser.Parser where
  info := {}
  fn   := skipTrailingWsFn

@[combinator_formatter Signaculum.Notatio.skipTrailingWsParser]
def skipTrailingWsParser.formatter : Lean.PrettyPrinter.Formatter := pure ()

@[combinator_parenthesizer Signaculum.Notatio.skipTrailingWsParser]
def skipTrailingWsParser.parenthesizer : Lean.PrettyPrinter.Parenthesizer := pure ()

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
                         Signaculum.Notatio.rawTextusSignumParser)) >>
      skipTrailingWsParser

@[term_parser 1001] def scriptumTermParser  : Lean.Parser.Parser := scriptumParserCore "scriptum!"
@[term_parser 1001] def scriptumTermParser2 : Lean.Parser.Parser := scriptumParserCore "scriptum"

-- scriptumMacro ノードを展開するエラボレーターにゃん（カインドは flat `scriptumMacro にゃ）
-- stx[1] が sakuraSignum* の null ノードにゃ
-- rawTextusFn が積んだ生 ident ノード（isIdent = true）は直接 loqui に変換にゃ
-- sakuraSignum ラッパーを持つ正規ノードは expandSignum 経由にゃ
@[term_elab scriptumMacro]
def elabScriptum : TermElab := fun stx expectedType? => do
  let ss := stx[1].getArgs
  -- 各シグナムノードを term に變換するにゃ
  let genTerm (s : Lean.Syntax) : Lean.Elab.Term.TermElabM (TSyntax `term) := do
    if s.isIdent then
      -- rawTextusFn 由來の裸 ident にゃ → 識別子名をテクストゥスとして直接 loqui にくるむにゃ
      `(Signaculum.Sakura.loqui $(Lean.Syntax.mkStrLit s.getId.toString))
    else
      let ts : TSyntax `sakuraSignum := ⟨s⟩
      `(expandSignum $ts)
  if h : 0 < ss.size then
    -- フォンティスのタブラから行番號を得るにゃん♪
    -- 異なる行のシグナム間に自動で linea（\n）を挿入するにゃ
    let tabulaFontis ← getFileMap
    let lineamSigni (s : Lean.Syntax) : Option Nat :=
      let pos? := match s.getHeadInfo with
        | .original (pos := p) .. => some p
        | .synthetic (pos := p) .. => some p
        | .none => none
      pos?.map fun pos => (tabulaFontis.toPosition pos).line
    let mut body ← genTerm (ss[0]'h)
    let mut lineaPrior := lineamSigni (ss[0]'h)
    for s in ss[1:] do
      -- 前のシグナムと行が違ったら \n を挾むにゃ
      let lineaCurrens := lineamSigni s
      match lineaPrior, lineaCurrens with
      | some lp, some lc =>
        if lc > lp then
          body ← `(Bind.bind $body fun () => Signaculum.Sakura.linea)
      | _, _ => pure ()
      let next ← genTerm s
      body ← `(Bind.bind $body fun () => $next)
      lineaPrior := lineaCurrens
    elabTerm body expectedType?
  else
    elabTerm (← `(pure ())) expectedType?
