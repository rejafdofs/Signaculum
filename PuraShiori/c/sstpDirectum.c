/* PuraShiori/c/sstpDirectum.c
 * ディレクトゥム SSTP — WM_COPYDATA 経由で SSP にスクリプトゥムを送信するにゃん
 * lean/lean.h のインライン關數を使ふのでインクルードするにゃん
 * 標準ヘッダーは -nostdinc -isystem {sysroot}/include/clang で解決するにゃん */
#include <lean/lean.h>

/* ═══════════════════════════════════════
 * Win32 API の手動宣言にゃん（Windows 専用にゃ）
 * ═══════════════════════════════════════ */
#ifdef _WIN32

typedef void*              HWND;
typedef void*              PVOID;
typedef unsigned int       DWORD;
typedef unsigned long long ULONG_PTR;  /* ポインタ幅の無符號整數にゃん（64ビット = 8バイト） */
typedef unsigned long long WPARAM;
typedef long long          LPARAM;
typedef long long          LRESULT;

/* 實際の Windows 定義にゃん:
 *   dwData: ULONG_PTR = 8バイト（ポインタ幅）
 *   cbData: DWORD     = 4バイト  ← DWORD のままでよいにゃ
 *   lpData: PVOID     = 8バイト
 * 合計 24バイト（offset 12 に 4バイトのパディングがあるにゃ） */
typedef struct {
    ULONG_PTR dwData;  /* 識別子 — 9801 にゃん */
    DWORD     cbData;  /* データバイト數にゃん */
    PVOID     lpData;  /* データへのポインタにゃん */
} COPYDATASTRUCT;

#define WM_COPYDATA 0x004A

extern HWND    __stdcall FindWindowExA(HWND, HWND, char const*, char const*);
extern LRESULT __stdcall SendMessageA(HWND, unsigned int, WPARAM, LPARAM);

/* lean_string_byte_size はヌル終端文字を含むので自前で長さを數へるにゃん */
static DWORD str_len(char const* s) {
    DWORD n = 0;
    while (s[n]) n++;
    return n;
}

static void sstp_directum_mittere_raw(char const* data, DWORD size) {
    HWND hwnd = FindWindowExA((HWND)0, (HWND)0, "SSP", (char const*)0);
    if (hwnd == (HWND)0) return;
    COPYDATASTRUCT cds;
    cds.dwData = 9801;
    cds.cbData = size;
    cds.lpData = (PVOID)data;
    SendMessageA(hwnd, WM_COPYDATA, (WPARAM)0, (LPARAM)&cds);
}

/* request は @& String（借用参照）なので b_lean_obj_arg にゃん
 * lean_obj_arg（所有）を使ふと呼出し後に参照カウントが誤って减算されるにゃ */
LEAN_EXPORT lean_obj_res sstp_directum_mittere(b_lean_obj_arg request, lean_obj_arg world) {
    char const* str = lean_string_cstr(request);
    sstp_directum_mittere_raw(str, str_len(str));
    return lean_io_result_mk_ok(lean_box(0));
}

#else /* _WIN32 でない環境向けのスタブにゃん */

/* request は @& String（借用参照）なので b_lean_obj_arg にゃん
 * lean_obj_arg（所有）を使ふと呼出し後に参照カウントが誤って减算されるにゃ */
LEAN_EXPORT lean_obj_res sstp_directum_mittere(b_lean_obj_arg request, lean_obj_arg world) {
    (void)request; (void)world;
    return lean_io_result_mk_ok(lean_box(0));
}

#endif /* _WIN32 */
