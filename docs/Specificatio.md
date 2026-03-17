# PuraShiori 仕様書

PuraShiori は Lean 4 で書かれた SHIORI/3.0 栞ライブラリ。
Ukagaka ゴーストが require するだけで使える。

---

## 全體構成

```
SSP (Ukagaka ベースウェア)
  │  DLL load/unload/request 呼出し
  ▼
ffi/shiori.c  (ゴースト側の C グルー)
  │  @[export] された Lean 關數を直接呼ぶ
  ▼
PuraShiori.Exporta  ← exportaLoad / exportaUnload / exportaRequest
  │
  ├── PuraShiori.Nuculum   ← Shiori 構造體・tracta
  │     ├── PuraShiori.Rogatio     ← SHIORI/3.0 要求の解析
  │     ├── PuraShiori.Responsum   ← SHIORI/3.0 應答の生成
  │     └── PuraShiori.Protocollum ← 共通型・定數
  │
  ├── PuraShiori.Sakura.*  ← SakuraScript モナドと DSL
  │
  ├── PuraShiori.Memoria.* ← 永続化・メモリー管理
  │
  ├── PuraShiori.Sstp      ← Direct SSTP 送信（WM_COPYDATA）
  │     └── PuraShiori/c/sstpDirectum.c  ← Win32 FFI
  │
  ├── PuraShiori.Syntaxis  ← コンパイル時 DSL 構文擴張
  └── PuraShiori.Loop      ← タイマー・ループ管理
```

---

## モジュール別仕様

### PuraShiori.Protocollum

SHIORI/3.0 プロトコルの共通型と定數。

| 型 | 説明 |
|---|---|
| `Methodus` | 要求の手法。`.pete` (GET) か `.notifica` (NOTIFY) |
| `StatusCodis` | 應答の狀態符號。200 / 204 / 400 / 500 |
| `crlf` | `"\r\n"` |
| `shioriVersio` | `"SHIORI/3.0"` |

---

### PuraShiori.Rogatio

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

---

### PuraShiori.Responsum

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
| `malaRogatio` | 400 | 要求が不正 |
| `errorInternus` | 500 | 内部例外 |

---

### PuraShiori.Nuculum

栞の核心。`Shiori` 構造體とルーティング。

```lean
structure Shiori where
  tractatores : List (String × Tractator)
  status      : IO.Ref ShioriStatus
  onOnerare   : Option (String → IO Unit)  -- load フック
  onExire     : Option (IO Unit)           -- unload フック

def Tractator := Rogatio → SakuraIO Unit
```

`tracta` が要求を受け取り `tractatores.lookup` でイベント名に對應する處理器を探して呼ぶ。
見つからなければ 204、例外が出れば 500。

---

### PuraShiori.Exporta

C グルーから呼ばれる `@[export]` 關數群。

| 關數 | 對應する C 側 | 説明 |
|---|---|---|
| `exportaLoad (domus)` | `load(hdir)` | 家ディレクトリを設定・onOnerare を呼ぶ |
| `exportaUnload` | `unload()` | onExire を呼ぶ |
| `exportaRequest (req)` | `request(req)` | 要求文字列を受け取り應答文字列を返す |

`spawnaMunitus` で非同期タスクを GC から保護しながら起動する機構もここにある。
タスクは最大 256 件保持し、超えたら後半 128 件だけ残して古い前半を捨てる。

---

### PuraShiori.Sakura.*

SakuraScript を Lean で組み立てるためのモナドと DSL。

`SakuraIO α = StateT String IO α` — 文字列を積み上げていくモナド。

| 關數 | 説明 |
|---|---|
| `Sakura.currere` | SakuraIO を実行して文字列を得る |
| `Sakura.excita` | 別イベントを發生させる |
| `Sakura.insere` | スクリプトに別イベントを埋め込む |
| `Sakura.notifica` | NOTIFY 通知を發生させる |
| `Sakura.excitaPostTempus` | 遅延発火 |

---

### PuraShiori.Sstp

Direct SSTP で SSP にスクリプトを送信する。

`sstpDirectumMittere` は C FFI 越しに `WM_COPYDATA` メッセージを SSP に送る。
`mitteSstpScriptum` はその上に `SSTP/1.4 Execute` リクエストを組み立てる。
`excitaEventum` は `SSTP/1.4 Notify` を送る。

