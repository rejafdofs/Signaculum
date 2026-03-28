# SakuraScriptum — 使い方ガイド

`Signaculum.Sakura` モジュールは、Lean 4 の do 記法でサクラスクリプトを型安全に組み立てるための DSL ライブラリです。

---

## モナドの種類

| 型エイリアス | 用途 |
|---|---|
| `SakuraM m α` | 基底モナド `m` を自由に選べる汎用形 |
| `SakuraPura α` | 純粋（副作用なし） |
| `SakuraIO α` | IO を伴う（`fortuito` など乱数系は必須） |

---

## 基本パターン

```lean
open Signaculum.Sakura

-- 文字列に変換するには currere を使う
def myScript : SakuraPura Unit := do
  sakura
  superficies 0
  loqui "こんにちは！"
  linea
  kero
  superficies 10
  loqui "やっほー♪"
  finis

-- 文字列を取得
#eval currereScriptum myScript  -- "\h\s[0]こんにちは！\n\u\s[10]やっほー♪\e"
```

---

## 文字の表示

| 関数 | 生成されるタグ | 説明 |
|---|---|---|
| `loqui s` | （テキスト） | `\`、`%`、`]` を自動エスケープして表示 |
| `loquiEtLinea s` | （テキスト）`\n` | 表示して改行 |
| `linea` | `\n` | 改行 |
| `dimidiaLinea` | `\n[half]` | 半改行 |
| `purga` | `\c` | 吹出し内容をクリア |
| `adscribe` | `\C` | 前の吹出しに追記 |
| `cursor x y` | `\_l[x,y]` | カーソル位置指定 |
| `crudus s` | （生文字列） | エスケープなしで直接出力（高度用） |

---

## 人格と表面

```lean
sakura            -- \h  主人格（さくら）
kero              -- \u  副人格
persona 2         -- \p[2]  第n人格

superficies 0     -- \s[0]  表面ID設定
superficiesAbsconde  -- \s[-1]  表面を非表示
animatio 5        -- \i[5]  アニメーション再生
animatioExpecta 5 -- \i[5,wait]  再生完了まで待つ
```

便利な組み合わせ：

```lean
sakuraLoquitur 0 "こんにちは"  -- \h\s[0]こんにちは
keroLoquitur 10 "やっほー"    -- \u\s[10]やっほー
```

---

## 待機・制御

| 関数 | タグ | 説明 |
|---|---|---|
| `mora 500` | `\_w[500]` | 500ms 待機 |
| `moraCeler 3` | `\w3` | 150ms 待機（50ms × n） |
| `moraAbsoluta 500` | `\__w[500]` | 絶対時間待機 |
| `expecta` | `\x` | クリック待ち |
| `expectaSine` | `\x[noclear]` | クリック待ち（クリア無し） |
| `tempusCriticum` | `\t` | 時間制約区間 |
| `prohibeTempus` | `\*` | タイムアウト防止 |
| `finis` | `\e` | スクリプト終了（必ず末尾に） |
| `celer` | `\_q` | 即時表示切替 |
| `exitus` | `\-` | ゴースト退出 |

---

## 選択肢

```lean
-- 単純な選択肢（識別子はイベント名に使う）
optio "はい" "OnYes"
optio "いいえ" "OnNo"

-- イベント＋参照引数付き
optioEventum "詳しく聞く" "OnAskDetail" ["topic1", "topic2"]

-- 錨（アンカー、クリック可能なテキスト）
ancora "myLink"
loqui "ここをクリック"
fineAncora

-- 選択肢タイムアウト（ミリ秒）
tempusOptionum 5000
```

---

## 書体

```lean
audax true           -- \f[bold,true]   太字オン
obliquus true        -- \f[italic,true] 斜体オン
sublinea true        -- \f[underline,true]
deletura true        -- \f[strike,true]
subscriptus true     -- \f[sub,true]
superscriptus true   -- \f[sup,true]
formaInhabilis       -- \f[disable]
formaPraefinita      -- \f[default]  書式リセット

-- 文字色（r, g, b はそれぞれ 0〜255、コンパイル時検証）
color (.rgb 255 0 0)      -- RGB
color (.hex "#FF0000")    -- 16進
color (.nomen "red")      -- 名前

