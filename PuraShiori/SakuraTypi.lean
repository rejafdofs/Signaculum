-- PuraShiori.SakuraTypi
-- 型定義専用ぢゃ。他の PuraShiori ファスキクルスへの インポルトなしにゃん♪

namespace PuraShiori

/-- サクラスクリプト構築モナドにゃん。
    文字列を蓄積する StateT で、基底モナド m を自由に選べるにゃ。
    純粹な構築には `SakuraPura`、IO が要る時は `SakuraIO` を使ふにゃん -/
abbrev SakuraM (m : Type → Type) [Monad m] (α : Type) :=
  StateT String m α

/-- IO 附きサクラスクリプト・モナドにゃん。お嬢樣の處理器はこれを使ふにゃ -/
abbrev SakuraIO (α : Type) := SakuraM IO α

/-- 純粹サクラスクリプト・モナドにゃん。副作用が要らにゃい時に使ふにゃ -/
abbrev SakuraPura (α : Type) := SakuraM Id α

namespace Sakura

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
    `xor`=XOR 描畫、`alpha`=α合成、`normal`=通常、`praefinitus`=既定にゃ -/
inductive MethodusMarci where
  | xor
  | alpha
  | normal
  | praefinitus
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
  | .xor        => "xor"
  | .alpha      => "alpha"
  | .normal     => "normal"
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

/-- 色の指定方法にゃん。
    - `rgb r g b`  : RGB 各 0〜255（`\f[color,...]` で r,g,b に展開されるにゃ）
    - `hex s`      : 16 進數文字列 "RRGGBB" または "#RRGGBB" にゃ
    - `nomen n`    : "red" "white" など名前付き色にゃ
    - `nullus`     : "none"（影色を無效化するときに使ふにゃ）-/
inductive Coloris where
  | rgb   (r g b : Nat)
  | hex   (s : String)
  | nomen (n : String)
  | nullus
  deriving Repr

def Coloris.toString : Coloris → String
  | .rgb r g b => s!"{r},{g},{b}"
  | .hex s     => s
  | .nomen n   => n
  | .nullus    => "none"

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
def OptionesSoni.cumVolumine (o : OptionesSoni) (n : Nat) : OptionesSoni :=
  { o with volumen := some n }

/-- 左右バランスを設定するにゃん（−100〜100、0 が中央）にゃ -/
def OptionesSoni.cumLibramento (o : OptionesSoni) (n : Int) : OptionesSoni :=
  { o with libramentum := some n }

/-- 再生速度を設定するにゃん（1〜10000、100 が等速）にゃ -/
def OptionesSoni.cumCursu (o : OptionesSoni) (n : Nat) : OptionesSoni :=
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
  colorisInitialis : Option (Nat × Nat × Nat) := none
  deriving Repr

def OptionesDialogi.toString (o : OptionesDialogi) : String :=
  let ps : List String := []
  let ps := match o.titulus          with | none => ps | some s => ps ++ [s!"--title={s}"]
  let ps := match o.signum           with | none => ps | some s => ps ++ [s!"--id={s}"]
  let ps := match o.directum         with | none => ps | some s => ps ++ [s!"--dir={s}"]
  let ps := match o.filtrum          with | none => ps | some s => ps ++ [s!"--filter={s}"]
  let ps := match o.nomen            with | none => ps | some s => ps ++ [s!"--name={s}"]
  let ps := match o.extensio         with | none => ps | some s => ps ++ [s!"--ext={s}"]
  let ps := match o.colorisInitialis with | none => ps | some (r, g, b) => ps ++ [s!"--color={r} {g} {b}"]
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

/-- 初期色を RGB で設定するにゃん（色選擇ダイアローグス専用にゃ） -/
def OptionesDialogi.cumColore (o : OptionesDialogi) (r g b : Nat) : OptionesDialogi :=
  { o with colorisInitialis := some (r, g, b) }

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

/-- `\\![open,X]`（追加引數なし）で開けるウィンドウの種類にゃん。
    `aperi` 關數に渡すにゃ。
    - `console`              : コンソール
    - `arcaCommunicationis`  : コミュニケートボックス
    - `arcaDoctrinae`        : 教育ボックス
    - `arcaFabricationis`    : 作成ボックス
    - `exploratorFantasmatis`: ゴースト探索ダイアローグス
    - `exploratorTegumenti`  : シェル探索ダイアローグス
    - `exploratorBullae`     : 吹出し探索ダイアローグス
    - `probatioSuperficiei`  : 表面テスト
    - `exploratorHeadlineae` : ヘッドラインセンサー探索
    - `exploratorModulorum`  : プラグイン探索
    - `graphumUsus`          : 使用率グラフ
    - `graphumUsusBullae`    : 吹出し使用率グラフ
    - `graphumUsusTotal`     : 總合使用率グラフ
    - `calendarium`          : カレンダー
    - `nuntium`              : メッセンジャー
    - `readme`               : README
    - `conditiones`          : 利用規約
    - `graphumAI`            : AI グラフ
    - `palettaDeveloper`     : 開發者パレット
    - `petitioShiori`        : SHIORI リクエストビューワー
    - `exploratorDressupi`   : 着せ替え探索 -/
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
private def escapePropNomen (s : String) : String := s.replace "]" "\\]"

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

end Sakura

end PuraShiori
