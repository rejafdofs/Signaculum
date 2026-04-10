# Signaculum 仕様書

Signaculum は Lean 4 で書かれた SHIORI/3.0 栞ライブラリ。
Ukagaka ゴーストが require するだけで使える。

---

## 全體構成

```
SSP (Ukagaka ベースウェア)
  │  DLL load/unload/request 呼出し
  ▼
procurator/shiori.dll  (Rust FFI ラッパー、詳細は docs/Procurator.md)
  │  パイプ經由で ghost.exe と通信する（コマンドバイト 1/2/3）
  ▼
Signaculum.Nucleus.Exporta  ← exportaLoad / exportaUnload / exportaRequest
  │
  ├── Signaculum.Nucleus.Nuculum   ← Shiori 構造體・tracta
  │     ├── Signaculum.Protocollum.Rogatio     ← SHIORI/3.0 要求の解析
  │     ├── Signaculum.Protocollum.Responsum   ← SHIORI/3.0 應答の生成
  │     └── Signaculum.Protocollum.Typi        ← 共通型・定數
  │
  ├── Signaculum.Sakura.*    ← SakuraScript モナドと DSL
  │     ├── Sakura.Typi           ← 型定義
  │     ├── Sakura.Signum.*       ← Signum 歸納型（17 カテゴリ）
  │     ├── Sakura.Status         ← SakuraM モナド定義
  │     ├── Sakura.Fundamentum    ← 基盤（emitte, loqui）
  │     ├── Sakura.Textus.*       ← テクストゥス・書體・選擇肢・制御
  │     │     ├── Textus.Scopi        ← 範圍制御（人格切替）
  │     │     ├── Textus.Superficiei  ← 表面制御（表情）
  │     │     ├── Textus.Exhibitionis ← 文字表示
  │     │     ├── Textus.Morae        ← 待機・テンポ制御
  │     │     ├── Textus.Optionum     ← 選擇肢
  │     │     ├── Textus.Imperii      ← 制御命令
  │     │     ├── Textus.Formae       ← 書體
  │     │     ├── Textus.Bullae       ← 吹出し
  │     │     ├── Textus.Utilia       ← 便利關數・無作爲・實行
  │     │     ├── Textus.Responsi     ← レスポンスムヘッダー設定
  │     │     ├── Textus.Catena       ← チェイントーク
  │     │     └── Textus.Colloquium   ← 統一トーク管理 DSL
  │     ├── Sakura.Systema.*      ← システム操作
  │     │     ├── Systema.Soni        ← 音響
  │     │     ├── Systema.Eventuum    ← 事象
  │     │     ├── Systema.Animationis ← 動畫パターン制御
  │     │     ├── Systema.Proprietatis← プロプリエタース・效果
  │     │     ├── Systema.Mutationis  ← ゴースト/シェル/吹出し變更
  │     │     ├── Systema.Retis       ← HTTP・ネットワーク
  │     │     └── Systema.Modorum     ← モード制御・同期
  │     ├── Sakura.Fenestra       ← 窓操作
  │     ├── Sakura.Systema.Communicationis ← ゴースト間通信（SSTP SEND）
  │     ├── Sakura.Literalis      ← リテラル解析
  │     └── Sakura.Theoremata    ← adCatenam 全稱證明（§1〜§8b）
  │
  ├── Signaculum.Memoria.*   ← 永続化・メモリー管理
  │
  ├── Signaculum.Sstp        ← SSTP/1.4 送信（TCP port 9801、Pure Lean）
  │
  ├── Signaculum.Syntaxis    ← コンパイル時 DSL 構文擴張
  ├── Signaculum.Notatio.*   ← scriptum! マクロ DSL（原形タグ記法）
  │     ├── Notatio.Lexema       ← LexemaSakurae 帰納型 IR
  │     ├── Notatio.Parsitor     ← カスタムパーサー（sakuraLexemaParser）
  │     ├── Notatio.Expande.*    ← タグ別展開ディスパッチ
  │     └── Notatio.Macro        ← scriptum! エラボレーター
  ├── Signaculum.Nucleus.Loop ← Communicatio 構造體による通信ループ管理
  ├── Signaculum.Elementa.*  ← 基礎要素（公理・補題・變數補助）
  │
  ├── Signaculum.Saori        ← SAORI ブリッジ（DLL/exe 呼出し）
  │
  ├── Signaculum.Utilia.*    ← ユーティリティ
  │     ├── Utilia.Tempus            ← 日時ユーティリティ（Std.Time 活用）
  │     ├── Utilia.Registrum         ← ログ機能（ghost_log.txt 記錄）
  │     ├── Utilia.Inspectio         ← 變數デバッグ支援
  │     ├── Utilia.ExpressioRegularis← 正規表現（pandaman64/lean-regex）
  │     └── Utilia.Horologium        ← タイマー（OnSecondChange 用）
  │
  └── Signaculum.Eventum.*   ← イベント処理支援
        ├── Eventum.NominaIaponica ← 日本語イベント名エイリアス
        └── Eventum.Involucra      ← イベントラッパー（なでられ・タイマー）
```

---

## モジュール別仕様

### Signaculum.Protocollum.Typi

SHIORI/3.0 プロトコルの共通型と定數。

