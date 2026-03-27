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
syntax "default"             : colorisLiteral
syntax "disable"             : colorisLiteral
syntax (priority := high) "default" "." "anchor"          : colorisLiteral
syntax (priority := high) "default" "." "anchornotselect" : colorisLiteral
syntax (priority := high) "default" "." "anchorvisited"   : colorisLiteral
syntax (priority := high) "default" "." "cursor"          : colorisLiteral
syntax (priority := high) "default" "." "cursornotselect" : colorisLiteral
syntax (priority := high) "default" "." "plain"           : colorisLiteral
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
  | `(colorisL default . anchor) =>
      `(Signaculum.Sakura.Coloris.praefinitusAncorae)
  | `(colorisL default . anchornotselect) =>
      `(Signaculum.Sakura.Coloris.praefinitusAncoraeNonElectae)
  | `(colorisL default . anchorvisited) =>
      `(Signaculum.Sakura.Coloris.praefinitusAncoraeVisae)
  | `(colorisL default . cursor) =>
      `(Signaculum.Sakura.Coloris.praefinitusCursoris)
  | `(colorisL default . cursornotselect) =>
      `(Signaculum.Sakura.Coloris.praefinitusCursorisNonElecti)
  | `(colorisL default . plain) =>
      `(Signaculum.Sakura.Coloris.praefinitusPlanus)
  | `(colorisL default) =>
      `(Signaculum.Sakura.Coloris.praefinitus)
  | `(colorisL disable) =>
      `(Signaculum.Sakura.Coloris.inhabilis)
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

/-- マーカー描畫方法リテラルカテゴリアにゃん。
    Win32 SetROP2 の全モード + SSP 擴張 (xor/alpha/normal/default) で書けるにゃ -/
declare_syntax_cat methodusMarciLiteral

-- Win32 SetROP2 モードにゃん
syntax "black"       : methodusMarciLiteral
syntax "notmergepen" : methodusMarciLiteral
syntax "masknotpen"  : methodusMarciLiteral
syntax "notcopypen"  : methodusMarciLiteral
syntax "maskpennot"  : methodusMarciLiteral
syntax "not"         : methodusMarciLiteral
syntax "xorpen"      : methodusMarciLiteral
syntax "notmaskpen"  : methodusMarciLiteral
syntax "maskpen"     : methodusMarciLiteral
syntax "notxorpen"   : methodusMarciLiteral
syntax "nop"         : methodusMarciLiteral
syntax "mergenotpen" : methodusMarciLiteral
syntax "copypen"     : methodusMarciLiteral
syntax "mergepennot" : methodusMarciLiteral
syntax "mergepen"    : methodusMarciLiteral
syntax "white"       : methodusMarciLiteral
-- SSP 擴張にゃん
syntax "xor"     : methodusMarciLiteral
syntax "alpha"   : methodusMarciLiteral
syntax "normal"  : methodusMarciLiteral
syntax "default" : methodusMarciLiteral
syntax "(" term ")" : methodusMarciLiteral

syntax "methodusMarciL " methodusMarciLiteral : term

