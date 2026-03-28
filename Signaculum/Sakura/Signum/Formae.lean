-- Signaculum.Sakura.Signum.Formae
-- 書體・カーソル・錨のフォルマエシグヌムにゃん♪
-- \\f[...] タグの全コンストゥルクトルをまとめた歸納型にゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- \\f[...] 書體・スタイルのシグヌムにゃん。
    基本書體、カーソルスタイル（選擇中・未選擇）、
    錨スタイル（選擇中・未選擇・訪問濟み）の全フォルマエを網羅してるにゃ♪ -/
inductive SignumFormae where
  -- 基本書體 (Forma Fundamentalis)
  | audax (b : Bool)                          -- \f[bold,b]（太字にゃ）
  | obliquus (b : Bool)                       -- \f[italic,b]（斜體にゃ）
  | sublinea (b : Bool)                       -- \f[underline,b]（下線にゃ）
  | deletura (b : Bool)                       -- \f[strike,b]（取消線にゃ）
  | subscriptus (b : Bool)                    -- \f[sub,b]（下付きにゃ）
  | superscriptus (b : Bool)                  -- \f[sup,b]（上付きにゃ）
  | color (c : Coloris)                       -- \f[color,c]（文字色にゃ）
  | altitudoLitterarum (m : MagnitudoLitterarum) -- \f[height,m]（文字の大きさにゃ）
  | nomenFontis (nomen : String)              -- \f[name,font]（書體名にゃ）
  | allineatio (d : DirectioAllineatio)       -- \f[align,d]（文字揃へにゃ）
  | allineatioVerticalis (d : DirectioVerticalis) -- \f[valign,d]（縱方向文字揃へにゃ）
  | colorUmbrae (c : Coloris)                 -- \f[shadowcolor,c]（文字影の色にゃ）
  | stylumUmbrae (s : StylusUmbrae)           -- \f[shadowstyle,s]（文字影のスタイルにゃ）
  | contornus (p : StatusContorni)            -- \f[outline,p]（輪郭にゃ）
  | formaInhabilis                            -- \f[disable]（テクストゥス表示を無效にするにゃ）
  | formaPraefinita                           -- \f[default]（書式を既定に戾すにゃ）
  -- カーソル・選擇中 (Cursor Electi)
  | stylumCursorisElecti (f : FormaMarci)     -- \f[cursorstyle,f]（選擇中カーソル形状にゃ）
  | colorCursorisElecti (c : Coloris)         -- \f[cursorcolor,c]（選擇中カーソル色にゃ）
  | colorPenicilliCursorisElecti (c : Coloris) -- \f[cursorbrushcolor,c]（選擇中カーソル塗り色にゃ）
  | colorCalamCursorisElecti (c : Coloris)    -- \f[cursorpencolor,c]（選擇中カーソル縁色にゃ）
  | colorFontisCursorisElecti (c : Coloris)   -- \f[cursorfontcolor,c]（選擇中カーソル文字色にゃ）
  | methodusCursorisElecti (m : MethodusMarci) -- \f[cursormethod,m]（選擇中カーソル描畫方法にゃ）
  -- カーソル・未選擇 (Cursor Non Electi)
  | stylumCursorisNonElecti (f : FormaMarci)  -- \f[cursornotselectstyle,f]（未選擇カーソル形状にゃ）
  | colorCursorisNonElecti (c : Coloris)      -- \f[cursornotselectcolor,c]（未選擇カーソル色にゃ）
  | colorPenicilliCursorisNonElecti (c : Coloris) -- \f[cursornotselectbrushcolor,c]（未選擇カーソル塗り色にゃ）
  | colorCalamCursorisNonElecti (c : Coloris) -- \f[cursornotselectpencolor,c]（未選擇カーソル縁色にゃ）
  | colorFontisCursorisNonElecti (c : Coloris) -- \f[cursornotselectfontcolor,c]（未選擇カーソル文字色にゃ）
  | methodusCursorisNonElecti (m : MethodusMarci) -- \f[cursornotselectmethod,m]（未選擇カーソル描畫方法にゃ）
  -- 錨フォントゥス色 (Color Fontis Ancorae)
  | colorFontisAncorae (c : Coloris)          -- \f[anchor.font.color,c]（錨テクストゥス全體色にゃ）
  -- 錨・選擇中 (Ancora Electa)
  | stylumAncorae (f : FormaMarci)            -- \f[anchorstyle,f]（選擇中錨形状にゃ）
  | colorAncorae (c : Coloris)               -- \f[anchorcolor,c]（選擇中錨色にゃ）
  | colorPenicilliAncorae (c : Coloris)       -- \f[anchorbrushcolor,c]（選擇中錨塗り色にゃ）
  | colorCalamAncorae (c : Coloris)           -- \f[anchorpencolor,c]（選擇中錨縁色にゃ）
  | colorFontisAncoraeTotae (c : Coloris)     -- \f[anchorfontcolor,c]（選擇中錨文字色にゃ）
  | methodusAncorae (m : MethodusMarci)       -- \f[anchormethod,m]（選擇中錨描畫方法にゃ）
  -- 錨・未選擇 (Ancora Non Electa)
  | stylumAncoraeNonElectae (f : FormaMarci)  -- \f[anchornotselectstyle,f]（未選擇錨形状にゃ）
  | colorAncoraeNonElectae (c : Coloris)      -- \f[anchornotselectcolor,c]（未選擇錨色にゃ）
  | colorPenicilliAncoraeNonElectae (c : Coloris) -- \f[anchornotselectbrushcolor,c]（未選擇錨塗り色にゃ）
  | colorCalamAncoraeNonElectae (c : Coloris) -- \f[anchornotselectpencolor,c]（未選擇錨縁色にゃ）
  | colorFontisAncoraeNonElectae (c : Coloris) -- \f[anchornotselectfontcolor,c]（未選擇錨文字色にゃ）
  | methodusAncoraeNonElectae (m : MethodusMarci) -- \f[anchornotselectmethod,m]（未選擇錨描畫方法にゃ）
  -- 錨・訪問濟み (Ancora Visa)
  | stylumAncoraeVisae (f : FormaMarci)       -- \f[anchorvisitedstyle,f]（訪問濟み錨形状にゃ）
  | colorAncoraeVisae (c : Coloris)           -- \f[anchorvisitedcolor,c]（訪問濟み錨色にゃ）
  | colorPenicilliAncoraeVisae (c : Coloris)  -- \f[anchorvisitedbrushcolor,c]（訪問濟み錨塗り色にゃ）
  | colorCalamAncoraeVisae (c : Coloris)      -- \f[anchorvisitedpencolor,c]（訪問濟み錨縁色にゃ）
  | colorFontisAncoraeVisae (c : Coloris)     -- \f[anchorvisitedfontcolor,c]（訪問濟み錨文字色にゃ）
  | methodusAncoraeVisae (m : MethodusMarci)  -- \f[anchorvisitedmethod,m]（訪問濟み錨描畫方法にゃ）
  deriving Repr

