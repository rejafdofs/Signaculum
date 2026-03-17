/* PuraShiori/c/sstpDirectum.c
 * ディレクトゥム SSTP — WM_COPYDATA 経由で SSP にスクリプトゥムを送信するにゃん
 * windows.h を使はずに必要な型・函數を手動宣言するにゃん（Lean 附属 clang は Windows SDK を持たないからにゃ） */

#include <stdint.h>
#include <string.h>
#include <lean/lean.h>

/* Windows 型の手動宣言にゃん */
typedef void*     HWND;
typedef uintptr_t WPARAM;
typedef intptr_t  LPARAM;
typedef intptr_t  LRESULT;
typedef uint32_t  DWORD;
typedef void*     PVOID;

typedef struct {
    DWORD dwData;
    DWORD cbData;
    PVOID lpData;
} COPYDATASTRUCT;

#define WM_COPYDATA 0x004A

/* Win32 API 宣言にゃん */
extern HWND   __stdcall FindWindowExA(HWND, HWND, const char*, const char*);
extern LRESULT __stdcall SendMessageA(HWND, unsigned int, WPARAM, LPARAM);

/* ディレクトゥム SSTP — dwData = 9801，lpData = SSTP/1.4 リクウェスティオ（UTF-8）にゃん */
static int sstp_directum_mittere_raw(const char* data, DWORD size) {
    HWND hwnd = FindWindowExA(NULL, NULL, "SSP", NULL);
    if (hwnd == NULL) return -1;
    COPYDATASTRUCT cds;
    cds.dwData = 9801;
    cds.cbData = size;
    cds.lpData = (PVOID)data;
    SendMessageA(hwnd, WM_COPYDATA, (WPARAM)0, (LPARAM)&cds);
    return 0;
}

/* Lean FFI エントリーポイントゥム — 文字列を受け取つて送信するにゃん */
LEAN_EXPORT lean_obj_res sstp_directum_mittere(lean_obj_arg request, lean_obj_arg world) {
    const char* str = lean_string_cstr(request);
    /* strlen を使ふ — lean_string_byte_size はヌル終端文字を含むからにゃん */
    sstp_directum_mittere_raw(str, (DWORD)strlen(str));
    return lean_io_result_mk_ok(lean_box(0));
}
