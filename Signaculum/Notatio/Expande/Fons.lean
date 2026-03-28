-- Signaculum.Notatio.Expande.Fons
-- 書體タグ \f[...] のディスパッチ關數にゃん♪
-- 舊い syntax + macro_rules を統一的な elaboration 型に置き換へるにゃ

import Lean
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio.Expande

open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentVal (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some s.getId.toString
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

/-- 數値リテラルかどうか確認して取り出すにゃん -/
private def expectaNatLit (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `num) := do
  if s.isNatLit? then
    pure ⟨s⟩
  else
    throwErrorAt s s!"{nomenSigni}: 數字が期待されてゐますにゃ"

/-- 文字列リテラルかどうか確認して取り出すにゃん -/
private def expectaStrLit (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `str) := do
  if s.isStrLit? then
    pure ⟨s⟩
  else
    throwErrorAt s s!"{nomenSigni}: 文字列が期待されてゐますにゃ"

/-- 括弧に包まれた term を取り出すにゃん。
    ノードが `group` で子が `(` term `)` の形なら term を返すにゃ -/
private def extractaTermParenthesatum (s : Lean.Syntax) : Option Lean.Syntax :=
  if s.getKind == ``Lean.Parser.Term.paren then
    -- `(` term `)` — 中身は args[1] にゃん
    let args := s.getArgs
    if args.size >= 2 then some args[1]! else none
  else
    none

-- ════════════════════════════════════════════════════
--  リテラル解釋函數 (Functiones Interpretationis)
--  此のモジュール内でのみ有效にゃん♪
-- ════════════════════════════════════════════════════

/-- 色リテラルを Coloris の term に解釋するにゃん♪
    - `[r, g, b]` (3 nums) → `Coloris.rgb r g b`
    - `[name]` ident → `Coloris.nomen "name"`
      (none→nullus, default→praefinitus, disable→inhabilis,
       default.anchor→praefinitusAncorae, etc.)
    - `[s]` strLit → `Coloris.hex s`
    - `[# ident]` → `Coloris.hex "#identname"`
    - `(expr)` → pass through -/
private def interpretaColoris (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  -- RGB 三つ組にゃん
  if valores.size == 3 then
    if valores[0]!.isNatLit? && valores[1]!.isNatLit? && valores[2]!.isNatLit? then
      let r : TSyntax `num := ⟨valores[0]!⟩
      let g : TSyntax `num := ⟨valores[1]!⟩
      let b : TSyntax `num := ⟨valores[2]!⟩
      return ← `(Signaculum.Sakura.Coloris.rgb $r $g $b)
  -- default.xxx 複合キーにゃん（ドット區切り）
  if valores.size == 3 then
    match extractIdentVal valores[0]!, extractIdentVal valores[1]!, extractIdentVal valores[2]! with
    | some "default", some ".", some sub =>
      match sub with
      | "anchor"          => return ← `(Signaculum.Sakura.Coloris.praefinitusAncorae)
      | "anchornotselect" => return ← `(Signaculum.Sakura.Coloris.praefinitusAncoraeNonElectae)
      | "anchorvisited"   => return ← `(Signaculum.Sakura.Coloris.praefinitusAncoraeVisae)
      | "cursor"          => return ← `(Signaculum.Sakura.Coloris.praefinitusCursoris)
      | "cursornotselect" => return ← `(Signaculum.Sakura.Coloris.praefinitusCursorisNonElecti)
      | "plain"           => return ← `(Signaculum.Sakura.Coloris.praefinitusPlanus)
      | _                 => throwErrorAt stx s!"\\f[...]: 不明な default.{sub} 色指定にゃ"
    | _, _, _ => pure ()
  -- # ident (hex 色) にゃん
  if valores.size == 2 then
    match extractIdentVal valores[0]! with
    | some "#" =>
      if valores[1]!.isIdent then
        let hexStr := "#" ++ valores[1]!.getId.toString
        return ← `(Signaculum.Sakura.Coloris.hex $(Lean.Syntax.mkStrLit hexStr))
      else
        throwErrorAt stx "\\f[...]: # の後には識別子が期待されてゐますにゃ"
    | _ => pure ()
  -- 單一値にゃん
  if valores.size == 1 then
    let v := valores[0]!
    -- 括弧附き term にゃん
    match extractaTermParenthesatum v with
    | some e => return ⟨e⟩
    | none   => pure ()
    -- 文字列リテラル（hex 色）にゃん
    if v.isStrLit? then
      let s : TSyntax `str := ⟨v⟩
      return ← `(Signaculum.Sakura.Coloris.hex $s)
    -- 識別子にゃん
    match extractIdentVal v with
    | some "none"    => return ← `(Signaculum.Sakura.Coloris.nullus)
    | some "default" => return ← `(Signaculum.Sakura.Coloris.praefinitus)
    | some "disable" => return ← `(Signaculum.Sakura.Coloris.inhabilis)
    | some name      => return ← `(Signaculum.Sakura.Coloris.nomen $(Lean.Syntax.mkStrLit name))
    | none           => pure ()
  throwErrorAt stx "\\f[...]: 色の指定が不正にゃ"

/-- 文字サイズリテラルを MagnitudoLitterarum の term に解釋するにゃん♪
    - `[n]` num → `MagnitudoLitterarum.absoluta n`
    - `[+, n]` → `MagnitudoLitterarum.relativa n`
    - `[-, n]` → `MagnitudoLitterarum.relativa (- n)`
    - `[n, %]` → `MagnitudoLitterarum.proportio n`
    - `[default]` → `MagnitudoLitterarum.praefinita`
    - `(expr)` → pass through -/
private def interpretaMagnitudinem (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  -- + n / - n にゃん
  if valores.size == 2 then
    match extractIdentVal valores[0]! with
    | some "+" =>
      let n ← expectaNatLit valores[1]! "\\f[height]"
      return ← `(Signaculum.Sakura.MagnitudoLitterarum.relativa $n)
    | some "-" =>
      let n ← expectaNatLit valores[1]! "\\f[height]"
      return ← `(Signaculum.Sakura.MagnitudoLitterarum.relativa (- $n))
    | _ => pure ()
    -- n % にゃん
    if valores[0]!.isNatLit? then
      match extractIdentVal valores[1]! with
      | some "%" =>
        let n : TSyntax `num := ⟨valores[0]!⟩
        return ← `(Signaculum.Sakura.MagnitudoLitterarum.proportio $n)
      | _ => pure ()
  -- 單一値にゃん
  if valores.size == 1 then
    let v := valores[0]!
    -- 括弧附き term にゃん
    match extractaTermParenthesatum v with
    | some e => return ⟨e⟩
    | none   => pure ()
    -- default にゃん
    match extractIdentVal v with
    | some "default" => return ← `(Signaculum.Sakura.MagnitudoLitterarum.praefinita)
    | _ => pure ()
    -- 數値（絕對）にゃん
    if v.isNatLit? then
      let n : TSyntax `num := ⟨v⟩
      return ← `(Signaculum.Sakura.MagnitudoLitterarum.absoluta $n)
  throwErrorAt stx "\\f[height]: サイズ指定が不正にゃ"

/-- 影スタイルを StylusUmbrae の term に解釋するにゃん♪
    offset → .offset, outline → .contornus, default → .praefinitus -/
private def interpretaStylusUmbrae (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  if valores.size == 1 then
    let v := valores[0]!
    match extractaTermParenthesatum v with
    | some e => return ⟨e⟩
    | none   => pure ()
    match extractIdentVal v with
    | some "offset"  => return ← `(Signaculum.Sakura.StylusUmbrae.offset)
    | some "outline" => return ← `(Signaculum.Sakura.StylusUmbrae.contornus)
    | some "default" => return ← `(Signaculum.Sakura.StylusUmbrae.praefinitus)
    | _              => pure ()
  throwErrorAt stx "\\f[shadowstyle]: offset/outline/default が期待されてゐますにゃ"

/-- 輪郭狀態を StatusContorni の term に解釋するにゃん♪
    true → .activus, false → .inactivus, default → .praefinitus, disable → .inhabilis -/
private def interpretaStatusContorni (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  if valores.size == 1 then
    let v := valores[0]!
    match extractaTermParenthesatum v with
    | some e => return ⟨e⟩
    | none   => pure ()
    match extractIdentVal v with
    | some "true"    => return ← `(Signaculum.Sakura.StatusContorni.activus)
    | some "false"   => return ← `(Signaculum.Sakura.StatusContorni.inactivus)
    | some "default" => return ← `(Signaculum.Sakura.StatusContorni.praefinitus)
    | some "disable" => return ← `(Signaculum.Sakura.StatusContorni.inhabilis)
    | _              => pure ()
  throwErrorAt stx "\\f[outline]: true/false/default/disable が期待されてゐますにゃ"

/-- 文字揃へ方向を DirectioAllineatio の term に解釋するにゃん♪
    left → .sinistrum, right → .dextrum, center → .centrum, justify → .contentum -/
private def interpretaDirectioAllineatio (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  if valores.size == 1 then
    let v := valores[0]!
    match extractaTermParenthesatum v with
    | some e => return ⟨e⟩
    | none   => pure ()
    match extractIdentVal v with
    | some "left"    => return ← `(Signaculum.Sakura.DirectioAllineatio.sinistrum)
    | some "right"   => return ← `(Signaculum.Sakura.DirectioAllineatio.dextrum)
    | some "center"  => return ← `(Signaculum.Sakura.DirectioAllineatio.centrum)
    | some "justify" => return ← `(Signaculum.Sakura.DirectioAllineatio.contentum)
    | _              => pure ()
  throwErrorAt stx "\\f[align]: left/right/center/justify が期待されてゐますにゃ"

/-- 縦方向文字揃へを DirectioVerticalis の term に解釋するにゃん♪
    top → .summum, middle → .medium, bottom → .imum -/
private def interpretaDirectioVerticalis (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  if valores.size == 1 then
    let v := valores[0]!
    match extractaTermParenthesatum v with
    | some e => return ⟨e⟩
    | none   => pure ()
    match extractIdentVal v with
    | some "top"    => return ← `(Signaculum.Sakura.DirectioVerticalis.summum)
    | some "middle" => return ← `(Signaculum.Sakura.DirectioVerticalis.medium)
    | some "bottom" => return ← `(Signaculum.Sakura.DirectioVerticalis.imum)
    | _             => pure ()
  throwErrorAt stx "\\f[valign]: top/middle/bottom が期待されてゐますにゃ"

/-- マーカー形状を FormaMarci の term に解釋するにゃん♪
    square → .quadratum, underline → .sublineaForma,
    square+underline → .utrumque, none → .nullus, default → .praefinitus -/
private def interpretaFormamMarci (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  -- square + underline (3 tokens) にゃん
  if valores.size == 3 then
    match extractIdentVal valores[0]!, extractIdentVal valores[1]!, extractIdentVal valores[2]! with
    | some "square", some "+", some "underline" =>
      return ← `(Signaculum.Sakura.FormaMarci.utrumque)
    | _, _, _ => pure ()
  -- 單一値にゃん
  if valores.size == 1 then
    let v := valores[0]!
    match extractaTermParenthesatum v with
    | some e => return ⟨e⟩
    | none   => pure ()
    match extractIdentVal v with
    | some "square"    => return ← `(Signaculum.Sakura.FormaMarci.quadratum)
    | some "underline" => return ← `(Signaculum.Sakura.FormaMarci.sublineaForma)
    | some "none"      => return ← `(Signaculum.Sakura.FormaMarci.nullus)
    | some "default"   => return ← `(Signaculum.Sakura.FormaMarci.praefinitus)
    | _                => pure ()
  throwErrorAt stx "\\f[...style]: square/underline/square+underline/none/default が期待されてゐますにゃ"

/-- マーカー描畫方法を MethodusMarci の term に解釋するにゃん♪
    Win32 SetROP2 の全モード + SSP 擴張 (xor/alpha/normal/default) にゃ -/
private def interpretaMethodumMarci (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  if valores.size == 1 then
    let v := valores[0]!
    match extractaTermParenthesatum v with
    | some e => return ⟨e⟩
    | none   => pure ()
    match extractIdentVal v with
    -- Win32 SetROP2 にゃん
    | some "black"       => return ← `(Signaculum.Sakura.MethodusMarci.black)
    | some "notmergepen" => return ← `(Signaculum.Sakura.MethodusMarci.notmergepen)
    | some "masknotpen"  => return ← `(Signaculum.Sakura.MethodusMarci.masknotpen)
    | some "notcopypen"  => return ← `(Signaculum.Sakura.MethodusMarci.notcopypen)
    | some "maskpennot"  => return ← `(Signaculum.Sakura.MethodusMarci.maskpennot)
    | some "not"         => return ← `(Signaculum.Sakura.MethodusMarci.not)
    | some "xorpen"      => return ← `(Signaculum.Sakura.MethodusMarci.xorpen)
    | some "notmaskpen"  => return ← `(Signaculum.Sakura.MethodusMarci.notmaskpen)
    | some "maskpen"     => return ← `(Signaculum.Sakura.MethodusMarci.maskpen)
    | some "notxorpen"   => return ← `(Signaculum.Sakura.MethodusMarci.notxorpen)
    | some "nop"         => return ← `(Signaculum.Sakura.MethodusMarci.nop)
    | some "mergenotpen" => return ← `(Signaculum.Sakura.MethodusMarci.mergenotpen)
    | some "copypen"     => return ← `(Signaculum.Sakura.MethodusMarci.copypen)
    | some "mergepennot" => return ← `(Signaculum.Sakura.MethodusMarci.mergepennot)
    | some "mergepen"    => return ← `(Signaculum.Sakura.MethodusMarci.mergepen)
    | some "white"       => return ← `(Signaculum.Sakura.MethodusMarci.white)
    -- SSP 擴張にゃん
    | some "xor"         => return ← `(Signaculum.Sakura.MethodusMarci.xor)
    | some "alpha"       => return ← `(Signaculum.Sakura.MethodusMarci.alpha)
    | some "normal"      => return ← `(Signaculum.Sakura.MethodusMarci.normal)
    | some "default"     => return ← `(Signaculum.Sakura.MethodusMarci.praefinitus)
    | _                  => pure ()
  throwErrorAt stx "\\f[...method]: 描畫方法の指定が不正にゃ"

-- ════════════════════════════════════════════════════
--  Bool 系補助 (Auxilium Booleanum)
-- ════════════════════════════════════════════════════

/-- Bool 系キー (bold/italic/underline/strike/sub/sup) の共通パターンにゃん♪
    true/false リテラル、または括弧附き term を處理するにゃ -/
private def interpretaBooleum (constructorNomen : Lean.Name) (valores : Array Lean.Syntax)
    (stx : Lean.Syntax)
    : TermElabM (Lean.TSyntax `term) := do
  if valores.size != 1 then
    throwErrorAt stx s!"\\f[...]: Bool 値が1つ期待されてゐますにゃ"
  let v := valores[0]!
  -- 括弧附き term にゃん
  match extractaTermParenthesatum v with
  | some e =>
    let ctor := mkIdent constructorNomen
    return ← `($ctor $e)
  | none => pure ()
  -- true / false リテラルにゃん
  match extractIdentVal v with
  | some "true" =>
    let ctor := mkIdent constructorNomen
    return ← `($ctor Bool.true)
  | some "false" =>
    let ctor := mkIdent constructorNomen
    return ← `($ctor Bool.false)
  | _ =>
    throwErrorAt stx "\\f[...]: true/false/(expr) が期待されてゐますにゃ"

-- ════════════════════════════════════════════════════
--  主ディスパッチ函數 (Functio Principalis Dispatchonis)
-- ════════════════════════════════════════════════════

/-- 書體タグ `\f[...]` のディスパッチにゃん♪
    `clavis` はキー名（例："bold", "color", "height"）、
    `valores` はカンマ區切り値の配列、`stx` は元の構文ノードにゃ。
    處理できたら `some term` を返すにゃん -/
def expandeFons (clavis : String) (valores : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match clavis with

  -- ════════════════════════════════════════════════════
  --  Bool 系 (Booleana)
  -- ════════════════════════════════════════════════════

  | "bold" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.audax valores stx)

  | "italic" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.obliquus valores stx)

  | "underline" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.sublinea valores stx)

  | "strike" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.deletura valores stx)

  | "sub" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.subscriptus valores stx)

  | "sup" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.superscriptus valores stx)

  -- ════════════════════════════════════════════════════
  --  色系 (Colores)
  -- ════════════════════════════════════════════════════

  | "color" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.color $c))

  | "shadowcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorUmbrae $c))

  -- ════════════════════════════════════════════════════
  --  文字サイズ (Magnitudo Litterarum)
  -- ════════════════════════════════════════════════════

  | "height" => do
    let m ← interpretaMagnitudinem valores stx
    pure <| some (← `(Signaculum.Sakura.altitudoLitterarum $m))

  -- ════════════════════════════════════════════════════
  --  フォント名 (Nomen Fontis)
  -- ════════════════════════════════════════════════════

  | "name" =>
    if valores.size != 1 then
      throwErrorAt stx "\\f[name]: term が1つ期待されてゐますにゃ"
    let v : TSyntax `term := ⟨valores[0]!⟩
    pure <| some (← `(Signaculum.Sakura.nomenFontis $v))

  -- ════════════════════════════════════════════════════
  --  影スタイル (Stylus Umbrae)
  -- ════════════════════════════════════════════════════

  | "shadowstyle" => do
    let s ← interpretaStylusUmbrae valores stx
    pure <| some (← `(Signaculum.Sakura.stylumUmbrae $s))

  -- ════════════════════════════════════════════════════
  --  輪郭 (Contornus)
  -- ════════════════════════════════════════════════════

  | "outline" => do
    let s ← interpretaStatusContorni valores stx
    pure <| some (← `(Signaculum.Sakura.contornus $s))

  -- ════════════════════════════════════════════════════
  --  方向系 (Directiones)
  -- ════════════════════════════════════════════════════

  | "align" => do
    let d ← interpretaDirectioAllineatio valores stx
    pure <| some (← `(Signaculum.Sakura.allineatio $d))

  | "valign" => do
    let d ← interpretaDirectioVerticalis valores stx
    pure <| some (← `(Signaculum.Sakura.allineatioVerticalis $d))

  -- ════════════════════════════════════════════════════
  --  パラメータなし (Sine Parametris)
  -- ════════════════════════════════════════════════════

  | "disable" =>
    pure <| some (← `(Signaculum.Sakura.formaInhabilis))

  | "default" =>
    pure <| some (← `(Signaculum.Sakura.formaPraefinita))

  -- ════════════════════════════════════════════════════
  --  カーソル選擇中 (Cursor Electi)
  -- ════════════════════════════════════════════════════

  | "cursorstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.stylumCursorisElecti $f))

  | "cursorcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorCursorisElecti $c))

  | "cursorbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorPenicilliCursorisElecti $c))

  | "cursorpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorCalamCursorisElecti $c))

  | "cursorfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorFontisCursorisElecti $c))

  | "cursormethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.methodusCursorisElecti $m))

  -- ════════════════════════════════════════════════════
  --  カーソル未選擇 (Cursor Non Electi)
  -- ════════════════════════════════════════════════════

  | "cursornotselectstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.stylumCursorisNonElecti $f))

  | "cursornotselectcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorCursorisNonElecti $c))

  | "cursornotselectbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorPenicilliCursorisNonElecti $c))

  | "cursornotselectpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorCalamCursorisNonElecti $c))

  | "cursornotselectfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorFontisCursorisNonElecti $c))

  | "cursornotselectmethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.methodusCursorisNonElecti $m))

  -- ════════════════════════════════════════════════════
  --  錨選擇中 (Ancora Electa)
  -- ════════════════════════════════════════════════════

  | "anchorstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.stylumAncorae $f))

  | "anchorcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorAncorae $c))

  | "anchorbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorPenicilliAncorae $c))

  | "anchorpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorCalamAncorae $c))

  | "anchorfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorFontisAncoraTotae $c))

  | "anchormethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.methodusAncorae $m))

  -- ════════════════════════════════════════════════════
  --  錨未選擇 (Ancora Non Electa)
  -- ════════════════════════════════════════════════════

  | "anchornotselectstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.stylumAncoraeNonElectae $f))

  | "anchornotselectcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorAncoraeNonElectae $c))

  | "anchornotselectbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorPenicilliAncoraeNonElectae $c))

  | "anchornotselectpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorCalamAncoraeNonElectae $c))

  | "anchornotselectfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorFontisAncoraeNonElectae $c))

  | "anchornotselectmethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.methodusAncoraeNonElectae $m))

  -- ════════════════════════════════════════════════════
  --  錨訪問済み (Ancora Visa)
  -- ════════════════════════════════════════════════════

  | "anchorvisitedstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.stylumAncoraeVisae $f))

  | "anchorvisitedcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorAncoraeVisae $c))

  | "anchorvisitedbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorPenicilliAncoraeVisae $c))

  | "anchorvisitedpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorCalamAncoraeVisae $c))

  | "anchorvisitedfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorFontisAncoraeVisae $c))

  | "anchorvisitedmethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.methodusAncoraeVisae $m))

  -- ════════════════════════════════════════════════════
  --  錨テクストゥス全體色 (Color Fontis Ancorae)
  -- ════════════════════════════════════════════════════

  | "anchor.font.color" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.colorFontisAncorae $c))

  -- ════════════════════════════════════════════════════
  --  未處理 (Non Tractatum)
  -- ════════════════════════════════════════════════════

  -- 此のモジュールで處理できないキーは none を返して次のディスパッチへ委ねるにゃん
  | _ => pure none

end Signaculum.Notatio.Expande
