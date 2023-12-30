#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce
#ErrorStdOut

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

; 1...
; 5...
global L := 15
; ...4
; ...8
global R := 48
; .23.
; .67.
global C := 27
; 1234
; 5678
global F := 18
; 1234
; 5678
global LS := 16
; 12..
; 56..
global RS := 38
; ..34
; ..78
global L3 := 17
; 123.
; 567.
global R3 := 28
; 1234
; 5678
global T := 14
; 1234
; 5678
global B := 58
; 1234
; 5678
global TL := 12
; 1234
; 5678
global TR := 34
; 1234
; 5678
global BL := 56
; 1234
; 5678
global BR := 78
; 1234
; 5678
global TLC := 11
; 1234
; 5678
global TRC := 44
; 1234
; 5678
global BLC := 55
; 1234
; 5678
global BRC := 88

global areasToZones := Map()
areasToZones["L"] := L
areasToZones["R"] := R
areasToZones["C"] := C
areasToZones["F"] := F
areasToZones["LS"] := LS
areasToZones["RS"] := RS
areasToZones["L3"] := L3
areasToZones["R3"] := R3
areasToZones["T"] := T
areasToZones["B"] := B
areasToZones["TL"] := TL
areasToZones["TR"] := TR
areasToZones["BL"] := BL
areasToZones["BR"] := BR
areasToZones["TLC"] := TLC
areasToZones["TRC"] := TRC
areasToZones["BLC"] := BLC
areasToZones["BRC"] := BRC

; 1   2   3   4
; 1   2   4   8
;
; 5   6   7   8
; 16 32  64 128
;

; global slots := Map()
; slots["L"] := 17
; slots["R"] := 136
; slots["C"] := 102
; slots["F"] := 255
; slots["LS"] := 31
; slots["RS"] := 204
; slots["L3"] := 119
; slots["R3"] := 238
; slots["T"] := 15
; slots["B"] := 240
; slots["TL"] := 3
; slots["TR"] := 12
; slots["BL"] := 48
; slots["BR"] := 192
; slots["TLC"] := 1
; slots["TRC"] := 8
; slots["BLC"] := 16
; slots["BRC"] := 128

global zonesToAreas := Map()

For key, value in areasToZones {
    zonesToAreas["" value] := key
    ; print value " " zonesToAreas["" value]
}


global spacing := 4
global columns := 4
global rows := 2

global slots := [1, 1, 1, 1, 1, 1, 1, 1]

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

DrawActive() {
    ; print "draw active"
    refresh

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
        border_color := "0x79e1df" ; pink
    } else {
        border_color := "0x7ce38b"
    }
    ;  border_color := "0xf9cbe5" ; pink
    ;  border_color := "0x79e1df" ; aqua

    ; global gfx
    ; gfx.DrawLine(brush, 100,100,1000,1000)


    DrawBorder(window, border_color, 1)
}

refresh()

