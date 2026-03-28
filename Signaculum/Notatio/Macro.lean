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

-- 中括弧で圍んだ Lean の式を直接埋め込むにゃん
-- show で期待型を明示することで IO α 等のモナド値の CoeDep 強制変換を起動するにゃ
syntax (priority := 50) "{" term "}" : sakuraSignum
macro_rules | `(expandSignum {$e}) => `(($e : Signaculum.Sakura.SakuraM _ Unit))

-- \{ \} で中括弧文字をエスケープにゃん
syntax (priority := 60) "\\{" : sakuraSignum
macro_rules | `(expandSignum \{) => `(Signaculum.Sakura.loqui "{")
syntax (priority := 60) "\\}" : sakuraSignum
macro_rules | `(expandSignum \}) => `(Signaculum.Sakura.loqui "}")

-- % 環境變數參照にゃん（SSP が展開する %month 等）
-- `loqui` は `%` をエスケープしてしまふから專用構文が要るにゃ
syntax (priority := 60) "%" ident : sakuraSignum
macro_rules | `(expandSignum %$i:ident) => `(Signaculum.Sakura.variabilisAmbientis $(Lean.Syntax.mkStrLit i.getId.toString))

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
--  裸テクストゥスパーサ (Parser Textus Nudus)
-- ════════════════════════════════════════════════════

-- SakuraScript タグ開始文字にゃ（これらに遭遇したら停止して categoryParser に委ねるにゃん）
-- \ → タグ接頭辭、" → 文字列リテラル、{ } → 式埋込、% → 環境變數、) ] → 括弧閉ぢ
private def estInitiumTagi (ch : Char) : Bool :=
  ch == '\\' || ch == '"' || ch == '{' || ch == '}' || ch == '%' ||
  ch == ')' || ch == ']'

-- scriptum ブロック內の裸テクストゥスを讀むにゃん♪
-- タグ開始文字と空白以外の全ての文字をテクストゥスとして積むにゃ
-- まづ空白を飛ばし、次にタグ開始文字でも空白でもにゃい文字を連續して讀むにゃ
-- @[sakuraSignum_parser] は使はず scriptumParserCore から <|> で呼ぶにゃ
private def rawTextusFn
    (c : Lean.Parser.ParserContext) (s : Lean.Parser.ParserState)
    : Lean.Parser.ParserState :=
  let input    := c.fileMap.source
  -- まづ空白を飛ばすにゃん（Lean の標準トークナイザと同樣の振舞ひにゃ）
  let wsEnd := Id.run do
    let mut p := s.pos
    while p.byteIdx < input.utf8ByteSize do
      let ch := p.get input
      if ch != ' ' && ch != '\t' && ch != '\n' && ch != '\r' then break
      p := p.next input
    return p
  -- テクストゥス本體を讀むにゃ（空白・タグ開始文字で停止にゃん）
  let startPos := wsEnd
  let (endPos, str) := Id.run do
    let mut p   := startPos
    let mut acc : String := ""
    while p.byteIdx < input.utf8ByteSize do
      let ch := p.get input
      if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' then break
      if estInitiumTagi ch then break
      acc := acc.push ch
      p   := p.next input
    return (p, acc)
  if endPos == startPos then
    -- 失敗時は元の位置（s.pos）を保つにゃん — <|> が回復できるやうにするにゃ
    s.mkError "expected text"
  else
    -- ident ノードとして push するにゃ（ソース位置を付けてホバー情報が出るにゃ）
    let identNode : Lean.Syntax :=
      Lean.Syntax.ident (Lean.SourceInfo.synthetic startPos endPos) str.toRawSubstring (Lean.Name.mkSimple str) []
    -- 後續空白を消費するにゃん（行跨ぎ判定は SourceInfo の位置で行ふから大丈夫にゃ）
    let finalPos := Id.run do
      let mut p := endPos
      while p.byteIdx < input.utf8ByteSize do
        let ch := p.get input
        if ch != ' ' && ch != '\t' && ch != '\n' && ch != '\r' then break
        p := p.next input
      return p
    { s with pos := finalPos, stxStack := s.stxStack.push identNode }

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

