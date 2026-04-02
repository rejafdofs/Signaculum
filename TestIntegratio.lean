-- TestIntegratio: DSL マクロ統合テストにゃん
-- eventum / varia / scriptum! / construe の統合動作を檢證するにゃ
-- コンパイルが通ること自體がテストにゃん♪

import Signaculum

open Signaculum.Sakura.Textus
open Signaculum.Sakura (loqui)

-- ═══════════════════════════════════════════════════
-- §1 變數宣言 (varia)
-- ═══════════════════════════════════════════════════
varia perpetua numerusLoquendi : Nat := 0
varia temporaria nomenUtentis : String := ""

-- ═══════════════════════════════════════════════════
-- §2 def ベースコールバック用の關數定義
-- ═══════════════════════════════════════════════════
def colloquiumSimplex : SakuraIO Unit := do
  sakura; superficies 0; loqui "やあにゃん"; finis

def onTextumAcceptum (textus : String) : SakuraIO Unit := do
  sakura; loqui s!"入力: {textus}"; finis

def onSalutatio (nomen : String) (aetas : Nat) : SakuraIO Unit := do
  sakura; loqui s!"{nomen}({aetas})"; finis

def onMenuLoqui : SakuraIO Unit := do
  sakura; loqui "ランダムトークにゃ"; finis

def onTopicum (topicum : String) : SakuraIO Unit := do
  sakura; loqui s!"話題: {topicum}"; finis

-- ═══════════════════════════════════════════════════
-- §3 eventum（從來形: Tractator 直接）
-- ═══════════════════════════════════════════════════
eventum "OnBoot" fun _req => do
  sakura; superficies 0; loqui "起動テストにゃん♪"; finis

eventum "OnClose" fun _req => do
  sakura; loqui "終了にゃ"; finis

eventum "OnMouseDoubleClick" fun req => do
  let scopus := (req.referentiam 3).getD ""
  sakura
  if scopus == "0" then loqui "觸らないでにゃ" else loqui "うにゃ？"
  finis

-- ═══════════════════════════════════════════════════
-- §4 scriptum! 基本タグ（native_decide で出力檢證）
-- ═══════════════════════════════════════════════════
example : Id.run (currereScriptum (scriptum! \h \s[0] こんにちは \e)) = "\\h\\s[0]こんにちは\\e" := by native_decide
example : Id.run (currereScriptum (let s := "世界"; scriptum! \h {s} \e)) = "\\h世界\\e" := by native_decide
example : Id.run (currereScriptum (let v : Option String := some "あり"; scriptum! \h {v} \e)) = "\\hあり\\e" := by native_decide
example : Id.run (currereScriptum (let v : Option String := none; scriptum! \h {v} \e)) = "\\h\\e" := by native_decide
example : Id.run (currereScriptum (scriptum! \q[話す, "OnMenuTalk"])) = "\\q[話す,OnMenuTalk]" := by native_decide

-- ═══════════════════════════════════════════════════
-- §5 SakuraM Unit 恆等インスタンス（コンパイル通過＝テスト成功）
-- ═══════════════════════════════════════════════════
def colloquia : Array (SakuraIO Unit) := #[ colloquiumSimplex, colloquiumSimplex ]
def testumArraySakuraM : SakuraIO Unit := Signaculum.Notatio.Exhibibilis.exhibe colloquia

-- ═══════════════════════════════════════════════════
-- §6 \![raise,...] 型チェック（コンパイル通過＝型チェック成功）
-- ═══════════════════════════════════════════════════
def testumRaiseTypo : SakuraIO Unit := do scriptum! \![raise, onSalutatio, "シロ", 5]
-- コメントが食はれないことの檢證にゃん
def testumRaiseSimplex : SakuraIO Unit := do scriptum! \![raise, colloquiumSimplex]

/- ブロックコメントも食はれないにゃん -/
-- ═══════════════════════════════════════════════════
-- §7 \q 識別子形・引數附き形
-- ═══════════════════════════════════════════════════
def testumOptioIdent : SakuraIO Unit := do scriptum! \q[話す, onMenuLoqui]
def testumOptioRef : SakuraIO Unit := do scriptum! \q[話題A, onTopicum, "topicA"]

-- ═══════════════════════════════════════════════════
-- §8 \_a 錨（識別子形）
-- ═══════════════════════════════════════════════════
def testumAncora : SakuraIO Unit := do scriptum! \_a[onMenuLoqui] クリック \_a

-- ═══════════════════════════════════════════════════
-- §9 \__q 範圍選擇肢（識別子形）
-- ═══════════════════════════════════════════════════
def testumOptioScopus : SakuraIO Unit := do scriptum! \__q[onMenuLoqui] ここが選擇肢 \__q

-- ═══════════════════════════════════════════════════
-- §10 \![open,inputbox,...] paramCount 檢證
-- ═══════════════════════════════════════════════════
def testumInputbox : SakuraIO Unit := do scriptum! \![open, inputbox, onTextumAcceptum, "名前を入力"]

-- ═══════════════════════════════════════════════════
-- §11 construe（ラッパー自動生成＋登錄）
-- ═══════════════════════════════════════════════════
construe
