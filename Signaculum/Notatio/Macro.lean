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

-- SakuraM m Unit → そのまゝ返すにゃん（恆等インスタンスゥス）
instance (priority := 105) {m : Type → Type} [Monad m] : Exhibibilis (Signaculum.Sakura.SakuraM m Unit) m where
  exhibe a := a

theorem exhibeSakuraM_eq {m : Type → Type} [Monad m] (a : Signaculum.Sakura.SakuraM m Unit) :
    Exhibibilis.exhibe (m := m) a = a := rfl

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
        if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' then
          p := p.next input
        else if ch == '-' && (p.next input).byteIdx < input.utf8ByteSize
                          && (p.next input).get input == '-' then
          -- --コメントを行末までスキップするにゃ
          p := p.next input; p := p.next input
          while p.byteIdx < input.utf8ByteSize do
            if (p.get input) == '\n' then
              p := p.next input; break
            p := p.next input
        else if ch == '/' && (p.next input).byteIdx < input.utf8ByteSize
                          && (p.next input).get input == '-' then
          -- /- -/ ブロックコメントをスキップするにゃ（ネスト非對應）
          p := p.next input; p := p.next input
          while p.byteIdx < input.utf8ByteSize do
            let ch := p.get input
            if ch == '-' && (p.next input).byteIdx < input.utf8ByteSize
                         && (p.next input).get input == '/' then
              p := p.next input; p := p.next input; break
            p := p.next input
        else break
      return p
    { s with pos := newPos }

def skipTrailingWsParser : Lean.Parser.Parser where
  info := {}
  fn   := skipTrailingWsFn

@[combinator_formatter Signaculum.Notatio.skipTrailingWsParser]
def skipTrailingWsParser.formatter : Lean.PrettyPrinter.Formatter := pure ()

@[combinator_parenthesizer Signaculum.Notatio.skipTrailingWsParser]
def skipTrailingWsParser.parenthesizer : Lean.PrettyPrinter.Parenthesizer := pure ()

/-- scriptum ブロック用のカスタム繰返しにゃん♪
    Lean の many はビルトイン ws skipper がコメントを飛ばしてしまふので、
    改行・コメントで確實に止まるカスタムループを使ふにゃ -/
private def manyLexemaFn : Lean.Parser.ParserFn := fun c s =>
  let input := c.fileMap.source
  let startPos := s.pos
  let sz := s.stxStack.size
  let rec loop (s : Lean.Parser.ParserState) : Nat → Lean.Parser.ParserState
    | 0 => s
    | n + 1 =>
      let sWs := Parsitor.skipWsFn c s
      if sWs.pos.byteIdx >= input.utf8ByteSize then s
      else
        let ch := sWs.pos.get input
        -- Lean コメント（-- / /- ）で停止するにゃ
        if ch == '-' && (sWs.pos.next input).byteIdx < input.utf8ByteSize then
          let ch2 := (sWs.pos.next input).get input
          if ch2 == '-' || ch2 == '/' then s  -- -- コメント
          else s  -- 孤立した - もスクリプトゥムでは不正にゃ
        else if ch == '/' && (sWs.pos.next input).byteIdx < input.utf8ByteSize
                          && (sWs.pos.next input).get input == '-' then s  -- /- コメント
        else
          let col := (c.fileMap.toPosition sWs.pos).column
          let refCol := match c.savedPos? with
            | some p => (c.fileMap.toPosition p).column
            | none   => 0
          if col <= refCol then s
          else
            let szInner := s.stxStack.size
            let s := Parsitor.sakuraLexemaFn c sWs
            if s.hasError then
              { s with pos := sWs.pos, stxStack := s.stxStack.shrink szInner, errorMsg := .none }
            else loop s n
  let s := loop s 10000
  let nodes := s.stxStack.extract sz s.stxStack.size
  let manyNode := Lean.Syntax.node (Lean.SourceInfo.synthetic startPos s.pos) Lean.nullKind nodes
  { s with stxStack := s.stxStack.shrink sz |>.push manyNode }

def manyLexemaParser : Lean.Parser.Parser where
  info := {}
  fn := manyLexemaFn

