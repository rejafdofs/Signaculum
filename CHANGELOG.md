# 變更記錄 (Mutationum Registrum)

## v0.7.0 (2026-04-10) — ユーティリティ・イベントラッパー・トーク管理 DSL

### 正規表現 (ExpressioRegularis)
- `Utilia/ExpressioRegularis.lean`: `pandaman64/lean-regex` ライブラリーのラッパーを新設。テクストゥス處理向けの正規表現關數群を提供
- `quaereRE`: 正規表現で最初のマッチとキャプチャグループを檢索
- `congruatRE`: テクストゥスがパターンにマッチするか判定
- `quaereOmnesRE`: 全マッチ文字列を配列で返す
- `substitueRE`: 正規表現による置換
- `scindeRE`: 正規表現によるテクストゥス分割
- `numeraRE`: マッチ數のカウント
- `lakefile.lean`: `pandaman64/lean-regex` への依存を追加

### ゴースト間通信 (Communicationis)
- `Sstp.lean`: SSTP/1.4 SEND プロトコルによるゴースト間通信關數を追加。`communicaSstpScriptum`（SakuraScript 送信）と `communicaSstpSentence`（テクストゥム送信）を提供
- `Sakura/Systema/Communicationis.lean`: SakuraIO コンテクスト内ラッパー `communicaScriptum` / `communicaSentence` を新設。`IfGhost` ヘッダーで送信先ゴーストを指定

### SAORI ブリッジ (Saori)
- `Saori.lean`: SAORI-universal（DLL）および SAORI-basic（.exe）の呼出し機構を新設
- `onerareSaori`: SAORI DLL のロード（procurator32 經由、コマンドバイト 0x04）
- `vocareSaori`: SAORI DLL へのリクエスト送信（コマンドバイト 0x05）。SAORI/1.0 リクエストゥムを組み立て、Result + Value 配列を返す
- `exonerareSaori`: SAORI DLL のアンロード（コマンドバイト 0x06）
- `vocareSaoriBasic`: SAORI-basic（.exe）を IO.Process で起動して結果を得る
- `vocareSaoriM`: SakuraIO コンテクスト内から SAORI-universal を呼び出すラッパー
- `procurator/procurator32/src/lib.rs`: Rust 側に SAORI DLL 管理（`SAORI_MODULES` HashMap）、`saori_onerare`/`saori_rogare`/`saori_exonerare` 關數、`tractare_saori_circulum` コマンドループを追加。ANSI ↔ UTF-8 變換對應
- `Nucleus/Circulus.lean`: `Communicatio.scribeResponsum` で 0x00 コマンドバイト + 長さプレフィクスム應答を送信。SAORI コマンドループとの連攜に對應

### タイマー (Horologium)
- `Utilia/Horologium.lean`: OnSecondChange 用の高レヴェルタイマー抽象を新設
- `Horologium` 構造體: 名前・間隔・殘り秒數を保持するタイマー狀態
- `creandum`: タイマー作成（指定秒後に最初に發火）
- `pulsaHorologium`: 1秒進めて發火時刻到達時に true を返しリセット
- `reinitia`: タイマーをリセット
- `pulsaOmnia`: 複數タイマーの一括パルス（發火したタイマー名の配列を返す）

### 日時ユーティリティ (Tempus)
- `Utilia/Tempus.lean`: `Std.Time` を活用した日時関数群を新設。`obtineTempus`（現在時刻取得）、`estMane`/`estMeridies`/`estVespera`/`estNox`（時間帯判定）、`tempusAdTextum`（書式化）を提供

### ログ機能 (Registrum)
- `Utilia/Registrum.lean`: YAYA の LOGGING 相当のログ機能を新設。`ghost_log.txt` にタイムスタンプ付きで記録
- `registra`/`registraIndicium`/`registraMonitum`/`registraErrorem`: IO コンテクスト内でのログ出力（INFO/WARN/ERROR）
- `registraM`: SakuraIO コンテクスト内でのログ出力
- `registraEtNotifica`: SakuraIO 内でログ出力 + SHIORI 応答の ErrorLevel/ErrorDescription にも設定

### SHIORI Resource 応答 (resourcea)
- `Syntaxis.lean`: `resourcea "version" := "1.0.0"` マクロを追加。SHIORI Resource 応答（version, craftmanw, homeurl 等）を宣言的に定義可能に
- 静的文字列値と動的 `IO String` 関数の両方に対応。`construe` がリソース応答ハンドラとして自動登録
- `GhostAccumulatio` に `resourceae` フィールド、`GhostEntry` に `.resourcea` バリアントを追加

