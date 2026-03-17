/* stddef.h — lean/lean.h 用最小スタブにゃん
 * Lean 附属 clang は標準ヘッダーを持たないので手動で用意するにゃん */
#pragma once
typedef unsigned long long size_t;
typedef long long          ptrdiff_t;
typedef long long          intptr_t;
typedef unsigned long long uintptr_t;
#define NULL ((void*)0)
#define offsetof(type, member) __builtin_offsetof(type, member)