| 型 | 説明 |
|---|---|
| `Methodus` | 要求の手法。`.pete` (GET) か `.notifica` (NOTIFY) |
| `StatusCodis` | 應答の狀態符號。200 / 204 / 311 / 312 / 400 / 500 |
| `crlf` | `"\r\n"` |
| `shioriVersio` | `"SHIORI/3.0"` |

---

### Signaculum.Protocollum.Rogatio

SHIORI/3.0 要求文字列を解析して `Rogatio` 構造體に変換する。

```
GET SHIORI/3.0\r\n
ID: OnBoot\r\n
Charset: UTF-8\r\n
Reference0: 0\r\n
\r\n
```

↓ `Rogatio.interpreta`

```lean
{ methodus    = .pete
  nomen       = "OnBoot"
  referentiae = #["0"]
  forma       = "UTF-8"
  ... }
```

`Reference0`〜`ReferenceN` は番號順に `referentiae : Array String` へ格納される。
番號が飛んでいる場合は空文字列で埋める。

追加ヘッダー:

| フィールド | ヘッダー | 説明 |
|---|---|---|
| `typusMittentis` | SenderType | イヴェントゥム發信元の分類（SSP 2.5.05+） |
| `status` | Status | ゴーストの狀態フラグ（talking, choosing 等） |
| `securitasOrigo` | SecurityOrigin | 送信サーヴァーの URL 形式文字列 |

---

### Signaculum.Protocollum.Responsum

`Responsum` 構造體から SHIORI/3.0 應答文字列を生成する。

```
SHIORI/3.0 200 OK\r\n
Charset: UTF-8\r\n
Value: \h\s[0]やあ。\e\r\n
\r\n
```

| 構築關數 | 狀態 | 説明 |
|---|---|---|
| `ok scriptum` | 200 | SakuraScript を Value に入れる |
| `nihil` | 204 | 空應答（應答不要イベント） |
| `pluribusDatis` | 311 | OnTeach で追加情報が必要 |
| `rescribeInput` | 312 | OnTeach で最新入力を破棄して再試行 |
| `malaRogatio` | 400 | 要求が不正 |
| `errorInternus` | 500 | 内部例外 |

`Responsum` は Value 以外のレスポンスムヘッダーも型安全に保持する:

| フィールド | ヘッダー | 型 |
|---|---|---|
| `sender` | Sender | `Option String` |
| `errorLevel` | ErrorLevel | `Option String`（"info"/"notice"/"warning"/"error"/"critical"）|
| `errorDescription` | ErrorDescription | `Option String` |
| `marker` | Marker | `Option String` |
| `balloonOffset` | BalloonOffset | `Option (Int × Int)` |
| `age` | Age | `Option Nat` |
| `securitas` | SecurityLevel | `Option String` |
| `markerSend` | MarkerSend | `Option String` |
| `valorNotifica` | ValueNotify | `Option String` |
| `cappitta` | 任意ヘッダー | `List (String × String)` |

---

### Signaculum.Nucleus.Nuculum

栞の核心。`Shiori` 構造體とルーティング。

```lean
structure Shiori where
  tractatores : Std.HashMap String Tractator  -- O(1) 探索にゃ
  status      : IO.Ref ShioriStatus
  onOnerare   : Option (String → IO Unit)  -- load フック
  onExire     : Option (IO Unit)           -- unload フック

def Tractator := Rogatio → SakuraIO Unit
```

`tracta` が要求を受け取り `tractatores[rogatio.nomen]?`（`Std.HashMap` の O(1) 探索）でイベント名に對應する處理器を探して呼ぶ。
見つからなければ 204、例外が出れば `ErrorLevel: error` + `ErrorDescription: 例外メッセージ` 附きの SHIORI/3.0 500 應答を返す。
`Sakura.currere` は `StatusSakurae` を返し、`tracta` がレスポンスムヘッダー（Marker, BalloonOffset 等）を `Responsum` にマッピングする。

---

### Signaculum.Nucleus.Exporta

C グルーから呼ばれる `@[export]` 關數群。

| 關數 | 對應する C 側 | 説明 |
|---|---|---|
| `exportaLoad (domus)` | `load(hdir)` | 家ディレクトリを設定・onOnerare を呼ぶ |
| `exportaUnload` | `unload()` | onExire を呼ぶ |
| `exportaRequest (req)` | `request(req)` | 要求文字列を受け取り應答文字列を返す |

`spawnaMunitus` で非同期タスクを GC から保護しながら起動する機構もここにある。
新規タスク追加時に `IO.hasFinished` で完了済みタスクを自動除去し、
残りが `maximumMunera`（256）件を超えたら後半を残して古い前半を捨てる。

`exportaRequest` は例外を `ErrorLevel: critical` + `ErrorDescription` 附きの SHIORI/3.0 500 應答として返す。

---

### Signaculum.Sakura.*

SakuraScript を Lean で組み立てるためのモナドと DSL。

`SakuraIO α = StateT StatusSakurae IO α` — 構造化シグヌムのリストゥス（`List Signum`）とレスポンスムヘッダーを積み上げていくモナド。

#### Signum 型 — 構造化サクラスクリプトタグ

全ての SakuraScript タグを型安全な帰納型 `Signum` で表現する。17 のカテゴリ別子帰納型をラップした判別共用體。