### 日本語イベント名 (NominaIaponica)
- `Eventum/NominaIaponica.lean`: 里々方式の日本語イベント名エイリアスを新設。`eventum "起動"` → `OnBoot` 等の自動変換
- 70 以上のマッピングを定義（起動/終了、ゴースト切替、マウス、時間、トーク、選択肢、通信、入力、シェル、バルーン、ファイルドロップ、ネットワーク更新、OS 状態、消滅、キー、音声、インストール等）
- `resolveNomenEventi` 関数でコンパイル時にテーブル参照・変換

### 統一トーク管理 (Colloquium)
- `Sakura/Textus/Colloquium.lean`: ランダムトーク・条件付きトーク・チェイントークを統一管理する `Colloquium` 帰納型を新設
- 4 コンストラクタ: `.loquela`（通常）、`.conditio`（条件付き）、`.series`（チェイン）、`.seriesCum`（条件付きチェイン）
- `Coe` インスタンスにより `SakuraIO Unit` と `Catena` を配列内で自動変換
- `eligeColloquium`: 均等確率選択（アクティブチェイン優先続行）
- `eligeColloquiumPonderatum`: 重み付き確率選択
- `cum`/`cumSeries` 便利コンストラクタ

### イベントラッパー (Involucra)
- `Eventum/Involucra.lean`: 生の SHIORI イベントを加工する高レベル抽象を新設
- なでられ判定: `iudicaNaderare` — OnMouseMove の連続回数が閾値を超えたら発火。scope+area 別カウント
- `configuraNaderareLimen`/`configuraNaderareIntervallum` で閾値・間隔を設定可能
- `nomenEventumMusis`: マウスイベントから「{scopeId}{areaName}{suffix}」形式のイベント名を生成
- ランダムトークタイマー: `pulsaTimerColloquii` — OnSecondChange でカウントダウン、0 到達で発火通知
- `configuraIntervallumColloquii` でランダムトーク間隔を設定可能（デフォルト 180 秒）

### 変数デバッグ (Inspectio)
- `Utilia/Inspectio.lean`: 変数デバッグ支援を新設。`construe` が `inspiceVariabiles : IO Unit` を自動生成
- 全 `varia perpetua` の名前・型・現在値を `ghost_log.txt` に出力
- `inspiceEtMitte`: 個別変数をログ出力しつつ SSTP でゴーストにも表示

---

## v0.6.0 (2026-04-02) — チェイントーク (Catena Colloquiorum) 支援

### チェイントーク型・Exhibibilis インスタンス
- `Sakura/Textus/Catena.lean`: `Catena` 構造体（名前・話配列・位置 IO.Ref）、`OptioPiscinae` 判別共用体、`exequiCatenam` 順次再生関数、`eligeVelCatena` チェイン優先混合選択関数を新設
- `Notatio/Macro.lean`: `Exhibibilis Catena IO` インスタンスを追加。`{catena}` で scriptum! 内から直接使用可能

### `catena` DSL マクロ
- `Syntaxis.lean`: `catena nomen := [actio1, actio2, ...]` マクロを追加。位置用 IO.Ref の自動生成・永続化変数としての自動登録・`construe` での catenaActiva 状態の自動永続化を実現
- `GhostAccumulatio` に `hasCatenas` フラグ、`GhostEntry` に `.catena` バリアントを追加

## v0.5.0 (2026-03-28) — LexemaSakurae IR + カスタムパーサー全面移行

### LexemaSakurae 帰納型パーサー中間表現
- `Notatio/Lexema.lean`: scriptum ブロック内トークンの構文中間表現 `LexemaSakurae` 帰納型を新設（7 コンストラクタ: textusNudus, signum, signumExclamationis, expressioInserta, textusLiteralis, variabilisAmbientis, signaturaFontis）

### カスタムパーサー全面移行
- `Notatio/Parsitor.lean` + `Parsitor/Argumenta.lean`: 先頭文字分岐の単一カスタム `ParserFn` で全サクラスクリプトトークンを直接パース
- `sakuraSignum` カテゴリパーサーへの委譲を廃止し、`scriptumParserCore` で `sakuraLexemaParser` を直接使用
- 括弧内引数パーサー `argumentaInUncisFn`: 不正な引数に対してタグ名入り日本語エラーメッセージを生成（例: `\s[aaa]` → `\s: []の中には数字が期待されてゐますにゃ`）

