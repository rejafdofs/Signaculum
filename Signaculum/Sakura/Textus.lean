-- Signaculum.Sakura.Textus
-- テキスト表示・書体・選択肢・タイミング にゃん♪

import Signaculum.Sakura.Fundamentum

namespace Signaculum.Sakura

-- ════════════════════════════════════════════════════
--  範圍制御 (Imperium Scopi) — 誰が喋るか
-- ════════════════════════════════════════════════════

/-- 主人格（\\h / \\0）に切り替へるにゃん -/
def sakura {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.scopi .sakura)

/-- 副人格（\\u / \\1）に切り替へるにゃん -/
def kero {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.scopi .kero)

/-- 第 n 人格（\\p[n]）に切り替へるにゃん -/
def persona {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte (.scopi (.persona n))

-- ════════════════════════════════════════════════════
--  表面制御 (Imperium Superficiei) — 表情
-- ════════════════════════════════════════════════════

/-- 表面 ID を設定する（\\s[n]）にゃん -/
def superficies {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte (.superficiei (.superficies n))

/-- 表面 動畫を再生する（\\i[n]）にゃん -/
def animatio {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte (.superficiei (.animatio n))

-- ════════════════════════════════════════════════════
--  文字表示 (Exhibitio Textus)
-- ════════════════════════════════════════════════════

/-- 改行（\\n）にゃん -/
def linea {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.exhibitionis .linea)

/-- 半改行（\\n[half]）にゃん -/
def dimidiaLinea {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.exhibitionis .dimidiaLinea)

/-- 吹出しの文字を淸掃する（\\c）にゃん -/
def purga {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.exhibitionis .purga)

/-- 前の吹出しに追記する（\\C）にゃん -/
def adscribe {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.exhibitionis .adscribe)

/-- カーソル位置を指定する（\\_l[x,y]）にゃん -/
def cursor {m : Type → Type} [Monad m] (x y : String) : SakuraM m Unit :=
  emitte (.exhibitionis (.cursor x y))

-- ════════════════════════════════════════════════════
--  待機 (Mora) — テンポ制御
-- ════════════════════════════════════════════════════

/-- ミリ秒待機（\\_w[ms]）にゃん -/
def mora {m : Type → Type} [Monad m] (ms : Nat) : SakuraM m Unit :=
  emitte (.morae (.mora ms))

/-- 簡易待機（\\w[1-9]、50ms × n）にゃん -/
def moraCeler {m : Type → Type} [Monad m] (n : Nat) (_h : 1 ≤ n ∧ n ≤ 9 := by omega) : SakuraM m Unit :=
  emitte (.morae (.moraCeler n _h))

/-- 絕對時間待機（\\__w[ms]）にゃん -/
def moraAbsoluta {m : Type → Type} [Monad m] (ms : Nat) : SakuraM m Unit :=
  emitte (.morae (.moraAbsoluta ms))

/-- 打鍵待ち（\\x）にゃん -/
def expecta {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.morae .expecta)

/-- 打鍵待ち・淸掃にゃし（\\x[noclear]）にゃん -/
def expectaSine {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.morae .expectaSine)

/-- 時間制約區劃（\\t）にゃん -/
def tempusCriticum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.imperii .tempusCriticum)

-- ════════════════════════════════════════════════════
--  選擇肢 (Optiones) — 使用者の選擇
-- ════════════════════════════════════════════════════

/-- 選擇肢を追加する（\\q[表題,識別子]）にゃん。
    表題(titulus)や識別子の特殊文字は自動的に遁走されるにゃ -/
def optio {m : Type → Type} [Monad m] (titulus signum : String) : SakuraM m Unit :=
  emitte (.optionum (.optio titulus signum))

/-- 事象附き選擇肢（\\q[表題,OnEvent,ref0,ref1,...]）にゃん。
    表題(titulus)や事象の特殊文字は自動的に遁走されるにゃ -/
def optioEventum {m : Type → Type} [Monad m]
    (titulus eventum : String) (citationes : List String := []) : SakuraM m Unit :=
  emitte (.optionum (.optioEventum titulus eventum citationes))

/-- 錨（\\_a[id]...テキスト...\\_a）にゃん。
    閉ぢる時は `fineAncora` を呼ぶにゃ -/
def ancora {m : Type → Type} [Monad m] (id : String) : SakuraM m Unit :=
  emitte (.optionum (.ancora id))

/-- 錨を閉ぢる（\\_a）にゃん -/
def fineAncora {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.optionum .fineAncora)

/-- 選擇肢の時間制限を設定する（\\![set,choicetimeout,ms]）にゃん -/
def tempusOptionum {m : Type → Type} [Monad m] (ms : Nat) : SakuraM m Unit :=
  emitte (.optionum (.tempusOptionum ms))

/-- 時間切れ防止（\\*）にゃん -/
def prohibeTempus {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.imperii .prohibeTempus)

-- ════════════════════════════════════════════════════
--  制御 (Imperium)
-- ════════════════════════════════════════════════════

/-- スクリプト終了（\\e）にゃん。全ての SakuraScript の末尾に必ず置くにゃ -/
def finis {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.imperii .finis)

/-- 即時表示切替（\\_q）にゃん -/
def celer {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.imperii .celer)

/-- ゴースト退出（\\-）にゃん -/
def exitus {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.imperii .exitus)

/-- 同期區劃切替（\\_s）にゃん -/
def synchrona {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.imperii .synchrona)

/-- 隨機ゴースト切替（\\+）にゃん -/
def mutaGhost {m : Type → Type} [Monad m] : SakuraM m Unit := emitte (.imperii .mutaGhost)

-- ════════════════════════════════════════════════════
--  書體 (Forma Litterarum)
-- ════════════════════════════════════════════════════

/-- 太字の切替（\\f[bold,b]）にゃん -/
def audax {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte (.formae (.audax b))

/-- 斜體の切替（\\f[italic,b]）にゃん -/
def obliquus {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte (.formae (.obliquus b))

/-- 下線の切替（\\f[underline,b]）にゃん -/
def sublinea {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte (.formae (.sublinea b))

/-- 取消線の切替（\\f[strike,b]）にゃん -/
def deletura {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte (.formae (.deletura b))

/-- 文字色の設定（\\f[color,色]）にゃん。
    `Coloris.rgb 255 0 0`、`Coloris.hex "#FF0000"`、`Coloris.nomen "red"` 全部使へるにゃ -/
def color {m : Type → Type} [Monad m] (c : Coloris) : SakuraM m Unit :=
  emitte (.formae (.color c))

/-- 文字の大きさ（\\f[height,...]）にゃん。
    絕對ピクセル、相對（+/−）、百分率、default が指定できるにゃ -/
def altitudoLitterarum {m : Type → Type} [Monad m] (mag : MagnitudoLitterarum) : SakuraM m Unit :=
  emitte (.formae (.altitudoLitterarum mag))

/-- 書體名の設定（\\f[name,font]）にゃん -/
def nomenFontis {m : Type → Type} [Monad m] (nomen : String) : SakuraM m Unit :=
  emitte (.formae (.nomenFontis nomen))

/-- 文字揃へ（\\f[align,方向]）にゃん -/
def allineatio {m : Type → Type} [Monad m] (directio : DirectioAllineatio) : SakuraM m Unit :=
  emitte (.formae (.allineatio directio))

/-- 縦方向文字揃へ（\\f[valign,方向]）にゃん -/
def allineatioVerticalis {m : Type → Type} [Monad m] (directio : DirectioVerticalis) : SakuraM m Unit :=
  emitte (.formae (.allineatioVerticalis directio))

/-- 文字影の色を設定するにゃん（\\f[shadowcolor,色]）。
    "none" で影を無效にするにゃ -/
def colorUmbrae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorUmbrae coloris))

/-- 文字影のスタイルを設定するにゃん（\\f[shadowstyle,スタイル]）。
    `offset`=右下ずらし、`contornus`=輪郭風、`praefinitus`=既定にゃ -/
def stylumUmbrae {m : Type → Type} [Monad m] (stylus : StylusUmbrae) : SakuraM m Unit :=
  emitte (.formae (.stylumUmbrae stylus))

/-- 文字の輪郭を設定するにゃん（\\f[outline,パラメータ]）。
    `activus`=有效、`inactivus`=無效、`praefinitus`=既定、`inhabilis`=無效化にゃ -/
def contornus {m : Type → Type} [Monad m] (parametrum : StatusContorni) : SakuraM m Unit :=
  emitte (.formae (.contornus parametrum))

/-- 下付き文字の切替にゃん（\\f[sub,true/false]）-/
def subscriptus {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte (.formae (.subscriptus b))

/-- 上付き文字の切替にゃん（\\f[sup,true/false]）-/
def superscriptus {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte (.formae (.superscriptus b))

/-- テキスト表示を無效にするにゃん（\\f[disable]）-/
def formaInhabilis {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.formae .formaInhabilis)

/-- 書式を既定に戾す（\\f[default]）にゃん -/
def formaPraefinita {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.formae .formaPraefinita)

-- カーソル（選擇中）スタイル

/-- 選擇中カーソルの形状にゃん（\\f[cursorstyle,形状]）-/
def stylumCursorisElecti {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte (.formae (.stylumCursorisElecti forma))

/-- 選擇中カーソルの色にゃん（\\f[cursorcolor,色]）-/
def colorCursorisElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorCursorisElecti coloris))

/-- 選擇中カーソルの塗り色にゃん（\\f[cursorbrushcolor,色]）-/
def colorPenicilliCursorisElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorPenicilliCursorisElecti coloris))

/-- 選擇中カーソルの縁色にゃん（\\f[cursorpencolor,色]）-/
def colorCalamCursorisElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorCalamCursorisElecti coloris))

/-- 選擇中カーソルの文字色にゃん（\\f[cursorfontcolor,色]）-/
def colorFontisCursorisElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorFontisCursorisElecti coloris))

