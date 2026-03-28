-- Signaculum.Notatio.Expande.Systema.Reliqua
-- 殘餘のシステムタグにゃん♪
-- call/change/update/reload/unload/load/bind/effect/biff/set/get/filter/wait 等にゃ

import Lean
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio.Expande

open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares Reliquorum)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentValReliqua (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some (s.getId.toString (escape := false))
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

/-- 文字列リテラルを期待して取り出すにゃん -/
private def expectaStrLitReliqua (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `str) := do
  match s.isStrLit? with
  | some _ => pure ⟨s⟩
  | none   => throwErrorAt s s!"{nomenSigni}: 文字列が期待されてゐますにゃ"

/-- 數値リテラルを取得するにゃん -/
private def getNatValReliqua (s : Lean.Syntax) : Option Nat :=
  match s.isNatLit? with
  | some n => some n
  | none   => none

-- ════════════════════════════════════════════════════
--  殘餘ディスパッチ (Dispatch Reliquorum)
-- ════════════════════════════════════════════════════

/-- call/change/update/reload 等の殘餘タグを展開するにゃん♪
    `imperium` は最初のカンマ區切り部分、`args` は殘りの引數配列にゃ -/
def expandeReliqua (imperium : String) (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  match imperium with

  -- ────────────────────────────────────────────────
  --  call 系にゃん
  -- ────────────────────────────────────────────────

  | "call" =>
    if args.size < 1 then
      throwErrorAt stx "\\![call,...]: サブコマンドが必要にゃ"
    let sub := match extractIdentValReliqua args[0]! with
      | some v => v
      | none   => ""
    match sub with
    | "shiori" =>
      if args.size < 2 then
        throwErrorAt stx "\\![call,shiori,...]: イヴェント名が必要にゃ"
      let e ← expectaStrLitReliqua args[1]! "\\![call,shiori]"
      pure <| some (← `(Signaculum.Sakura.vocaShiori $e))
    | "saori" =>
      if args.size < 3 then
        throwErrorAt stx "\\![call,saori,...]: DLL パスと關數名が必要にゃ"
      let d ← expectaStrLitReliqua args[1]! "\\![call,saori]"
      let f ← expectaStrLitReliqua args[2]! "\\![call,saori]"
      pure <| some (← `(Signaculum.Sakura.vocaSaori $d $f))
    | "ghost" =>
      if args.size < 2 then
        throwErrorAt stx "\\![call,ghost,...]: ゴースト名が必要にゃ"
      let n ← expectaStrLitReliqua args[1]! "\\![call,ghost]"
      pure <| some (← `(Signaculum.Sakura.vocaGhost $n))
    | other =>
      throwErrorAt stx s!"\\![call,{other},...]: 未知のサブコマンドにゃ"

  -- ────────────────────────────────────────────────
  --  change 系にゃん
  -- ────────────────────────────────────────────────

  | "change" =>
    if args.size < 1 then
      throwErrorAt stx "\\![change,...]: サブコマンドが必要にゃ"
    let sub := match extractIdentValReliqua args[0]! with
      | some v => v
      | none   => ""
    match sub with
    | "ghost" =>
      if args.size < 2 then
        throwErrorAt stx "\\![change,ghost,...]: ゴースト名が必要にゃ"
      let n ← expectaStrLitReliqua args[1]! "\\![change,ghost]"
      pure <| some (← `(Signaculum.Sakura.mutaGhostNomen $n))
    | "shell" =>
      if args.size < 2 then
        throwErrorAt stx "\\![change,shell,...]: シェル名が必要にゃ"
      let n ← expectaStrLitReliqua args[1]! "\\![change,shell]"
      pure <| some (← `(Signaculum.Sakura.mutaShell $n))
    | "balloon" =>
      if args.size < 2 then
        throwErrorAt stx "\\![change,balloon,...]: 吹出し名が必要にゃ"
      let n ← expectaStrLitReliqua args[1]! "\\![change,balloon]"
      pure <| some (← `(Signaculum.Sakura.mutaBullam $n))
    | other =>
      throwErrorAt stx s!"\\![change,{other},...]: 未知のサブコマンドにゃ"

  -- ────────────────────────────────────────────────
  --  引數なし命令にゃん
  -- ────────────────────────────────────────────────

  | "updatebymyself"  => pure <| some (← `(Signaculum.Sakura.renovaSeIpsum))
  | "vanishbymyself"  => pure <| some (← `(Signaculum.Sakura.evanesceSeIpsum))
  | "executesntp"     => pure <| some (← `(Signaculum.Sakura.executaSNTP))
  | "reloadsurface"   => pure <| some (← `(Signaculum.Sakura.renovaSuperficiem))

  -- ────────────────────────────────────────────────
  --  reload にゃん
  -- ────────────────────────────────────────────────

  | "reload" =>
    if args.size < 1 then
      throwErrorAt stx "\\![reload,...]: 對象が必要にゃ"
    let s : TSyntax `term := ⟨args[0]!⟩
    pure <| some (← `(Signaculum.Sakura.renova $s))

  -- ────────────────────────────────────────────────
  --  unload/load にゃん
  -- ────────────────────────────────────────────────

  | "unload" =>
    if args.size < 1 then
      throwErrorAt stx "\\![unload,...]: 對象が必要にゃ"
    let sub := match extractIdentValReliqua args[0]! with
      | some v => v
      | none   => ""
    match sub with
    | "shiori" => pure <| some (← `(Signaculum.Sakura.expelleShiori))
    | "makoto" => pure <| some (← `(Signaculum.Sakura.expelleMakoto))
    | other    => throwErrorAt stx s!"\\![unload,{other}]: 未知の對象にゃ"

  | "load" =>
    if args.size < 1 then
      throwErrorAt stx "\\![load,...]: 對象が必要にゃ"
    let sub := match extractIdentValReliqua args[0]! with
      | some v => v
      | none   => ""
    match sub with
    | "shiori" => pure <| some (← `(Signaculum.Sakura.oneraSHIORI))
    | "makoto" => pure <| some (← `(Signaculum.Sakura.oneraMakoto))
    | other    => throwErrorAt stx s!"\\![load,{other}]: 未知の對象にゃ"

  -- ────────────────────────────────────────────────
  --  bind — 着替へにゃん（0/1 の驗證つきにゃ）
  -- ────────────────────────────────────────────────

  | "bind" =>
    if args.size == 2 then
      -- \![bind, c, p] — トグル形式にゃん
      let c ← expectaStrLitReliqua args[0]! "\\![bind]"
      let p ← expectaStrLitReliqua args[1]! "\\![bind]"
      pure <| some (← `(Signaculum.Sakura.nexaDressup $c $p Option.none))
    else if args.size >= 3 then
      -- \![bind, c, p, v] — 明示的値にゃん
      let c ← expectaStrLitReliqua args[0]! "\\![bind]"
      let p ← expectaStrLitReliqua args[1]! "\\![bind]"
      match getNatValReliqua args[2]! with
      | some 1 => pure <| some (← `(Signaculum.Sakura.nexaDressup $c $p (Option.some Bool.true)))
      | some 0 => pure <| some (← `(Signaculum.Sakura.nexaDressup $c $p (Option.some Bool.false)))
      | _      => throwErrorAt args[2]! "\\![bind,...] の値は 0 か 1 のみにゃ"
    else
      throwErrorAt stx "\\![bind,...]: category, part の2引數が最低必要にゃ"

  -- ────────────────────────────────────────────────
  --  effect / effect2 にゃん
  -- ────────────────────────────────────────────────

  | "effect" =>
    if args.size < 3 then
      throwErrorAt stx "\\![effect,...]: plugin, speed, parameter の3引數が必要にゃ"
    let p ← expectaStrLitReliqua args[0]! "\\![effect]"
    let s : TSyntax `term := ⟨args[1]!⟩
    let r ← expectaStrLitReliqua args[2]! "\\![effect]"
    pure <| some (← `(Signaculum.Sakura.applicaEffectum $p $s $r))

  | "effect2" =>
    if args.size < 4 then
      throwErrorAt stx "\\![effect2,...]: id, plugin, speed, parameter の4引數が必要にゃ"
    let i : TSyntax `term := ⟨args[0]!⟩
    let p ← expectaStrLitReliqua args[1]! "\\![effect2]"
    let s : TSyntax `term := ⟨args[2]!⟩
    let r ← expectaStrLitReliqua args[3]! "\\![effect2]"
    pure <| some (← `(Signaculum.Sakura.applicaEffectum2 $i $p $s $r))

  -- ────────────────────────────────────────────────
  --  biff — 郵便確認にゃん
  -- ────────────────────────────────────────────────

  | "biff" =>
    if args.size < 1 then
      throwErrorAt stx "\\![biff,...]: アカウント名が必要にゃ"
    let a ← expectaStrLitReliqua args[0]! "\\![biff]"
    pure <| some (← `(Signaculum.Sakura.exploraPostam $a))

  -- ────────────────────────────────────────────────
  --  set 系にゃん
  -- ────────────────────────────────────────────────

  | "set" =>
    if args.size < 1 then
      throwErrorAt stx "\\![set,...]: サブコマンドが必要にゃ"
    let sub := match extractIdentValReliqua args[0]! with
      | some v => v
      | none   => ""
    match sub with
    | "property" =>
      if args.size < 3 then
        throwErrorAt stx "\\![set,property,...]: プロパティ名と値が必要にゃ"
      let p : TSyntax `term := ⟨args[1]!⟩
      let v ← expectaStrLitReliqua args[2]! "\\![set,property]"
      pure <| some (← `(Signaculum.Sakura.configuraProprietatem $p $v))

    | "otherghosttalk" =>
      if args.size < 2 then
        throwErrorAt stx "\\![set,otherghosttalk,...]: モードが必要にゃ"
      let m : TSyntax `term := ⟨args[1]!⟩
      pure <| some (← `(Signaculum.Sakura.configuraAliosGhostes $m))

    | "othersurfacechange" =>
      if args.size < 2 then
        throwErrorAt stx "\\![set,othersurfacechange,...]: 眞僞値が必要にゃ"
      let b : TSyntax `term := ⟨args[1]!⟩
      pure <| some (← `(Signaculum.Sakura.configuraAliasSuperficies $b))

    | "wallpaper" =>
      if args.size < 2 then
        throwErrorAt stx "\\![set,wallpaper,...]: ファイル名が必要にゃ"
      let v ← expectaStrLitReliqua args[1]! "\\![set,wallpaper]"
      if args.size == 2 then
        -- モード省略にゃん
        pure <| some (← `(Signaculum.Sakura.configuraTapete $v Option.none))
      else
        -- モード指定にゃん — キーワードを檢査するにゃ
        let modeStr := match extractIdentValReliqua args[2]! with
          | some v => v
          | none   => ""
        match modeStr with
        | "center"    => pure <| some (← `(Signaculum.Sakura.configuraTapete $v (Option.some .centrum)))
        | "tile"      => pure <| some (← `(Signaculum.Sakura.configuraTapete $v (Option.some .tessella)))
        | "stretch"   => pure <| some (← `(Signaculum.Sakura.configuraTapete $v (Option.some .extende)))
        | "stretch-x" => pure <| some (← `(Signaculum.Sakura.configuraTapete $v (Option.some .extendeX)))
        | "stretch-y" => pure <| some (← `(Signaculum.Sakura.configuraTapete $v (Option.some .extendeY)))
        | "span"      => pure <| some (← `(Signaculum.Sakura.configuraTapete $v (Option.some .spatium)))
        | other       =>
          throwErrorAt args[2]! s!"\\![set,wallpaper,...,{other}]: 未知のモードにゃ（center/tile/stretch/stretch-x/stretch-y/span が使へるにゃ）"

    | "shioridebugmode" =>
      pure <| some (← `(Signaculum.Sakura.configuraShioriDebug))

    | "choicetimeout" =>
      if args.size < 2 then
        throwErrorAt stx "\\![set,choicetimeout,...]: ミリ秒が必要にゃ"
      let ms : TSyntax `term := ⟨args[1]!⟩
      pure <| some (← `(Signaculum.Sakura.tempusOptionum $ms))

    | other =>
      throwErrorAt stx s!"\\![set,{other},...]: 未知のサブコマンドにゃ"

  -- ────────────────────────────────────────────────
  --  get 系にゃん
  -- ────────────────────────────────────────────────

  | "get" =>
    if args.size < 1 then
      throwErrorAt stx "\\![get,...]: サブコマンドが必要にゃ"
    let sub := match extractIdentValReliqua args[0]! with
      | some v => v
      | none   => ""
    match sub with
    | "property" =>
      if args.size < 3 then
        throwErrorAt stx "\\![get,property,...]: イヴェント名とプロパティが必要にゃ"
      let e ← expectaStrLitReliqua args[1]! "\\![get,property]"
      let p : TSyntax `term := ⟨args[2]!⟩
      pure <| some (← `(Signaculum.Sakura.legeProprietatem $e [$p]))
    | other =>
      throwErrorAt stx s!"\\![get,{other},...]: 未知のサブコマンドにゃ"

  -- ────────────────────────────────────────────────
  --  filter にゃん
  -- ────────────────────────────────────────────────

  | "filter" =>
    if args.size == 0 then
      -- \![filter] — フィルタ除去にゃん
      pure <| some (← `(Signaculum.Sakura.applicaFiltratum "" 0 ""))
    else if args.size >= 3 then
      let p ← expectaStrLitReliqua args[0]! "\\![filter]"
      let t : TSyntax `term := ⟨args[1]!⟩
      let r ← expectaStrLitReliqua args[2]! "\\![filter]"
      pure <| some (← `(Signaculum.Sakura.applicaFiltratum $p $t $r))
    else
      throwErrorAt stx "\\![filter,...]: plugin, time, parameter の3引數が必要にゃ"

  -- ────────────────────────────────────────────────
  --  wait,syncobject にゃん
  -- ────────────────────────────────────────────────

  | "wait" =>
    if args.size < 1 then
      throwErrorAt stx "\\![wait,...]: サブコマンドが必要にゃ"
    let sub := match extractIdentValReliqua args[0]! with
      | some v => v
      | none   => ""
    match sub with
    | "syncobject" =>
      if args.size < 3 then
        throwErrorAt stx "\\![wait,syncobject,...]: 名前とタイムアウトが必要にゃ"
      let n ← expectaStrLitReliqua args[1]! "\\![wait,syncobject]"
      let t : TSyntax `term := ⟨args[2]!⟩
      pure <| some (← `(Signaculum.Sakura.expectaSyncObjectum $n $t))
    | other =>
      throwErrorAt stx s!"\\![wait,{other},...]: 未知のサブコマンドにゃ"

  -- ────────────────────────────────────────────────
  --  update にゃん
  -- ────────────────────────────────────────────────

  | "update" =>
    if args.size < 1 then
      throwErrorAt stx "\\![update,...]: 對象が必要にゃ"
    let sub := match extractIdentValReliqua args[0]! with
      | some v => v
      | none   => ""
    match sub with
    | "platform" => pure <| some (← `(Signaculum.Sakura.renovaPlatformam))
    | other      => throwErrorAt stx s!"\\![update,{other}]: 未知の對象にゃ"

  | _ => pure none

end Signaculum.Notatio.Expande