refresh() {

    ; reset data
    global handlesByPos := Map()
    global posByHandle := Map()
    global handleDesc := Map()

    ; print "refresh windows list"
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

    count := 0

    ; global slots
    global slots := [0, 0, 0, 0, 0, 0, 0, 0]
    ; print "remaining_slots " remaining_slots

    for handle in windowHandles
    {

        class := WinGetClass(handle)

        if (class ~= "WorkerW|Shell_TrayWnd|NarratorHelperWindow|Button|PseudoConsoleWindow")
            continue

        ; Attempts to execute WinGetProcessName to exclude windows with no process
        try {

            process := WinGetProcessName(handle)

            getWindowArea(&area, handle)

            put(handlesByPos, area, handle)
            posByHandle[handle] := area
            handleDesc[handle] := "[" count "] '" area "' `t" process


            ; print "areaZone " areaZone
            ; if (area != "Min" and area != "Max") { ; min max are ignored

            ;     areaZone := areasToZones.Get(area)
            ;     print "OK 3"
            ;     print count ": " area " '" process "' (" class ") Zone " areaZone


            ; ;     print "zone -> " areaZone

            ;     if (StrLen(areaZone) == 1) {
            ;         ; print "Removing  slots[" area "] := 1 "
            ;         remaining_slots[area] := 1
            ;     } else {

            ;         zoneToCell(&startCol, &startRow, SubStr(areaZone, 1, 1))
            ;         zoneToCell(&stopCol, &stopRow, SubStr(areaZone, 2, 1))

            ;         ; print "start stop " startCol " " startRow " " stopCol " " stopRow
            ;         Loop stopRow - startRow + 1 {
            ;             row := A_Index - 1
            ;             ; print "Loop  " row
            ;             Loop stopCol - startCol + 1 {

            ;                 col := A_Index + startCol - 1
            ;                 ; print "col  " col " row " row
            ;                 index := ((row ) * columns) + col
            ;                 remaining_slots[index] := 1
            ;                 ; print "Removing  slots[" index "] := 1 "
            ;             }
            ;         }
            ;     }
            ; areaBits := Integer(slots[area])
            ; remaining_slots := remaining_slots ^ areaBits
            ; ; print "removing slots " areaBits
            ; print "remaining_slots " remaining_slots
            ; }
            count := count + 1

        }
        catch as e  ; Handles the first error thrown by the block above.
        { }


    }

    debugRefresh := true


    if (debugRefresh)
        print "Handles :"

    visibleHandles := Map()

    for handle, pos in posByHandle {

        if (debugRefresh)
            print handle "`t " pos

        if (pos != "Min" and pos != "Max")
            visibleHandles.Set(handle, pos)
    }

    if (debugRefresh)
        print "`nVisible Handles :"

    ; Build slots usage status
    for handle, pos in visibleHandles {

        zone := areasToZones[pos]

        zoneToCell(&startCol, &startRow, SubStr(zone, 1, 1))

        if (StrLen(zone) == 1) {
            stopCol := startCol
            stopRow := startRow
        } else {
            zoneToCell(&stopCol, &stopRow, SubStr(zone, 2, 1))
        }

        if (debugRefresh)
            print handle "`t " handleDesc[handle] " `t" startCol "," startRow " -> " stopCol "," stopRow

        for row in range(startRow, stopRow) {

            for col in range(startCol, stopCol) {
                print col "," row
                index := (row - 1) * columns + col
                slots[index] := 1
            }
        }

    }

    ; bug in slots lists
    for index, status in slots {
        print index " = " status
    }
    available_zones := []

    ; Build available zone list
    for row in range(1, rows) {

        print "--- Row " row " ---"

        for col in range(1, columns) {

            slotIndex := (row - 1) * columns + col
            slotStatus := slots[slotIndex]

            print "Check " col "," row " = " slotStatus

            if ( slotStatus == 0) {
                startSlot := slotIndex
                print "Slot " startSlot " is Free. startSlot " startSlot " columns " columns

                ; extends zone right or bottom

                for nextCol in range(startSlot, columns * row ) {
                    print "nextcol " nextCol
                    ; nextIndex := (row - 1) * columns + nextCol
                    nextIndex := nextCol
                    nextStatus := slots[nextIndex]

                    ; print "  next " nextCol "," row " = " nextStatus

                    if ( nextStatus == 0 ) {
                        print "  next " nextIndex " Free, add zone " startSlot nextIndex
                    } else {
                        print "  next " nextIndex " used. break"
                        break
                    }


                    
                }
            }


            ;     startSlot := slotIndex
            ;     nextSlot := startSlot + 1

            ;     print "Slot " startSlot " : Free, add zone '" startSlot "'"

            ;     available_zones.Push(startSlot)

            ;     ; print "Mod " Mod(nextSlot, 4)

            ;     ; endOfRow := (nextSlot) // 4

            ;     ; print "nextSlot " nextSlot " Mod " Mod(nextSlot, 4) ", endOfRow " endOfRow

            ;     if ( nextSlot > slots.Length) {
            ;         print "`t next slot " nextSlot ", break (end of slots)"
            ;         break
            ;     }

            ;     if (Mod(nextSlot - 1 , 4) == 0) {
            ;         print "`t next slot " nextSlot ", break (next row)"
            ;         break
            ;     }

            ;     ; if (  endOfRow == 1 or endOfRow == 2 or nextSlot > columns * rows) {
            ;     ;     print "`t next slot " nextSlot ", break (end of row)"
            ;     ;     continue
            ;     ; }

            ;     ; if ( slots[nextSlot] == 1 )
            ;     ;     print "`t next slot " nextSlot " : used, break (cannot extend)"

            ;     print "| nextSlot " nextSlot " Mod " Mod(nextSlot - 1 , 4)
            ;     ; add horiz areas
            ;     while ( slots[nextSlot] == 0 ) {

            ;         print "`t-> Slot " nextSlot " : Free, add zone '" startSlot nextSlot

            ;         available_zones.Push(startSlot nextSlot)

            ;         nextSlot := nextSlot + 1

            ;         if ( nextSlot > columns * rows) {
            ;             print "`t next slot " nextSlot ", break (end of slots)"
            ;             break
            ;         }

            ;         if (Mod(nextSlot - 1 , 4) == 0) {
            ;             print "`t next slot " nextSlot ", break (next row)"
            ;             continue
            ;         }

            ;         print "| nextSlot " nextSlot " Mod " Mod(nextSlot - 1 , 4)


            ;     }


        }
    }


    ; available_zones := []


    ; for i, cell in remaining_slots {
    ;     print "slot " i " = "  cell
    ; }

    ; for i, cell in remaining_slots {
    ;     ; print "Check zone " i " : "  cell

    ;     if ( cell == 1 ) {
    ;         print "Cell " i " : Used"
    ;     } else if ( cell == 0 ) {
    ;         startCol := i
    ;         available_zones.Push(startCol)
    ;         print "Cell " i " : Free, add zone '" startCol "'"


    ;         Loop (columns - startCol) {
    ;             ; row := A_Index - 1


    ;             col := A_Index + startCol

    ;             if ( remaining_slots[col] == 1) {
    ;                 print "`tCol : "  A_Index + startCol " is occupied, break "
    ;                 break
    ;             }
    ;             else
    ;             {
    ;                 available_zones.Push(startCol col)
    ;                 print "`tCol : "  A_Index + startCol " is free, add zone '" startCol col "'"
    ;             }
    ;             ; expand cells
    ;             ; Loop columns - startCol {
    ;             ;     if ( remaining_slots[stopCell] == 0 ) {
    ;             ;     stopCell := (row * columns) + startCell + A_Index
    ;             ;     ; print "stopCell : "  stopCell
    ;             ;     if ( remaining_slots[stopCell] == 0 ) {
    ;             ;         print "`tOpen zone : "  startCell "" stopCell
    ;             ;         available_zones.Push(startCell "" stopCell)
    ;             ;     } else {
    ;             ;         continue
    ;             ;     }
    ;             ; }
    ;     }
    ;    }
    ; }

    ; for key, value in  available_zones
    ;      print  "available_zone " value
    ; for  zone, zoneValue in  areasToZones {
    ;     print "Check " zone " " zoneValue
}

range(start, stop) {
    range := []
    loops := stop - start + 1
    loop loops {
        range.Push(start + A_Index - 1)
    }
    return range
}

; PlaceNewWindow(handle) {
;     ; print "Placing " handle

;     WinWait handle
;     class := WinGetClass(handle)

;     ; Attempts to execute WinGetProcessName to exclude windows with no process
;     try {

;         process := WinGetProcessName(handle)

;         ; print count ": " process

;         ; getWindowArea(&area, handle)

;         ; put(handlesByPos, area, handle)

;         ; posByHandle.Set(handle, area)

;         title := WinGetTitle(handle)
;         print "Placing " process "' (" class ")"
;         print "remaining_slots " remaining_slots


;         ; for key, value in slots {
;         ;     available := (  value ~ remaining_slots )
;         ;     ; if (available)
;         ;         print "is available slot : " key ", " available


;         ; }
;         ; count := count + 1

;     }
;     catch as e  ; Handles the first error thrown by the block above.
;     { }


;     dump(handlesByPos)
; }


; F2::PlaceNewWindow(WinGetId("A"))
F2:: refresh()


put(map, key, value) {
    values := map.Get(key, [])
    values.Push(value)
    map.Set(key, values)
}

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

; SortWindows() {

;     ;     DetectHiddenWindows false

;     windowHandles := WinGetList(, , "Program Manager")

;     count := 0

;     for handle in windowHandles
;     {

;         class := WinGetClass(handle)

;         if (class ~= "WorkerW|Shell_TrayWnd|NarratorHelperWindow|Button|PseudoConsoleWindow")
;             continue

;         ; Attempts to execute WinGetProcessName to exclude windows with no process
;         try {

;             process := WinGetProcessName(handle)

;             ; print count ": " process

;             getWindowArea(&area, handle)

;             put(handlesByPos, area, handle)

;             posByHandle.Set(handle, area)

;             ; title := WinGetTitle(handle)
;             ; print count ": " area " '" process "' (" class ")"

;             count := count + 1

;         }
;         catch as e  ; Handles the first error thrown by the block above.
;         { }


;     }
; }


; F1::getWindowArea2(&startZone,&endZone,WinGetId("A"))
; F1:: snapToZone(1, 2)
; F2:: snapToZone(2, 2)
; F3:: snapToZone(3, 3)
; F4:: snapToZone(4, 4)
; F5:: snapToZone(5, 5)
; F6:: snapToZone(6, 6)
; F7:: snapToZone(7, 7)
; F8:: snapToZone(8, 8)

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

            if (startZone == endZone) {
                area := startZone
            } else {
                area := startZone "" endZone
            }
            area := zonesToAreas["" area]
            ; print "`t " area
    }
}

getWindowZones(&startZone, &endZone, window) {


    WinGetPos &x, &y, &width, &height, window

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


print(message) {
    try {
        FileAppend message "`n", "*"
    } catch {

    }
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