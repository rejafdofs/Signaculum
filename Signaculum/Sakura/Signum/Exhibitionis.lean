-- Signaculum.Sakura.Signum.Exhibitionis
-- テクストゥス表示シグヌムにゃん♪ 文字の表示や改行、カーソル位置を制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura.Signum

/-- テクストゥス表示のシグヌムにゃん。表示文字列や改行、淸掃等に對應するにゃ -/
inductive SignumExhibitionis where
  | textus (s : String)                    -- 表示テクストゥス（evadeTextus でシリアライズにゃ）
  | linea                                  -- \\n（改行にゃ）
  | dimidiaLinea                           -- \\n[half]（半改行にゃ）
  | lineaProportionalis (n : Int)          -- \\n[percent,n]（割合改行にゃ）
  | purga                                  -- \\c（淸掃にゃ）
  | purgaCharacterem (n : Nat)             -- \\c[char,n]
  | purgaCharacteremAb (n initium : Nat)   -- \\c[char,n,initium]
  | purgaLineam (n : Nat)                  -- \\c[line,n]
  | purgaLineamAb (n initium : Nat)        -- \\c[line,n,initium]
  | adscribe                               -- \\C（追記にゃ）
  | cursor (x y : String)                  -- \\_l[x,y]（カーソル位置にゃ）
  | characterUnicode (code : String)       -- \\_u[0xXXXX]（ウニコーディス文字にゃ）
  | characterMessage (code : String)       -- \\_m[0xXX]（メッサーギウム文字にゃ）
  | saltum (nexus : String)                -- \\j[url]（ジャンプにゃ）
  | linearisAbrogatur                      -- \\_n（改行無效化にゃ）
  deriving Repr

def SignumExhibitionis.adCatenam : SignumExhibitionis → String
  | .textus s                  => evadeTextus s
  | .linea                     => "\\n"
  | .dimidiaLinea              => "\\n[half]"
  | .lineaProportionalis n     => s!"\\n[percent,{n}]"
  | .purga                     => "\\c"
  | .purgaCharacterem n        => s!"\\c[char,{n}]"
  | .purgaCharacteremAb n i    => s!"\\c[char,{n},{i}]"
  | .purgaLineam n             => s!"\\c[line,{n}]"
  | .purgaLineamAb n i         => s!"\\c[line,{n},{i}]"
  | .adscribe                  => "\\C"
  | .cursor x y                => s!"\\_l[{evadeArgumentum x},{evadeArgumentum y}]"
  | .characterUnicode code     => s!"\\_u[{code}]"
  | .characterMessage code     => s!"\\_m[{code}]"
  | .saltum nexus              => s!"\\j[{evadeArgumentum nexus}]"
  | .linearisAbrogatur         => "\\_n"

end Signaculum.Sakura.Signum
