# Procurator — Rust FFI ラッパー

`procurator/procurator32/` は SSP（Ukagaka ベースウェア）から読み込まれる 32-bit Windows DLL (`shiori.dll`) の Rust 実装。
ghost.exe（Lean 4 ビルド物）を子プロセスとして起動し、パイプ経由で SHIORI/3.0 の load/unload/request を中継する。

---

## アーキテクチャ

```
SSP (ベースウェア)
  │  C ABI: load() / unload() / request()
  ▼
shiori.dll (procurator32, Rust cdylib)
  │  stdin/stdout パイプ
  ▼
ghost.exe (Lean 4 ビルド物)
  Signaculum.Nucleus.Circulus — コマンドバイトでディスパッチ
```

SSP は `shiori.dll` を SHIORI/3.0 仕様に基づいて `HGLOBAL` 経由で呼び出す。
procurator はそのペイロードをパイプに転送し、ghost.exe の応答を `HGLOBAL` に詰めて返す。

---

## エクスポート関数（C ABI）

| 関数 | シグネチャ | 説明 |
|---|---|---|
| `load` | `(h: HGLOBAL, len: i32) -> BOOL` | ghost.exe を起動し LOAD コマンドを送信 |
| `unload` | `() -> BOOL` | UNLOAD コマンドを送信しパイプを閉じる |
| `request` | `(h: HGLOBAL, len: *mut i32) -> HGLOBAL` | SHIORI 要求を転送し応答を返す |

---

## パイプ IPC プロトコル

ghost.exe の stdin/stdout を使った長さプレフィクス付きバイナリプロトコル。
全ての整数はリトルエンディアン (LE) で送受信される。

### LOAD（コマンドバイト: `1`）

```
procurator → ghost.exe:
  [1: u8] [len: u32 LE] [path: UTF-8 bytes]

ghost.exe → procurator:
  [result: u8]   -- 1=成功, 0=失敗
```

`path` は SSP から渡されたゴーストディレクトリパス。
SSP は ANSI (CP_ACP / Shift_JIS) で渡すため、procurator が UTF-8 に変換してから送信する。

### UNLOAD（コマンドバイト: `2`）

```
procurator → ghost.exe:
  [2: u8]

ghost.exe:
  変数を保存して自発的に終了
```

procurator は応答を待たずにパイプを閉じる（SSP のタイムアウトによるクラッシュを防止）。

### REQUEST（コマンドバイト: `3`）

```
procurator → ghost.exe:
  [3: u8] [len: u32 LE] [request: UTF-8 bytes]

ghost.exe → procurator:
  [len: u32 LE] [response: UTF-8 bytes]
```

要求が ANSI の場合、procurator が UTF-8 に変換して送信。
応答も UTF-8 で受け取り、元が ANSI なら ANSI に戻して SSP に返す。

### SAORI LOAD（コマンドバイト: `0x04`）

```
ghost.exe → procurator:
  [0x04: u8] [pathLen: u32 LE] [dllPath: UTF-8 bytes] [hdirLen: u32 LE] [hdir: UTF-8 bytes]

procurator → ghost.exe:
  [result: u8]   -- 1=成功, 0=失敗
```

ghost.exe が SAORI DLL のロードを要求する。`dllPath` は SAORI DLL のパス（ghost ディレクトーリウムからの相對パスまたは絶對パス）、`hdir` は ghost のホームディレクトーリウム。
procurator は `LoadLibraryW` で DLL をロードし、`load()` エクスポート關數を呼ぶ。SAORI DLL は Shift_JIS を期待するものが多いため、`hdir` は UTF-8 → ANSI に變換してから渡す。
ロード濟みの DLL を再度ロードしようとした場合は成功扱ひで即座に `1` を返す。

### SAORI REQUEST（コマンドバイト: `0x05`）