/-- 選擇中カーソルの描畫方法にゃん（\\f[cursormethod,方法]）-/
def methodusCursorisElecti {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte (.formae (.methodusCursorisElecti methodus))

-- カーソル（未選擇）スタイル

/-- 未選擇カーソルの形状にゃん（\\f[cursornotselectstyle,形状]）-/
def stylumCursorisNonElecti {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte (.formae (.stylumCursorisNonElecti forma))

/-- 未選擇カーソルの色にゃん（\\f[cursornotselectcolor,色]）-/
def colorCursorisNonElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorCursorisNonElecti coloris))

/-- 未選擇カーソルの塗り色にゃん（\\f[cursornotselectbrushcolor,色]）-/
def colorPenicilliCursorisNonElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorPenicilliCursorisNonElecti coloris))

/-- 未選擇カーソルの縁色にゃん（\\f[cursornotselectpencolor,色]）-/
def colorCalamCursorisNonElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorCalamCursorisNonElecti coloris))

/-- 未選擇カーソルの文字色にゃん（\\f[cursornotselectfontcolor,色]）-/
def colorFontisCursorisNonElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorFontisCursorisNonElecti coloris))

/-- 未選擇カーソルの描畫方法にゃん（\\f[cursornotselectmethod,方法]）-/
def methodusCursorisNonElecti {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte (.formae (.methodusCursorisNonElecti methodus))

-- 錨（選擇中）スタイル

/-- 錨テクストゥス全體色（\\f[anchor.font.color,色]）にゃん -/
def colorFontisAncorae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorFontisAncorae coloris))