@[combinator_formatter Signaculum.Notatio.manyLexemaParser]
def manyLexemaParser.formatter : Lean.PrettyPrinter.Formatter := pure ()

@[combinator_parenthesizer Signaculum.Notatio.manyLexemaParser]
def manyLexemaParser.parenthesizer : Lean.PrettyPrinter.Parenthesizer := pure ()

end Signaculum.Notatio

-- ════════════════════════════════════════════════════
--  scriptum! パーサー + エラボレーター (ネームスペース外で宣言にゃん)
-- ════════════════════════════════════════════════════

open Lean Elab Term Signaculum.Notatio Signaculum.Notatio.Parsitor Signaculum.Notatio.Expande

private def scriptumParserCore (kw : String) : Lean.Parser.Parser :=
  withInitioLineae <|
    Lean.Parser.leadingNode `scriptumMacro Lean.Parser.maxPrec <|
      Lean.Parser.symbol kw >>
      manyLexemaParser >>
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

-- ════════════════════════════════════════════════════
--  %property[...] 糖衣構文解決 (Resolutio Proprietatis)
-- ════════════════════════════════════════════════════

/-- ジェネリックサブプロパティ名を解決するにゃん♪ -/
private def resolveProprietasGenerica (suffix : String) (stx : Lean.Syntax)
    : TermElabM (TSyntax `term) := do
  match suffix with
  | "name"        => `(Signaculum.Sakura.ProprietasGenerica.nomen)
  | "sakuraname"  => `(Signaculum.Sakura.ProprietasGenerica.sakuraNomen)
  | "keroname"    => `(Signaculum.Sakura.ProprietasGenerica.keroNomen)
  | "craftmanw"   => `(Signaculum.Sakura.ProprietasGenerica.fabricator)
  | "craftmanurl" => `(Signaculum.Sakura.ProprietasGenerica.fabricatorNexus)
  | "path"        => `(Signaculum.Sakura.ProprietasGenerica.via)
  | "thumbnail"   => `(Signaculum.Sakura.ProprietasGenerica.imago)
  | "homeurl"     => `(Signaculum.Sakura.ProprietasGenerica.nexusAedis)
  | "username"    => `(Signaculum.Sakura.ProprietasGenerica.nomenUtentis)
  | "index"       => `(Signaculum.Sakura.ProprietasGenerica.index)
  | "icon"        => `(Signaculum.Sakura.ProprietasGenerica.icon)
  | _ => throwErrorAt stx s!"未知のジェネリックサブプロパティにゃ: {suffix}"

/-- スコープサブプロパティ名を解決するにゃん♪ -/
private def resolveProprietasScopus (suffix : String) (stx : Lean.Syntax)
    : TermElabM (TSyntax `term) := do
  match suffix with
  | "surface.num"            => `(Signaculum.Sakura.ProprietasScopus.superficiesNum)
  | "surface.x"              => `(Signaculum.Sakura.ProprietasScopus.superficiesX)
  | "surface.y"              => `(Signaculum.Sakura.ProprietasScopus.superficiesY)
  | "seriko.defaultsurface"  => `(Signaculum.Sakura.ProprietasScopus.serikoSuperficiesPraef)
  | "x"                      => `(Signaculum.Sakura.ProprietasScopus.x)
  | "y"                      => `(Signaculum.Sakura.ProprietasScopus.y)
  | "rect"                   => `(Signaculum.Sakura.ProprietasScopus.rect)
  | "name"                   => `(Signaculum.Sakura.ProprietasScopus.nomen)
  | _ => throwErrorAt stx s!"未知のスコープサブプロパティにゃ: {suffix}"