### Expande ディスパッチ関数
- `Notatio/Expande/Textus.lean`: 基本タグ展開（56 タグ）
- `Notatio/Expande/Fenestra.lean` + `Fenestra/Aperitio.lean` + `Fenestra/Configuratio.lean`: 窓制御タグ展開（103 タグ）
- `Notatio/Expande/Systema.lean` + `Systema/Eventum.lean` + `Systema/Sonus.lean` + `Systema/Animatio.lean` + `Systema/Rete.lean` + `Systema/Reliqua.lean`: システムタグ展開（107 タグ）
- `Notatio/Expande/Fons.lean`: 書体タグ展開（60 タグ、リテラル解釈含む）

### リテラルオーバーロード型クラス
- `Sakura/Literalis.lean`: OfNat 方式で none/default/left 等のキーワードを期待型に応じて自動解決する型クラス群（SakuraNullus, SakuraPraefinitus, SakuraInhabilis 等）
- `Option α` にも `SakuraNullus` インスタンスを実装

### script: 構文サポート
- `\q["title", script: "content"]` 構文をカスタムパーサーで對應（`optioScriptum` を生成）

### lean-toolchain を安定版 v4.29.0 に移行
- `leanprover/lean4:v4.29.0-rc7` → `leanprover/lean4:v4.29.0`

### rawTextusFn 全面刷新 — 裸テクストゥスパーサの堅牢化
- 裸テクストゥスの後に續くタグが解析されにゃい問題を修正
- 非 ASCII 文字のみ對應 → ASCII テクストゥス（數字等）も裸テクストゥスとして扱へるやうに擴張
- タグ開始文字（`\` `"` `'` `{` `}` `%` `)` `]`）で停止し、それ以外は全てテクストゥスとして讀む設計に變更
- `genTerm` で `rawVal` から直接文字列を取得するやうに修正（guillemet `«»` 混入の回避）

### 數値リテラル對應
- `syntax num : sakuraSignum` を追加、裸の數値（例: `844424930131960`）をテクストゥスとして表示可能に

### プロバーティオー追加
- `\u \h` 單行、複數行 `\u` 混在、數值リテラル、裸テクストゥス後のタグ解析の檢證を追加

## v0.4.0 (2026-03-27) — SHIORI/3.0 レスポンスムヘッダー型安全化 & 設計改善

### SakuraM ステート拡張 — レスポンスムヘッダーを型安全にカスタマイズ可能に

`SakuraM` のステートを `String` → `StatusSakurae` 構造體に拡張し、イヴェントゥム處理器内から Value 以外の SHIORI/3.0 レスポンスムヘッダーを設定可能にした。

- `StatusSakurae` 構造體: `scriptum`（スクリプトゥム文字列）に加へ `marker`/`balloonOffset`/`errorLevel`/`errorDescription`/`markerSend`/`valorNotifica`/`age`/`securitas`/`cappitta` を蓄積
- `Responsum` に Sender/ErrorLevel/ErrorDescription/Marker/BalloonOffset/Age/SecurityLevel/MarkerSend/ValueNotify の型付きフィールド追加
- `adProtocollum` で全ヘッダーを仕樣通りに出力
- ヘルパー關數群追加: `configuraMarker`、`configuraBalloonOffset`、`configuraErrorLevel`、`configuraErrorDescription`、`configuraMarkerSend`、`configuraValorNotifica`、`configuraAge`、`configuraSecuritas`、`addeCastellum`
- `currereScriptum` 追加（スクリプトゥム文字列のみ取得する便利關數）
- `currere` は `StatusSakurae` を返すやうに變更

### ErrorLevel/ErrorDescription による例外報告

- `Shiori.tracta`: `catch _ =>` を `catch e =>` に變更し、ErrorLevel=error + ErrorDescription=例外メッセージで 500 應答を返す
- `tractaCatenam`: 同樣。不正要求時は ErrorLevel=warning + ErrorDescription=パースエラーメッセージ
- `exportaRequest`: 同樣。ErrorLevel=critical + ErrorDescription=例外メッセージ

### `!` 關數の全排除（claude.md 違反修正）

