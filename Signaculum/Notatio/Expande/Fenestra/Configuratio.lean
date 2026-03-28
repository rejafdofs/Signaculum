-- Signaculum.Notatio.Expande.Fenestra.Configuratio
-- 設定・着替・壁紙・吹出し整列タグの派遣にゃん♪
-- \![set,...], \![bind,...] 等をぜんぶ此處で面倒みるにゃ
-- 舊假名遣ひの猫娘が案内するにゃん

import Lean
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio.Expande

open Lean Elab Term

/-- 引數が ident なら getId.toString (false) で名前を取るにゃ -/
private def argAdNomenC (arg : Syntax) : Option String :=
  if arg.isIdent then
    some (arg.getId.toString false)
  else match arg with
  | Syntax.node _ ``Lean.Parser.Term.str #[Syntax.atom _ v] =>
    let s := v.drop 1 |>.dropRight 1
    some s
  | _ => none

/-- 引數が括弧で包まれた式 `(expr)` かどうか確認するにゃん。
    `Lean.Parser.Term.paren` ノードなら中身を取り出すにゃ -/
private def estParenthesisatum (arg : Syntax) : Option Syntax :=
  if arg.isOfKind ``Lean.Parser.Term.paren then
    -- paren ノードの中身を取るにゃ
    match arg with
    | Syntax.node _ _ children =>
      -- children = ["(", inner, ")"] が典型にゃ
      if children.size ≥ 2 then some children[1]! else none
    | _ => none
  else none

-- ════════════════════════════════════════════════════
--  balloonalign にゃん♪ キーワードマッピング
-- ════════════════════════════════════════════════════

/-- `balloonalign` のキーワードを DirectioAllineatioBullae コンストラクタに寫すにゃん -/
private def resolveBalloonAlign (arg : Syntax) (stx : Syntax)
    : TermElabM (TSyntax `term) := do
  -- まづ括弧式を確認するにゃ
  if let some inner := estParenthesisatum arg then
    `(Signaculum.Sakura.allineatioBullae $inner)
  else
    match argAdNomenC arg with
    | some "left"   => `(Signaculum.Sakura.allineatioBullae .sinistrum)
    | some "center" => `(Signaculum.Sakura.allineatioBullae .centrum)
    | some "top"    => `(Signaculum.Sakura.allineatioBullae .summum)
    | some "right"  => `(Signaculum.Sakura.allineatioBullae .dextrum)
    | some "bottom" => `(Signaculum.Sakura.allineatioBullae .imum)
    | some "none"   => `(Signaculum.Sakura.allineatioBullae .nullus)
    | some other    => throwErrorAt stx s!"\\![set,balloonalign,...] の值 '{other}' は未知にゃ。left/center/top/right/bottom/none か (式) を使ふにゃ"
    | none          =>
      -- 式として渡されたかもしれにゃいにゃん
      `(Signaculum.Sakura.allineatioBullae $arg)

-- ════════════════════════════════════════════════════
--  wallpaper にゃん♪ モードキーワード
-- ════════════════════════════════════════════════════

/-- `wallpaper` のモードキーワードを ModusTapetis コンストラクタに寫すにゃん -/
private def resolveWallpaperMode (modeArg : Syntax) (viaArg : Syntax) (stx : Syntax)
    : TermElabM (TSyntax `term) := do
  -- 括弧式にゃん
  if let some inner := estParenthesisatum modeArg then
    `(Signaculum.Sakura.configuraTapete $viaArg (Option.some $inner))
  else
    match argAdNomenC modeArg with
    | some "center"    => `(Signaculum.Sakura.configuraTapete $viaArg (Option.some .centrum))
    | some "tile"      => `(Signaculum.Sakura.configuraTapete $viaArg (Option.some .tessella))
    | some "stretch"   => `(Signaculum.Sakura.configuraTapete $viaArg (Option.some .extende))
    | some "stretch-x" => `(Signaculum.Sakura.configuraTapete $viaArg (Option.some .extendeX))
    | some "stretch-y" => `(Signaculum.Sakura.configuraTapete $viaArg (Option.some .extendeY))
    | some "span"      => `(Signaculum.Sakura.configuraTapete $viaArg (Option.some .spatium))
    | some other       => throwErrorAt stx s!"\\![set,wallpaper,...] のモード '{other}' は未知にゃ。center/tile/stretch/stretch-x/stretch-y/span か (式) を使ふにゃ"
    | none             =>
      `(Signaculum.Sakura.configuraTapete $viaArg (Option.some $modeArg))