open Lean Elab Term Meta Signaculum.Notatio

/-- SakuraScript を原形タグ記法で書けるパーサにゃん。
    行の先頭列より深いトークンだけ取り込むにゃ♪
    感嘆符あり・なし両方受け付けるにゃ（scriptum! / scriptum）-/
private def scriptumParserCore (kw : String) : Lean.Parser.Parser :=
  withInitioLineae <|
    Lean.Parser.leadingNode `scriptumMacro Lean.Parser.maxPrec <|
      Lean.Parser.symbol kw >>
      Lean.Parser.many (Lean.Parser.checkColGt "expected indent" >>
                        (Signaculum.Notatio.rawTextusSignumParser <|>
                         Lean.Parser.categoryParser `sakuraSignum 0)) >>
      skipTrailingWsParser

@[term_parser 1001] def scriptumTermParser  : Lean.Parser.Parser := scriptumParserCore "scriptum!"
@[term_parser 1001] def scriptumTermParser2 : Lean.Parser.Parser := scriptumParserCore "scriptum"

-- scriptumMacro ノードを展開するエラボレーターにゃん（カインドは flat `scriptumMacro にゃ）
-- stx[1] が sakuraSignum* の null ノードにゃ
-- rawTextusFn が積んだ生 ident ノード（isIdent = true）は直接 loqui に変換にゃ
-- sakuraSignum ラッパーを持つ正規ノードは expandSignum 経由にゃ
-- 各タグを個別にエラボレートしてホバー情報を登録するにゃん♪

/-- 二つの SakuraM アクションを順次結合する Expr を作るにゃん。
    Bind.bind a (fun () => b) に相當するにゃ -/
private def mkSequentia (a b : Expr) : TermElabM Expr := do
  let lam := Expr.lam `_ (mkConst ``Unit) b .default
  mkAppM ``Bind.bind #[a, lam]

@[term_elab scriptumMacro]
def elabScriptum : TermElab := fun stx expectedType? => do
  let ss := stx[1].getArgs
  -- 各シグナムノードを term 構文に變換するにゃ
  let genTermStx (s : Lean.Syntax) : Lean.Elab.Term.TermElabM (TSyntax `term) := do
    if s.isIdent then
      -- rawTextusFn 由來の裸 ident にゃ → rawVal から直接文字列を取るにゃん（guillemet 回避）
      let textus := match s with
        | .ident _ rawVal _ _ => rawVal.toString
        | _ => s.getId.toString  -- 到達しにゃいはずにゃが安全策にゃ
      `(Signaculum.Sakura.loqui $(Lean.Syntax.mkStrLit textus))
    else
      let ts : TSyntax `sakuraSignum := ⟨s⟩
      `(expandSignum $ts)
  -- 單一シグナムをエラボレートしてホバー情報を登録するにゃん
  -- withRef で元のタグ構文の位置を參照點にし、addTermInfo でホバーを紐づけるにゃ
  let elabUnum (s : Lean.Syntax) : TermElabM Expr := do
    let termStx ← genTermStx s
    let expr ← withRef s <| elabTerm termStx none
    addTermInfo s expr
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
    let mut result ← elabUnum (ss[0]'h)
    let mut lineaPrior := lineamSigni (ss[0]'h)
    for s in ss[1:] do
      -- 前のシグナムと行が違ったら \n を挾むにゃ
      let lineaCurrens := lineamSigni s
      match lineaPrior, lineaCurrens with
      | some lp, some lc =>
        if lc > lp then
          let lineaExpr ← elabTerm (← `(Signaculum.Sakura.linea)) none
          result ← mkSequentia result lineaExpr
      | _, _ => pure ()
      let nextExpr ← elabUnum s
      result ← mkSequentia result nextExpr
      lineaPrior := lineaCurrens
    ensureHasType expectedType? result
  else
    elabTerm (← `(pure ())) expectedType?
