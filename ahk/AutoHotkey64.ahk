#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce
#ErrorStdOut

ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
DetectHiddenWindows true

; global zoneX := [-2, 635, 1275, 1915]
; global zoneY := [44, 822]
; global zoneWidth := [647, 650, 650, 647]
; global zoneHeight := [780, 780, 780, 780]
; global zoneCenterX := [322, 960, 650, 647]
; global zoneCenterY := [406, 1184]
global zoneSlots := [0, 0, 0, 0, 0, 0, 0, 0]

; global zoneX := [5, 639, 1292, 1929]
; global zoneY := [44, 825]
; global zoneWidth := [633, 633, 633, 633]
; global zoneHeight := [775, 775, 775, 775]
; global zoneCenter := [322, 960, 650, 647]


global lastActionWindow := 0

global lastPromotedWindow := -1
global lastPromotedWindowZone := -1

global lastPositiodnById := 0 ; @TODO
global lastPositionByProcess := 0 ; @TODO

myGui := Gui()
myGui.Opt("+LastFound")
hWnd := WinExist()
DllCall("RegisterShellHookWindow", "UInt", hWnd)
MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(MsgNum, ShellMessage)
Persistent ; This script will not exit automatically, even though it has nothing to do.

ShellMessage(wParam, lParam, msg, hwnd) {
    ; print "event " wParam " " lParam " " msg " " hwnd
    switch wParam {
        case 32772: SetTimer(DrawActive, -1)
            ; case 1: PlaceNewWindow(lParam)
    }
}

; However, you can use its tray icon to open the script in an editor, or to
; launch Window Spy or the Help file.
; Persistent

print(message) {
    try {
        FileAppend message "`n", "*"
    } catch {

    }
}

; onEvent(wParam, lParam, msg, hwnd) {
;     ; print "event " wParam " " lParam " " msg " " hwnd
;     if (wParam = 32772) {
;         SetTimer(DrawActive, -1)
;     }
; }

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
    hwnd := WinExist("A")
    DrawBorder(hwnd, border_color, 1)
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

; F2::PlaceNewWindow(WinGetId("A"))

; PlaceNewWindow(window) {

;     DetectHiddenWindows false

;     windowHandles := WinGetList(, , "Program Manager")

;     global zoneSlots := [0, 0, 0, 0, 0, 0, 0, 0]

;     windowByArea := Map()


;     for handle in windowHandles
;     {

;         try  ; Attempts to execute WinGetProcessName to exclude windows with no process
;         {
;             process := WinGetProcessName(handle)

;             ; if ( process == "explorer.exe" or process == "cmd.exe")
;             ;     continue

;             WinGetPos &x, &y, &width, &height, handle

;             ; if ( ( width == 0 and height == 0 ) or( width == 1 and height == 1) or (x == 0 and  y == 38 ))
;             ;     continue

;             class := WinGetClass(handle)

;             if (class == "FC_HIDDEN_WND"
;                 or class == "WorkerW"
;                 or class == "GDI+ Hook Window Class"
;                 or class == "XamlExplorerHostIslandWindow"
;                 or class == "WindowsDashboard"
;                 or class == "TabletModeCoverWindow"
;                 or class == "ApplicationFrameWindow"
;                 or class == "Windows.UI.Core.CoreWindow")
;                 continue


;             getWindowArea(&area, handle)

;             print "area " area
;             if (area == -1)
;                 continue


;             values := windowByArea.Get(area, [])
;             values.Push(handle)
;             windowByArea.Set(area, values)

;             toGrid(&targetStartCol, &targetStartRow, SubStr(area, 1, 1))
;             toGrid(&targetStopCol, &targetStopRow, SubStr(area, 2, 1))


;             Loop targetStopCol - targetStartCol {
;                 col := targetStartCol + A_Index
;                 Loop targetStopRow - targetStopRow {
;                     row := A_Index
;                     print col "," row
;                 }
;             }


;             ; print "process " process ", area " area ", size " size " minMax " minMax
;             ; title := WinGetTitle(handle)
;             ; print "class: " class ", title " title

;         }
;         catch as e  ; Handles the first error thrown by the block above.
;         { }


;         For key, values in windowByArea {
;             for i, j in values
;                 print key " -> " j
;         }
;     }


; for j, y in zoneCenterY {
;     for i, x in zoneCenterX {
;         winId := DllCall("WindowFromPoint", "Int", x, "Int", y)
;         process := WinGetProcessName("ahk_id " winID)

;         ; print "col " i " row " j " " x " " y  " winId " winId " : " process " " title

;         if ( process == "explorer.exe") {
;             GW_HWNDNEXT :=2 ; Returns a handle to the window below the given window.
;             GW_HWNDPREV :=3 ; Returns a handle to the window above the given window.

;             above := DllCall("GetWindow", "uint", winID, "uint", GW_HWNDNEXT)

;               print "above " above
;         }
;         ; print "col " i " row " j " winId " winId
;         title := WinGetTitle("ahk_id " winID)
;         print "col " i " row " j " " x " " y  " winId " winId " : " process " " title
;     }

; }


; try  ; Attempts to execute WinGetProcessName to exclude windows with no process
; {
;     WinWaitActive window
;     process := WinGetProcessName(window)
;     print "Place " process


; } catch as e  ; Handles the first error thrown by the block above.
; { }

; }