macro_rules
  | `(methodusMarciL black)       => `(Signaculum.Sakura.MethodusMarci.black)
  | `(methodusMarciL notmergepen) => `(Signaculum.Sakura.MethodusMarci.notmergepen)
  | `(methodusMarciL masknotpen)  => `(Signaculum.Sakura.MethodusMarci.masknotpen)
  | `(methodusMarciL notcopypen)  => `(Signaculum.Sakura.MethodusMarci.notcopypen)
  | `(methodusMarciL maskpennot)  => `(Signaculum.Sakura.MethodusMarci.maskpennot)
  | `(methodusMarciL not)         => `(Signaculum.Sakura.MethodusMarci.not)
  | `(methodusMarciL xorpen)      => `(Signaculum.Sakura.MethodusMarci.xorpen)
  | `(methodusMarciL notmaskpen)  => `(Signaculum.Sakura.MethodusMarci.notmaskpen)
  | `(methodusMarciL maskpen)     => `(Signaculum.Sakura.MethodusMarci.maskpen)
  | `(methodusMarciL notxorpen)   => `(Signaculum.Sakura.MethodusMarci.notxorpen)
  | `(methodusMarciL nop)         => `(Signaculum.Sakura.MethodusMarci.nop)
  | `(methodusMarciL mergenotpen) => `(Signaculum.Sakura.MethodusMarci.mergenotpen)
  | `(methodusMarciL copypen)     => `(Signaculum.Sakura.MethodusMarci.copypen)
  | `(methodusMarciL mergepennot) => `(Signaculum.Sakura.MethodusMarci.mergepennot)
  | `(methodusMarciL mergepen)    => `(Signaculum.Sakura.MethodusMarci.mergepen)
  | `(methodusMarciL white)       => `(Signaculum.Sakura.MethodusMarci.white)
  | `(methodusMarciL xor)         => `(Signaculum.Sakura.MethodusMarci.xor)
  | `(methodusMarciL alpha)       => `(Signaculum.Sakura.MethodusMarci.alpha)
  | `(methodusMarciL normal)      => `(Signaculum.Sakura.MethodusMarci.normal)
  | `(methodusMarciL default)     => `(Signaculum.Sakura.MethodusMarci.praefinitus)
  | `(methodusMarciL ($e))        => `($e)


-- ════════════════════════════════════════════════════
--  stylusUmbraeLiteral (StylusUmbrae 型リテラル)
-- ════════════════════════════════════════════════════

/-- 文字影スタイルリテラルカテゴリアにゃん。offset/outline/default で書けるにゃ -/
declare_syntax_cat stylusUmbraeLiteral

syntax "offset"  : stylusUmbraeLiteral
syntax "outline" : stylusUmbraeLiteral
syntax "default" : stylusUmbraeLiteral
syntax "(" term ")" : stylusUmbraeLiteral

syntax "stylusUmbraeL " stylusUmbraeLiteral : term

macro_rules
  | `(stylusUmbraeL offset)  => `(Signaculum.Sakura.StylusUmbrae.offset)
  | `(stylusUmbraeL outline) => `(Signaculum.Sakura.StylusUmbrae.contornus)
  | `(stylusUmbraeL default) => `(Signaculum.Sakura.StylusUmbrae.praefinitus)
  | `(stylusUmbraeL ($e))    => `($e)


-- ════════════════════════════════════════════════════
--  statusContorniLiteral (StatusContorni 型リテラル)
-- ════════════════════════════════════════════════════

/-- 文字輪郭リテラルカテゴリアにゃん。true/false/default/disable で書けるにゃ -/
declare_syntax_cat statusContorniLiteral

syntax "true"    : statusContorniLiteral
syntax "false"   : statusContorniLiteral
syntax "default" : statusContorniLiteral
syntax "disable" : statusContorniLiteral
syntax "(" term ")" : statusContorniLiteral

syntax "statusContorniL " statusContorniLiteral : term

macro_rules
  | `(statusContorniL true)    => `(Signaculum.Sakura.StatusContorni.activus)
  | `(statusContorniL false)   => `(Signaculum.Sakura.StatusContorni.inactivus)
  | `(statusContorniL default) => `(Signaculum.Sakura.StatusContorni.praefinitus)
  | `(statusContorniL disable) => `(Signaculum.Sakura.StatusContorni.inhabilis)
  | `(statusContorniL ($e))    => `($e)


-- ════════════════════════════════════════════════════
--  directioAllineatioBullaeLiteral (DirectioAllineatioBullae 型リテラル)
-- ════════════════════════════════════════════════════

/-- 吹出し方向リテラルカテゴリアにゃん。left/center/top/right/bottom/none で書けるにゃ -/
declare_syntax_cat directioAllineatioBullaeLiteral

syntax "left"   : directioAllineatioBullaeLiteral
syntax "center" : directioAllineatioBullaeLiteral
syntax "top"    : directioAllineatioBullaeLiteral
syntax "right"  : directioAllineatioBullaeLiteral
syntax "bottom" : directioAllineatioBullaeLiteral
syntax "none"   : directioAllineatioBullaeLiteral
syntax "(" term ")" : directioAllineatioBullaeLiteral

