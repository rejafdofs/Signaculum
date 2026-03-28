-- Signaculum.Notatio.Expande.Systema.Rete
-- HTTP・ネットワーク・實行系タグのディスパッチにゃん♪
-- execute 系サブコマンドを扱ふにゃ

import Lean
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio.Expande.Systema

open Lean Elab Term

-- ════════════════════════════════════════════════════
--  補助函數 (Functiones Auxiliares Retis)
-- ════════════════════════════════════════════════════

/-- 識別子やアトムから文字列値を取り出すにゃん -/
private def extractIdentValRete (s : Lean.Syntax) : Option String :=
  if s.isIdent then
    some (s.getId.toString (escape := false))
  else match s.isAtom with
  | true  => some s.getAtomVal
  | false => none

/-- 文字列リテラルを期待して取り出すにゃん -/
private def expectaStrLitRete (s : Lean.Syntax) (nomenSigni : String)
    : TermElabM (Lean.TSyntax `str) := do
  match s.isStrLit? with
  | some _ => pure ⟨s⟩
  | none   => throwErrorAt s s!"{nomenSigni}: 文字列が期待されてゐますにゃ"

-- ════════════════════════════════════════════════════
--  execute サブコマンドディスパッチ (Dispatch Executionis)
-- ════════════════════════════════════════════════════

/-- `\![execute,...]` のサブコマンドを展開するにゃん♪
    `args[0]` がサブコマンド名（"http-get" 等）、殘りが引數にゃ -/
def expandeExecutio (args : Array Lean.Syntax) (stx : Lean.Syntax)
    : TermElabM (Option (TSyntax `term)) := do
  if args.size < 1 then
    throwErrorAt stx "\\![execute,...]: サブコマンドが必要にゃ"
  let sub := match extractIdentValRete args[0]! with
    | some v => v
    | none   => ""
  match sub with

  -- ────────────────────────────────────────────────
  --  HTTP メソッドにゃん
  -- ────────────────────────────────────────────────

  | "http-get" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,http-get,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,http-get]"
    pure <| some (← `(Signaculum.Sakura.executaHttpGet $u))

  | "http-post" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,http-post,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,http-post]"
    pure <| some (← `(Signaculum.Sakura.executaHttpPost $u))

  | "http-head" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,http-head,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,http-head]"
    pure <| some (← `(Signaculum.Sakura.executaHttpHead $u))

  | "http-put" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,http-put,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,http-put]"
    pure <| some (← `(Signaculum.Sakura.executaHttpPut $u))

  | "http-delete" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,http-delete,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,http-delete]"
    pure <| some (← `(Signaculum.Sakura.executaHttpDelete $u))

  | "http-patch" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,http-patch,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,http-patch]"
    pure <| some (← `(Signaculum.Sakura.executaHttpPatch $u))

  | "http-options" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,http-options,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,http-options]"
    pure <| some (← `(Signaculum.Sakura.executaHttpOptions $u))

  -- ────────────────────────────────────────────────
  --  RSS にゃん
  -- ────────────────────────────────────────────────

  | "rss-get" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,rss-get,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,rss-get]"
    pure <| some (← `(Signaculum.Sakura.executaRssGet $u))

  | "rss-post" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,rss-post,...]: URL が必要にゃ"
    let u ← expectaStrLitRete args[1]! "\\![execute,rss-post]"
    pure <| some (← `(Signaculum.Sakura.executaRssPost $u))

  -- ────────────────────────────────────────────────
  --  ヘッドライン・DNS・PING にゃん
  -- ────────────────────────────────────────────────

  | "headline" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,headline,...]: 名前が必要にゃ"
    let n ← expectaStrLitRete args[1]! "\\![execute,headline]"
    pure <| some (← `(Signaculum.Sakura.executaHeadline $n))

  | "nslookup" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,nslookup,...]: パラメータが必要にゃ"
    let p ← expectaStrLitRete args[1]! "\\![execute,nslookup]"
    pure <| some (← `(Signaculum.Sakura.executaNslookup [$p]))

  | "ping" =>
    if args.size < 2 then
      throwErrorAt stx "\\![execute,ping,...]: パラメータが必要にゃ"
    let p ← expectaStrLitRete args[1]! "\\![execute,ping]"
    pure <| some (← `(Signaculum.Sakura.executaPing [$p]))

  -- ────────────────────────────────────────────────
  --  ダンプ・インストール・作成にゃん
  -- ────────────────────────────────────────────────

  | "dumpsurface" =>
    if args.size < 7 then
      throwErrorAt stx "\\![execute,dumpsurface,...]: dir, scope, list, prefix, event, zero の6引數が必要にゃ"
    let d ← expectaStrLitRete args[1]! "\\![execute,dumpsurface]"
    let s : TSyntax `term := ⟨args[2]!⟩
    let l ← expectaStrLitRete args[3]! "\\![execute,dumpsurface]"
    let p ← expectaStrLitRete args[4]! "\\![execute,dumpsurface]"
    let e ← expectaStrLitRete args[5]! "\\![execute,dumpsurface]"
    let z : TSyntax `term := ⟨args[6]!⟩
    pure <| some (← `(Signaculum.Sakura.executaDumpSuperficiei $d $s $l $p $e $z))

  | "install" =>
    -- install の後にさらにサブコマンドがあるにゃん
    if args.size < 2 then
      throwErrorAt stx "\\![execute,install,...]: サブコマンドが必要にゃ"
    let installSub := match extractIdentValRete args[1]! with
      | some v => v
      | none   => ""
    match installSub with
    | "url" =>
      if args.size < 4 then
        throwErrorAt stx "\\![execute,install,url,...]: URL, type の2引數が必要にゃ"
      let u ← expectaStrLitRete args[2]! "\\![execute,install,url]"
      let t ← expectaStrLitRete args[3]! "\\![execute,install,url]"
      pure <| some (← `(Signaculum.Sakura.executaInstallationemUrl $u $t))
    | "path" =>
      if args.size < 3 then
        throwErrorAt stx "\\![execute,install,path,...]: パスが必要にゃ"
      let v ← expectaStrLitRete args[2]! "\\![execute,install,path]"
      pure <| some (← `(Signaculum.Sakura.executaInstallationemVia $v))
    | other =>
      throwErrorAt stx s!"\\![execute,install,{other},...]: 未知のサブコマンドにゃ"

  | "createupdatedata" =>
    pure <| some (← `(Signaculum.Sakura.executaCreationemUpdateData))

  | "createnar" =>
    pure <| some (← `(Signaculum.Sakura.executaCreationemNar))

  | "emptyrecyclebin" =>
    pure <| some (← `(Signaculum.Sakura.evacuaRecyclatorium))

  | other =>
    throwErrorAt stx s!"\\![execute,{other},...]: 未知のサブコマンドにゃ"

end Signaculum.Notatio.Expande.Systema