```
SSTP/1.4\r\n
Command: Execute\r\n
Charset: UTF-8\r\n
Sender: uka-lean\r\n
Script: \h\s[0]やあ。\e\r\n
\r\n
```

---

### PuraShiori/c/sstpDirectum.c — FFI 実装

Win32 API `FindWindowExA` + `SendMessageA(WM_COPYDATA)` で Direct SSTP を実現する。

#### COPYDATASTRUCT レイアウト（64-bit Windows）

| フィールド | 型 | サイズ | オフセット | 内容 |
|---|---|---|---|---|
| `dwData` | `ULONG_PTR` | 8 バイト | 0 | 識別子 = `9801` |
| `cbData` | `DWORD` | 4 バイト | 8 | データバイト數（ヌル終端を含まない） |
| (padding) | — | 4 バイト | 12 | 自然アライメント |
| `lpData` | `PVOID` | 8 バイト | 16 | SSTP リクエスト文字列へのポインタ |

合計 24 バイト。

#### 注意点

`lean_string_byte_size` はヌル終端文字を含むので使わず、自前の `str_len` でバイト数を数える。

`request` は `@& String`（借用参照）なので C 側は `b_lean_obj_arg`。
`lean_obj_arg`（所有）を使うと呼出し後に参照カウントが誤って減算されてメモリ破壊を引き起こす。

`_WIN32` 未定義環境（非 Windows ビルド）ではスタブが代わりに入り、何もせず `IO.ok ()` を返す。

`SendMessageA` は同期呼出しなので、`request` の内部バッファは呼出し中ずっと有効。

#### ビルド

`lakefile.lean` の `extern_lib sstpDirectum` が `lean.cc`（Lean 附属 clang）でコンパイルする。
フラグは Lean 自身のモジュールコンパイルと同一:

```
-I {leanIncludeDir}
--sysroot={lean.sysroot}
-nostdinc
-isystem {lean.sysroot}/include/clang
-DNDEBUG
```

`include/clang` に `stddef.h`・`stdbool.h`・`stdint.h` 等が含まれる。
`-luser32` はすでに Lean の実行ファイルリンクコマンドに含まれているので個別指定不要。

---

### PuraShiori.Memoria.*

| モジュール | 説明 |
|---|---|
| `StatusPermanens` | `ghost_status.bin` への永続化（型クラスベース） |
| `Lemma` | 永続化の補題・証明 |
| `Auxilia` | 補助關數 |
| `Citationes` | `Citatio` 型クラス（Reference との変換） |
| `Citatio` | `toRef`/`fromRef` の基本インスタンス |

---

### PuraShiori.Syntaxis — コンパイル時 DSL

ゴースト作者が使う構文マクロ群。コンパイル時に環境拡張 `GhostAccumulatio` へ宣言を蓄積し、`construe` が最終的に `registraShiori(Ex)` の呼出しコードを生成する。

| 構文 | 説明 |
|---|---|
| `varia perpetua n : T := v` | 永続化される變數を宣言 |
| `varia temporaria n : T := v` | 一時變數を宣言 |
| `eventum "名前" 処理器` | イベントハンドラを登録 |
| `excita f args*` | def ベースのイベントを發生させる |
| `insere f args*` | def ベースのイベントをスクリプトに埋め込む |
| `notifica f args*` | def ベースの NOTIFY を發生させる |
| `spawna f args*` | IO Unit を非同期実行 |
| `spawnaScriptum f args*` | SakuraIO Unit を非同期実行して SSTP で送信 |
| `construe` | 全宣言を組み合わせて栞を構築・登録 |

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
            → Sakura.currere  (SakuraScript 文字列を得る)
        → Responsum.adProtocollum  (serialize)
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
      sstpDirectumMittere (FFI) →
        SendMessageA(WM_COPYDATA) → [SSP]
```

---

## 不変条件・制約

- `exportaRequest` は必ず應答文字列を返す（例外は catch して文字列に変換）
- `Rogatio.interpreta` が失敗した場合は 400 を返す
- `tractatores.lookup` が失敗した場合は 204 を返す（ハンドラ未登録は正常）
- `str_len` の返り値は `DWORD`（32-bit）。SSTP リクエストが 4GB を超えることはない
- `SendMessageA` は同期呼出し。SSP が応答するまでブロックする
- `taskusCustodia` の上限は 256 件。超えたら前半を捨てて後半 128 件を残す（GC リーク防止）
