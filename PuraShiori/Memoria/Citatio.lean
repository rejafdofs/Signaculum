-- PuraShiori.Citatio
-- SHIORI リフェレンスの型安全な相互變換クラスにゃん♪
-- fromRef (toRef a) = a が型クラスの法則として保証されるにゃ

import LemmaGeneralis
namespace PuraShiori

/-- 値を SHIORI リフェレンス文字列に變換し、逆變換も保証される型クラスにゃん。
    `toRef` でセリアーリザーティオー・`fromRef` で復元するにゃ。
    `roundtrip : ∀ a, fromRef (toRef a) = a` が法則として要求されるにゃ。
    `insere`/`excita` の引數變換と、處理器ラッパーのリフェレンス復元に使ふにゃ -/
class Citatio (α : Type) where
  toRef     : α → String
  fromRef   : String → α
  roundtrip : ∀ (a : α), fromRef (toRef a) = a

end PuraShiori
