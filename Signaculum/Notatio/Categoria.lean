-- Signaculum.Notatio.Categoria
-- 構文カテゴリア宣言にゃん。sakuraSignum と fontisClavis の土臺ぢゃ♪

import Lean

namespace Signaculum.Notatio

open Lean Elab Meta

-- サクラスクリプトの標籤を表す構文カテゴリアにゃん
declare_syntax_cat sakuraSignum

-- 書體キーを表す構文カテゴリアにゃん（\f[key,value] の key 部分）
declare_syntax_cat fontisClavis

-- 構文カテゴリアから term への橋渡しにゃん
syntax "expandSignum " sakuraSignum : term

-- 展開ルールのないシグナムが來たらその位置でエラーにゃん（最低優先度フォールバック）
elab_rules : term
  | `(expandSignum $s:sakuraSignum) =>
    Lean.throwErrorAt s "未知のサクラスクリプトシグナムにゃ"

end Signaculum.Notatio
