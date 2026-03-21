-- Signaculum.Sakura.SyntaxisSakuraScripti
-- SakuraScript 記法で SakuraScript を書けるやうにする構文擴張にゃん♪
-- 内部では Sakura モジュールの關數を呼ぶにゃ

import Lean
import Signaculum.Syntaxis

open Lean Elab Command Term Meta

namespace Signaculum

-- ═══════════════════════════════════════════════════
-- カスタムパーサにゃん：バックスラッシュをトークンとして扱ふ
-- ═══════════════════════════════════════════════════

declare_syntax_cat ssTag

/-- バックスラッシュ付きトークンのパーサを生成するにゃん。
    `bsSymbol "h"` は `\h` にマッチするにゃ -/
private def bsSymbol (tag : String) : Lean.Parser.Parser :=
  Lean.Parser.symbol ("\\" ++ tag)

-- ═══════════════════════════════════════════════════
-- 引数なしタグにゃん
-- ═══════════════════════════════════════════════════

@[ssTag_parser] def ssTag_h      : Lean.Parser.Parser := bsSymbol "h"
@[ssTag_parser] def ssTag_u      : Lean.Parser.Parser := bsSymbol "u"
@[ssTag_parser] def ssTag_n0     : Lean.Parser.Parser := bsSymbol "n"
@[ssTag_parser] def ssTag_c      : Lean.Parser.Parser := bsSymbol "c"
@[ssTag_parser] def ssTag_cUp    : Lean.Parser.Parser := bsSymbol "C"
@[ssTag_parser] def ssTag_x0     : Lean.Parser.Parser := bsSymbol "x"
@[ssTag_parser] def ssTag_t      : Lean.Parser.Parser := bsSymbol "t"
@[ssTag_parser] def ssTag_e      : Lean.Parser.Parser := bsSymbol "e"
@[ssTag_parser] def ssTag_minus  : Lean.Parser.Parser := bsSymbol "-"
@[ssTag_parser] def ssTag_plus   : Lean.Parser.Parser := bsSymbol "+"
@[ssTag_parser] def ssTag_star   : Lean.Parser.Parser := bsSymbol "*"
@[ssTag_parser] def ssTag_4      : Lean.Parser.Parser := bsSymbol "4"
@[ssTag_parser] def ssTag_5      : Lean.Parser.Parser := bsSymbol "5"
@[ssTag_parser] def ssTag_v      : Lean.Parser.Parser := bsSymbol "v"
@[ssTag_parser] def ssTag_6      : Lean.Parser.Parser := bsSymbol "6"
@[ssTag_parser] def ssTag_7      : Lean.Parser.Parser := bsSymbol "7"
@[ssTag_parser] def ssTag_uq     : Lean.Parser.Parser := bsSymbol "_q"
@[ssTag_parser] def ssTag_us0    : Lean.Parser.Parser := bsSymbol "_s"
@[ssTag_parser] def ssTag_uV     : Lean.Parser.Parser := bsSymbol "_V"
@[ssTag_parser] def ssTag_un     : Lean.Parser.Parser := bsSymbol "_n"
@[ssTag_parser] def ssTag_ua0    : Lean.Parser.Parser := bsSymbol "_a"
@[ssTag_parser] def ssTag_uplus  : Lean.Parser.Parser := bsSymbol "_+"
@[ssTag_parser] def ssTag_uquest : Lean.Parser.Parser := bsSymbol "_?"

-- ═══════════════════════════════════════════════════
-- 引数ありタグにゃん（\s[N], \_w[N], \p[N] 等）
-- ═══════════════════════════════════════════════════