/-- SignumFormae をサクラスクリプトゥム文字列に變換するにゃん -/
def SignumFormae.adCatenam : SignumFormae → String
  -- 基本書體
  | .audax b              => s!"\\f[bold,{if b then "true" else "false"}]"
  | .obliquus b           => s!"\\f[italic,{if b then "true" else "false"}]"
  | .sublinea b           => s!"\\f[underline,{if b then "true" else "false"}]"
  | .deletura b           => s!"\\f[strike,{if b then "true" else "false"}]"
  | .subscriptus b        => s!"\\f[sub,{if b then "true" else "false"}]"
  | .superscriptus b      => s!"\\f[sup,{if b then "true" else "false"}]"
  | .color c              => s!"\\f[color,{c.toString}]"
  | .altitudoLitterarum m => s!"\\f[height,{m.toString}]"
  | .nomenFontis nomen    => s!"\\f[name,{evadeArgumentum nomen}]"
  | .allineatio d         => s!"\\f[align,{d.toString}]"
  | .allineatioVerticalis d => s!"\\f[valign,{d.toString}]"
  | .colorUmbrae c        => s!"\\f[shadowcolor,{c.toString}]"
  | .stylumUmbrae s       => s!"\\f[shadowstyle,{s.toString}]"
  | .contornus p          => s!"\\f[outline,{p.toString}]"
  | .formaInhabilis       => "\\f[disable]"
  | .formaPraefinita      => "\\f[default]"
  -- カーソル・選擇中
  | .stylumCursorisElecti f          => s!"\\f[cursorstyle,{f.toString}]"
  | .colorCursorisElecti c           => s!"\\f[cursorcolor,{c.toString}]"
  | .colorPenicilliCursorisElecti c  => s!"\\f[cursorbrushcolor,{c.toString}]"
  | .colorCalamCursorisElecti c      => s!"\\f[cursorpencolor,{c.toString}]"
  | .colorFontisCursorisElecti c     => s!"\\f[cursorfontcolor,{c.toString}]"
  | .methodusCursorisElecti m        => s!"\\f[cursormethod,{m.toString}]"
  -- カーソル・未選擇
  | .stylumCursorisNonElecti f          => s!"\\f[cursornotselectstyle,{f.toString}]"
  | .colorCursorisNonElecti c           => s!"\\f[cursornotselectcolor,{c.toString}]"
  | .colorPenicilliCursorisNonElecti c  => s!"\\f[cursornotselectbrushcolor,{c.toString}]"
  | .colorCalamCursorisNonElecti c      => s!"\\f[cursornotselectpencolor,{c.toString}]"
  | .colorFontisCursorisNonElecti c     => s!"\\f[cursornotselectfontcolor,{c.toString}]"
  | .methodusCursorisNonElecti m        => s!"\\f[cursornotselectmethod,{m.toString}]"
  -- 錨フォントゥス色
  | .colorFontisAncorae c  => s!"\\f[anchor.font.color,{c.toString}]"
  -- 錨・選擇中
  | .stylumAncorae f            => s!"\\f[anchorstyle,{f.toString}]"
  | .colorAncorae c             => s!"\\f[anchorcolor,{c.toString}]"
  | .colorPenicilliAncorae c    => s!"\\f[anchorbrushcolor,{c.toString}]"
  | .colorCalamAncorae c        => s!"\\f[anchorpencolor,{c.toString}]"
  | .colorFontisAncoraeTotae c  => s!"\\f[anchorfontcolor,{c.toString}]"
  | .methodusAncorae m          => s!"\\f[anchormethod,{m.toString}]"
  -- 錨・未選擇
  | .stylumAncoraeNonElectae f          => s!"\\f[anchornotselectstyle,{f.toString}]"
  | .colorAncoraeNonElectae c           => s!"\\f[anchornotselectcolor,{c.toString}]"
  | .colorPenicilliAncoraeNonElectae c  => s!"\\f[anchornotselectbrushcolor,{c.toString}]"
  | .colorCalamAncoraeNonElectae c      => s!"\\f[anchornotselectpencolor,{c.toString}]"
  | .colorFontisAncoraeNonElectae c     => s!"\\f[anchornotselectfontcolor,{c.toString}]"
  | .methodusAncoraeNonElectae m        => s!"\\f[anchornotselectmethod,{m.toString}]"
  -- 錨・訪問濟み
  | .stylumAncoraeVisae f          => s!"\\f[anchorvisitedstyle,{f.toString}]"
  | .colorAncoraeVisae c           => s!"\\f[anchorvisitedcolor,{c.toString}]"
  | .colorPenicilliAncoraeVisae c  => s!"\\f[anchorvisitedbrushcolor,{c.toString}]"
  | .colorCalamAncoraeVisae c      => s!"\\f[anchorvisitedpencolor,{c.toString}]"
  | .colorFontisAncoraeVisae c     => s!"\\f[anchorvisitedfontcolor,{c.toString}]"
  | .methodusAncoraeVisae m        => s!"\\f[anchorvisitedmethod,{m.toString}]"

end Signaculum.Sakura
