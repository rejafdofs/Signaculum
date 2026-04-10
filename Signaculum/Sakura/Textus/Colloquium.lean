-- Signaculum.Sakura.Textus.Colloquium
-- 統一トーク管理 DSL にゃん♪
-- ランダムトーク・條件附きトーク・チェイントークを Colloquium 型で統合するにゃ
-- 舊 API（OptioPiscinae / eligeVelCatena）の改善版にゃん

import Signaculum.Sakura.Textus.Catena

namespace Signaculum.Sakura.Textus

-- ═══════════════════════════════════════════════════
-- 統一トークエントリ型 (Colloquium) にゃん
-- ═══════════════════════════════════════════════════

/-- 統一トークエントリにゃん♪
    ランダム・條件附き・チェインを一つの型で表現するにゃ。
    Coe インスタンスにより配列内で `.loquela` ラッピングが不要にゃん -/
inductive Colloquium where
  /-- 通常トーク（無條件でランダム候補に入るにゃ）-/
  | loquela   (actio : SakuraIO Unit)
  /-- 條件附きトーク（條件が眞の時のみ候補に入るにゃ）-/
  | conditio  (cond : IO Bool) (actio : SakuraIO Unit)
  /-- チェイントーク（Catena 構造體への參照にゃ）-/
  | series    (c : Catena)
  /-- 條件附きチェイントークにゃん -/
  | seriesCum (cond : IO Bool) (c : Catena)

/-- SakuraIO Unit → Colloquium の自動變換にゃん♪
    配列リテラル内で `.loquela` ラッピングが不要になるにゃ -/
instance : Coe (SakuraIO Unit) Colloquium := ⟨.loquela⟩

/-- Catena → Colloquium の自動變換にゃん♪
    配列リテラル内で `.series` ラッピングが不要になるにゃ -/
instance : Coe Catena Colloquium := ⟨.series⟩

-- ═══════════════════════════════════════════════════
-- 便利コンストラクタ (Constructores Commodi) にゃん
-- ═══════════════════════════════════════════════════

/-- 條件附きトークの便利コンストラクタにゃん -/
def cum (cond : IO Bool) (actio : SakuraIO Unit) : Colloquium :=
  .conditio cond actio

/-- 條件附きチェインの便利コンストラクタにゃん -/
def cumSeries (cond : IO Bool) (c : Catena) : Colloquium :=
  .seriesCum cond c

-- ═══════════════════════════════════════════════════
-- 統一選擇 (Electio Unificata) にゃん
-- ═══════════════════════════════════════════════════

/-- Colloquium 配列からトークを選擇して實行するにゃん♪
    1. 活動中のチェインがあれば續行
    2. なければ全條件を評價してフィルタリング
    3. 候補からランダムに一つ選擇して實行
    4. 候補が0個なら何もしにゃい（204 相當にゃ）-/
def eligeColloquium (colloquia : Array Colloquium) : SakuraIO Unit := do
  -- 活動中のチェインを確認するにゃん
  let activa : Option String ← liftM (show IO (Option String) from catenaActiva.get)
  match activa with
  | some nomen =>
    -- 活動中チェインを探すにゃん
    let mut inventa := false
    for c in colloquia do
      match c with
      | .series cat | .seriesCum _ cat =>
        if cat.nomen == nomen then
          exequiCatenam cat
          inventa := true
          break
      | _ => pure ()
    -- 見つからなかったらリセットしてランダム選擇にフォールバックにゃ
    unless inventa do
      liftM (show IO Unit from catenaActiva.set none)
      eligeExCandidatis colloquia
  | none =>
    eligeExCandidatis colloquia
where
  /-- 條件を評價してフィルタリングし、候補からランダムに選ぶにゃん -/
  eligeExCandidatis (colloquia : Array Colloquium) : SakuraIO Unit := do
    -- 候補を収集するにゃん
    let mut candidati : Array (SakuraIO Unit) := #[]
    for c in colloquia do
      match c with
      | .loquela actio =>
        candidati := candidati.push actio
      | .conditio cond actio =>
        let b ← liftM (show IO Bool from cond)
        if b then candidati := candidati.push actio
      | .series cat =>
        -- チェインの開始をアクションとしてラップするにゃん
        candidati := candidati.push (do
          liftM (show IO Unit from catenaActiva.set (some cat.nomen))
          exequiCatenam cat)
      | .seriesCum cond cat =>
        let b ← liftM (show IO Bool from cond)
        if b then
          candidati := candidati.push (do
            liftM (show IO Unit from catenaActiva.set (some cat.nomen))
            exequiCatenam cat)
    -- 候補からランダムに一つ選ぶにゃん
    let n := candidati.size
    if h : n = 0 then pure ()
    else do
      let idx ← liftM (IO.rand 0 (n - 1))
      let i := idx % n
      have hi : i < n := Nat.mod_lt idx (by omega)
      candidati[i]'hi

/-- 重み附き Colloquium 選擇にゃん♪
    重みに比例した確率でトークが選ばれるにゃ -/
def eligeColloquiumPonderatum (colloquia : Array (Nat × Colloquium)) : SakuraIO Unit := do
  -- 活動中チェイン確認にゃん
  let activa : Option String ← liftM (show IO (Option String) from catenaActiva.get)
  match activa with
  | some nomen =>
    let mut inventa := false
    for (_, c) in colloquia do
      match c with
      | .series cat | .seriesCum _ cat =>
        if cat.nomen == nomen then
          exequiCatenam cat
          inventa := true
          break
      | _ => pure ()
    unless inventa do
      liftM (show IO Unit from catenaActiva.set none)
      eligePonderatum colloquia
  | none =>
    eligePonderatum colloquia
where
  eligePonderatum (colloquia : Array (Nat × Colloquium)) : SakuraIO Unit := do
    -- 重み附き候補を収集するにゃん
    let mut candidati : Array (Nat × SakuraIO Unit) := #[]
    for (pondus, c) in colloquia do
      match c with
      | .loquela actio =>
        candidati := candidati.push (pondus, actio)
      | .conditio cond actio =>
        let b ← liftM (show IO Bool from cond)
        if b then candidati := candidati.push (pondus, actio)
      | .series cat =>
        candidati := candidati.push (pondus, do
          liftM (show IO Unit from catenaActiva.set (some cat.nomen))
          exequiCatenam cat)
      | .seriesCum cond cat =>
        let b ← liftM (show IO Bool from cond)
        if b then
          candidati := candidati.push (pondus, do
            liftM (show IO Unit from catenaActiva.set (some cat.nomen))
            exequiCatenam cat)
    -- 重みの合計を計算するにゃん
    let summaPonderum := candidati.foldl (fun acc (p, _) => acc + p) 0
    if summaPonderum == 0 then pure ()
    else do
      let mut punctum ← liftM (IO.rand 0 (summaPonderum - 1))
      for (pondus, actio) in candidati do
        if punctum < pondus then
          actio
          return
        punctum := punctum - pondus

end Signaculum.Sakura.Textus