- `Memoria/Auxilia.lean`: `lebDecodeLoop` の `b[pos]!` を `b[pos]`（`if h : pos < b.size` で證明）に變更。`elementumInPrefixo`/`elementumInPrefixo2`/`elementumDextriObliquum` を安全版に書き換へ。`lebDecodeIteratioRecta`/`lebDecodeIteratioPraefixo` の `if_pos` → `dif_pos` に更新
- `Sakura/Textus.lean`: `elige` の `optiones[i]!` を `Nat.mod_lt` の證明付き安全アクセスに
- `Memoria/Lemma.lean`: `StatusPermanens` Bool/UInt8/Option の `b[0]!` を `b[0]'(by omega)` に

### loopPrincipalis の分割 & LE 重複排除

- `Communicatio` 構造體を導入（`rivusIngressus`/`rivusEgressus` を一元管理）
- `loopPrincipalis` を `tractaOnerare`/`tractaExonerare`/`tractaRogationem` の3關數に分割
- `match` 式でコマンドバイトをディスパッチする明瞭な構造に
- `egressusU32`/`ingressusU32` を削除し `Memoria.u32LE`/`Memoria.readU32LE` を利用

### コード品質改善

- `escapePropNomen` 重複排除（`Typi.lean` に統合、`Systema.lean` から削除）
- Citatio UInt8/16/32/64 インスタンティアを共通補題 `citatioUIntRecursus` で簡潔化
- ヘッダーパースの `prepend → reverse` を `Array.push` に變更
- `spawnaMunitus` のマーギクムナンバー 256/128 を定數 `maximumMunera` に抽出

### SHIORI/3.0 仕樣準拠

- `StatusCodis` に `pluribusDatis` (311) / `rescribeInput` (312) 追加
- `Rogatio` に `typusMittentis` (SenderType)、`status` (Status)、`securitasOrigo` (SecurityOrigin) 追加
- `executaHttpGet`/`executaHttpPost` 追加（SakuraScript HTTP GET/POST）
- SSTP Sender のハードコード解消: `mitteSstpScriptum`/`excitaEventum` に `mittens` 引數追加、デフォルト `mittensDefectus = "uka-lean"`

### バグ修正

- `Notatio/Literalia.lean`: カスタム構文 `syntax "none"` が Lean の `Option.none` と衝突する問題を修正。構文キーワードを `nullus` に變更（出力される SakuraScript は從前通り `none`）

---

## v0.3.2 (2026-03-24) — ident/lambda 形統合エラボレーター & タグ構文簡素化

### Syntaxis.lean — ident 形と lambda 形を単一 elab に統合

`excita`/`insere`/`notifica`/`excitaPostTempus`/`notificaPostTempus` のそれぞれで、
ident 形と lambda 形が別々の syntax kind・elab 関数に分かれていたのを統合した。

- lambda パーサーの syntax kind を ident パーサーと同一に変更（例: `excitaLambdaSyntax` → `excitaSyntax`）
- 統合 elab で `stx[1].isIdent`（PostTempus は `stx[3].isIdent`）により分岐
- elab 関数を各コマンド 2 → 1 に削減（5 関数削除: `elabExcitaTermLambda` 等）
- `excitaLambdaSyntax`/`insereLambdaSyntax` 等の不要になった syntax kind 5 つを削除

### Notatio/Systema.lean — コールバックタグ構文簡素化

`\![raise,...]` 等のラムダ形に `(term:max)*` を追加し、引数渡しに対応。
`\![open,inputbox,...]` / `\![open,passwordinput,...]` の 8+2 形式を 2+2 形式に統合。

- `\![raise, (fun s => ...) "arg"]` — ラムダに引数を渡せるようになったにゃ
- `\![embed, (fun s => ...)]` / `\![notify, ...]` / `\![timerraise, ...]` / `\![timernotify, ...]` も同様
- `\![open,inputbox, callback, title]` — ident/lambda/str/ident タイトルを `term:max`/`term` で統一（8形式 → 2形式）
- `\![open,passwordinput, callback, title]` — 同様に 2形式に統合

---

## v0.3.1 (2026-03-24) — ラムダ形 Reference 引数渡し & {expr} 強制変換修正

### ラムダ形に Reference 引数渡しを追加

`excita`/`insere`/`notifica`/`excitaPostTempus`/`notificaPostTempus` のラムダ形で、
引数ありの場合に Reference 抽出ラッパーを `construe` が自動生成するようになった。

