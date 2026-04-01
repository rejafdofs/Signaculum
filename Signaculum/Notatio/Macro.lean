-- Signaculum.Notatio.Macro
-- scriptum! マクロ本體にゃん♪ カスタムパーサー經由で全トークンを處理するにゃ

import Signaculum.Notatio.Parsitor
import Signaculum.Notatio.Expande

namespace Signaculum.Notatio

open Lean Elab Term
open Signaculum.Notatio.Parsitor

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

-- Option α → some なら exhibe、none なら無出力にゃん（非正格評價）
universe u in
instance (priority := 92) {α : Type u} {m : Type → Type} [Monad m] [Exhibibilis α m] : Exhibibilis (Option α) m where
  exhibe
    | .some a => Exhibibilis.exhibe (m := m) a
    | .none   => pure ()

-- some のとき内側の exhibe に委譲するにゃん♪ 定義から自明にゃ
universe u in
theorem exhibeOptionSome_eq {α : Type u} {m : Type → Type} [Monad m] [Exhibibilis α m]
    (a : α) : Exhibibilis.exhibe (m := m) (some a : Option α) = Exhibibilis.exhibe (m := m) a := rfl

-- none のとき無出力にゃん♪ これも定義から自明にゃ
universe u in
theorem exhibeOptionNullus_eq {m : Type → Type} [Monad m] {α : Type} [Exhibibilis α m] :
    Exhibibilis.exhibe (m := m) (.none : Option α) = pure () := rfl

-- Exhibibilis 經由の CoeDep にゃん。{expr} の型強制はぜんぶこゝを通るにゃ
universe u in
instance {α : Type u} {m : Type → Type} [Monad m] [Exhibibilis α m] (a : α) :
    CoeDep α a (Signaculum.Sakura.SakuraM m Unit) where
  coe := Exhibibilis.exhibe a

-- ════════════════════════════════════════════════════
--  行先頭位置コンビナートル (Combinatrix Initii Lineae)
-- ════════════════════════════════════════════════════

def withInitioLineae : Lean.Parser.Parser → Lean.Parser.Parser :=
  Lean.Parser.withFn fun f c s =>
    let leadPos := Id.run do
      let input := c.fileMap.source
      let pos   := s.pos
      let lineNum  := (c.fileMap.toPosition pos).line
      let lineStart :=
        if h : lineNum - 1 < c.fileMap.positions.size
        then c.fileMap.positions[lineNum - 1]
        else pos
      let mut p := lineStart
      while p.byteIdx < pos.byteIdx do
        let ch := p.get input
        if ch != ' ' && ch != '\t' then break
        p := p.next input
      return p
    Lean.Parser.adaptCacheableContextFn
      ({ · with savedPos? := leadPos }) f c s

-- ════════════════════════════════════════════════════
--  trailing 空白スキップ
-- ════════════════════════════════════════════════════

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

end Signaculum.Notatio

-- ════════════════════════════════════════════════════
--  scriptum! パーサー + エラボレーター (ネームスペース外で宣言にゃん)
-- ════════════════════════════════════════════════════

open Lean Elab Term Signaculum.Notatio Signaculum.Notatio.Parsitor Signaculum.Notatio.Expande

/-- SakuraScript を原形タグ記法で書けるパーサにゃん。
    カスタムパーサー sakuraLexemaParser で全トークンを直接パースするにゃ♪
    感嘆符あり・なし両方受け付けるにゃ（scriptum! / scriptum）-/
