-- Signaculum.Sakura.Typi
-- 型定義専用ぢゃ。他の Signaculum ファスキクルスへの インポルトなしにゃん♪

namespace Signaculum.Sakura

/-- SHIORI/3.0 レスポンスムの ErrorLevel ヘッダーの等級にゃん。
    SSP のデヴェロッパーパレットで確認できるにゃ♪ -/
inductive GradusErroris where
  | informatio  -- info: 情報にゃ
  | monitum     -- notice: 通知にゃ
  | admonitio   -- warning: 警告にゃ
  | error       -- error: エラーにゃ
  | pernicies   -- critical: 致命的エラーにゃ
  deriving Repr, BEq, Inhabited

/-- GradusErroris を SHIORI/3.0 仕樣の文字列に變換するにゃん -/
def GradusErroris.adCatenam : GradusErroris → String
  | .informatio => "info"
  | .monitum    => "notice"
  | .admonitio  => "warning"
  | .error      => "error"
  | .pernicies  => "critical"

instance : ToString GradusErroris := ⟨GradusErroris.adCatenam⟩

-- ════════════════════════════════════════════════════
--  列挙型 (Typi Enumerati)
-- ════════════════════════════════════════════════════

/-- カーソル・錨の形状にゃん。
    `quadratum`=矩形、`sublineaForma`=下線、`utrumque`=矩形+下線、
    `nullus`=非表示、`praefinitus`=バルーン設定の標準に戻るにゃ -/
inductive FormaMarci where
  | quadratum        -- square
  | sublineaForma    -- underline
  | utrumque         -- square+underline
  | nullus           -- none
  | praefinitus      -- default
  deriving Repr

/-- 選擇肢マーカーの描畫方法にゃん。
    Win32 SetROP2 の全オペレーターに加へ、SSP 擴張の `alpha`/`normal` も使へるにゃ。
    `R2_` プレフィクスなしの小文字で指定するにゃん -/
inductive MethodusMarci where
  -- Win32 SetROP2 オペレーターにゃん
  | black          -- R2_BLACK
  | notmergepen    -- R2_NOTMERGEPEN
  | masknotpen     -- R2_MASKNOTPEN
  | notcopypen     -- R2_NOTCOPYPEN
  | maskpennot     -- R2_MASKPENNOT
  | not            -- R2_NOT
  | xorpen         -- R2_XORPEN
  | notmaskpen     -- R2_NOTMASKPEN
  | maskpen        -- R2_MASKPEN
  | notxorpen      -- R2_NOTXORPEN
  | nop            -- R2_NOP
  | mergenotpen    -- R2_MERGENOTPEN
  | copypen        -- R2_COPYPEN
  | mergepennot    -- R2_MERGEPENNOT
  | mergepen       -- R2_MERGEPEN
  | white          -- R2_WHITE
  -- SSP 擴張にゃん
  | xor            -- xor（R2_XORPEN の別名にゃ）
  | alpha          -- α合成
  | normal         -- 通常描畫
  | praefinitus    -- default（既定に戾すにゃ）
  deriving Repr

/-- 文字揃への方向にゃん。
    `sinistrum`=左、`dextrum`=右、`centrum`=中央、`contentum`=均等にゃ -/
inductive DirectioAllineatio where
  | sinistrum   -- left
  | dextrum     -- right
  | centrum     -- center
  | contentum   -- justify
  deriving Repr

/-- 縦方向文字揃へにゃん。
    `summum`=上、`medium`=中央、`imum`=下にゃ -/
inductive DirectioVerticalis where
  | summum   -- top
  | medium   -- middle
  | imum     -- bottom
  deriving Repr

/-- ウィンドウ状態にゃん。
    `semperSupra`=常に最前面、`nonSemperSupra`=通常、`minime`=最小化にゃ -/
inductive StatusFenestrae where
  | semperSupra       -- stayontop
  | nonSemperSupra    -- !stayontop
  | minime            -- minimize
  deriving Repr

/-- デスクトップ吸着方向にゃん。
    `summum`=上、`imum`=下、`liber`=自由移動にゃ -/
inductive DirectioDesktop where
  | summum   -- top
  | imum     -- bottom
  | liber    -- free
  deriving Repr

def FormaMarci.toString : FormaMarci → String
  | .quadratum     => "square"
  | .sublineaForma => "underline"
  | .utrumque      => "square+underline"
  | .nullus        => "none"
  | .praefinitus   => "default"

def MethodusMarci.toString : MethodusMarci → String
  | .black       => "black"
  | .notmergepen => "notmergepen"
  | .masknotpen  => "masknotpen"
  | .notcopypen  => "notcopypen"
  | .maskpennot  => "maskpennot"
  | .not         => "not"
  | .xorpen      => "xorpen"
  | .notmaskpen  => "notmaskpen"
  | .maskpen     => "maskpen"
  | .notxorpen   => "notxorpen"
  | .nop         => "nop"
  | .mergenotpen => "mergenotpen"
  | .copypen     => "copypen"
  | .mergepennot => "mergepennot"
  | .mergepen    => "mergepen"
  | .white       => "white"
  | .xor         => "xor"
  | .alpha       => "alpha"
  | .normal      => "normal"
  | .praefinitus => "default"

def DirectioAllineatio.toString : DirectioAllineatio → String
  | .sinistrum  => "left"
  | .dextrum    => "right"
  | .centrum    => "center"
  | .contentum  => "justify"

def DirectioVerticalis.toString : DirectioVerticalis → String
  | .summum => "top"
  | .medium => "middle"
  | .imum   => "bottom"

def StatusFenestrae.toString : StatusFenestrae → String
  | .semperSupra    => "stayontop"
  | .nonSemperSupra => "!stayontop"
  | .minime         => "minimize"

def DirectioDesktop.toString : DirectioDesktop → String
  | .summum => "top"
  | .imum   => "bottom"
  | .liber  => "free"

/-- 吹出し方向の設定にゃん。`allineatioBullae` に渡すにゃ。
    ukadoc の `\\![set,balloonalign,...]` に對應するにゃん。
    `sinistrum`=左、`centrum`=中央、`summum`=上、`dextrum`=右、`imum`=下、`nullus`=自動にゃ -/
inductive DirectioAllineatioBullae where
  | sinistrum   -- left
  | centrum     -- center
  | summum      -- top
  | dextrum     -- right
  | imum        -- bottom
  | nullus      -- none（自動切替にゃ）
  deriving Repr

def DirectioAllineatioBullae.toString : DirectioAllineatioBullae → String
  | .sinistrum => "left"
  | .centrum   => "center"
  | .summum    => "top"
  | .dextrum   => "right"
  | .imum      => "bottom"
  | .nullus    => "none"

/-- 文字影のスタイルにゃん。`stylumUmbrae` に渡すにゃ。
    ukadoc の `\\f[shadowstyle,...]` に對應するにゃん。
    `offset`=右下ずらし、`contornus`=輪郭風、`praefinitus`=既定にゃ -/
inductive StylusUmbrae where
  | offset      -- offset（右下ずらし影にゃ）
  | contornus   -- outline（輪郭風影にゃ）
  | praefinitus -- default（既定に戾すにゃ）
  deriving Repr

