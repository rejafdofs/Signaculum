# 變更記錄 (Mutationum Registrum)

## v0.2.0 — Pure Lean TCP SSTP & 品質改善

### C コード排除 — Pure Lean TCP SSTP

- `Signaculum/c/sstpDirectum.c`（Win32 `WM_COPYDATA` による Direct SSTP）を完全に排除
- `Std.Internal.UV.TCP.Socket`（Lean 4 組込み libuv バインディング）による Pure Lean TCP 實裝に置換
- TCP `localhost:9801` で SSP に SSTP/1.4 リクエストを送信。OS 非依存で動作する
- `lakefile.lean` から `extern_lib sstpDirectum` セクション（C ビルド設定）を削除

### SSTP パケット形式の修正

- Execute リクエスト: `SSTP/1.4` → `EXECUTE SSTP/1.4`（正しい SSTP/1.4 形式に修正）
- Notify リクエスト: `SSTP/1.4` → `NOTIFY SSTP/1.4`（正しい SSTP/1.4 形式に修正）
- ヘッダー値から CR/LF を除去する `purgaCrlf` 關數を追加（パケット破損防止）

### ハンドラ探索の高速化 (`Nucleus/Nuculum.lean`)

- `tractatores` の型を `List (String × Tractator)` → `Std.HashMap String Tractator` に變更
- イベント名による探索が O(n) → O(1) に改善
- `Shiori.creare` で `Std.HashMap.ofList` により List から HashMap へ變換

### エラー處理の改善

- `Nucleus/Nuculum.lean`: 致命的例外を文字列ではなく `Responsum.errorInternus.adProtocollum` で正規の SHIORI/3.0 500 應答として返すやうに變更
- `Nucleus/Exporta.lean`: 同上、`exportaRequest` の `catch` ブロックでも正規の 500 應答を返す

### タスク管理の改善 (`Nucleus/Exporta.lean`)

- `spawnaMunitus` で新規タスク追加時に `IO.hasFinished` で完了濟みタスクを自動除去するやうに變更
- 完了濟みタスクが溜まらないため、タスクリストが効率的に管理される

### ループ處理の改善 (`Nucleus/Loop.lean`)

- `ingressusU32` の戻り値を `IO UInt32` → `IO (Option UInt32)` に變更
- 長さ 0 のエラー時にループを繼續するやうに修正（以前は `return ()` で終了してゐた）

### 構文衛生の修正 (`Syntaxis.lean`)

- `set_option hygiene false` のスコープを `construe` エラボレーションのみに限定（`set_option hygiene false in`）
- 他のマクロに影響を與へない

### ビルド設定の修正 (`lakefile.lean`)

- 7 つの未登錄モジュールを `globs` に追加: `Loop`, `Citatio`, `Citationes`, `Auxilia`, `Axiom`, `Lemma`, `Varia`
- テスト用 `lean_lib TestGhost` と `lean_exe ghost` ターゲットを追加

### 文字列操作の修正

- `String.filter` を `String.foldl` に置換（Lean 4.29.0-rc6 では `String.filter` が未提供のため）

---

## 最適化 (Optimizatio)

### `evadeTextus` の文字列構築改善 (`SakuraScriptum.lean`)
SakuraScriptum の特殊文字遁走處理で、通常文字の追加を `String.ofList [c]`（毎囘リスト生成 + 文字列變換）から `acc.push c`（1文字直接追加）に變更したにゃ。文字列が長いほど效果が出るにゃん♪

### `executareScripturam` の O(n²) → O(n) 改善 (`StatusPermanens.lean`)
永続化の書出處理で、リストの末尾に `++` で追加してゐたのを、先頭に `::` で追加して最後に `.reverse` する方式に變更したにゃ。`++` はリスト全體を毎囘コピーするので O(n²) だったのが、O(n) になったにゃん♪

### `Protocollum/Rogatio.lean` の配列構築簡素化
`referentiae` 配列の初期化を手動ループから `(List.replicate maximumIndex "").toArray` に變更したにゃ。すっきりにゃん♪