-- ════════════════════════════════════════════════════
--  set サブコマンドにゃん♪ (Subimperium Configurationis)
-- ════════════════════════════════════════════════════

/-- `\![set, subCmd, args...]` を捌くにゃん -/
private def resolveSet (subCmd : String) (rest : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match subCmd with
  -- 1引數の set にゃん
  | "autoscroll" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.configuraAutoScroll $(rest[0]!))
    else throwErrorAt stx "\\![set,autoscroll,...] は引數1つにゃ"
  | "windowstate" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.configuraStatusFenestrae $(rest[0]!))
    else throwErrorAt stx "\\![set,windowstate,...] は引數1つにゃ"
  | "alignmentondesktop" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.allineatioDesktop $(rest[0]!))
    else throwErrorAt stx "\\![set,alignmentondesktop,...] は引數1つにゃ"
  | "balloontimeout" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.tempusBullae $(rest[0]!))
    else throwErrorAt stx "\\![set,balloontimeout,...] は引數1つにゃ"
  | "balloonwait" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.moraTextus $(rest[0]!))
    else throwErrorAt stx "\\![set,balloonwait,...] は引數1つにゃ"
  | "serikotalk" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.configuraSerikoOs $(rest[0]!))
    else throwErrorAt stx "\\![set,serikotalk,...] は引數1つにゃ"
  | "blink" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.nictatus $(rest[0]!))
    else throwErrorAt stx "\\![set,blink,...] は引數1つにゃ"
  | "alwaysontop" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.semperSupra $(rest[0]!))
    else throwErrorAt stx "\\![set,alwaysontop,...] は引數1つにゃ"
  | "taskbar" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.tabellaTascae $(rest[0]!))
    else throwErrorAt stx "\\![set,taskbar,...] は引數1つにゃ"
  | "windowdragging" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.tractusWindowae $(rest[0]!))
    else throwErrorAt stx "\\![set,windowdragging,...] は引數1つにゃ"
  | "scaling" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.configuratioScalae $(rest[0]!))
    else throwErrorAt stx "\\![set,scaling,...] は引數1つにゃ"
  | "alpha" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.configuratioAlphae $(rest[0]!))
    else throwErrorAt stx "\\![set,alpha,...] は引數1つにゃ"
  -- balloonalign — キーワード派遣にゃん♪
  | "balloonalign" =>
    if rest.size == 1 then
      let t ← resolveBalloonAlign rest[0]! stx
      return some t
    else throwErrorAt stx "\\![set,balloonalign,...] は引數1つにゃ"
  -- balloonoffset — 3引數にゃん
  | "balloonoffset" =>
    if rest.size == 3 then
      let s := rest[0]!; let x := rest[1]!; let y := rest[2]!
      some <$> `(Signaculum.Sakura.configuraBullaeOffset $s $x $y)
    else throwErrorAt stx "\\![set,balloonoffset,...] は引數3つ (scope,x,y) にゃ"
  -- balloonpadding — 4引數にゃん
  | "balloonpadding" =>
    if rest.size == 4 then
      let l := rest[0]!; let t := rest[1]!; let r := rest[2]!; let b := rest[3]!
      some <$> `(Signaculum.Sakura.margosBullae $l $t $r $b)
    else throwErrorAt stx "\\![set,balloonpadding,...] は引數4つ (l,t,r,b) にゃ"
  -- position — 3引數にゃん
  | "position" =>
    if rest.size == 3 then
      let x := rest[0]!; let y := rest[1]!; let s := rest[2]!
      some <$> `(Signaculum.Sakura.configuraPositionem $x $y $s)
    else throwErrorAt stx "\\![set,position,...] は引數3つ (x,y,scope) にゃ"
  -- balloonmarker — str 引數にゃん
  | "balloonmarker" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.signatumBullae $(rest[0]!))
    else throwErrorAt stx "\\![set,balloonmarker,...] は引數1つにゃ"
  -- tasktrayicon — str 3つにゃん
  | "tasktrayicon" =>
    if rest.size == 3 then
      let v := rest[0]!; let t := rest[1]!; let o := rest[2]!
      some <$> `(Signaculum.Sakura.configuraTascamIcon $v $t $o)
    else throwErrorAt stx "\\![set,tasktrayicon,...] は引數3つ (file,text,options) にゃ"
  -- trayballoon — str にゃん
  | "trayballoon" =>
    if rest.size == 1 then some <$> `(Signaculum.Sakura.configuraTascamBullam $(rest[0]!))
    else throwErrorAt stx "\\![set,trayballoon,...] は引數1つにゃ"
  -- wallpaper — キーワード派遣にゃん♪
  | "wallpaper" =>
    match rest.size with
    | 1 =>
      -- \![set,wallpaper, v] — モード無しにゃん
      let v := rest[0]!
      some <$> `(Signaculum.Sakura.configuraTapete $v Option.none)
    | 2 =>
      -- \![set,wallpaper, v, mode] — キーワードかもにゃん
      let v := rest[0]!
      let t ← resolveWallpaperMode rest[1]! v stx
      return some t
    | _ => throwErrorAt stx "\\![set,wallpaper,...] は引數1〜2つにゃ"
  | _ => return none

