#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce ; send 32772
#ErrorStdOut

;
; Debug
;

global logLevel := "INFO"

#Include helpers.ahk
#Include constants.ahk

ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
; DetectHiddenWindows true
DetectHiddenWindows false
; #Include CGdip.ahk

;  CGdip.Startup

global handlesByPos := Map()
global posByHandle := Map()
global available_zones_by_size := Map()

;
; Config
;

global spacing := 4
global columns := 4
global rows := 2



global slots := [0, 0, 0, 0, 0, 0, 0, 0]



myGui := Gui()
myGui.Opt("+LastFound")
hWnd := WinExist()
DllCall("RegisterShellHookWindow", "UInt", hWnd)
MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(MsgNum, ShellMessage)
Persistent ; This script will not exit automatically, even though it has nothing to do.


ShellMessage(wParam, lParam, msg, hwnd) {
    debug "[event] id " wParam " handle " lParam " msg " msg " " hwnd
    
    ; refresh

    switch wParam {
        ;
        case 32772:
            ; refresh
            SetTimer(DrawActive, -1) ; run once
            ; HSHELL_WINDOWCREATED
        case 1:
            ; refresh
            PlaceNewWindow(lParam)
            ; HSHELL_APPCOMMAND 12
            ; HSHELL_REDRAW 6
            ; if wParam = 1
            ;     msg = HSHELL_WINDOWCREATED
            ; if wParam = 2q
            ;     msg = HSHELL_WINDOWDESTROYED
            ; if wParam = 3
            ;     msg = HSHELL_ACTIVATESHELLWINDOW
            ; if wParam = 4
            ;     msg = HSHELL_WINDOWACTIVATED
            ; if wParam = 5
            ;     msg = HSHELL_GETMINRECT
            ; if wParam = 6
            ;     msg = HSHELL_REDRAW
            ; if wParam = 7
            ;     msg = HSHELL_TASKMAN
            ; if wParam = 8
            ;     msg = HSHELL_LANGUAGE
            ; if wParam = 9
            ;     msg = HSHELL_SYSMENU
            ; if wParam = 10
            ;     msg = HSHELL_ENDTASK
            ; if wParam = 11
            ;     msg = HSHELL_ACCESSIBILITYSTATE
            ; if wParam = 12
            ;     msg = HSHELL_APPCOMMAND
            ; if wParam = 13
            ;     msg = HSHELL_WINDOWREPLACED
            ; if wParam = 14
            ;     msg = HSHELL_WINDOWREPLACING
            ; if wParam = 15
            ;     msg = HSHELL_HIGHBIT
            ; if wParam = 16
            ;     msg = HSHELL_FLASH
            ; if wParam = 17
            ;     msg = HSHELL_RUDEAPPACTIVATED
    }
}

DrawActive() {
    

    ; border_color := "0x6238FF"
    border_color := "0x7ce38b"

    ; Start by removing the borders from all windows, since we do not know which window was previously active
    windowHandles := WinGetList(, , ,)
    For handle in windowHandles
    {
        DrawBorder(handle, , 0)
    }

    ; Draw the border around the active window
    window := WinExist("A")

    if hasWindowsOnSamePosition(window) {
        border_color := "0xf9cbe5"
    } else {
        border_color := "0x7ce38b"
    }
    ;  border_color := "0xf9cbe5" ; pink
    ;  border_color := "0x79e1df" ; aqua


    DrawBorder(window, border_color, 1)
}

; refresh()