```lean
inductive Signum where
  | scopi         : SignumScopi → Signum         -- 人格切替（\h, \u, \p[n]）
  | superficiei   : SignumSuperficiei → Signum   -- 表情（\s[n], \i[n]）
  | exhibitionis  : SignumExhibitionis → Signum  -- テキスト表示（\n, \c, \_l 等）
  | morae         : SignumMorae → Signum         -- 待機（\w, \_w, \x）
  | optionum      : SignumOptionum → Signum      -- 選擇肢
  | imperii       : SignumImperii → Signum       -- 制御（\e, \-, \_q 等）
  | formae        : SignumFormae → Signum        -- 書式（フォント、色、揃へ）
  | bullae        : SignumBullae → Signum        -- 吹出し
  | fenestrae     : SignumFenestrae → Signum     -- 窓操作
  | inputi        : SignumInputi → Signum        -- 入力ダイアログ
  | soni          : SignumSoni → Signum          -- 音聲
  | eventuum      : SignumEventuum → Signum      -- 事象（\![raise,...] 等）
  | animationis   : SignumAnimationis → Signum   -- アニメーション
  | mutationis    : SignumMutationis → Signum    -- ゴースト切替
  | retis         : SignumRetis → Signum         -- ネットワーク・HTTP
  | modorum       : SignumModorum → Signum       -- モード變更
  | proprietatis  : SignumProprietatis → Signum  -- プロパティ取得
```

| 關數 | 説明 |
|---|---|
| `Signum.adCatenam` | 個別の `Signum` をサクラスクリプト文字列に變換する |
| `adCatenamLista signa` | `List Signum` を連結してサクラスクリプト文字列に變換する |

`StatusSakurae.scriptum` の型は `List Signum` であり、`emitte` で蓄積し、最終的に `adCatenamLista` で文字列化される。

| 關數 | 説明 |
|---|---|
| `Sakura.currere` | SakuraIO を実行して `StatusSakurae`（スクリプトゥム + ヘッダー）を得る |
| `Sakura.currereScriptum` | SakuraIO を実行してスクリプトゥム文字列のみを得る |
| `Sakura.excita` | 別イベントを發生させる |
| `Sakura.insere` | スクリプトに別イベントを埋め込む |
| `Sakura.notifica` | NOTIFY 通知を發生させる |
| `Sakura.excitaPostTempus` | 遅延発火 |
| `Sakura.aperiInputum` | テキスト入力ボックス（simplex/sigillum） |
| `Sakura.aperiInputumDiei` | 日付入力（月: 1〜12、日: diesInMense による閏年考慮検証） |
| `Sakura.aperiInputumTemporis` | 時刻入力（時: ≤23、分秒: ≤59） |
| `Sakura.aperiInputumGradus` | スライダー入力（minimum ≤ initium ≤ maximum） |
| `Sakura.aperiInputumIP` | IP アドレス入力（各オクテット ≤ 255） |
| `Sakura.aperiInputumColoris` | 色入力（RGB 各 ≤ 255） |

#### パラメータ境界検証

以下の関数は証明パラメータによるコンパイル時境界検証を持つ。不正な値はコンパイルエラーになる。

| 関数 | 制約 |
|---|---|
| `Coloris.rgb r g b` | 各値 ≤ 255 |
| `OptionesSoni.cumVolumine n` | n ≤ 100 |
| `OptionesSoni.cumLibramento n` | -100 ≤ n ∧ n ≤ 100 |
| `OptionesSoni.cumCursu n` | 1 ≤ n ∧ n ≤ 10000 |
| `moraCeler n` | 1 ≤ n ∧ n ≤ 9 |
| `configuratioAlphae n` | n ≤ 100 |
| `aperiInputumIP ip1 ip2 ip3 ip4` | 各オクテット ≤ 255 |
| `aperiInputumDiei annus mensis dies` | 1 ≤ mensis ≤ 12、1 ≤ dies ≤ diesInMense annus mensis |
| `aperiInputumTemporis hora minutum secundum` | hora ≤ 23、minutum ≤ 59、secundum ≤ 59 |
| `aperiInputumGradus minimum maximum initium` | minimum ≤ initium ∧ initium ≤ maximum |

`lineaProportionalis` は `Nat` から `Int` に変更され、負値や100超の指定も可能になった。

#### 補助関数（Typi.lean）

| 関数 | 説明 |
|---|---|
| `estBissextilis annus` | 閏年判定（400/100/4 年規則） |
| `diesInMense annus mensis` | 指定年月の日数を返す（閏年考慮） |

---

### Signaculum.Sstp — Pure Lean TCP SSTP

SSTP/1.4 プロトコルで TCP (`localhost:9801`) 經由で SSP にスクリプトを送信する。
**C コード不要** — `Std.Internal.UV.TCP.Socket`（Lean 4 組込み libuv バインディング）のみで實裝されてゐる。

| 關數 | 説明 |
|---|---|
| `sstpDirectumMittere` | 生の SSTP リクエスト文字列を TCP で SSP に送信する |
| `mitteSstpScriptum` | `EXECUTE SSTP/1.4` リクエストを組み立てて送信する。`mittens` 引數で Sender を指定可能（デフォルト: `mittensDefectus = "uka-lean"`） |
| `excitaEventum` | `NOTIFY SSTP/1.4` リクエストを送信する。`mittens` 引數で Sender を指定可能 |
| `purgaCrlf` | ヘッダー値から CR/LF を除去してパケット破損を防ぐ |

#### SSTP/1.4 パケット形式

Execute:
```
EXECUTE SSTP/1.4\r\n
Charset: UTF-8\r\n
Sender: {mittens}\r\n
Script: \h\s[0]やあ。\e\r\n
\r\n
```

