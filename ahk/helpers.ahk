print "Loading helpers.ahk`n"
#Include constants2.ahk
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


class Zones extends Array {

    __New(cols := 4, rows := 4, margin := 0, spacing := 0) {
        this.cols := cols
        this.rows := rows
        this.margin := margin
        this.spacing := spacing ;  // 2 ; counted double ?
        this.init()
    }

    init() {

        MonitorGetWorkArea(getNonitorId(), &left, &top, &right, &bottom)

        originX := (this.margin) + left
        originY := (this.margin) + top

        areaWidth := (right - left)
        areaHeight := (bottom - top)

        this.cellWidth := (areaWidth - ((this.cols + 1) * this.spacing)) / this.cols
        this.cellHeight := (areaHeight - ((this.rows + 1) * this.spacing)) / this.rows
        ; print "areaWidth "  areaWidth "`n"
        ; print "areaHeight "  areaHeight "`n"
        ; print "CellWidth "  this.cellWidth "`n"
        ; print "cellHeight "  this.cellHeight   "`n"
        ; print "originX "  originX "`n"
        ; print "originY "  originY   "`n"


        ; build all possible zones
        for startRow in range(1, this.rows) {

            for startCol in range(1, this.cols) {

                startIndex := (startRow - 1) * this.cols + startCol
                zoneStart := startIndex

                for stopRow in range(startRow, this.rows) {

                    for stopCol in range(startCol, this.cols) {

                        stopIndex := (stopRow - 1) * this.cols + stopCol
                        zoneStop := stopIndex

                        x := originX + ((startCol - 1) * this.cellWidth) + ((startCol - 1) * this.spacing)
                        y := originY + ((startRow - 1) * this.cellHeight) + ((startRow - 1) * this.spacing)

                        w := this.cellWidth * (stopCol - startCol + 1) + ((stopCol - startCol) * this.spacing)
                        h := this.cellHeight * (stopRow - startRow + 1) + ((stopRow - startRow) * this.spacing)

                        xAsInt := Round(x) + 4 ; add left margin ?
                        yAsInt := Round(y) + 4 ; add top margin ?
                        wAsInt := Round(w) - 6 ; add right spaceing 4 ?
                        hAsInt := Round(h) - 6

                        if ( zoneStop >= 10) {
                            code := (zoneStart * 100 ) + zoneStop
                        } else {
                            code := (zoneStart * 10 ) + zoneStop
                        }
                        ; code := zoneStart "" zoneStop ; may bug, pad
                        newZone := Zone(code, zoneStart, zoneStop, startCol, startRow, stopCol, stopRow, xAsInt, yAsInt, wAsInt, hAsInt)
                        this.Push(newZone)

                        ; print zoneStart " "  zoneStop "`n"
                    }
                }

            }

        }


        ; print "Zones count : " this.zones.Length

        ; for it in this {
        ;     print it.toString() " " namedZones[it.code] "`n"
        ; }
    }

    debugZones(zones) {
        for zone in zones {
            debugGui := Gui(, "zone_" zone.code,)
            debugGuiHandle := debugGui.Hwnd
            debugGui.Show()
            WinMoveEx zone.x, zone.y, zone.w, zone.h, debugGuiHandle
            ; WinGetPosEx(&x,&y,&w,&h,debugGuiHandle)
            ; print zone.toString() "`n"
            ; print "real x " x " y " y " w " w " h" h

        }
    }

    findByCode(code) {
        for zone in this {
            if (zone.code == code)
                return zone

        }
    }

    findByShape(cols, rows) {
        filtered := []
        for candidate in this {
            if (candidate.cols() == cols and candidate.rows() == rows)
                filtered.Push(candidate)
            candidate
        }
        return filtered
    }

    findBySize(size) {
        filtered := []
        for candidate in this {
            if (candidate.size() == size)
                filtered.Push(candidate)

        }
        return filtered
    }

    findMatches(handle := WinGetId("A")) {
        bestMatches := []
        WinGetPosEx(&x, &y, &w, &h, handle)

        for candidate in this {

            centerDistance := candidate.centerDistance(x, y, x + w, y + h)
            startPosDistance := distance(x, y, candidate.x, candidate.y)
            finalDistance := centerDistance + startPosDistance
            ; print "Distance to " candidate.code " : "  finalDistance "`n"
            if (finalDistance <= 40)
                bestMatches.Push(candidate)
        }


        if (bestMatches.Length == 0) {

            state := WinGetMinMax(handle)

            switch state {
                case 0:
                    ; print "Floating `n"
                    newZone := Zone(0, -1, -1, -1, -1, -1, -1, x, y, w, h)
                    bestMatches.Push(newZone)
                case 1:
                    ; print "Max `n"
                    newZone := Zone(9000, -1, -1, -1, -1, -1, -1, x, y, w, h)
                    bestMatches.Push(newZone)
                case -1:
                    ; print "Min `n"
                    newZone := Zone(-1, -1, -1, -1, -1, -1, -1, x, y, w, h)
                    bestMatches.Push(newZone)
            }
            ; print "Guesed " newZone.toString()
        }

        return bestMatches
    }

    findByName(name) {

    }

}

class Zone {

    __New(code, zoneStart, zoneStop, startCol, startRow, stopCol, stopRow, x, y, w, h) {
        this.code := code
        if (namedZones.Has("" this.code))
            this.name := namedZones[""  this.code]
        else
            this.name := "" this.code
        this.zoneStart := zoneStart
        this.zoneStop := zoneStop

        this.startCol := startCol
        this.startRow := startRow
        this.stopCol := stopCol
        this.stopRow := stopRow
        this.x := x
        this.y := y
        this.w := w
        this.h := h
    }

    cols() {
        return (this.stopCol - this.startCol + 1)
    }

    rows() {
        return (this.stopRow - this.startRow + 1)
    }


    size() {
        return this.cols() * this.rows()
    }


    centerDistance(x1, y1, x2, y2) {
        otherCenterX := (x1 + x2) // 2
        otherCenterY := (y1 + y2) // 2
        return distance(otherCenterX, otherCenterY, this.centerX(), this.centerY())
    }

    centerX() {
        return (this.x + (this.w // 2))
    }

    centerY() {
        return (this.y + (this.h // 2))
    }


    toString() {
        return this.name " " this.code " " this.cols() "x" this.rows() " (" this.x "," this.y " " this.w "x" this.h " ) " this.startCol "," this.stopCol " x " this.startRow "," this.stopRow " size " this.size() " center " this.centerX() "," this.centerY()
    }

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