; promote( window := WinGetId("A")) {

;     global lastPromotedWindow
;     global lastPromotedWindowZone

;     if (window == lastPromotedWindow) {

;         snapToZone(SubStr(lastPromotedWindowZone, 1, 1), SubStr(lastPromotedWindowZone, 2, 1))
;         lastPromotedWindow := -1
;         lastPromotedWindowZone := -1
;         return
;     }

;     candidates := getBiggestVisibleAreas()

;     area := -1

;     for key, values in candidates {
;         area := key
;     }

;     if (area != -1) {

;         getWindowArea(&currentZone, window)

;         snapToZone(SubStr(area, 1, 1), SubStr(area, 2, 1))
;         lastPromotedWindow := window
;         lastPromotedWindowZone := currentZone
;     }

; }

; getBiggestVisibleAreas() {

;     windowHandles := WinGetList(, , "Program Manager")

;     candidates := Map()

;     maxSize := 0

;     for handle in windowHandles
;     {

;         try  ; Attempts to execute WinGetProcessName to exclude windows with no process
;         {
;             process := WinGetProcessName(handle)

;             ; if ( process == "explorer.exe" or process == "cmd.exe")
;             ;     continue

;             WinGetPos &x, &y, &width, &height, handle

;             ; if ( ( width == 0 and height == 0 ) or( width == 1 and height == 1) or (x == 0 and  y == 38 ))
;             ;     continue

;             class := WinGetClass(handle)

;             if (class == "FC_HIDDEN_WND"
;                 or class == "WorkerW"
;                 or class == "GDI+ Hook Window Class"
;                 or class == "XamlExplorerHostIslandWindow"
;                 or class == "WindowsDashboard"
;                 or class == "TabletModeCoverWindow"
;                 or class == "ApplicationFrameWindow"
;                 or class == "Windows.UI.Core.CoreWindow")
;                 continue


;             getWindowArea(&area, handle)

;             if (area == -1)
;                 continue

;             toGrid(&targetStartCol, &targetStartRow, SubStr(area, 1, 1))
;             toGrid(&targetStopCol, &targetStopRow, SubStr(area, 2, 1))

;             size := (targetStopCol - targetStartCol + 1) * (targetStopRow - targetStartRow + 1)

;             minMax := WinGetMinMax(handle)

;             ; print "process " process ", area " area ", size " size " minMax " minMax
;             title := WinGetTitle(handle)
;             ; print "class: " class ", title " title

;             if (size == maxSize) {
;                 values := candidates.Get(area, [])
;                 values.Push(handle)
;                 candidates.Set(area, values)
;             } else if (size > maxSize) {
;                 candidates.Clear
;                 values := candidates.Get(size, [])
;                 values.Push(handle)
;                 candidates.Set(area, values)
;                 maxSize := size
;             }
;         }
;         catch as e  ; Handles the first error thrown by the block above.
;         { }
;     }


;     print "MaxArea =" maxSize ", area candidates " candidates.Count
;     For key, values in candidates {
;         for i, j in values
;             print key " -> " j
;     }

;     return candidates
; }

