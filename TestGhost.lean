-- TestGhost: Signaculum のコア API をテストするにゃん
-- DSL マクロ（Syntaxis）は LemmaGeneralis の証明依存のため迂回するにゃ

import Signaculum.Protocollum
import Signaculum.Sakura.Scriptum
import Signaculum.Nucleus
import Signaculum.Sstp
import Signaculum.Elementa.Varia

open Signaculum
open Signaculum.Nucleus
open Signaculum.Sakura

-- ═══════════════════════════════════════════════════
-- 事象處理器を直接定義するにゃん（DSL マクロなし版）
-- ═══════════════════════════════════════════════════

def tractatorInInceptione : Tractator := fun _req => do
  sakura
  superficies 0
  loqui "起動にゃ！テストゴーストにゃん♪"
  linea
  mora 500
  kero
  superficies 10
  loqui "よろしくにゃ。"
  finis

def tractatorInClausura : Tractator := fun _req => do
  sakura
  superficies 0
  loqui "またにゃ〜♪"
  linea
  mora 300
  loqui "\\-"
  finis

def tractatorMusDupliciPulsu : Tractator := fun req => do
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

initialize (Signaculum.Nucleus.registraShiori [
  ("OnBoot", tractatorInInceptione),
  ("OnClose", tractatorInClausura),
  ("OnMouseDoubleClick", tractatorMusDupliciPulsu)
])

-- ═══════════════════════════════════════════════════
-- 純粹テスト: SakuraPura で SakuraScript を生成してみるにゃん
-- ═══════════════════════════════════════════════════

/-- 純粹な SakuraScript 生成のテストにゃん -/
def testumPurumSakura : String := Id.run do
  Sakura.currereScriptum do
    sakura
    superficies 0
    loqui "テストにゃ！"
    linea
    mora 200
    kero
    loqui "テスト完了にゃ。"
    finis

-- ═══════════════════════════════════════════════════
-- エントリーポイントにゃん
-- ═══════════════════════════════════════════════════

def main : IO Unit := do
  IO.println "=== TestGhost ==="
  IO.println s!"SakuraScript 生成テスト:\n{testumPurumSakura}"
  let registrata ← Signaculum.Nucleus.estRegistrata
  IO.println s!"栞登錄狀態: {registrata}"

