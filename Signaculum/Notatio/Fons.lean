-- Signaculum.Notatio.Fons
-- 書體タグ \\f[...] の構文規則にゃん♪ fontisClavis カテゴリアを使ふにゃ

import Signaculum.Notatio.Categoria
import Signaculum.Notatio.Literalia
import Signaculum.Sakura.Scriptum

namespace Signaculum.Notatio

open Lean Signaculum.Sakura

syntax "\\f" "[" fontisClavis "]" : sakuraSignum

-- Bool 系にゃん
syntax "bold" "," term : fontisClavis
macro_rules | `(expandSignum \f[bold, $b]) => `(Signaculum.Sakura.audax $b)

syntax "italic" "," term : fontisClavis
macro_rules | `(expandSignum \f[italic, $b]) => `(Signaculum.Sakura.obliquus $b)

syntax "underline" "," term : fontisClavis
macro_rules | `(expandSignum \f[underline, $b]) => `(Signaculum.Sakura.sublinea $b)

syntax "strike" "," term : fontisClavis
macro_rules | `(expandSignum \f[strike, $b]) => `(Signaculum.Sakura.deletura $b)

syntax "sub" "," term : fontisClavis
macro_rules | `(expandSignum \f[sub, $b]) => `(Signaculum.Sakura.subscriptus $b)

syntax "sup" "," term : fontisClavis
macro_rules | `(expandSignum \f[sup, $b]) => `(Signaculum.Sakura.superscriptus $b)

-- 色系にゃん（colorisLiteral で SakuraScript リテラルが直接書けるにゃ）
syntax "color" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[color, $c:colorisLiteral]) => `(Signaculum.Sakura.color (colorisL $c))

syntax "shadowcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[shadowcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorUmbrae (colorisL $c))

-- 數値系にゃん
syntax "height" "," term : fontisClavis
macro_rules | `(expandSignum \f[height, $n]) => `(Signaculum.Sakura.altitudoLitterarum $n)

-- 文字列系にゃん
syntax "name" "," term : fontisClavis
macro_rules | `(expandSignum \f[name, $s]) => `(Signaculum.Sakura.nomenFontis $s)

syntax "shadowstyle" "," term : fontisClavis
macro_rules | `(expandSignum \f[shadowstyle, $s]) => `(Signaculum.Sakura.stylumUmbrae $s)

syntax "outline" "," term : fontisClavis
macro_rules | `(expandSignum \f[outline, $s]) => `(Signaculum.Sakura.contornus $s)

-- 方向系にゃん（リテラルで書けるにゃ）
syntax "align" "," directioAllineatioLiteral : fontisClavis
macro_rules | `(expandSignum \f[align, $d:directioAllineatioLiteral]) => `(Signaculum.Sakura.allineatio (directioAllineatioL $d))

syntax "valign" "," directioVerticalisLiteral : fontisClavis
macro_rules | `(expandSignum \f[valign, $d:directioVerticalisLiteral]) => `(Signaculum.Sakura.allineatioVerticalis (directioVerticalisL $d))

-- パラメータなしにゃん
syntax "disable" : fontisClavis
macro_rules | `(expandSignum \f[disable]) => `(Signaculum.Sakura.formaInhabilis)

syntax "default" : fontisClavis
macro_rules | `(expandSignum \f[default]) => `(Signaculum.Sakura.formaPraefinita)

-- カーソル（選擇中）にゃん
syntax "cursorstyle" "," formaMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursorstyle, $f:formaMarciLiteral]) => `(Signaculum.Sakura.stylumCursorisElecti (formaMarciL $f))

syntax "cursorcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursorcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorCursorisElecti (colorisL $c))

syntax "cursorbrushcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursorbrushcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorPenicilliCursorisElecti (colorisL $c))

syntax "cursorpencolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursorpencolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorCalamCursorisElecti (colorisL $c))