-- \s[N] — superficies
syntax "\\s" "[" num "]" : ssTag
-- \p[N] — persona
syntax "\\p" "[" num "]" : ssTag
-- \i[N] — animatio
syntax "\\i" "[" num "]" : ssTag
-- \_w[N] — mora (ms)
syntax "\\_w" "[" num "]" : ssTag
-- \__w[N] — moraAbsoluta
syntax "\\__w" "[" num "]" : ssTag
-- \w{N} — moraCeler (0-9)
syntax "\\w" num : ssTag
-- \n[half] — dimidiaLinea
syntax "\\n" "[" "half" "]" : ssTag
-- \n[percent,N] — lineaProportionalis
syntax "\\n" "[" "percent" "," num "]" : ssTag
-- \x[noclear] — expectaSine
syntax "\\x" "[" "noclear" "]" : ssTag
-- \_a[id] — ancora
syntax "\\_a" "[" str "]" : ssTag
-- \q[titulus,signum] — optio
syntax "\\q" "[" str "," str "]" : ssTag
-- \b[N] — bulla
syntax "\\b" "[" num "]" : ssTag
-- \_b[via,x,y] — imagoBullae
syntax "\\_b" "[" str "," num "," num "]" : ssTag
-- \z[N] — zoom
syntax "\\z" "[" num "]" : ssTag
-- \_v[via] — sonus
syntax "\\_v" "[" str "]" : ssTag
-- \f[...] — format tags (open-ended: use string args)
syntax "\\f" "[" str "]" : ssTag
-- \j[nexus] — saltum
syntax "\\j" "[" str "]" : ssTag
-- \![command,...] — SHIORI command (open-ended: use string)
syntax "\\!" "[" str "]" : ssTag
-- \_l[x,y] — cursor
syntax "\\_l" "[" str "," str "]" : ssTag
-- \_u[code] — characterUnicode
syntax "\\_u" "[" str "]" : ssTag
-- \8[via] — sonus8
syntax "\\8" "[" str "]" : ssTag

-- テキスト表示にゃん
@[ssTag_parser] def ssTag_str : Lean.Parser.Parser := Lean.Parser.strLit

-- Lean 項を埋め込むにゃん（変數の挿入に使ふ）
syntax "#(" term ")" : ssTag

-- ═══════════════════════════════════════════════════
-- 本體マクロにゃん
-- ═══════════════════════════════════════════════════

syntax "sakurascriptum!" ssTag* : term

-- 後方互換テスト用にゃん
syntax "ssTest!" ssTag* : term