refresh(exclude := "") {

    info "Updating..."
    ; reset data
    global handlesByPos := Map()
    global posByHandle := Map()
    global handleDesc := Map()
    global available_zones_by_size := Map()

    MonitorGetWorkArea(1, &wl, &wt, &wr, &wb)
    ; print "Monitor 1 WorkArea  l  " wl " t " wt " r " wr " b " wb
    ; MonitorGet(1, &Left, &Top, &Right, &Bottom)
    ; print "Monitor 1 Area      l  " Left " t " Top " r " Right " b " Bottom

    global originX := 0 + wl
    global originY := 0 + wt
    global areaWidth := (wr - wl)
    global areaWHeight := (wb - wt)

    global cellWidth := (areaWidth - ((columns + 1) * spacing)) // columns
    global cellHeight := (areaWHeight - ((rows + 1) * spacing)) // rows

    windowHandles := WinGetList(, , "Program Manager")

    handleIndex := 0

    global slots := [0, 0, 0, 0, 0, 0, 0, 0]

    for handle in windowHandles
    {
        if (handle ~= exclude)
            continue

        class := WinGetClass(handle)

        ; ignore some system classes
        if (class ~= "WorkerW|Shell_TrayWnd|NarratorHelperWindow|Button|PseudoConsoleWindow")
            continue

        try {

            process := WinGetProcessName(handle)

            ; get 'approximate by threshold' window area
            getWindowArea(&area, handle)

            ; handles by same area
            put(handlesByPos, area, handle)
            ; area by handle
            posByHandle[handle] := area
            ; handle short desc
            handleDesc[handle] := "[" handleIndex "] '" area "' `t" process

            handleIndex := handleIndex + 1

        }
        catch as e
        {
            ; do nothing
        }
    }

    debug "Handles :"

    ; filter handles to visible ones
    visibleHandles := Map()

    for handle, pos in posByHandle {

        debug handle "`t " handleDesc[handle]

        if (pos != "Min" and pos != "Max")
            visibleHandles.Set(handle, pos)

    }

    debug "`nVisible Handles :"

    ; Compute which slots in grid are occupied by visible handles
    for handle, pos in visibleHandles {

        zone := areasToZones[pos]

        zoneToCell(&startCol, &startRow, SubStr(zone, 1, 1))
        zoneToCell(&stopCol, &stopRow, SubStr(zone, 2, 1))

        debug handle "`t " handleDesc[handle] " `t" startCol "," startRow " -> " stopCol "," stopRow

        for row in range(startRow, stopRow) {

            for col in range(startCol, stopCol) {

                handleIndex := (row - 1) * columns + col
                slots[handleIndex] := 1
            }
        }

    }

    ; build short handle description for debug purpose
    rowDesc := "Slots :`n`n"

    for row in range(1, rows) {
        for col in range(1, columns) {
            handleIndex := (row - 1) * columns + col
            rowDesc := rowDesc " " slots[handleIndex]
        }
        rowDesc := rowDesc "`n"
    }

    debug rowDesc

    ; Build available areas list
    available_zones := []
    for row in range(1, rows) {

        debug "--- Free areas in Row " row " ---"

        for col in range(1, columns) {

            slotIndex := (row - 1) * columns + col
            slotStatus := slots[slotIndex]

            ; If a free slot is found, try to expand to contiguous free slots
            if (slotStatus == 0) {
                startSlot := slotIndex

                debug "Slot " startSlot " to" ;. startSlot " startSlot " columns " columns

                ; expand area to right on same row
                for nextIndex in range(startSlot, columns * row) {

                    nextStatus := slots[nextIndex]

                    if (nextStatus == 0) {
                        available_zones.Push(startSlot nextIndex)
                        debug "  Slot " nextIndex ", add zone " startSlot nextIndex
                    } else {
                        ; debug "  Slot " nextIndex " used. break"
                        break
                    }

                }
                ; expand area to right on the row below !! only works with max 2 rows (as now)
                if (row < rows) {

                    ; print "Checking row below " startSlot + columns " " columns * (row + 1)

                    for nextIndex in range(startSlot + columns, columns * (row + 1)) {

                        nextStatus := slots[nextIndex]

                        if (nextStatus == 0) {
                            available_zones.Push(startSlot nextIndex)
                            debug "  Slot " nextIndex ", add zone " startSlot nextIndex
                        } else {
                            ; debug "  Slot " nextIndex " used. break"
                            break
                        }

                    }
                }

            }
        }
    }


    ; for index, zone in available_zones {
    ;     info index " " zone
    ; }

    ; available areas by size
    for index, zone in available_zones {
        zoneToCell(&startCol, &startRow, SubStr(zone, 1, 1))
        zoneToCell(&stopCol, &stopRow, SubStr(zone, 2, 1))
        size := (stopCol - startCol + 1) * (stopRow - startRow + 1)
        ; info "Area " zone " size " size
        put(available_zones_by_size, size, zone)
    }

    ; dump(available_zones_by_size)

}

PlaceNewWindow(handle) {
    ; print "Placing " handle
    ; exclude new window from actual windows ?

    refresh(handle)

    maxAvailableSize := -1

    for size, zone in available_zones_by_size {
        if (size > maxAvailableSize)
            maxAvailableSize := size
    }


    rightest := -1

    if (maxAvailableSize != -1) {
        debug "Max available size " maxAvailableSize
        areas := available_zones_by_size[maxAvailableSize]


        for i, area in areas {
            if (area > rightest)
                rightest := area
        }

        debug "rightest Area " rightest

    }


    WinWait handle
    ; class := WinGetClass(handle)

    ; getWindowArea(&area, handle)


    ; do not use all slots if screen is empty
    if (rightest == F)
        rightest := C

    if (rightest != -1)
        snapTo(rightest, handle)

}


