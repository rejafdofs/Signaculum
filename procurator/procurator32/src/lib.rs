/*! procurator32.c の Rust 版にゃん♪
 * 32-bit DLL として SSP に讀み込まれ、ghost.exe へパイプで仕事を丸投げするにゃ
 */
#![allow(non_snake_case)]

use std::collections::HashMap;
use std::io::{Read, Write};
use std::os::windows::process::CommandExt;
use std::process::{Child, ChildStdin, ChildStdout, Command, Stdio};
use std::sync::Mutex;
use windows_sys::Win32::Foundation::{BOOL, HMODULE};
use windows_sys::Win32::Globalization::{
    MultiByteToWideChar, WideCharToMultiByte, CP_ACP, CP_UTF8,
};
use windows_sys::Win32::System::LibraryLoader::{FreeLibrary, GetProcAddress, LoadLibraryW};
use windows_sys::Win32::System::Memory::{GlobalAlloc, GlobalLock, GlobalUnlock, GMEM_FIXED};

type HGLOBAL = *mut core::ffi::c_void;

macro_rules! log_trace {
    ($($arg:tt)*) => {
        // Logging disabled for release (depurgatio inactivata)
        // if let Ok(mut file) = std::fs::OpenOptions::new()
        //     .create(true)
        //     .append(true)
        //     .open("C:\\Users\\a\\procurator32_trace.txt")
        // {
        //     use std::io::Write;
        //     let _ = writeln!(file, $($arg)*);
        // }
    };
}

// にゃ：SSP は Windows ANSI(CP_ACP) でパスを渡すにゃ。Shift_JIS 等でも正しく變換するにゃ
fn ansi_bytes_to_string(bytes: &[u8]) -> String {
    // 末尾のヌル・バックスラッシュを取り除くにゃ
    let trimmed = match bytes.iter().rposition(|&b| b != 0 && b != b'\\') {
        Some(pos) => &bytes[..=pos],
        None => return String::new(),
    };
    // CP_ACP = 0
    let wlen = unsafe {
        MultiByteToWideChar(
            CP_ACP,
            0,
            trimmed.as_ptr() as _,
            trimmed.len() as i32,
            core::ptr::null_mut(),
            0,
        )
    };
    if wlen <= 0 {
        return String::from_utf8_lossy(trimmed).into_owned();
    }
    let mut wbuf = vec![0u16; wlen as usize];
    unsafe {
        MultiByteToWideChar(
            CP_ACP,
            0,
            trimmed.as_ptr() as _,
            trimmed.len() as i32,
            wbuf.as_mut_ptr(),
            wlen,
        );
    }
    String::from_utf16_lossy(&wbuf)
}

// Windows ANSI(Shift_JIS) のバイト列を UTF-8文字列のバイト列に變換するにゃん
fn ansi_to_utf8_bytes(bytes: &[u8]) -> Vec<u8> {
    let wlen = unsafe {
        MultiByteToWideChar(
            CP_ACP,
            0,
            bytes.as_ptr() as _,
            bytes.len() as i32,
            core::ptr::null_mut(),
            0,
        )
    };
    if wlen <= 0 {
        return bytes.to_vec(); // フォールバック(代替)にゃ
    }
    let mut wbuf = vec![0u16; wlen as usize];
    unsafe {
        MultiByteToWideChar(
            CP_ACP,
            0,
            bytes.as_ptr() as _,
            bytes.len() as i32,
            wbuf.as_mut_ptr(),
            wlen,
        );
    }

    let u8len = unsafe {
        WideCharToMultiByte(
            CP_UTF8,
            0,
            wbuf.as_ptr(),
            wlen,
            core::ptr::null_mut(),
            0,
            core::ptr::null_mut(),
            core::ptr::null_mut(),
        )
    };
    if u8len <= 0 {
        return bytes.to_vec();
    }
    let mut u8buf = vec![0u8; u8len as usize];
    unsafe {
        WideCharToMultiByte(
            CP_UTF8,
            0,
            wbuf.as_ptr(),
            wlen,
            u8buf.as_mut_ptr() as _,
            u8len,
            core::ptr::null_mut(),
            core::ptr::null_mut(),
        );
    }
    u8buf
}

