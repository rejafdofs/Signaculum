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

extern_lib sstpDirectum pkg := do
  let lean ← getLeanInstall
  let leanIncludeDir ← getLeanIncludeDir
  let srcFile := pkg.dir / "Signaculum" / "c" / "sstpDirectum.c"
  let oFile := pkg.buildDir / "c" / "sstpDirectum.o"
  let libFile := pkg.buildDir / "lib" / nameToStaticLib "sstpDirectum"
  Job.async do
    buildFileUnlessUpToDate' oFile do
      -- Lean がモジュールのネイティヴコンパイルに使ふのと同じフラグにゃん
      -- lean.sysroot/include/clang に stddef.h・stdbool.h 等が含まれるにゃ
      let clangInclude := lean.sysroot / "include" / "clang"
      compileO oFile srcFile
        #[s!"-I{leanIncludeDir}",
          s!"--sysroot={lean.sysroot}",
          "-nostdinc",
          s!"-isystem{clangInclude}",
          "-DNDEBUG"]
        lean.cc
    buildFileUnlessUpToDate' libFile do
      compileStaticLib libFile #[oFile]
    return libFile

lean_lib Signaculum where globs :=
  #[`Signaculum, `Signaculum.Protocollum, `Signaculum.Sakura.Typi, `Signaculum.Sakura.Fundamentum,
    `Signaculum.Sakura.Textus, `Signaculum.Sakura.Fenestra, `Signaculum.Sakura.Systema, `Signaculum.Sakura.Scriptum,
    `Signaculum.Rogatio, `Signaculum.Responsum, `Signaculum.Nuculum, `Signaculum.Exporta, `Signaculum.Loop,
    `Signaculum.Memoria.StatusPermanens, `Signaculum.Memoria.Citatio, `Signaculum.Memoria.Citationes,
    `Signaculum.Memoria.Auxilia, `Signaculum.Memoria.Lemma,
    `Signaculum.Axiom, `Signaculum.Lemma, `Signaculum.Varia,
    `Signaculum.Sstp, `Signaculum.Syntaxis]

lean_lib TestGhost where
  globs := #[`TestGhost]

lean_exe ghost where
  root := `Main