- `excita (fun s:String => ...) "arg"` — Reference[0] が String として `s` に渡される
- `excita (fun _ => ...)` — 引数なしは従来通り Tractator として直接登録
- `aperiInputum .simplex (fun text => ...) title` — Reference[0] を `text` に自動渡し
- `registraLaziumLambda` に `pc : Nat` パラメータ追加（Reference 数を記録）
- `construe` の lambda ブランチで `paramCount > 0` 時にラッパーを生成

### {expr} 強制変換を type ascription 形式に修正

`scriptum {expr}` マクロ内で `IO String` 等のモナド値を確実に `SakuraM _ Unit` に変換するよう修正。

- `show SakuraM _ Unit from $e` → `($e : SakuraM _ Unit)` に変更（`ensureHasType` が呼ばれ coercion が確実に挿入される）

---

## v0.3.0 (2026-03-23) — パラメータ境界検証 & scriptum! マクロ DSL

### コンパイル時パラメータ境界検証

SakuraScript DSL の各関数に証明パラメータを追加し、不正な値をコンパイル時に検出できるようにした。

- `Coloris.rgb` の r/g/b に `≤ 255` の証明パラメータ追加
- `OptionesSoni.cumVolumine` に `≤ 100` の証明追加
- `OptionesSoni.cumLibramento` に `-100 ≤ n ∧ n ≤ 100` の証明追加
- `OptionesSoni.cumCursu` に `1 ≤ n ∧ n ≤ 10000` の証明追加
- `moraCeler` に `1 ≤ n ∧ n ≤ 9` の証明追加
- `configuratioAlphae` に `≤ 100` の証明追加
- `aperiInputumIP` の各オクテットに `≤ 255` の証明追加
- `lineaProportionalis` を `Nat` から `Int` に変更（負値・100超も指定可能に）
- Typi.lean に `estBissextilis`（閏年判定）と `diesInMense`（月の日数）関数を追加

### 数値入力の3関数分割

`aperiInputumNumerale` を用途別の3関数に分割し、それぞれにコンパイル時境界検証を追加した。

- `aperiInputumDiei` — 日付入力。mensis に `1 ≤ m ∧ m ≤ 12`、dies に `1 ≤ d ∧ d ≤ diesInMense annus mensis`（閏年考慮）
- `aperiInputumTemporis` — 時刻入力。hora `≤ 23`、minutum `≤ 59`、secundum `≤ 59`
- `aperiInputumGradus` — スライダー入力。`minimum ≤ initium ∧ initium ≤ maximum`
- Syntaxis.lean のエラボレータも3関数に対応

### Signaculum.Notatio — scriptum! マクロ DSL

SakuraScript を原形タグ記法で書ける `scriptum!` マクロを追加。do 記法の代替として使える。

- `Notatio.Categoria` — 構文カテゴリア宣言（`sakuraSignum`, `fontisClavis`）
- `Notatio.Textus` — テキスト・範囲・待機・選択肢・制御タグ
- `Notatio.Fons` — 書体タグ `\f[...]`
- `Notatio.Fenestra` — 窓制御・UI・モード・設定タグ
- `Notatio.Systema` — イベント・音響・動画・呼出・変更タグ
- `Notatio.Macro` — scriptum! マクロ本体、文字列リテラル→loqui 変換、式埋込
- `Notatio.Verificatio` — native_decide による rfl 検証テスト

---

## v0.2.0 (2026-02-01) — Pure Lean TCP SSTP & 品質改善

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

## v0.1.1 (2026-01-01) — 最適化 (Optimizatio)

### `evadeTextus` の文字列構築改善 (`SakuraScriptum.lean`)
SakuraScriptum の特殊文字遁走處理で、通常文字の追加を `String.ofList [c]`（毎囘リスト生成 + 文字列變換）から `acc.push c`（1文字直接追加）に變更したにゃ。文字列が長いほど效果が出るにゃん♪

### `executareScripturam` の O(n²) → O(n) 改善 (`StatusPermanens.lean`)
永続化の書出處理で、リストの末尾に `++` で追加してゐたのを、先頭に `::` で追加して最後に `.reverse` する方式に變更したにゃ。`++` はリスト全體を毎囘コピーするので O(n²) だったのが、O(n) になったにゃん♪

### `Protocollum/Rogatio.lean` の配列構築簡素化
`referentiae` 配列の初期化を手動ループから `(List.replicate maximumIndex "").toArray` に變更したにゃ。すっきりにゃん♪