Notify:
```
NOTIFY SSTP/1.4\r\n
Charset: UTF-8\r\n
Sender: {mittens}\r\n
Event: OnSomeEvent\r\n
Reference0: arg0\r\n
\r\n
```

#### TCP 通信フロー

1. `Socket.new` で TCP ソケットを生成
2. `sock.connect` で `127.0.0.1:9801` に接續（`IO.Promise` を返す非同期 API）
3. `sock.send` でリクエスト文字列を UTF-8 バイト列として送信
4. `sock.shutdown` で TCP FIN を送信して切斷
5. 接續失敗（SSP 未起動等）は `try/catch` で靜かに無視（舊 C 實裝と同一の振舞ひ）

#### 舊實裝（削除濟み）

以前は `Signaculum/c/sstpDirectum.c` で Win32 `WM_COPYDATA` による Direct SSTP を C FFI で實裝してゐたが、
Windows 專用かつ非 Windows 環境では no-op スタブになる制限があつた。
TCP SSTP は OS 非依存で動作するため、C コードを完全に排除した。

---

### Signaculum.Memoria.*

| モジュール | 説明 |
|---|---|
| `StatusPermanens` | `ghost_status.bin` への永続化（型クラスベース） |
| `Lemma` | 永続化の補題・証明 |
| `Auxilia` | 補助關數 |
| `Citationes` | `Citatio` 型クラス（Reference との変換） |
| `Citatio` | `toRef`/`fromRef` の基本インスタンス |

---

### Signaculum.Syntaxis — コンパイル時 DSL

ゴースト作者が使う構文マクロ群。コンパイル時に環境拡張 `GhostAccumulatio` へ宣言を蓄積し、`construe` が最終的に `registraShiori(Ex)` の呼出しコードを生成する。

`registraLazium` / `registraLaziumLambda` はコールバック登録の共通基盤。scriptum! マクロ（Expande 配下）からも呼び出されるため public。

| 構文 | 説明 |
|---|---|
| `varia perpetua n : T := v` | 永続化される變數を宣言 |
| `varia temporaria n : T := v` | 一時變數を宣言 |
| `eventum "名前" 処理器` | イベントハンドラを登録 |
| `excita f args*` | def ベースのイベントを發生させる（識別子形）。args は Reference 経由で渡される |
| `excita (fun _ => ...)` | ラムダ形（引数なし）。ラムダは Tractator として直接登録 |
| `excita (fun p:T => ...) args*` | ラムダ形（引数あり）。args を Reference 経由で渡し、ラムダのパラメータ型に自動変換 |
| `insere f args*` | def ベースのイベントをスクリプトに埋め込む（識別子形） |
| `insere (fun _ => ...)` | ラムダ形（引数なし） |
| `insere (fun p:T => ...) args*` | ラムダ形（引数あり） |
| `notifica f args*` | def ベースの NOTIFY を發生させる（識別子形） |
| `notifica (fun _ => ...)` | ラムダ形（引数なし） |
| `notifica (fun p:T => ...) args*` | ラムダ形（引数あり） |
| `excitaPostTempus ms rep f args*` | def ベース遅延発火（識別子形） |
| `excitaPostTempus ms rep (fun _ => ...)` | ラムダ形遅延発火（引数なし） |
| `excitaPostTempus ms rep (fun p:T => ...) args*` | ラムダ形遅延発火（引数あり） |
| `notificaPostTempus ms rep f args*` | def ベース遅延通知（識別子形） |
| `notificaPostTempus ms rep (fun _ => ...)` | ラムダ形遅延通知（引数なし） |
| `notificaPostTempus ms rep (fun p:T => ...) args*` | ラムダ形遅延通知（引数あり） |
| `optioEventum titulus f args*` | def ベース事象付き選擇肢 |
| `spawna f args*` | IO Unit を非同期実行 |
| `spawnaScriptum f args*` | SakuraIO Unit を非同期実行して SSTP で送信 |
| `construe` | 全宣言を組み合わせて栞を構築・登録し `def main` も自動生成 |
| `aperiInputum modus f titulus textus` | テキスト入力（f は識別子/ラムダ）。Reference[0] がテキストとしてパラメータに渡される |
| `aperiInputumDiei f titulus annus mensis dies` | 日付入力（f は識別子、境界検証付き） |
| `aperiInputumTemporis f titulus hora minutum secundum` | 時刻入力（f は識別子、境界検証付き） |
| `aperiInputumGradus f titulus minimum maximum initium` | スライダー入力（f は識別子、境界検証付き） |
| `aperiInputumIP f titulus ip1 ip2 ip3 ip4` | IP 入力（f は識別子、各オクテット ≤ 255） |
| `aperiInputumColoris f titulus r g b` | 色入力（f は識別子、RGB 各 ≤ 255） |

---

### Signaculum.Notatio.* — scriptum! マクロ DSL

SakuraScript を原形タグ記法（`\h \s[0] "テキスト" \e`）で書けるマクロ DSL。`scriptum!` マクロを提供し、型チェッカが引数の妥当性を自動検証する。タグ構文と使用法の詳細は [docs/Notatio.md](Notatio.md) を参照。

#### 處理パイプライン

