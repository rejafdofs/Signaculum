-- Signaculum.Notatio.Expande.Fons
-- 書體タグ \f[...] のディスパッチ關數にゃん♪
-- 舊い syntax + macro_rules を統一的な elaboration 型に置き換へるにゃ

import Lean
import Signaculum.Sakura.Scriptum
import Signaculum.Sakura.Literalis

namespace Signaculum.Notatio.Expande

open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentVal (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some (s.getId.toString (escape := false))
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

/-- 數値リテラルかどうか確認して取り出すにゃん -/
private def expectaNatLit (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `num) := do
  if s.isNatLit?.isSome then
    pure ⟨s⟩
  else
    throwErrorAt s s!"{nomenSigni}: 數字が期待されてゐますにゃ"

/-- 文字列リテラルかどうか確認して取り出すにゃん -/
private def expectaStrLit (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `str) := do
  if s.isStrLit?.isSome then
    pure ⟨s⟩
  else
    match extractIdentVal s with
    | some v => pure ⟨Syntax.mkStrLit v⟩
    | none   => throwErrorAt s s!"{nomenSigni}: 文字列が期待されてゐますにゃ"

/-- 括弧附き term か、ident/numLit/strLit でない構文ノードを term として取り出すにゃん。
    カスタムパーサーは (expr) の括弧を剥がして中身だけ積むから、
    paren ノードではなく直接 term ノードが來るにゃ -/
private def extractaTermParenthesatum (s : Lean.Syntax) : Option Lean.Syntax :=
  -- paren ノードならその中身にゃ
  if s.getKind == ``Lean.Parser.Term.paren then
    let args := s.getArgs
    if args.size >= 2 then some args[1]! else none
  -- ident でも numLit でも strLit でもなければ term として扱ふにゃ
  else if !s.isIdent && s.isNatLit?.isNone && s.isStrLit?.isNone && !s.isAtom then
    some s
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
    if valores[0]!.isNatLit?.isSome && valores[1]!.isNatLit?.isSome && valores[2]!.isNatLit?.isSome then
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
    if v.isStrLit?.isSome then
      let s : TSyntax `str := ⟨v⟩
      return ← `(Signaculum.Sakura.Coloris.hex $s)
    -- 識別子にゃん
    match extractIdentVal v with
    | some "none"                  => return ← `(Signaculum.Sakura.SakuraNullus.nullus)
    | some "default"               => return ← `(Signaculum.Sakura.SakuraPraefinitus.praefinitus)
    | some "disable"               => return ← `(Signaculum.Sakura.SakuraInhabilis.inhabilis)
    | some "default.anchor"        => return ← `(Signaculum.Sakura.Coloris.praefinitusAncorae)
    | some "default.anchornotselect" => return ← `(Signaculum.Sakura.Coloris.praefinitusAncoraeNonElectae)
    | some "default.anchorvisited" => return ← `(Signaculum.Sakura.Coloris.praefinitusAncoraeVisae)
    | some "default.cursor"        => return ← `(Signaculum.Sakura.Coloris.praefinitusCursoris)
    | some "default.cursornotselect" => return ← `(Signaculum.Sakura.Coloris.praefinitusCursorisNonElecti)
    | some "default.plain"         => return ← `(Signaculum.Sakura.Coloris.praefinitusPlanus)
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
    if valores[0]!.isNatLit?.isSome then
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
    | some "default" => return ← `(Signaculum.Sakura.SakuraPraefinitus.praefinitus)
    | _ => pure ()
    -- 數値（絕對）にゃん
    if v.isNatLit?.isSome then
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
    | some "offset"  => return ← `(Signaculum.Sakura.SakuraOffset.offset)
    | some "outline" => return ← `(Signaculum.Sakura.SakuraContornus.contornus)
    | some "default" => return ← `(Signaculum.Sakura.SakuraPraefinitus.praefinitus)
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
    | some "true"    => return ← `(Signaculum.Sakura.SakuraActivus.activus)
    | some "false"   => return ← `(Signaculum.Sakura.SakuraInactivus.inactivus)
    | some "default" => return ← `(Signaculum.Sakura.SakuraPraefinitus.praefinitus)
    | some "disable" => return ← `(Signaculum.Sakura.SakuraInhabilis.inhabilis)
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
    | some "left"    => return ← `(Signaculum.Sakura.SakuraSinistrum.sinistrum)
    | some "right"   => return ← `(Signaculum.Sakura.SakuraDextrum.dextrum)
    | some "center"  => return ← `(Signaculum.Sakura.SakuraCentrum.centrum)
    | some "justify" => return ← `(Signaculum.Sakura.SakuraContentum.contentum)
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
    | some "top"    => return ← `(Signaculum.Sakura.SakuraSummum.summum)
    | some "middle" => return ← `(Signaculum.Sakura.SakuraMedium.medium)
    | some "bottom" => return ← `(Signaculum.Sakura.SakuraImum.imum)
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
    | some "square"    => return ← `(Signaculum.Sakura.SakuraQuadratum.quadratum)
    | some "underline" => return ← `(Signaculum.Sakura.SakuraSublinea.sublinea)
    | some "none"      => return ← `(Signaculum.Sakura.SakuraNullus.nullus)
    | some "default"   => return ← `(Signaculum.Sakura.SakuraPraefinitus.praefinitus)
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
    | some "default"     => return ← `(Signaculum.Sakura.SakuraPraefinitus.praefinitus)
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
    return ← `($ctor $(⟨e⟩))
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
    pure <| some (← interpretaBooleum `Signaculum.Sakura.Textus.audax valores stx)

  | "italic" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.Textus.obliquus valores stx)

  | "underline" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.Textus.sublinea valores stx)

  | "strike" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.Textus.deletura valores stx)

  | "sub" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.Textus.subscriptus valores stx)

  | "sup" =>
    pure <| some (← interpretaBooleum `Signaculum.Sakura.Textus.superscriptus valores stx)

  -- ════════════════════════════════════════════════════
  --  色系 (Colores)
  -- ════════════════════════════════════════════════════

  | "color" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.color $c))

  | "shadowcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorUmbrae $c))

  -- ════════════════════════════════════════════════════
  --  文字サイズ (Magnitudo Litterarum)
  -- ════════════════════════════════════════════════════

  | "height" => do
    let m ← interpretaMagnitudinem valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.altitudoLitterarum $m))

  -- ════════════════════════════════════════════════════
  --  フォント名 (Nomen Fontis)
  -- ════════════════════════════════════════════════════

  | "name" =>
    if valores.size != 1 then
      throwErrorAt stx "\\f[name]: term が1つ期待されてゐますにゃ"
    let v : TSyntax `term := ⟨valores[0]!⟩
    pure <| some (← `(Signaculum.Sakura.Textus.nomenFontis $v))

  -- ════════════════════════════════════════════════════
  --  影スタイル (Stylus Umbrae)
  -- ════════════════════════════════════════════════════

  | "shadowstyle" => do
    let s ← interpretaStylusUmbrae valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.stylumUmbrae $s))

  -- ════════════════════════════════════════════════════
  --  輪郭 (Contornus)
  -- ════════════════════════════════════════════════════

  | "outline" => do
    let s ← interpretaStatusContorni valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.contornus $s))

  -- ════════════════════════════════════════════════════
  --  方向系 (Directiones)
  -- ════════════════════════════════════════════════════

  | "align" => do
    let d ← interpretaDirectioAllineatio valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.allineatio $d))

  | "valign" => do
    let d ← interpretaDirectioVerticalis valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.allineatioVerticalis $d))

  -- ════════════════════════════════════════════════════
  --  パラメータなし (Sine Parametris)
  -- ════════════════════════════════════════════════════

  | "disable" =>
    pure <| some (← `(Signaculum.Sakura.Textus.formaInhabilis))

  | "default" =>
    pure <| some (← `(Signaculum.Sakura.Textus.formaPraefinita))

  -- ════════════════════════════════════════════════════
  --  カーソル選擇中 (Cursor Electi)
  -- ════════════════════════════════════════════════════

  | "cursorstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.stylumCursorisElecti $f))

  | "cursorcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorCursorisElecti $c))

  | "cursorbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorPenicilliCursorisElecti $c))

  | "cursorpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorCalamCursorisElecti $c))

  | "cursorfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorFontisCursorisElecti $c))

  | "cursormethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.methodusCursorisElecti $m))

  -- ════════════════════════════════════════════════════
  --  カーソル未選擇 (Cursor Non Electi)
  -- ════════════════════════════════════════════════════

  | "cursornotselectstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.stylumCursorisNonElecti $f))

  | "cursornotselectcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorCursorisNonElecti $c))

  | "cursornotselectbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorPenicilliCursorisNonElecti $c))

  | "cursornotselectpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorCalamCursorisNonElecti $c))

  | "cursornotselectfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorFontisCursorisNonElecti $c))

  | "cursornotselectmethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.methodusCursorisNonElecti $m))

  -- ════════════════════════════════════════════════════
  --  錨選擇中 (Ancora Electa)
  -- ════════════════════════════════════════════════════

  | "anchorstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.stylumAncorae $f))

  | "anchorcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorAncorae $c))

  | "anchorbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorPenicilliAncorae $c))

  | "anchorpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorCalamAncorae $c))

  | "anchorfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorFontisAncoraTotae $c))

  | "anchormethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.methodusAncorae $m))

  -- ════════════════════════════════════════════════════
  --  錨未選擇 (Ancora Non Electa)
  -- ════════════════════════════════════════════════════

  | "anchornotselectstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.stylumAncoraeNonElectae $f))

  | "anchornotselectcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorAncoraeNonElectae $c))

  | "anchornotselectbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorPenicilliAncoraeNonElectae $c))

  | "anchornotselectpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorCalamAncoraeNonElectae $c))

  | "anchornotselectfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorFontisAncoraeNonElectae $c))

  | "anchornotselectmethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.methodusAncoraeNonElectae $m))

  -- ════════════════════════════════════════════════════
  --  錨訪問済み (Ancora Visa)
  -- ════════════════════════════════════════════════════

  | "anchorvisitedstyle" => do
    let f ← interpretaFormamMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.stylumAncoraeVisae $f))

  | "anchorvisitedcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorAncoraeVisae $c))

  | "anchorvisitedbrushcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorPenicilliAncoraeVisae $c))

  | "anchorvisitedpencolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorCalamAncoraeVisae $c))

  | "anchorvisitedfontcolor" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorFontisAncoraeVisae $c))

  | "anchorvisitedmethod" => do
    let m ← interpretaMethodumMarci valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.methodusAncoraeVisae $m))

  -- ════════════════════════════════════════════════════
  --  錨テクストゥス全體色 (Color Fontis Ancorae)
  -- ════════════════════════════════════════════════════

  | "anchor.font.color" => do
    let c ← interpretaColoris valores stx
    pure <| some (← `(Signaculum.Sakura.Textus.colorFontisAncorae $c))

  -- ════════════════════════════════════════════════════
  --  未處理 (Non Tractatum)
  -- ════════════════════════════════════════════════════

  -- 此のモジュールで處理できないキーは none を返して次のディスパッチへ委ねるにゃん
  | _ => pure none

end Signaculum.Notatio.Expande
