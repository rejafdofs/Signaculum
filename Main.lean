-- ghost.exe のエントリーポイントにゃん
-- 標準入出力パイプ經由でホストプロセスと通信するにゃ

import Signaculum

open Signaculum
open Signaculum.Nucleus

def main : IO Unit := do
  -- ループに入る前に栞が登錄されてゐるか確認するにゃ
  let registrata ← Signaculum.Nucleus.estRegistrata
  IO.println s!"栞登錄狀態: {registrata}"
  -- 實際のゴーストでは loopPrincipalis を呼ぶにゃん
  Signaculum.Nucleus.loopPrincipalis