-- サイズ・フォント
altitudoLitterarum (.absoluta 14)    -- \f[height,14]
altitudoLitterarum (.relativa 3)     -- \f[height,+3]
altitudoLitterarum (.relativa (-5))  -- \f[height,-5]
altitudoLitterarum (.proportio 200)  -- \f[height,200%]
altitudoLitterarum .praefinita       -- \f[height,default]
nomenFontis "MS Gothic"             -- \f[name,MS Gothic]

-- 文字揃え
allineatio .centrum         -- \f[align,center]
allineatioVerticalis .summum -- \f[valign,top]

-- 影・輪郭
colorUmbrae (.rgb 0 0 0)
stylumUmbrae .offset        -- \f[shadowstyle,offset]
stylumUmbrae .contornus     -- \f[shadowstyle,outline]
contornus .activus          -- \f[outline,true]
contornus .inhabilis        -- \f[outline,disable]
```

`DirectioAllineatio` の値: `.sinistrum` `.dextrum` `.centrum` `.contentum`
`DirectioVerticalis` の値: `.summum` `.medium` `.imum`
`StylusUmbrae` の値: `.offset` `.contornus` `.praefinitus`
`StatusContorni` の値: `.activus` `.inactivus` `.praefinitus` `.inhabilis`
`MagnitudoLitterarum` の値: `.absoluta n` `.relativa n` `.proportio n` `.praefinita`

---

## 音声

```lean
sonus "voice.wav"                              -- \_v[voice.wav]
expectaSonum                                   -- \_V（再生待ち）
sonus8 "se.wav"                                -- \8[se.wav]（簡易）

sonusPulsus "bgm.mp3"                          -- \![sound,play,...]
sonusPulsus "bgm.mp3" { volumen := some 80 }   -- 音量指定
sonusOrbitans "bgm.mp3"                        -- ループ
sonusInterrumpit "bgm.mp3"                     -- 停止
sonusPausat "bgm.mp3"                          -- 一時停止
sonusContinuat "bgm.mp3"                       -- 再開
sonusOneratur "bgm.mp3"                        -- 事前読み込み
expectaSonumPulsus                             -- \![sound,wait]
```

`OptionesSoni` のチェーン例（各パラメータにコンパイル時境界検証あり）：

```lean
-- cumVolumine: 0〜100、cumLibramento: -100〜100、cumCursu: 1〜10000
sonusPulsus "bgm.mp3"
  ({ } |>.cumVolumine 70 |>.cumLibramento (-20) |>.cumCursu 150)
```

---

## ウィンドウの開閉

```lean
-- 引数なしで開けるウィンドウ
aperi .console
aperi .arcaCommunicationis
aperi .exploratorFantasmatis
-- ...（FenestraAperibilis の全コンストラクタ参照）

-- 引数付き（FenestraAperibilis のペイロード付きコンストラクタ）
aperi (.navigator "https://example.com")   -- ブラウザで URL を開く
aperi (.nuntiatorem "to=foo@bar.com")      -- メーラー
aperi (.explorator "C:/path/to/dir")       -- エクスプローラー
aperi (.configuratio "myPluginId")         -- 設定ダイアログ
aperi (.fasciculum "C:/path/to/file.exe") -- ファイル実行
aperi (.auxilium "HelpTopicId")           -- ヘルプ

-- 閉じる
claude .inputum
claude .console
claude .communicatio
```

`FenestraClaudibilis`: `.inputum` `.console` `.communicatio` `.doctrina` `.fabricatio`

---

## ダイアログ

```lean
-- ファイルを開くダイアログ
aperiDialogum .aperire

-- オプション付き
aperiDialogum .servare
  ({ } |>.cumTitulo "保存先を選択" |>.cumExtensione "txt")

aperiDialogum .directorium  -- フォルダ選択
aperiDialogum .color        -- 色選択

-- ダイアログを閉じる
claudeDialogum "myDialogId"
```

`ModusDialogi`: `.aperire` `.servare` `.directorium` `.color`

`OptionesDialogi` のフィールド:

| メソッド | 対応オプション |
|---|---|
| `cumTitulo s` | `--title=s` |
| `cumSigno s` | `--id=s` |
| `cumDirecto s` | `--dir=s` |
| `cumFiltro s` | `--filter=s` |
| `cumNomine s` | `--name=s` |
| `cumExtensione s` | `--ext=s` |
| `cumColore c` | `--color=...`（色選択専用、`Coloris` 型） |

---

## 入力ボックス

### テキスト入力

以下は文字列形（イベント名を文字列で指定）、def ベース形（識別子形）、ラムダ形の3通りです。

```lean
-- 通常（inputbox）— 文字列形
aperiInputum .simplex "OnInput" "タイトル" "初期テキスト"