def StylusUmbrae.toString : StylusUmbrae → String
  | .offset      => "offset"
  | .contornus   => "outline"
  | .praefinitus => "default"

/-- 文字輪郭の狀態にゃん。`contornus` に渡すにゃ。
    ukadoc の `\\f[outline,...]` に對應するにゃん。
    `activus`=有效、`inactivus`=無效、`praefinitus`=既定、`inhabilis`=無效化にゃ -/
inductive StatusContorni where
  | activus     -- true / 1
  | inactivus   -- false / 0
  | praefinitus -- default
  | inhabilis   -- disable
  deriving Repr

def StatusContorni.toString : StatusContorni → String
  | .activus     => "true"
  | .inactivus   => "false"
  | .praefinitus => "default"
  | .inhabilis   => "disable"

/-- 壁紙の表示モードにゃん。`configuraTapete` に渡すにゃ。
    ukadoc の `\\![set,wallpaper,...,option]` に對應するにゃん -/
inductive ModusTapetis where
  | centrum   -- center（中央配置にゃ）
  | tessella  -- tile（タイル配置にゃ）
  | extende   -- stretch（引き伸ばしにゃ）
  | extendeX  -- stretch-x（橫方向のみ引き伸ばしにゃ）
  | extendeY  -- stretch-y（縱方向のみ引き伸ばしにゃ）
  | spatium   -- span（複數モニタにまたがるにゃ）
  deriving Repr

def ModusTapetis.toString : ModusTapetis → String
  | .centrum  => "center"
  | .tessella => "tile"
  | .extende  => "stretch"
  | .extendeX => "stretch-x"
  | .extendeY => "stretch-y"
  | .spatium  => "span"

/-- 選擇モードにゃん。`ingredereModumSelectionis` に渡すにゃ。
    ukadoc の `\\![enter,selectmode,mode,...]` に對應するにゃん -/
inductive ModusSelectionis where
  | rectus  -- rect（矩形選擇にゃ）
  deriving Repr

def ModusSelectionis.toString : ModusSelectionis → String
  | .rectus => "rect"

/-- 文字の大きさ指定にゃん。`altitudoLitterarum` に渡すにゃ。
    ukadoc の `\\f[height,...]` に對應するにゃん。
    - `absoluta n`   : 絕對ピクセル（例：15）
    - `relativa n`   : 相對ピクセル（例：+3, -5）
    - `proportio n`  : 百分率（例：200%）
    - `praefinita`   : 既定に戾す -/
inductive MagnitudoLitterarum where
  | absoluta  (n : Nat)  -- 絕對ピクセルにゃ
  | relativa  (n : Int)  -- 相對ピクセル（+/−）にゃ
  | proportio (n : Int)  -- 百分率にゃ
  | praefinita           -- default にゃ
  deriving Repr

def MagnitudoLitterarum.toString : MagnitudoLitterarum → String
  | .absoluta n  => s!"{n}"
  | .relativa n  => if n ≥ 0 then s!"+{n}" else s!"{n}"
  | .proportio n => s!"{n}%"
  | .praefinita  => "default"

/-- 色の指定方法にゃん。
    - `rgb r g b`  : RGB 各 0〜255（`\f[color,...]` で r,g,b に展開されるにゃ）
    - `hex s`      : 16 進數文字列 "RRGGBB" または "#RRGGBB" にゃ
    - `nomen n`    : "red" "white" など名前付き色にゃ
    - `nullus`     : "none"（影色を無效化するときに使ふにゃ）
    - `praefinitus`                    : "default"（既定色に戾すにゃ）
    - `inhabilis`                      : "disable"（色指定を無效化するにゃ）
    - `praefinitusAncorae`             : "default.anchor"
    - `praefinitusAncoraeNonElectae`   : "default.anchornotselect"
    - `praefinitusAncoraeVisae`        : "default.anchorvisited"
    - `praefinitusCursoris`            : "default.cursor"
    - `praefinitusCursorisNonElecti`   : "default.cursornotselect"
    - `praefinitusPlanus`              : "default.plain" -/
inductive Coloris where
  | rgb   (r g b : Nat) (hr : r ≤ 255 := by omega) (hg : g ≤ 255 := by omega) (hb : b ≤ 255 := by omega)
  | hex   (s : String)
  | nomen (n : String)
  | nullus
  | praefinitus
  | inhabilis
  | praefinitusAncorae
  | praefinitusAncoraeNonElectae
  | praefinitusAncoraeVisae
  | praefinitusCursoris
  | praefinitusCursorisNonElecti
  | praefinitusPlanus
  deriving Repr

def Coloris.toString : Coloris → String
  | .rgb r g b ..                  => s!"{r},{g},{b}"
  | .hex s                         => s
  | .nomen n                       => n
  | .nullus                        => "none"
  | .praefinitus                   => "default"
  | .inhabilis                     => "disable"
  | .praefinitusAncorae            => "default.anchor"
  | .praefinitusAncoraeNonElectae  => "default.anchornotselect"
  | .praefinitusAncoraeVisae       => "default.anchorvisited"
  | .praefinitusCursoris           => "default.cursor"
  | .praefinitusCursorisNonElecti  => "default.cursornotselect"
  | .praefinitusPlanus             => "default.plain"

/-- 音聲コマンドのオプション群にゃん。
    指定したフィールドだけが出力されるにゃ。
    - `volumen`     : 音量 0〜100（`--volume=n`）
    - `libramentum` : 左右バランス −100〜100（`--balance=n`）
    - `cursus`      : 再生速度 1〜10000、100 が等速（`--rate=n`）
    - `fenestra`    : シークバー窓の表示（`--window=true/false`）
    - `solusAudio`  : 映像ファイルの音聲のみ再生、load 専用（`--sound-only=true/false`） -/
structure OptionesSoni where
  volumen     : Option Nat  := none
  libramentum : Option Int  := none
  cursus      : Option Nat  := none
  fenestra    : Option Bool := none
  solusAudio  : Option Bool := none
  deriving Repr

def OptionesSoni.toString (o : OptionesSoni) : String :=
  let ps : List String := []
  let ps := match o.volumen     with | none => ps | some v => ps ++ [s!"--volume={v}"]
  let ps := match o.libramentum with | none => ps | some b => ps ++ [s!"--balance={b}"]
  let ps := match o.cursus      with | none => ps | some r => ps ++ [s!"--rate={r}"]
  let ps := match o.fenestra    with | none => ps | some w => ps ++ [s!"--window={if w then "true" else "false"}"]
  let ps := match o.solusAudio  with | none => ps | some s => ps ++ [s!"--sound-only={if s then "true" else "false"}"]
  ",".intercalate ps

/-- 音量を設定するにゃん（0〜100）。ドット記法でチェーンできるにゃ♪ -/
def OptionesSoni.cumVolumine (o : OptionesSoni) (n : Nat) (_h : n ≤ 100 := by omega) : OptionesSoni :=
  { o with volumen := some n }

/-- 左右バランスを設定するにゃん（−100〜100、0 が中央）にゃ -/
def OptionesSoni.cumLibramento (o : OptionesSoni) (n : Int) (_h : -100 ≤ n ∧ n ≤ 100 := by omega) : OptionesSoni :=
  { o with libramentum := some n }