/-- バルーンスコープサブプロパティ名を解決するにゃん♪ -/
private def resolveProprietasBullaeScopus (suffix : String) (stx : Lean.Syntax)
    : TermElabM (TSyntax `term) := do
  match suffix with
  | "num"              => `(Signaculum.Sakura.ProprietasBullaeScopus.numerus)
  | "validwidth"       => `(Signaculum.Sakura.ProprietasBullaeScopus.latitudo)
  | "validwidth.initial" => `(Signaculum.Sakura.ProprietasBullaeScopus.latitudoInitialis)
  | "validheight"      => `(Signaculum.Sakura.ProprietasBullaeScopus.altitudo)
  | "validheight.initial" => `(Signaculum.Sakura.ProprietasBullaeScopus.altitudoInitialis)
  | "lines"            => `(Signaculum.Sakura.ProprietasBullaeScopus.linea)
  | "lines.initial"    => `(Signaculum.Sakura.ProprietasBullaeScopus.lineaInitialis)
  | "basepos.x"        => `(Signaculum.Sakura.ProprietasBullaeScopus.basePosX)
  | "basepos.y"        => `(Signaculum.Sakura.ProprietasBullaeScopus.basePosY)
  | "char_width"       => `(Signaculum.Sakura.ProprietasBullaeScopus.latitudoCharacteris)
  | _ => throwErrorAt stx s!"未知のバルーンスコープサブプロパティにゃ: {suffix}"

/-- rateofuse サブプロパティ名を解決するにゃん♪ -/
private def resolveProprietasRateOfUse (suffix : String) (stx : Lean.Syntax)
    : TermElabM (TSyntax `term) := do
  match suffix with
  | "name"       => `(Signaculum.Sakura.ProprietasRateOfUse.nomen)
  | "sakuraname" => `(Signaculum.Sakura.ProprietasRateOfUse.sakuraNomen)
  | "keroname"   => `(Signaculum.Sakura.ProprietasRateOfUse.keroNomen)
  | "boottime"   => `(Signaculum.Sakura.ProprietasRateOfUse.numerusStartuporum)
  | "bootminute" => `(Signaculum.Sakura.ProprietasRateOfUse.minutae)
  | "percent"    => `(Signaculum.Sakura.ProprietasRateOfUse.proportio)
  | _ => throwErrorAt stx s!"未知の rateofuse サブプロパティにゃ: {suffix}"

/-- 文字列の指定位置以降を String として取り出すにゃん♪
    String.drop は Slice を返すから、toString で變換するにゃ -/
private def stringDropToString (s : String) (n : Nat) : String :=
  (s.drop n).toString

/-- 文字列を指定文字で前後に分割するにゃん♪ 最初の出現位置で切るにゃ -/
private def splitAtChar (s : String) (ch : Char) : Option (String × String) := Id.run do
  let chars := s.toList
  let mut before : List Char := []
  let mut rest := chars
  while true do
    match rest with
    | [] => return .none
    | c :: cs =>
      if c == ch then
        return .some (before.reverse |> String.ofList, cs |> String.ofList)
      before := c :: before
      rest := cs
  return .none

/-- "prefix(name).suffix" からパレンの中身とサフィクスを抽出するにゃん♪
    prefixLen の長さ分だけ先頭をスキップして '(' を探すにゃ -/
private def extractNomenEtSuffix (s : String) (prefixLen : Nat)
    : Option (String × String) := do
  let rest := stringDropToString s prefixLen
  if rest.front? != some '(' then .none
  let inner := stringDropToString rest 1  -- '(' の後にゃ
  -- ')' で分割にゃ
  let (nomen, afterParen) ← splitAtChar inner ')'
  -- '.' を期待にゃ
  if afterParen.front? != some '.' then .none
  let suffix := stringDropToString afterParen 1
  .some (nomen, suffix)

/-- "prefix.index(n).suffix" からインデックスとサフィクスを抽出するにゃん♪ -/
private def extractIndexEtSuffix (s : String) (prefixLen : Nat)
    : Option (Nat × String) := do
  let rest := stringDropToString s prefixLen
  if !rest.startsWith ".index(" then .none
  let inner := stringDropToString rest 7  -- ".index(" の後にゃ
  let (numStr, afterParen) ← splitAtChar inner ')'
  let n ← numStr.toNat?
  if afterParen.front? != some '.' then .none
  let suffix := stringDropToString afterParen 1
  .some (n, suffix)

