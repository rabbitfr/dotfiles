print "Loading helpers.ahk`n"

;
; Log helpers
;
global logLevel := "INFO"

print(message) {
    try {
        ; FileAppend message "`n", "*"
        FileAppend message, "*"
    } catch {

    }
}

info(message) {
    if (logLevel == "INFO")
        print message
}


debug(message) {
    if (logLevel == "DEBUG")
        print message
}

;
; Loop helpers
;

range(start, stop) {
    range := []
    loops := stop - start + 1
    loop loops {
        range.Push(start + A_Index - 1)
    }
    return range
}


;
; Map helpers
;

put(map, key, value) {
    values := map.Get(key, [])
    values.Push(value)
    map.Set(key, values)
}


getNonitorId() {
    if (MonitorGetCount() == 1) {
        return 1
    }
    else {
        return 1
        ; not implemented
        ; Get the current monitor the mouse cusor is in.
        ; DllCall("GetCursorPos", "uint64*", &point := 0)
        ; DllCall("MonitorFromPoint", "uint64", point, "uint", 0x2, "ptr")
    }
}

padEnd(string, length, char) {
    toPad := length - StrLen("" string)

    ; print "padding " string " ,loops " toPad

    Loop toPad {
        string := string char
    }

    return string
}

distance(X1, y1, x2, y2) {
    return Sqrt(((x2 - x1) * (x2 - x1)) + ((y2 - y1) * (y2 - y1)))
}

indexOf(array, value) {

    for candidate in array {
        if (candidate == value) {
            return A_Index
        }
    }
    return -1
}

; move window and fix offset from invisible border
WinMoveEx(x?, y?, w?, h?, hwnd?) {
    if !(hwnd is integer)
        hwnd := WinExist(hwnd)
    if !IsSet(hwnd)
        hwnd := WinExist()

    ; compare pos and get offset
    WinGetPosEx(&fX, &fY, &fW, &fH, hwnd)
    WinGetPos(&wX, &wY, &wW, &wH, hwnd)
    diffX := fX - wX
    diffY := fY - wY
    diffW := fW - wW
    diffH := fH - wH
    ; print "diffX " diffX  "diffY " diffY "diffW " diffW  "diffH " diffW
    ; new x, y, w, h with offset corrected.
    IsSet(x) && nX := x - diffX
    IsSet(y) && nY := y - diffY
    IsSet(w) && nW := w - diffW
    IsSet(h) && nH := h - diffH
    WinMove(nX?, nY?, nW?, nH?, hwnd?)
}

; get window position without the invisible border
WinGetPosEx(&x?, &y?, &w?, &h?, hwnd?) {
    static DWMWA_EXTENDED_FRAME_BOUNDS := 9

    if !(hwnd is integer)
        hwnd := WinExist(hwnd)
    if !IsSet(hwnd)
        hwnd := WinExist() ; last found window

    DllCall("dwmapi\DwmGetWindowAttribute",
        "ptr", hwnd,
        "uint", DWMWA_EXTENDED_FRAME_BOUNDS,
        "ptr", RECT := Buffer(16, 0),
        "int", RECT.size,
        "uint")
    x := NumGet(RECT, 0, "int")
    y := NumGet(RECT, 4, "int")
    w := NumGet(RECT, 8, "int") - x
    h := NumGet(RECT, 12, "int") - y
}

AltTabWindows() { ; modernized, original by ophthalmos https://www.autohotkey.com/boards/viewtopic.php?t=13288
    static WS_EX_APPWINDOW := 0x40000 ; has a taskbar button
    static WS_EX_TOOLWINDOW := 0x80 ; does not appear on the Alt-Tab list
    static GW_OWNER := 4 ; identifies as the owner window

    ; Get the current monitor the mouse cusor is in.
    DllCall("GetCursorPos", "uint64*", &point := 0)
    hMonitor := DllCall("MonitorFromPoint", "uint64", point, "uint", 0x2, "ptr")

    AltTabList := []

    DetectHiddenWindows False     ; makes IsWindowVisible and DWMWA_CLOAKED unnecessary in subsequent call to WinGetList()

    for hwnd in WinGetList() {    ; gather a list of running programs

        ; Check if the window is on the same monitor.
        if hMonitor == DllCall("MonitorFromWindow", "ptr", hwnd, "uint", 0x2, "ptr") {

            ; Find the top-most owner of the child window.
            owner := DllCall("GetAncestor", "ptr", hwnd, "uint", GA_ROOTOWNER := 3, "ptr")
            owner := owner || hwnd ; Above call could be zero.

            ; Check to make sure that the active window is also the owner window.
            if (DllCall("GetLastActivePopup", "ptr", owner) = hwnd) {

                ; Get window extended style.
                es := WinGetExStyle(hwnd)

                ; Must appear on the Alt+Tab list, have a taskbar button, and not be a Windows 10 background app.
                if (!(es & WS_EX_TOOLWINDOW) || (es & WS_EX_APPWINDOW))
                    AltTabList.push(hwnd)
            }
        }
    }

    return AltTabList
}

DrawBorder(hwnd, color := 0xFF0000, enable := 1) {
    static DWMWA_BORDER_COLOR := 34
    static DWMWA_COLOR_DEFAULT := 0xFFFFFFFF
    R := (color & 0xFF0000) >> 16
    G := (color & 0xFF00) >> 8
    B := (color & 0xFF)
    color := (B << 16) | (G << 8) | R
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_BORDER_COLOR, "int*", enable ? color : DWMWA_COLOR_DEFAULT, "int", 4)
}