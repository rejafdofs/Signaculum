# Signaculum —  Lean 4 製 SHIORI

 SHIORI ビブリオテーカにゃん♪

- **型安全な永続化** — 保存→読込の往復を Lean 4 の定理として証明済みにゃ
- **`scriptum` 記法** — サクラスクリプトを原形タグ記法（`\h \s[0] "テキスト" \e`）で書けるにゃ
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
rev = "main"
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
  scriptum
    \h \s[0] {s!"起動 {numerus} 囘目にゃん♪"} \e

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
保存→復元の往復は `serializeMappam_roundtrip` 定理として Lean 4 で証明済みにゃ。

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

## SakuraScriptum 命令一覧 (Mandata)

`open Signaculum Sakura` してから使ふにゃ。

### 人格・表情

| 命令 | SakuraScript |
|---|---|
| `sakura` | `\h` |
| `kero` | `\u` |
| `persona n` | `\p[n]` |
| `superficies n` | `\s[n]` |
| `animatio n` | `\i[n]` |

### 文字表示

| 命令 | SakuraScript |
|---|---|
| `loqui "文字列"` | （テキスト表示・特殊文字自動エスケープ） |
| `loquiEtLinea "文字列"` | （テキスト表示 + `\n`） |
| `linea` | `\n` |
| `dimidiaLinea` | `\n[half]` |
| `purga` | `\c` |
| `finis` | `\e` |

### 待機・操作

| 命令 | SakuraScript |
|---|---|
| `mora ms` | `\w[ms]` |
| `expecta` | `\x` |
| `expectaSine` | `\x[noclear]` |
| `exitus` | `\-` |

### 選択肢

| 命令 | SakuraScript |
|---|---|
| `optio "表示名" "EventName"` | `\q[表示名,EventName]` |
| `optioEventum "表示名" "EventName" ["r0","r1"]` | `\q[表示名,EventName,r0,r1]` |
| `optioEventum "表示名" f args*` | （識別子形・§ `excita`/`insere` 参照） |
| `ancora "signum"` … `fineAncora` | `\_a[signum]` … `\_a` |

### 入力ボックス

| 命令 | SakuraScript |
|---|---|
| `aperiInputum modus f titulus textus` | `\![open,inputbox,...]` |
| `aperiInputum modus (fun text => ...) titulus` | （ラムダ形） |
| `aperiInputumDiei f titulus annus mensis dies` | `\![open,dateinput,...]` |
| `aperiInputumTemporis f titulus hora minutum secundum` | `\![open,timeinput,...]` |
| `aperiInputumGradus f titulus minimum maximum initium` | `\![open,sliderinput,...]` |
| `aperiInputumIP f titulus ip1 ip2 ip3 ip4` | `\![open,ipinput,...]` |
| `legeProprietatem f proprietates` | `\![get,property,...]` |

### 書体

| 命令 | SakuraScript |
|---|---|
| `audax true/false` | `\f[bold,true/false]` |
| `obliquus true/false` | `\f[italic,true/false]` |
| `color r g b` | `\f[color,r,g,b]` |
| `altitudoLitterarum n` | `\f[height,n]` |
| `formaPraefinita` | `\f[default]` |
| `crudus "signum"` | （生の SakuraScript を直接出力） |
| `sonus "via"` | `\![play,sound,via]` |
| `aperi "nexus"` | `\![open,browser,nexus]` |

### HTTP

| 命令 | SakuraScript |
|---|---|
| `executaHttpGet url` | `\![execute,http-get,URL]` |
| `executaHttpPost url` | `\![execute,http-post,URL]` |
| `executaHttpHead url` | `\![execute,http-head,URL]` |
| `executaHttpPut url` | `\![execute,http-put,URL]` |
| `executaHttpDelete url` | `\![execute,http-delete,URL]` |
| `executaHttpPatch url` | `\![execute,http-patch,URL]` |

### 便利命令

```lean
sakuraLoquitur 0 "こんにちは"   -- sakura; superficies 0; loqui "..."
keroLoquitur 10 "にゃ！"        -- kero; superficies 10; loqui "..."
```

---

## エラー報告 (Reportatio Errorum)

SHIORI/3.0 の `ErrorLevel` / `ErrorDescription` レスポンスムヘッダーを設定するにゃ。SSP のデヴェロッパーパレットで確認できるにゃん♪

### 便利關數

| 關數 | ErrorLevel |
|---|---|
| `reportaInformationem msg` | `info` |
| `reportaMonitum msg` | `notice` |
| `reportaAdmonitionem msg` | `warning` |
| `reportaError msg` | `error` |
| `reportaPerniciem msg` | `critical` |

任意のレヴェルを指定するには `reportaErrorem gradus msg` を使ふにゃ。

### `GradusErroris`

```lean

.informatio   -- info
.monitum      -- notice
.admonitio    -- warning
.error        -- error
.pernicies    -- critical

structure DatorumLusoris where
  gradus : Nat
  nomen  : String

instance : StatusPermanens DatorumLusoris where
  typusTag := "DatorumLusoris"
  adBytes p :=
    encodeField p.gradus ++
    encodeField p.nomen
  eBytes b := do
    let (gradus, pos1) <- decodeField b 0
    let (nomen,  _)    <- decodeField b pos1
    return { gradus, nomen }
  roundtrip := by sorry   -- ユーザー側の構造體では sorry から始めて後で證明する流れにゃ

varia perpetua lusor : DatorumLusoris := { gradus := 1, nomen := "シロ" }

```

### 使用例

```lean
eventum "OnBoot" fun _ => do
  let res <- someOperation.obtinere
  if res == "" then
    reportaAdmonitionem "operation returned empty"
  scriptum
    \h \s[0] こんにちは！ \e
```

---

## 参照 (Referentia)

- [UKADOC Project](https://ssp.shillest.net/ukadoc/manual/index.html) — SHIORI/3.0・SakuraScript 仕様にゃ
- [SSP](http://ssp.shillest.net/) — 基底ウェアにゃ
