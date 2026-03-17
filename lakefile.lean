import Lake

open System Lake DSL

package PuraShiori where
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
  let srcFile := pkg.dir / "PuraShiori" / "c" / "sstpDirectum.c"
  let oFile := pkg.buildDir / "c" / "sstpDirectum.o"
  let libFile := pkg.buildDir / "lib" / nameToStaticLib "sstpDirectum"
  Job.async do
    buildFileUnlessUpToDate' oFile do
      -- PuraShiori/c/include を先に置くことで stddef.h スタブが lean.h より優先されるにゃん
      let stubInclude := pkg.dir / "PuraShiori" / "c" / "include"
      compileO oFile srcFile #[s!"-I{stubInclude}", s!"-I{leanIncludeDir}"] lean.cc
    buildFileUnlessUpToDate' libFile do
      compileStaticLib libFile #[oFile]
    return libFile

lean_lib PuraShiori where globs :=
  #[`PuraShiori, `PuraShiori.Protocollum, `PuraShiori.Sakura.Typi, `PuraShiori.Sakura.Fundamentum,
    `PuraShiori.Sakura.Textus, `PuraShiori.Sakura.Fenestra, `PuraShiori.Sakura.Systema, `PuraShiori.Sakura.Scriptum,
    `PuraShiori.Rogatio, `PuraShiori.Responsum, `PuraShiori.Nuculum, `PuraShiori.Exporta,
    `PuraShiori.Memoria.StatusPermanens, `PuraShiori.Memoria.Lemma, `PuraShiori.Sstp, `PuraShiori.Syntaxis]
