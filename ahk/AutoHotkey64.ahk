#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce ; send 32772
#ErrorStdOut

;
; Debug
;

global logLevel := "INFO"
SetWinDelay(1)
#Include helpers.ahk
#Include Tiler.ahk
#Include constants.ahk

ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
; DetectHiddenWindows true
DetectHiddenWindows false
#Include CGdip.ahk


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


; myGui := Gui()
; myGui.Opt("+LastFound")
; hWnd := WinExist()
; DllCall("RegisterShellHookWindow", "UInt", hWnd)
; MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
; OnMessage(MsgNum, ShellMessage)
; Persistent ; This script will not exit automatically, even though it has nothing to do.


; ShellMessage(wParam, lParam, msg, hwnd) {
;     ; debug "[event] id " wParam " handle " lParam " msg " msg " " hwnd

;     ; refresh

;     switch wParam {
;         ;
;         case 32772:
;             ; wm.update()
;             ; SetTimer(DrawActive, -1) ; run once
;             ; HSHELL_WINDOWCREATED
;         case 1:
;             ; refresh
;             ; PlaceNewWindow(lParam)
;             ; HSHELL_APPCOMMAND 12
;             ; HSHELL_REDRAW 6
;             ; if wParam = 1
;             ;     msg = HSHELL_WINDOWCREATED
;             ; if wParam = 2q
;             ;     msg = HSHELL_WINDOWDESTROYED
;             ; if wParam = 3
;             ;     msg = HSHELL_ACTIVATESHELLWINDOW
;             ; if wParam = 4
;             ;     msg = HSHELL_WINDOWACTIVATED
;             ; if wParam = 5
;             ;     msg = HSHELL_GETMINRECT
;             ; if wParam = 6
;             ;     msg = HSHELL_REDRAW
;             ; if wParam = 7
;             ;     msg = HSHELL_TASKMAN
;             ; if wParam = 8
;             ;     msg = HSHELL_LANGUAGE
;             ; if wParam = 9
;             ;     msg = HSHELL_SYSMENU
;             ; if wParam = 10
;             ;     msg = HSHELL_ENDTASK
;             ; if wParam = 11
;             ;     msg = HSHELL_ACCESSIBILITYSTATE
;             ; if wParam = 12
;             ;     msg = HSHELL_APPCOMMAND
;             ; if wParam = 13
;             ;     msg = HSHELL_WINDOWREPLACED
;             ; if wParam = 14
;             ;     msg = HSHELL_WINDOWREPLACING
;             ; if wParam = 15
;             ;     msg = HSHELL_HIGHBIT
;             ; if wParam = 16
;             ;     msg = HSHELL_FLASH
;             ; if wParam = 17
;             ;     msg = HSHELL_RUDEAPPACTIVATED
;     }
; }


; DrawActive() {


;     ; border_color := "0x6238FF"
;     border_color := "0x7ce38b"

;     ; Start by removing the borders from all windows, since we do not know which window was previously active
;     windowHandles := WinGetList(, , ,)
;     For handle in windowHandles
;     {
;         DrawBorder(handle, , 0)
;     }

;     ; Draw the border around the active window
;     window := WinExist("A")

;     if hasWindowsOnSamePosition(window) {
;         border_color := "0xf9cbe5"
;     } else {
;         border_color := "0x7ce38b"
;     }
;     ;  border_color := "0xf9cbe5" ; pink
;     ;  border_color := "0x79e1df" ; aqua


;     DrawBorder(window, border_color, 1)
; }

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

        zone := namedAreas[pos]

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


; F3:: PlaceNewWindow(WinGetId("A"))
; F2:: refresh()
; F6:: test()