; snapToZone(targetStart, targetStop) {

;     window := WinGetId("A")

;     getWindowArea(&currentZone, window)
;     ; print "getWindowArea found " currentZone

;     if (currentZone == targetStart "" targetStop) {
;         ; switch to next mode zone if requested zone is current zone
;         switch targetStart "" targetStop {
;             case 22:
;                 targetStart := 2
;                 targetStop := 4
;             case 46:
;                 targetStart := 2
;                 targetStop := 8
;             case 88:
;                 targetStart := 6
;                 targetStop := 8
;             case 12:
;                 targetStart := 1
;                 targetStop := 4
;             case 36:
;                 targetStart := 1
;                 targetStop := 8
;             case 78:
;                 targetStart := 5
;                 targetStop := 8
;             case 11:
;                 targetStart := 1
;                 targetStop := 3
;             case 35:
;                 targetStart := 1
;                 targetStop := 7
;             case 77:
;                 targetStart := 5
;                 targetStop := 7
;         }
;         ; print "switched to mode #! zone " targetStart "" targetStop
;     }
;     ; else if (currentZone == 14 and targetStart "" targetStop == 12) {
;     ;     targetStart := 1
;     ;     targetStop := 6
;     ;     ; print "switched to mode #! zone " targetStart "" targetStop
;     ; } else if (currentZone == 58 and targetStart "" targetStop == 78) {
;     ;     targetStart := 3
;     ;     targetStop := 8
;     ;     ; print "switched to mode #! zone " targetStart "" targetStop
;     ; }

;     ; currentStart := SubStr(currentZone, 1, 1)
;     ; currentStop := SubStr(currentZone, 2, 1)

;     ; toGrid(&currentStartCol, &currentStartRow, currentStart)
;     ; toGrid(&currentStopCol, &currentStopRow, currentStop)

;     toGrid(&targetStartCol, &targetStartRow, targetStart)
;     toGrid(&targetStopCol, &targetStopRow, targetStop)

;     ; print "targetStartCol " targetStartCol " targetStartRow " targetStartRow " targetStopCol " targetStopCol " targetStopRow " targetStopRow

;     ; targetArea
;     x := zoneX[targetStartCol]
;     y := zoneY[targetStartRow]
;     w := zoneX[targetStopCol] - zoneX[targetStartCol] + zoneWidth[targetStopCol]
;     h := zoneY[targetStopRow] - zoneY[targetStartRow] + zoneHeight[targetStopRow]

;     if !hasInvisibleBorder(window) {
;         x := x + 8
;         w := w - 16
;         h := h - 8
;     }

;     ; print "x " x " y " y " w " w " h " h
;     WinSetTransparent 0, window

;     ; WinMoveEx x, y, w, h, window*
;     WinMove x, y, w, h, window

;     WinSetTransparent 255, window
; }

; hasInvisibleBorder(window) {
;     WinGetClientPos , , &cWidth, &cHeight, window
;     WinGetPos , , &width, &height, window
;     return cWidth != width and cHeight != height

; }

; F1::getWindowArea2(&startZone,&endZone,WinGetId("A"))
F1:: snapToZone(1, 2)
F2:: snapToZone(2, 2)
F3:: snapToZone(3, 3)
F4:: snapToZone(4, 4)
F5:: snapToZone(5, 5)
F6:: snapToZone(6, 6)
F7:: snapToZone(7, 7)
F8:: snapToZone(8, 8)



global spacing := 4
global columns := 4
global rows := 2

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

global L := 15
global R := 48
global C := 27
global F := 18
global LS := 16
global RS := 38
global L3 := 17
global R3 := 28


left(window := WinGetId("A")) {
    getWindowArea(&startZone, &endZone, window)

    switch startZone "" endZone {
        case C: snapTo(L3, window) 
        ; case 38: snapToZone(1, 7, window) 
        ; unexpand 
        case R3: snapTo(C, window) 
        case L3: snapTo(LS, window)
    }
}


