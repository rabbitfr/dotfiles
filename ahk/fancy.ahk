#Requires AutoHotkey v2.0

snap5(start,stop) {
    window := WinGetId("A")

    currentZone := getZone(window)

    if ( currentZone == start "" stop ) {
        return
    }

     WinSetTransparent 0,window

    ;    SetWinDelay 5
    ; move on zone 1
    WinMove -2,44,647,780,window

    ; reset state and snap to zone 1
;     x := -2
;     y := 44
;     width := 647
;     height := 780
;     WinMove x,y,width,height, window
     PostMessage 0x112, 0xF010,,,window
     SendEvent "^{Down}{Enter}"
;     sleep 10

     right()
     left()



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
    WinSetTransparent 255,window
}

right(repeat := 1) {
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
