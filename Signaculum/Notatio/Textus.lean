-- Signaculum.Notatio.Textus
-- テクストゥス表示・範圍制御・待機・選擇肢・基本制御の構文規則にゃん♪

import Signaculum.Notatio.Categoria
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio

open Lean Signaculum.Sakura

-- ════════════════════════════════════════════════════
--  範圍制御 (Imperium Scopi)
-- ════════════════════════════════════════════════════

syntax "\\h" : sakuraSignum
macro_rules | `(expandSignum \h) => `(Signaculum.Sakura.sakura)

syntax "\\u" : sakuraSignum
macro_rules | `(expandSignum \u) => `(Signaculum.Sakura.kero)

syntax "\\p" "[" num "]" : sakuraSignum
macro_rules | `(expandSignum \p[$n]) => `(Signaculum.Sakura.persona $n)

-- ════════════════════════════════════════════════════
--  表面制御 (Imperium Superficiei)
-- ════════════════════════════════════════════════════

syntax "\\s" "[" num "]" : sakuraSignum
macro_rules | `(expandSignum \s[$n]) => `(Signaculum.Sakura.superficies $n)

syntax "\\s" "[-1]" : sakuraSignum
macro_rules | `(expandSignum \s[-1]) => `(Signaculum.Sakura.superficiesAbsconde)

syntax "\\i" "[" num "]" : sakuraSignum
macro_rules | `(expandSignum \i[$n]) => `(Signaculum.Sakura.animatio $n)

syntax "\\i" "[" num "," "wait" "]" : sakuraSignum
macro_rules | `(expandSignum \i[$n, wait]) => `(Signaculum.Sakura.animatioExpecta $n)

-- ════════════════════════════════════════════════════
--  改行 (Lineae)
-- ════════════════════════════════════════════════════

syntax "\\n" : sakuraSignum
macro_rules | `(expandSignum \n) => `(Signaculum.Sakura.linea)

syntax "\\n" "[half]" : sakuraSignum
macro_rules | `(expandSignum \n[half]) => `(Signaculum.Sakura.dimidiaLinea)

syntax "\\n" "[percent," num "]" : sakuraSignum
macro_rules | `(expandSignum \n[percent,$n]) => `(Signaculum.Sakura.lineaProportionalis $n)

syntax "\\_n" : sakuraSignum
macro_rules | `(expandSignum \_n) => `(Signaculum.Sakura.linearisAbrogatur)

-- ════════════════════════════════════════════════════
--  清掃 (Purgatio)
-- ════════════════════════════════════════════════════

syntax "\\c" : sakuraSignum
macro_rules | `(expandSignum \c) => `(Signaculum.Sakura.purga)

syntax "\\C" : sakuraSignum
macro_rules | `(expandSignum \C) => `(Signaculum.Sakura.adscribe)

-- ════════════════════════════════════════════════════
--  待機 (Mora)
-- ════════════════════════════════════════════════════

syntax "\\w" num : sakuraSignum
macro_rules | `(expandSignum \w $n) => `(Signaculum.Sakura.moraCeler $n)

syntax "\\_w" "[" num "]" : sakuraSignum
macro_rules | `(expandSignum \_w[$n]) => `(Signaculum.Sakura.mora $n)

syntax "\\__w" "[" num "]" : sakuraSignum
macro_rules | `(expandSignum \__w[$n]) => `(Signaculum.Sakura.moraAbsoluta $n)

syntax "\\__w" "[clear]" : sakuraSignum
macro_rules | `(expandSignum \__w[clear]) => `(Signaculum.Sakura.reseraTimerSynchrinae)

syntax "\\__w" "[animation," num "]" : sakuraSignum
macro_rules | `(expandSignum \__w[animation,$n]) => `(Signaculum.Sakura.moraAnimationem $n)

syntax "\\x" : sakuraSignum
macro_rules | `(expandSignum \x) => `(Signaculum.Sakura.expecta)

syntax "\\x" "[noclear]" : sakuraSignum
macro_rules | `(expandSignum \x[noclear]) => `(Signaculum.Sakura.expectaSine)