syntax "cursorfontcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursorfontcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorFontisCursorisElecti (colorisL $c))

syntax "cursormethod" "," methodusMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursormethod, $m:methodusMarciLiteral]) => `(Signaculum.Sakura.methodusCursorisElecti (methodusMarciL $m))

-- カーソル（未選擇）にゃん
syntax "cursornotselectstyle" "," formaMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursornotselectstyle, $f:formaMarciLiteral]) => `(Signaculum.Sakura.stylumCursorisNonElecti (formaMarciL $f))

syntax "cursornotselectcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursornotselectcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorCursorisNonElecti (colorisL $c))

syntax "cursornotselectbrushcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursornotselectbrushcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorPenicilliCursorisNonElecti (colorisL $c))

syntax "cursornotselectpencolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursornotselectpencolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorCalamCursorisNonElecti (colorisL $c))

syntax "cursornotselectfontcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursornotselectfontcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorFontisCursorisNonElecti (colorisL $c))

syntax "cursornotselectmethod" "," methodusMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[cursornotselectmethod, $m:methodusMarciLiteral]) => `(Signaculum.Sakura.methodusCursorisNonElecti (methodusMarciL $m))

-- 錨（選擇中）にゃん
syntax "anchorstyle" "," formaMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorstyle, $f:formaMarciLiteral]) => `(Signaculum.Sakura.stylumAncorae (formaMarciL $f))

syntax "anchorcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorAncorae (colorisL $c))

syntax "anchorbrushcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorbrushcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorPenicilliAncorae (colorisL $c))

syntax "anchorpencolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorpencolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorCalamAncorae (colorisL $c))

syntax "anchorfontcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorfontcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorFontisAncoraTotae (colorisL $c))

syntax "anchormethod" "," methodusMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchormethod, $m:methodusMarciLiteral]) => `(Signaculum.Sakura.methodusAncorae (methodusMarciL $m))

-- 錨（未選擇）にゃん
syntax "anchornotselectstyle" "," formaMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchornotselectstyle, $f:formaMarciLiteral]) => `(Signaculum.Sakura.stylumAncoraeNonElectae (formaMarciL $f))

syntax "anchornotselectcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchornotselectcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorAncoraeNonElectae (colorisL $c))

syntax "anchornotselectbrushcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchornotselectbrushcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorPenicilliAncoraeNonElectae (colorisL $c))

syntax "anchornotselectpencolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchornotselectpencolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorCalamAncoraeNonElectae (colorisL $c))

syntax "anchornotselectfontcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchornotselectfontcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorFontisAncoraeNonElectae (colorisL $c))

syntax "anchornotselectmethod" "," methodusMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchornotselectmethod, $m:methodusMarciLiteral]) => `(Signaculum.Sakura.methodusAncoraeNonElectae (methodusMarciL $m))

-- 錨（訪問済み）にゃん
syntax "anchorvisitedstyle" "," formaMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorvisitedstyle, $f:formaMarciLiteral]) => `(Signaculum.Sakura.stylumAncoraeVisae (formaMarciL $f))

syntax "anchorvisitedcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorvisitedcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorAncoraeVisae (colorisL $c))

syntax "anchorvisitedbrushcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorvisitedbrushcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorPenicilliAncoraeVisae (colorisL $c))

syntax "anchorvisitedpencolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorvisitedpencolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorCalamAncoraeVisae (colorisL $c))

syntax "anchorvisitedfontcolor" "," colorisLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorvisitedfontcolor, $c:colorisLiteral]) => `(Signaculum.Sakura.colorFontisAncoraeVisae (colorisL $c))

syntax "anchorvisitedmethod" "," methodusMarciLiteral : fontisClavis
macro_rules | `(expandSignum \f[anchorvisitedmethod, $m:methodusMarciLiteral]) => `(Signaculum.Sakura.methodusAncoraeVisae (methodusMarciL $m))

end Signaculum.Notatio