// UTF-8文字列のバイト列を Windows ANSI(Shift_JIS) のバイト列に變換するにゃん
fn utf8_to_ansi_bytes(bytes: &[u8]) -> Vec<u8> {
    let wlen = unsafe {
        MultiByteToWideChar(
            CP_UTF8,
            0,
            bytes.as_ptr() as _,
            bytes.len() as i32,
            core::ptr::null_mut(),
            0,
        )
    };
    if wlen <= 0 {
        return bytes.to_vec();
    }
    let mut wbuf = vec![0u16; wlen as usize];
    unsafe {
        MultiByteToWideChar(
            CP_UTF8,
            0,
            bytes.as_ptr() as _,
            bytes.len() as i32,
            wbuf.as_mut_ptr(),
            wlen,
        );
    }

    let ansi_len = unsafe {
        WideCharToMultiByte(
            CP_ACP,
            0,
            wbuf.as_ptr(),
            wlen,
            core::ptr::null_mut(),
            0,
            core::ptr::null_mut(),
            core::ptr::null_mut(),
        )
    };
    if ansi_len <= 0 {
        return bytes.to_vec();
    }
    let mut ansi_buf = vec![0u8; ansi_len as usize];
    unsafe {
        WideCharToMultiByte(
            CP_ACP,
            0,
            wbuf.as_ptr(),
            wlen,
            ansi_buf.as_mut_ptr() as _,
            ansi_len,
            core::ptr::null_mut(),
            core::ptr::null_mut(),
        );
    }
    ansi_buf
}

// にゃ：SSP は基本的に單一スレッドで SHIORI を呼ぶので Mutex で十分にゃ
struct Nexus {
    _filius: Child,
    calamus: ChildStdin, // 子プロケッスス stdin
    rivus: ChildStdout,  // 子プロケッスス stdout
}

static NEXUS: Mutex<Option<Nexus>> = Mutex::new(None);

// SAORI DLL 管理にゃん♪ ロード濟みモジュールを保持するにゃ
static SAORI_MODULES: Mutex<Option<HashMap<String, HMODULE>>> = Mutex::new(None);

// SAORI C ABI 型定義にゃ
type SaoriLoadFn = unsafe extern "C" fn(h: HGLOBAL, len: i32) -> BOOL;
type SaoriRequestFn = unsafe extern "C" fn(h: HGLOBAL, len: *mut i32) -> HGLOBAL;
type SaoriUnloadFn = unsafe extern "C" fn() -> BOOL;

// ═══════════════════════════════════════════════════
// SAORI 補助關數にゃん♪
// ═══════════════════════════════════════════════════

/// UTF-8 文字列を UTF-16 のヌル終端ワイド文字列に變換するにゃ
fn utf8_to_wide(s: &str) -> Vec<u16> {
    s.encode_utf16().chain(std::iter::once(0)).collect()
}

/// SAORI DLL をロードして load() を呼ぶにゃん♪
/// via: DLL パス（UTF-8）、hdir: ghost ディレクトーリウムパス（UTF-8）
/// 成功なら true を返すにゃ
fn saori_onerare(via: &str, hdir: &str) -> bool {
    log_trace!("[SAORI] onerare: via={}, hdir={}", via, hdir);
    let mut guard = SAORI_MODULES.lock().unwrap();
    let modules = guard.as_mut().expect("SAORI_MODULES non initialisatus にゃ！");

    // 既にロード濟みなら成功扱ひにゃ
    if modules.contains_key(via) {
        log_trace!("[SAORI] iam oneratus: {}", via);
        return true;
    }

    let wide_path = utf8_to_wide(via);
    let hmodule = unsafe { LoadLibraryW(wide_path.as_ptr()) };
    if hmodule.is_null() {
        log_trace!("[SAORI] LoadLibraryW failed: {}", via);
        return false;
    }

    // load 關數を取得して呼ぶにゃん
    let load_fn = unsafe { GetProcAddress(hmodule, b"load\0".as_ptr()) };
    if let Some(load_fn) = load_fn {
        let load: SaoriLoadFn = unsafe { core::mem::transmute(load_fn) };
        // hdir を HGLOBAL に詰めて渡すにゃ（SAORI は Shift_JIS を期待する DLL が多いにゃ）
        let hdir_ansi = utf8_to_ansi_bytes(hdir.as_bytes());
        let hdir_len = hdir_ansi.len();
        let hg = unsafe { GlobalAlloc(GMEM_FIXED, hdir_len + 1) } as HGLOBAL;
        if !hg.is_null() {
            unsafe {
                let ptr = hg as *mut u8;
                core::ptr::copy_nonoverlapping(hdir_ansi.as_ptr(), ptr, hdir_len);
                *ptr.add(hdir_len) = 0;
            }
            let res = unsafe { load(hg, hdir_len as i32) };
            log_trace!("[SAORI] load() returned: {}", res);
            // SAORI の load は自前で HGLOBAL を管理するので解放しにゃい
            if res == 0 {
                unsafe { FreeLibrary(hmodule) };
                return false;
            }
        }
    } else {
        log_trace!("[SAORI] load 關數が見つからにゃい: {}", via);
        unsafe { FreeLibrary(hmodule) };
        return false;
    }

    modules.insert(via.to_string(), hmodule);
    log_trace!("[SAORI] onerare success: {}", via);
    true
}

