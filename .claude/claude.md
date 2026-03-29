# 最重要事項

pythonは使わないで下さい

## 型安全性・証明

・sorry禁止
・ 新機能の実装等でプランを書く課程で必ずそれが満たすべき条件を考え（例：エンコードしてデコードしたら元に戻る等）、それの実装と証明をプランに組込む
・公理を追加したい場合はユーザーに対話型インターフェースで許可を取る
・！ 関数や? 関数などは実行時のオーバーヘッドが大きいので基本的に使用禁止（外から来た入力の処理など入力の正当性証明が不可能な場合のみ？関数は使用可能）。普通の関数を使つて入力の正当性を示す方が実行時早いのでそうしてください
・例外: Notatio/Expande 配下のマクロ展開コード（TermElabM 等）はコンパイル時のみ実行されるため、`args[i]!` 等の使用を許容する。ただし `if h : args.size = n` + `args[i]'(by omega)` への段階的移行が望ましい

### `?` 関数の代替パターン

`?` 関数を使わずに安全にアクセスする具体例:

```lean
-- ❌ 禁止: パニックや Option の不要なオーバーヘッド
let x := arr[i]!
let y := arr.get? i

-- ✅ 推奨: 証明付き安全アクセス
if h : i < arr.size then
  let x := arr[i]'h
  ...

-- ✅ 推奨: サイズが定数の場合
if h : arr.size = 3 then
  let a := arr[0]'(by omega)
  let b := arr[1]'(by omega)
  let c := arr[2]'(by omega)
  ...
```

## 命名・コメント規約

・識別子（ファイル名や変数名や定理名等は）必ずラテン語で命名する
・コメントは猫耳ボクっ娘ロリでカタカナ語を全てラテン語のカタカナ語で書き（例：プロジェクト→プロイェクトム）、舊字舊かなを使うシロちゃんの口調で書く

## 参照ドキュメント

- ukadoc sakurascript 一覧: https://ssp.shillest.net/ukadoc/manual/list_sakura_script.html
- ukadoc トップ: https://ssp.shillest.net/ukadoc/manual/index.html

## sakurascriptum マクロの三原則

sakurascriptum マクロ (`scriptum!`) は以下の三要件を常に満たすこと:

1. **sakurascript 互換性**: ukadoc 定義の有効な sakurascript タグをマクロ構文として置くと、そのまま（または同機能な物が）出力される
2. **全機能実現可能性**: 拡張構文（タグ構文 + `{expr}` 埋め込み）で栞の全機能を実現可能であること（SSP がエラーを吐くような危険なレスポンスの生成やエラー等ユーザーに直接触らせたくない場所を除く）
3. **安全性**: どのような入力があっても SSP がエラーを吐くような文字列を出力しないこと（不正な入力はコンパイル時にエラーにする）

新しい sakurascript タグのサポートを追加する際は:
- `Sakura/*.lean` にランタイム関数を追加し、`evadeArgumentum`/`evadeTextus` で引数を適切にエスケープする
- `Notatio/*.lean` にマクロ構文ルールを追加する
- `Notatio/Verificatio.lean` に `native_decide` による出力検証証明を追加する
- 数値パラメータに上限/下限がある場合は依存型（`by omega`）で静的に検証する

## 証明方針

以下には証明方針として有力な物がいくつかのっています。此のような方法を使って下さい

- aesopを使ってみる
- 関数の定義を使って書替へてみる
- loogleを使って今の目標に似た命題がないか探してみる

## 証明できない場合

理論上証明可能だけど証明できなそうな補題はlemma.leanにsorryで(後で証明するが今ではない)、floot型のバイナリ化安全性の樣に理論上証明できなそうな補題はAxioum.leanにおいてください

## モジュール構造

・namespace はディレクトリ階層と一致させる。Signaculum/Memoria/Foo.lean なら namespace は Signaculum.Memoria。フラットな namespace にしない
・サブディレクトリを作ったら必ずそのディレクトリと同名の集約ファイルを作る（例：Memoria/ → Memoria.lean）。集約ファイルはサブモジュールを import するだけでよい
・ファイル先頭のコメントに書くパスと実際の namespace を一致させる

## ビルド・開発設定

・これをビルドするときは　lake build Signaculumでビルドして
・lakefile.lean に require を追加するとき、実際にコード中で import しているか確認する。使っていない依存は追加しない
・テストファイルは Main.lean から import しない。テスト用ターゲットを別途 lakefile に定義する
・lean-toolchain は RC 版を使わない。stable リリースに固定する

### デバッグコマンド禁止

・`#eval`・`#eval!`・`#check`・`#print` をコミットに含めない。作業中の一時的な確認用途のみ許可し、コミット前に必ず消す

## Rust (procurator) 規約

・procurator/ 配下の Rust コードは Edition 2021 を使用する
・ターゲットは `i686-pc-windows-msvc`（32-bit Windows）に固定。他のターゲット向けのコードを混入しない
・SHIORI DLL のエクスポート関数（`load`/`unload`/`request`）は C ABI (`extern "C"`) を維持する
・ANSI ↔ UTF-8 変換は Win32 API (`MultiByteToWideChar`/`WideCharToMultiByte`) を使用する
・コメントは Lean 側と同様に日本語（猫耳口調・舊字舊かな）で書く

## ドキュメント

・README.md のコード例もプロジェクトのルール（！関数禁止等）に従う
・CHANGELOG.md のエントリには必ず日付を付ける（形式：YYYY-MM-DD）
・docs/ 内のドキュメントはコード変更に合わせて同時に更新する

## プロセス

・プラン作成後の実装中にプランから逸脱した変更（設計変更、追加、省略、回避策等）を独断で行った場合は、コミット前に必ずユーザーにその内容と理由を報告し確認を取ること