-- パスワード（passwordinput）— 文字列形
aperiInputum .sigillum "OnPassInput" "パスワード" ""

-- def ベース形（識別子形）
def onTextEntered (text : String) : SakuraIO Unit := do
  sakura; superficies 0; loqui s!"入力: {text}"; finis
aperiInputum .simplex onTextEntered "名前を入力" ""

-- ラムダ形（インラインで書けるにゃ）
-- text には SSP が返す Reference[0]（ユーザー入力文字列）が自動的に渡される
aperiInputum .simplex (fun text => scriptum こんにちは\、{text}さん) "名前を入力"

-- オプション付き
aperiInputum .simplex "OnInput" "タイトル" ""
  ({ } |>.cumNoClose |>.cumNoClear |>.cumTempore 30)
```

### 数値系入力

数値入力は用途別に3つの関数に分かれています。それぞれコンパイル時に境界が検証されます。

```lean
-- 日付入力（年・月・日）
-- mensis: 1〜12、dies: 1〜diesInMense（閏年考慮）
aperiInputumDiei "OnDate" "日付を選択" 2026 3 14

-- 時刻入力（時・分・秒）
-- hora: 0〜23、minutum: 0〜59、secundum: 0〜59
aperiInputumTemporis "OnTime" "時刻を選択" 12 0 0

-- スライダー入力（最小・最大・初期値）
-- minimum ≤ initium ∧ initium ≤ maximum
aperiInputumGradus "OnSlider" "音量" 0 100 50
```

### IP アドレス入力

```lean
aperiInputumIP "OnIP" "IPアドレス" 192 168 1 1
```

`OptionesInputi` のメソッド: `.cumNoClose` `.cumNoClear` `.cumTempore n`

---

## イベント

```lean
-- イベントを発生させる（文字列形: SSP 組み込み事象はこちら）
excita "OnMyEvent"
excita "OnMyEvent" ["ref0", "ref1"]

-- 他ゴーストに発生させる
excitaAlium "SomeGhost" "OnMyEvent" ["arg"]

-- 一定時間後（文字列形）
excitaPostTempus 5000 1 "OnTimer"        -- 5秒後、1回
excitaPostTempus 1000 0 "OnTick"         -- 1秒ごと、無限

-- 結果をその場に埋め込む
insere "OnGetValue" ["key"]

-- 通知（文字列形）
notifica "OnNotify"
notificaAlium "SomeGhost" "OnNotify"
```

### def ベース DSL 形式（識別子形）

```lean
-- A 形式: def ベース事象（型付き引数あり）
-- 引数は Reference 経由で渡される（Reference[0], Reference[1], ...）
excita onGreet "れゃ" 42                    -- \![raise,Ns.onGreet,...]
notifica onGreet "れゃ" 42                  -- \![notify,...]
excitaPostTempus 5000 1 onGreet "れゃ" 42   -- \![timerraise,...]
notificaPostTempus 1000 0 onGreet "れゃ" 42 -- \![timernotify,...]
optioEventum "詳しく" onChosen "topic1"     -- \q[...]

-- 非同期 SSTP 送信（SakuraIO Unit を返す def）
spawnaScriptum onLongTask arg1             -- do 記法
-- scriptum! 記法でも同様：
-- \![async, onLongTask arg1]

-- B 形式: コールバック登録のみ（SSP がランタイムで refs を渡す）
aperiInputum .simplex onTextEntered "名前を入力" ""
aperiInputumGradus onAgeSelected "年齢" 0 100 25
aperiInputumIP onIPSelected "IP アドレス" 192 168 1 1
legeProprietatem onPropResult [.ghostName, .shellName]

-- 他ゴースト・プラグイン宛ては文字列形のまま
excitaAlium "AnotherGhost" "OnSomeEvent" ["arg"]
notificaPlugin "MyPlugin" "OnNotify"
```

### ラムダ形（インラインコールバック）

ラムダ形は `(fun ...)` でコールバックをインラインに書ける。
引数なしの場合ラムダは `Rogatio → SakuraIO Unit` 型（`Tractator`）として直接登録される。
引数ありの場合は **Reference 経由で渡され**、ラムダのパラメータ型に応じて自動変換される。

```lean
-- 引数なし: ラムダは Tractator として直接登録
excita (fun _ => scriptum こんにちは)

