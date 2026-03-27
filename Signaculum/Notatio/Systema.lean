-- Signaculum.Notatio.Systema
-- イヴェントゥム・音響・動畫・呼出・實行・變更の構文規則にゃん♪

import Signaculum.Notatio.Categoria
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio

open Lean Signaculum.Sakura

-- 事象にゃん
-- str 形: 文字列リテラルを直接 Sakura 關數に渡すにゃ
-- ident 形: 構文を ident term* で受け取り term_elab ノードを直接構築して TermElabM に委ねるにゃん

-- term_elab ノードを直接組み立てるにゃん
-- kind: ノードカインドにゃ、kw: キーワードアトムにゃ
-- extraArgs: ms/rep 等の追加引數にゃ、ident: 關數識別子にゃ、argRaws: 引數配列にゃ
private def mkSignalNode (kind : SyntaxNodeKind) (kw : String)
    (extraArgs : Array Syntax) (identStx : Syntax) (argRaws : Array Syntax) : Syntax :=
  -- identStx の位置情報を外側ノードに継承してエラー位置をタグ行に帰着させるにゃん
  Lean.Syntax.node identStx.getHeadInfo kind
    (#[Lean.Syntax.atom .none kw] ++ extraArgs ++
     #[identStx, Lean.Syntax.node .none nullKind argRaws])

syntax "\\!" "[raise," str "]" : sakuraSignum
macro_rules | `(expandSignum \![raise, $e:str]) => `(Signaculum.Sakura.excita $e)

syntax "\\!" "[raise," ident (term:max)* "]" : sakuraSignum
macro_rules
| `(expandSignum \![raise, $f:ident $args:term*]) =>
  return mkSignalNode `excitaSyntax "excita" #[] f.raw (args.map (·.raw))

syntax "\\!" "[raise," "(" term ")" (term:max)* "]" : sakuraSignum
macro_rules | `(expandSignum \![raise, ($lam:term) $args:term*]) => `(excita ($lam) $args*)

syntax "\\!" "[embed," str "]" : sakuraSignum
macro_rules | `(expandSignum \![embed, $e:str]) => `(Signaculum.Sakura.insere $e)

syntax "\\!" "[embed," ident (term:max)* "]" : sakuraSignum
macro_rules
| `(expandSignum \![embed, $f:ident $args:term*]) =>
  return mkSignalNode `insereSyntax "insere" #[] f.raw (args.map (·.raw))

syntax "\\!" "[embed," "(" term ")" (term:max)* "]" : sakuraSignum
macro_rules | `(expandSignum \![embed, ($lam:term) $args:term*]) => `(insere ($lam) $args*)

syntax "\\!" "[notify," str "]" : sakuraSignum
macro_rules | `(expandSignum \![notify, $e:str]) => `(Signaculum.Sakura.notifica $e)

syntax "\\!" "[notify," ident (term:max)* "]" : sakuraSignum
macro_rules
| `(expandSignum \![notify, $f:ident $args:term*]) =>
  return mkSignalNode `notificaSyntax "notifica" #[] f.raw (args.map (·.raw))

syntax "\\!" "[notify," "(" term ")" (term:max)* "]" : sakuraSignum
macro_rules | `(expandSignum \![notify, ($lam:term) $args:term*]) => `(notifica ($lam) $args*)

-- タイマーにゃん
syntax "\\!" "[timerraise," term "," term "," str "]" : sakuraSignum
macro_rules
| `(expandSignum \![timerraise, $ms, $rep, $e:str]) =>
  `(Signaculum.Sakura.excitaPostTempus $ms $rep $e)

syntax "\\!" "[timerraise," term "," term "," ident (term:max)* "]" : sakuraSignum
macro_rules
| `(expandSignum \![timerraise, $ms, $rep, $f:ident $args:term*]) =>
  return mkSignalNode `excitaPostTempusSyntax "excitaPostTempus"
    #[ms.raw, rep.raw] f.raw (args.map (·.raw))

syntax "\\!" "[timerraise," term "," term "," "(" term ")" (term:max)* "]" : sakuraSignum
macro_rules
| `(expandSignum \![timerraise, $ms, $rep, ($lam:term) $args:term*]) =>
  `(excitaPostTempus $ms $rep ($lam) $args*)

syntax "\\!" "[timernotify," term "," term "," str "]" : sakuraSignum
macro_rules
| `(expandSignum \![timernotify, $ms, $rep, $e:str]) =>
  `(Signaculum.Sakura.notificaPostTempus $ms $rep $e)

syntax "\\!" "[timernotify," term "," term "," ident (term:max)* "]" : sakuraSignum
macro_rules
| `(expandSignum \![timernotify, $ms, $rep, $f:ident $args:term*]) =>
  return mkSignalNode `notificaPostTempusSyntax "notificaPostTempus"
    #[ms.raw, rep.raw] f.raw (args.map (·.raw))

syntax "\\!" "[timernotify," term "," term "," "(" term ")" (term:max)* "]" : sakuraSignum
macro_rules
| `(expandSignum \![timernotify, $ms, $rep, ($lam:term) $args:term*]) =>
  `(notificaPostTempus $ms $rep ($lam) $args*)



-- 音響にゃん
syntax "\\_v" "[" str "]" : sakuraSignum
macro_rules | `(expandSignum \_v[$s]) => `(Signaculum.Sakura.sonus $s)

syntax "\\8" "[" str "]" : sakuraSignum
macro_rules | `(expandSignum \8[$s]) => `(Signaculum.Sakura.sonus8 $s)

syntax "\\!" "[sound,play," str "]" : sakuraSignum
macro_rules | `(expandSignum \![sound,play, $s]) => `(Signaculum.Sakura.sonusPulsus $s)

syntax "\\!" "[sound,loop," str "]" : sakuraSignum
macro_rules | `(expandSignum \![sound,loop, $s]) => `(Signaculum.Sakura.sonusOrbitans $s)

syntax "\\!" "[sound,stop," str "]" : sakuraSignum
macro_rules | `(expandSignum \![sound,stop, $s]) => `(Signaculum.Sakura.sonusInterrumpit $s)

syntax "\\!" "[sound,pause," str "]" : sakuraSignum
macro_rules | `(expandSignum \![sound,pause, $s]) => `(Signaculum.Sakura.sonusPausat $s)

syntax "\\!" "[sound,resume," str "]" : sakuraSignum
macro_rules | `(expandSignum \![sound,resume, $s]) => `(Signaculum.Sakura.sonusContinuat $s)

syntax "\\!" "[sound,wait]" : sakuraSignum
macro_rules | `(expandSignum \![sound,wait]) => `(Signaculum.Sakura.expectaSonumPulsus)

-- 動畫にゃん
syntax "\\!" "[anim,start," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![anim,start, $s, $i]) => `(Signaculum.Sakura.animaIncepit $s $i)

syntax "\\!" "[anim,stop," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![anim,stop, $s, $i]) => `(Signaculum.Sakura.animaDesinit $s $i)