/// SAORI DLL に request を送信するにゃん♪
/// via: DLL パス、rogatio: SAORI/1.0 リクエスト文字列（UTF-8）
/// 應答文字列（UTF-8）を返すにゃ
fn saori_rogare(via: &str, rogatio: &[u8]) -> Vec<u8> {
    log_trace!("[SAORI] rogare: via={}, len={}", via, rogatio.len());
    let guard = SAORI_MODULES.lock().unwrap();
    let modules = guard.as_ref().expect("SAORI_MODULES non initialisatus にゃ！");

    let hmodule = match modules.get(via) {
        Some(h) => *h,
        None => {
            log_trace!("[SAORI] non oneratus: {}", via);
            return Vec::new();
        }
    };

    let request_fn = unsafe { GetProcAddress(hmodule, b"request\0".as_ptr()) };
    let request_fn = match request_fn {
        Some(f) => f,
        None => {
            log_trace!("[SAORI] request 關數が見つからにゃい: {}", via);
            return Vec::new();
        }
    };

    let request: SaoriRequestFn = unsafe { core::mem::transmute(request_fn) };

    // SAORI は Shift_JIS を期待するものが多いにゃ。UTF-8 の SAORI リクエストゥムを ANSI に變換するにゃん
    let ansi_req = utf8_to_ansi_bytes(rogatio);
    let req_len = ansi_req.len();
    let hg = unsafe { GlobalAlloc(GMEM_FIXED, req_len + 1) } as HGLOBAL;
    if hg.is_null() {
        log_trace!("[SAORI] GlobalAlloc failed for request");
        return Vec::new();
    }
    unsafe {
        let ptr = hg as *mut u8;
        core::ptr::copy_nonoverlapping(ansi_req.as_ptr(), ptr, req_len);
        *ptr.add(req_len) = 0;
    }

    let mut resp_len: i32 = req_len as i32;
    let resp_h = unsafe { request(hg, &mut resp_len) };

    if resp_h.is_null() || resp_len <= 0 {
        log_trace!("[SAORI] request returned null/empty");
        return Vec::new();
    }

    let resp_bytes = unsafe {
        let ptr = GlobalLock(resp_h as _) as *const u8;
        let bytes = core::slice::from_raw_parts(ptr, resp_len as usize).to_vec();
        GlobalUnlock(resp_h as _);
        bytes
    };

    // 應答を ANSI → UTF-8 に變換するにゃん
    let utf8_resp = ansi_to_utf8_bytes(&resp_bytes);
    log_trace!("[SAORI] rogare resp len={}", utf8_resp.len());
    utf8_resp
}

/// SAORI DLL をアンロードするにゃん♪
fn saori_exonerare(via: &str) {
    log_trace!("[SAORI] exonerare: {}", via);
    let mut guard = SAORI_MODULES.lock().unwrap();
    let modules = guard.as_mut().expect("SAORI_MODULES non initialisatus にゃ！");

    if let Some(hmodule) = modules.remove(via) {
        // unload 關數を呼ぶにゃん
        let unload_fn = unsafe { GetProcAddress(hmodule, b"unload\0".as_ptr()) };
        if let Some(unload_fn) = unload_fn {
            let unload: SaoriUnloadFn = unsafe { core::mem::transmute(unload_fn) };
            let _ = unsafe { unload() };
        }
        unsafe { FreeLibrary(hmodule) };
        log_trace!("[SAORI] exonerare success: {}", via);
    } else {
        log_trace!("[SAORI] exonerare: non oneratus: {}", via);
    }
}

