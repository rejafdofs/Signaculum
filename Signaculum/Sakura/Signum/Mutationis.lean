-- Signaculum.Sakura.Signum.Mutationis
-- 變更・再讀込シグヌムにゃん♪ ゴーストやシェルの切替、モジュールの讀込を制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 變更・再讀込のシグヌムにゃん。change / reboot / reload 等のタグに對應するにゃ -/
inductive SignumMutationis where
  | mutaGhostNomen (nomen : String) (optiones : OptionesMutationis)
    -- \![change,ghost,name,opts]（ゴーストを名前で切り替へるにゃ）
  | mutaShell (nomen : String) (optiones : OptionesMutationis)
    -- \![change,shell,name,opts]（シェルを切り替へるにゃ）
  | mutaBullam (nomen : String) (optiones : OptionesMutationis)
    -- \![change,balloon,name,opts]（吹出しを切り替へるにゃ）
  | renovaGhost
    -- \![reboot]（ゴーストを再起動するにゃ）
  | renova (scopus : ScopusRenovationis)
    -- \![reload,scopus]（指定對象を再讀込するにゃ）
  | renovaSuperficiem
    -- \![reloadsurface]（表面を再讀込するにゃ）
  | expelleShiori
    -- \![unload,shiori]（SHIORI をアンロードするにゃ）
  | expelleMakoto
    -- \![unload,makoto]（makoto をアンロードするにゃ）
  | oneraSHIORI
    -- \![load,shiori]（SHIORI をロードするにゃ）
  | oneraMakoto
    -- \![load,makoto]（makoto をロードするにゃ）
  | configuraShioriDebug
    -- \![set,shioridebugmode]（SHIORI のデバッグモードを設定するにゃ）
  deriving Repr

/-- 變更・再讀込シグヌムをさくらスクリプトゥム文字列に變換するにゃん -/
def SignumMutationis.adCatenam : SignumMutationis → String
  | .mutaGhostNomen nm opt =>
    let o := opt.toString
    let o := if o.isEmpty then "" else s!",{o}"
    s!"\\![change,ghost,{evadeArgumentum nm}{o}]"
  | .mutaShell nm opt =>
    let o := opt.toString
    let o := if o.isEmpty then "" else s!",{o}"
    s!"\\![change,shell,{evadeArgumentum nm}{o}]"
  | .mutaBullam nm opt =>
    let o := opt.toString
    let o := if o.isEmpty then "" else s!",{o}"
    s!"\\![change,balloon,{evadeArgumentum nm}{o}]"
  | .renovaGhost          => "\\![reboot]"
  | .renova sc            => s!"\\![reload,{sc.toString}]"
  | .renovaSuperficiem    => "\\![reloadsurface]"
  | .expelleShiori        => "\\![unload,shiori]"
  | .expelleMakoto        => "\\![unload,makoto]"
  | .oneraSHIORI          => "\\![load,shiori]"
  | .oneraMakoto          => "\\![load,makoto]"
  | .configuraShioriDebug => "\\![set,shioridebugmode]"

end Signaculum.Sakura
