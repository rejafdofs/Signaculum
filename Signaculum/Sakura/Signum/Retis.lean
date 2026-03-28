-- Signaculum.Sakura.Signum.Retis
-- 通信・ファイル操作シグヌムにゃん♪ HTTP やアーカイヴ操作を制御するにゃ

import Signaculum.Sakura.Typi

namespace Signaculum.Sakura

/-- 通信・ファイル操作のシグヌムにゃん。execute 系の HTTP / ネットワーク / ファイルタグに對應するにゃ -/
inductive SignumRetis where
  | executaHttpGet (nexus : String) (optiones : String)
    -- \![execute,http-get,URL,opts]（HTTP GET にゃ）
  | executaHttpPost (nexus : String) (optiones : String)
    -- \![execute,http-post,URL,opts]（HTTP POST にゃ）
  | executaHttpHead (nexus : String) (optiones : String)
    -- \![execute,http-head,URL,opts]（HTTP HEAD にゃ）
  | executaHttpPut (nexus : String) (optiones : String)
    -- \![execute,http-put,URL,opts]（HTTP PUT にゃ）
  | executaHttpDelete (nexus : String) (optiones : String)
    -- \![execute,http-delete,URL,opts]（HTTP DELETE にゃ）
  | executaHttpPatch (nexus : String) (optiones : String)
    -- \![execute,http-patch,URL,opts]（HTTP PATCH にゃ）
  | executaHttpOptions (nexus : String) (optiones : String)
    -- \![execute,http-options,URL,opts]（HTTP OPTIONS にゃ）
  | executaRssGet (nexus : String) (optiones : String)
    -- \![execute,rss-get,URL,opts]（RSS GET にゃ）
  | executaRssPost (nexus : String) (optiones : String)
    -- \![execute,rss-post,URL,opts]（RSS POST にゃ）
  | executaHeadline (nomen : String)
    -- \![execute,headline,name]（ヘッドラインを實行するにゃ）
  | executaNslookup (parametra : List String)
    -- \![execute,nslookup,param,...]（DNS 解決にゃ）
  | executaPing (parametra : List String)
    -- \![execute,ping,param,...]（PING にゃ）
  | executaSNTP
    -- \![executesntp]（SNTP 時刻同期にゃ）
  | executaDumpSuperficiei (directum : String) (scopus : Nat) (lista praefixum eventum : String) (zero : Bool)
    -- \![execute,dumpsurface,...]（表面ダンプにゃ）
  | executaInstallationemUrl (nexus typus : String)
    -- \![execute,install,url,URL,type]（URL からインストールするにゃ）
  | executaInstallationemVia (via : String)
    -- \![execute,install,path,file]（ファイルからインストールするにゃ）
  | executaCreationemUpdateData
    -- \![execute,createupdatedata]（更新データを作成するにゃ）
  | executaCreationemNar
    -- \![execute,createnar]（NAR ファイルを作成するにゃ）
  | evacuaRecyclatorium
    -- \![execute,emptyrecyclebin]（ゴミ箱を空にするにゃ）
  | extraheArchivum (via directum : String) (optiones : String)
    -- \![execute,extractarchive,file,folder,opts]（アーカイヴを展開するにゃ）
  | comprimeArchivum (via directum : String) (optiones : String)
    -- \![execute,compressarchive,file,folder,opts]（フォルダを壓縮するにゃ）
  deriving Repr

/-- 通信・ファイル操作シグヌムをさくらスクリプトゥム文字列に變換するにゃん -/
def SignumRetis.adCatenam : SignumRetis → String
  | .executaHttpGet nx opt =>
    if opt.isEmpty then s!"\\![execute,http-get,{evadeArgumentum nx}]"
    else s!"\\![execute,http-get,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaHttpPost nx opt =>
    if opt.isEmpty then s!"\\![execute,http-post,{evadeArgumentum nx}]"
    else s!"\\![execute,http-post,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaHttpHead nx opt =>
    if opt.isEmpty then s!"\\![execute,http-head,{evadeArgumentum nx}]"
    else s!"\\![execute,http-head,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaHttpPut nx opt =>
    if opt.isEmpty then s!"\\![execute,http-put,{evadeArgumentum nx}]"
    else s!"\\![execute,http-put,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaHttpDelete nx opt =>
    if opt.isEmpty then s!"\\![execute,http-delete,{evadeArgumentum nx}]"
    else s!"\\![execute,http-delete,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaHttpPatch nx opt =>
    if opt.isEmpty then s!"\\![execute,http-patch,{evadeArgumentum nx}]"
    else s!"\\![execute,http-patch,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaHttpOptions nx opt =>
    if opt.isEmpty then s!"\\![execute,http-options,{evadeArgumentum nx}]"
    else s!"\\![execute,http-options,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaRssGet nx opt =>
    if opt.isEmpty then s!"\\![execute,rss-get,{evadeArgumentum nx}]"
    else s!"\\![execute,rss-get,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaRssPost nx opt =>
    if opt.isEmpty then s!"\\![execute,rss-post,{evadeArgumentum nx}]"
    else s!"\\![execute,rss-post,{evadeArgumentum nx},{evadeArgumentum opt}]"
  | .executaHeadline nm =>
    s!"\\![execute,headline,{evadeArgumentum nm}]"
  | .executaNslookup ps =>
    let cc := ",".intercalate (ps.map evadeArgumentum)
    s!"\\![execute,nslookup,{cc}]"
  | .executaPing ps =>
    let cc := ",".intercalate (ps.map evadeArgumentum)
    s!"\\![execute,ping,{cc}]"
  | .executaSNTP =>
    "\\![executesntp]"
  | .executaDumpSuperficiei dir sc li pr ev z =>
    s!"\\![execute,dumpsurface,{evadeArgumentum dir},{sc},{evadeArgumentum li},{evadeArgumentum pr},{evadeArgumentum ev},{if z then "1" else "0"}]"
  | .executaInstallationemUrl nx ty =>
    s!"\\![execute,install,url,{evadeArgumentum nx},{evadeArgumentum ty}]"
  | .executaInstallationemVia v =>
    s!"\\![execute,install,path,{evadeArgumentum v}]"
  | .executaCreationemUpdateData =>
    "\\![execute,createupdatedata]"
  | .executaCreationemNar =>
    "\\![execute,createnar]"
  | .evacuaRecyclatorium =>
    "\\![execute,emptyrecyclebin]"
  | .extraheArchivum v dir opt =>
    if opt.isEmpty then s!"\\![execute,extractarchive,{evadeArgumentum v},{evadeArgumentum dir}]"
    else s!"\\![execute,extractarchive,{evadeArgumentum v},{evadeArgumentum dir},{evadeArgumentum opt}]"
  | .comprimeArchivum v dir opt =>
    if opt.isEmpty then s!"\\![execute,compressarchive,{evadeArgumentum v},{evadeArgumentum dir}]"
    else s!"\\![execute,compressarchive,{evadeArgumentum v},{evadeArgumentum dir},{evadeArgumentum opt}]"

end Signaculum.Sakura
