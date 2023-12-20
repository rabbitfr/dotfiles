#SingleInstance force
ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
#WinActivateForce


global zoneX := [-2, 635, 1275, 1915]
global zoneY := [44, 822]
global zoneWidth := [647, 650, 650, 647]
global zoneHeight := [780, 780, 780, 780]
global zoneCenter := [322, 960, 650, 647]

;global areaWidth  := 2560
;global areaHeight := 1600

SLEEP_VALUE := 5

snapToZone(targetStart, targetStop) {

    window := WinGetId("A")

    SetWinDelay 5

    getArea(&currentZone, window)

    if (currentZone == targetStart "" targetStop) {
        return
    }

    currentStart := SubStr(currentZone, 1, 1)
    currentStop := SubStr(currentZone, 2, 1)

    toGrid(&currentStartCol, &currentStartRow, currentStart)
    toGrid(&currentStopCol, &currentStopRow, currentStop)

    toGrid(&targetStartCol, &targetStartRow, targetStart)
    toGrid(&targetStopCol, &targetStopRow, targetStop)


    ;    window := WinGetId("A")

    ;    MsgBox "current : start " currentStart " (" currentStartCol "," currentStartRow ")`tend  " currentStop " (" currentStopCol "," currentStopRow ")`n"
    ;         . "target  : start " targetStart " (" targetStartCol "," targetStartRow ")`tend  " targetStop " (" targetStopCol "," targetStopRow ")`n"
    ;         . "shrinkY : " (currentStopRow-currentStartRow) "`n"
    ;         . "shrinkX : " (currentStopCol-currentStartCol) "`n"
    ;         . "left    : " (currentStartCol - 1)

    ; WinSetTransparent 0,window

    ; reset to area 11
    ; shrinkY(currentStopRow - currentStartRow)
    ; shrinkX(currentStopCol - currentStartCol)
    ; left(currentStartCol - 1)
    ; up(currentStartRow - 1)
    ; right(targetStartCol - 1)
    ; down(targetStartRow - 1)
    ; growX(targetStopCol - targetStartCol)
    ; growY(targetStopRow - targetStartRow)

    ; WinSetTransparent 255,window

    ; sleep 15
    ;    WinMove -2,44,647,780, window

    ;    CoordMode "Mouse","Screen"

    ;    startCol := 1
    ;    startRow := 1

    ;    MouseMove (startCol * 640 ) - 320  , ( startRow * 780 ) - 410, 0

    ;    MouseGetPos ,,, &hwnd

    ;    WinActivate "ahk_id" window
    ;
    ;    getArea(&currentZone, window)
    ;
    ;    if ( currentZone == start "" stop ) {
    ;        return
    ;    }

    ;    WinSetTransparent 0,window

    ;    reset(window)

    ;    CoordMode "Mouse","Window"
    ;    MouseMove 0,60,0


    ;    PostMessage 0x112, 0xF010, , , window                                 ;      WM_SYSCOMMAND, SC_MOVE
    ;    SendEvent "^{Down}"
    ;    sleep 10
    ;    CoordMode "Mouse","Screen"
    ;    WinMove 320 , 410,647,780, window
    ;    MouseMove 320 , 410, 10
    ;    sleep 10
    ;       SendEvent "{Click}"
    ;     sleep 10
    ;    SendEvent "^{Up}{Enter}"
    ;    WinMove -2,44,647,780, window
    ;    sleep 10
    ;    PostMessage 0xA1, 2,,, A

    ;    SendEvent "!{Space}m"
    ;    sleep 10
    ;    SendInput "#{right}"
    ;    sleep 10
    ;    SendInput "#{left}"
    ;    sleep 10
    ;    right()
    ;    left()

    ;    down()
    ;    right(2)

    ;    MouseMove (stopCol * 640 ) - 320  , ( stopRow * 780 ) - 410, 10
    ;    sleep 15
    ;    CoordMode "Mouse","Screen"
    ;    WinMove -2,44,647,780, window
    ;    MouseMove (startCol * 640 ) - 320  , ( startRow * 780 ) - 410, 10
    ;    sleep 15
    ;    SendEvent "!{Space}m"
    ;    sleep 15
    ;    SendEvent "{Enter}"
    ;    SendInput "m"
    ;    sleep 15
    ;    SendEvent "LWin up"
    ;    sleep 15
    ;    SendEvent "{Click down}"
    ;    sleep 15
    ;    SendInput "{Ctrl down}"
    ;    MouseDrag ,(startCol * 640 ) - 320  , ( startRow * 780 ) - 410,(stopCol * 640 ) - 320  , ( stopRow * 780 ) - 410, 10
    ;    SendEvent "^{Click " (stopCol * 640 ) - 320 " " ( stopRow * 780 ) - 410 " Down}"
    ;    sleep 15
    ;    SendEvent "{Ctrl up}"
    ;    SendInput "{Enter}"
    ;    sleep 15
    ;    SendEvent "^{up}"
    ;    sleep 15


    ;    sleep 15
    ;    SendEvent "{LButton}"
    ;    sleep 15
    ;    SendInput "{Enter}"
    ;    sleep 15
    ;    SendInput "{Ctrl down}{Ctrl up}"
    ;    WinRestore window
    ;    Send "{LWin up}"
    ;    SendEvent "{Ctrl up}"
    ;    sleep 15
    ;    SendInput "^{Up}"
    ;    sleep 15
    ;    Send "{LWin up}{LWin down}"
    ;    Send "{LWin up}"
    ;    sleep 5
    ; ┌───────┐
    ; │1 3 5 7│
    ; │       │
    ; │2 4 6 8│
    ; └───────┘

    ;    switch start "" stop {
    ;        case 22:
    ;            down
    ;        case 46:
    ;            right
    ;            down
    ;            growX
    ;        case 88:
    ;            right 3
    ;            down
    ;        case 12:
    ;            growY
    ;        case 36:
    ;            right
    ;            growX
    ;            growY
    ;        case 78:
    ;            right 3
    ;            growY
    ;        case 11:
    ;             right
    ;             left
    ;        case 35:
    ;            right
    ;            growX
    ;        case 77:
    ;            right 3
    ;        ; others
    ;        case 24: ; ok
    ;            down
    ;            growX
    ;        case 14:
    ;            growX
    ;            growY
    ;        case 18:
    ;            growX 4
    ;            growY
    ;        case 68:
    ;            right 2
    ;            down
    ;            growX
    ;        case 58:
    ;            right 2
    ;            growY
    ;            growX
    ;        case 13:
    ;            growX
    ;        case 57:
    ;            right 2
    ;            growX
    ;
    ;    }

    ;    sleep 10
    ;    WinSetTransparent 255,window
}