syntax "directioAllineatioBullaeL " directioAllineatioBullaeLiteral : term

macro_rules
  | `(directioAllineatioBullaeL left)   => `(Signaculum.Sakura.DirectioAllineatioBullae.sinistrum)
  | `(directioAllineatioBullaeL center) => `(Signaculum.Sakura.DirectioAllineatioBullae.centrum)
  | `(directioAllineatioBullaeL top)    => `(Signaculum.Sakura.DirectioAllineatioBullae.summum)
  | `(directioAllineatioBullaeL right)  => `(Signaculum.Sakura.DirectioAllineatioBullae.dextrum)
  | `(directioAllineatioBullaeL bottom) => `(Signaculum.Sakura.DirectioAllineatioBullae.imum)
  | `(directioAllineatioBullaeL none)   => `(Signaculum.Sakura.DirectioAllineatioBullae.nullus)
  | `(directioAllineatioBullaeL ($e))   => `($e)


-- ════════════════════════════════════════════════════
--  modusTapetisLiteral (ModusTapetis 型リテラル)
-- ════════════════════════════════════════════════════

/-- 壁紙モードリテラルカテゴリアにゃん。center/tile/stretch/stretch-x/stretch-y/span で書けるにゃ -/
declare_syntax_cat modusTapetisLiteral

syntax "center"  : modusTapetisLiteral
syntax "tile"    : modusTapetisLiteral
syntax "stretch" : modusTapetisLiteral
syntax (priority := high) "stretch" "-" "x" : modusTapetisLiteral
syntax (priority := high) "stretch" "-" "y" : modusTapetisLiteral
syntax "span"    : modusTapetisLiteral
syntax "(" term ")" : modusTapetisLiteral

syntax "modusTapetisL " modusTapetisLiteral : term

macro_rules
  | `(modusTapetisL center)      => `(Signaculum.Sakura.ModusTapetis.centrum)
  | `(modusTapetisL tile)        => `(Signaculum.Sakura.ModusTapetis.tessella)
  | `(modusTapetisL stretch - x) => `(Signaculum.Sakura.ModusTapetis.extendeX)
  | `(modusTapetisL stretch - y) => `(Signaculum.Sakura.ModusTapetis.extendeY)
  | `(modusTapetisL stretch)     => `(Signaculum.Sakura.ModusTapetis.extende)
  | `(modusTapetisL span)        => `(Signaculum.Sakura.ModusTapetis.spatium)
  | `(modusTapetisL ($e))        => `($e)


-- ════════════════════════════════════════════════════
--  magnitudoLitterarumLiteral (MagnitudoLitterarum 型リテラル)
-- ════════════════════════════════════════════════════

/-- 文字の大きさリテラルカテゴリアにゃん。
    數值=絕對px、+n/−n=相對、n%=百分率、default=既定にゃ -/
declare_syntax_cat magnitudoLitterarumLiteral

syntax "default" : magnitudoLitterarumLiteral
syntax "+" num   : magnitudoLitterarumLiteral
syntax "-" num   : magnitudoLitterarumLiteral
syntax num "%"   : magnitudoLitterarumLiteral
syntax num       : magnitudoLitterarumLiteral
syntax "(" term ")" : magnitudoLitterarumLiteral

syntax "magnitudoLitterarumL " magnitudoLitterarumLiteral : term

macro_rules
  | `(magnitudoLitterarumL default) => `(Signaculum.Sakura.MagnitudoLitterarum.praefinita)
  | `(magnitudoLitterarumL + $n:num) => `(Signaculum.Sakura.MagnitudoLitterarum.relativa $n)
  | `(magnitudoLitterarumL - $n:num) => `(Signaculum.Sakura.MagnitudoLitterarum.relativa (- $n))
  | `(magnitudoLitterarumL $n:num %) => `(Signaculum.Sakura.MagnitudoLitterarum.proportio $n)
  | `(magnitudoLitterarumL $n:num)   => `(Signaculum.Sakura.MagnitudoLitterarum.absoluta $n)
  | `(magnitudoLitterarumL ($e))     => `($e)

end Signaculum.Notatio