```
scriptum! ブロック（ソース文字列）
  │
  ▼  Phase 1: パース（Parsitor.lean）
sakuraLexemaParser (カスタム ParserFn)
  先頭文字で分岐:
    '\' → バックスラッシュタグ / 感嘆符タグ / 書體タグ
    '"' → 文字列リテラル
    '{' → 式埋込
    '%' → 環境變數
    他  → 裸テクストゥス
  [] 内引數: デリミタ（, ] " \ { } ( )）と空白以外の全文字を受理。
    スペース區切りテキスト（例: OnInterval 30）は , や ] まで吸收して strLit に變換。
  │
  ▼  Phase 2: 中間表現（Lexema.lean）
LexemaSakurae ノード（Syntax ノードとして stxStack に積まれる）
  │
  ▼  Phase 3: 展開（Macro.lean + Expande/*.lean）
genTermLexema: ノードカインドでディスパッチ
  lexemaTextusNudus   → loqui "テキスト"
  lexemaTextusLit     → loqui "..."
  lexemaExpressio     → (expr : SakuraM _ Unit)  ← Exhibibilis 型クラス
  lexemaVariabilis    → variabilisAmbientis "name"
  lexemaSignum        → Expande.Textus / Fenestra / Systema に委譲
  lexemaSignumExcl    → Expande.Fenestra / Systema に委譲
  lexemaFontis        → Expande.Fons に委譲
  │
  ▼  Phase 4: エラボレーション（Macro.lean elabScriptum）
Bind.bind で連鎖した SakuraM m Unit 項
  異なる行のトークン間に自動 linea（\n）挿入
```

#### LexemaSakurae 帰納型 IR

パーサーが生テクストゥスからシンタクスノードを生成し、エラボレーターが `SakuraM` term に變換する中間表現。

| コンストラクタ | 説明 | 例 |
|---|---|---|
| `textusNudus` | 裸テクストゥス（タグでも式でもない平文） | `こんにちは` |
| `signum` | バックスラッシュタグ（タグ名 + [] 内引數） | `\h`, `\s[0]`, `\w 5` |
| `signumExclamationis` | 感嘆符タグ（コマンド名 + 引數） | `\![move,100,200]` |
| `expressioInserta` | 式埋込 | `{s!"hello"}` |
| `textusLiteralis` | 文字列リテラル | `"こんにちは"` |
| `variabilisAmbientis` | 環境變數參照 | `%username` |
| `signaturaFontis` | 書體タグ（キー名 + 値） | `\f[bold,true]` |

#### Expande ディスパッチ構造

`genTermLexema` は `signum` / `signumExclamationis` / `signaturaFontis` ノードをタグ名に基づいて4つの展開モジュールに委譲する。

| モジュール | 擔當 | 主なタグ |
|---|---|---|
| `Expande.Textus` | 基本タグ展開 | `\h` `\u` `\p` `\s` `\n` `\w` `\x` `\e` `\q` `\_a` 等 |
| `Expande.Fenestra` | 窓制御タグ展開 | `\![move,...]` `\![set,...]` `\![enter,...]` `\![open,...]` 等 |
| `Expande.Systema` | システムタグ展開 | `\![raise,...]` `\![embed,...]` `\![sound,...]` `\![anim,...]` 等 |
| `Expande.Fons` | 書體タグ展開 | `\f[bold,...]` `\f[color,...]` `\f[height,...]` `\f[default]` 等 |

`Fenestra` と `Systema` はさらにサブモジュール（`Fenestra/Aperitio`, `Fenestra/Configuratio`, `Systema/Eventum`, `Systema/Sonus`, `Systema/Animatio`, `Systema/Rete`, `Systema/Reliqua`）に分割されてゐる。

#### コールバック統一形

`\![open,inputbox,...]` 等の入力ダイアログ、`\![raise,...]` 等のイベント發火タグでは、コールバック引數に文字列リテラル・識別子・ラムダ式のいづれでも渡せる。Expande 側の `resolveCallbackum` / `resolveCallbackumEventum` がシンタクスノードの種類で三方向に分岐する:

1. **strLit** → イヴェント名としてそのまま渡す（従来の文字列形）
2. **ident** → `registraLazium` でコールバック登録（型から paramCount を自動推定）
3. **その他の term** → `registraLaziumLambda` で登録（paramCount は追加引數數）

いづれの場合も最終的に `Signaculum.Sakura.*` のランタイム関數にイヴェント名文字列として渡される。`construe` が `ghostAccumulatioExt` の `LazyEventDecl` から Tractator ラッパー def を自動生成し、SHIORI ハンドラテーブルに登録する。

#### イヴェント名の UUID v4 化

識別子形・ラムダ形で登録されるイヴェント名は、関數名やソース位置ではなく UUID v4 準據の一意識別子が自動生成される。形式は `On_xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`。

- **関數名の隠蔽**: Lean の内部名がプロトコル上に露出しない
- **SSP 直接發火**: `On` プレフィクスにより、SSP が `\![open,inputbox,...]` 等のウィジェットコールバックで `OnUserInput` にリダイレクトせず、指定された ID で直接發火する（ukadoc 仕様: イヴェント名が `On` で始まる場合は直接發火、それ以外は `OnUserInput` / `OnChoiceSelect` / `OnAnchorSelect` 等にリダイレクト）
- **衝突回避**: 128ビット亂數による UUID v4 で、イヴェント名の衝突が實質不可能

#### エラーメッセージ