/// 全ての SAORI DLL をアンロードするにゃん♪（unload 時に呼ぶにゃ）
fn saori_exonerare_omnes() {
    log_trace!("[SAORI] exonerare_omnes");
    let mut guard = SAORI_MODULES.lock().unwrap();
    if let Some(modules) = guard.as_mut() {
        let viae: Vec<String> = modules.keys().cloned().collect();
        for via in &viae {
            if let Some(hmodule) = modules.remove(via.as_str()) {
                let unload_fn = unsafe { GetProcAddress(hmodule, b"unload\0".as_ptr()) };
                if let Some(unload_fn) = unload_fn {
                    let unload: SaoriUnloadFn = unsafe { core::mem::transmute(unload_fn) };
                    let _ = unsafe { unload() };
                }
                unsafe { FreeLibrary(hmodule) };
            }
        }
    }
    *guard = None;
}

/// パイプから SAORI コマンドを處理するにゃん♪
/// ghost.exe が最終應答（0x00）を返すまでループするにゃ
/// 戻り値は最終應答のバイト列にゃ
fn tractare_saori_circulum(
    calamus: &mut ChildStdin,
    rivus: &mut ChildStdout,
) -> std::io::Result<Vec<u8>> {
    loop {
        // コマンドバイトを讀むにゃん
        let mut cmd = [0u8; 1];
        rivus.read_exact(&mut cmd)?;

        match cmd[0] {
            // 0x00: 最終應答にゃ — [len:u32LE][response]
            0x00 => {
                let resp_len = lege_u32(rivus)? as usize;
                if resp_len == 0 {
                    return Ok(Vec::new());
                }
                let mut resp = vec![0u8; resp_len];
                rivus.read_exact(&mut resp)?;
                return Ok(resp);
            }
            // 0x04: SAORI load にゃ — [pathLen:u32][dllPath][hdirLen:u32][hdir]
            0x04 => {
                let path_len = lege_u32(rivus)? as usize;
                let mut path_buf = vec![0u8; path_len];
                rivus.read_exact(&mut path_buf)?;
                let hdir_len = lege_u32(rivus)? as usize;
                let mut hdir_buf = vec![0u8; hdir_len];
                rivus.read_exact(&mut hdir_buf)?;
                let via = String::from_utf8_lossy(&path_buf).to_string();
                let hdir = String::from_utf8_lossy(&hdir_buf).to_string();
                let ok = saori_onerare(&via, &hdir);
                // 應答: [0/1: u8]
                calamus.write_all(&[if ok { 1u8 } else { 0u8 }])?;
                calamus.flush()?;
            }
            // 0x05: SAORI request にゃ — [pathLen:u32][dllPath][reqLen:u32][requestStr]
            0x05 => {
                let path_len = lege_u32(rivus)? as usize;
                let mut path_buf = vec![0u8; path_len];
                rivus.read_exact(&mut path_buf)?;
                let req_len = lege_u32(rivus)? as usize;
                let mut req_buf = vec![0u8; req_len];
                rivus.read_exact(&mut req_buf)?;
                let via = String::from_utf8_lossy(&path_buf).to_string();
                let resp = saori_rogare(&via, &req_buf);
                // 應答: [respLen:u32LE][respStr]
                scribe_u32(calamus, resp.len() as u32)?;
                if !resp.is_empty() {
                    calamus.write_all(&resp)?;
                }
                calamus.flush()?;
            }
            // 0x06: SAORI unload にゃ — [pathLen:u32][dllPath]
            0x06 => {
                let path_len = lege_u32(rivus)? as usize;
                let mut path_buf = vec![0u8; path_len];
                rivus.read_exact(&mut path_buf)?;
                let via = String::from_utf8_lossy(&path_buf).to_string();
                saori_exonerare(&via);
                // アンロードに應答は不要にゃ
            }
            other => {
                log_trace!("[SAORI] unknown command byte: {}", other);
                // 不明なコマンドは無視するにゃ
            }
        }
    }
}

fn scribe_u32(w: &mut impl Write, v: u32) -> std::io::Result<()> {
    w.write_all(&v.to_le_bytes())
}