-- 引数あり: Reference[0] が String として s に渡される
excita (fun s : String => scriptum {s}さん、こんにちは) "名前"

-- 複数引数
excita (fun name : String => fun n : Nat => scriptum {name}は{n}回目) "れゃ" 3

-- PostTempus ラムダ形
excitaPostTempus 5000 1 (fun s : String => scriptum {s}) "text"

-- aperiInputum ラムダ形（Reference[0] = 入力テキスト）
aperiInputum .simplex (fun text => scriptum こんにちは\、{text}さん) "名前を入力"
```

---

## ゴースト・シェル・吹出しの切替

```lean
mutaGhostNomen "AnotherGhost"
mutaGhostNomen "AnotherGhost" { excitaEventum := true }

mutaShell "NewShell"
mutaBullam "NewBalloon"

renova .shiori    -- リロード（ScopusRenovationis）
renova .tegumentum
renova .fantasma

renovaGhost       -- \![reboot]（完全再起動）
```

`ScopusRenovationis`: `.descriptum` `.shiori` `.tegumentum` `.bulla` `.fantasma` `.makoto` `.graphumAI`

---

## 表示・可視性

```lean
vanesco           -- \![vanish]（一時非表示）
restituere        -- \![restore]（復元）
restituere "GhostName"  -- 他ゴーストを復元

movere 100 200 (-1) (-1)     -- \![move,sx,sy,kx,ky]
movereAsync 100 200 (-1) (-1)
zoom 150                      -- \z[150]（150%表示）

seraRepictura    -- 再描画ロック
reseraRepictura  -- ロック解除
```

---

## ウィンドウ状態・位置

```lean
configuraStatusFenestrae .semperSupra   -- 最前面固定
configuraStatusFenestrae .minime        -- 最小化
allineatioDesktop .imum                 -- 下部吸着
configuratioScalae 150                  -- 拡大率 150%（Int 型、負値で軸反転）
configuratioAlphae 80                   -- 透明度 80（0〜100、コンパイル時検証）
configuraPositionem 0 0 0               -- 位置固定
reseraPositionem                        -- 位置固定解除
ordoFenestrarum [0, 1, 2]              -- Z順序
```

---

## アニメーション制御

```lean
animaIncepit 0 5     -- \![anim,start,0,5]
animaDesinit 0 5     -- \![anim,stop,0,5]
animaPausat 0 5      -- \![anim,pause,0,5]
animaContinuat 0 5   -- \![anim,resume,0,5]
animaPurgat 0 5      -- \![anim,clear,0,5]
animaOperatur 0 5    -- \![anim,playing,0,5]（再生中か確認）
animaTranslatio 0 5 10 (-5)  -- \![anim,offset,0,5,10,-5]

-- anim add 系
animaAddOverlay 3
animaAddOverlayPos 3 10 20
animaAddBase 3
animaAddMove 10 (-5)
animaAddOverlayFast 3
```

---

## 着せ替え・効果

```lean
nexaDressup "hat" "top" (some true)  -- \![bind,hat,top,1]（着衣）
nexaDressup "hat" "top" (some false) -- \![bind,hat,top,0]（脱衣）
nexaDressup "hat" "top"              -- \![bind,hat,top]（トグル）
applicaEffectum "blur.dll" 60 ""
applicaFiltratum "sepia.dll" 500 ""
applicaFiltratum "" 0 ""           -- フィルター除去

applicaEffectum2 1 "blur.dll" 60 ""  -- 副表面に効果
```

---

## HTTP・外部実行

```lean
executaHttpGet "https://example.com"
executaHttpPost "https://example.com" "--body=hello"
executaHttpHead "https://example.com"
executaHttpPut  "https://example.com" ""
executaHttpDelete "https://example.com" ""
executaHttpPatch  "https://example.com" ""
executaRssGet   "https://example.com/feed.rss"