reset(window) {
    WinMove -2, 44, 647, 780, window
    ;    sleep 10
    ;    SendInput "!{Space}m"
    ;    sleep 10
    ;    SendInput "{Ctrl}{Enter}"
    ;    sleep 10

    Send "#{Right}"
    ;    left()
}

getArea(&area, window) {
    WinGetPos &x, &y, &width, &height, window

    switch x {
        case -2: colStart := 1
        case 635: colStart := 2
        case 1275: colStart := 3
        case 1915: colStart := 4
        default: MsgBox x
    }

    switch x + width {
        case 645: colStop := 1
        case 1285: colStop := 2
        case 1925: colStop := 3
        case 2562: colStop := 4
    }

    switch y {
        case 44: rowStart := 1
        case 822: rowStart := 2
    }

    switch y + height {
        case 824: rowStop := 1
        case 1602: rowStop := 2
    }

    getZone(colStart, rowStart, &startZone)
    getZone(colStop, rowStop, &endZone)

    area := startZone "" endZone
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

left(repeat := 1) {
    Send "#{left " repeat " }"
    Sleep 5
}

up(repeat := 1) {
    Send "#{up " repeat " }"
    Sleep 5
}

down(repeat := 1) {
    Send "#{down " repeat "}"
    Sleep 5
}

growX(repeat := 1) {
    Send "^!#{right " repeat "}"
    Sleep 5
}

growY(repeat := 1) {
    Send "^!#{down " repeat "}"
    Sleep 5
}

shrinkX(repeat := 1) {
    Send "^!#{left " repeat "}"
    Sleep 5
}

shrinkY(repeat := 1) {
    SendInput "^!#{up " repeat "}"
    Sleep 5
}


;reset(window) {
;    WinMove -2,44,647,780, window
;    SendInput "!{Space}m"
;    SendEvent "^{Down}{Enter}"
;    right()
;    left()
;}
;
;
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