/-- 再生速度を設定するにゃん（1〜10000、100 が等速）にゃ -/
def OptionesSoni.cumCursu (o : OptionesSoni) (n : Nat) (_h : 1 ≤ n ∧ n ≤ 10000 := by omega) : OptionesSoni :=
  { o with cursus := some n }

/-- シークバー窓の表示を設定するにゃん -/
def OptionesSoni.cumFenestra (o : OptionesSoni) (b : Bool := true) : OptionesSoni :=
  { o with fenestra := some b }

/-- 映像ファイルの音聲のみ再生を設定するにゃん（load 専用）にゃ -/
def OptionesSoni.cumSoloAudio (o : OptionesSoni) (b : Bool := true) : OptionesSoni :=
  { o with solusAudio := some b }

/-- 吹出しの對象スコープにゃん。
    - `sakura` : キャラクター０（さくら）側にゃ
    - `kero`   : キャラクター１（うろ）側にゃ -/
inductive ScopusBullae where
  | sakura
  | kero
  deriving Repr

def ScopusBullae.toString : ScopusBullae → String
  | .sakura => "sakura"
  | .kero   => "kero"

/-- 他ゴーストのトーク連携モードにゃん。
    - `inactivus` : 連携なし（`false`）
    - `ante`      : 自分のトーク前に連携（`before`）
    - `post`      : 自分のトーク後に連携（`after`） -/
inductive ModusGhostAlieni where
  | inactivus
  | ante
  | post
  deriving Repr

def ModusGhostAlieni.toString : ModusGhostAlieni → String
  | .inactivus => "false"
  | .ante      => "before"
  | .post      => "after"

/-- 入力ボックスのオプション群にゃん。
    - `noclose` : 送信後もボックスを閉ぢない（`--option=noclose`）
    - `noclear` : 送信後も入力文字列をクリアしない（`--option=noclear`）
    - `tempus`  : タイムアウト秒數（`--timeout=n`） -/
structure OptionesInputi where
  noclose : Bool       := false
  noclear : Bool       := false
  tempus  : Option Nat := none
  deriving Repr

def OptionesInputi.toString (o : OptionesInputi) : String :=
  let ps : List String := []
  let ps := if o.noclose then ps ++ ["--option=noclose"] else ps
  let ps := if o.noclear then ps ++ ["--option=noclear"] else ps
  let ps := match o.tempus with | none => ps | some t => ps ++ [s!"--timeout={t}"]
  ",".intercalate ps

/-- 送信後もボックスを閉ぢない設定にするにゃん -/
def OptionesInputi.cumNoClose (o : OptionesInputi) : OptionesInputi :=
  { o with noclose := true }

/-- 送信後も入力をクリアしない設定にするにゃん -/
def OptionesInputi.cumNoClear (o : OptionesInputi) : OptionesInputi :=
  { o with noclear := true }

/-- タイムアウト秒數を設定するにゃん -/
def OptionesInputi.cumTempore (o : OptionesInputi) (n : Nat) : OptionesInputi :=
  { o with tempus := some n }

/-- ダイアローグスのオプション群にゃん。
    - `titulus`          : ダイアローグスのタイトル（`--title=s`）
    - `signum`           : 識別子（`--id=s`）
    - `directum`         : 初期ディレクトリウム（`--dir=s`）
    - `filtrum`          : ファイルフィルトルム（`--filter=s`）
    - `nomen`            : 初期ファイル名（`--name=s`）
    - `extensio`         : デフォルト拡張子（`--ext=s`）
    - `colorisInitialis` : 初期色 RGB（`--color=R G B`、色選擇ダイアローグス専用） -/
structure OptionesDialogi where
  titulus          : Option String             := none
  signum           : Option String             := none
  directum         : Option String             := none
  filtrum          : Option String             := none
  nomen            : Option String             := none
  extensio         : Option String             := none
  colorisInitialis : Option Coloris := none
  deriving Repr

def OptionesDialogi.toString (o : OptionesDialogi) : String :=
  let ps : List String := []
  let ps := match o.titulus          with | none => ps | some s => ps ++ [s!"--title={s}"]
  let ps := match o.signum           with | none => ps | some s => ps ++ [s!"--id={s}"]
  let ps := match o.directum         with | none => ps | some s => ps ++ [s!"--dir={s}"]
  let ps := match o.filtrum          with | none => ps | some s => ps ++ [s!"--filter={s}"]
  let ps := match o.nomen            with | none => ps | some s => ps ++ [s!"--name={s}"]
  let ps := match o.extensio         with | none => ps | some s => ps ++ [s!"--ext={s}"]
  let ps := match o.colorisInitialis with | none => ps | some c => ps ++ [s!"--color={c.toString}"]
  ",".intercalate ps

/-- ダイアローグスのタイトルを設定するにゃん -/
def OptionesDialogi.cumTitulo (o : OptionesDialogi) (s : String) : OptionesDialogi :=
  { o with titulus := some s }

/-- 識別子を設定するにゃん -/
def OptionesDialogi.cumSigno (o : OptionesDialogi) (s : String) : OptionesDialogi :=
  { o with signum := some s }

/-- 初期ディレクトリウムを設定するにゃん -/
def OptionesDialogi.cumDirecto (o : OptionesDialogi) (s : String) : OptionesDialogi :=
  { o with directum := some s }

/-- ファイルフィルトルムを設定するにゃん -/
def OptionesDialogi.cumFiltro (o : OptionesDialogi) (s : String) : OptionesDialogi :=
  { o with filtrum := some s }

/-- 初期ファイル名を設定するにゃん -/
def OptionesDialogi.cumNomine (o : OptionesDialogi) (s : String) : OptionesDialogi :=
  { o with nomen := some s }

/-- デフォルト拡張子を設定するにゃん -/
def OptionesDialogi.cumExtensione (o : OptionesDialogi) (s : String) : OptionesDialogi :=
  { o with extensio := some s }

/-- 初期色を設定するにゃん（色選擇ダイアローグス専用にゃ） -/
def OptionesDialogi.cumColore (o : OptionesDialogi) (c : Coloris) : OptionesDialogi :=
  { o with colorisInitialis := some c }

/-- ゴースト・シェル・吹出し切替コマンドのオプション群にゃん。
    - `excitaEventum` : 切替後に OnShellChanged 等のイベントを發生させる（`--option=raise-event`） -/
structure OptionesMutationis where
  excitaEventum : Bool := false
  deriving Repr

def OptionesMutationis.toString (o : OptionesMutationis) : String :=
  if o.excitaEventum then "--option=raise-event" else ""

/-- 切替後にイベントを發生させる設定にするにゃん -/
def OptionesMutationis.cumExcitaEventu (o : OptionesMutationis) : OptionesMutationis :=
  { o with excitaEventum := true }

-- ════════════════════════════════════════════════════
--  遁走關數 (Functiones Evasionis)
--  FenestraAperibilis.toString 等で使ふので此處に置くにゃん♪
-- ════════════════════════════════════════════════════

