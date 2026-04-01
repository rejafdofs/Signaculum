# scriptum! マクロ記法 — Notatio ガイド

`Signaculum.Notatio` モジュールは `scriptum!` マクロを提供します。SakuraScript を原形タグ記法（`\h \s[0] "テキスト" \e`）で書けるようにする DSL です。

do 記法による SakuraScript の組み立ては [SakuraScriptum.md](SakuraScriptum.md) を参照してください。

---

## 基本的な使い方

```lean
import Signaculum

def myTalk : SakuraPura Unit := scriptum!
  \h \s[0] "こんにちは" \n
  \u \s[10] "やっほー"
  \e
```

---

## do 記法との比較

```lean
-- do 記法
def talkDo : SakuraPura Unit := do
  sakura; superficies 0; loqui "こんにちは"; linea
  kero; superficies 10; loqui "やっほー"
  finis

-- scriptum! 記法（同じ出力）
def talkScriptum : SakuraPura Unit := scriptum!
  \h \s[0] "こんにちは" \n
  \u \s[10] "やっほー"
  \e
```

---

## 対応タグ一覧

| 記法 | 対応する do 記法 | 説明 |
|---|---|---|
| `\h` | `sakura` | 主人格 |
| `\u` | `kero` | 副人格 |
| `\p[n]` | `persona n` | 第n人格 |
| `\s[n]` / `\s[-1]` | `superficies n` / `superficiesAbsconde` | 表面 |
| `\i[n]` / `\i[n, wait]` | `animatio n` / `animatioExpecta n` | アニメーション |
| `\n` / `\n[half]` / `\n[percent,n]` | `linea` / `dimidiaLinea` / `lineaProportionalis n` | 改行 |
| `\w n` | `moraCeler n` | 簡易待機 |
| `\_w[n]` / `\__w[n]` | `mora n` / `moraAbsoluta n` | 待機 |
| `\x` / `\x[noclear]` | `expecta` / `expectaSine` | クリック待ち |
| `\e` | `finis` | 終了 |
| `\_q` | `celer` | 即時表示 |
| `\-` | `exitus` | 退出 |
| `\+` | `adscribe` | 追記 |
| `\*` | `prohibeTempus` | タイムアウト防止 |
| `\_+` | `inhibeTagas` | タグ実行禁止 |
| `\v` | `expectaSonum` | 音声再生待ち |
| `\b[n]` / `\b[-1]` | `bulla n` / `bullaAbsconde` | 吹出し |
| `\f[bold, b]` | `audax b` | 太字 |
| `\f[color, c]` | `color c` | 色 |
| `\f[height, n]` | `altitudoLitterarum mag` | 文字サイズ（MagnitudoLitterarum 型） |
| `\f[default]` | `formaPraefinita` | 書式リセット |
| `\_v["file"]` | `sonus "file"` | 音声 |
| `\8["file"]` | `sonus8 "file"` | 簡易音声 |
| `\![sound,play,"file"]` | `sonusPulsus "file"` | 音再生 |
| `\![move, sx, sy, kx, ky]` | `movere sx sy kx ky` | 移動 |
| `\![moveasync, sx, sy, kx, ky]` | `movereAsync sx sy kx ky` | 非同期移動 |
| `\![enter,passivemode]` | `ingredereModumPassivum` | パッシブモード |
| `\![leave,passivemode]` | `egrediereModumPassivum` | パッシブモード解除 |
| `\![set,autoscroll, b]` | `configuraAutoScroll b` | 自動スクロール |
| `\![set,windowstate, s]` | `configuraStatusFenestrae s` | ウィンドウ状態 |
| `\![raise, f, args*]` | `excita f args*` | イベント発生（f: 文字列/識別子/ラムダ） |
| `\![embed, f, args*]` | `insere f args*` | イベント埋込 |
| `\![notify, f, args*]` | `notifica f args*` | 通知 |
| `\![timerraise, t, r, f, args*]` | `excitaPostTempus t r f args*` | 遅延発火 |
| `\![timernotify, t, r, f, args*]` | `notificaPostTempus t r f args*` | 遅延通知 |
| `\![open,inputbox, f, title]` | `aperiInputum .simplex f title ""` | テキスト入力（f: 文字列/識別子/ラムダ） |
| `\![open,inputbox, f, title, text]` | `aperiInputum .simplex f title text` | テキスト入力（初期テキスト付き） |
| `\![open,passwordinput, f, title]` | `aperiInputum .sigillum f title ""` | パスワード入力 |
| `\![open,dateinput, f, title, y, m, d]` | `aperiInputumDiei f title y m d` | 日付入力 |
| `\![open,timeinput, f, title, h, m, s]` | `aperiInputumTemporis f title h m s` | 時刻入力 |
| `\![open,sliderinput, f, title, min, max, init]` | `aperiInputumGradus f title min max init` | スライダー入力 |
| `\![open,ipinput, f, title, a, b, c, d]` | `aperiInputumIP f title a b c d` | IP入力 |
| `\![open,colorinput, f, title, r, g, b]` | `aperiInputumColoris f title r g b` | 色入力 |
| `\![async, ident args*]` | `spawnaScriptum ident args*` | 非同期 SSTP 送信 |
| `\![anim,start, s, i]` | `animaIncepit s i` | アニメーション開始 |
| `\![change,ghost, "name"]` | `mutaGhostNomen "name"` | ゴースト変更 |
| `\q["text","id"]` | `optio "text" "id"` | 選択肢 |
| `\q["title", script: "content"]` | `optioScriptum "title" "content"` | スクリプト実行型選択肢 |
| `\__q["id"]` / `\__q` | `optioScopus "id"` / `fineOptioScopus` | 範囲選択肢 |
| `\_a["id"]` ... `\_a` | `ancora "id"` ... `fineAncora` | 錨 |
| `\0` / `\1` | `sakura` / `kero` | 旧形式スコープ |
| `\c[char, n]` / `\c[char, n, i]` | `purgaCharacterem n` / `purgaCharacteremAb n i` | 文字単位クリア |
| `\c[line, n]` / `\c[line, n, i]` | `purgaLineam n` / `purgaLineamAb n i` | 行単位クリア |
| `\_s[n]` / `\_s[n, m]` | `synchronaScopi [n]` / `synchronaScopi [n, m]` | スコープ指定同期 |
| `\_b["file", x, y]` | `imagoBullae "file" x y` | バルーン画像（透過） |
| `\_b["file", x, y, opaque]` | `imagoBullaeOpaca "file" x y` | バルーン画像（不透明） |
| `\_b["file", inline]` | `imagoBullaeInlineata "file"` | インライン画像 |
| `\_b["file", inline, opaque]` | `imagoBullaeInlineataOpaca "file"` | インライン画像（不透明） |
| `\![raiseother, "ghost", "event"]` | `excitaAlium "ghost" "event"` | 他ゴーストイベント |
| `\![notifyother, "ghost", "event"]` | `notificaAlium "ghost" "event"` | 他ゴースト通知 |
| `\![raiseplugin, "plugin", "event"]` | `vocaPlugin "plugin" "event"` | プラグインイベント |
| `\![notifyplugin, "plugin", "event"]` | `notificaPlugin "plugin" "event"` | プラグイン通知 |
| `\![sound,load, "file"]` | `sonusOneratur "file"` | 音声事前読込 |
| `\![sound,cdplay, n]` | `sonusCD n` | CD再生 |
| `\![filter, "plugin", t, "param"]` | `applicaFiltratum "plugin" t "param"` | フィルター適用 |
| `\![filter]` | `applicaFiltratum "" 0 ""` | フィルター解除 |
| `\![anim,offset, s, i, x, y]` | `animaTranslatio s i x y` | アニメーション位置ずらし |
| `\![anim,add,overlay, id]` | `animaAddOverlay id` | オーバーレイ追加 |
| `\![anim,add,base, id]` | `animaAddBase id` | ベース変更 |
| `\![anim,add,move, x, y]` | `animaAddMove x y` | 表面移動 |
| `\![execute,http-get, "url"]` | `executaHttpGet "url"` | HTTP GET |
| `\![execute,http-options, "url"]` | `executaHttpOptions "url"` | HTTP OPTIONS |
| `\![execute,rss-post, "url"]` | `executaRssPost "url"` | RSS POST |
| `\![execute,headline, "name"]` | `executaHeadline "name"` | ヘッドライン |
| `\![execute,install,path, "file"]` | `executaInstallationemVia "file"` | ファイルからインストール |
| `\![execute,createnar]` | `executaCreationemNar` | NAR作成 |
| `\![execute,emptyrecyclebin]` | `evacuaRecyclatorium` | ゴミ箱を空にする |
| `\![execute,createupdatedata]` | `executaCreationemUpdateData` | 更新データ作成 |
| `\![execute,resetballoonpos]` | `renovaPositionemBullae` | バルーン位置リセット |
| `\![execute,resetwindowpos]` | `renovaPositionemWindowae` | ウィンドウ位置リセット |
| `\![moveasync,cancel]` | `cancellaMotumAsync` | 非同期移動キャンセル |
| `\![lock,repaint,manual]` | `seraRepicturaManualiter` | 手動再描画ロック |
| `\![lock,balloonrepaint,manual]` | `seraRepicturaBullaeManualiter` | 手動バルーン再描画ロック |
| `\![open,ghostexplorer]` | `aperi .exploratorFantasmatis` | ゴーストエクスプローラ |
| `\![open,browser, "url"]` | `aperi (.navigator "url")` | ブラウザで開く |
| `\![open,editor, "file"]` | `aperiEditorem "file"` | エディタで開く |
| `\![open,dateinput, ...]` | `aperiInputumDiei ...` | 日付入力 |
| `\![open,timeinput, ...]` | `aperiInputumTemporis ...` | 時刻入力 |
| `\![open,sliderinput, ...]` | `aperiInputumGradus ...` | スライダー入力 |
| `\![open,ipinput, ...]` | `aperiInputumIP ...` | IPアドレス入力 |
| `\![open,dialog, modus]` | `aperiDialogum modus` | ダイアログ |
| `\![close,dialog, "id"]` | `claudeDialogum "id"` | ダイアログを閉じる |
| `\![set,balloonoffset, s, x, y]` | `configuraBullaeOffset s x y` | バルーンオフセット |
| `\![set,balloonwait, p]` | `moraTextus p` | テキスト速度 |
| `\![set,balloonmarker, "s"]` | `signatumBullae "s"` | バルーンマーカー |
| `\![set,blink, b]` | `nictatus b` | まばたき設定 |
| `\![set,alwaysontop, b]` | `semperSupra b` | 最前面設定 |
| `\![set,scaling, p]` | `configuratioScalae p` | 拡大率（Int 型、負値で軸反転） |
| `\![set,alpha, v]` | `configuratioAlphae v` | 透明度 |
| `\![set,position, x, y, s]` | `configuraPositionem x y s` | 位置固定 |
| `\![set,shioridebugmode]` | `configuraShioriDebug` | SHIORIデバッグ |
| `\![set,choicetimeout, ms]` | `tempusOptionum ms` | 選択肢タイムアウト |
| `\![enter,selectmode, rect, c]` | `ingredereModumSelectionis .rectus c` | 選択モード |
| `\![leave,selectmode]` | `egrediereModumSelectionis` | 選択モード解除 |
| `\![call,ghost, "name"]` | `vocaGhost "name"` | ゴースト呼出し |
| `\![update,platform]` | `renovaPlatformam` | プラットフォーム更新 |
| `\![wait,syncobject, "name", t]` | `expectaSyncObjectum "name" t` | 同期オブジェクト待機 |
| `\m["umsg", "wparam", "lparam"]` | `nuntiumWindowae ...` | Windowsメッセージ |
| `\__v["options"]` | `synthesisVocis "options"` | 音声合成調整 |
| `\f[anchor.font.color, c]` | `colorFontisAncorae c` | 錨テキスト色 |
| `%month` / `%username` 等 | `variabilisAmbientis "month"` | 環境変数参照 |
| `"テキスト"` | `loqui "テキスト"` | 文字列表示 |
| `{expr}` | （任意の Lean 式） | 式埋込（`Exhibibilis` 型クラス経由） |

