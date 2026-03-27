-- Signaculum.Sakura.Fundamentum
-- 基底発出プリミティウィ。emitte / evade* / loqui / crudus にゃん♪

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- サクラスクリプトの斷片を發出するにゃん。
    これが全ての土臺にゃ -/
def emitte {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit :=
  modify fun st => { st with scriptum := st.scriptum ++ s }

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

/-- 文字列を表示するにゃん。
    \\、%、] の特殊文字は自動的に遁走されるにゃ。
    生のサクラスクリプトを發出したい時は `crudus` を使ふにゃん -/
def loqui {m : Type → Type} [Monad m] (s : String) : SakuraM m Unit :=
  emitte (evadeTextus s)

/-- 任意の SakuraScript 標籤を直接發出する（高度にゃ使用向け）にゃん -/
def crudus {m : Type → Type} [Monad m] (signum : String) : SakuraM m Unit :=
  emitte signum

end Signaculum.Sakura