/-- 文字列中の特殊文字（\\、%、]）を全て遁走して表示用に安全な形にするにゃん。
    loqui 等の表示系關數はこれを通すから、お嬢樣は氣にしにゃくていいにゃ♪ -/
def evadeTextus (s : String) : String :=
  s.foldl (fun acc c =>
    match c with
    | '\\' => acc ++ "\\"
    | '%'  => acc ++ "\\%"
    | ']'  => acc ++ "\\]"
    | _    => acc.push c
  ) ""

/-- タグ引數内の特殊文字（\\、%、]）を遁走し、`,` や `"` を含む場合は `"..."` 括りにするにゃん。
    ukadoc 仕樣: `"..."` 括りが公式で、`\,` は未定義にゃ。
    括り内では `"` → `""` に二重化するにゃ♪ -/
def evadeArgumentum (s : String) : String :=
  let s1 := s.foldl (fun acc c =>
    match c with
    | '\\' => acc ++ "\\\\"
    | ']'  => acc ++ "\\]"
    | '%'  => acc ++ "\\%"
    | _    => acc.push c
  ) ""
  if s1.any (fun c => c == ',' || c == '"') then
    "\"" ++ s1.replace "\"" "\"\"" ++ "\""
  else
    s1

/-- `\\![open,X]` で開けるウィンドウの種類にゃん。`aperi` 關數に渡すにゃ -/
inductive FenestraAperibilis where
  | console
  | arcaCommunicationis
  | arcaDoctrinae
  | arcaFabricationis
  | exploratorFantasmatis
  | exploratorTegumenti
  | exploratorBullae
  | probatioSuperficiei
  | exploratorHeadlineae
  | exploratorModulorum
  | graphumUsus
  | graphumUsusBullae
  | graphumUsusTotal
  | calendarium
  | nuntium
  | readme
  | conditiones
  | graphumAI
  | palettaDeveloper
  | petitioShiori
  | exploratorDressupi
  | navigator    (nexus  : String)
  | nuntiatorem  (param  : String)
  | explorator   (via    : String)
  | configuratio (id     : String)
  | fasciculum   (via    : String)
  | auxilium     (id     : String)
  deriving Repr

def FenestraAperibilis.toString : FenestraAperibilis → String
  | .console               => "console"
  | .arcaCommunicationis   => "communicatebox"
  | .arcaDoctrinae         => "teachbox"
  | .arcaFabricationis     => "makebox"
  | .exploratorFantasmatis => "ghostexplorer"
  | .exploratorTegumenti   => "shellexplorer"
  | .exploratorBullae      => "balloonexplorer"
  | .probatioSuperficiei   => "surfacetest"
  | .exploratorHeadlineae  => "headlinesensorexplorer"
  | .exploratorModulorum   => "pluginexplorer"
  | .graphumUsus           => "rateofusegraph"
  | .graphumUsusBullae     => "rateofusegraphballoon"
  | .graphumUsusTotal      => "rateofusegraphtotal"
  | .calendarium           => "calendar"
  | .nuntium               => "messenger"
  | .readme                => "readme"
  | .conditiones           => "terms"
  | .graphumAI             => "aigraph"
  | .palettaDeveloper      => "developer"
  | .petitioShiori         => "shiorirequest"
  | .exploratorDressupi    => "dressupexplorer"
  | .navigator    nexus    => s!"browser,{evadeArgumentum nexus}"
  | .nuntiatorem  param    => s!"mailer,{evadeArgumentum param}"
  | .explorator   via      => s!"explorer,{evadeArgumentum via}"
  | .configuratio id       => s!"configurationdialog,{evadeArgumentum id}"
  | .fasciculum   via      => s!"file,{evadeArgumentum via}"
  | .auxilium     id       => s!"help,{evadeArgumentum id}"

/-- `\\![close,X]`（追加引數なし）で閉ぢられるウィンドウの種類にゃん。
    `claude` 關數に渡すにゃ。
    - `inputum`      : 入力ボックス
    - `console`      : コンソール
    - `communicatio` : コミュニケートボックス
    - `doctrina`     : 教育ボックス
    - `fabricatio`   : 作成ボックス -/
inductive FenestraClaudibilis where
  | inputum
  | console
  | communicatio
  | doctrina
  | fabricatio
  deriving Repr

def FenestraClaudibilis.toString : FenestraClaudibilis → String
  | .inputum      => "inputbox"
  | .console      => "console"
  | .communicatio => "communicatebox"
  | .doctrina     => "teachbox"
  | .fabricatio   => "makebox"

/-- `\\![reload,X]` で再讀込できる對象の種類にゃん。
    `renova` 關數に渡すにゃ。
    - `descriptum` : descript.txt
    - `shiori`     : SHIORI
    - `tegumentum` : シェル
    - `bulla`      : 吹出し
    - `fantasma`   : ゴースト全體
    - `makoto`     : makoto
    - `graphumAI`  : AI グラフ -/
inductive ScopusRenovationis where
  | descriptum
  | shiori
  | tegumentum
  | bulla
  | fantasma
  | makoto
  | graphumAI
  deriving Repr

def ScopusRenovationis.toString : ScopusRenovationis → String
  | .descriptum => "descript"
  | .shiori     => "shiori"
  | .tegumentum => "shell"
  | .bulla      => "balloon"
  | .fantasma   => "ghost"
  | .makoto     => "makoto"
  | .graphumAI  => "aigraph"

-- ════════════════════════════════════════════════════
--  プロパティ型 (Typi Proprietatis)
-- ════════════════════════════════════════════════════

/-- ghostlist / balloonlist 等の generic サブプロパティにゃん -/
inductive ProprietasGenerica where
  | nomen           -- name
  | sakuraNomen     -- sakuraname
  | keroNomen       -- keroname
  | fabricator      -- craftmanw
  | fabricatorNexus -- craftmanurl
  | via             -- path
  | imago           -- thumbnail
  | nexusAedis      -- homeurl
  | nomenUtentis    -- username
  | index           -- index
  | icon            -- icon（ghostlist 専用にゃ）
  deriving Repr

def ProprietasGenerica.toString : ProprietasGenerica → String
  | .nomen           => "name"
  | .sakuraNomen     => "sakuraname"
  | .keroNomen       => "keroname"
  | .fabricator      => "craftmanw"
  | .fabricatorNexus => "craftmanurl"
  | .via             => "path"
  | .imago           => "thumbnail"
  | .nexusAedis      => "homeurl"
  | .nomenUtentis    => "username"
  | .index           => "index"
  | .icon            => "icon"

/-- currentghost.scope(ID) のサブプロパティにゃん -/
inductive ProprietasScopus where
  | superficiesNum          -- surface.num
  | superficiesX            -- surface.x
  | superficiesY            -- surface.y
  | serikoSuperficiesPraef  -- seriko.defaultsurface
  | x                       -- x（スコープ基準点 X にゃ）
  | y                       -- y（スコープ基準点 Y にゃ）
  | rect                    -- rect（ウィンドウ矩形にゃ）
  | nomen                   -- name
  deriving Repr

