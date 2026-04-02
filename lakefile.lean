import Lake

open System Lake DSL

package Signaculum where
  version := v!"0.1.0"
  description := "Lean 4 製 SHIORI/3.0 栞(Ukagaka ghost)ビブリオテーカ(bibliotheca)"
  keywords := #["ukagaka", "shiori", "ghost", "sakura-script"]
  leanOptions := #[⟨`autoImplicit, false⟩, ⟨`pp.unicode.fun, true⟩]

require LemmaGeneralis from git "https://github.com/rejafdofs/LemmaGeneralis"@"main"

lean_lib Signaculum where globs := #[.one `Signaculum, .submodules `Signaculum]

lean_exe testGhost where
  root := `TestGhost

lean_exe testIntegratio where
  root := `TestIntegratio

lean_exe ghost where
  root := `Main
