#Requires AutoHotkey v2.0
#SingleInstance force
#WinActivateForce
#ErrorStdOut

ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0

hWnd := WinExist()
DllCall("RegisterShellHookWindow", "UInt", hWnd)
MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(MsgNum, onEvent)

; This script will not exit automatically, even though it has nothing to do.
; However, you can use its tray icon to open the script in an editor, or to
; launch Window Spy or the Help file.
Persistent

print(message) {
    FileAppend message "`n", "*"
}


global zoneX := [-2, 635, 1275, 1915]
global zoneY := [44, 822]
global zoneWidth := [647, 650, 650, 647]
global zoneHeight := [780, 780, 780, 780]
; global zoneHeight := [760, 760, 760, 760]

global zoneCenter := [322, 960, 650, 647]
global spacing := 0

threshold := 150

;global areaWidth  := 2560
;global areaHeight := 1600

SLEEP_VALUE := 5

onEvent(wParam,lParam, msg, hwnd) {
    print "event "  wParam " " lParam " " msg " " hwnd
    if (wParam = 32772){
        SetTimer(DrawActive,-1)
    }
}


DrawActive() {
    border_color := "0x6238FF"
    ; Start by removing the borders from all windows, since we do not know which window was previously active
    windowHandles := WinGetList(,,,)
    For handle in windowHandles
    {
        DrawBorder(handle, , 0)
    }
    ; Draw the border around the active window
    hwnd := WinExist("A")
    DrawBorder(hwnd, border_color, 1)
}

DrawBorder(hwnd, color:=0xFF0000, enable:=1) {
    static DWMWA_BORDER_COLOR := 34
    static DWMWA_COLOR_DEFAULT	:= 0xFFFFFFFF
    R := (color & 0xFF0000) >> 16
    G := (color & 0xFF00) >> 8
    B := (color & 0xFF)
    color := (B << 16) | (G << 8) | R
    DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", DWMWA_BORDER_COLOR, "int*", enable ? color : DWMWA_COLOR_DEFAULT, "int", 4)
}


promote() {
    window := WinGetId("A")



}

getBiggestAreas() {

}

snapToZone(targetStart, targetStop) {

    ; setup()

    window := WinGetId("A")

    getWindowArea(&currentZone, window)

    if (currentZone == targetStart "" targetStop) {
        ; switch to next mode zone
        switch targetStart "" targetStop {
            case 22:
                targetStart := 2
                targetStop := 4
            case 46:
                targetStart := 2
                targetStop := 8
            case 88:
                targetStart := 6
                targetStop := 8
            case 12:
                targetStart := 1
                targetStop := 4
            case 36:
                targetStart := 1
                targetStop := 8
            case 78:
                targetStart := 5
                targetStop := 8
            case 11:
                targetStart := 1
                targetStop := 3
            case 35:
                targetStart := 1
                targetStop := 7
            case 77:
                targetStart := 5
                targetStop := 7
        }
        ; print "switched to mode #! zone " targetStart "" targetStop
    } else {
        ; print "current : " currentZone "`tnext : "  targetStart "" targetStop
    }


    ; currentStart := SubStr(currentZone, 1, 1)
    ; currentStop := SubStr(currentZone, 2, 1)

    ; toGrid(&currentStartCol, &currentStartRow, currentStart)
    ; toGrid(&currentStopCol, &currentStopRow, currentStop)

    toGrid(&targetStartCol, &targetStartRow, targetStart)
    toGrid(&targetStopCol, &targetStopRow, targetStop)

    ; targetArea
    x := zoneX[targetStartCol]
    y := zoneY[targetStartRow]
    w := zoneX[targetStopCol] - zoneX[targetStartCol] + zoneWidth[targetStopCol]
    h := zoneY[targetStopRow] - zoneY[targetStartRow] + zoneHeight[targetStopRow]

    ; print "x " x " y " y " w " w " h " h
    WinSetTransparent 0,window
    
    WinMove x, y, w, h, window
    
    WinSetTransparent 255,window
}