right(window := WinGetId("A")) {
    getWindowArea(&startZone, &endZone, window)

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
    getWindowArea(&startZone, &endZone, window)

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
    getWindowArea(&startZone, &endZone, window)

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
    snapToZone(SubStr(area,1,1),SubStr(area,2,1),window)
}
snapToZone(zoneStart, zoneStop, window := WinGetId("A")) {

    getWindowArea(&currentStartZone, &currentEndZone, window)

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


setup() {

    MonitorGetWorkArea(1, &wl, &wt, &wr, &wb)
    print "Monitor 1 WorkArea  l  " wl " t " wt " r " wr " b " wb
    MonitorGet(1, &Left, &Top, &Right, &Bottom)
    print "Monitor 1 Area      l  " Left " t " Top " r " Right " b " Bottom

    global originX := 0 + wl
    global originY := 0 + wt
    global areaWidth := (wr - wl)
    global areaWHeight := (wb - wt)

    global cellWidth := (areaWidth - ((columns + 1) * spacing)) // columns
    global cellHeight := (areaWHeight - ((rows + 1) * spacing)) // rows

    print "Monitor 1 cells    w " cellWidth " h " cellHeight
    print "                   areaWidth " areaWidth " areaWHeight " areaWHeight
    print "                   originX   " originX " originY " originY

}

getWindowArea(&startZone, &endZone, window) {

    WinGetPos &x, &y, &width, &height, window

    setup()

    x1 := x
    y1 := y

    ; x2 := x + width
    ; y2 := y + height

    startCol := Round(x1 / cellWidth) + 1
    startRow := Round(y1 / cellHeight) + 1

    stopCol := startCol + Round(width / cellWidth) - 1
    stopRow := startRow + Round(height / cellHeight) - 1

    ; print "x1 " x1 " y1 " y1 " x2  " x2 " y2 " y2
    ; print "x1 " Round(x1 / cellWidth) " y1 " Round(y1 / cellHeight) " w  " Round(width / cellWidth) " h "  Round(height / cellHeight)

    ; print "startCol " startCol " startRow " startRow " stopCol  " stopCol " stopRow "  stopRow

    cellToZone(startCol, startRow, &startZone)
    cellToZone(stopCol, stopRow, &endZone)

    ; print "startZone " startZone " endZone " endZone
    ; colStart := -1
    ; colStop := -1
    ; rowStart := -1
    ; rowStop := -1

    ; setup

    ; for col, pos in zoneX
    ;     if (x >= pos - threshold and x <= pos + threshold) {
    ;         colStart := col
    ;         break
    ;     }

    ; window
}

;
;
;
; getWindowArea(&area, window) {

;     WinGetPos &x, &y, &width, &height, window

;     colStart := -1
;     colStop := -1
;     rowStart := -1
;     rowStop := -1
;     area := -1

;     for col, pos in zoneX
;         if (x >= pos - threshold and x <= pos + threshold) {
;             colStart := col
;             break
;         }

;     for col, pos in zoneX {
;         ; print " " x + width " >=  " (pos + zoneWidth[col]) - threshold  " and " x + width " <= " (pos + +zoneWidth[col]) + threshold
;         if (x + width >= (pos + zoneWidth[col]) - threshold and x + width <= (pos + +zoneWidth[col]) + threshold) {
;             colStop := col
;             break
;         }
;     }

;     for row, pos in zoneY {
;         ; print "  " y " >=  " zoneY[row] - threshold " and " y " <= " zoneY[row] + threshold
;         if (y >= pos - threshold and y <= pos + threshold) {
;             rowStart := row
;             break
;         }
;     }

;     for row, pos in zoneY {
;         ; print "  " y + height " >=  " zoneY[row] - threshold " and " y + height " <= " zoneY[row] + threshold
;         if (y + height >= (pos + zoneHeight[row]) - threshold and y + height <= (pos + zoneHeight[row]) + threshold) {
;             rowStop := row
;             break
;         }
;     }

;     if (colStart != -1 and rowStart != -1 and colStop != -1 and rowStop != -1) {
;         getZone(colStart, rowStart, &startZone)
;         getZone(colStop, rowStop, &endZone)

;         area := startZone "" endZone
;         ; print "Setting area to " area
;     }

;     ; print "area not found "

; }

; getZone(col, row, &zone) {
;     switch col "" row {
;         case 11: zone := 1
;         case 12: zone := 2
;         case 21: zone := 3
;         case 22: zone := 4
;         case 31: zone := 5
;         case 32: zone := 6
;         case 41: zone := 7
;         case 42: zone := 8
;     }
; }

; toGrid(&col, &row, zone) {
;     ; print "toGrid(" zone ")"
;     switch zone {
;         case 1:
;             col := 1
;             row := 1
;         case 2:
;             col := 1
;             row := 2
;         case 3:
;             col := 2
;             row := 1
;         case 4:
;             col := 2
;             row := 2
;         case 5:
;             col := 3
;             row := 1
;         case 6:
;             col := 3
;             row := 2
;         case 7:
;             col := 4
;             row := 1
;         case 8:
;             col := 4
;             row := 2
;     }
; }


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


; setup() {
;     MonitorGetWorkArea(1, &wLeft, &wTop, &wRight, &wBottom)
;     ; print "Workarea   " wLeft " " wTop " " wRight " " wBottom
;     ; MonitorGet(1, &Left, &Top, &Right, &Bottom)
;     ; FileAppend "Boundaries " Left " " Top " " Right " " Bottom, "*"
;     print "w    " (wRight - (5 * spacing)) // 4
;     print "h   " ((wBottom - wTop) - (3 * spacing)) // 2
; }

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


#numpad1:: snapToZone(5, 5)
#numpad2:: snapToZone(6, 7)
#numpad3:: snapToZone(8, 8)
#numpad4:: snapToZone(1, 5)
#numpad5:: snapToZone(2, 7)
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