/-- 選擇中の錨形状にゃん（\\f[anchorstyle,形状]）-/
def stylumAncorae {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte (.formae (.stylumAncorae forma))

/-- 選擇中の錨色にゃん（\\f[anchorcolor,色]）-/
def colorAncorae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorAncorae coloris))

/-- 選擇中の錨塗り色にゃん（\\f[anchorbrushcolor,色]）-/
def colorPenicilliAncorae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorPenicilliAncorae coloris))

/-- 選擇中の錨縁色にゃん（\\f[anchorpencolor,色]）-/
def colorCalamAncorae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorCalamAncorae coloris))

/-- 選擇中の錨文字色にゃん（\\f[anchorfontcolor,色]）-/
def colorFontisAncoraeTotae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorFontisAncoraeTotae coloris))

/-- 選擇中の錨描畫方法にゃん（\\f[anchormethod,方法]）-/
def methodusAncorae {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte (.formae (.methodusAncorae methodus))

-- 錨（未選擇）スタイル

/-- 未選擇の錨形状にゃん（\\f[anchornotselectstyle,形状]）-/
def stylumAncoraeNonElectae {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte (.formae (.stylumAncoraeNonElectae forma))

/-- 未選擇の錨色にゃん（\\f[anchornotselectcolor,色]）-/
def colorAncoraeNonElectae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorAncoraeNonElectae coloris))

