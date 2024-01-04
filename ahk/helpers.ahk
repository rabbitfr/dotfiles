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


class Tiles extends Array {

    filterByArea(area) {

    }

    findById(id) {

    }

}

#F10:: {


    z := Zones() 

    debugGui := Gui(, "zone_1" )
    debugGuiHandle := debugGui.Hwnd
    debugGui.Show()
    ; WinMoveEx 4, 42, 1271 + 16, 1000 - 8, debugGuiHandle
    WinMove 4, 42, 1271 - 16 + 6, 1000 - 16 +6, debugGuiHandle
    ; WinGetPosEx(&x,&y,&w,&h,debugGuiHandle)
    ; print zone.toString() "`n"
    ; print "real x " x " y " y " w " w " h" h


    debugGui2 := Gui(, "zone_2")
    debugGuiHandle2 := debugGui2.Hwnd
    debugGui2.Show()
    ; WinMoveEx 1285, 42, 1271 + 16, 1000 -8 ,debugGuiHandle2
    WinMove 1285, 42, 1271 - 16, 1000 - 16 +6,debugGuiHandle2
    ; WinGetPosEx(&x,&y,&w,&h,debugGuiHandle2)
    ; print zone.toString() "`n"
    ; print "real x " x " y " y " w " w " h" h


}


#F11:: {
    z := Zones()
    
    print "------------------------------------------`n"
    ; test := z.findByShape(2,2)
    test := z.findBySize(1)

    for t in test 
        print t.toString() "`n"
    print "------------------------------------------`n"
    z.debugZones(test)
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

        originX := (this.margin ) + left
        originY := (this.margin ) + top

        areaWidth := (right - left)
        areaHeight := (bottom - top)

        this.cellWidth := (areaWidth - ((this.cols + 1) * this.spacing)) / this.cols 
        this.cellHeight := (areaHeight - ((this.rows + 1) * this.spacing)) / this.rows
        print "areaWidth "  areaWidth "`n"
        print "areaHeight "  areaHeight "`n"
        print "CellWidth "  this.cellWidth "`n"
        print "cellHeight "  this.cellHeight   "`n"
        print "originX "  originX "`n"
        print "originY "  originY   "`n"

        this.zones := []

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

                        w := this.cellWidth * ( stopCol - startCol +1 )  + (( stopCol - startCol ) * this.spacing)
                        h := this.cellHeight * ( stopRow - startRow +1 ) + (( stopRow - startRow ) * this.spacing)

                        xAsInt := Round(x) + 4 ; add left margin ? 
                        yAsInt := Round(y) + 4 ; add top margin ?
                        wAsInt := Round(w) - 6 ; add right spaceing 4 ?
                        hAsInt := Round(h) - 6
        
                        code := zoneStart "_"  zoneStop  
                        newZone := Zone(code, zoneStart, zoneStop, startCol, startRow, stopCol, stopRow, xAsInt, yAsInt, wAsInt, hAsInt)
                        this.zones.Push(newZone)         
                     
                        ; print zoneStart " "  zoneStop "`n"   
                    }
                }

            }

        }

        ; print "Zones count : " this.zones.Length

        ; for it in this.zones {
        ;     print it.toString() "`n"
        ; }
    }

    ; debugZones() {
    ;     for zone in this.zones {
    ;         debugGui := Gui(, "zone_" zone.code,)
    ;         debugGuiHandle := debugGui.Hwnd
    ;         debugGui.Show()
    ;         WinMoveEx zone.x, zone.y, zone.w, zone.h, debugGuiHandle

    ;     }
    ; }

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
        for zone in this.zones {
            if (zone.code == code)
              return zone

        }
    }

    findByShape(cols, rows) {
        filtered := [] 
        for candindate in this.zones {
            if (candindate.cols() == cols and candindate.rows() == rows)
                filtered.Push(candindate)

        }
        return filtered
    }

    findBySize(size) {
        filtered := [] 
        for candindate in this.zones {
            if (candindate.size() == size)
                filtered.Push(candindate)

        }
        return filtered
    }

    findMatches(x, y, w, h) {

    }

    findByName(name) {

    }

}

class Zone {

    __New(code, zoneStart, zoneStop, startCol, startRow, stopCol, stopRow, x, y, w, h) {
        this.code := code

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
        return this.cols() *  this.rows()
    }

    
    toString() {
        return  this.code " " this.cols() "x" this.rows() " (" this.x "," this.y " " this.w "x" this.h " ) " this.startCol "," this.stopCol  " x " this.startRow "," this.stopRow " size " this.size()
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