import Lake

open System Lake DSL

package Signaculum where
  version := v!"0.1.0"
  description := "Lean 4 製 SHIORI/3.0 栞(Ukagaka ghost)ビブリオテーカ(bibliotheca)"
  keywords := #["ukagaka", "shiori", "ghost", "sakura-script"]
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`pp.unicode.fun, true⟩]

require "leanprover-community" / batteries @ git "main"

require Repl from git "https://github.com/leanprover-community/repl"

require LemmaGeneralis from git "https://github.com/rejafdofs/LemmaGeneralis"@"main"

lean_lib Signaculum where globs :=
  #[`Signaculum,
    `Signaculum.Protocollum, `Signaculum.Protocollum.Typi, `Signaculum.Protocollum.Rogatio, `Signaculum.Protocollum.Responsum,
    `Signaculum.Sakura.Typi, `Signaculum.Sakura.Fundamentum,
    `Signaculum.Sakura.Textus, `Signaculum.Sakura.Fenestra, `Signaculum.Sakura.Systema, `Signaculum.Sakura.Scriptum,
    `Signaculum.Nucleus, `Signaculum.Nucleus.Nuculum, `Signaculum.Nucleus.Exporta, `Signaculum.Nucleus.Loop,
    `Signaculum.Memoria.StatusPermanens, `Signaculum.Memoria.Citatio, `Signaculum.Memoria.Citationes,
    `Signaculum.Memoria.Auxilia, `Signaculum.Memoria.Lemma,
    `Signaculum.Elementa, `Signaculum.Elementa.Axiom, `Signaculum.Elementa.Lemma, `Signaculum.Elementa.Varia,
    `Signaculum.Sakura.SyntaxisSakuraScripti,
    `Signaculum.Sstp, `Signaculum.Syntaxis]

lean_lib TestGhost where
  globs := #[`TestGhost]

lean_exe ghost where
  root := `Main
