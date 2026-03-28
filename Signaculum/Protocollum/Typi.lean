-- Signaculum.Protocollum.Typi
-- SHIORI/3.0 プロトコッルムの共通型と定數にゃん

namespace Signaculum.Protocollum

/-- SHIORI 要求の手法(methodus)にゃん。GET は應答を期待し、NOTIFY は通知のみにゃ -/
inductive Methodus where
  | pete     -- GET: SakuraScript 等の Value を期待するにゃ
  | notifica -- NOTIFY: 應答不要（Value を返しても無視される）
  deriving Repr, BEq, Inhabited

namespace Methodus

/-- 文字列に變換するにゃん -/
def adCatenam : Methodus → String
  | .pete     => "GET"
  | .notifica => "NOTIFY"

/-- 文字列から構文解析するにゃん -/
def exCatena (s : String) : Option Methodus :=
  match s with
  | "GET"    => some .pete
  | "NOTIFY" => some .notifica
  | _ => none

end Methodus

/-- SHIORI プロトコッルムの版にゃん -/
def shioriVersio : String := "SHIORI/3.0"

/-- 應答の狀態符號にゃ -/
inductive StatusCodis where
  | ok             -- 200 OK
  | inanis         -- 204 No Content（空の應答にゃ）
  | pluribusDatis  -- 311 OnTeach で追加情報が必要にゃ
  | rescribeInput  -- 312 OnTeach で最新入力を破棄して再試行にゃ
  | malaRogatio    -- 400 Bad Request（不正要求にゃ）
  | errorInternus  -- 500 Internal Server Error（内部異常にゃ）
  deriving Repr, BEq

namespace StatusCodis

def adNumerum : StatusCodis → Nat
  | .ok            => 200
  | .inanis        => 204
  | .pluribusDatis => 311
  | .rescribeInput => 312
  | .malaRogatio   => 400
  | .errorInternus => 500

def adCatenam : StatusCodis → String
  | .ok            => "OK"
  | .inanis        => "No Content"
  | .pluribusDatis => "Need More Information"
  | .rescribeInput => "Advice"
  | .malaRogatio   => "Bad Request"
  | .errorInternus => "Internal Server Error"

/-- 狀態行の完全にゃ文字列表現にゃん -/
def lineaStatus (sc : StatusCodis) : String :=
  s!"{shioriVersio} {sc.adNumerum} {sc.adCatenam}"

end StatusCodis

/-- 行末の CR+LF にゃん -/
def crlf : String := "\r\n"

/-- ヘッダー値から CR・LF を除去してプロトコッルムパケットゥムの破損を防ぐにゃん。
    SHIORI/3.0 レスポンスムと SSTP リクエストゥムの両方で使ふにゃ -/
def purgaCrlf (s : String) : String :=
  s.foldl (fun acc c => if c != '\r' && c != '\n' then acc.push c else acc) ""

end Signaculum.Protocollum