syntax "\\t" : sakuraSignum
macro_rules | `(expandSignum \t) => `(Signaculum.Sakura.tempusCriticum)

-- ════════════════════════════════════════════════════
--  制御 (Imperium)
-- ════════════════════════════════════════════════════

syntax "\\e" : sakuraSignum
macro_rules | `(expandSignum \e) => `(Signaculum.Sakura.finis)

syntax "\\_q" : sakuraSignum
macro_rules | `(expandSignum \_q) => `(Signaculum.Sakura.celer)

syntax "\\-" : sakuraSignum
macro_rules | `(expandSignum \-) => `(Signaculum.Sakura.exitus)

syntax "\\+" : sakuraSignum
macro_rules | `(expandSignum \+) => `(Signaculum.Sakura.mutaGhost)

syntax "\\*" : sakuraSignum
macro_rules | `(expandSignum \*) => `(Signaculum.Sakura.prohibeTempus)

syntax "\\_+" : sakuraSignum
macro_rules | `(expandSignum \_+) => `(Signaculum.Sakura.mutaGhostSequens)

syntax "\\v" : sakuraSignum
macro_rules | `(expandSignum \v) => `(Signaculum.Sakura.togglaSupra)

syntax "\\4" : sakuraSignum
macro_rules | `(expandSignum \4) => `(Signaculum.Sakura.recede)

syntax "\\5" : sakuraSignum
macro_rules | `(expandSignum \5) => `(Signaculum.Sakura.accede)

syntax "\\6" : sakuraSignum
macro_rules | `(expandSignum \6) => `(Signaculum.Sakura.syncTempus)

syntax "\\7" : sakuraSignum
macro_rules | `(expandSignum \7) => `(Signaculum.Sakura.eventumTempus)

syntax "\\_?" : sakuraSignum
macro_rules | `(expandSignum \_?) => `(Signaculum.Sakura.inhibeTagas)

syntax "\\_V" : sakuraSignum
macro_rules | `(expandSignum \_V) => `(Signaculum.Sakura.expectaSonum)

-- ════════════════════════════════════════════════════
--  同期 (Synchronia)
-- ════════════════════════════════════════════════════

syntax "\\_s" : sakuraSignum
macro_rules | `(expandSignum \_s) => `(Signaculum.Sakura.synchrona)

-- ════════════════════════════════════════════════════
--  吹出し (Bulla)
-- ════════════════════════════════════════════════════

syntax "\\b" "[" num "]" : sakuraSignum
macro_rules | `(expandSignum \b[$n]) => `(Signaculum.Sakura.bulla $n)

syntax "\\b" "[-1]" : sakuraSignum
macro_rules | `(expandSignum \b[-1]) => `(Signaculum.Sakura.bullaAbsconde)

-- ════════════════════════════════════════════════════
--  跳躍 (Saltum)
-- ════════════════════════════════════════════════════

syntax "\\j" "[" str "]" : sakuraSignum
macro_rules | `(expandSignum \j[$s]) => `(Signaculum.Sakura.saltum $s)

-- ════════════════════════════════════════════════════
--  錨 (Ancora)
-- ════════════════════════════════════════════════════

syntax "\\_a" : sakuraSignum
macro_rules | `(expandSignum \_a) => `(Signaculum.Sakura.fineAncora)

syntax "\\_a" "[" str "]" : sakuraSignum
macro_rules | `(expandSignum \_a[$s]) => `(Signaculum.Sakura.ancora $s)

-- ════════════════════════════════════════════════════
--  選擇肢 (Optiones)
-- ════════════════════════════════════════════════════

syntax "\\q" "[" str "," str "]" : sakuraSignum
macro_rules | `(expandSignum \q[$t,$id]) => `(Signaculum.Sakura.optio $t $id)

-- ════════════════════════════════════════════════════
--  文字 (Characteres)
-- ════════════════════════════════════════════════════

syntax "\\_u" "[" str "]" : sakuraSignum
macro_rules | `(expandSignum \_u[$s]) => `(Signaculum.Sakura.characterUnicode $s)

