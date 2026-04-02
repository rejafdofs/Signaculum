-- TestIntegratio: DSL マクロ統合テストにゃん
-- eventum / varia / scriptum! / construe の統合動作を檢證するにゃ
-- コンパイルが通ること自體がテストにゃん♪

import Signaculum

open Signaculum.Sakura.Textus
      Signaculum.Sakura (sakura kero finis loqui linea superficies mora)

-- ═══════════════════════════════════════════════════
-- §1 變數宣言 (varia)
-- ═══════════════════════════════════════════════════

varia perpetua numerusLoquendi : Nat := 0
varia temporaria nomenUtentis : String := ""

-- ═══════════════════════════════════════════════════
-- §2 def ベースコールバック用の關數定義
-- ═══════════════════════════════════════════════════

/-- 引數なし: SakuraIO Unit -/
def colloquiumSimplex : SakuraIO Unit := do
  sakura; superficies 0; loqui "やあにゃん"; finis

/-- 1引數: String → SakuraIO Unit -/
def onTextumAcceptum (textus : String) : SakuraIO Unit := do
  sakura; loqui s!"入力: {textus}"; finis

/-- 2引數: String → Nat → SakuraIO Unit（型チェックテスト用） -/
def onSalutatio (nomen : String) (aetas : Nat) : SakuraIO Unit := do
  sakura; loqui s!"{nomen}({aetas})"; finis

/-- 選擇肢コールバック: 引數なし -/
def onMenuLoqui : SakuraIO Unit := do
  sakura; loqui "ランダムトークにゃ"; finis

/-- 選擇肢コールバック: 1引數 -/
def onTopicum (topicum : String) : SakuraIO Unit := do
  sakura; loqui s!"話題: {topicum}"; finis

-- ═══════════════════════════════════════════════════
-- §3 eventum コマンド（從來形: Tractator 直接）
-- ═══════════════════════════════════════════════════

eventum "OnBoot" fun _req => do
  sakura; superficies 0
  loqui "起動テストにゃん♪"
  finis

eventum "OnClose" fun _req => do
  sakura; loqui "終了にゃ"; finis

-- ═══════════════════════════════════════════════════
-- §4 scriptum! 基本タグ
-- ═══════════════════════════════════════════════════

/-- 基本タグの組み合はせにゃん -/
def testumBasicum : SakuraPura Unit := scriptum!
  \h \s[0] こんにちは \e

-- ═══════════════════════════════════════════════════
-- §5 scriptum! 式埋込 ({expr})
-- ═══════════════════════════════════════════════════

/-- String 埋込にゃん -/
def testumExpressio : SakuraPura Unit :=
  let s := "世界"
  scriptum! \h {"こんにちは" ++ s} \e

-- ═══════════════════════════════════════════════════
-- §6 scriptum! 式埋込: SakuraM Unit 恆等インスタンス
-- ═══════════════════════════════════════════════════

/-- SakuraIO Unit の配列→ランダム選擇にゃん -/
def colloquia : Array (SakuraIO Unit) :=
  #[ colloquiumSimplex, colloquiumSimplex ]

def testumArraySakuraM : SakuraIO Unit := scriptum!
  {colloquia}

-- ═══════════════════════════════════════════════════
-- §7 scriptum! \![raise,...] 型チェック
-- ═══════════════════════════════════════════════════

/-- raise + 識別子 + 型付き引數にゃん -/
def testumRaiseTypo : SakuraIO Unit := scriptum!
  \![raise, onSalutatio, "シロ", 5]

/-- raise + 引數なし識別子にゃん -/
def testumRaiseSimplex : SakuraIO Unit := scriptum!
  \![raise, colloquiumSimplex]

-- ═══════════════════════════════════════════════════
-- §8 scriptum! \q 選擇肢
-- ═══════════════════════════════════════════════════

/-- \q 文字列形（從來互換）にゃん -/
def testumOptioStr : SakuraPura Unit := scriptum!
  \q[話す, "OnMenuTalk"]

/-- \q 識別子形にゃん -/
def testumOptioIdent : SakuraIO Unit := scriptum!
  \q[話す, onMenuLoqui]

/-- \q 識別子+引數形（型チェック）にゃん -/
def testumOptioRef : SakuraIO Unit := scriptum!
  \q[話題A, onTopicum, "topicA"]
  \q[話題B, onTopicum, "topicB"]

-- ═══════════════════════════════════════════════════
-- §9 scriptum! \_a 錨
-- ═══════════════════════════════════════════════════

/-- 錨の識別子形にゃん -/
def testumAncora : SakuraIO Unit := scriptum!
  \_a[onMenuLoqui] クリック \_a

-- ═══════════════════════════════════════════════════
-- §10 scriptum! \__q 範圍選擇肢
-- ═══════════════════════════════════════════════════

/-- 範圍選擇肢の識別子形にゃん -/
def testumOptioScopus : SakuraIO Unit := scriptum!
  \__q[onMenuLoqui] ここが選擇肢 \__q

-- ═══════════════════════════════════════════════════
-- §11 scriptum! \![open,inputbox,...] paramCount 檢證
-- ═══════════════════════════════════════════════════

/-- inputbox + 識別子コールバック（paramCount=1）にゃん -/
def testumInputbox : SakuraIO Unit := scriptum!
  \![open, inputbox, onTextumAcceptum, "名前を入力"]

-- ═══════════════════════════════════════════════════
-- §12 scriptum! Option 埋込
-- ═══════════════════════════════════════════════════

/-- Option α の Exhibibilis にゃん -/
def testumOption : SakuraPura Unit :=
  let v : Option String := some "あり"
  scriptum! \h {v} \e

-- ═══════════════════════════════════════════════════
-- §13 eventum + scriptum! で Tractator を構成
-- ═══════════════════════════════════════════════════

eventum "OnMouseDoubleClick" fun req => do
  let scopus := (req.referentiam 3).getD ""
  sakura
  if scopus == "0" then
    scriptum! つつかないでにゃ
  else
    scriptum! うにゃ？
  finis

-- ═══════════════════════════════════════════════════
-- §14 construe（ラッパー自動生成＋登錄）
-- ═══════════════════════════════════════════════════

construe
