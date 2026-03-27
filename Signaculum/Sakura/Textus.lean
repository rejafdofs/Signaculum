-- Signaculum.Sakura.Textus
-- テキスト表示・書体・選択肢・タイミング にゃん♪

import Signaculum.Sakura.Fundamentum

namespace Signaculum.Sakura

-- ════════════════════════════════════════════════════
--  範圍制御 (Imperium Scopi) — 誰が喋るか
-- ════════════════════════════════════════════════════

/-- 主人格（\\h / \\0）に切り替へるにゃん -/
def sakura {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\h"

/-- 副人格（\\u / \\1）に切り替へるにゃん -/
def kero {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\u"

/-- 第 n 人格（\\p[n]）に切り替へるにゃん -/
def persona {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte s!"\\p[{n}]"

-- ════════════════════════════════════════════════════
--  表面制御 (Imperium Superficiei) — 表情
-- ════════════════════════════════════════════════════

/-- 表面 ID を設定する（\\s[n]）にゃん -/
def superficies {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte s!"\\s[{n}]"

/-- 表面 動畫を再生する（\\i[n]）にゃん -/
def animatio {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte s!"\\i[{n}]"

-- ════════════════════════════════════════════════════
--  文字表示 (Exhibitio Textus)
-- ════════════════════════════════════════════════════

/-- 改行（\\n）にゃん -/
def linea {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\n"

/-- 半改行（\\n[half]）にゃん -/
def dimidiaLinea {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\n[half]"

/-- 吹出しの文字を淸掃する（\\c）にゃん -/
def purga {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\c"

/-- 前の吹出しに追記する（\\C）にゃん -/
def adscribe {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\C"

/-- カーソル位置を指定する（\\_l[x,y]）にゃん -/
def cursor {m : Type → Type} [Monad m] (x y : String) : SakuraM m Unit :=
  emitte s!"\\_l[{evadeArgumentum x},{evadeArgumentum y}]"

-- ════════════════════════════════════════════════════
--  待機 (Mora) — テンポ制御
-- ════════════════════════════════════════════════════

/-- ミリ秒待機（\\_w[ms]）にゃん -/
def mora {m : Type → Type} [Monad m] (ms : Nat) : SakuraM m Unit :=
  emitte s!"\\_w[{ms}]"

/-- 簡易待機（\\w[1-9]、50ms × n）にゃん -/
def moraCeler {m : Type → Type} [Monad m] (n : Nat) (_h : 1 ≤ n ∧ n ≤ 9 := by omega) : SakuraM m Unit :=
  emitte s!"\\w{n}"

/-- 絕對時間待機（\\__w[ms]）にゃん -/
def moraAbsoluta {m : Type → Type} [Monad m] (ms : Nat) : SakuraM m Unit :=
  emitte s!"\\__w[{ms}]"

/-- 打鍵待ち（\\x）にゃん -/
def expecta {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\x"

/-- 打鍵待ち・淸掃にゃし（\\x[noclear]）にゃん -/
def expectaSine {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\x[noclear]"

/-- 時間制約區劃（\\t）にゃん -/
def tempusCriticum {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\t"

-- ════════════════════════════════════════════════════
--  選擇肢 (Optiones) — 使用者の選擇
-- ════════════════════════════════════════════════════

/-- 選擇肢を追加する（\\q[表題,識別子]）にゃん。
    表題(titulus)や識別子の特殊文字は自動的に遁走されるにゃ -/
def optio {m : Type → Type} [Monad m] (titulus signum : String) : SakuraM m Unit :=
  emitte s!"\\q[{evadeArgumentum titulus},{evadeArgumentum signum}]"

/-- 事象附き選擇肢（\\q[表題,OnEvent,ref0,ref1,...]）にゃん。
    表題(titulus)や事象の特殊文字は自動的に遁走されるにゃ -/
def optioEventum {m : Type → Type} [Monad m]
    (titulus eventum : String) (citationes : List String := []) : SakuraM m Unit :=
  let catenaCitationis := match citationes with
    | [] => ""
    | res => "," ++ ",".intercalate (res.map evadeArgumentum)
  emitte s!"\\q[{evadeArgumentum titulus},{evadeArgumentum eventum}{catenaCitationis}]"

/-- 錨（\\_a[id]...テキスト...\\_a）にゃん。
    閉ぢる時は `fineAncora` を呼ぶにゃ -/
def ancora {m : Type → Type} [Monad m] (id : String) : SakuraM m Unit :=
  emitte s!"\\_a[{evadeArgumentum id}]"

/-- 錨を閉ぢる（\\_a）にゃん -/
def fineAncora {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\_a"

/-- 選擇肢の時間制限を設定する（\\![set,choicetimeout,ms]）にゃん -/
def tempusOptionum {m : Type → Type} [Monad m] (ms : Nat) : SakuraM m Unit :=
  emitte s!"\\![set,choicetimeout,{ms}]"

/-- 時間切れ防止（\\*）にゃん -/
def prohibeTempus {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\*"

-- ════════════════════════════════════════════════════
--  制御 (Imperium)
-- ════════════════════════════════════════════════════

/-- スクリプト終了（\\e）にゃん。全ての SakuraScript の末尾に必ず置くにゃ -/
def finis {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\e"

/-- 即時表示切替（\\_q）にゃん -/
def celer {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\_q"

/-- ゴースト退出（\\-）にゃん -/
def exitus {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\-"

/-- 同期區劃切替（\\_s）にゃん -/
def synchrona {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\_s"

/-- 隨機ゴースト切替（\\+）にゃん -/
def mutaGhost {m : Type → Type} [Monad m] : SakuraM m Unit := emitte "\\+"

-- ════════════════════════════════════════════════════
--  書體 (Forma Litterarum)
-- ════════════════════════════════════════════════════

/-- 太字の切替（\\f[bold,b]）にゃん -/
def audax {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte s!"\\f[bold,{if b then "true" else "false"}]"

/-- 斜體の切替（\\f[italic,b]）にゃん -/
def obliquus {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte s!"\\f[italic,{if b then "true" else "false"}]"

/-- 下線の切替（\\f[underline,b]）にゃん -/
def sublinea {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte s!"\\f[underline,{if b then "true" else "false"}]"

/-- 取消線の切替（\\f[strike,b]）にゃん -/
def deletura {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte s!"\\f[strike,{if b then "true" else "false"}]"

/-- 文字色の設定（\\f[color,色]）にゃん。
    `Coloris.rgb 255 0 0`、`Coloris.hex "#FF0000"`、`Coloris.nomen "red"` 全部使へるにゃ -/
def color {m : Type → Type} [Monad m] (c : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[color,{c.toString}]"

/-- 文字の大きさ（\\f[height,n]）にゃん -/
def altitudoLitterarum {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte s!"\\f[height,{n}]"

/-- 書體名の設定（\\f[name,font]）にゃん -/
def nomenFontis {m : Type → Type} [Monad m] (nomen : String) : SakuraM m Unit :=
  emitte s!"\\f[name,{evadeArgumentum nomen}]"

/-- 文字揃へ（\\f[align,方向]）にゃん -/
def allineatio {m : Type → Type} [Monad m] (directio : DirectioAllineatio) : SakuraM m Unit :=
  emitte s!"\\f[align,{directio.toString}]"

/-- 縦方向文字揃へ（\\f[valign,方向]）にゃん -/
def allineatioVerticalis {m : Type → Type} [Monad m] (directio : DirectioVerticalis) : SakuraM m Unit :=
  emitte s!"\\f[valign,{directio.toString}]"

/-- 文字影の色を設定するにゃん（\\f[shadowcolor,色]）。
    "none" で影を無效にするにゃ -/
def colorUmbrae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[shadowcolor,{coloris.toString}]"

/-- 文字影のスタイルを設定するにゃん（\\f[shadowstyle,スタイル]）-/
def stylumUmbrae {m : Type → Type} [Monad m] (stylus : String) : SakuraM m Unit :=
  emitte s!"\\f[shadowstyle,{evadeArgumentum stylus}]"

/-- 文字の輪郭を設定するにゃん（\\f[outline,パラメータ]）-/
def contornus {m : Type → Type} [Monad m] (parametrum : String) : SakuraM m Unit :=
  emitte s!"\\f[outline,{evadeArgumentum parametrum}]"

/-- 下付き文字の切替にゃん（\\f[sub,true/false]）-/
def subscriptus {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte s!"\\f[sub,{if b then "true" else "false"}]"

/-- 上付き文字の切替にゃん（\\f[sup,true/false]）-/
def superscriptus {m : Type → Type} [Monad m] (b : Bool := true) : SakuraM m Unit :=
  emitte s!"\\f[sup,{if b then "true" else "false"}]"

/-- テキスト表示を無效にするにゃん（\\f[disable]）-/
def formaInhabilis {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\f[disable]"

/-- 書式を既定に戾す（\\f[default]）にゃん -/
def formaPraefinita {m : Type → Type} [Monad m] : SakuraM m Unit :=
  emitte "\\f[default]"

-- カーソル（選擇中）スタイル

/-- 選擇中カーソルの形状にゃん（\\f[cursorstyle,形状]）-/
def stylumCursorisElecti {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte s!"\\f[cursorstyle,{forma.toString}]"

/-- 選擇中カーソルの色にゃん（\\f[cursorcolor,色]）-/
def colorCursorisElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[cursorcolor,{coloris.toString}]"

/-- 選擇中カーソルの塗り色にゃん（\\f[cursorbrushcolor,色]）-/
def colorPenicilliCursorisElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[cursorbrushcolor,{coloris.toString}]"

/-- 選擇中カーソルの縁色にゃん（\\f[cursorpencolor,色]）-/
def colorCalamCursorisElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[cursorpencolor,{coloris.toString}]"

/-- 選擇中カーソルの文字色にゃん（\\f[cursorfontcolor,色]）-/
def colorFontisCursorisElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[cursorfontcolor,{coloris.toString}]"

/-- 選擇中カーソルの描畫方法にゃん（\\f[cursormethod,方法]）-/
def methodusCursorisElecti {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte s!"\\f[cursormethod,{methodus.toString}]"

-- カーソル（未選擇）スタイル

/-- 未選擇カーソルの形状にゃん（\\f[cursornotselectstyle,形状]）-/
def stylumCursorisNonElecti {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte s!"\\f[cursornotselectstyle,{forma.toString}]"

/-- 未選擇カーソルの色にゃん（\\f[cursornotselectcolor,色]）-/
def colorCursorisNonElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[cursornotselectcolor,{coloris.toString}]"

/-- 未選擇カーソルの塗り色にゃん（\\f[cursornotselectbrushcolor,色]）-/
def colorPenicilliCursorisNonElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[cursornotselectbrushcolor,{coloris.toString}]"

/-- 未選擇カーソルの縁色にゃん（\\f[cursornotselectpencolor,色]）-/
def colorCalamCursorisNonElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[cursornotselectpencolor,{coloris.toString}]"

/-- 未選擇カーソルの文字色にゃん（\\f[cursornotselectfontcolor,色]）-/
def colorFontisCursorisNonElecti {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[cursornotselectfontcolor,{coloris.toString}]"

/-- 未選擇カーソルの描畫方法にゃん（\\f[cursornotselectmethod,方法]）-/
def methodusCursorisNonElecti {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte s!"\\f[cursornotselectmethod,{methodus.toString}]"

-- 錨（選擇中）スタイル

/-- 錨テクストゥス全體色（\\f[anchor.font.color,色]）にゃん -/
def colorFontisAncorae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchor.font.color,{coloris.toString}]"

/-- 選擇中の錨形状にゃん（\\f[anchorstyle,形状]）-/
def stylumAncorae {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte s!"\\f[anchorstyle,{forma.toString}]"

/-- 選擇中の錨色にゃん（\\f[anchorcolor,色]）-/
def colorAncorae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchorcolor,{coloris.toString}]"

/-- 選擇中の錨塗り色にゃん（\\f[anchorbrushcolor,色]）-/
def colorPenicilliAncorae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchorbrushcolor,{coloris.toString}]"

/-- 選擇中の錨縁色にゃん（\\f[anchorpencolor,色]）-/
def colorCalamAncorae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchorpencolor,{coloris.toString}]"

/-- 選擇中の錨文字色にゃん（\\f[anchorfontcolor,色]）-/
def colorFontisAncoraeTotae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchorfontcolor,{coloris.toString}]"

/-- 選擇中の錨描畫方法にゃん（\\f[anchormethod,方法]）-/
def methodusAncorae {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte s!"\\f[anchormethod,{methodus.toString}]"

-- 錨（未選擇）スタイル

/-- 未選擇の錨形状にゃん（\\f[anchornotselectstyle,形状]）-/
def stylumAncoraeNonElectae {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte s!"\\f[anchornotselectstyle,{forma.toString}]"

/-- 未選擇の錨色にゃん（\\f[anchornotselectcolor,色]）-/
def colorAncoraeNonElectae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchornotselectcolor,{coloris.toString}]"

/-- 未選擇の錨塗り色にゃん（\\f[anchornotselectbrushcolor,色]）-/
def colorPenicilliAncoraeNonElectae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchornotselectbrushcolor,{coloris.toString}]"

/-- 未選擇の錨縁色にゃん（\\f[anchornotselectpencolor,色]）-/
def colorCalamAncoraeNonElectae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchornotselectpencolor,{coloris.toString}]"

/-- 未選擇の錨文字色にゃん（\\f[anchornotselectfontcolor,色]）-/
def colorFontisAncoraeNonElectae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchornotselectfontcolor,{coloris.toString}]"

/-- 未選擇の錨描畫方法にゃん（\\f[anchornotselectmethod,方法]）-/
def methodusAncoraeNonElectae {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte s!"\\f[anchornotselectmethod,{methodus.toString}]"

-- 錨（訪問済み）スタイル

/-- 訪問済み錨形状にゃん（\\f[anchorvisitedstyle,形状]）-/
def stylumAncoraeVisae {m : Type → Type} [Monad m] (forma : FormaMarci) : SakuraM m Unit :=
  emitte s!"\\f[anchorvisitedstyle,{forma.toString}]"

/-- 訪問済み錨色にゃん（\\f[anchorvisitedcolor,色]）-/
def colorAncoraeVisae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchorvisitedcolor,{coloris.toString}]"

/-- 訪問済み錨塗り色にゃん（\\f[anchorvisitedbrushcolor,色]）-/
def colorPenicilliAncoraeVisae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchorvisitedbrushcolor,{coloris.toString}]"

/-- 訪問済み錨縁色にゃん（\\f[anchorvisitedpencolor,色]）-/
def colorCalamAncoraeVisae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchorvisitedpencolor,{coloris.toString}]"

/-- 訪問済み錨文字色にゃん（\\f[anchorvisitedfontcolor,色]）-/
def colorFontisAncoraeVisae {m : Type → Type} [Monad m] (coloris : Coloris) : SakuraM m Unit :=
  emitte s!"\\f[anchorvisitedfontcolor,{coloris.toString}]"

/-- 訪問済み錨描畫方法にゃん（\\f[anchorvisitedmethod,方法]）-/
def methodusAncoraeVisae {m : Type → Type} [Monad m] (methodus : MethodusMarci) : SakuraM m Unit :=
  emitte s!"\\f[anchorvisitedmethod,{methodus.toString}]"

-- ════════════════════════════════════════════════════
--  吹出し (Bulla)
-- ════════════════════════════════════════════════════

/-- 吹出し ID を變更する（\\b[n]）にゃん -/
def bulla {m : Type → Type} [Monad m] (n : Nat) : SakuraM m Unit :=
  emitte s!"\\b[{n}]"

/-- 吹出しに畫像を重ねる（\\_b[path,x,y]）にゃん -/
def imagoBullae {m : Type → Type} [Monad m]
    (via : String) (x y : Nat) : SakuraM m Unit :=
  emitte s!"\\_b[{evadeArgumentum via},{x},{y}]"

/-- URL やファスキクルスへジャンプする（\\j[url]）にゃん -/
def saltum {m : Type → Type} [Monad m] (nexus : String) : SakuraM m Unit :=
  emitte s!"\\j[{evadeArgumentum nexus}]"

/-- 特殊文字の遁走(escape)にゃん -/
def evade {m : Type → Type} [Monad m] (c : Char) : SakuraM m Unit :=
  match c with
  | '\\' => emitte "\\\\"
  | '%'  => emitte "\\%"
  | ']'  => emitte "\\]"
  | _    => emitte (String.ofList [c])

/-- Unicode コードポイントで文字を出力するにゃん（\\_u[0xXXXX]）。
    code は "0041" のやうに 4 桁 16 進數で指定にゃ -/
def characterUnicode {m : Type → Type} [Monad m] (code : String) : SakuraM m Unit :=
  emitte s!"\\_u[{code}]"

/-- メッセージコードで文字を出力するにゃん（\\_m[0xXX]）-/
def characterMessage {m : Type → Type} [Monad m] (code : String) : SakuraM m Unit :=
  emitte s!"\\_m[{code}]"

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
    (scriptum : SakuraM m Unit) (initium : String := "") : m String := do
  let (_, resultatum) ← StateT.run scriptum { scriptum := initium }
  return resultatum.scriptum

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

end Signaculum.Sakura
