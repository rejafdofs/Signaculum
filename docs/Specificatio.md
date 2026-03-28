# Signaculum 仕様書

Signaculum は Lean 4 で書かれた SHIORI/3.0 栞ライブラリ。
Ukagaka ゴーストが require するだけで使える。

---

## 全體構成

```
SSP (Ukagaka ベースウェア)
  │  DLL load/unload/request 呼出し
  ▼
procurator/shiori.dll  (Rust FFI ラッパー)
  │  パイプ經由で ghost.exe と通信する
  ▼
Signaculum.Nucleus.Exporta  ← exportaLoad / exportaUnload / exportaRequest
  │
  ├── Signaculum.Nucleus.Nuculum   ← Shiori 構造體・tracta
  │     ├── Signaculum.Protocollum.Rogatio     ← SHIORI/3.0 要求の解析
  │     ├── Signaculum.Protocollum.Responsum   ← SHIORI/3.0 應答の生成
  │     └── Signaculum.Protocollum.Typi        ← 共通型・定數
  │
  ├── Signaculum.Sakura.*    ← SakuraScript モナドと DSL
  │
  ├── Signaculum.Memoria.*   ← 永続化・メモリー管理
  │
  ├── Signaculum.Sstp        ← SSTP/1.4 送信（TCP port 9801、Pure Lean）
  │
  ├── Signaculum.Syntaxis    ← コンパイル時 DSL 構文擴張
  ├── Signaculum.Notatio.*   ← scriptum! マクロ DSL（原形タグ記法）
  ├── Signaculum.Nucleus.Loop ← Communicatio 構造體による通信ループ管理
  └── Signaculum.Elementa.*  ← 基礎要素（公理・補題・變數補助）
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
| `Sakura.aperiInputumDiei` | 日付入力（月: 1〜12、日: diesInMense による閏年考慮検証） |
| `Sakura.aperiInputumTemporis` | 時刻入力（時: ≤23、分秒: ≤59） |
| `Sakura.aperiInputumGradus` | スライダー入力（minimum ≤ initium ≤ maximum） |

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
| `aperiInputum modus (fun text => ...) titulus` | ラムダ形テキスト入力。Reference[0] がテキストとしてパラメータに渡される |
| `aperiInputumDiei f titulus annus mensis dies` | def ベースの日付入力（境界検証付き） |
| `aperiInputumTemporis f titulus hora minutum secundum` | def ベースの時刻入力（境界検証付き） |
| `aperiInputumGradus f titulus minimum maximum initium` | def ベースのスライダー入力（境界検証付き） |

---

### Signaculum.Notatio.* — scriptum! マクロ DSL

SakuraScript を原形タグ記法（`\h \s[0] "テキスト" \e`）で書けるマクロ DSL。`scriptum!` マクロを提供し、型チェッカが引数の妥当性を自動検証する。

| モジュール | 説明 |
|---|---|
| `Notatio.Categoria` | 構文カテゴリア `sakuraSignum`、`fontisClavis` の宣言 |
| `Notatio.Textus` | テキスト・範囲・待機・選択肢・制御タグ（`\h` `\u` `\s[n]` `\n` `\w n` `\x` `\e` 等） |
| `Notatio.Fons` | 書体タグ `\f[...]`（bold, italic, color, height, default 等） |
| `Notatio.Fenestra` | 窓制御・UI・モード・設定タグ（`\![move,...]` `\![enter,...]` `\![set,...]` 等） |
| `Notatio.Systema` | イベント・音響・動画・呼出・変更タグ（`\![raise,...]` `\![embed,...]` `\![notify,...]` `\![timerraise,...]` `\![timernotify,...]` `\![async,...]` `\![sound,...]` `\![anim,...]` `\![open,inputbox,...]` 等。識別子形・ラムダ形の両方を提供） |
| `Notatio.Macro` | `scriptum!` マクロ本体、文字列リテラル→`loqui` 変換、式埋込 `(expr)` |
| `Notatio.Verificatio` | `native_decide` による rfl 検証テスト |

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