---

## 式埋込と型強制（Exhibibilis 型クラス）

`{expr}` には任意の Lean 式を書けます。`Exhibibilis` 型クラスのインスタンスを持つ型は自動的に `SakuraM` に変換されます。

| 型 | 変換内容 | 優先度 |
|---|---|---|
| `String` | `loqui s` として表示 | 100 |
| `Array α` / `List α` | ランダムに1要素選んで `exhibe` で表示（`SakuraIO` 文脈のみ） | 95 |
| `Option α` | `some a` → `exhibe a`、`none` → 無出力（非正格評價） | 92 |
| `m String` | モナドを実行して `loqui` で表示 | 90 |
| `IO.Ref α` | 値を読み取って `toString` + `loqui`（`SakuraIO` 文脈のみ） | 85 |
| `m α` (`ToString α`) | モナドを実行して `toString` + `loqui` | 80 |
| `α` (`ToString α`) | `toString` + `loqui`（最汎用） | 70 |

`Array α` / `List α` の要素型 `α` 自体も `Exhibibilis` であればよいため、`Array String`、`Array (IO String)`、`List Nat` なども対応します。

```lean
varia perpetua nomenMeum : String := ""

-- IO.Ref String は {ref} でそのまま展開できる
eventum "OnBoot" fun _ => scriptum
  \h \s[0] こんにちは、{nomenMeum}！

-- IO.Ref Nat など ToString α をもつ型は toString <$> ref.get と書く
varia perpetua numerus : Nat := 0
eventum "OnBoot" fun _ => scriptum
  \h 起動 {toString <$> numerus.obtinere} 回目にゃん

-- Array / List はランダムに1要素が表示される（SakuraIO 文脈）
eventum "OnBoot" fun _ => scriptum
  \h \s[0] {#["おはよう！", "こんにちは！", "やっほー！"]}
  \e
```

---

## モジュール構成

| ファイル | 内容 |
|---|---|
| `Signaculum/Notatio.lean` | アグレガートル |
| `Signaculum/Notatio/Lexema.lean` | `LexemaSakurae` 帰納型 IR |
| `Signaculum/Notatio/Parsitor.lean` | カスタムパーサー（`sakuraLexemaParser`） |
| `Signaculum/Notatio/Parsitor/Argumenta.lean` | 括弧内引数パーサー（エラーメッセージ生成） |
| `Signaculum/Notatio/Expande/Textus.lean` | テキスト・範囲・待機・選択肢・制御タグ展開 |
| `Signaculum/Notatio/Expande/Fenestra.lean` | 窓制御・UI・モード・設定タグ展開 |
| `Signaculum/Notatio/Expande/Fons.lean` | 書体タグ展開 |
| `Signaculum/Notatio/Expande/Systema.lean` | イベント・音響・動画・呼出・変更タグ展開 |
| `Signaculum/Notatio/Macro.lean` | `scriptum!` マクロ本体・文字列リテラル・式埋込 |
| `Signaculum/Notatio/Verificatio.lean` | `native_decide` による rfl 検証テスト |