executaExtractionem "archive.zip" "C:/dest"
executaCompressionem "C:/source" "archive.zip"
executaInstallationem "C:/path" "ghost.nar"
executaInstallationemUrl "https://example.com/ghost.nar" "ghost"
executaCreationemNAR
executaCreationemUpdateData
renovaSeIpsum
evanesceSeIpsum
```

---

## SHIORI / SAORI / プラグイン呼び出し

```lean
vocaShiori "OnMyEvent" ["ref0"]
vocaSaori "plugin.dll" "MyFunction" ["arg0"]
vocaPlugin "MyPlugin" "OnEvent" ["arg"]

-- プラグインへの通知
notificaPlugin "MyPlugin" "OnNotify"
excitaPluginPostTempus 1000 3 "MyPlugin" "OnTimer"
```

---

## 設定系

```lean
configuraAutoScroll true
configuraBullaeOffset .sakura 10 (-5)
sessioRapida true
nictatus true
semperSupra false
tabellaTascae true
tractusWindowae false
configuraSerikoOs true
configuraStickyWindow [0, 1]
resetStickyWindow
allineatioDesktop .liber
```

---

## プロパティ

```lean
configuraProprietatem "mykey" "myvalue"
legeProprietatem "OnResult" ["key1", "key2"]
```

---

## 乱数選択

```lean
-- IO モナドが必要
def talkRandom : SakuraIO Unit := do
  sakura
  superficies 0
  fortuito #["やっほー！", "こんにちは！", "おはよう！"]
  finis

-- 文字列だけ取り出す場合
let s ← elige #["A", "B", "C"]
```

scriptum! 記法では `{expr}` に `Array α` / `List α` を渡すだけでランダム表示できます（`Exhibibilis` 型クラス経由）：

```lean
-- {配列} で自動ランダム選択（SakuraIO 文脈）
def talkRandom2 : SakuraIO Unit := scriptum!
  \h \s[0] {#["やっほー！", "こんにちは！", "おはよう！"]}
  \e

-- List でも同様
def talkRandom3 : SakuraIO Unit := scriptum!
  \h \s[0] {["A", "B", "C"]}
  \e
```

---

## 特殊文字・低レベル

```lean
characterUnicode "0041"   -- \_u[0041]（'A'）
characterMessage "0x41"   -- \_m[0x41]
evade '\\'                -- バックスラッシュのエスケープ出力
inhibeTagas               -- \_?（タグ実行禁止）
referentiaResourcei "ID"  -- \&[ID]
nuntiumWindowae "0x400" "0" "0"  -- \m[...] Windows メッセージ送信
creaViam                  -- \![create,shortcut]
exploraPostam "account"   -- \![biff,account]
```

---

## 吹出し制御

```lean
bulla 2                   -- \b[2]  吹出しID変更
bullaAbsconde             -- \b[-1] 非表示
imagoBullae "img.png" 10 20
imagoBullaeOpaca "img.png" 10 20
imagoBullaeInlineata "img.png"
imagoBullaeInlineataOpaca "img.png"
lineaProportionalis 50    -- \n[percent,50]（Int 型: 負値・100超も指定可能）
linearisAbrogatur         -- \_n（自動改行禁止）
allineatioBullae .sinistrum -- \![set,balloonalign,left]
allineatioBullae .centrum   -- \![set,balloonalign,center]
allineatioBullae .nullus    -- \![set,balloonalign,none]
tempusBullae 3000         -- 3秒で消える
moraTextus 200            -- テキストスクロール速度
signatumBullae "marker"
margosBullae 5 5 5 5      -- \![set,balloonpadding,...]
seraRepicturaBullae
reseraRepicturaBullae
seraMotusBullae
reseraMotusBullae
ostendeMarcam             -- \![*]
renovaPositionemBullae    -- \![execute,resetballoonpos]
```

---

## モード制御

```lean
ingredereModumPassivum    -- \![enter,passivemode]
egrediereModumPassivum
ingredereModumOnline      -- \![enter,onlinemode]
egrediereModumOnline
ingredereModumNonInterruptum
egrediereModumNonInterruptum
ingredereModumInductivum
egrediereModumInductivum
ingredereModumCollisionis          -- \![enter,collisionmode]
ingredereModumCollisionis true     -- 矩形衝突
egrediereModumCollisionis
ingredereModumSelectionis .rectus "0,0,100,100"
egrediereModumSelectionis
ingredereSticky
egrediereSticky
ingrederePositionemDomesticam
egredierePositionemDomesticam
```

---

## 引数のエスケープについて

`loqui` は表示テキスト用（`\`・`%`・`]` をエスケープ）。タグ引数はライブラリ側が `evadeArgumentum` で自動処理するため、呼び出し側で手動エスケープは不要です。カンマや引用符を含む文字列も自動的に `"..."` でクォートされます。

---

## 最小のトーク例

```lean
open Signaculum.Sakura