fn lege_u32(r: &mut impl Read) -> std::io::Result<u32> {
    let mut b = [0u8; 4];
    r.read_exact(&mut b)?;
    Ok(u32::from_le_bytes(b))
}

// SSP は HGLOBAL に格納された文字列 + 長さを渡す。戻り値は BOOL にゃ
#[unsafe(no_mangle)]
pub unsafe extern "C" fn load(h: HGLOBAL, len: i32) -> BOOL {
    log_trace!("=== load called (len={}) ===", len);
    // ① ディレクトーリウム文字列を取り出して HGLOBAL を開放するにゃ
    let via_bytes = {
        let ptr = GlobalLock(h) as *const u8;
        let bytes = core::slice::from_raw_parts(ptr, len as usize).to_vec();
        GlobalUnlock(h);
        bytes
    };

    let via = ansi_bytes_to_string(&via_bytes);
    if via.is_empty() {
        log_trace!("load failed: ansi_bytes_to_string empty");
        return 0;
    }
    log_trace!("load via: {}", via);

    // ② ghost.exe を起動するにゃ（同じディレクトーリウムにあるはずにゃ）
    let host_via = format!("{via}\\ghost.exe");

    let stderr_file = std::fs::File::create("C:\\Users\\a\\ghost_host_stderr.txt")
        .unwrap_or_else(|_| std::fs::File::create("nul").unwrap());

    let mut filius = match Command::new(&host_via)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::from(stderr_file))
        .creation_flags(0x08000000) // CREATE_NO_WINDOW
        .spawn()
    {
        Ok(c) => c,
        Err(_) => {
            log_trace!("load failed: failed to spawn ghost.exe");
            return 0;
        }
    };
    let mut calamus = filius.stdin.take().unwrap();
    let mut rivus = filius.stdout.take().unwrap();

    // ③ ONERARE(load) 命令を送るにゃ: [1u8][len:u32LE][bytes]
    // ghost.dll(Lean) は UTF-8 を前提にするにゃ。ANSI パスを UTF-8 に變換して送るにゃん！
    let utf8_via = ansi_to_utf8_bytes(&via_bytes);
    log_trace!(
        "load sending UTF-8 path ({} bytes): {}",
        utf8_via.len(),
        String::from_utf8_lossy(&utf8_via)
    );
    let ok = calamus.write_all(&[1u8]).is_ok()
        && scribe_u32(&mut calamus, utf8_via.len() as u32).is_ok()
        && calamus.write_all(&utf8_via).is_ok()
        && calamus.flush().is_ok();
    if !ok {
        log_trace!("load failed: pipe write error");
        return 0;
    }

    // ④ 應答: [0/1: u8]
    let mut resp = [0u8; 1];
    if rivus.read_exact(&mut resp).is_err() || resp[0] == 0 {
        log_trace!("load failed: ghost_host returned false or pipe closed");
        return 0;
    }

    log_trace!("load success");

    // SAORI モジュール管理を初期化するにゃん♪
    *SAORI_MODULES.lock().unwrap() = Some(HashMap::new());

    *NEXUS.lock().unwrap() = Some(Nexus {
        _filius: filius,
        calamus,
        rivus,
    });
    1
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn unload() -> BOOL {
    log_trace!("=== unload called ===");
    // 全ての SAORI DLL を先にアンロードするにゃん♪
    saori_exonerare_omnes();
    if let Some(mut n) = NEXUS.lock().unwrap().take() {
        // ONERARE 終了命令: [2u8]
        let _ = n.calamus.write_all(&[2u8]);
        let _ = n.calamus.flush();
        // 待機すると SSP がタイムアウト等で強制終了（墜落）する恐れがあるため、
        // kill せず、且つ wait もせずに、そのままパイプを閉ぢて終了するにゃ。
        // ghost.exe はパイプから 2 を讀み取った後、自發的に變數を保存して單獨で終了するにゃん♪
        drop(n.calamus);
        drop(n.rivus);
    }
    log_trace!("=== unload done ===");
    1
}