def ProprietasScopus.toString : ProprietasScopus → String
  | .superficiesNum         => "surface.num"
  | .superficiesX           => "surface.x"
  | .superficiesY           => "surface.y"
  | .serikoSuperficiesPraef => "seriko.defaultsurface"
  | .x                      => "x"
  | .y                      => "y"
  | .rect                   => "rect"
  | .nomen                  => "name"

/-- currentghost.balloon.scope(ID) のサブプロパティにゃん -/
inductive ProprietasBullaeScopus where
  | numerus              -- num（吹出し ID にゃ）
  | latitudo             -- validwidth
  | latitudoInitialis    -- validwidth.initial
  | altitudo             -- validheight
  | altitudoInitialis    -- validheight.initial
  | linea                -- lines
  | lineaInitialis       -- lines.initial
  | basePosX             -- basepos.x
  | basePosY             -- basepos.y
  | latitudoCharacteris  -- char_width
  deriving Repr

def ProprietasBullaeScopus.toString : ProprietasBullaeScopus → String
  | .numerus             => "num"
  | .latitudo            => "validwidth"
  | .latitudoInitialis   => "validwidth.initial"
  | .altitudo            => "validheight"
  | .altitudoInitialis   => "validheight.initial"
  | .linea               => "lines"
  | .lineaInitialis      => "lines.initial"
  | .basePosX            => "basepos.x"
  | .basePosY            => "basepos.y"
  | .latitudoCharacteris => "char_width"

/-- rateofuselist のサブプロパティにゃん -/
inductive ProprietasRateOfUse where
  | nomen               -- name
  | sakuraNomen         -- sakuraname
  | keroNomen           -- keroname
  | numerusStartuporum  -- boottime（起動回數にゃ）
  | minutae             -- bootminute（累計分にゃ）
  | proportio           -- percent
  deriving Repr

def ProprietasRateOfUse.toString : ProprietasRateOfUse → String
  | .nomen              => "name"
  | .sakuraNomen        => "sakuraname"
  | .keroNomen          => "keroname"
  | .numerusStartuporum => "boottime"
  | .minutae            => "bootminute"
  | .proportio          => "percent"

/-- プロパティシステムの鍵にゃん。`proprietasCitata` / `legeProprietatem` に渡すにゃ。
    引數付きコンストラクタは動的な ID やゴースト名を受け取るにゃ♪ -/
inductive Proprietas where
  -- ── system.* ──
  | systemAnnus              -- system.year
  | systemMensis             -- system.month
  | systemDies               -- system.day
  | systemHora               -- system.hour
  | systemMinutum            -- system.minute
  | systemSecundum           -- system.second
  | systemMillisecundum      -- system.millisecond
  | systemDiesSeptimanus     -- system.dayofweek
  | systemCursorPositio      -- system.cursor.pos
  | systemOsTypus            -- system.os.type
  | systemOsNomen            -- system.os.name
  | systemOsVersione         -- system.os.version
  | systemOsCompilatio       -- system.os.build
  | systemOsParensTypus      -- system.os.parenttype
  | systemOsParensNomen      -- system.os.parentname
  | systemCpuOnus            -- system.cpu.load
  | systemCpuNumerus         -- system.cpu.num
  | systemCpuVendor          -- system.cpu.vendor
  | systemCpuNomen           -- system.cpu.name
  | systemCpuPulsus          -- system.cpu.clock
  | systemCpuFunctiones      -- system.cpu.features
  | systemMemoriaOnus        -- system.memory.load
  | systemMemoriaPhysicaTota -- system.memory.phyt
  | systemMemoriaPhysicaLibera -- system.memory.phya
  -- ── baseware.* ──
  | basewereVersione         -- baseware.version
  | basewereNomen            -- baseware.name
  -- ── ghostlist.* ──
  | ghostlistNumerus                                              -- ghostlist.count
  | ghostlistNomen  (nomen : String) (p : ProprietasGenerica)    -- ghostlist(name).*
  | ghostlistIndex  (index : Nat)    (p : ProprietasGenerica)    -- ghostlist.index(n).*
  | ghostlistCurrent               (p : ProprietasGenerica)      -- ghostlist.current.*
  -- ── activeghostlist.* ──
  | activeghostlistNomen  (nomen : String) (p : ProprietasGenerica)
  | activeghostlistIndex  (index : Nat)    (p : ProprietasGenerica)
  | activeghostlistCurrent               (p : ProprietasGenerica)
  -- ── currentghost.* ──
  | currentghostGenerica   (p : ProprietasGenerica)   -- currentghost.*（generic にゃ）
  | currentghostStatus                                -- currentghost.status
  | currentghostScopusNumerus                         -- currentghost.scope.count
  | currentghostScopus (scopus : Nat) (p : ProprietasScopus)
  -- ── currentghost.shelllist.* ──
  | currentghostShelllistNumerus
  | currentghostShelllistNomen  (nomen : String) (p : ProprietasGenerica)
  | currentghostShelllistIndex  (index : Nat)    (p : ProprietasGenerica)
  | currentghostShelllistCurrent               (p : ProprietasGenerica)
  -- ── currentghost.balloon.* ──
  | currentghostBullaeNumerus                         -- currentghost.balloon.count
  | currentghostBullaeGenerica (p : ProprietasGenerica) -- currentghost.balloon.*
  | currentghostBullaeScopusNumerus (scopus : Nat)   -- currentghost.balloon.scope(n).count
  | currentghostBullaeScopus (scopus : Nat) (p : ProprietasBullaeScopus)
  -- ── currentghost.mousecursor.* ──
  | currentghostCursorMus        -- currentghost.mousecursor
  | currentghostCursorTextus     -- currentghost.mousecursor.text
  | currentghostCursorExspecto   -- currentghost.mousecursor.wait
  | currentghostCursorManus      -- currentghost.mousecursor.hand
  | currentghostCursorPrehendo   -- currentghost.mousecursor.grip
  | currentghostCursorSagitta    -- currentghost.mousecursor.arrow
  | currentghostBullaeCursorMus      -- currentghost.balloon.mousecursor
  | currentghostBullaeCursorTextus   -- currentghost.balloon.mousecursor.text
  | currentghostBullaeCursorExspecto -- currentghost.balloon.mousecursor.wait
  | currentghostBullaeCursorSagitta  -- currentghost.balloon.mousecursor.arrow
  -- ── currentghost.seriko.* ──
  | currentghostSerikoSurfacesOmnes    -- currentghost.seriko.surfacelist.all
  | currentghostSerikoSurfacesDefinitae -- currentghost.seriko.surfacelist.defined
  -- ── balloonlist.* ──
  | balloonlistNumerus
  | balloonlistNomen  (nomen : String) (p : ProprietasGenerica)
  | balloonlistIndex  (index : Nat)    (p : ProprietasGenerica)
  -- ── headlinelist.* ──
  | headlinelistNumerus
  | headlinelistNomen  (nomen : String) (p : ProprietasGenerica)
  | headlinelistIndex  (index : Nat)    (p : ProprietasGenerica)
  -- ── pluginlist.* ──
  | pluginlistNumerus
  | pluginlistNomen  (nomen : String) (p : ProprietasGenerica)
  | pluginlistIndex  (index : Nat)    (p : ProprietasGenerica)
  -- ── history.ghost.* ──
  | historyGhostNumerus
  | historyGhostNomen  (nomen : String) (p : ProprietasGenerica)
  | historyGhostIndex  (index : Nat)    (p : ProprietasGenerica)
  -- ── history.balloon.* ──
  | historyBullaeNumerus
  | historyBullaeNomen  (nomen : String) (p : ProprietasGenerica)
  | historyBullaeIndex  (index : Nat)    (p : ProprietasGenerica)
  -- ── history.headline.* ──
  | historyHeadlineNumerus
  | historyHeadlineNomen  (nomen : String) (p : ProprietasGenerica)
  | historyHeadlineIndex  (index : Nat)    (p : ProprietasGenerica)
  -- ── history.plugin.* ──
  | historyPluginNumerus
  | historyPluginNomen  (nomen : String) (p : ProprietasGenerica)
  | historyPluginIndex  (index : Nat)    (p : ProprietasGenerica)
  -- ── rateofuselist.* ──
  | rateofuselistNomen  (nomen : String) (p : ProprietasRateOfUse)
  | rateofuselistIndex  (index : Nat)    (p : ProprietasRateOfUse)
  -- ── SHIORI 變數 ──
  | shioriVariabilis (nomen : String)    -- shiori.{name}
  deriving Repr