`Parsitor/Argumenta.lean` の `argumentaInUncisFn` は括弧内引數を解析し、不正な引數に對してタグ名入りの日本語エラーメッセージを生成する（例: `\s[aaa]` → `\s: []の中には数字が期待されてゐますにゃ`）。

#### 検証

ランタイム関数の正しさは `Sakura/Theoremata.lean` の全称証明（∀ 量化）で保証する。全 Signum カテゴリの adCatenam 関数について、定数・Bool・Nat/Int・String・有限列挙・if/match 分岐を含む全コンストラクタの出力が定義通りであることを証明済み。加えて adCatenamLista のリスト連結準同型性、evadeTextus/evadeArgumentum の定義展開同値性、SignumFormae の構造的 prefix/suffix 性質も証明済み。

`Notatio/Verificatio.lean` には scriptum! マクロ固有の動作検証（行跨ぎ改行自動挿入、式埋込、舊形式スコープ、裸テクストゥス解析）のみを置く。

使用例:

```lean
import Signaculum.Notatio
open Signaculum.Notatio

def myTalk : SakuraPura Unit := scriptum!
  \h \s[0] "こんにちは" \n
  \u \s[10] "やっほー"
  \e
```

---

### Signaculum.Utilia.* — ユーティリティ

ゴースト開発向けの汎用ユーティリティ群。

#### Utilia.Tempus — 日時ユーティリティ

`Std.Time` を活用した日時関数群。時間帯別の挨拶分岐やログのタイムスタンプに使える。

| 関数 | 説明 |
|---|---|
| `obtineTempus` | 現在時刻を `PlainDateTime`（UTC）として取得 |
| `obtineTimestamp` | Unix タイムスタンプを取得 |
| `estMane dt` | 朝かどうか（6 ≤ hora < 12） |
| `estMeridies dt` | 昼かどうか（12 ≤ hora < 18） |
| `estVespera dt` | 夕方かどうか（18 ≤ hora < 24） |
| `estNox dt` | 夜かどうか（0 ≤ hora < 6） |
| `tempusAdTextum dt` | "YYYY-MM-DD HH:MM:SS" 形式の文字列に変換 |

#### Utilia.Registrum — ログ機能

YAYA の LOGGING に相当するログ機能。`ghost_log.txt` にタイムスタンプ付きでメッセージを記録する。

| 関数 | 説明 |
|---|---|
| `registra gradus nuntius` | 指定等級でログ出力 |
| `registraIndicium nuntius` | INFO ログ |
| `registraMonitum nuntius` | WARN ログ |
| `registraErrorem nuntius` | ERROR ログ |
| `registraM gradus nuntius` | SakuraIO 内でログ出力 |
| `registraEtNotifica gradus nuntius` | SakuraIO 内でログ + SHIORI ErrorLevel/ErrorDescription に設定 |

ログ等級 `GradusRegistri` は `.indicium`（INFO）、`.monitum`（WARN）、`.error`（ERROR）の3段階。
`registraEtNotifica` は `StatusSakurae` の `errorLevel`/`errorDescription` にも設定するため、SSP 側のログにもエラー情報が記録される。

グローバル設定:

| 関数 | 説明 |
|---|---|
| `activaRegistrum` | ログ出力を有効にする |
| `inactivaRegistrum` | ログ出力を無効にする |
| `statuereDomusRegistri domus` | ログファイルのディレクトリを設定（exportaLoad から呼ばれる） |

#### Utilia.Inspectio — 変数デバッグ支援

`construe` が `inspiceVariabiles : IO Unit` を自動生成する。全 `varia perpetua` の名前・型・現在値を `ghost_log.txt` に出力する。

| 関数 | 説明 |
|---|---|
| `inspiceVariabiles` | 全変数をログにダンプ（`construe` が自動生成） |
| `inspiceEtMitte nomen obtineValorem` | 個別変数をログ出力 + SSTP でゴーストにも表示 |
| `caputInspectionis` | ダンプのヘッダー文字列 |
| `lineaInspectionis nomen typus valor` | ダンプの単一行を生成 |

---

### Signaculum.Eventum.* — イベント処理支援

生の SHIORI イベントを加工して高レベルな抽象を提供するモジュール群。

#### Eventum.NominaIaponica — 日本語イベント名

里々方式の日本語イベント名エイリアス。`eventum "起動"` と書くと `OnBoot` に自動変換される。

`tabulaEventorum : List (String × String)` に 70 以上のマッピングが定義済み。テーブルにない名前はカスタムイベント名としてそのまま使われる。

| 関数 | 説明 |
|---|---|
| `resolveNomenEventi nomen` | 日本語名を SHIORI/3.0 イベント名に変換（テーブルにない場合はそのまま返す） |

カテゴリ別マッピング例:

| 日本語名 | SHIORI イベント名 |
|---|---|
| `起動` | `OnBoot` |
| `終了` | `OnClose` |
| `ランダムトーク` | `OnAITalk` |
| `クリック` | `OnMouseClick` |
| `毎秒` | `OnSecondChange` |
| `選択肢選択` | `OnChoiceSelect` |

#### Eventum.Involucra — イベントラッパー

生の SHIORI イベントを加工して高レベルな抽象を提供する。里々の「なでられ」「つつかれ」や YAYA のシステム辞書に相当する。

##### なでられ判定

`OnMouseMove` の連続回数が閾値を超えたら「なでられた」と判定する。scope + area をキーにして個別にカウントする。

