-- Signaculum.Utilia.Inspectio
-- 變數デバッグ支援にゃん♪
-- さとりすとの變數リスト / さとりて的な機能にゃ
-- construe が inspiceVariabiles を自動生成するにゃん

import Signaculum.Utilia.Registrum
import Signaculum.Sstp

namespace Signaculum.Utilia

/-- 變數の値をログに出力して SSTP でゴーストにも表示するにゃん♪
    デバッグ用にゃ -/
def inspiceEtMitte (nomen : String) (obtineValorem : IO String) : IO Unit := do
  let valor ← obtineValorem
  let linea := s!"{nomen} = {valor}"
  registraIndicium linea
  Signaculum.Sstp.mitteSstpScriptum s!"\\h\\s[0]【DEBUG】\\n{linea}\\e"

-- 注意: inspiceVariabiles 本體は construe が自動生成するにゃん♪
-- 全 varia perpetua の名前・型・現在值を取得してログ出力するにゃ
-- 以下はヘルパーのみ提供するにゃん

/-- 變數ダンプのヘッダーにゃん -/
def caputInspectionis : String := "═══ Inspectio Variabilium ═══"

/-- 變數ダンプの單一行を生成するにゃん -/
def lineaInspectionis (nomen typus valor : String) : String :=
  s!"  {nomen} : {typus} = {valor}"

end Signaculum.Utilia
