-- Signaculum.Notatio.Expande.Fenestra.Aperitio
-- 窓の開閉タグを捌く派遣にゃん♪
-- \![open,...] と \![close,...] をぜんぶ此處で面倒みるにゃ

import Lean
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio.Expande

open Lean Elab Term

/-- 引數が ident なら getId.toString (false) で名前を取るにゃ -/
private def argAdNomenA (arg : Syntax) : Option String :=
  if arg.isIdent then
    some (arg.getId.toString false)
  else match arg with
  | Syntax.node _ ``Lean.Parser.Term.str #[Syntax.atom _ v] =>
    let s := v.drop 1 |>.dropRight 1
    some s
  | _ => none

-- ════════════════════════════════════════════════════
--  open にゃん♪ 固定名ウィンドウ (Fenestrae Fixae)
-- ════════════════════════════════════════════════════

/-- 固定名の open ウィンドウ名を FenestraAperibilis コンストラクタにゃん -/
private def resolveOpenFixum (nomen : String) : TermElabM (Option (TSyntax `term)) :=
  match nomen with
  | "console"                  => some <$> `(Signaculum.Sakura.aperi .console)
  | "communicatebox"           => some <$> `(Signaculum.Sakura.aperi .arcaCommunicationis)
  | "teachbox"                 => some <$> `(Signaculum.Sakura.aperi .arcaDoctrinae)
  | "makebox"                  => some <$> `(Signaculum.Sakura.aperi .arcaFabricationis)
  | "ghostexplorer"            => some <$> `(Signaculum.Sakura.aperi .exploratorFantasmatis)
  | "shellexplorer"            => some <$> `(Signaculum.Sakura.aperi .exploratorTegumenti)
  | "balloonexplorer"          => some <$> `(Signaculum.Sakura.aperi .exploratorBullae)
  | "surfacetest"              => some <$> `(Signaculum.Sakura.aperi .probatioSuperficiei)
  | "headlinesensorexplorer"   => some <$> `(Signaculum.Sakura.aperi .exploratorHeadlineae)
  | "pluginexplorer"           => some <$> `(Signaculum.Sakura.aperi .exploratorModulorum)
  | "rateofusegraph"           => some <$> `(Signaculum.Sakura.aperi .graphumUsus)
  | "rateofusegraphballoon"    => some <$> `(Signaculum.Sakura.aperi .graphumUsusBullae)
  | "rateofusegraphtotal"      => some <$> `(Signaculum.Sakura.aperi .graphumUsusTotal)
  | "calendar"                 => some <$> `(Signaculum.Sakura.aperi .calendarium)
  | "messenger"                => some <$> `(Signaculum.Sakura.aperi .nuntium)
  | "readme"                   => some <$> `(Signaculum.Sakura.aperi .readme)
  | "terms"                    => some <$> `(Signaculum.Sakura.aperi .conditiones)
  | "aigraph"                  => some <$> `(Signaculum.Sakura.aperi .graphumAI)
  | "developer"                => some <$> `(Signaculum.Sakura.aperi .palettaDeveloper)
  | "shiorirequest"            => some <$> `(Signaculum.Sakura.aperi .petitioShiori)
  | "dressupexplorer"          => some <$> `(Signaculum.Sakura.aperi .exploratorDressupi)
  | _ => return none

-- ════════════════════════════════════════════════════
--  open — 引數付きにゃん (Cum Argumentis)
-- ════════════════════════════════════════════════════

/-- `\![open,browser,"url"]` 等の引數付き open を捌くにゃん -/
private def resolveOpenCumArgs (subCmd : String) (rest : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match subCmd with
  | "browser" =>
    if rest.size == 1 then
      let u := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.navigator $u))
    else throwErrorAt stx "\\![open,browser,...] は URL 引數1つにゃ"
  | "mailer" =>
    if rest.size == 1 then
      let a := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.nuntiatorem $a))
    else throwErrorAt stx "\\![open,mailer,...] はアドレス引數1つにゃ"
  | "explorer" =>
    if rest.size == 1 then
      let v := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.explorator $v))
    else throwErrorAt stx "\\![open,explorer,...] はパス引數1つにゃ"
  | "configurationdialog" =>
    if rest.size == 1 then
      let i := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.configuratio $i))
    else throwErrorAt stx "\\![open,configurationdialog,...] は ID 引數1つにゃ"
  | "file" =>
    if rest.size == 1 then
      let v := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.fasciculum $v))
    else throwErrorAt stx "\\![open,file,...] はパス引數1つにゃ"
  | "help" =>
    if rest.size == 1 then
      let i := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.auxilium $i))
    else throwErrorAt stx "\\![open,help,...] は ID 引數1つにゃ"
  | "dialog" =>
    if rest.size == 1 then
      let m := rest[0]!
      some <$> `(Signaculum.Sakura.aperiDialogum $m)
    else throwErrorAt stx "\\![open,dialog,...] は引數1つにゃ"
  | "editor" =>
    match rest.size with
    | 1 =>
      let v := rest[0]!
      some <$> `(Signaculum.Sakura.aperiEditorem $v)
    | 2 =>
      let v := rest[0]!; let l := rest[1]!
      some <$> `(Signaculum.Sakura.aperiEditorem $v $l)
    | _ => throwErrorAt stx "\\![open,editor,...] は引數1〜2つにゃ"
  -- 入力ダイアログ拡張にゃん♪ (Extensio Ingressuum)
  | "dateinput" =>
    if rest.size == 5 then
      let cb := rest[0]!; let title := rest[1]!
      let y := rest[2]!; let m := rest[3]!; let d := rest[4]!
      some <$> `(Signaculum.Sakura.aperiInputumDiei (show String from $cb) (show String from $title) $y $m $d)
    else throwErrorAt stx "\\![open,dateinput,...] は引數5つ (cb,title,y,m,d) にゃ"
  | "timeinput" =>
    if rest.size == 5 then
      let cb := rest[0]!; let title := rest[1]!
      let h := rest[2]!; let m := rest[3]!; let s := rest[4]!
      some <$> `(Signaculum.Sakura.aperiInputumTemporis (show String from $cb) (show String from $title) $h $m $s)
    else throwErrorAt stx "\\![open,timeinput,...] は引數5つ (cb,title,h,m,s) にゃ"
  | "sliderinput" =>
    if rest.size == 5 then
      let cb := rest[0]!; let title := rest[1]!
      let mn := rest[2]!; let mx := rest[3]!; let init := rest[4]!
      some <$> `(Signaculum.Sakura.aperiInputumGradus (show String from $cb) (show String from $title) $mn $mx $init)
    else throwErrorAt stx "\\![open,sliderinput,...] は引數5つ (cb,title,min,max,init) にゃ"
  | "ipinput" =>
    if rest.size == 6 then
      let cb := rest[0]!; let title := rest[1]!
      let a := rest[2]!; let b := rest[3]!; let c := rest[4]!; let d := rest[5]!
      some <$> `(Signaculum.Sakura.aperiInputumIP (show String from $cb) (show String from $title) $a $b $c $d)
    else throwErrorAt stx "\\![open,ipinput,...] は引數6つ (cb,title,a,b,c,d) にゃ"
  | _ => return none

-- ════════════════════════════════════════════════════
--  close にゃん♪ (Claudere)
-- ════════════════════════════════════════════════════

/-- `\![close,...]` を捌くにゃん -/
private def resolveClose (subCmd : String) (rest : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match subCmd with
  | "console"        => some <$> `(Signaculum.Sakura.claude .console)
  | "inputum"        => some <$> `(Signaculum.Sakura.claude .inputum)
  | "communicatebox" => some <$> `(Signaculum.Sakura.claude .arcaCommunicationis)
  | "teachbox"       => some <$> `(Signaculum.Sakura.claude .arcaDoctrinae)
  | "dialog" =>
    if rest.size == 1 then
      let i := rest[0]!
      some <$> `(Signaculum.Sakura.claudeDialogum $i)
    else throwErrorAt stx "\\![close,dialog,...] は ID 引數1つにゃ"
  | _ => return none

-- ════════════════════════════════════════════════════
--  統合派遣にゃん♪
-- ════════════════════════════════════════════════════

/-- open / close タグの統合派遣關數にゃん。
    Fenestra.lean から呼ばれるにゃ -/
def expandeApertioEtc (imperium : String) (args : Array Syntax) (stx : Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match imperium with
  | "open" =>
    if args.size == 0 then return none
    let subCmd := argAdNomenA args[0]!
    match subCmd with
    | none => return none
    | some sc =>
      -- まづ固定名ウィンドウを試すにゃ
      if args.size == 1 then
        if let some r ← resolveOpenFixum sc then return some r
      -- 次に引數付きウィンドウにゃ
      let rest := args.extract 1 args.size
      resolveOpenCumArgs sc rest stx
  | "close" =>
    if args.size == 0 then return none
    let subCmd := argAdNomenA args[0]!
    match subCmd with
    | none => return none
    | some sc =>
      let rest := args.extract 1 args.size
      resolveClose sc rest stx
  | _ => return none

end Signaculum.Notatio.Expande
