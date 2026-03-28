-- Signaculum.Notatio.Lexema
-- サクラスクリプトの構文中間表現にゃん♪
-- パーサーが生テクストゥスから此の型のノードを生成し、エラボレーターが SakuraM term に變換するにゃ

import Lean

namespace Signaculum.Notatio

/-- scriptum ブロック内のトークンをパーサーが分類した中間表現にゃん♪
    パーサーが生テクストゥスから此の型に對應するシンタクスノードを生成し、
    エラボレーターが SakuraM term に變換するにゃ -/
inductive LexemaSakurae where
  /-- 裸テクストゥス（タグでも式でもない平文にゃ） -/
  | textusNudus (valor : String) (stx : Lean.Syntax)
  /-- バックスラッシュタグ（\\h, \\s[n], \\w5 等にゃ）
      nomen はタグ名（"\\h", "\\s" 等）、argumenta は [] 内の , 區切り引數にゃ -/
  | signum (nomen : String) (argumenta : List (Lean.TSyntax `term)) (stx : Lean.Syntax)
  /-- 感嘆符タグ（\\![cmd, args...] にゃ）
      imperium はコマンド名（"move", "set,wallpaper" 等）、argumenta は殘りの , 區切り引數にゃ -/
  | signumExclamationis (imperium : String) (argumenta : List (Lean.TSyntax `term)) (stx : Lean.Syntax)
  /-- 式埋込（{expr} にゃ） -/
  | expressioInserta (corpus : Lean.TSyntax `term) (stx : Lean.Syntax)
  /-- 文字列リテラル（"..." にゃ） -/
  | textusLiteralis (valor : String) (stx : Lean.Syntax)
  /-- 環境變數參照（%ident にゃ） -/
  | variabilisAmbientis (nomen : String) (stx : Lean.Syntax)
  /-- 書體タグ（\\f[key,value,...] にゃ）
      clavis はフォントキー名（"bold", "color" 等）、valores は , 區切り値にゃ -/
  | signaturaFontis (clavis : String) (valores : List (Lean.TSyntax `term)) (stx : Lean.Syntax)

/-- レクセマからソース位置情報を取るにゃん -/
def LexemaSakurae.syntaxis : LexemaSakurae → Lean.Syntax
  | .textusNudus _ stx => stx
  | .signum _ _ stx => stx
  | .signumExclamationis _ _ stx => stx
  | .expressioInserta _ stx => stx
  | .textusLiteralis _ stx => stx
  | .variabilisAmbientis _ stx => stx
  | .signaturaFontis _ _ stx => stx

end Signaculum.Notatio