private def scriptumParserCore (kw : String) : Lean.Parser.Parser :=
  withInitioLineae <|
    Lean.Parser.leadingNode `scriptumMacro Lean.Parser.maxPrec <|
      Lean.Parser.symbol kw >>
      Lean.Parser.many (Lean.Parser.checkColGt "expected indent" >>
                        sakuraLexemaParser) >>
      skipTrailingWsParser

@[term_parser 1001] def scriptumTermParser  : Lean.Parser.Parser := scriptumParserCore "scriptum!"
@[term_parser 1001] def scriptumTermParser2 : Lean.Parser.Parser := scriptumParserCore "scriptum"

-- ════════════════════════════════════════════════════
--  LexemaSakurae ノード → term 變換補助
-- ════════════════════════════════════════════════════

/-- ノードの子から引數配列を取るにゃん（子[1] が nullKind ノードにゃ） -/
private def extractArgs (s : Lean.Syntax) : Array Lean.Syntax :=
  if s.getNumArgs > 1 then s[1].getArgs else #[]

/-- ノードの子[0] の atom 値を取るにゃん（タグ名・コマンド名にゃ） -/
private def extractLabel (s : Lean.Syntax) : String :=
  match s[0] with
  | .atom _ val => val
  | _ => ""

-- ════════════════════════════════════════════════════
--  scriptumMacro エラボレーター
-- ════════════════════════════════════════════════════

/-- LexemaSakurae ノードを term 構文に變換するにゃん♪
    ノードカインドでディスパッチしてから Expande 關數に委ねるにゃ -/
private def genTermLexema (s : Lean.Syntax) : TermElabM (TSyntax `term) := do
  let kind := s.getKind
  -- 裸テクストゥスにゃ
  if kind == lexemaTextusNudus then
    let identNode := s[0]
    let textus := match identNode with
      | .ident _ rawVal _ _ => rawVal.toString
      | _ => identNode.getId.toString
    let stx ← `(Signaculum.Sakura.loqui $(Lean.Syntax.mkStrLit textus))
    return ⟨stx.raw.setHeadInfo (s.getHeadInfo)⟩
  -- 文字列リテラルにゃ
  if kind == lexemaTextusLit then
    let strStx : TSyntax `str := ⟨s[0]⟩
    return ← `(Signaculum.Sakura.loqui $strStx)
  -- 式埋込にゃ
  if kind == lexemaExpressio then
    let termStx : TSyntax `term := ⟨s[0]⟩
    return ← `(($termStx : Signaculum.Sakura.SakuraM _ Unit))
  -- 環境變數にゃ
  if kind == lexemaVariabilis then
    let nomen := match s[0] with
      | .ident _ rawVal _ _ => rawVal.toString
      | _ => s[0].getId.toString
    return ← `(Signaculum.Sakura.Systema.variabilisAmbientis $(Lean.Syntax.mkStrLit nomen))
  -- バックスラッシュタグにゃ
  if kind == lexemaSignum then
    let nomen := extractLabel s
    let args := extractArgs s
    -- Textus ディスパッチにゃ
    if let some t ← expandeSignumTextus nomen args s then return t
    -- Fenestra basicum ディスパッチにゃ（\z, \_b 等）
    if let some t ← expandeSignumFenestraeBasicum nomen args s then return t
    -- Systema basicum ディスパッチにゃ（\_v, \8, \m, \__v 等）
    if let some t ← expandeSignumSystematisBasicum nomen args s then return t
    throwErrorAt s s!"未知のサクラスクリプトタグにゃ: {nomen}"
  -- 感嘆符タグにゃ
  if kind == lexemaSignumExcl then
    let imperium := extractLabel s
    let args := extractArgs s
    -- Fenestra ディスパッチにゃ
    if let some t ← expandeSignumFenestrae imperium args s then return t
    -- Systema ディスパッチにゃ
    if let some t ← expandeSignumSystematis imperium args s then return t
    throwErrorAt s s!"未知の \\![...] コマンドにゃ: {imperium}"
  -- 書體タグにゃ
  if kind == lexemaFontis then
    let clavis := extractLabel s
    let valores := extractArgs s
    if let some t ← expandeFons clavis valores s then return t
    throwErrorAt s s!"未知の \\f[...] キーにゃ: {clavis}"
  -- 未知のノードにゃ
  throwErrorAt s "未知のレクセマにゃ"

@[term_elab scriptumMacro]
def elabScriptum : TermElab := fun stx expectedType? => do
  let ss := stx[1].getArgs
  if h : 0 < ss.size then
    -- フォンティスのタブラから行番號を得るにゃん♪
    -- 異なる行のシグナム間に自動で linea（\n）を挿入するにゃ
    let tabulaFontis ← getFileMap
    let lineamSigni (s : Lean.Syntax) : Option Nat :=
      let pos? := match s.getHeadInfo with
        | .original (pos := p) .. => some p
        | .synthetic (pos := p) .. => some p
        | .none => Option.none
      pos?.map fun pos => (tabulaFontis.toPosition pos).line
    -- レクセマの term を全てリストゥスに溜めるにゃん♪
    let mut partes : Array (TSyntax `term) := #[]
    partes := partes.push (← genTermLexema (ss[0]'h))
    let mut lineaPrior := lineamSigni (ss[0]'h)
    for s in ss[1:] do
      -- 前のシグナムと行が違ったら \n を挾むにゃ
      let lineaCurrens := lineamSigni s
      match lineaPrior, lineaCurrens with
      | some lp, some lc =>
        if lc > lp then
          partes := partes.push (← `(Signaculum.Sakura.Textus.linea))
      | _, _ => pure ()
      partes := partes.push (← genTermLexema s)
      lineaPrior := lineaCurrens
    -- 右結合で畳むにゃん♪ flat な do A; B; C; D になるにゃ
    if hp : 0 < partes.size then
      let mut body := partes[partes.size - 1]'(by omega)
      for i in List.range (partes.size - 1) |>.reverse do
        if hi : i < partes.size then
          body ← `(Bind.bind $(partes[i]'hi) fun () => $body)
      elabTerm body expectedType?
    else
      elabTerm (← `(pure ())) expectedType?
  else
    elabTerm (← `(pure ())) expectedType?
