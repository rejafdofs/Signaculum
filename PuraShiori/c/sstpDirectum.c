/* PuraShiori/c/sstpDirectum.c
 * ディレクトゥム SSTP — WM_COPYDATA ヴィアー SSP ニ スクリプトゥムヲ ミッテレ スルニャン
 * ソケットゥムヲ ツカハズニ ウィンドウズ IPC ヲ ツカフニャン */

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <string.h>
#include <lean/lean.h>

/* ディレクトゥム SSTP — dwData = 9801，lpData = SSTP/1.4 リクウェスティオ（UTF-8） */
static int sstp_directum_mittere_raw(const char* data, DWORD size) {
    HWND hwnd = FindWindowExA(NULL, NULL, "SSP", NULL);
    if (hwnd == NULL) return -1;
    COPYDATASTRUCT cds;
    cds.dwData = 9801;
    cds.cbData = size;
    cds.lpData = (PVOID)data;
    SendMessageA(hwnd, WM_COPYDATA, (WPARAM)NULL, (LPARAM)&cds);
    return 0;
}

/* Lean FFI エントリーポイントゥム — ストリングヲ ウケトッテ ソウシン スルニャン */
LEAN_EXPORT lean_obj_res sstp_directum_mittere(lean_obj_arg request, lean_obj_arg world) {
    const char* str = lean_string_cstr(request);
    /* strlen ヲ ツカフ — lean_string_byte_size ハ ヌルジヲ フクムカラニャン */
    sstp_directum_mittere_raw(str, (DWORD)strlen(str));
    return lean_io_result_mk_ok(lean_box(0));
}
