-- Signaculum.Notatio.Expande.Fenestra.Aperitio
-- 窓の開閉タグを捌く派遣にゃん♪
-- \![open,...] と \![close,...] をぜんぶ此處で面倒みるにゃ

import Lean
import Signaculum.Sakura.Scriptum
import Signaculum.Syntaxis

namespace Signaculum.Notatio.Expande.Fenestra

open Lean Elab Term Meta

/-- 引數が ident なら getId.toString (false) で名前を取るにゃ -/
private def argAdNomenA (arg : Syntax) : Option String :=
  if arg.isIdent then
    some (arg.getId.toString false)
  else match arg with
  | Syntax.node _ ``Lean.Parser.Term.str #[Syntax.atom _ v] =>
    let s := (v.drop 1 |>.dropEnd 1).toString
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
--  コールバック解決にゃん♪ (Resolutio Callbacki)
-- ════════════════════════════════════════════════════

/-- cb 構文ノードからイヴェント名文字列の term とパラメータ型配列を作るにゃ。
    strLit → そのまま（型情報なし）、ident → registraLazium（型取得＋paramCount檢證）、
    項 → elaborate して型取得＋paramCount檢證 → registraLaziumLambda -/
private def resolveCallbackum (cb : Syntax) (paramCount : Nat := 1)
    : TermElabM (TSyntax `term × Array Lean.Expr) := do
  if cb.isStrLit?.isSome then
    let stx : TSyntax `term := ⟨cb⟩
    return (stx, #[])
  else if cb.isIdent then
    let ev ← Signaculum.registraLazium ⟨cb⟩
    let fname ← Signaculum.resolveToConst ⟨cb⟩
    let some info := (← getEnv).find? fname |
      throwError "resolveCallbackum: {cb} が見つからにゃいにゃ"
    let paramTypes ← Signaculum.getExplicitParamTypes info.type
    if paramTypes.size != paramCount then
      throwError "\\![open,...]: コールバック {cb} は {paramTypes.size} 引數ですが、このウィジェットは {paramCount} 個の Reference を返すにゃ"
    return (← `($(Syntax.mkStrLit ev)), paramTypes)
  else
    let cbExpr ← elabTerm cb none
    let cbType ← inferType cbExpr
    let paramTypes ← Signaculum.getExplicitParamTypes (← whnf cbType)
    if paramTypes.size != paramCount then
      throwError "\\![open,...]: コールバックは {paramTypes.size} 引數ですが、このウィジェットは {paramCount} 個の Reference を返すにゃ"
    let posIdx := (cb.getPos?.getD ⟨0⟩).byteIdx
    let ev ← Signaculum.registraLaziumLambda cb posIdx paramCount
    return (← `($(Syntax.mkStrLit ev)), paramTypes)

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
      some <$> `(Signaculum.Sakura.aperi (.navigator $(⟨u⟩)))
    else throwErrorAt stx "\\![open,browser,...] は URL 引數1つにゃ"
  | "mailer" =>
    if rest.size == 1 then
      let a := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.nuntiatorem $(⟨a⟩)))
    else throwErrorAt stx "\\![open,mailer,...] はアドレス引數1つにゃ"
  | "explorer" =>
    if rest.size == 1 then
      let v := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.explorator $(⟨v⟩)))
    else throwErrorAt stx "\\![open,explorer,...] はパス引數1つにゃ"
  | "configurationdialog" =>
    if rest.size == 1 then
      let i := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.configuratio $(⟨i⟩)))
    else throwErrorAt stx "\\![open,configurationdialog,...] は ID 引數1つにゃ"
  | "file" =>
    if rest.size == 1 then
      let v := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.fasciculum $(⟨v⟩)))
    else throwErrorAt stx "\\![open,file,...] はパス引數1つにゃ"
  | "help" =>
    if rest.size == 1 then
      let i := rest[0]!
      some <$> `(Signaculum.Sakura.aperi (.auxilium $(⟨i⟩)))
    else throwErrorAt stx "\\![open,help,...] は ID 引數1つにゃ"
  | "dialog" =>
    if rest.size == 1 then
      let m := rest[0]!
      some <$> `(Signaculum.Sakura.aperiDialogum $(⟨m⟩))
    else throwErrorAt stx "\\![open,dialog,...] は引數1つにゃ"
  | "editor" =>
    match rest.size with
    | 1 =>
      let v := rest[0]!
      some <$> `(Signaculum.Sakura.aperiEditorem $(⟨v⟩))
    | 2 =>
      let v := rest[0]!; let l := rest[1]!
      some <$> `(Signaculum.Sakura.aperiEditorem $(⟨v⟩) $(⟨l⟩))
    | _ => throwErrorAt stx "\\![open,editor,...] は引數1〜2つにゃ"
  -- 入力ダイアログ拡張にゃん♪ (Extensio Ingressuum)
  | "dateinput" =>
    if h : rest.size = 5 then
      let cb := rest[0]'(by omega); let title := rest[1]'(by omega)
      let y := rest[2]'(by omega); let m := rest[3]'(by omega); let d := rest[4]'(by omega)
      let (evStx, _) ← resolveCallbackum cb
      some <$> `(Signaculum.Sakura.aperiInputumDiei $evStx (show String from $(⟨title⟩)) $(⟨y⟩) $(⟨m⟩) $(⟨d⟩))
    else throwErrorAt stx "\\![open,dateinput,...] は引數5つ (f,title,y,m,d) にゃ"
  | "timeinput" =>
    if h : rest.size = 5 then
      let cb := rest[0]'(by omega); let title := rest[1]'(by omega)
      let hr := rest[2]'(by omega); let mi := rest[3]'(by omega); let se := rest[4]'(by omega)
      let (evStx, _) ← resolveCallbackum cb
      some <$> `(Signaculum.Sakura.aperiInputumTemporis $evStx (show String from $(⟨title⟩)) $(⟨hr⟩) $(⟨mi⟩) $(⟨se⟩))
    else throwErrorAt stx "\\![open,timeinput,...] は引數5つ (f,title,h,m,s) にゃ"
  | "sliderinput" =>
    if h : rest.size = 5 then
      let cb := rest[0]'(by omega); let title := rest[1]'(by omega)
      let mn := rest[2]'(by omega); let mx := rest[3]'(by omega); let init := rest[4]'(by omega)
      let (evStx, _) ← resolveCallbackum cb
      some <$> `(Signaculum.Sakura.aperiInputumGradus $evStx (show String from $(⟨title⟩)) $(⟨mn⟩) $(⟨mx⟩) $(⟨init⟩))
    else throwErrorAt stx "\\![open,sliderinput,...] は引數5つ (f,title,min,max,init) にゃ"
  | "ipinput" =>
    if h : rest.size = 6 then
      let cb := rest[0]'(by omega); let title := rest[1]'(by omega)
      let a := rest[2]'(by omega); let b := rest[3]'(by omega)
      let c := rest[4]'(by omega); let d := rest[5]'(by omega)
      let (evStx, _) ← resolveCallbackum cb
      some <$> `(Signaculum.Sakura.aperiInputumIP $evStx (show String from $(⟨title⟩)) $(⟨a⟩) $(⟨b⟩) $(⟨c⟩) $(⟨d⟩))
    else throwErrorAt stx "\\![open,ipinput,...] は引數6つ (f,title,a,b,c,d) にゃ"
  | "colorinput" =>
    if h : rest.size = 5 then
      let cb := rest[0]'(by omega); let title := rest[1]'(by omega)
      let r := rest[2]'(by omega); let g := rest[3]'(by omega); let b := rest[4]'(by omega)
      let (evStx, _) ← resolveCallbackum cb
      some <$> `(Signaculum.Sakura.aperiInputumColoris $evStx (show String from $(⟨title⟩)) $(⟨r⟩) $(⟨g⟩) $(⟨b⟩))
    else throwErrorAt stx "\\![open,colorinput,...] は引數5つ (f,title,r,g,b) にゃ"
  | "inputbox" | "passwordinput" =>
    let modusStx ← if subCmd == "inputbox"
      then `(Signaculum.Sakura.ModusInputiTextus.simplex)
      else `(Signaculum.Sakura.ModusInputiTextus.sigillum)
    if h : rest.size = 2 ∨ rest.size = 3 then
      let cb := rest[0]'(by omega); let title := rest[1]'(by omega)
      let textStx : TSyntax `term ← if h3 : rest.size = 3
        then pure ⟨rest[2]'(by omega)⟩ else `("")
      let (evStx, _) ← resolveCallbackum cb
      some <$> `(Signaculum.Sakura.aperiInputum $modusStx $evStx
        (show String from $(⟨title⟩)) (show String from $textStx))
    else throwErrorAt stx s!"\\![open,{subCmd},...] は引數2〜3つ (f,title[,text]) にゃ"
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
      some <$> `(Signaculum.Sakura.claudeDialogum $(⟨i⟩))
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

end Signaculum.Notatio.Expande.Fenestra