/-- 未選擇の錨塗り色にゃん（\\f[anchornotselectbrushcolor,色]）-/
def colorPenicilliAncoraeNonElectae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorPenicilliAncoraeNonElectae coloris))

/-- 未選擇の錨縁色にゃん（\\f[anchornotselectpencolor,色]）-/
def colorCalamAncoraeNonElectae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorCalamAncoraeNonElectae coloris))

/-- 未選擇の錨文字色にゃん（\\f[anchornotselectfontcolor,色]）-/
def colorFontisAncoraeNonElectae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorFontisAncoraeNonElectae coloris))

/-- 未選擇の錨描畫方法にゃん（\\f[anchornotselectmethod,方法]）-/
def methodusAncoraeNonElectae {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte (.formae (.methodusAncoraeNonElectae methodus))

-- 錨（訪問済み）スタイル

/-- 訪問済み錨形状にゃん（\\f[anchorvisitedstyle,形状]）-/
def stylumAncoraeVisae {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte (.formae (.stylumAncoraeVisae forma))

/-- 訪問済み錨色にゃん（\\f[anchorvisitedcolor,色]）-/
def colorAncoraeVisae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorAncoraeVisae coloris))

/-- 訪問済み錨塗り色にゃん（\\f[anchorvisitedbrushcolor,色]）-/
def colorPenicilliAncoraeVisae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorPenicilliAncoraeVisae coloris))

/-- 訪問済み錨縁色にゃん（\\f[anchorvisitedpencolor,色]）-/
def colorCalamAncoraeVisae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorCalamAncoraeVisae coloris))

/-- 訪問済み錨文字色にゃん（\\f[anchorvisitedfontcolor,色]）-/
def colorFontisAncoraeVisae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte (.formae (.colorFontisAncoraeVisae coloris))

