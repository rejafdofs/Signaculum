-- Signaculum.Sakura.Textus.Optionum
-- 選擇肢關數にゃん♪

import Signaculum.Sakura.Fundamentum

namespace Signaculum.Sakura.Textus

-- ════════════════════════════════════════════════════
--  選擇肢 (Optiones) — 使用者の選擇
-- ════════════════════════════════════════════════════

/-- 選擇肢を追加する（\\q[表題,識別子]）にゃん。
    表題(titulus)や識別子の特殊文字は自動的に遁走されるにゃ -/
def optio {m : Type → Type} [Monad m] (titulus signum : String) : SakuraM m Unit :=
  emitte (.optionum (.optio titulus signum))

/-- 事象附き選擇肢（\\q[表題,OnEvent,ref0,ref1,...]）にゃん。
    表題(titulus)や事象の特殊文字は自動的に遁走されるにゃ -/
def optioEventum {m : Type → Type} [Monad m]
    (titulus eventum : String) (citationes : List String := []) : SakuraM m Unit :=
  emitte (.optionum (.optioEventum titulus eventum citationes))

/-- 錨（\\_a[id]...テキスト...\\_a）にゃん。
    閉ぢる時は `fineAncora` を呼ぶにゃ -/
def ancora {m : Type → Type} [Monad m] (id : String) (citationes : List String := []) : SakuraM m Unit :=
  emitte (.optionum (.ancora id citationes))

/-- 錨を閉ぢる（\\_a）にゃん -/
def fineAncora {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.optionum .fineAncora)

/-- 選擇肢の時間制限を設定する（\\![set,choicetimeout,ms]）にゃん -/
def tempusOptionum {m : Type → Type} [Monad m] (ms : Nat) : SakuraM m Unit :=
  emitte (.optionum (.tempusOptionum ms))

/-- 時間切れ防止（\\*）にゃん -/
def prohibeTempus {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.imperii .prohibeTempus)

-- ════════════════════════════════════════════════════
--  選擇肢拡張 (Extensio Optionum)
-- ════════════════════════════════════════════════════

/-- スクリプトゥム實行型選擇肢（\\q[title,script:content]）にゃん。
    選擇時にスクリプトゥムが直接實行されるにゃ -/
def optioScriptum {m : Type → Type} [Monad m] (titulus scriptum : String) : SakuraM m Unit :=
  emitte (.optionum (.optioScriptum titulus scriptum))

/-- 複數 ID 選擇肢（\\q[title,ID1,ID2,...]）にゃん。
    複數の識別子を格納するにゃ -/
def optioMultiplex {m : Type → Type} [Monad m] (titulus : String) (signa : List String) : SakuraM m Unit :=
  emitte (.optionum (.optioMultiplex titulus signa))

/-- 範圍選擇肢の開始（\\__q[ID,...]）にゃん。
    次の `fineOptioScopus` まで全テクストゥスが選擇肢になるにゃ -/
def optioScopus {m : Type → Type} [Monad m] (signum : String) (citationes : List String := []) : SakuraM m Unit :=
  emitte (.optionum (.optioScopus signum citationes))

/-- 範圍選擇肢の終了（\\__q）にゃん -/
def fineOptioScopus {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.optionum .fineOptioScopus)

end Signaculum.Sakura.Textus