-- プロパティ名中の ] を遁走するにゃん（%property[...] の括弧を壞さにゃいためにゃ）
/-- プロプリエタース名中の ] を遁走するにゃん（%property[...] の括弧を壞さにゃいためにゃ） -/
def escapePropNomen (s : String) : String := s.replace "]" "\\]"

def Proprietas.toString : Proprietas → String
  -- system time
  | .systemAnnus               => "system.year"
  | .systemMensis              => "system.month"
  | .systemDies                => "system.day"
  | .systemHora                => "system.hour"
  | .systemMinutum             => "system.minute"
  | .systemSecundum            => "system.second"
  | .systemMillisecundum       => "system.millisecond"
  | .systemDiesSeptimanus      => "system.dayofweek"
  | .systemCursorPositio       => "system.cursor.pos"
  -- system OS
  | .systemOsTypus             => "system.os.type"
  | .systemOsNomen             => "system.os.name"
  | .systemOsVersione          => "system.os.version"
  | .systemOsCompilatio        => "system.os.build"
  | .systemOsParensTypus       => "system.os.parenttype"
  | .systemOsParensNomen       => "system.os.parentname"
  -- system CPU
  | .systemCpuOnus             => "system.cpu.load"
  | .systemCpuNumerus          => "system.cpu.num"
  | .systemCpuVendor           => "system.cpu.vendor"
  | .systemCpuNomen            => "system.cpu.name"
  | .systemCpuPulsus           => "system.cpu.clock"
  | .systemCpuFunctiones       => "system.cpu.features"
  -- system memory
  | .systemMemoriaOnus         => "system.memory.load"
  | .systemMemoriaPhysicaTota  => "system.memory.phyt"
  | .systemMemoriaPhysicaLibera => "system.memory.phya"
  -- baseware
  | .basewereVersione          => "baseware.version"
  | .basewereNomen             => "baseware.name"
  -- ghostlist
  | .ghostlistNumerus          => "ghostlist.count"
  | .ghostlistNomen  n p       => s!"ghostlist({escapePropNomen n}).{p.toString}"
  | .ghostlistIndex  i p       => s!"ghostlist.index({i}).{p.toString}"
  | .ghostlistCurrent  p       => s!"ghostlist.current.{p.toString}"
  -- activeghostlist
  | .activeghostlistNomen  n p  => s!"activeghostlist({escapePropNomen n}).{p.toString}"
  | .activeghostlistIndex  i p  => s!"activeghostlist.index({i}).{p.toString}"
  | .activeghostlistCurrent  p  => s!"activeghostlist.current.{p.toString}"
  -- currentghost
  | .currentghostGenerica p    => s!"currentghost.{p.toString}"
  | .currentghostStatus        => "currentghost.status"
  | .currentghostScopusNumerus => "currentghost.scope.count"
  | .currentghostScopus s p    => s!"currentghost.scope({s}).{p.toString}"
  -- currentghost shelllist
  | .currentghostShelllistNumerus        => "currentghost.shelllist.count"
  | .currentghostShelllistNomen  n p     => s!"currentghost.shelllist({escapePropNomen n}).{p.toString}"
  | .currentghostShelllistIndex  i p     => s!"currentghost.shelllist.index({i}).{p.toString}"
  | .currentghostShelllistCurrent  p     => s!"currentghost.shelllist.current.{p.toString}"
  -- currentghost balloon
  | .currentghostBullaeNumerus           => "currentghost.balloon.count"
  | .currentghostBullaeGenerica p        => s!"currentghost.balloon.{p.toString}"
  | .currentghostBullaeScopusNumerus s   => s!"currentghost.balloon.scope({s}).count"
  | .currentghostBullaeScopus s p        => s!"currentghost.balloon.scope({s}).{p.toString}"
  -- currentghost cursors
  | .currentghostCursorMus               => "currentghost.mousecursor"
  | .currentghostCursorTextus            => "currentghost.mousecursor.text"
  | .currentghostCursorExspecto          => "currentghost.mousecursor.wait"
  | .currentghostCursorManus             => "currentghost.mousecursor.hand"
  | .currentghostCursorPrehendo          => "currentghost.mousecursor.grip"
  | .currentghostCursorSagitta           => "currentghost.mousecursor.arrow"
  | .currentghostBullaeCursorMus         => "currentghost.balloon.mousecursor"
  | .currentghostBullaeCursorTextus      => "currentghost.balloon.mousecursor.text"
  | .currentghostBullaeCursorExspecto    => "currentghost.balloon.mousecursor.wait"
  | .currentghostBullaeCursorSagitta     => "currentghost.balloon.mousecursor.arrow"
  -- currentghost seriko
  | .currentghostSerikoSurfacesOmnes     => "currentghost.seriko.surfacelist.all"
  | .currentghostSerikoSurfacesDefinitae => "currentghost.seriko.surfacelist.defined"
  -- balloonlist
  | .balloonlistNumerus        => "balloonlist.count"
  | .balloonlistNomen  n p     => s!"balloonlist({escapePropNomen n}).{p.toString}"
  | .balloonlistIndex  i p     => s!"balloonlist.index({i}).{p.toString}"
  -- headlinelist
  | .headlinelistNumerus       => "headlinelist.count"
  | .headlinelistNomen  n p    => s!"headlinelist({escapePropNomen n}).{p.toString}"
  | .headlinelistIndex  i p    => s!"headlinelist.index({i}).{p.toString}"
  -- pluginlist
  | .pluginlistNumerus         => "pluginlist.count"
  | .pluginlistNomen  n p      => s!"pluginlist({escapePropNomen n}).{p.toString}"
  | .pluginlistIndex  i p      => s!"pluginlist.index({i}).{p.toString}"
  -- history
  | .historyGhostNumerus       => "history.ghost.count"
  | .historyGhostNomen  n p    => s!"history.ghost({escapePropNomen n}).{p.toString}"
  | .historyGhostIndex  i p    => s!"history.ghost.index({i}).{p.toString}"
  | .historyBullaeNumerus      => "history.balloon.count"
  | .historyBullaeNomen  n p   => s!"history.balloon({escapePropNomen n}).{p.toString}"
  | .historyBullaeIndex  i p   => s!"history.balloon.index({i}).{p.toString}"
  | .historyHeadlineNumerus    => "history.headline.count"
  | .historyHeadlineNomen  n p => s!"history.headline({escapePropNomen n}).{p.toString}"
  | .historyHeadlineIndex  i p => s!"history.headline.index({i}).{p.toString}"
  | .historyPluginNumerus      => "history.plugin.count"
  | .historyPluginNomen  n p   => s!"history.plugin({escapePropNomen n}).{p.toString}"
  | .historyPluginIndex  i p   => s!"history.plugin.index({i}).{p.toString}"
  -- rateofuselist
  | .rateofuselistNomen  n p   => s!"rateofuselist({escapePropNomen n}).{p.toString}"
  | .rateofuselistIndex  i p   => s!"rateofuselist.index({i}).{p.toString}"
  -- SHIORI 變數
  | .shioriVariabilis nomen    => s!"shiori.{nomen}"

