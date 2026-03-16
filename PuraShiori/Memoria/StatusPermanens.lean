-- PuraShiori.StatusPermanens
-- 永續化（persistentia）の型クラスにゃん♪
-- インスタンティアと補助關數は AuxiliaStatusPermanens.lean にあるにゃ

import LemmaGeneralis
namespace PuraShiori

/-- 永續化できる型の型クラスにゃん。
    `typusTag` で型の文字列識別子を提供するにゃ。
    ゴーストの更新で變數の型が變はった時でも、タグが不一致なら讀み飛ばすにゃ♪
    `adBytes` で ByteArray にセリアーリザーティオー、`eBytes` で復元するにゃ。
    自作構造體も `encodeField`/`decodeField` を使へばインスタンティアを書けるにゃん♪ -/
class StatusPermanens (α : Type) where
  /-- 型の文字列識別子にゃん。バージョン更新時の型チェックに使ふにゃ。
      例: `"Nat"`, `"String"`, `"List(Nat)"` 等にゃ -/
  typusTag : String
  /-- 値を ByteArray にセリアーリザーティオーするにゃん -/
  adBytes  : α → ByteArray
  /-- ByteArray から値を復元するにゃん。失敗したら `none` を返すにゃ -/
  eBytes   : ByteArray → Option α
  /-- セリアーリザーティオーの正しさにゃん: セリアーリザーティオーして復元すると元の値に戻るにゃ。
      eBytes (adBytes v) = some v が全 v で保証されるにゃ -/
  roundtrip : ∀ (v : α), eBytes (adBytes v) = some v

end PuraShiori
