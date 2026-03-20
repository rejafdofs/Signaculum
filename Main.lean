-- ghost.exe のエントリーポイントにゃん
-- 標準入出力パイプ經由でホストプロセスと通信するにゃ

import TestGhost

open Signaculum

def main : IO Unit := do
  IO.println "TestGhost 起動にゃん♪"
  -- ループに入る前に栞が登錄されてゐるか確認するにゃ
  let registrata ← Signaculum.estRegistrata
  IO.println s!"栞登錄狀態: {registrata}"
  -- 實際のゴーストでは loopPrincipalis を呼ぶが、
  -- テストでは SakuraScript 生成のみ確認するにゃん
  IO.println s!"純粹テスト: {testPuraSakura}"