| 関数 | 説明 |
|---|---|
| `iudicaNaderare scopeId areaName` | なでられ判定を行う（`IO Bool`） |
| `configuraNaderareLimen limen` | 閾値を設定（デフォルト 10） |
| `configuraNaderareIntervallum ms` | リセットまでの最大間隔を設定（デフォルト 2000ms） |

##### マウスイベント名生成

| 関数 | 説明 |
|---|---|
| `nomenEventumMusis rogatio suffix` | `"{scopeId}{areaName}{suffix}"` 形式のイベント名を生成 |

##### ランダムトークタイマー

`OnSecondChange` でカウントダウンし、0 に達したらランダムトーク発火を通知する。ゴーストが話し中（`talking`）や選択肢提示中（`choosing`）の場合は発火しない。

| 関数 | 説明 |
|---|---|
| `pulsaTimerColloquii status` | タイマーパルス（0 到達で `true`、`IO Bool`） |
| `configuraIntervallumColloquii secundae` | ランダムトーク間隔を設定（秒、デフォルト 180） |

---

### Signaculum.Sakura.Textus.Colloquium — 統一トーク管理

ランダムトーク・条件付きトーク・チェイントークを `Colloquium` 帰納型で統一管理する DSL。旧 API（`OptioPiscinae` / `eligeVelCatena`）の改善版。

```lean
inductive Colloquium where
  | loquela   (actio : SakuraIO Unit)           -- 通常トーク
  | conditio  (cond : IO Bool) (actio : SakuraIO Unit)  -- 条件付き
  | series    (c : Catena)                      -- チェイントーク
  | seriesCum (cond : IO Bool) (c : Catena)     -- 条件付きチェイン
```

`Coe` インスタンスにより `SakuraIO Unit` と `Catena` は配列内で自動変換される。

| 関数 | 説明 |
|---|---|
| `eligeColloquium colloquia` | 配列から均等確率で選択・実行（アクティブチェイン優先続行） |
| `eligeColloquiumPonderatum colloquia` | 重み付き確率で選択・実行 |
| `cum cond actio` | 条件付きトークの便利コンストラクタ |
| `cumSeries cond catena` | 条件付きチェインの便利コンストラクタ |

---

### Signaculum.Utilia.ExpressioRegularis — 正規表現

`pandaman64/lean-regex` ライブラリーのラッパー。ゴースト開發でのテクストゥス處理に便利な正規表現關數群を提供する。

| 關數 | 説明 |
|---|---|
| `quaereRE exemplar textus` | 最初のマッチとキャプチャグループを檢索。マッチ全體が `[0]`、キャプチャグループが `[1]` 以降に入る。マッチしなければ `none` |
| `congruatRE exemplar textus` | テクストゥスがパターンにマッチするか判定（`Bool`） |
| `quaereOmnesRE exemplar textus` | 全マッチ文字列を配列で返す |
| `substitueRE exemplar substitutio textus` | パターンにマッチした全箇所を `substitutio` に置換 |
| `scindeRE exemplar textus` | パターンをデリミタとしてテクストゥスを分割 |
| `numeraRE exemplar textus` | マッチした箇所の數を返す |

全關數はパターンが不正な場合でも例外を投げず、`none` / `false` / 空配列 / 元テクストゥスを返す安全設計。`Regex.build` の `Except` を `.toOption` で變換してゐる。

---

### Signaculum.Sakura.Systema.Communicationis — ゴースト間通信

SSTP/1.4 SEND プロトコルで他のゴーストにスクリプトゥムやテクストゥムを送信する。`Signaculum.Sstp` の低レベル關數を SakuraIO コンテクストにリフトしたラッパー。

| 關數 | 説明 |
|---|---|
| `communicaScriptum ghostNomen scriptum` | 他ゴーストに SakuraScript を送信（SSTP SEND / `IfGhost` + `Script` ヘッダー） |
| `communicaSentence ghostNomen sentence` | 他ゴーストにテクストゥムを送信（SSTP SEND / `IfGhost` + `Sentence` ヘッダー） |

いづれも `mittens` 引數で Sender を指定可能（デフォルト: `mittensDefectus = "uka-lean"`）。

低レベル（`Signaculum.Sstp`）:

| 關數 | 説明 |
|---|---|
| `communicaSstpScriptum ghostNomen scriptum` | SSTP SEND で Script を送信（`IO Unit`） |
| `communicaSstpSentence ghostNomen sentence` | SSTP SEND で Sentence を送信（`IO Unit`） |

#### SSTP/1.4 SEND パケット形式

Script 送信:
```
SEND SSTP/1.4\r\n
Charset: UTF-8\r\n
Sender: {mittens}\r\n
Script: {scriptum}\r\n
IfGhost: {ghostNomen}\r\n
\r\n
```

Sentence 送信:
```
SEND SSTP/1.4\r\n
Charset: UTF-8\r\n
Sender: {mittens}\r\n
Sentence: {sentence}\r\n
IfGhost: {ghostNomen}\r\n
\r\n
```

---

### Signaculum.Saori — SAORI ブリッジ

SAORI-universal（DLL）および SAORI-basic（.exe）の呼出し機構。
SAORI-universal は procurator32 經由のパイプ通信で Win32 DLL を呼び出す。SAORI-basic は `IO.Process` で外部プロセスを直接起動する。

#### SAORI-universal（DLL、procurator32 經由）