/-- 訪問済み錨描畫方法にゃん（\\f[anchorvisitedmethod,方法]）-/
def methodusAncoraeVisae {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte (.formae (.methodusAncoraeVisae methodus))

-- ════════════════════════════════════════════════════
--  吹出し (Bulla)
-- ════════════════════════════════════════════════════

/-- 吹出し ID を變更する（\\b[n]）にゃん -/
def bulla {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte (.bullae (.bulla n))

/-- 吹出しに畫像を重ねる（\\_b[path,x,y]）にゃん -/
def imagoBullae {m : Type → Type} [Monad m]
    (via : String) (x y : Nat) : SakuraM m Unit :=
  emitte (.bullae (.imagoBullae via x y))

/-- URL やファスキクルスへジャンプする（\\j[url]）にゃん -/
def saltum {m : Type → Type} [Monad m] (nexus : String) : SakuraM m Unit :=
  emitte (.exhibitionis (.saltum nexus))

/-- 特殊文字の遁走(escape)にゃん -/
def evade {m : Type → Type} [Monad m] (c : Char) : SakuraM m Unit :=
  emitte (.exhibitionis (.textus (String.ofList [c])))

/-- Unicode コードポイントで文字を出力するにゃん（\\_u[0xXXXX]）。
    code は "0041" のやうに 4 桁 16 進數で指定にゃ -/
def characterUnicode {m : Type → Type} [Monad m] (code : String) : SakuraM m Unit :=
  emitte (.exhibitionis (.characterUnicode code))

/-- メッセージコードで文字を出力するにゃん（\\_m[0xXX]）-/
def characterMessage {m : Type → Type} [Monad m] (code : String) : SakuraM m Unit :=
  emitte (.exhibitionis (.characterMessage code))

-- ════════════════════════════════════════════════════
--  便利にゃ組合せ (Combinationes Utiles)
-- ════════════════════════════════════════════════════

/-- 文字列を表示して改行するにゃん -/
def loquiEtLinea {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit := do
  loqui s; linea

/-- 主人格で表面を設定してから喋るにゃん -/
def sakuraLoquitur {m : Type → Type} [Monad m]
    (sup : Nat) (s : String) : SakuraM m Unit := do
  sakura; superficies sup; loqui s

/-- 副人格で表面を設定してから喋るにゃん -/
def keroLoquitur {m : Type → Type} [Monad m]
    (sup : Nat) (s : String) : SakuraM m Unit := do
  kero; superficies sup; loqui s

-- ════════════════════════════════════════════════════
--  無作爲 (Fortuita) — ランダム選擇
-- ════════════════════════════════════════════════════

/-- 配列からランダムに1つ選ぶにゃん。空配列なら空文字列を返すにゃ。
    インデックスは `i % n` で計算するから、配列アクセスは常に安全にゃ♪ -/
def elige (optiones : Array String) : IO String := do
  if h : optiones.size = 0 then return ""
  else
    let n := optiones.size
    let index ← IO.rand 0 (n - 1)
    let i := index % n
    have hi : i < n := Nat.mod_lt index (by omega)
    return optiones[i]

/-- 配列からランダムに1つ選んで表示するにゃん。
    `elige` + `loqui` の便利關數にゃ♪
    ```
    fortuito #["やっほー！", "こんにちは！", "おはよう！"]
    ``` -/
def fortuito (optiones : Array String) : SakuraIO Unit := do
  let s ← elige optiones
  loqui s

-- ════════════════════════════════════════════════════
--  實行 (Executio)
-- ════════════════════════════════════════════════════

/-- サクラスクリプト・モナドを實行し、蓄積された StatusSakurae を得るにゃん。
    スクリプトゥム文字列だけでなく Marker 等の附加ヘッダーも含むにゃ -/
def currere {m : Type → Type} [Monad m]
    (scriptum : SakuraM m Unit) (initium : StatusSakurae := {}) : m StatusSakurae := do
  let (_, resultatum) ← StateT.run scriptum initium
  return resultatum

/-- サクラスクリプト・モナドを實行し、蓄積されたスクリプトゥム文字列だけを得るにゃん。
    附加ヘッダーが不要な時はこちらを使ふにゃ -/
def currereScriptum {m : Type → Type} [Monad m]
    (scriptum : SakuraM m Unit) (initium : List Signum := []) : m String := do
  let (_, resultatum) ← StateT.run scriptum { scriptum := initium }
  return adCatenamLista resultatum.scriptum

-- ════════════════════════════════════════════════════
--  レスポンスムヘッダー設定 (Configuratio Responsi)
-- ════════════════════════════════════════════════════

/-- Marker ヘッダーを設定するにゃん。バルーン下部に附加情報を表示するにゃ -/
def configuraMarker {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit :=
  modify fun st => { st with marker := some s }

/-- BalloonOffset ヘッダーを設定するにゃん。バルーン位置を補正するにゃ -/
def configuraBalloonOffset {m : Type → Type} [Monad m] (x y : Int) : SakuraM m Unit :=
  modify fun st => { st with balloonOffset := some (x, y) }

/-- ErrorLevel ヘッダーを設定するにゃん。SSP のデヴェロッパーパレットで確認できるにゃ -/
def configuraErrorLevel {m : Type → Type} [Monad m] (gradus : GradusErroris) : SakuraM m Unit :=
  modify fun st => { st with errorLevel := some gradus }

/-- ErrorDescription ヘッダーを設定するにゃん。エラーの詳細を記すにゃ -/
def configuraErrorDescription {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit :=
  modify fun st => { st with errorDescription := some s }

/-- ErrorLevel と ErrorDescription を一括で設定するにゃん。
    イヴェントゥム處理器内でエラーを報告したい時に使ふにゃ♪ -/
def reportaErrorem {m : Type → Type} [Monad m]
    (gradus : GradusErroris) (descriptio : String) : SakuraM m Unit :=
  modify fun st => { st with errorLevel := some gradus, errorDescription := some descriptio }

/-- 情報レヴェルのエラーを報告するにゃん -/
def reportaInformationem {m : Type → Type} [Monad m] (msg : String) : SakuraM m Unit :=
  reportaErrorem .informatio msg

/-- 通知レヴェルのエラーを報告するにゃん -/
def reportaMonitum {m : Type → Type} [Monad m] (msg : String) : SakuraM m Unit :=
  reportaErrorem .monitum msg

/-- 警告レヴェルのエラーを報告するにゃん -/
def reportaAdmonitionem {m : Type → Type} [Monad m] (msg : String) : SakuraM m Unit :=
  reportaErrorem .admonitio msg

/-- エラーレヴェルのエラーを報告するにゃん -/
def reportaError {m : Type → Type} [Monad m] (msg : String) : SakuraM m Unit :=
  reportaErrorem .error msg

/-- 致命的エラーを報告するにゃん -/
def reportaPerniciem {m : Type → Type} [Monad m] (msg : String) : SakuraM m Unit :=
  reportaErrorem .pernicies msg

/-- MarkerSend ヘッダーを設定するにゃん。SSTP 送信先へのマーカーにゃ -/
def configuraMarkerSend {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit :=
  modify fun st => { st with markerSend := some s }

/-- ValueNotify ヘッダーを設定するにゃん。NOTIFY でもスクリプトゥムを實行するにゃ -/
def configuraValorNotifica {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit :=
  modify fun st => { st with valorNotifica := some s }

/-- Age ヘッダーを設定するにゃん。通信世代カウンタにゃ -/
def configuraAge {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  modify fun st => { st with age := some n }

/-- SecurityLevel ヘッダーを設定するにゃん。"local" か "external" にゃ -/
def configuraSecuritas {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit :=
  modify fun st => { st with securitas := some s }

/-- ヘッダーキー名から `:` と CR/LF を除去してパケットゥム破損を防ぐにゃん -/
private def purgaClavis (s : String) : String :=
  s.foldl (fun acc c => if c != ':' && c != '\r' && c != '\n' then acc.push c else acc) ""

/-- 任意のカスタムヘッダーを追加するにゃん。X-SSTP-PassThru-* 等に使ふにゃ。
    キー名から `:` と CR/LF は自動的に除去されるにゃ -/
def addeCastellum {m : Type → Type} [Monad m] (clavis valor : String) : SakuraM m Unit :=
  modify fun st => { st with cappitta := st.cappitta ++ [(purgaClavis clavis, valor)] }

-- ════════════════════════════════════════════════════
--  文字・行淸掃拡張 (Extensio Purgationis)
-- ════════════════════════════════════════════════════

/-- カーソル位置から n 文字を淸掃するにゃん（\\c[char,n]）-/
def purgaCharacterem {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte (.exhibitionis (.purgaCharacterem n))

/-- 指定位置から n 文字を淸掃するにゃん（\\c[char,n,initium]）-/
def purgaCharacteremAb {m : Type → Type} [Monad m] (n initium : Nat) : SakuraM m Unit :=
  emitte (.exhibitionis (.purgaCharacteremAb n initium))

/-- カーソル位置から n 行を淸掃するにゃん（\\c[line,n]）-/
def purgaLineam {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte (.exhibitionis (.purgaLineam n))

/-- 指定位置から n 行を淸掃するにゃん（\\c[line,n,initium]）-/
def purgaLineamAb {m : Type → Type} [Monad m] (n initium : Nat) : SakuraM m Unit :=
  emitte (.exhibitionis (.purgaLineamAb n initium))

-- ════════════════════════════════════════════════════
--  選擇肢拡張 (Extensio Optionum)
-- ════════════════════════════════════════════════════

/-- スクリプトゥム實行型選擇肢（\\q[title,script:content]）にゃん。
    選擇時にスクリプトゥムが直接實行されるにゃ -/
def optioScriptum {m : Type → Type} [Monad m] (titulus scriptum : String) : SakuraM m Unit :=
  emitte (.optionum (.optioScriptum titulus scriptum))

/-- 複數 ID 選擇肢（\\q[title,ID1,ID2,...]）にゃん。
    複數の識別子を格納するにゃ -/
def optioMultiplex {m : Type → Type} [Monad m] (titulus : String) (signa : List String) : SakuraM m Unit :=
  emitte (.optionum (.optioMultiplex titulus signa))

/-- 範圍選擇肢の開始（\\__q[ID,...]）にゃん。
    次の `fineOptioScopus` まで全テクストゥスが選擇肢になるにゃ -/
def optioScopus {m : Type → Type} [Monad m] (signum : String) (citationes : List String := []) : SakuraM m Unit :=
  emitte (.optionum (.optioScopus signum citationes))

/-- 範圍選擇肢の終了（\\__q）にゃん -/
def fineOptioScopus {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte (.optionum .fineOptioScopus)

end Signaculum.Sakura