getWindowArea(&area, window) {
    WinGetPos &x, &y, &width, &height, window

    colStart := -1
    colStop := -1
    rowStart := -1
    rowStop := -1
    area := -1

    for col, pos in zoneX
        if (x >= pos - threshold and x <= pos + threshold) {
            colStart := col
            break
        }

    for col, pos in zoneX {
        ; print " " x + width " >=  " (pos + zoneWidth[col]) - threshold  " and " x + width " <= " (pos + +zoneWidth[col]) + threshold
        if (x + width >= (pos + zoneWidth[col]) - threshold and x + width <= (pos + +zoneWidth[col]) + threshold) {
            colStop := col
            break
        }
    }

    for row, pos in zoneY {
        ; print "  " y " >=  " zoneY[row] - threshold " and " y " <= " zoneY[row] + threshold
        if (y >= pos - threshold and y <= pos + threshold) {
            rowStart := row
            break
        }
    }

    for row, pos in zoneY {
        print "  " y + height " >=  " zoneY[row] - threshold " and " y + height " <= " zoneY[row] + threshold
        if (y + height >= (pos + zoneHeight[row]) - threshold and y + height <= (pos + zoneHeight[row]) + threshold) {
            rowStop := row
            break
        }
    }

    ; print "x " x " y " y " w " width " h " height
    ; print "colStart " colStart
    ; print "rowStart " rowStart
    ; print "colStop " colStop
    ; print "rowStop " rowStop

    if (colStart != -1 and rowStart != -1 and colStop != -1 and rowStop != -1) {
        getZone(colStart, rowStart, &startZone)
        getZone(colStop, rowStop, &endZone)
        area := startZone "" endZone
    }

    ; switch x {
    ;     case -2: colStart := 1
    ;     case 635: colStart := 2
    ;     case 1275: colStart := 3
    ;     case 1915: colStart := 4
    ;     default: MsgBox x
    ; }

    ; switch x + width {
    ;     case 645: coltSop := 1
    ;     case 1285: colStop := 2
    ;     case 1925: colStop := 3
    ;     case 2562: colStop := 4
    ; }

    ; switch y {
    ;     case 44: rowStart := 1
    ;     case 822: rowStart := 2
    ; }

    ; switch y + height {
    ;     case 824: rowStop := 1
    ;     case 1602: rowStop := 2
    ; }

    ; getZone(colStart, rowStart, &startZone)
    ; getZone(colStop, rowStop, &endZone)

    ; area := startZone "" endZone
}

getZone(col, row, &zone) {
    switch col "" row {
        case 11: zone := 1
        case 12: zone := 2
        case 21: zone := 3
        case 22: zone := 4
        case 31: zone := 5
        case 32: zone := 6
        case 41: zone := 7
        case 42: zone := 8
    }
}

toGrid(&col, &row, zone) {
    switch zone {
        case 1:
            col := 1
            row := 1
        case 2:
            col := 1
            row := 2
        case 3:
            col := 2
            row := 1
        case 4:
            col := 2
            row := 2
        case 5:
            col := 3
            row := 1
        case 6:
            col := 3
            row := 2
        case 7:
            col := 4
            row := 1
        case 8:
            col := 4
            row := 2
    }
}


right(repeat := 1) {
    Send "#{right " repeat "}"
    Sleep 5
}

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

; growX(repeat := 1) {
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


setup() {
    MonitorGetWorkArea(1, &wLeft, &wTop, &wRight, &wBottom)
    ; print "Workarea   " wLeft " " wTop " " wRight " " wBottom
    ; MonitorGet(1, &Left, &Top, &Right, &Bottom)
    ; FileAppend "Boundaries " Left " " Top " " Right " " Bottom, "*"
    print "w    " (wRight - (5 * spacing)) // 4
    print "h   " ((wBottom - wTop) - (3 * spacing)) // 2
}



#numpad1:: snapToZone(2, 2)
#numpad2:: snapToZone(4, 6)
#numpad3:: snapToZone(8, 8)
#numpad4:: snapToZone(1, 2)
#numpad5:: snapToZone(3, 6)
#numpad6:: snapToZone(7, 8)
#numpad7:: snapToZone(1, 1)
#numpad8:: snapToZone(3, 5)
#numpad9:: snapToZone(7, 7)

#!numpad1:: snapToZone(2, 4)
#!numpad2:: snapToZone(2, 8)
#!numpad3:: snapToZone(6, 8)
#!numpad4:: snapToZone(1, 4)
#!numpad5:: snapToZone(1, 8)
#!numpad6:: snapToZone(5, 8)
#!numpad7:: snapToZone(1, 3)
#!numpad8:: snapToZone(1, 7)
#!numpad9:: snapToZone(5, 7)