| 關數 | 説明 |
|---|---|
| `onerareSaori via directorium` | SAORI DLL をロード（コマンド 0x04）。`via` は DLL パス、`directorium` は ghost ホームディレクトーリウム。成功なら `true` |
| `vocareSaori via argumenta` | SAORI DLL にリクエスト送信（コマンド 0x05）。SAORI/1.0 リクエストゥムを自動組立。Result + Value の配列を返す |
| `exonerareSaori via` | SAORI DLL をアンロード（コマンド 0x06） |
| `vocareSaoriM via argumenta` | SakuraIO コンテクスト内から `vocareSaori` を呼ぶラッパー |

#### SAORI-basic（.exe、IO.Process 經由）

| 關數 | 説明 |
|---|---|
| `vocareSaoriBasic exeVia argumenta` | 外部プロセスを起動し stdout を結果として返す。異常終了時は `none` |

#### SAORI/1.0 リクエスト形式

```
EXECUTE SAORI/1.0\r\n
Charset: UTF-8\r\n
Argument0: {arg0}\r\n
Argument1: {arg1}\r\n
\r\n
```

#### SAORI/1.0 應答パース

應答文字列から `Result:` ヘッダーを最初の要素、`Value0:` `Value1:` ... を續く要素として配列に格納する。`parsaSaoriResponsum` が自動的にパースする。

#### パイプ IPC プロトコル（SAORI 擴張）

procurator32 と ghost.exe の間で SAORI 呼出しを中繼するコマンド。通常の SHIORI REQUEST 應答フローの中に SAORI コマンドが挟まる構造。詳細は [Procurator.md](Procurator.md) を参照。

| コマンドバイト | 方向 | 説明 |
|---|---|---|
| `0x04` | ghost → procurator | SAORI DLL ロード |
| `0x05` | ghost → procurator | SAORI DLL リクエスト |
| `0x06` | ghost → procurator | SAORI DLL アンロード |
| `0x00` | ghost → procurator | 最終 SHIORI 應答（SAORI ループ終了） |

---

### Signaculum.Utilia.Horologium — タイマー

OnSecondChange 用の高レヴェルタイマー抽象。`Eventum.Involucra.pulsaTimerColloquii`（ランダムトーク用）とは異なり、汎用の名前付きタイマーを複數管理できる。

```lean
structure Horologium where
  nomen       : String       -- タイマーの識別名にゃ
  intervallum : Nat          -- 發火間隔（秒）にゃ
  residuum    : IO.Ref Nat   -- 殘り秒數にゃん
```

| 關數 | 説明 |
|---|---|
| `creandum nomen intervallum` | タイマーを作成。`intervallum` 秒後に最初に發火する |
| `pulsaHorologium h` | タイマーを1秒進める。發火時刻に達したら `true` を返してリセット |
| `reinitia h` | タイマーをリセット（殘り秒數を `intervallum` に戻す） |
| `pulsaOmnia horologia` | 複數タイマーの一括パルス。發火したタイマー名の配列を返す |

---

### Signaculum.Syntaxis — resourcea マクロ

`resourcea` マクロで SHIORI Resource 応答を宣言的に定義できる。

| 構文 | 説明 |
|---|---|
| `resourcea "nomen" := "valor"` | 静的文字列でリソース応答を宣言 |
| `resourcea "nomen" body` | 動的（`IO String`）でリソース応答を宣言 |

`construe` が `GhostAccumulatio.resourceae` から全リソース応答ハンドラを SHIORI ハンドラテーブルに登録する。

---

## データフロー

```
[SSP]
  load(hdir)
    → exportaLoad: domus を設定、onOnerare 呼出し
  request(req_str)
    → exportaRequest
        → Rogatio.interpreta  (parse)
        → Shiori.tracta       (dispatch)
            → tractatores.lookup(nomen)
            → tractator(rogatio)  [ゴースト定義のハンドラ]
            → Sakura.currere  (StatusSakurae を得る)
            → StatusSakurae → Responsum にマッピング
        → Responsum.adProtocollum  (serialize、全ヘッダーを出力)
    ← 應答文字列
  unload()
    → exportaUnload: onExire 呼出し
```

非同期 SSTP 送信（`spawnaScriptum`）はこのフローとは独立して走る:

```
spawnaScriptum f →
  spawnaMunitus (IO.asTask) →
    Sakura.currere f →
    Sstp.mitteSstpScriptum →
      sstpDirectumMittere (Pure Lean TCP) →
        Socket.connect 127.0.0.1:9801 →
        Socket.send → [SSP]
```

---

## 不変条件・制約

- `exportaRequest` は必ず應答文字列を返す（例外は catch して `ErrorLevel: critical` + `ErrorDescription` 附きの SHIORI/3.0 500 應答に変換）
- `Rogatio.interpreta` が失敗した場合は `ErrorLevel: warning` 附きの 400 を返す
- `tractatores[nomen]?`（HashMap O(1) 探索）が失敗した場合は 204 を返す（ハンドラ未登録は正常）
- SSTP 送信は Pure Lean TCP（`localhost:9801`）で行ふ。C コード不要。Sender は `mittens` 引數で指定可能
- `taskusCustodia` は `IO.hasFinished` で完了済みタスクを自動除去し、上限 `maximumMunera`（256）件を超えたら前半を捨てて後半を残す
- `!` 關數（getElem!）は使用しにゃい。全ての配列アクセスは添字の正当性を證明して安全アクセスする