F3:: PlaceNewWindow(WinGetId("A"))
F2:: refresh()

;
; Helpers
;


dump(map) {
    For key, values in map {
        print key " : "
        if (values.Length > 0)
            for i, j in values
                print "`t -> " j
    }
}

hasWindowsOnSamePosition(window) {
    global handlesByPos
    global posByHandle

    if (posByHandle.Has(window)) {

        pos := posByHandle.Get(window)

        handlesAtPos := handlesByPos.Get(pos)

        for i, j in handlesAtPos
            print "`t h -> " j

        return handlesAtPos.Length > 1
    }
    return false
}

nextModZone(&zoneStart, &zoneStop) {
    switch zoneStart "" zoneStop {
        case 55:
            zoneStart := 5
            zoneStop := 6
        case 67:
            zoneStart := 5 ; ???
            zoneStop := 8
        case 88:
            zoneStart := 7
            zoneStop := 8
        case 15:
            zoneStart := 1
            zoneStop := 6
        case 27:
            zoneStart := 1
            zoneStop := 8
        case 48:
            zoneStart := 3
            zoneStop := 8
        case 11:
            zoneStart := 1
            zoneStop := 2
        case 23:
            zoneStart := 1 ; ??
            zoneStop := 4
        case 44:
            zoneStart := 3
            zoneStop := 4
    }
}


;  1  2  3  4
;  5  6  7  8

left(window := WinGetId("A")) {
    getWindowZones(&startZone, &endZone, window)

    switch startZone "" endZone {
        case C: snapTo(L3, window)
            ; case 38: snapToZone(1, 7, window)
            ; unexpand
        case R3: snapTo(C, window)
        case L3: snapTo(LS, window)
    }
}


right(window := WinGetId("A")) {
    getWindowZones(&startZone, &endZone, window)

    switch startZone "" endZone {
        case C: snapTo(R3, window)
            ; case RS: snapToZone(R3, window)
        case L: snapTo(L3, window)
            ; unexpand
        case LS: snapTo(L3, window)
        case R3: snapTo(R, window)
        case L3: snapTo(C, window)
    }
}

up(window := WinGetId("A")) {
    getWindowZones(&startZone, &endZone, window)

    switch startZone "" endZone {
        ;     case 27: snapToZone(2, 8, window)
        ;     case 38: snapToZone(1, 7, window)
        ;     case 15: snapToZone(1, 7, window)
        ;     ; unexpand
        ;     case 17: snapToZone(2, 7, window)
        ;     case 28: snapToZone(4, 8, window)
    }
}

down(window := WinGetId("A")) {
    getWindowZones(&startZone, &endZone, window)

    switch startZone "" endZone {
        ;     case 27: snapToZone(2, 8, window)
        ;     case 38: snapToZone(1, 7, window)
        ;     case 15: snapToZone(1, 7, window)
        ;     ; unexpand
        ;     case 17: snapToZone(2, 7, window)
        ;     case 28: snapToZone(4, 8, window)
    }
}

snapTo(area, window := WinGetId("A")) {

    snapToZone(SubStr(area, 1, 1), SubStr(area, 2, 1), window)
}

snapToZone(zoneStart, zoneStop, window := WinGetId("A")) {
    refresh
    getWindowZones(&currentStartZone, &currentEndZone, window)

    if (currentStartZone == zoneStart and currentEndZone == zoneStop) {
        nextModZone(&zoneStart, &zoneStop)
    }

    zoneToCell(&startCol, &startRow, zoneStart)

    x := originX + ((startCol - 1) * cellWidth) + (startCol * spacing)
    y := originY + ((startRow - 1) * cellHeight) + (startRow * spacing)

    zoneToCell(&stopCol, &stopRow, zoneStop)

    w := ((stopCol - startCol) + 1) * cellWidth
    h := ((stopRow - startRow) + 1) * cellHeight

    ; print "col " startCol " row " startRow " x  " x " y " y " w  " w " h " h

    WinMoveEx x, y, w, h, window

}

