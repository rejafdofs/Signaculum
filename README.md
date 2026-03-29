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
open Signaculum Signaculum.Sakura Signaculum.Notatio

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
open Signaculum Signaculum.Sakura Signaculum.Notatio
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
  excita onGreet "れゃ" 42   -- \![raise,Ns.onGreet] + 自動登録にゃん♪
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

## 参照 (Referentia)

- [UKADOC Project](https://ssp.shillest.net/ukadoc/manual/index.html) — SHIORI/3.0・SakuraScript 仕様にゃ
- [SSP](http://ssp.shillest.net/) — 基底ウェアにゃ