syntax "\\!" "[anim,pause," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![anim,pause, $s, $i]) => `(Signaculum.Sakura.animaPausat $s $i)

syntax "\\!" "[anim,resume," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![anim,resume, $s, $i]) => `(Signaculum.Sakura.animaContinuat $s $i)

syntax "\\!" "[anim,clear," term "," term "]" : sakuraSignum
macro_rules | `(expandSignum \![anim,clear, $s, $i]) => `(Signaculum.Sakura.animaPurgat $s $i)

-- 非同期起動にゃん（term 丸ごと渡すにゃん）
syntax "\\!" "[async," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![async, $app:term]) => do
  `(liftM (Signaculum.spawnaMunitus do
      let _st ← Signaculum.Sakura.currere $app
      Signaculum.Sstp.mitteSstpScriptum _st.scriptum))

-- 呼出にゃん
syntax "\\!" "[call,shiori," str "]" : sakuraSignum
macro_rules | `(expandSignum \![call,shiori, $e]) => `(Signaculum.Sakura.vocaShiori $e)

syntax "\\!" "[call,saori," str "," str "]" : sakuraSignum
macro_rules | `(expandSignum \![call,saori, $d, $f]) => `(Signaculum.Sakura.vocaSaori $d $f)

-- 変更にゃん
syntax "\\!" "[change,ghost," str "]" : sakuraSignum
macro_rules | `(expandSignum \![change,ghost, $n]) => `(Signaculum.Sakura.mutaGhostNomen $n)

syntax "\\!" "[change,shell," str "]" : sakuraSignum
macro_rules | `(expandSignum \![change,shell, $n]) => `(Signaculum.Sakura.mutaShell $n)

syntax "\\!" "[change,balloon," str "]" : sakuraSignum
macro_rules | `(expandSignum \![change,balloon, $n]) => `(Signaculum.Sakura.mutaBullam $n)

-- 更新にゃん
syntax "\\!" "[updatebymyself]" : sakuraSignum
macro_rules | `(expandSignum \![updatebymyself]) => `(Signaculum.Sakura.renovaSeIpsum)

syntax "\\!" "[vanishbymyself]" : sakuraSignum
macro_rules | `(expandSignum \![vanishbymyself]) => `(Signaculum.Sakura.evanesceSeIpsum)

syntax "\\!" "[executesntp]" : sakuraSignum
macro_rules | `(expandSignum \![executesntp]) => `(Signaculum.Sakura.executaSNTP)

syntax "\\!" "[reloadsurface]" : sakuraSignum
macro_rules | `(expandSignum \![reloadsurface]) => `(Signaculum.Sakura.renovaSuperficiem)

syntax "\\!" "[reload," term "]" : sakuraSignum
macro_rules | `(expandSignum \![reload, $s]) => `(Signaculum.Sakura.renova $s)

-- 荷卸にゃん
syntax "\\!" "[unload,shiori]" : sakuraSignum
macro_rules | `(expandSignum \![unload,shiori]) => `(Signaculum.Sakura.expelleShiori)

syntax "\\!" "[load,shiori]" : sakuraSignum
macro_rules | `(expandSignum \![load,shiori]) => `(Signaculum.Sakura.oneraSHIORI)

syntax "\\!" "[unload,makoto]" : sakuraSignum
macro_rules | `(expandSignum \![unload,makoto]) => `(Signaculum.Sakura.expelleMakoto)

syntax "\\!" "[load,makoto]" : sakuraSignum
macro_rules | `(expandSignum \![load,makoto]) => `(Signaculum.Sakura.oneraMakoto)

-- 着替・效果にゃん
syntax "\\!" "[bind," str "," str "," str "]" : sakuraSignum
macro_rules | `(expandSignum \![bind, $c, $p, $v]) => `(Signaculum.Sakura.nexaDressup $c $p $v)

syntax "\\!" "[effect," str "," term "," str "]" : sakuraSignum
macro_rules | `(expandSignum \![effect, $p, $s, $r]) => `(Signaculum.Sakura.applicaEffectum $p $s $r)

-- 郵便にゃん
syntax "\\!" "[biff," str "]" : sakuraSignum
macro_rules | `(expandSignum \![biff, $a]) => `(Signaculum.Sakura.exploraPostam $a)

-- 設定システムにゃん
syntax "\\!" "[set,property," term "," str "]" : sakuraSignum
macro_rules | `(expandSignum \![set,property, $p, $v]) => `(Signaculum.Sakura.configuraProprietatem $p $v)

-- 入力ボックスにゃん（\![open,inputbox,callback,timeout,title] / \![open,inputbox,callback,title]）
-- コールバックは ident 形・ラムダ形どちらも受け付けるにゃん。タイトルは str/ident/任意 term でよいにゃ

-- タイムアウトあり
syntax "\\!" "[open,inputbox," term:max "," term "," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![open,inputbox, ($lam:term), $_t, $title]) =>
  `(aperiInputum .simplex ($lam) $title)
