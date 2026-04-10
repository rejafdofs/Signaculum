-- Signaculum.Utilia.ExpressioRegularis
-- 正規表現（エクスプレッシオー・レーグラーリス）にゃん♪
-- 現在は基本的な文字列パターンマッチを提供するにゃ
-- 將來 lean-regex が Lean 4.29.0 對應したら移行するにゃん

namespace Signaculum.Utilia

/-- テクストゥスにパターンが含まれるか判定するにゃん（部分文字列檢索）-/
def continetPatronum (patronus textus : String) : Bool :=
  (textus.splitOn patronus).length > 1

/-- テクストゥスをセパレーターで分割するにゃん -/
def scindeTextum (separator textus : String) : Array String :=
  (textus.splitOn separator).toArray

/-- テクストゥスの部分文字列を置換するにゃん -/
def substitueTextum (veterem novum textus : String) : String :=
  textus.replace veterem novum

/-- テクストゥスがプレーフィクスムで始まるか判定するにゃん -/
def incipitCum (praefixum textus : String) : Bool :=
  textus.startsWith praefixum

/-- テクストゥスがスッフィクスムで終はるか判定するにゃん -/
def desinitCum (suffixum textus : String) : Bool :=
  textus.endsWith suffixum

end Signaculum.Utilia