```
ghost.exe → procurator:
  [0x05: u8] [pathLen: u32 LE] [dllPath: UTF-8 bytes] [reqLen: u32 LE] [request: UTF-8 bytes]

procurator → ghost.exe:
  [respLen: u32 LE] [response: UTF-8 bytes]
```

ghost.exe が SAORI DLL にリクエストを送信する。`request` は SAORI/1.0 リクエスト文字列（UTF-8）。
procurator は UTF-8 → ANSI に變換してから DLL の `request()` エクスポート關數に `HGLOBAL` 經由で渡す。
應答は ANSI → UTF-8 に變換して ghost.exe に返す。DLL が未ロードの場合は空應答（`respLen = 0`）を返す。

### SAORI UNLOAD（コマンドバイト: `0x06`）

```
ghost.exe → procurator:
  [0x06: u8] [pathLen: u32 LE] [dllPath: UTF-8 bytes]

procurator:
  応答なし
```

ghost.exe が SAORI DLL のアンロードを要求する。procurator は DLL の `unload()` エクスポート關數を呼び、`FreeLibrary` でモジュールを解放する。
應答は送信しにゃい（fire-and-forget）。DLL が未ロードの場合は靜かに無視する。

### SAORI コマンドループ

通常の SHIORI REQUEST 處理の中で、ghost.exe が SAORI 呼出しを行ふと以下のフローになる:

```
procurator → ghost.exe:  [3: u8] [reqLen: u32 LE] [request]   ← 通常の REQUEST

ghost.exe → procurator:  [0x04] [...]   ← SAORI LOAD（任意回數）
procurator → ghost.exe:  [result: u8]

ghost.exe → procurator:  [0x05] [...]   ← SAORI REQUEST（任意回數）
procurator → ghost.exe:  [respLen: u32 LE] [response]

ghost.exe → procurator:  [0x06] [...]   ← SAORI UNLOAD（任意回數）

ghost.exe → procurator:  [0x00] [len: u32 LE] [response]   ← 最終 SHIORI 應答
```

procurator の `tractare_saori_circulum` が `0x00`（最終應答）を受け取るまでループし、SAORI コマンド（0x04/0x05/0x06）をディスパッチする。
`unload()` 時には `saori_exonerare_omnes` で全ての SAORI DLL を自動アンロードする。

---

## エンコーディング変換

SSP は `Charset: UTF-8` ヘッダの有無でエンコーディングを示す。

| 関数 | 変換方向 | 用途 |
|---|---|---|
| `ansi_bytes_to_string` | ANSI → Rust String | LOAD パスの変換 |
| `ansi_to_utf8_bytes` | ANSI → UTF-8 bytes | 要求の変換 |
| `utf8_to_ansi_bytes` | UTF-8 → ANSI bytes | 応答の変換 |

変換は Win32 API (`MultiByteToWideChar` / `WideCharToMultiByte`) を使用。
`CP_ACP`（システム既定のコードページ、日本語環境では Shift_JIS）と `CP_UTF8` 間で変換する。

---

## ビルド手順

### 前提条件

- Rust ツールチェイン（`rustup`）
- 32-bit Windows ターゲット: `rustup target add i686-pc-windows-msvc`

### ビルド

```bash
cd procurator
cargo build --release --target i686-pc-windows-msvc -p procurator32
```

成果物: `target/i686-pc-windows-msvc/release/shiori.dll`

### 配置

```
ghost/master/
├── shiori.dll        ← procurator ビルド物
├── ghost.exe         ← Lean ビルド物 (lake build ghost)
└── ghost_status.bin  ← 永続化データ（自動生成）
```

---

## 依存クレート

| クレート | 用途 |
|---|---|
| `windows-sys` 0.59 | Win32 API バインディング（`GlobalAlloc`, `MultiByteToWideChar` 等） |

---

## テスト

`procurator/probatio/` に結合テスト用バイナリがある。
ghost.exe のパイプ通信をシミュレートして LOAD → REQUEST → UNLOAD のサイクルを検証する。