-- ════════════════════════════════════════════════════
--  サブプロパティ SakuraScript 名 (Abbreviaturae Subproprietatis)
-- ════════════════════════════════════════════════════

-- ジェネリックサブプロパティの SakuraScript 名にゃん♪
-- `%property[ghostlist "foo" .name]` のやうに使ふにゃ
namespace ProprietasGenerica
abbrev name       : ProprietasGenerica := .nomen
abbrev sakuraname : ProprietasGenerica := .sakuraNomen
abbrev keroname   : ProprietasGenerica := .keroNomen
abbrev craftmanw  : ProprietasGenerica := .fabricator
abbrev craftmanurl: ProprietasGenerica := .fabricatorNexus
abbrev path       : ProprietasGenerica := .via
abbrev thumbnail  : ProprietasGenerica := .imago
abbrev homeurl    : ProprietasGenerica := .nexusAedis
abbrev username   : ProprietasGenerica := .nomenUtentis
-- index, icon は既にコンストラクタ名と一致するため省略にゃ（.index, .icon で使へるにゃ）
end ProprietasGenerica

-- スコープサブプロパティの SakuraScript 名にゃん♪
namespace ProprietasScopus
abbrev surface.num           : ProprietasScopus := .superficiesNum
abbrev surface.x             : ProprietasScopus := .superficiesX
abbrev surface.y             : ProprietasScopus := .superficiesY
abbrev seriko.defaultsurface : ProprietasScopus := .serikoSuperficiesPraef
-- x, y, rect, name は既にコンストラクタ名で使へるにゃ
end ProprietasScopus

-- バルーンスコープサブプロパティの SakuraScript 名にゃん♪
namespace ProprietasBullaeScopus
abbrev num             : ProprietasBullaeScopus := .numerus
abbrev validwidth      : ProprietasBullaeScopus := .latitudo
abbrev validwidth.initial : ProprietasBullaeScopus := .latitudoInitialis
abbrev validheight     : ProprietasBullaeScopus := .altitudo
abbrev validheight.initial : ProprietasBullaeScopus := .altitudoInitialis
abbrev lines           : ProprietasBullaeScopus := .linea
abbrev lines.initial   : ProprietasBullaeScopus := .lineaInitialis
abbrev basepos.x       : ProprietasBullaeScopus := .basePosX
abbrev basepos.y       : ProprietasBullaeScopus := .basePosY
abbrev char_width      : ProprietasBullaeScopus := .latitudoCharacteris
end ProprietasBullaeScopus

-- rateofuse サブプロパティの SakuraScript 名にゃん♪
namespace ProprietasRateOfUse
abbrev name       : ProprietasRateOfUse := .nomen
abbrev sakuraname : ProprietasRateOfUse := .sakuraNomen
abbrev keroname   : ProprietasRateOfUse := .keroNomen
abbrev boottime   : ProprietasRateOfUse := .numerusStartuporum
abbrev bootminute : ProprietasRateOfUse := .minutae
abbrev percent    : ProprietasRateOfUse := .proportio
end ProprietasRateOfUse

-- ════════════════════════════════════════════════════
--  Proprietas SakuraScript 名 (Abbreviaturae Proprietatis)
-- ════════════════════════════════════════════════════

