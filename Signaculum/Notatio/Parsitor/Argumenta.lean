-- Signaculum.Notatio.Parsitor.Argumenta
-- 括弧内引數パーサーの補助關數にゃん♪
-- [] 内の , 區切り要素を汎用パースするにゃ

import Lean

namespace Signaculum.Notatio.Parsitor

open Lean Parser

-- ════════════════════════════════════════════════════
--  補助: 空白スキップ
-- ════════════════════════════════════════════════════

/-- scriptum ブロック内の空白を飛ばすにゃん（改行含む） -/
def skipWsFn (c : ParserContext) (s : ParserState) : ParserState :=
  let input := c.fileMap.source
  let pos := Id.run do
    let mut p := s.pos
    while p.byteIdx < input.utf8ByteSize do
      let ch := p.get input
      if ch != ' ' && ch != '\t' && ch != '\n' && ch != '\r' then break
      p := p.next input
    return p
  { s with pos := pos }

-- ════════════════════════════════════════════════════
--  ident 讀取補助
-- ════════════════════════════════════════════════════

/-- 英數字・ドット・ハイフン・アンダースコアを連續で讀んで ident ノードを積むにゃん
    讀めなかったらエラーにゃ -/
private def legeIdentFn (c : ParserContext) (s : ParserState) : ParserState :=
  let input := c.fileMap.source
  let startPos := s.pos
  let endPos := Id.run do
    let mut p := startPos
    while p.byteIdx < input.utf8ByteSize do
      let ch := p.get input
      if ch.isAlphanum || ch == '.' || ch == '-' || ch == '_' then
        p := p.next input
      else break
    return p
  if endPos == startPos then
    s.mkError "引數が期待されてゐますにゃ"
  else
    let sub : Substring.Raw := ⟨input, startPos, endPos⟩
    let str := sub.toString
    let identNode := Syntax.ident (SourceInfo.synthetic startPos endPos) str.toRawSubstring (Name.mkSimple str) []
    { s with pos := endPos, stxStack := s.stxStack.push identNode }

-- ════════════════════════════════════════════════════
--  括弧附き term パーサー
-- ════════════════════════════════════════════════════

/-- "(" term ")" をパースするにゃ。開き括弧は既に確認濟みで pos が '(' にゃん -/
private def legeParenTermFn (c : ParserContext) (s : ParserState) : ParserState :=
  let input := c.fileMap.source
  -- '(' を消費にゃ（atom は積まない — term の中に含まれるにゃ）
  let s := { s with pos := s.pos.next input }
  let s := skipWsFn c s
  let s := (termParser maxPrec).fn c s
  if s.hasError then s
  else
    let s := skipWsFn c s
    if s.pos.byteIdx >= input.utf8ByteSize || s.pos.get input != ')' then
      s.mkError "')' が期待されてゐますにゃ"
    else
      { s with pos := s.pos.next input }

-- ════════════════════════════════════════════════════
--  符號附き數値パーサー
-- ════════════════════════════════════════════════════

/-- +num / -num をパースするにゃ。pos が '+' or '-' にゃん -/
private def legeSignedNumFn (c : ParserContext) (s : ParserState) : ParserState :=
  let input := c.fileMap.source
  let ch := s.pos.get input
  let nextPos := s.pos.next input
  if nextPos.byteIdx < input.utf8ByteSize && (nextPos.get input).isDigit then
    -- 符號を atom として積むにゃ
    let signAtom := mkAtom (SourceInfo.synthetic s.pos nextPos) (String.singleton ch)
    let s := { s with pos := nextPos, stxStack := s.stxStack.push signAtom }
    numLitFn c s
  else
    -- 符號の後に數字がないなら ident として讀むにゃ
    legeIdentFn c s

-- ════════════════════════════════════════════════════
--  單一引數パーサー
-- ════════════════════════════════════════════════════

/-- 單一の引數要素をパースするにゃん♪
    numLit → strLit → (term) → 符號附き數値 → ident の優先順で試行するにゃ
    パーサーの中でだけ有效だから none 等のキーワード衝突は起きにゃいにゃ -/
def argumentumFn (c : ParserContext) (s : ParserState) : ParserState :=
  let input := c.fileMap.source
  let s := skipWsFn c s
  if s.pos.byteIdx >= input.utf8ByteSize then
    s.mkError "引數が期待されてゐますにゃ"
  else
    let ch := s.pos.get input
    if ch.isDigit then numLitFn c s
    else if ch == '"' then strLitFn c s
    else if ch == '(' then legeParenTermFn c s
    else if ch == '+' || ch == '-' then legeSignedNumFn c s
    else legeIdentFn c s

-- ════════════════════════════════════════════════════
--  括弧内引數リストパーサー
-- ════════════════════════════════════════════════════

/-- 殘りの , 區切り引數を讀み、']' で閉ぢて nullKind にまとめるにゃ -/
partial def legeRestantiaArgumenta (nomenTagi : String) (c : ParserContext) (s : ParserState) (stackSz : Nat)
    : ParserState :=
  let input := c.fileMap.source
  let s := skipWsFn c s
  if s.pos.byteIdx < input.utf8ByteSize && s.pos.get input == ',' then
    let s := { s with pos := s.pos.next input }
    let s := skipWsFn c s
    let s := argumentumFn c s
    if s.hasError then
      s.mkError s!"{nomenTagi}: 引數が不正にゃ"
    else
      legeRestantiaArgumenta nomenTagi c s stackSz
  else if s.pos.byteIdx < input.utf8ByteSize && s.pos.get input == ']' then
    let s := { s with pos := s.pos.next input }
    let args := s.stxStack.extract stackSz s.stxStack.size
    let s := { s with stxStack := s.stxStack.shrink stackSz }
    let argsNode := Syntax.node SourceInfo.none nullKind args
    { s with stxStack := s.stxStack.push argsNode }
  else
    s.mkError s!"{nomenTagi}: , か ] が期待されてゐますにゃ"

/-- `[` arg1 `,` arg2 `,` ... `]` をパースして引數の nullKind ノードを積むにゃん♪
    nomenTagi はエラーメッセージ用のタグ名にゃ -/
def argumentaInUncisFn (nomenTagi : String) (c : ParserContext) (s : ParserState)
    : ParserState :=
  let input := c.fileMap.source
  let s := skipWsFn c s
  if s.pos.byteIdx >= input.utf8ByteSize || s.pos.get input != '[' then
    s.mkError s!"{nomenTagi}: '[' が期待されてゐますにゃ"
  else
    let s := { s with pos := s.pos.next input }
    let s := skipWsFn c s
    if s.pos.byteIdx < input.utf8ByteSize && s.pos.get input == ']' then
      let argsNode := Syntax.node SourceInfo.none nullKind #[]
      { s with pos := s.pos.next input, stxStack := s.stxStack.push argsNode }
    else
      let stackSz := s.stxStack.size
      let s := argumentumFn c s
      if s.hasError then
        s.mkError s!"{nomenTagi}: 引數が不正にゃ"
      else
        legeRestantiaArgumenta nomenTagi c s stackSz

end Signaculum.Notatio.Parsitor
