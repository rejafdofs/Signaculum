# Signaculum —  Lean 4 製 SHIORI

 SHIORI ビブリオテーカにゃん♪

- **型安全な永続化** — 保存→読込の往復を Lean 4 の定理として証明済みにゃ
- **型安全な Reference 変換** — `Citatio` クラッシスが `fromRef (toRef a) = a` を保証するにゃ
- **`do` 記法** — SakuraScriptum を直感的に組み立てられるにゃ
- **`scriptum` 記法** — `Signaculum.Notatio` モジュールでサクラスクリプトを原形タグ記法（`\h \s[0] "テキスト" \e`）で書けるにゃ
- 識別子は全てラテン語で統一されてゐるにゃ

---

## はじめに (Introductio)

### 前提 (Praemissa)

- [Lean 4 / elan](https://leanprover.github.io/lean4/doc/setup.html)（Lake 附属）
- Windows / Linux / macOS（SSTP は TCP `localhost:9801` で通信するため OS 非依存にゃ）

### ① 新規プロヱクトゥムを作るにゃ

```bash
lake new my-ghost
cd my-ghost
```

### ② `lakefile.toml` に追記するにゃ

```toml
name = "my-ghost"
version = "0.1.0"

[[require]]
git = "https://github.com/rejafdofs/Signaculum"
name = "Signaculum"

[[lean_lib]]
name = "Ghost"

[[lean_exe]]
name = "ghost"
root = "Main"
```

### ③ `Main.lean` を書くにゃ

```lean
import Signaculum

varia perpetua   numerusSalutationum : Nat := 0
varia temporaria nomina              : String := ""

eventum "OnFirstBoot" fun _ => scriptum
  \h \s[0] はじめましてにゃん！ \n
  \u \s[10] よろしくお願ひします。 \e

eventum "OnBoot" fun _ => do
  numerusSalutationum.renovare (· + 1)
  let numerus <- numerusSalutationum.obtinere
  sakura; superficies 0
  if numerus == 1 then
    loquiEtLinea "はじめましてにゃん！"
    mora 800; linea
    kero; superficies 10
    loquiEtLinea "よろしくお願ひします。"
  else
    loqui s!"起動 {numerus} 囘目にゃん♪"
  finis

eventum "OnClose" fun _ => do
  sakura; superficies 3; loqui "またにゃー！"
  finis

construe
```

### ④ 構築するにゃ

```bash
lake update
lake build ghost
```

### ⑤ `shiori.dll` を配置するにゃ

Releases から最新の `shiori.dll` を入手して、`ghost.exe` と同じフォルダに置くにゃ。

```
ghost/master/
├── shiori.dll        ← SSP から読まれる代理にゃ
├── ghost.exe         ← Lean 構築物にゃ
└── ghost_status.bin  ← 永続化ダータ（自動生成）にゃ
```

---

## 宣言の書き方

### `varia` — 變數の宣言

```lean
varia perpetua   名前 : 型 := 初期値   -- 終了時に保存・起動時に復元するにゃ
varia temporaria 名前 : 型 := 初期値   -- 起動中だけ使ふ一時的な變數にゃ
```

變数は `IO.Ref` として展開されるにゃ。

```lean
let n <- numerusSalutationum.obtinere   -- 読取にゃ
numerusSalutationum.statuere 42        -- 設定にゃ
numerusSalutationum.renovare (· + 1)   -- 更新にゃ
```

使へる型: `Nat` `Int` `Bool` `String` `Float` `UInt8/16/32/64` `Char` `ByteArray` `Option α` `List α` `Array α` `α × β`、および `StatusPermanens` クラッシスの実体を持つ任意の型にゃ。

**型安全な永続化にゃ♪**
型が変はつても `typusTag` が一致しにゃければ安全に読み飛ばされるにゃん。
保存→復元の往復は `ordinaMappam_roundtrip` 定理として Lean 4 で証明済みにゃ。

---

### `eventum` — 事象処理器の宣言

```lean
eventum "事象名" fun rogatio => do
  -- rogatio : Rogatio（SSP からの要求情報）
  ...
  finis   -- 末尾に必ず書くにゃ
```

`rogatio` から取れるもの:

| 式 | 型 | 内容 |
|---|---|---|
| `rogatio.nomen` | `String` | 事象名 |
| `rogatio.referentiam 0` | `Option String` | Reference0 |
| `rogatio.mittens` | `Option String` | Sender ヘッダ |
| `rogatio.securitas` | `Option String` | SecurityLevel ヘッダ |
| `rogatio.typusMittentis` | `Option String` | SenderType ヘッダ（SSP 2.5.05+） |
| `rogatio.status` | `Option String` | Status ヘッダ（talking, choosing 等） |
| `rogatio.securitasOrigo` | `Option String` | SecurityOrigin ヘッダ |
| `rogatio.caput "key"` | `Option String` | 任意ヘッダ |

---

### `construe` — 栞の総仕上げ

```lean
construe
```

主ファスキクルスの末尾に一度書くにゃ。`eventum` と `excita`/`insere` 識別子形で宣言した全ての処理器を、コンパイル時に環境拡張を介して収集し登録するにゃ♪

---

## `scriptum` 記法 (Notatio Scripti)

`Signaculum.Notatio` をインポートすると、サクラスクリプトのタグを直接書けるにゃ。
感嘆符あり（`scriptum!`）でも感嘆符なし（`scriptum`）でも同じにゃん♪

```lean
import Signaculum
```

### 基本の書き方

インデントで囲んだ範囲がひとつの `scriptum` ブロックになるにゃ：

```lean
eventum "OnBoot" fun _ => scriptum
  \h \s[0] こんにちは！ \e
```

`do` ブロック内では `scriptum!` の列が深いインデントにゃ：

```lean
eventum "OnBoot" fun _ => do
  numerusSalutationum.renovare (· + 1)
  let numerus <- numerusSalutationum.obtinere
  scriptum
    \h \s[0] {s!"起動 {numerus} 囘目にゃん♪"} \e
```

### 使へる要素

| 記法 | 意味 |
|---|---|
| `\h` `\u` `\e` `\n` `\c` `\x` | 基本タグにゃ |
| `\s[0]` `\s[-1]` | 表情にゃ |
| `\w 500` | 待機（ミリ秒）にゃ |
| `\b[0]` `\b[-1]` | 吹き出しにゃ |
| `\f[bold, true]` `\f[default]` | 書体にゃ |
| `\f[color, 255,0,0]` `\f[color, red]` `\f[color, nullus]` | 文字色にゃ |
| `\f[align, left]` `\f[align, center]` | 横揃へにゃ |
| `\f[valign, top]` `\f[valign, bottom]` | 縦揃へにゃ |
| `"文字列"` | テキストを表示にゃ |
| `識別子` | 識別子をそのままテキストにゃ（スペース区切りで複数可）にゃ |
| `{式}` | Lean の式を埋め込むにゃ（`String` は自動で `loqui` にゃ） |
| `\{` `\}` | `{` `}` をエスケープにゃ |

### 複数タグの連結

```lean
eventum "OnGreet" fun _ => scriptum
  \h \s[0] やあ！ \w 500 \n どこから来たの？ \e
```

### Lean 式の埋め込み

```lean
let nomen := "シロ"
scriptum
  \h \s[0] {s!"こんにちは、{nomen}さん！"} \e
```

`{}` の中に `String` 型の式を入れると `loqui` で表示されるにゃ。
`SakuraM m Unit` 型の式は直接つながるにゃ：

```lean
scriptum
  \h {superficies 3} さようなら！ \e
```

---

## def 関數と `excita` / `insere`

通常の `def` 関數を事象として登録できるにゃ。`excita` / `insere` の識別子形を任意の `def` 内で使ふと、`construe` 時に自動でラッパーが生成されて登録されるにゃん♪

引數は `Citatio.toRef` で文字列 Reference に変換され、呼び出し時に `Citatio.fromRef` で復元されるにゃ。

識別子形を使ふと、プロトコル上のイベント名は UUID v4 準據の `On_` プレフィクス附き一意識別子に自動変換されるにゃ（例: `On_a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d`）。関數名はプロトコルに露出しないにゃん♪ SSP は `On` 始まりのイベント名を直接 ID として發火するため、inputbox 等のウィジェットコールバックも正しく動作するにゃ。

```lean
-- 通常の def で処理を定義するにゃ
def onGreet (nomen : String) (kai : Nat) : SakuraIO Unit := do
  sakura; superficies 0
  loquiEtLinea s!"こんにちは、{nomen}さん！{kai}囘目にゃ"
  finis

eventum "OnGreet" fun rogatio => do
  let nomen := (rogatio.referentiam 0).getD "ゲスト"
  let kai   := (rogatio.referentiam 1).getD "0"
  onGreet nomen kai.toNat   -- 直接呼ぶ（インライン展開）にゃ
  finis

eventum "OnBoot" fun _ => do
  excita onGreet "れゃ" 42   -- \![raise,On_xxxx,...] + 自動登録にゃん♪
  finis

construe
```

`excita` は `\![raise,...]` に展開、`insere` は `\![embed,...]` に展開されるにゃ。
SSP 組み込み事象には文字列形 `excita "OnBoot"` を使ふにゃ。

識別子形は `notifica`、`excitaPostTempus`、`notificaPostTempus`、`optioEventum` にも使へるにゃ：

```lean
-- 通知（notify）
notifica onGreet "れゃ" 42

-- 遅延 raise（5秒後、1回）
excitaPostTempus 5000 1 onGreet "れゃ" 42

-- 遅延通知（1秒ごと、無限）
notificaPostTempus 1000 0 onGreet "れゃ" 42

-- 事象附き選択肢
optioEventum "詳しく" onChosen "topic1"
```

B 形式（コールバック登録）は入力結果を受け取る def のイベント名を自動登録するにゃ：

```lean
-- テキスト入力結果を受け取る def
def onTextEntered (text : String) : SakuraIO Unit := do
  sakura; superficies 0; loqui s!"入力: {text}"; finis

-- 入力ボックスを開く（def 形式）
aperiInputum .simplex onTextEntered "名前を入力" ""
aperiInputumGradus onAgeSelected "年齢" 0 100 25
aperiInputumIP onIPSelected "IP アドレス" 192 168 1 1
legeProprietatem onPropResult [.ghostName, .shellName]
```

ラムダ形ならその場で書けるにゃ：

```lean
-- ラムダ形（def を書かずにインラインで）
aperiInputum .simplex (fun text => scriptum こんにちは\、{text}さん) "名前を入力"

-- scriptum タグ記法でも使えるにゃ
scriptum
  \![open,inputbox,(fun text => scriptum ありがとう\、{text}),名前を教えて]
```

---

## 非同期処理 (Actiones Asynchronae)

`Tractator` は同期関数なので、HTTP 取得など重い IO を直接実行すると SSP 全体がブロックする。
`spawna` / `spawnaScriptum` を使うと、IO をバックグラウンドスレッドで起動し、完了後に SSTP 経由でスクリプトを届けられるにゃ。

### `spawna f args*`

`f : T1 → ... → IO Unit` をバックグラウンドで起動するにゃ。
結果の返却は `f` の中で `Sstp.mitteSstpScriptum` を呼ぶことで行うにゃ。

```lean
import Signaculum
open Signaculum Sakura

-- バックグラウンドで動く IO 関数にゃ
def downloadAndDisplay (url : String) : IO Unit := do
  let data := "取得ダータ"  -- 実際は HTTP 等にゃ
  Sstp.mitteSstpScriptum s!"\\h\\s[0]{data}\\e"

eventum "OnBoot" fun _ => do
  spawna downloadAndDisplay "https://example.com"
  loqui "取得中..."; finis

construe
```

`spawna` は SakuraIO の蓄積スクリプトを変化させにゃいにゃ。
現在のハンドラはすぐ返り、バックグラウンドタスクが完了すると別スクリプトが SSP に届くにゃ。

### `spawnaScriptum f args*`

`f : T1 → ... → SakuraIO Unit` をバックグラウンドで起動し、
`Sakura.currere` でスクリプト文字列化して SSTP 送信するにゃ。

```lean
-- 通常の SakuraIO 関数をそのまま非同期に使へるにゃ
def displayData (data : String) : SakuraIO Unit := do
  sakura; superficies 0; loqui data; finis

eventum "OnHttpDone" fun req => do
  let data := (req.referentiam 0).getD ""
  spawnaScriptum displayData data   -- 現ハンドラは即返り、表示は後から届くにゃ
  finis

construe
```

### 動作保証にゃ

- タスクは `taskusCustodia` に保持されるので、完了前に GC されにゃいにゃ
- `spawna` 内で例外が起きても `registrareVestigium` に流れるだけで、ゴーストはクラッシュしにゃいにゃ
- `spawna` / `spawnaScriptum` は `SakuraIO Unit` を返す（`liftM` による持ち上げ）にゃ

### SSTP 直接送信 (`Sstp`)

バックグラウンド外でも `Signaculum.Sstp` を使へるにゃ。
TCP (`localhost:9801`) で SSP に SSTP/1.4 リクエストを送信するにゃ。Pure Lean 實裝（C コード不要）にゃん♪

```lean
-- SakuraScript を SSP に送信にゃ
Sstp.mitteSstpScriptum "\\h\\s[0]こんにちは\\e"

-- ゴースト名を Sender に指定して送信にゃ
Sstp.mitteSstpScriptum "\\h\\s[0]こんにちは\\e" (mittens := "MyGhost")

-- SHIORI イヴェントゥムを SSP に通知にゃ
Sstp.excitaEventum "OnSomeEvent" ["arg0", "arg1"]
```

---

## SakuraScriptum 命令概要 (Mandata)

`open Signaculum Sakura` してから使ふにゃ。よく使ふ基本命令だけ載せてあるにゃ。

| 命令 | SakuraScript | 意味 |
|---|---|---|
| `sakura` / `kero` | `\h` / `\u` | 主人格 / 副人格に切り替へ |
| `superficies n` | `\s[n]` | 表情を n 番にする |
| `loqui "文字列"` | （テキスト） | 文字を表示（特殊文字自動エスケープ） |
| `linea` | `\n` | 改行 |
| `mora ms` | `\_w[ms]` | ms ミリ秒待機 |
| `optio "名前" "Event"` | `\q["名前","Event"]` | 選択肢を追加 |
| `finis` | `\e` | **スクリプト終了（必須）** |

全命令の詳細は [docs/SakuraScriptum.md](docs/SakuraScriptum.md)（do 記法）、`scriptum!` マクロ記法は [docs/Notatio.md](docs/Notatio.md) を参照にゃ。

---

## 無作為選択 (Fortuita)

```lean
fortuito #["やっほー！", "こんにちは！", "おはよう！"]
-- ランダムに 1 つ選んで loqui で表示にゃ

let s <- elige #["A", "B", "C"]   -- ランダムに 1 つ選んで返すにゃ
```

---

## チェイントーク (Catena Colloquiorum)

```lean
-- 順次再生トークを定義にゃ
catena historiaPrima := [
  do sakura; loqui "第一話"; finis,
  do sakura; loqui "第二話"; finis,
  do sakura; loqui "第三話"; finis
]

-- 通常トークとチェインの混合選択（チェイン優先）
eventum "OnAITalk" fun _ => do
  eligeVelCatena #[
    .simplex (do sakura; loqui "通常トーク"; finis),
    .catena historiaPrima
  ]
```

---

## 即時保存 (servaStatum)

`construe` が自動生成する `servaStatum : IO Unit` を使へば、任意のタイミングで `perpetua` 變數を保存できるにゃ。

```lean
eventum "OnBoot" fun _ => do
  numerusSalutationum.renovare (· + 1)
  servaStatum           -- 即時保存にゃ！
  sakura; superficies 0
  loqui s!"起動 {<- numerusSalutationum.obtinere} 囘目にゃん♪"
  finis
```

---

## SakuraScript モナドの實行

`currere` と `currereScriptum` の2つの實行關數があるにゃ。

| 關數 | 戻り値 | 用途 |
|---|---|---|
| `Sakura.currere action` | `StatusSakurae` | スクリプトゥム + 全レスポンスムヘッダーを取得にゃ |
| `Sakura.currereScriptum action` | `String` | スクリプトゥム文字列のみ取得にゃ |

通常のイヴェントゥム處理器（`eventum` / `Tractator`）では `currere` が自動的に呼ばれるにゃ。
手動で SakuraScript を生成したい時は `currereScriptum` を使ふにゃ:

```lean
def testPuraSakura : String := Id.run do
  Sakura.currereScriptum do
    sakura; superficies 0; loqui "テストにゃ！"; finis
```

---

## 永続化ファスキクルスの形式 (Forma Datorum Permanens)

`ghost_status.bin` にバイナリ形式 v3（マジックバイト `UKA\x03`）で保存されるにゃ。`perpetua` 變數のみ保存・復元されるにゃ。

| 型 | `typusTag` | エンコード |
|---|---|---|
| `Nat` | `"Nat"` | UInt64 LE 8バイトにゃ |
| `Int` | `"Int"` | Int64 LE 8バイトにゃ |
| `Bool` | `"Bool"` | 1バイト（0/1）にゃ |
| `String` | `"String"` | UTF-8 バイト列にゃ |
| `Float` | `"Float"` | IEEE 754 倍精度 8バイトにゃ |
| `UInt8/16/32/64` | `"UInt8"` 等 | 各サイズ LE にゃ |
| `Char` | `"Char"` | UInt32 として Unicode 符号点にゃ |
| `ByteArray` | `"ByteArray"` | そのままにゃ |
| `Option α` | `"Option(α)"` | 1バイトタグ + 中身にゃ |
| `List α` | `"List(α)"` | 4バイト要素数 + 各要素にゃ |
| `Array α` | `"Array(α)"` | `List α` と同じにゃ |
| `α × β` | `"Prod(α,β)"` | フィールドの連結にゃ |

### 自作構造体の永続化

```lean
structure DatorumLusoris where
  gradus : Nat
  nomen  : String

instance : StatusPermanens DatorumLusoris where
  typusTag := "DatorumLusoris"
  adBytes p :=
    codificaAgrum p.gradus ++
    codificaAgrum p.nomen
  eBytes b := do
    let (gradus, pos1) <- decodificaAgrum b 0
    let (nomen,  _)    <- decodificaAgrum b pos1
    return { gradus, nomen }
  roundtrip := by sorry   -- ユーザー側の構造體では sorry から始めて後で證明する流れにゃ

varia perpetua lusor : DatorumLusoris := { gradus := 1, nomen := "シロ" }
```

### `Citatio` クラッシスによる Reference 変換

SHIORI Reference（文字列）への往復変換を型クラスで保証するにゃ。

```lean
class Citatio (α : Type) where
  toRef     : α -> String
  fromRef   : String -> α
  roundtrip : forall (a : α), fromRef (toRef a) = a   -- 往復が定理として保証されるにゃ
```

基本型（`Nat` `Int` `Bool` `String` `Char` `UInt8/16/32/64` `Option α` `List α` `α × β`）の実体が定義済みにゃ。

---

## 日時ユーティリティ (Tempus)

`Signaculum.Utilia.Tempus` は `Std.Time` を活用した日時関数を提供する。時間帯別の挨拶分岐やログのタイムスタンプに使える。

```lean
import Signaculum

eventum "OnBoot" fun _ => do
  let dt ← liftM Signaculum.Utilia.obtineTempus
  sakura; superficies 0
  if Signaculum.Utilia.estMane dt then
    loqui "おはようにゃん♪"
  else if Signaculum.Utilia.estVespera dt then
    loqui "こんばんはにゃん♪"
  else
    loqui "こんにちはにゃん♪"
  finis
```

| 関数 | 説明 |
|---|---|
| `obtineTempus` | 現在時刻を `PlainDateTime`（UTC）で取得 |
| `obtineTimestamp` | Unix タイムスタンプを取得 |
| `estMane dt` | 朝かどうか（6 ≤ hora < 12） |
| `estMeridies dt` | 昼かどうか（12 ≤ hora < 18） |
| `estVespera dt` | 夕方かどうか（18 ≤ hora < 24） |
| `estNox dt` | 夜かどうか（0 ≤ hora < 6） |
| `tempusAdTextum dt` | "YYYY-MM-DD HH:MM:SS" 形式の文字列に変換 |

---

## ログ機能 (Registrum)

`Signaculum.Utilia.Registrum` は YAYA の LOGGING に相当するログ機能を提供する。`ghost_log.txt` にタイムスタンプ付きでメッセージを記録する。

```lean
import Signaculum

eventum "OnBoot" fun _ => do
  -- IO コンテクスト内でログ出力
  liftM (show IO Unit from Signaculum.Utilia.registraIndicium "起動しました")
  -- SakuraIO コンテクスト内でログ + SHIORI ErrorLevel/ErrorDescription に設定
  Signaculum.Utilia.registraEtNotifica .monitum "何かおかしいかも"
  sakura; superficies 0; loqui "起動にゃん♪"; finis
```

| 関数 | 説明 |
|---|---|
| `registra gradus nuntius` | 指定等級でログ出力 |
| `registraIndicium nuntius` | INFO ログ |
| `registraMonitum nuntius` | WARN ログ |
| `registraErrorem nuntius` | ERROR ログ |
| `registraM gradus nuntius` | SakuraIO 内でログ出力 |
| `registraEtNotifica gradus nuntius` | SakuraIO 内でログ + SHIORI 応答の ErrorLevel/ErrorDescription に設定 |

ログ等級 `GradusRegistri` は `.indicium`（INFO）、`.monitum`（WARN）、`.error`（ERROR）の3段階。`registraEtNotifica` を使うと SSP 側のログにもエラー情報が記録される。

---

## SHIORI Resource 応答 (resourcea)

`resourcea` マクロで SHIORI Resource 応答（`GET SHIORI/3.0` / `ID: version` 等）を宣言できる。SSP がゴーストの情報を問い合わせた時に返す値を定義する。

```lean
import Signaculum

resourcea "version"  := "1.0.0"
resourcea "craftmanw" := "作者名"
resourcea "homeurl"  := "https://example.com"

construe
```

静的な文字列値のほか、動的な `IO String` 関数も指定できる。`construe` が自動的にリソース応答ハンドラとして登録する。

---

## 日本語イベント名 (NominaIaponica)

`Signaculum.Eventum.NominaIaponica` は里々のように日本語名でイベントを宣言できるマッピングテーブルを提供する。`eventum` の引数に日本語名を渡すと、コンパイル時に SHIORI/3.0 イベント名に変換される。

```lean
import Signaculum

eventum "起動" fun _ => do
  sakura; superficies 0; loqui "起動にゃん♪"; finis

eventum "ランダムトーク" fun _ => do
  sakura; superficies 0; loqui "暇にゃん..."; finis

construe
```

70 以上のマッピングが定義済み（起動/終了、ゴースト切替、マウス、時間、トーク、選択肢、通信、入力、シェル、バルーン、ファイルドロップ、ネットワーク更新、OS 状態、消滅、キー、音声、インストール等）。テーブルにない名前はカスタムイベント名としてそのまま使われる。

---

## トーク管理 (Colloquium)

`Signaculum.Sakura.Textus.Colloquium` はランダムトーク・条件付きトーク・チェイントークを統一的に管理する DSL を提供する。旧 API（`OptioPiscinae` / `eligeVelCatena`）の改善版。

```lean
import Signaculum

varia perpetua numerusColloquii : Nat := 0

catena historiaPrima := [
  do sakura; loqui "第一話にゃ"; finis,
  do sakura; loqui "第二話にゃ"; finis,
  do sakura; loqui "完結にゃ！"; finis
]

eventum "OnAITalk" fun _ => do
  eligeColloquium #[
    -- 通常トーク（Coe により SakuraIO Unit をそのまま書ける）
    do sakura; loqui "暇にゃ..."; finis,
    do sakura; loqui "今日もいい天気にゃ"; finis,
    -- 条件付きトーク
    cum (do let n ← numerusColloquii.get; pure (n > 10))
        (do sakura; loqui "たくさん話したにゃん♪"; finis),
    -- チェイントーク（Coe により Catena をそのまま書ける）
    historiaPrima
  ]
```

`Colloquium` 型は4つのコンストラクタを持つ:

| コンストラクタ | 説明 |
|---|---|
| `.loquela actio` | 通常トーク（無条件でランダム候補） |
| `.conditio cond actio` | 条件付きトーク（条件が真の時のみ候補） |
| `.series catena` | チェイントーク |
| `.seriesCum cond catena` | 条件付きチェイントーク |

`Coe` インスタンスにより `SakuraIO Unit` と `Catena` は配列内で自動変換される。

| 関数 | 説明 |
|---|---|
| `eligeColloquium colloquia` | 配列から均等確率で選択・実行 |
| `eligeColloquiumPonderatum colloquia` | 重み付き確率で選択・実行 |

いずれもアクティブなチェインがあれば優先的に続行する。

---

## イベントラッパー (Involucra)

`Signaculum.Eventum.Involucra` は生の SHIORI イベントを加工して高レベルな抽象を提供する。里々の「なでられ」「つつかれ」や YAYA のシステム辞書に相当する。

### なでられ判定

`OnMouseMove` の連続回数が閾値を超えたら「なでられた」と判定する。scope + area をキーにして個別にカウントする。

```lean
import Signaculum

eventum "OnMouseMove" fun rogatio => do
  let scopeId := (rogatio.referentiam 3).getD ""
  let areaName := (rogatio.referentiam 4).getD ""
  let naderare ← liftM (Signaculum.Eventum.iudicaNaderare scopeId areaName)
  if naderare then
    sakura; superficies 5; loqui "にゃ〜ん♪ なでなでにゃ〜"; finis
  else pure ()
```

| 関数 | 説明 |
|---|---|
| `configuraNaderareLimen n` | なでられ判定の閾値を設定（デフォルト 10） |
| `configuraNaderareIntervallum ms` | リセットまでの最大間隔を設定（デフォルト 2000ms） |
| `iudicaNaderare scopeId areaName` | なでられ判定を行う（`IO Bool`） |

### マウスイベント名生成

```lean
let nomen := Signaculum.Eventum.nomenEventumMusis rogatio "つつかれ"
-- "0HEADつつかれ" のようなイベント名が生成される
```

### ランダムトークタイマー

`OnSecondChange` でカウントダウンし、0 に達したらランダムトーク発火を通知する。

```lean
eventum "OnSecondChange" fun rogatio => do
  let fire ← liftM (Signaculum.Eventum.pulsaTimerColloquii rogatio.status)
  if fire then
    -- ランダムトーク処理
    sakura; superficies 0; loqui "にゃん♪"; finis
  else pure ()
```

| 関数 | 説明 |
|---|---|
| `configuraIntervallumColloquii n` | ランダムトーク間隔を設定（秒、デフォルト 180） |
| `pulsaTimerColloquii status` | タイマーパルス（0 到達で `true`） |

---

## 変数デバッグ (Inspectio)

`Signaculum.Utilia.Inspectio` は変数のデバッグ支援を提供する。`construe` が `inspiceVariabiles : IO Unit` を自動生成し、全ての `varia perpetua` の名前・型・現在値を `ghost_log.txt` に出力する。

```lean
import Signaculum

varia perpetua numerus : Nat := 0
varia perpetua nomen   : String := "シロ"

eventum "OnKeyPress" fun rogatio => do
  let key := (rogatio.referentiam 0).getD ""
  if key == "F12" then
    liftM inspiceVariabiles  -- 全変数をログに出力
  sakura; superficies 0; loqui "デバッグにゃ"; finis

construe
```

出力例（ghost_log.txt）:
```
═══ Inspectio Variabilium ═══
  numerus : Nat = 42
  nomen : String = シロ
```

`inspiceEtMitte` を使うと個別の変数をログ出力しつつ SSTP でゴーストにも表示できる。

---

## 参照 (Referentia)

- [UKADOC Project](https://ssp.shillest.net/ukadoc/manual/index.html) — SHIORI/3.0・SakuraScript 仕様にゃ
- [SSP](http://ssp.shillest.net/) — 基底ウェアにゃ
