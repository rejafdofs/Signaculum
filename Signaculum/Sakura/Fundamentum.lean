-- Signaculum.Sakura.Fundamentum
-- 基底発出プリミティウィ。emitte / loqui にゃん♪

import Signaculum.Sakura.Status

namespace Signaculum.Sakura

/-- 構造化シグヌムを發出するにゃん。
    これが全ての土臺にゃ -/
def emitte {m : Type → Type} [Monad m] (s : Signum) : SakuraM m Unit :=
  modify fun st => { st with scriptum := st.scriptum ++ [s] }

/-- 文字列を表示するにゃん。
    \\、%、] の特殊文字は自動的に遁走されるにゃ。
    構造化シグヌムとして蓄積されるから安全にゃん♪ -/
def loqui {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit :=
  emitte (.exhibitionis (.textus s))

end Signaculum.Sakura