-- SakuraScript プロパティ名で Proprietas を參照するための略稱にゃん♪
-- `open Signaculum.Sakura.Proprietas in system.year` で使へるにゃ
namespace Proprietas
-- ── system.* ──
abbrev system.year           : Proprietas := .systemAnnus
abbrev system.month          : Proprietas := .systemMensis
abbrev system.day            : Proprietas := .systemDies
abbrev system.hour           : Proprietas := .systemHora
abbrev system.minute         : Proprietas := .systemMinutum
abbrev system.second         : Proprietas := .systemSecundum
abbrev system.millisecond    : Proprietas := .systemMillisecundum
abbrev system.dayofweek      : Proprietas := .systemDiesSeptimanus
abbrev system.cursor.pos     : Proprietas := .systemCursorPositio
abbrev system.os.type        : Proprietas := .systemOsTypus
abbrev system.os.name        : Proprietas := .systemOsNomen
abbrev system.os.version     : Proprietas := .systemOsVersione
abbrev system.os.build       : Proprietas := .systemOsCompilatio
abbrev system.os.parenttype  : Proprietas := .systemOsParensTypus
abbrev system.os.parentname  : Proprietas := .systemOsParensNomen
abbrev system.cpu.load       : Proprietas := .systemCpuOnus
abbrev system.cpu.num        : Proprietas := .systemCpuNumerus
abbrev system.cpu.vendor     : Proprietas := .systemCpuVendor
abbrev system.cpu.name       : Proprietas := .systemCpuNomen
abbrev system.cpu.clock      : Proprietas := .systemCpuPulsus
abbrev system.cpu.features   : Proprietas := .systemCpuFunctiones
abbrev system.memory.load    : Proprietas := .systemMemoriaOnus
abbrev system.memory.phyt    : Proprietas := .systemMemoriaPhysicaTota
abbrev system.memory.phya    : Proprietas := .systemMemoriaPhysicaLibera
-- ── baseware.* ──
abbrev baseware.version      : Proprietas := .basewereVersione
abbrev baseware.name         : Proprietas := .basewereNomen
-- ── ghostlist ──
abbrev ghostlist.count       : Proprietas := .ghostlistNumerus
def ghostlist (nomen : String) (p : ProprietasGenerica) : Proprietas := .ghostlistNomen nomen p
def ghostlist.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .ghostlistIndex i p
def ghostlist.current (p : ProprietasGenerica) : Proprietas := .ghostlistCurrent p
-- ── activeghostlist ──
def activeghostlist (nomen : String) (p : ProprietasGenerica) : Proprietas := .activeghostlistNomen nomen p
def activeghostlist.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .activeghostlistIndex i p
def activeghostlist.current (p : ProprietasGenerica) : Proprietas := .activeghostlistCurrent p
-- ── currentghost ──
abbrev currentghost.status   : Proprietas := .currentghostStatus
abbrev currentghost.scope.count : Proprietas := .currentghostScopusNumerus
def currentghost (p : ProprietasGenerica) : Proprietas := .currentghostGenerica p
def currentghost.scope (scopus : Nat) (p : ProprietasScopus) : Proprietas := .currentghostScopus scopus p
-- currentghost.shelllist
abbrev currentghost.shelllist.count : Proprietas := .currentghostShelllistNumerus
def currentghost.shelllist (nomen : String) (p : ProprietasGenerica) : Proprietas := .currentghostShelllistNomen nomen p
def currentghost.shelllist.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .currentghostShelllistIndex i p
def currentghost.shelllist.current (p : ProprietasGenerica) : Proprietas := .currentghostShelllistCurrent p
-- currentghost.balloon
abbrev currentghost.balloon.count : Proprietas := .currentghostBullaeNumerus
def currentghost.balloon (p : ProprietasGenerica) : Proprietas := .currentghostBullaeGenerica p
def currentghost.balloon.scope (scopus : Nat) (p : ProprietasBullaeScopus) : Proprietas := .currentghostBullaeScopus scopus p
def currentghost.balloon.scope.count (scopus : Nat) : Proprietas := .currentghostBullaeScopusNumerus scopus
-- currentghost.mousecursor
abbrev currentghost.mousecursor       : Proprietas := .currentghostCursorMus
abbrev currentghost.mousecursor.text  : Proprietas := .currentghostCursorTextus
abbrev currentghost.mousecursor.wait  : Proprietas := .currentghostCursorExspecto
abbrev currentghost.mousecursor.hand  : Proprietas := .currentghostCursorManus
abbrev currentghost.mousecursor.grip  : Proprietas := .currentghostCursorPrehendo
abbrev currentghost.mousecursor.arrow : Proprietas := .currentghostCursorSagitta
abbrev currentghost.balloon.mousecursor       : Proprietas := .currentghostBullaeCursorMus
abbrev currentghost.balloon.mousecursor.text  : Proprietas := .currentghostBullaeCursorTextus
abbrev currentghost.balloon.mousecursor.wait  : Proprietas := .currentghostBullaeCursorExspecto
abbrev currentghost.balloon.mousecursor.arrow : Proprietas := .currentghostBullaeCursorSagitta
-- currentghost.seriko
abbrev currentghost.seriko.surfacelist.all     : Proprietas := .currentghostSerikoSurfacesOmnes
abbrev currentghost.seriko.surfacelist.defined : Proprietas := .currentghostSerikoSurfacesDefinitae
-- ── balloonlist ──
abbrev balloonlist.count : Proprietas := .balloonlistNumerus
def balloonlist (nomen : String) (p : ProprietasGenerica) : Proprietas := .balloonlistNomen nomen p
def balloonlist.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .balloonlistIndex i p
-- ── headlinelist ──
abbrev headlinelist.count : Proprietas := .headlinelistNumerus
def headlinelist (nomen : String) (p : ProprietasGenerica) : Proprietas := .headlinelistNomen nomen p
def headlinelist.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .headlinelistIndex i p
-- ── pluginlist ──
abbrev pluginlist.count : Proprietas := .pluginlistNumerus
def pluginlist (nomen : String) (p : ProprietasGenerica) : Proprietas := .pluginlistNomen nomen p
def pluginlist.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .pluginlistIndex i p
-- ── history.* ──
abbrev history.ghost.count    : Proprietas := .historyGhostNumerus
def history.ghost (nomen : String) (p : ProprietasGenerica) : Proprietas := .historyGhostNomen nomen p
def history.ghost.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .historyGhostIndex i p
abbrev history.balloon.count  : Proprietas := .historyBullaeNumerus
def history.balloon (nomen : String) (p : ProprietasGenerica) : Proprietas := .historyBullaeNomen nomen p
def history.balloon.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .historyBullaeIndex i p
abbrev history.headline.count : Proprietas := .historyHeadlineNumerus
def history.headline (nomen : String) (p : ProprietasGenerica) : Proprietas := .historyHeadlineNomen nomen p
def history.headline.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .historyHeadlineIndex i p
abbrev history.plugin.count   : Proprietas := .historyPluginNumerus
def history.plugin (nomen : String) (p : ProprietasGenerica) : Proprietas := .historyPluginNomen nomen p
def history.plugin.index (i : Nat) (p : ProprietasGenerica) : Proprietas := .historyPluginIndex i p
-- ── rateofuselist ──
def rateofuselist (nomen : String) (p : ProprietasRateOfUse) : Proprietas := .rateofuselistNomen nomen p
def rateofuselist.index (i : Nat) (p : ProprietasRateOfUse) : Proprietas := .rateofuselistIndex i p
-- ── shiori ──
def shiori (nomen : String) : Proprietas := .shioriVariabilis nomen
end Proprietas

/-- ダイアローグス・モードにゃん。`aperiDialogum` に渡すにゃ。
    - `aperire`     : ファイルを開く（`open`）
    - `servare`     : ファイルを保存（`save`）
    - `directorium` : フォルダ選擇（`folder`）
    - `color`       : 色選擇（`color`） -/
inductive ModusDialogi where
  | aperire | servare | directorium | color
  deriving Repr

def ModusDialogi.toString : ModusDialogi → String
  | .aperire     => "open"
  | .servare     => "save"
  | .directorium => "folder"
  | .color       => "color"

/-- テキスト入力ボックスのモードにゃん。`aperiInputum` に渡すにゃ。
    - `simplex`  : 通常入力ボックス（`inputbox`）
    - `sigillum` : パスワード入力（`passwordinput`） -/
inductive ModusInputiTextus where
  | simplex | sigillum
  deriving Repr

def ModusInputiTextus.toString : ModusInputiTextus → String
  | .simplex  => "inputbox"
  | .sigillum => "passwordinput"

/-- 數値入力ボックスのモードにゃん。`aperiInputumNumerale` に渡すにゃ。
    - `dies`   : 日付入力（`dateinput`）
    - `tempus` : 時刻入力（`timeinput`）
    - `gradus` : スライダー入力（`sliderinput`） -/
inductive ModusInputiNumeralis where
  | dies | tempus | gradus
  deriving Repr

def ModusInputiNumeralis.toString : ModusInputiNumeralis → String
  | .dies   => "dateinput"
  | .tempus => "timeinput"
  | .gradus => "sliderinput"

/-- 閏年かどうかにゃん。4で割り切れて、100で割り切れないか、400で割り切れるにゃ -/
def estBissextilis (annus : Nat) : Bool :=
  annus % 4 == 0 && (annus % 100 != 0 || annus % 400 == 0)

/-- その年のその月が何日まであるかにゃん -/
def diesInMense (annus mensis : Nat) : Nat :=
  match mensis with
  | 1 => 31 | 2 => if estBissextilis annus then 29 else 28
  | 3 => 31 | 4 => 30 | 5 => 31 | 6 => 30
  | 7 => 31 | 8 => 31 | 9 => 30 | 10 => 31
  | 11 => 30 | 12 => 31 | _ => 0

end Signaculum.Sakura
