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

lean_lib Signaculum where globs := #[.submodules `Signaculum]

lean_lib TestGhost where
  globs := #[`TestGhost]

lean_exe ghost where
  root := `Main