| `(expandSignum \![open,inputbox, $f:ident, $_t, $title]) =>
  `(aperiInputum .simplex $f $title "")

-- タイムアウトなし
syntax "\\!" "[open,inputbox," term:max "," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![open,inputbox, ($lam:term), $title]) =>
  `(aperiInputum .simplex ($lam) $title)
| `(expandSignum \![open,inputbox, $f:ident, $title]) =>
  `(aperiInputum .simplex $f $title "")

-- パスワード入力にゃん（ラムダ形・ident 形どちらも受け付けるにゃ）
-- タイムアウトあり
syntax "\\!" "[open,passwordinput," term:max "," term "," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![open,passwordinput, ($lam:term), $_t, $title]) =>
  `(aperiInputum .sigillum ($lam) $title)
| `(expandSignum \![open,passwordinput, $f:ident, $_t, $title]) =>
  `(aperiInputum .sigillum $f $title "")

-- タイムアウトなし
syntax "\\!" "[open,passwordinput," term:max "," term "]" : sakuraSignum
macro_rules
| `(expandSignum \![open,passwordinput, ($lam:term), $title]) =>
  `(aperiInputum .sigillum ($lam) $title)
| `(expandSignum \![open,passwordinput, $f:ident, $title]) =>
  `(aperiInputum .sigillum $f $title "")

end Signaculum.Notatio
