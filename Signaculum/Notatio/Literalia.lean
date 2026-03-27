-- Signaculum.Notatio.Literalia
-- リテラル構文カテゴリアにゃん♪ SakuraScript のリテラルを Lean の型に橋渡しするにゃ

import Lean
import Signaculum.Sakura.Typi

namespace Signaculum.Notatio

open Lean

-- ════════════════════════════════════════════════════
--  colorisLiteral (Coloris 型リテラル)
-- ════════════════════════════════════════════════════

/-- 色リテラルカテゴリアにゃん。SakuraScript の色形式を直接書けるやうにするにゃ。
    - `255,0,0`   → RGB 十進數
    - `#FF0000`   → 16 進數（文字始まり）
    - `"0F0F0F"`  → 16 進數（文字列リテラル、數字始まりに使ふにゃ）
    - `none`      → 無效化（Coloris.nullus）
    - `red`       → 名前付き色
    - `($e)`      → 後方互換（Lean 式）-/
declare_syntax_cat colorisLiteral

syntax num "," num "," num  : colorisLiteral
syntax "#" ident             : colorisLiteral
syntax str                   : colorisLiteral
syntax "none"                : colorisLiteral
syntax ident                 : colorisLiteral
syntax "(" term ")"          : colorisLiteral

/-- colorisLiteral を Coloris の term に展開するにゃ -/
syntax "colorisL " colorisLiteral : term

macro_rules
  | `(colorisL $r:num , $g:num , $b:num) =>
      `(Signaculum.Sakura.Coloris.rgb $r $g $b)
  | `(colorisL # $h:ident) => do
      let s : String := "#" ++ h.getId.toString
      `(Signaculum.Sakura.Coloris.hex $(Lean.Syntax.mkStrLit s))
  | `(colorisL $s:str) =>
      `(Signaculum.Sakura.Coloris.hex $s)
  | `(colorisL none) =>
      `(Signaculum.Sakura.Coloris.nullus)
  | `(colorisL $n:ident) => do
      let s : String := n.getId.toString
      `(Signaculum.Sakura.Coloris.nomen $(Lean.Syntax.mkStrLit s))
  | `(colorisL ($e)) =>
      `($e)


-- ════════════════════════════════════════════════════
--  directioAllineatioLiteral (DirectioAllineatio 型リテラル)
-- ════════════════════════════════════════════════════

/-- 文字揃リテラルカテゴリアにゃん。left/right/center/justify で書けるにゃ -/
declare_syntax_cat directioAllineatioLiteral

syntax "left"    : directioAllineatioLiteral
syntax "right"   : directioAllineatioLiteral
syntax "center"  : directioAllineatioLiteral
syntax "justify" : directioAllineatioLiteral
syntax "(" term ")" : directioAllineatioLiteral

syntax "directioAllineatioL " directioAllineatioLiteral : term

macro_rules
  | `(directioAllineatioL left)    => `(Signaculum.Sakura.DirectioAllineatio.sinistrum)
  | `(directioAllineatioL right)   => `(Signaculum.Sakura.DirectioAllineatio.dextrum)
  | `(directioAllineatioL center)  => `(Signaculum.Sakura.DirectioAllineatio.centrum)
  | `(directioAllineatioL justify) => `(Signaculum.Sakura.DirectioAllineatio.contentum)
  | `(directioAllineatioL ($e))    => `($e)


-- ════════════════════════════════════════════════════
--  directioVerticalisLiteral (DirectioVerticalis 型リテラル)
-- ════════════════════════════════════════════════════

/-- 縦方向リテラルカテゴリアにゃん。top/middle/bottom で書けるにゃ -/
declare_syntax_cat directioVerticalisLiteral

syntax "top"    : directioVerticalisLiteral
syntax "middle" : directioVerticalisLiteral
syntax "bottom" : directioVerticalisLiteral
syntax "(" term ")" : directioVerticalisLiteral

syntax "directioVerticalisL " directioVerticalisLiteral : term

macro_rules
  | `(directioVerticalisL top)    => `(Signaculum.Sakura.DirectioVerticalis.summum)
  | `(directioVerticalisL middle) => `(Signaculum.Sakura.DirectioVerticalis.medium)
  | `(directioVerticalisL bottom) => `(Signaculum.Sakura.DirectioVerticalis.imum)
  | `(directioVerticalisL ($e))   => `($e)


-- ════════════════════════════════════════════════════
--  formaMarciLiteral (FormaMarci 型リテラル)
-- ════════════════════════════════════════════════════

/-- マーカー形状リテラルカテゴリアにゃん。square/underline/none/default で書けるにゃ -/
declare_syntax_cat formaMarciLiteral

-- square+underline は + を含むため高優先度で宣言するにゃ
syntax (priority := high) "square" "+" "underline" : formaMarciLiteral
syntax "square"    : formaMarciLiteral
syntax "underline" : formaMarciLiteral
syntax "none"      : formaMarciLiteral
syntax "default"   : formaMarciLiteral
syntax "(" term ")" : formaMarciLiteral

syntax "formaMarciL " formaMarciLiteral : term

macro_rules
  | `(formaMarciL square + underline) => `(Signaculum.Sakura.FormaMarci.utrumque)
  | `(formaMarciL square)             => `(Signaculum.Sakura.FormaMarci.quadratum)
  | `(formaMarciL underline)          => `(Signaculum.Sakura.FormaMarci.sublineaForma)
  | `(formaMarciL none)               => `(Signaculum.Sakura.FormaMarci.nullus)
  | `(formaMarciL default)            => `(Signaculum.Sakura.FormaMarci.praefinitus)
  | `(formaMarciL ($e))               => `($e)


-- ════════════════════════════════════════════════════
--  methodusMarciLiteral (MethodusMarci 型リテラル)
-- ════════════════════════════════════════════════════

/-- マーカー描畫方法リテラルカテゴリアにゃん。xor/alpha/normal/default で書けるにゃ -/
declare_syntax_cat methodusMarciLiteral

syntax "xor"     : methodusMarciLiteral
syntax "alpha"   : methodusMarciLiteral
syntax "normal"  : methodusMarciLiteral
syntax "default" : methodusMarciLiteral
syntax "(" term ")" : methodusMarciLiteral

syntax "methodusMarciL " methodusMarciLiteral : term

macro_rules
  | `(methodusMarciL xor)     => `(Signaculum.Sakura.MethodusMarci.xor)
  | `(methodusMarciL alpha)   => `(Signaculum.Sakura.MethodusMarci.alpha)
  | `(methodusMarciL normal)  => `(Signaculum.Sakura.MethodusMarci.normal)
  | `(methodusMarciL default) => `(Signaculum.Sakura.MethodusMarci.praefinitus)
  | `(methodusMarciL ($e))    => `($e)

end Signaculum.Notatio