/-- ssTag からアクション項を生成するにゃん -/
private def ssTagToTerm (tag : TSyntax `ssTag) : MacroM (TSyntax `term) := do
  -- まず引数ありタグをパターンマッチするにゃん
  match tag with
  -- \s[N]
  | `(ssTag| \s [ $n:num ]) => `(Signaculum.Sakura.superficies $n)
  -- \p[N]
  | `(ssTag| \p [ $n:num ]) => `(Signaculum.Sakura.persona $n)
  -- \i[N]
  | `(ssTag| \i [ $n:num ]) => `(Signaculum.Sakura.animatio $n)
  -- \_w[N]
  | `(ssTag| \_w [ $n:num ]) => `(Signaculum.Sakura.mora $n)
  -- \__w[N]
  | `(ssTag| \__w [ $n:num ]) => `(Signaculum.Sakura.moraAbsoluta $n)
  -- \wN
  | `(ssTag| \w $n:num) => `(Signaculum.Sakura.moraCeler $n)
  -- \n[half]
  | `(ssTag| \n [ half ]) => `(Signaculum.Sakura.dimidiaLinea)
  -- \n[percent,N]
  | `(ssTag| \n [ percent , $n:num ]) => `(Signaculum.Sakura.lineaProportionalis $n)
  -- \x[noclear]
  | `(ssTag| \x [ noclear ]) => `(Signaculum.Sakura.expectaSine)
  -- \_a[id]
  | `(ssTag| \_a [ $s:str ]) => `(Signaculum.Sakura.ancora $s)
  -- \q[titulus,signum]
  | `(ssTag| \q [ $t:str , $s:str ]) => `(Signaculum.Sakura.optio $t $s)
  -- \b[N]
  | `(ssTag| \b [ $n:num ]) => `(Signaculum.Sakura.bulla $n)
  -- \_b[via,x,y]
  | `(ssTag| \_b [ $v:str , $x:num , $y:num ]) => `(Signaculum.Sakura.imagoBullae $v $x $y)
  -- \z[N]
  | `(ssTag| \z [ $n:num ]) => `(Signaculum.Sakura.zoom $n)
  -- \_v[via]
  | `(ssTag| \_v [ $s:str ]) => `(Signaculum.Sakura.sonus $s)
  -- \f[params] — 書式タグ（生の引數文字列を渡すにゃん）
  | `(ssTag| \f [ $s:str ]) => `(Signaculum.Sakura.crudus (String.append "\\f[" (String.append $s "]")))
  -- \j[nexus]
  | `(ssTag| \j [ $s:str ]) => `(Signaculum.Sakura.saltum $s)
  -- \![command]
  | `(ssTag| \! [ $s:str ]) => `(Signaculum.Sakura.crudus (String.append "\\![" (String.append $s "]")))
  -- \_l[x,y]
  | `(ssTag| \_l [ $x:str , $y:str ]) => `(Signaculum.Sakura.cursor $x $y)
  -- \_u[code]
  | `(ssTag| \_u [ $s:str ]) => `(Signaculum.Sakura.characterUnicode $s)
  -- \8[via]
  | `(ssTag| \8 [ $s:str ]) => `(Signaculum.Sakura.sonus8 $s)
  -- #(term) — 埋め込み項にゃん
  | `(ssTag| #( $t:term )) => pure t
  -- テキスト
  | `(ssTag| $s:str) => `(Signaculum.Sakura.loqui $s)
  | _ =>
    -- 引数なしの atom タグにゃん
    if tag.raw.isAtom then
      match tag.raw.getAtomVal with
      | "\\h"  => `(Signaculum.Sakura.sakura)
      | "\\u"  => `(Signaculum.Sakura.kero)
      | "\\n"  => `(Signaculum.Sakura.linea)
      | "\\c"  => `(Signaculum.Sakura.purga)
      | "\\C"  => `(Signaculum.Sakura.adscribe)
      | "\\x"  => `(Signaculum.Sakura.expecta)
      | "\\t"  => `(Signaculum.Sakura.tempusCriticum)
      | "\\e"  => `(Signaculum.Sakura.finis)
      | "\\-"  => `(Signaculum.Sakura.exitus)
      | "\\+"  => `(Signaculum.Sakura.mutaGhost)
      | "\\*"  => `(Signaculum.Sakura.prohibeTempus)
      | "\\4"  => `(Signaculum.Sakura.recede)
      | "\\5"  => `(Signaculum.Sakura.accede)
      | "\\v"  => `(Signaculum.Sakura.togglaSupra)
      | "\\6"  => `(Signaculum.Sakura.syncTempus)
      | "\\7"  => `(Signaculum.Sakura.eventumTempus)
      | "\\_q" => `(Signaculum.Sakura.celer)
      | "\\_s" => `(Signaculum.Sakura.synchrona)
      | "\\_V" => `(Signaculum.Sakura.expectaSonum)
      | "\\_n" => `(Signaculum.Sakura.linearisAbrogatur)
      | "\\_a" => `(Signaculum.Sakura.fineAncora)
      | "\\_+" => `(Signaculum.Sakura.mutaGhostSequens)
      | "\\_?" => `(Signaculum.Sakura.inhibeTagas)
      | other  => `(Signaculum.Sakura.crudus $(Syntax.mkStrLit other))
    else
      `(pure ())

/-- ssTag 列をチェインした項を生成するにゃん -/
private def chainStmts (stmts : Array (TSyntax `term)) : MacroM (TSyntax `term) := do
  if stmts.isEmpty then
    `((pure () : Signaculum.SakuraIO Unit))
  else
    let mut body : TSyntax `term := stmts[stmts.size - 1]!
    for i in List.range (stmts.size - 1) |>.reverse do
      let s := stmts[i]!
      body ← `(Bind.bind $s (fun _ => $body))
    pure body

macro_rules
  | `(sakurascriptum! $tags*) => do
    let stmts ← tags.mapM ssTagToTerm
    chainStmts stmts

macro_rules
  | `(ssTest! $tags*) => do
    let stmts ← tags.mapM ssTagToTerm
    chainStmts stmts

end Signaculum