zoneToCell(&col, &row, zone) {
    col := Mod(zone - 1, columns) + 1
    row := ((zone - 1) // columns) + 1
}

cellToZone(col, row, &zone) {
    zone := col + ((row - 1) * columns)
}

getWindowArea(&area, window) {

    MinMax := WinGetMinMax(window)

    ; print "MinMax " MinMax

    switch MinMax {
        case -1:
            area := "Min"
        case 1:
            area := "Max"
        case 0:
            getWindowZones(&startZone, &endZone, window)
            area := startZone "" endZone
            area := zonesToAreas["" area]
            ; print "`t " area
    }
}

getWindowZones(&startZone, &endZone, window) {


    WinGetPos &x, &y, &width, &height, window

    x1 := x
    y1 := y


    startCol := Round(x1 / cellWidth) + 1
    startRow := Round(y1 / cellHeight) + 1

    stopCol := startCol + Round(width / cellWidth) - 1
    stopRow := startRow + Round(height / cellHeight) - 1


    ; print "x1 " Round(x1 / cellWidth) " y1 " Round(y1 / cellHeight) " w  " Round(width / cellWidth) " h "  Round(height / cellHeight)

    ; print "startCol " startCol " startRow " startRow " stopCol  " stopCol " stopRow "  stopRow

    cellToZone(startCol, startRow, &startZone)
    cellToZone(stopCol, stopRow, &endZone)

    ; print "x1 " x1 " y1 " y1 " width  " width " height " height
    ; print "x1 " originX + (startCol - 1 ) * cellWidth " y1 " originY + ( startRow -1 ) * cellHeight ; " width  " width " height " height
}

;

; right(repeat := 1) {
;     Send "#{right " repeat "}"
;     Sleep 5
; }

; left(repeat := 1) {
;     Send "#{left " repeat " }"
;     Sleep 5
; }

; up(repeat := 1) {
;     Send "#{up " repeat " }"
;     Sleep 5
; }

; down(repeat := 1) {
;     Send "#{down " repeat "}"
;     Sleep 5
; }

;     Send "^!#{right " repeat "}"
;     Sleep 5
; }

; growY(repeat := 1) {
;     Send "^!#{down " repeat "}"
;     Sleep 5
; }

; shrinkX(repeat := 1) {
;     Send "^!#{left " repeat "}"
;     Sleep 5
; }

; shrinkY(repeat := 1) {
;     SendInput "^!#{up " repeat "}"
;     Sleep 5
; }
;right(repeat := 1) {
;    SendInput "#{right " repeat "}"
;;    sleep 10
;}
;

;
;growX(repeat := 1) {
;   SendInput "^!#{right " repeat "}"
;}
;
;growY(repeat := 1) {
;   SendInput "^!#{down " repeat "}"
;}

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

; #x:: promote()

; #Up:: ;disable
; #Down:: ; disable

; #HotIf GetKeyState("LWin", "P")
; Left & Up:: snapToZone(1, 1)

; #HotIf GetKeyState("LWin", "P")
; Left & Down:: snapToZone(2, 2)

; #HotIf GetKeyState("LWin", "P")
; Up & Right:: snapToZone(7, 7)

; #HotIf GetKeyState("LWin", "P")
; Down & Right:: snapToZone(8, 8)


#numpad1:: snapTo(BLC)
#numpad2:: snapToZone(6, 7)
#numpad3:: snapToZone(8, 8)
#numpad4:: snapToZone(1, 5)
#numpad5:: snapTo(C)
#numpad6:: snapToZone(4, 8)
#numpad7:: snapToZone(1, 1)
#numpad8:: snapToZone(2, 3)
#numpad9:: snapToZone(4, 4)

#Left:: left()
#Right:: right()
#Up:: up()
#Down:: down()


; Left:: if (GetKeyState("LWin") and GetKeyState("Left") and GetKeyState("Up")){
;     MsgBox "Left."
; }

; Up:: if (GetKeyState("LWin") and GetKeyState("Left") and GetKeyState("Up")){
;     MsgBox "Up."
; }

; #!numpad1:: snapToZone(2, 4)
; #!numpad2:: snapToZone(2, 8)
; #!numpad3:: snapToZone(6, 8)
; #!numpad4:: snapToZone(1, 4)
; #!numpad5:: snapToZone(1, 8)
; #!numpad6:: snapToZone(5, 8)
; #!numpad7:: snapToZone(1, 3)
; #!numpad8:: snapToZone(1, 7)
; #!numpad9:: snapToZone(5, 7)

DrawBorder(hwnd, color := 0xFF0000, enable := 1) {
    static DWMWA_BORDER_COLOR := 34
    static DWMWA_COLOR_DEFAULT := 0xFFFFFFFF
    R := (color & 0xFF0000) >> 16
    G := (color & 0xFF00) >> 8
    B := (color & 0xFF)
    color := (B << 16) | (G << 8) | R
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_BORDER_COLOR, "int*", enable ? color : DWMWA_COLOR_DEFAULT, "int", 4)
}