def myTalk : SakuraPura Unit := do
  sakura
  superficies 0
  loqui "ねえ、聞いてくれる？"
  mora 500
  linea
  optio "うん" "OnYes"
  optio "いや" "OnNo"
  finis

-- スクリプト文字列を取得してSHIORIから返す
def getValue : String := Id.run (currere myTalk)
```

---

## scriptum! マクロ記法

`Signaculum.Notatio` モジュールは `scriptum!` マクロを提供します。SakuraScript を原形タグ記法で書けるようにする DSL です。

### 基本的な使い方

```lean
import Signaculum.Notatio

open Signaculum.Notatio

def myTalk : SakuraPura Unit := scriptum!
  \h \s[0] "こんにちは" \n
  \u \s[10] "やっほー"
  \e
```

### do 記法との比較

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

### 対応タグ一覧

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
| `\![raise, "event"]` | `excita "event"` | イベント発生（文字列形） |
| `\![raise, ident args*]` | `excita ident args*` | イベント発生（def 識別子形） |
| `\![raise, (fun x => ...)]` | `excita (fun x => ...)` | イベント発生（ラムダ形） |
| `\![embed, "event"]` | `insere "event"` | イベント埋込（文字列形） |
| `\![embed, ident args*]` | `insere ident args*` | イベント埋込（def 識別子形） |
| `\![embed, (fun x => ...)]` | `insere (fun x => ...)` | イベント埋込（ラムダ形） |
| `\![notify, "event"]` | `notifica "event"` | 通知（文字列形） |
| `\![notify, ident args*]` | `notifica ident args*` | 通知（def 識別子形） |
| `\![notify, (fun x => ...)]` | `notifica (fun x => ...)` | 通知（ラムダ形） |
| `\![timerraise, t, r, "event"]` | `excitaPostTempus t r "event"` | 遅延発火（文字列形） |
| `\![timerraise, t, r, ident args*]` | `excitaPostTempus t r ident args*` | 遅延発火（def 識別子形） |
| `\![timerraise, t, r, (fun x => ...)]` | `excitaPostTempus t r (fun x => ...)` | 遅延発火（ラムダ形） |
| `\![timernotify, t, r, "event"]` | `notificaPostTempus t r "event"` | 遅延通知（文字列形） |
| `\![timernotify, t, r, ident args*]` | `notificaPostTempus t r ident args*` | 遅延通知（def 識別子形） |
| `\![timernotify, t, r, (fun x => ...)]` | `notificaPostTempus t r (fun x => ...)` | 遅延通知（ラムダ形） |
| `\![open,inputbox, (fun x => ...), t, title]` | `aperiInputum .simplex (fun x => ...) title` | テキスト入力（ラムダ形） |
| `\![open,inputbox, ident, t, title]` | `aperiInputum .simplex ident title ""` | テキスト入力（識別子形） |
| `\![open,passwordinput, (fun x => ...), t, title]` | `aperiInputum .sigillum (fun x => ...) title` | パスワード入力（ラムダ形） |
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

### 式埋込と型強制（Exhibibilis 型クラス）

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

### モジュール構成

| ファイル | 内容 |
|---|---|
| `Signaculum/Notatio.lean` | アグレガートル |
| `Signaculum/Notatio/Categoria.lean` | 構文カテゴリア宣言 |
| `Signaculum/Notatio/Textus.lean` | テキスト・範囲・待機・選択肢・制御タグ |
| `Signaculum/Notatio/Fons.lean` | 書体タグ |
| `Signaculum/Notatio/Fenestra.lean` | 窓制御・UI・モード・設定タグ |
| `Signaculum/Notatio/Systema.lean` | イベント・音響・動画・呼出・変更タグ |
| `Signaculum/Notatio/Macro.lean` | scriptum! マクロ本体・文字列リテラル・式埋込 |
| `Signaculum/Notatio/Verificatio.lean` | rfl 検証テスト |