/-- "prefix.current.suffix" からサフィクスを抽出するにゃん♪ -/
private def extractCurrentSuffix (s : String) (prefixLen : Nat)
    : Option String := do
  let rest := stringDropToString s prefixLen
  if !rest.startsWith ".current." then .none
  .some (stringDropToString rest 9)

/-- ジェネリックリスト系プロパティを解決するにゃん♪
    ghostlist / activeghostlist / balloonlist 等の共通パターンにゃ -/
private def resolveListaGenerica (nomen : String) (praefixum : String)
    (mkNomen : TSyntax `term → TSyntax `term → TermElabM (TSyntax `term))
    (mkIndex : TSyntax `term → TSyntax `term → TermElabM (TSyntax `term))
    (mkCurrent : TSyntax `term → TermElabM (TSyntax `term))
    (stx : Lean.Syntax) : TermElabM (Option (TSyntax `term)) := do
  if let some (n, suffix) := extractNomenEtSuffix nomen praefixum.length then
    let sub ← resolveProprietasGenerica suffix stx
    let nLit := Lean.Syntax.mkStrLit n
    some <$> mkNomen nLit sub
  else if let some (i, suffix) := extractIndexEtSuffix nomen praefixum.length then
    let sub ← resolveProprietasGenerica suffix stx
    let iLit := Lean.Syntax.mkNumLit (toString i)
    some <$> mkIndex iLit sub
  else if let some suffix := extractCurrentSuffix nomen praefixum.length then
    let sub ← resolveProprietasGenerica suffix stx
    some <$> mkCurrent sub
  else
    return .none

/-- プロパティパス文字列を Proprietas コンストラクタ構文に解決するにゃん♪
    scriptum マクロの %property[...] 糖衣構文で使ふにゃ -/
private def resolveNomenProprietatis (nomen : String) (stx : Lean.Syntax)
    : TermElabM (TSyntax `term) := do
  -- ── 靜的プロパティ（パラメータ無し）にゃ ──
  match nomen with
  -- system.*
  | "system.year"           => return ← `(Signaculum.Sakura.Proprietas.systemAnnus)
  | "system.month"          => return ← `(Signaculum.Sakura.Proprietas.systemMensis)
  | "system.day"            => return ← `(Signaculum.Sakura.Proprietas.systemDies)
  | "system.hour"           => return ← `(Signaculum.Sakura.Proprietas.systemHora)
  | "system.minute"         => return ← `(Signaculum.Sakura.Proprietas.systemMinutum)
  | "system.second"         => return ← `(Signaculum.Sakura.Proprietas.systemSecundum)
  | "system.millisecond"    => return ← `(Signaculum.Sakura.Proprietas.systemMillisecundum)
  | "system.dayofweek"      => return ← `(Signaculum.Sakura.Proprietas.systemDiesSeptimanus)
  | "system.cursor.pos"     => return ← `(Signaculum.Sakura.Proprietas.systemCursorPositio)
  | "system.os.type"        => return ← `(Signaculum.Sakura.Proprietas.systemOsTypus)
  | "system.os.name"        => return ← `(Signaculum.Sakura.Proprietas.systemOsNomen)
  | "system.os.version"     => return ← `(Signaculum.Sakura.Proprietas.systemOsVersione)
  | "system.os.build"       => return ← `(Signaculum.Sakura.Proprietas.systemOsCompilatio)
  | "system.os.parenttype"  => return ← `(Signaculum.Sakura.Proprietas.systemOsParensTypus)
  | "system.os.parentname"  => return ← `(Signaculum.Sakura.Proprietas.systemOsParensNomen)
  | "system.cpu.load"       => return ← `(Signaculum.Sakura.Proprietas.systemCpuOnus)
  | "system.cpu.num"        => return ← `(Signaculum.Sakura.Proprietas.systemCpuNumerus)
  | "system.cpu.vendor"     => return ← `(Signaculum.Sakura.Proprietas.systemCpuVendor)
  | "system.cpu.name"       => return ← `(Signaculum.Sakura.Proprietas.systemCpuNomen)
  | "system.cpu.clock"      => return ← `(Signaculum.Sakura.Proprietas.systemCpuPulsus)
  | "system.cpu.features"   => return ← `(Signaculum.Sakura.Proprietas.systemCpuFunctiones)
  | "system.memory.load"    => return ← `(Signaculum.Sakura.Proprietas.systemMemoriaOnus)
  | "system.memory.phyt"    => return ← `(Signaculum.Sakura.Proprietas.systemMemoriaPhysicaTota)
  | "system.memory.phya"    => return ← `(Signaculum.Sakura.Proprietas.systemMemoriaPhysicaLibera)
  -- baseware.*
  | "baseware.version"      => return ← `(Signaculum.Sakura.Proprietas.basewereVersione)
  | "baseware.name"         => return ← `(Signaculum.Sakura.Proprietas.basewereNomen)
  -- ghostlist.count
  | "ghostlist.count"       => return ← `(Signaculum.Sakura.Proprietas.ghostlistNumerus)
  -- currentghost 靜的にゃ
  | "currentghost.status"   => return ← `(Signaculum.Sakura.Proprietas.currentghostStatus)
  | "currentghost.scope.count" => return ← `(Signaculum.Sakura.Proprietas.currentghostScopusNumerus)
  -- currentghost.shelllist.count
  | "currentghost.shelllist.count" => return ← `(Signaculum.Sakura.Proprietas.currentghostShelllistNumerus)
  -- currentghost.balloon.count
  | "currentghost.balloon.count" => return ← `(Signaculum.Sakura.Proprietas.currentghostBullaeNumerus)
  -- currentghost mousecursor
  | "currentghost.mousecursor"        => return ← `(Signaculum.Sakura.Proprietas.currentghostCursorMus)
  | "currentghost.mousecursor.text"   => return ← `(Signaculum.Sakura.Proprietas.currentghostCursorTextus)
  | "currentghost.mousecursor.wait"   => return ← `(Signaculum.Sakura.Proprietas.currentghostCursorExspecto)
  | "currentghost.mousecursor.hand"   => return ← `(Signaculum.Sakura.Proprietas.currentghostCursorManus)
  | "currentghost.mousecursor.grip"   => return ← `(Signaculum.Sakura.Proprietas.currentghostCursorPrehendo)
  | "currentghost.mousecursor.arrow"  => return ← `(Signaculum.Sakura.Proprietas.currentghostCursorSagitta)
  | "currentghost.balloon.mousecursor"        => return ← `(Signaculum.Sakura.Proprietas.currentghostBullaeCursorMus)
  | "currentghost.balloon.mousecursor.text"   => return ← `(Signaculum.Sakura.Proprietas.currentghostBullaeCursorTextus)
  | "currentghost.balloon.mousecursor.wait"   => return ← `(Signaculum.Sakura.Proprietas.currentghostBullaeCursorExspecto)
  | "currentghost.balloon.mousecursor.arrow"  => return ← `(Signaculum.Sakura.Proprietas.currentghostBullaeCursorSagitta)
  -- currentghost seriko
  | "currentghost.seriko.surfacelist.all"     => return ← `(Signaculum.Sakura.Proprietas.currentghostSerikoSurfacesOmnes)
  | "currentghost.seriko.surfacelist.defined" => return ← `(Signaculum.Sakura.Proprietas.currentghostSerikoSurfacesDefinitae)
  -- balloonlist.count / headlinelist.count / pluginlist.count
  | "balloonlist.count"     => return ← `(Signaculum.Sakura.Proprietas.balloonlistNumerus)
  | "headlinelist.count"    => return ← `(Signaculum.Sakura.Proprietas.headlinelistNumerus)
  | "pluginlist.count"      => return ← `(Signaculum.Sakura.Proprietas.pluginlistNumerus)
  -- history.*.count
  | "history.ghost.count"    => return ← `(Signaculum.Sakura.Proprietas.historyGhostNumerus)
  | "history.balloon.count"  => return ← `(Signaculum.Sakura.Proprietas.historyBullaeNumerus)
  | "history.headline.count" => return ← `(Signaculum.Sakura.Proprietas.historyHeadlineNumerus)
  | "history.plugin.count"   => return ← `(Signaculum.Sakura.Proprietas.historyPluginNumerus)
  | _ => pure ()
  -- ── パラメータ付きプロパティにゃ ──
  -- ghostlist(name).* / ghostlist.index(n).* / ghostlist.current.*
  if nomen.startsWith "ghostlist" && !nomen.startsWith "ghostlist." || nomen.startsWith "ghostlist." then
    if let some r ← resolveListaGenerica nomen "ghostlist"
        (fun n sub => `(Signaculum.Sakura.Proprietas.ghostlistNomen $n $sub))
        (fun i sub => `(Signaculum.Sakura.Proprietas.ghostlistIndex $i $sub))
        (fun sub   => `(Signaculum.Sakura.Proprietas.ghostlistCurrent $sub))
        stx then
      return r
  -- activeghostlist(name).* / .index(n).* / .current.*
  if nomen.startsWith "activeghostlist" then
    if let some r ← resolveListaGenerica nomen "activeghostlist"
        (fun n sub => `(Signaculum.Sakura.Proprietas.activeghostlistNomen $n $sub))
        (fun i sub => `(Signaculum.Sakura.Proprietas.activeghostlistIndex $i $sub))
        (fun sub   => `(Signaculum.Sakura.Proprietas.activeghostlistCurrent $sub))
        stx then
      return r
  -- currentghost generic: currentghost.name 等にゃ
  if nomen.startsWith "currentghost." then
    -- currentghost.scope(n).* — ProprietasScopus にゃ
    if nomen.startsWith "currentghost.scope(" then
      let inner := stringDropToString nomen 20  -- "currentghost.scope(" の後にゃ
      if let some (numStr, afterParen) := splitAtChar inner ')' then
        if let some n := numStr.toNat? then
          if afterParen.startsWith "." then
            let suffix := stringDropToString afterParen 1
            let sub ← resolveProprietasScopus suffix stx
            let nLit := Lean.Syntax.mkNumLit (toString n)
            return ← `(Signaculum.Sakura.Proprietas.currentghostScopus $nLit $sub)
    -- currentghost.shelllist(name).* / .index(n).* / .current.*
    if nomen.startsWith "currentghost.shelllist" then
      if let some (n, suffix) := extractNomenEtSuffix nomen "currentghost.shelllist".length then
        let sub ← resolveProprietasGenerica suffix stx
        let nLit := Lean.Syntax.mkStrLit n
        return ← `(Signaculum.Sakura.Proprietas.currentghostShelllistNomen $nLit $sub)
      if let some (i, suffix) := extractIndexEtSuffix nomen "currentghost.shelllist".length then
        let sub ← resolveProprietasGenerica suffix stx
        let iLit := Lean.Syntax.mkNumLit (toString i)
        return ← `(Signaculum.Sakura.Proprietas.currentghostShelllistIndex $iLit $sub)
      if let some suffix := extractCurrentSuffix nomen "currentghost.shelllist".length then
        let sub ← resolveProprietasGenerica suffix stx
        return ← `(Signaculum.Sakura.Proprietas.currentghostShelllistCurrent $sub)
    -- currentghost.balloon.scope(n).* — ProprietasBullaeScopus にゃ
    if nomen.startsWith "currentghost.balloon.scope(" then
      let inner := stringDropToString nomen 27  -- "currentghost.balloon.scope(" の後にゃ
      if let some (numStr, afterParen) := splitAtChar inner ')' then
        if let some n := numStr.toNat? then
          if afterParen.startsWith "." then
            let suffix := stringDropToString afterParen 1
            if suffix == "count" then
              let nLit := Lean.Syntax.mkNumLit (toString n)
              return ← `(Signaculum.Sakura.Proprietas.currentghostBullaeScopusNumerus $nLit)
            else
              let sub ← resolveProprietasBullaeScopus suffix stx
              let nLit := Lean.Syntax.mkNumLit (toString n)
              return ← `(Signaculum.Sakura.Proprietas.currentghostBullaeScopus $nLit $sub)
    -- currentghost.balloon.* (generic)
    if nomen.startsWith "currentghost.balloon." then
      let suffix := stringDropToString nomen 21
      -- 既に處理濟みの balloon.count / balloon.mousecursor* / balloon.scope* は上で返すにゃ
      -- 殘りは generic にゃ
      if !suffix.startsWith "mousecursor" && !suffix.startsWith "scope" && suffix != "count" then
        let sub ← resolveProprietasGenerica suffix stx
        return ← `(Signaculum.Sakura.Proprietas.currentghostBullaeGenerica $sub)
    -- currentghost.* (generic) — 上で處理されなかった殘りにゃ
    let suffix := stringDropToString nomen 13  -- "currentghost." の後にゃ
    if !suffix.startsWith "scope" && !suffix.startsWith "shelllist" && !suffix.startsWith "balloon"
       && !suffix.startsWith "mousecursor" && !suffix.startsWith "seriko"
       && suffix != "status" then
      let sub ← resolveProprietasGenerica suffix stx
      return ← `(Signaculum.Sakura.Proprietas.currentghostGenerica $sub)
  -- balloonlist(name).* / .index(n).*
  if nomen.startsWith "balloonlist" && nomen != "balloonlist.count" then
    if let some (n, suffix) := extractNomenEtSuffix nomen "balloonlist".length then
      let sub ← resolveProprietasGenerica suffix stx
      let nLit := Lean.Syntax.mkStrLit n
      return ← `(Signaculum.Sakura.Proprietas.balloonlistNomen $nLit $sub)
    if let some (i, suffix) := extractIndexEtSuffix nomen "balloonlist".length then
      let sub ← resolveProprietasGenerica suffix stx
      let iLit := Lean.Syntax.mkNumLit (toString i)
      return ← `(Signaculum.Sakura.Proprietas.balloonlistIndex $iLit $sub)
  -- headlinelist(name).* / .index(n).*
  if nomen.startsWith "headlinelist" && nomen != "headlinelist.count" then
    if let some (n, suffix) := extractNomenEtSuffix nomen "headlinelist".length then
      let sub ← resolveProprietasGenerica suffix stx
      let nLit := Lean.Syntax.mkStrLit n
      return ← `(Signaculum.Sakura.Proprietas.headlinelistNomen $nLit $sub)
    if let some (i, suffix) := extractIndexEtSuffix nomen "headlinelist".length then
      let sub ← resolveProprietasGenerica suffix stx
      let iLit := Lean.Syntax.mkNumLit (toString i)
      return ← `(Signaculum.Sakura.Proprietas.headlinelistIndex $iLit $sub)
  -- pluginlist(name).* / .index(n).*
  if nomen.startsWith "pluginlist" && nomen != "pluginlist.count" then
    if let some (n, suffix) := extractNomenEtSuffix nomen "pluginlist".length then
      let sub ← resolveProprietasGenerica suffix stx
      let nLit := Lean.Syntax.mkStrLit n
      return ← `(Signaculum.Sakura.Proprietas.pluginlistNomen $nLit $sub)
    if let some (i, suffix) := extractIndexEtSuffix nomen "pluginlist".length then
      let sub ← resolveProprietasGenerica suffix stx
      let iLit := Lean.Syntax.mkNumLit (toString i)
      return ← `(Signaculum.Sakura.Proprietas.pluginlistIndex $iLit $sub)
  -- history.ghost(name).* / .index(n).*
  if nomen.startsWith "history.ghost" && nomen != "history.ghost.count" then
    if let some (n, suffix) := extractNomenEtSuffix nomen "history.ghost".length then
      let sub ← resolveProprietasGenerica suffix stx
      let nLit := Lean.Syntax.mkStrLit n
      return ← `(Signaculum.Sakura.Proprietas.historyGhostNomen $nLit $sub)
    if let some (i, suffix) := extractIndexEtSuffix nomen "history.ghost".length then
      let sub ← resolveProprietasGenerica suffix stx
      let iLit := Lean.Syntax.mkNumLit (toString i)
      return ← `(Signaculum.Sakura.Proprietas.historyGhostIndex $iLit $sub)
  -- history.balloon(name).* / .index(n).*
  if nomen.startsWith "history.balloon" && nomen != "history.balloon.count" then
    if let some (n, suffix) := extractNomenEtSuffix nomen "history.balloon".length then
      let sub ← resolveProprietasGenerica suffix stx
      let nLit := Lean.Syntax.mkStrLit n
      return ← `(Signaculum.Sakura.Proprietas.historyBullaeNomen $nLit $sub)
    if let some (i, suffix) := extractIndexEtSuffix nomen "history.balloon".length then
      let sub ← resolveProprietasGenerica suffix stx
      let iLit := Lean.Syntax.mkNumLit (toString i)
      return ← `(Signaculum.Sakura.Proprietas.historyBullaeIndex $iLit $sub)
  -- history.headline(name).* / .index(n).*
  if nomen.startsWith "history.headline" && nomen != "history.headline.count" then
    if let some (n, suffix) := extractNomenEtSuffix nomen "history.headline".length then
      let sub ← resolveProprietasGenerica suffix stx
      let nLit := Lean.Syntax.mkStrLit n
      return ← `(Signaculum.Sakura.Proprietas.historyHeadlineNomen $nLit $sub)
    if let some (i, suffix) := extractIndexEtSuffix nomen "history.headline".length then
      let sub ← resolveProprietasGenerica suffix stx
      let iLit := Lean.Syntax.mkNumLit (toString i)
      return ← `(Signaculum.Sakura.Proprietas.historyHeadlineIndex $iLit $sub)
  -- history.plugin(name).* / .index(n).*
  if nomen.startsWith "history.plugin" && nomen != "history.plugin.count" then
    if let some (n, suffix) := extractNomenEtSuffix nomen "history.plugin".length then
      let sub ← resolveProprietasGenerica suffix stx
      let nLit := Lean.Syntax.mkStrLit n
      return ← `(Signaculum.Sakura.Proprietas.historyPluginNomen $nLit $sub)
    if let some (i, suffix) := extractIndexEtSuffix nomen "history.plugin".length then
      let sub ← resolveProprietasGenerica suffix stx
      let iLit := Lean.Syntax.mkNumLit (toString i)
      return ← `(Signaculum.Sakura.Proprietas.historyPluginIndex $iLit $sub)
  -- rateofuselist(name).* / .index(n).*
  if nomen.startsWith "rateofuselist" then
    if let some (n, suffix) := extractNomenEtSuffix nomen "rateofuselist".length then
      let sub ← resolveProprietasRateOfUse suffix stx
      let nLit := Lean.Syntax.mkStrLit n
      return ← `(Signaculum.Sakura.Proprietas.rateofuselistNomen $nLit $sub)
    if let some (i, suffix) := extractIndexEtSuffix nomen "rateofuselist".length then
      let sub ← resolveProprietasRateOfUse suffix stx
      let iLit := Lean.Syntax.mkNumLit (toString i)
      return ← `(Signaculum.Sakura.Proprietas.rateofuselistIndex $iLit $sub)
  -- shiori.*
  if nomen.startsWith "shiori." then
    let varNomen := stringDropToString nomen 7
    let nLit := Lean.Syntax.mkStrLit varNomen
    return ← `(Signaculum.Sakura.Proprietas.shioriVariabilis $nLit)
  -- 未知にゃ
  throwErrorAt stx s!"未知のプロパティ名にゃ: {nomen}"

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
  -- プロパティ引用（Lean term）にゃ
  if kind == lexemaProprietasCitata then
    let termStx : TSyntax `term := ⟨s[0]⟩
    return ← `(Signaculum.Sakura.Systema.proprietasCitata $termStx)
  -- プロパティ引用（糖衣構文）にゃ
  if kind == lexemaProprietasCitataNomen then
    let nomen := match s[0] with
      | .atom _ val => val
      | _ => ""
    let propTerm ← resolveNomenProprietatis nomen s
    return ← `(Signaculum.Sakura.Systema.proprietasCitata $propTerm)
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