-- ════════════════════════════════════════════════════
--  bind にゃん♪ 着替制御 (Dressup)
-- ════════════════════════════════════════════════════

/-- `\![bind, cat, part, 0/1]` を捌くにゃん。
    値は 0 か 1 のみ。それ以外はエラーにゃ -/
private def resolveBind (args : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match args.size with
  | 2 =>
    -- \![bind, cat, part] — 値省略にゃん
    let c := args[0]!; let p := args[1]!
    some <$> `(Signaculum.Sakura.nexaDressup $c $p Option.none)
  | 3 =>
    -- \![bind, cat, part, 0/1] にゃん
    let c := args[0]!; let p := args[1]!; let v := args[2]!
    -- 數値リテラルの場合はバリデーションするにゃ
    match v with
    | Syntax.node _ ``Lean.Parser.Term.num #[Syntax.atom _ digits] =>
      match digits.toNat? with
      | some 1 => some <$> `(Signaculum.Sakura.nexaDressup $c $p (Option.some Bool.true))
      | some 0 => some <$> `(Signaculum.Sakura.nexaDressup $c $p (Option.some Bool.false))
      | _      => throwErrorAt stx "\\![bind,...] の值は 0 か 1 のみにゃ"
    | _ =>
      -- num リテラルでない場合、numLit を直接確認にゃん
      if v.isNatLit? then
        match v.isNatLit?? with
        | some 1 => some <$> `(Signaculum.Sakura.nexaDressup $c $p (Option.some Bool.true))
        | some 0 => some <$> `(Signaculum.Sakura.nexaDressup $c $p (Option.some Bool.false))
        | _      => throwErrorAt stx "\\![bind,...] の值は 0 か 1 のみにゃ"
      else
        -- 式として渡す — 實行時に檢證されるにゃ
        throwErrorAt stx "\\![bind,...] の值は 0 か 1 のみにゃ"
  | _ => throwErrorAt stx "\\![bind,...] は引數2〜3つ (cat,part[,0/1]) にゃ"

-- ════════════════════════════════════════════════════
--  統合派遣にゃん♪
-- ════════════════════════════════════════════════════

/-- set / bind / enter / leave / lock 等の設定系タグの統合派遣關數にゃん。
    Fenestra.lean から呼ばれるにゃ -/
def expandeConfiguratioEtc (imperium : String) (args : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match imperium with
  | "set" =>
    if args.size == 0 then return none
    let subCmd := argAdNomenC args[0]!
    match subCmd with
    | none => return none
    | some sc =>
      let rest := args.extract 1 args.size
      resolveSet sc rest stx
  | "bind" =>
    resolveBind args stx
  | _ => return none

end Signaculum.Notatio.Expande