syntax "\\_m" "[" str "]" : sakuraSignum
macro_rules | `(expandSignum \_m[$s]) => `(Signaculum.Sakura.characterMessage $s)

syntax "\\_l" "[" str "," str "]" : sakuraSignum
macro_rules | `(expandSignum \_l[$x,$y]) => `(Signaculum.Sakura.cursor $x $y)

-- ════════════════════════════════════════════════════
--  資源 (Resourcea)
-- ════════════════════════════════════════════════════

syntax "\\&" "[" str "]" : sakuraSignum
macro_rules | `(expandSignum \&[$s]) => `(Signaculum.Sakura.referentiaResourcei $s)

-- ════════════════════════════════════════════════════
--  舊形式スコープ (Scopi Antiqui)
-- ════════════════════════════════════════════════════

syntax "\\0" : sakuraSignum
macro_rules | `(expandSignum \0) => `(Signaculum.Sakura.sakura)

syntax "\\1" : sakuraSignum
macro_rules | `(expandSignum \1) => `(Signaculum.Sakura.kero)

-- ════════════════════════════════════════════════════
--  文字・行淸掃拡張 (Extensio Purgationis)
-- ════════════════════════════════════════════════════

syntax "\\c" "[char," num "]" : sakuraSignum
macro_rules | `(expandSignum \c[char, $n]) => `(Signaculum.Sakura.purgaCharacterem $n)

syntax "\\c" "[char," num "," num "]" : sakuraSignum
macro_rules | `(expandSignum \c[char, $n, $i]) => `(Signaculum.Sakura.purgaCharacteremAb $n $i)

syntax "\\c" "[line," num "]" : sakuraSignum
macro_rules | `(expandSignum \c[line, $n]) => `(Signaculum.Sakura.purgaLineam $n)

syntax "\\c" "[line," num "," num "]" : sakuraSignum
macro_rules | `(expandSignum \c[line, $n, $i]) => `(Signaculum.Sakura.purgaLineamAb $n $i)

-- ════════════════════════════════════════════════════
--  選擇肢拡張 (Extensio Optionum)
-- ════════════════════════════════════════════════════

-- イヴェントゥム附き選擇肢（\\q[title,OnEvent,r0,r1,...]）にゃん
syntax "\\q" "[" str "," str "," str,+ "]" : sakuraSignum
macro_rules
| `(expandSignum \q[$t, $e, $rs,*]) => do
  let elems := rs.getElems
  let termElems ← elems.mapM fun (r : Lean.TSyntax `str) =>
    `(term| $r)
  `(Signaculum.Sakura.optioEventum $t $e [$termElems,*])

-- スクリプトゥム實行型選擇肢（\\q[title,script:content]）にゃん
syntax "\\q" "[" str "," "script:" str "]" : sakuraSignum
macro_rules | `(expandSignum \q[$t, script: $s]) => `(Signaculum.Sakura.optioScriptum $t $s)

-- 範圍選擇肢の開始にゃん（\\__q[ID]）
syntax "\\__q" "[" str "]" : sakuraSignum
macro_rules | `(expandSignum \__q[$s]) => `(Signaculum.Sakura.optioScopus $s)

-- 範圍選擇肢の終了にゃん（\\__q）
syntax "\\__q" : sakuraSignum
macro_rules | `(expandSignum \__q) => `(Signaculum.Sakura.fineOptioScopus)

-- ════════════════════════════════════════════════════
--  同期拡張 (Extensio Synchroniae)
-- ════════════════════════════════════════════════════

-- スコープ指定同期にゃん（\\_s[ID1,ID2,...]）— 可變長にゃ
syntax "\\_s" "[" num,+ "]" : sakuraSignum
macro_rules
| `(expandSignum \_s[$ns,*]) => do
  let elems := ns.getElems
  let termElems ← elems.mapM fun (n : Lean.TSyntax `num) =>
    `(term| $n)
  `(Signaculum.Sakura.synchronaScopi [$termElems,*])

end Signaculum.Notatio
