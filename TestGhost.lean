-- TestGhost: Signaculum のコア API をテストするにゃん
-- DSL マクロ（Syntaxis）は LemmaGeneralis の証明依存のため迂回するにゃ

import Signaculum.Protocollum
import Signaculum.Sakura.Scriptum
import Signaculum.Nucleus
import Signaculum.Sstp
import Signaculum.Varia

open Signaculum
open Signaculum.Sakura

-- ═══════════════════════════════════════════════════
-- 事象處理器を直接定義するにゃん（DSL マクロなし版）
-- ═══════════════════════════════════════════════════

def tractatorOnBoot : Tractator := fun _req => do
  sakura
  superficies 0
  loqui "起動にゃ！テストゴーストにゃん♪"
  linea
  mora 500
  kero
  superficies 10
  loqui "よろしくにゃ。"
  finis

def tractatorOnClose : Tractator := fun _req => do
  sakura
  superficies 0
  loqui "またにゃ〜♪"
  linea
  mora 300
  loqui "\\-"
  finis

def tractatorOnMouseDoubleClick : Tractator := fun req => do
  let scopus := (req.referentiam 3).getD ""
  sakura
  superficies 5
  if scopus == "0" then
    loqui "觸らないでにゃ〜"
  else
    loqui "うにゃ？"
  linea
  finis

-- ═══════════════════════════════════════════════════
-- 栞を登錄するにゃん（construe マクロの代はりに手動登錄）
-- ═══════════════════════════════════════════════════

initialize (Signaculum.registraShiori [
  ("OnBoot", tractatorOnBoot),
  ("OnClose", tractatorOnClose),
  ("OnMouseDoubleClick", tractatorOnMouseDoubleClick)
])

-- ═══════════════════════════════════════════════════
-- 純粹テスト: SakuraPura で SakuraScript を生成してみるにゃん
-- ═══════════════════════════════════════════════════

/-- 純粹な SakuraScript 生成のテストにゃん -/
def testPuraSakura : String := Id.run do
  Sakura.currere do
    sakura
    superficies 0
    loqui "テストにゃ！"
    linea
    mora 200
    kero
    loqui "テスト完了にゃ。"
    finis

-- コンパイル時チェック
#eval! do
  let sakura := testPuraSakura
  IO.println s!"=== SakuraScript 生成テスト ==="
  IO.println sakura
  IO.println ""
  IO.println s!"=== Responsum フォーマットテスト ==="
  let resp := Responsum.ok "\\h\\s[0]テストにゃ\\e"
  IO.println resp.adProtocollum
  IO.println s!"=== Rogatio パーステスト ==="
  let reqStr := "GET SHIORI/3.0\r\nID: OnBoot\r\nReference0: installed\r\nCharset: UTF-8\r\n\r\n"
  match Rogatio.interpreta reqStr with
  | .ok r =>
    IO.println s!"methodus: {r.methodus.adCatenam}"
    IO.println s!"nomen: {r.nomen}"
    IO.println s!"ref0: {r.referentiam 0}"
    IO.println s!"charset: {r.forma}"
  | .error e => IO.println s!"Parse error: {e}"
  IO.println ""
  IO.println s!"=== 全テスト完了 ==="