; test() {
;     pToken := CGdip.Startup()

;     g1 := Gui()
;     g1.Opt("-Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs")
;     g1.Show("NA")
;     ; Get a handle to this window we have created in order to update it later
;     hwnd1 := WinExist()

;     Width := 300, Height := 200

;     hbm := CGdip.Bitmap.Create(Width, Height)

;     hdc := CreateCompatibleDC()

;     obm := SelectObject(hdc, hbm)

;     G := CGdip.Graphics.FromHDC(hdc)

;     G.SetSmoothingMode(4)

;     pBrush := CGdip.Brush.SolidFill(0x77000000)


;     G.FillRoundedRectangle(pBrush,0,0,Width,Height,20)

;     pBrush.__Delete()

;     UpdateLayeredWindow(hwnd1, hdc, 500,500,Width,Height)

;     OnMessage(0x201, WM_LBUTTONDOWN)`

;     SelectObject(hdc,obm)

;     DeleteDC(hdc)

;     G.__Delete()


; }


; WM_LBUTTONDOWN(wParam, lParam, msg, hwnd)
; {
; 	PostMessage 0xA1, 2
; }
; ExitFunc(ExitReason, ExitCode)
; {
;    global
;    ; gdi+ may now be shutdown on exiting the program
;    CGdip.Shutdown()
; }

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
            area := areasToName["" area]
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


wm := Tiler()
; wm.update()

hiddenEventReceiver := Gui()
hiddenEventReceiver.Opt("+LastFound")
receiver := WinExist()

DllCall("RegisterShellHookWindow", "UInt", receiver)

MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(MsgNum, onEvent)

global lastEventId := -1
global lastEventHandle := -1

onEvent(eventId, eventHandle, msg, ignore) {

    ; print "Event " eventId "  p " eventHandle ; " " msg " " handle

    global lastEventId
    global lastEventHandle

    if (eventId != lastEventId or eventHandle != lastEventHandle) {
        ; do nothing
        lastEventId := eventId
        lastEventHandle := eventHandle
    } else {
        ; print "Skip event"
        return ; ignore
    }

    switch eventId {

        case HSHELL_ACTIVATESHELLWINDOW:
        case HSHELL_GETMINRECT:
        case HSHELL_REDRAW: ; 6
        case HSHELL_TASKMAN:
        case HSHELL_LANGUAGE:
        case HSHELL_SYSMENU:
        case HSHELL_ENDTASK:
        case HSHELL_ACCESSIBILITYSTATE:
        case HSHELL_APPCOMMAND:
        case HSHELL_WINDOWREPLACED:
        case HSHELL_WINDOWREPLACING:
        case HSHELL_HIGHBIT:
        case HSHELL_FLASH: ; 16
        case HSHELL_WINDOWCREATED: ; 1
            print "Updating WIN CREATED " eventHandle 
            wm.update
        case HSHELL_WINDOWDESTROYED: ; 2
        print "Updating WIN DESTROYED " eventHandle 
            wm.update
        case HSHELL_WINDOWACTIVATED: ; 4
        print "Updating WIN ACTIVATED: " eventHandle 
            wm.update
        case HSHELL_RUDEAPPACTIVATED,
            HSHELL_RUDEAPPACTIVATED_BIS: ; 32772
            print "Updating WIN RUDEAPPACTIVATED, " eventHandle 
            wm.update
            print "updateActiveWindow WIN RUDEAPPACTIVATED"
            wm.updateActiveWindow()
    }
}

ExcludeScriptMessages := "1"	; 0 to include

HookWinEvent()

HookWinEvent() {
    global
    HookProcAdr := CallbackCreate(CaptureWinEvent, "F")
    dwFlags := (0x0000 | 0x0002 | 0x0001)
    hWinEventHook := SetWinEventHook(0x800B, 0x800B, 0, HookProcAdr, 0, 0, dwFlags)
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) {
    DllCall("ole32\CoInitialize", "Uint", 0)
    return DllCall("SetWinEventHook", "Uint", eventMin, "Uint", eventMax, "Uint", hmodWinEventProc, "Uint", lpfnWinEventProc, "Uint", idProcess, "Uint", idThread, "Uint", dwFlags)
}


CaptureWinEvent(hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    ; Global PauseStatus := -1 , WM_VSCROLL := -1  , SB_BOTTOM := -1 , ogLV_WMessages:= -1 , winMessageList:= -1

    if (hWnd == 0)
        return

    if (Event != 32779)
        return

    If WinExist("ahk_id " hWnd) {
        wm.winMoved(hWnd)
        
    } else {
        return
    }

    ; Event += 0
    ; message := ""


    ; if (Event = 1)
    ;     Message := "EVENT_SYSTEM_SOUND"
    ; else if (Event = 2)
    ;     Message := "EVENT_SYSTEM_ALERT"
    ; else if (Event = 3)
    ;     Message := "EVENT_SYSTEM_FOREGROUND"
    ; else if (Event = 4)
    ;     Message := "EVENT_SYSTEM_MENUSTART"
    ; else if (Event = 5)
    ;     Message := "EVENT_SYSTEM_MENUEND"
    ; else if (Event = 6)
    ;     Message := "EVENT_SYSTEM_MENUPOPUPSTART"
    ; else if (Event = 7)
    ;     Message := "EVENT_SYSTEM_MENUPOPUPEND"
    ; else if (Event = 8)
    ;     Message := "EVENT_SYSTEM_CAPTURESTART"
    ; else if (Event = 9)
    ;     Message := "EVENT_SYSTEM_CAPTUREEND"
    ; else if (Event = 10)
    ;     Message := "EVENT_SYSTEM_MOVESIZESTART"
    ; else if (Event = 11)
    ;     Message := "EVENT_SYSTEM_MOVESIZEEND"
    ; else if (Event = 12)
    ;     Message := "EVENT_SYSTEM_CONTEXTHELPSTART"
    ; else if (Event = 13)
    ;     Message := "EVENT_SYSTEM_CONTEXTHELPEND"
    ; else if (Event = 14)
    ;     Message := "EVENT_SYSTEM_DRAGDROPSTART"
    ; else if (Event = 15)
    ;     Message := "EVENT_SYSTEM_DRAGDROPEND"
    ; else if (Event = 16)
    ;     Message := "EVENT_SYSTEM_DIALOGSTART"
    ; else if (Event = 17)
    ;     Message := "EVENT_SYSTEM_DIALOGEND"
    ; else if (Event = 18)
    ;     Message := "EVENT_SYSTEM_SCROLLINGSTART"
    ; else if (Event = 19)
    ;     Message := "EVENT_SYSTEM_SCROLLINGEND"
    ; else if (Event = 20)
    ;     Message := "EVENT_SYSTEM_SWITCHSTART"
    ; else if (Event = 21)
    ;     Message := "EVENT_SYSTEM_SWITCHEND"
    ; else if (Event = 22)
    ;     Message := "EVENT_SYSTEM_MINIMIZESTART"
    ; else if (Event = 23)
    ;     Message := "EVENT_SYSTEM_MINIMIZEEND"
    ; else if (Event = 32779)
    ;     Message := "EVENT_OBJECT_LOCATIONCHANGE"

    ; ; print "Event " Event " Message " Message " hWnd " hWnd " idObject " idObject " idChild " idChild " dwEventThread " dwEventThread " dwmsEventTime " dwmsEventTime

    ; Sleep(0)
    ; EventHex := Event

    ; if(message!=""){
    ;     try{
    ;         if (myGui.filterMsg.Has(message) and myGui.filterMsg[message]=1){
    ;             return
    ;         }
    ;         	; give a little time for WinGetTitle/WinGetActiveTitle functions, otherwise they return blank
    ;         WinhWnd := WinGetTitle(hWnd) = "" ? DllCall("user32\GetAncestor", "Ptr", hWnd, "UInt", 1, "Ptr") : hWnd
    ;         phWnd := WinGetPID(WinhWnd)
    ;         if (myGui.ExcludeOwnMessages and myGui.phwnd+0=phWnd){
    ;             return
    ;         }
    ;         WinClass := WinGetClass(hWnd)
    ;         ogLV_WMessages.Add("", format("0x{:x}",hWnd), format("0x{:x}",idObject), format("0x{:x}",idChild), WinGetTitle(hWnd), WinClass, format("0x{:x}",EventHex), Message,WinGetProcessName(hWnd),format("0x{:x}", phWnd),WinGetTitle(WinhWnd))

    ;         if (!WinActive(myGui)){
    ;             SendMessage(WM_VSCROLL, SB_BOTTOM, 0, "SysListView321", "ahk_id " myGui.Hwnd)
    ;         }
    ;     }
    ; }
}



Persistent

; RegWrite 0, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableLockWorkstation" ; disable the Windows lock feature
; DllCall("LockWorkStation")
 
; Sleep(1000)
; RegWrite 1, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System","DisableLockWorkstation" ; reenable the Windows lock feature

#numpad1:: wm.snapTo(BLC)
#numpad2:: wm.snapTo(CB)
#numpad3:: wm.snapTo(BRC)
#numpad4:: wm.snapTo(L)
#numpad5:: wm.snapTo(C)
#numpad6:: wm.snapTo(R)
#numpad7:: wm.snapTo(TLC)
#numpad8:: wm.snapTo(CT)
#numpad9:: wm.snapTo(TRC)

#Left:: wm.modLeft()
#Right:: wm.modRight()


; #Up:: up()
; #Down:: down()

#Enter::Run("wt.exe")
#d::Send("^{Space}")
#w::Send("!{F4}")

; #Down::{
;     print "#down"
;     ; print A_PriorHotkey
;     ; print A_TimeSincePriorHotkey
; }

; #Up::  {
;     ; print A_PriorHotkey " " A_TimeSincePriorHotkey
;     if ( A_TimeSincePriorHotkey == "" ) {
;         combo := "#Up"
;         print combo " single"
;     } else if (A_TimeSincePriorHotkey < 200) {
        
;         switch A_PriorHotkey {
;             case "#Down":   combo := "invalid"
;             case "#Left":   combo := "Up Left"
;             case "#Right":  combo := "Up Right"
;             case "#Up":     combo := "Up x2"
;             default:  combo := "not found"  
;         }
;         print combo " combo"
;     } else {
;         print combo " single"
;     }



;     ; print A_PriorHotkey
;     ; print A_TimeSincePriorHotkey
; }
; #Down:: ;
; #Right:: ;
; #Left:: {
;     ; print A_PriorHotkey " " A_TimeSincePriorHotkey
;     if ( A_TimeSincePriorHotkey == "" ) {
;         combo := "#Left"
;         print combo " single"
;     } else if (A_TimeSincePriorHotkey <  200) {
;         switch A_PriorHotkey {
;             case "#Down":   combo := "Down Left"
;             case "#Left":   combo := "Left x2"
;             case "#Right":  combo := "invalid"
;             case "#Up":     combo := "Up Left"
;             default:  combo := "not found"  
;         }
;         print combo " combo"
;     } else {
;         combo := "#Left"
;         print combo " single"
;     }

;     ; print combo "  " A_TimeSincePriorHotkey

;     ; print A_PriorHotkey
;     ; print A_TimeSincePriorHotkey
; }
#y:: wm.snapTo(TLC) ;
#u:: wm.snapTo(TL) ;
#i:: wm.snapTo(TR) ;
#o:: wm.snapTo(TRC) 

#h:: wm.snapTo(LS) ;
#j:: wm.snapTo(l3) 
#k:: wm.snapTo(R3) 
#l:: wm.snapTo(RS) ;

#n:: wm.snapTo(BLC) ;
#m:: wm.snapTo(BL) ;
#,:: wm.snapTo(BR) ; 
#.:: wm.snapTo(BRC) ;

; #T:: wm.snapTo(R3)
; #numpad4:: wm.snapTo(L)
; #numpad5:: wm.snapTo(C)
; #numpad6:: wm.snapTo(R)
; #numpad7:: wm.snapTo(TLC)
; #numpad8:: wm.snapTo(CT)
; #numpad9:: wm.snapTo(TRC)

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