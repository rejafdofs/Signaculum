/* PuraShiori/c/sstpDirectum.c
 * ディレクトゥム SSTP — WM_COPYDATA 経由で SSP にスクリプトゥムを送信するにゃん
 * lean/lean.h のインライン關數を使ふのでインクルードするにゃん
 * stddef.h は PuraShiori/c/include/ の自前スタブを使ふにゃん */
#include <lean/lean.h>

/* ═══════════════════════════════════════
 * Win32 API の手動宣言にゃん（Windows 専用にゃ）
 * ═══════════════════════════════════════ */
#ifdef _WIN32

typedef void*              HWND;
typedef void*              PVOID;
typedef unsigned int       DWORD;
typedef unsigned long long WPARAM;
typedef long long          LPARAM;
typedef long long          LRESULT;

typedef struct {
    DWORD dwData;
    DWORD cbData;
    PVOID lpData;
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

LEAN_EXPORT lean_obj_res sstp_directum_mittere(lean_obj_arg request, lean_obj_arg world) {
    char const* str = lean_string_cstr(request);
    sstp_directum_mittere_raw(str, str_len(str));
    return lean_io_result_mk_ok(lean_box(0));
}

#else /* _WIN32 でない環境向けのスタブにゃん */

LEAN_EXPORT lean_obj_res sstp_directum_mittere(lean_obj_arg request, lean_obj_arg world) {
    (void)request; (void)world;
    return lean_io_result_mk_ok(lean_box(0));
}

#endif /* _WIN32 */
