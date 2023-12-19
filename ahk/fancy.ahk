#Requires AutoHotkey v2.0
;MyGui := Gui()
;MyGui.Opt("+LastFound")
;#SingleInstance force

global zoneX := [-2, 635, 1275, 1915 ]
global zoneY := [ 44, 822 ]
global zoneWidth := [ 647, 650, 650 , 647 ]
global zoneHeight:= [ 780, 780, 780 , 780 ]

;global areaWidth  := 2560
;global areaHeight := 1600
`
SLEEP_VALUE := 5

snapToZone(start,stop) {
;    SetWinDelay 1`

    window := WinGetId("A")

    getArea(&currentZone, window)

    if ( currentZone == start "" stop ) {
        return
    }

;    WinSetTransparent 0,window

    reset(window)

    ; ┌───────┐
    ; │1 3 5 7│
    ; │       │
    ; │2 4 6 8│
    ; └───────┘

    switch start "" stop {
        case 22:
            down
        case 46:
            right
            down
            growX
        case 88:
            right 3
            down
        case 12:
            growY
        case 36:
            right
            growX
            growY
        case 78:
            right 3
            growY
        case 11:
             right
             left
        case 35:
            right
            growX
        case 77:
            right 3
        ; others
        case 24: ; ok
            down
            growX
        case 14:
            growX
            growY
        case 18:
            growX 4
            growY
        case 68:
            right 2
            down
            growX
        case 58:
            right 2
            growY
            growX
        case 13:
            growX
        case 57:
            right 2
            growX

    }

;    sleep 10
;    WinSetTransparent 255,window
}

reset(window) {
    WinMove -2,44,647,780, window
    SendInput "!{Space}m"
    SendEvent "^{Down}{Enter}"
    right()
    left()
}

getArea(&area, window) {
    WinGetPos &x, &y, &width, &height, window

    switch x {
        case -2   : colStart := 1
        case 635  : colStart := 2
        case 1275 : colStart := 3
        case 1915 : colStart := 4
    }

    switch x+width {
        case 645   : colStop := 1
        case 1285  : colStop := 2
        case 1925  : colStop := 3
        case 2562 :  colStop := 4
     }

    switch y {
        case 44   : rowStart := 1
        case 822  : rowStart := 2
    }

    switch y+height {
        case 824  : rowStop := 1
        case 1602 : rowStop := 2
    }

    getZone(colStart, rowStart, &startZone)
    getZone(colStop , rowStop,  &endZone)

    area := startZone "" endZone
}

getZone(col, row, &zone) {
    switch col "" row {
        case 11 : zone := 1
        case 12 : zone := 2
        case 21 : zone := 3
        case 22 : zone := 4
        case 31 : zone := 5
        case 32 : zone := 6
        case 41 : zone := 7
        case 42 : zone := 8
    }
}

right(repeat := 1) {w
    SendInput "#{right " repeat "}"
;    sleep 10
}

left() {
    SendInput "#{left}"
;    sleep 10
}

down() {
    SendInput "#{down}"
;    sleep 10
}

growX(repeat := 1) {
    SendInput "^!#{right " repeat "}"
;    sleep 10
}

growY() {
    SendInput "^!#{down}"
;    sleep 10
}

shrinkX() {
    SendInput "^!#{left}"
;    sleep 10
}

shrinkY() {
    SendInput "^!#{up}"
;    sleep 10
}