#[unsafe(no_mangle)]
pub unsafe extern "C" fn request(h: HGLOBAL, len: *mut i32) -> HGLOBAL {
    log_trace!("=== request called (len={}) ===", *len);
    // *len は入力時に要求文字列の長さにゃ（GlobalSize ではないにゃん！）
    let rogatio_len = (*len) as usize;
    let raw_rogatio = {
        let ptr = GlobalLock(h) as *const u8;
        let bytes = core::slice::from_raw_parts(ptr, rogatio_len).to_vec();
        GlobalUnlock(h);
        bytes
    };

    // SSP から來た要求が Shift_JIS(ANSI) か UTF-8 か判定するにゃ（Charset: UTF-8 が無ければ ANSI と看做す）
    let is_utf8 = if let Ok(s) = core::str::from_utf8(&raw_rogatio) {
        s.contains("Charset: UTF-8") || s.contains("Charset: utf-8")
    } else {
        false
    };

    let rogatio = if is_utf8 {
        log_trace!("request is UTF-8");
        log_trace!("REQUEST:\n{}", String::from_utf8_lossy(&raw_rogatio));
        raw_rogatio
    } else {
        log_trace!("request is ANSI(Shift_JIS) -> converting to UTF-8");
        // Shift_JIS -> UTF-8 變換をかませるにゃ！ Lean 側は常に UTF-8 として處理できるやうになるにゃ♪
        let u8b = ansi_to_utf8_bytes(&raw_rogatio);
        log_trace!("REQUEST (UTF-8 conv):\n{}", String::from_utf8_lossy(&u8b));
        u8b
    };

    let mut guard = NEXUS.lock().unwrap();
    let n = match guard.as_mut() {
        Some(n) => n,
        None => {
            log_trace!("request failed: no NEXUS (not loaded)");
            *len = 0;
            return core::ptr::null_mut();
        }
    };

    // ROGARE(request) 命令: [3u8][len:u32LE][bytes]
    // 巨大な要求（37KB超）の際にパイプ膠着（Deadlock）を防ぐため、または相手の不慮の死に備へるため
    // 念のためこの書込みを確實に行へるやうにするにゃん。
    let ok = n.calamus.write_all(&[3u8]).is_ok()
        && scribe_u32(&mut n.calamus, rogatio.len() as u32).is_ok()
        && n.calamus.write_all(&rogatio).is_ok()
        && n.calamus.flush().is_ok();
    if !ok {
        log_trace!("request failed: write to ghost_host pipe failed");
        // パイプが壞れた（hostが死んだ）可能性が高いにゃ
        *len = 0;
        return core::ptr::null_mut();
    }

    // 應答(responsum) — SAORI コマンドループ經由で最終應答を待つにゃん♪
    // ghost.exe は SAORI 呼出し（0x04/05/06）を挟んでから最終應答（0x00）を返すにゃ
    let u8_resp = match tractare_saori_circulum(&mut n.calamus, &mut n.rivus) {
        Ok(v) => v,
        Err(_) => {
            log_trace!("request failed: tractare_saori_circulum error");
            *len = 0;
            return core::ptr::null_mut();
        }
    };

    if u8_resp.is_empty() {
        log_trace!("request: resp was empty");
        *len = 0;
        return core::ptr::null_mut();
    }

    // ghost.dll(Lean) は UTF-8 で應答を返すにゃ。元が ANSI なら Shift_JIS に變換して返すにゃん！
    let final_resp = if is_utf8 {
        log_trace!("RESP (UTF-8 pass-through): len={}", u8_resp.len());
        u8_resp
    } else {
        let ansi_r = utf8_to_ansi_bytes(&u8_resp);
        log_trace!(
            "RESP (ANSI conv): len={} -> {}",
            u8_resp.len(),
            ansi_r.len()
        );
        ansi_r
    };
    let final_len = final_resp.len();

    // SSP が文字列を NUL 終端として扱ふ可能性を考慮して +1 確保するにゃん
    let out_h = GlobalAlloc(GMEM_FIXED, final_len + 1) as HGLOBAL;
    if out_h.is_null() {
        log_trace!("request failed: GlobalAlloc returned NULL");
        *len = 0;
        return core::ptr::null_mut();
    }

    let slice = core::slice::from_raw_parts_mut(out_h as *mut u8, final_len + 1);
    slice[..final_len].copy_from_slice(&final_resp);
    slice[final_len] = 0; // NUL 終端にゃ！

    *len = final_len as i32;
    log_trace!("=== request done ===");
    out_h
}
