print "Loading Zones.ahk`n"

class Zones extends Array {

    

    __New(cols := 4, rows := 4, margin := 0, spacing := 0) {
        this.cols := cols
        this.rows := rows
        this.margin := margin
        this.spacing := spacing ;  // 2 ; counted double ?
        this.init()

        ; move to zones
        H_MAIN_CYCLE := [LS, L3, C, R3, RS]
        H_TOP_CYCLE := [TLC, TL, CT, TR, TRC]
        H_BOTTOM_CYCLE := [BLC, BL, CB, BR, BRC]
   

        this.H_CYCLES := [H_MAIN_CYCLE, H_TOP_CYCLE, H_BOTTOM_CYCLE]

        ; move to zones 
        V_RC_CYCLE := [TRC, R, BRC]
        V_C_CYCLE := [CB, C, CT]
        V_LC_CYCLE := [TLC, L, BLC]
        V_R_CYCLE := [TR, RS, BR]
        V_L_CYCLE := [TL, LS, BL]

        this.V_CYCLES := [V_RC_CYCLE, V_C_CYCLE, V_LC_CYCLE, V_R_CYCLE, V_L_CYCLE]


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

                        if (zoneStop >= 10) {
                            code := (zoneStart * 100) + zoneStop
                        } else {
                            code := (zoneStart * 10) + zoneStop
                        }
                        ; code := zoneStart "" zoneStop ; may bug, pad
                        newZone := Zone(code, zoneStart, zoneStop, startCol, startRow, stopCol, stopRow, xAsInt, yAsInt, wAsInt, hAsInt)
                        this.Push(newZone)

                        ; print zoneStart " " zoneStop "`n"
                    }
                }

            }

        }


        ; print "Zones count : " this.zones.Length

        ; for it in this {
        ;     print it.toString() "`n"
        ; }
    }

    availableZones(usedSlots) {
        available_zones := []

        ; compute all available zones
        for startRow in range(1, this.rows) {

            for startCol in range(1, this.cols) {

                startIndex := (startRow - 1) * this.cols + startCol
                zoneStart := startIndex

                if (usedSlots[startIndex] == 1) {
                    ; print startCol "," startRow " used`n"
                    continue
                }

                for stopRow in range(startRow, this.rows) {

                    for stopCol in range(startCol, this.cols) {

                        stopIndex := (stopRow - 1) * this.cols + stopCol
                        zoneStop := stopIndex

                        if (usedSlots[stopIndex] == 1) {
                            ; print startCol "," startRow " used `n"
                            break
                        }

                        if (zoneStop >= 10) {
                            code := (zoneStart * 100) + zoneStop
                        } else {
                            code := (zoneStart * 10) + zoneStop
                        }

                        available_zones.Push(code)
                    }
                }
            }
        }
        return available_zones
    }

    shiftToZone(zone, zoneToFitIn) {
        startColOffset := zoneToFitIn.startCol - zone.startCol
        stopColOffset := zoneToFitIn.stopCol - zone.stopCol
        startRowffset := zoneToFitIn.startRow - zone.startRow
        stopRowffset := zoneToFitIn.stopRow - zone.stopRow

        newStartCol := zoneToFitIn.startCol + startColOffset
        newStopCol := newStartCol + zone.cols - 1

        newZoneStart := (zone.startRow - 1) * this.cols + newStartCol
        newZoneStop := (zone.stopRow - 1) * this.cols + newStopCol

        if (newZoneStop >= 10) {
            code := (newZoneStart * 100) + newZoneStop
        } else {
            code := (newZoneStart * 10) + newZoneStop
        }

        ; print "Zone " zone.code " resized to " code "`n"
        resizedToFit := this.findByCode(code)
        return resizedToFit
    ; }
    }
    ; Right - left ?
    fitToZone(zone, zoneToFitIn) {
        ; if (this.isInside(zone, zoneToFitIn)) {
        ;     ; nothing to do
        ;     ; print "Zone " zone.code " is  inside " zoneToFitIn.code "`n"
        ;     return zone
        ; } else {

            startColOffset := zoneToFitIn.startCol - zone.startCol
            stopColOffset := zoneToFitIn.stopCol - zone.stopCol
            startRowffset := zoneToFitIn.startRow - zone.startRow
            stopRowffset := zoneToFitIn.stopRow - zone.stopRow

            newStartCol := zone.startCol + startColOffset
            newStopCol := zone.stopCol + stopColOffset

            newZoneStart := (zone.startRow - 1) * this.cols + newStartCol
            newZoneStop := (zone.stopRow - 1) * this.cols + newStopCol

            if (newZoneStop >= 10) {
                code := (newZoneStart * 100) + newZoneStop
            } else {
                code := (newZoneStart * 10) + newZoneStop
            }

            ; print "Zone " zone.code " resized to " code "`n"
            resizedToFit := this.findByCode(code)
            return resizedToFit
        ; }

    }

    

    ; ; Right - left ?
    ; expandToZone(zone, zoneToExpandIn) {

       
    ;     startColOffset := zoneToExpandIn.startCol - zone.startCol
    ;     stopColOffset := zoneToExpandIn.stopCol - zone.stopCol
    ;     startRowffset := zoneToExpandIn.startRow - zone.startRow
    ;     stopRowffset := zoneToExpandIn.stopRow - zone.stopRow

    ;     print "startColOffset " startColOffset " stopColOffset " stopColOffset " startRowffset " startRowffset " stopRowffset " stopRowffset "`n"

    ;     newStartCol := zone.startCol + startColOffset
    ;     newStopCol := zone.stopCol + stopColOffset

    ;     newZoneStart := (zone.startRow - 1) * this.cols + newStartCol
    ;     newZoneStop := (zone.stopRow - 1) * this.cols + newStopCol

    ;     if (newZoneStop >= 10) {
    ;         code := (newZoneStart * 100) + newZoneStop
    ;     } else {
    ;         code := (newZoneStart * 10) + newZoneStop
    ;     }

    ;     print "Zone " zone.code " resized to " code "`n"
    ;     resizedToFit := this.findByCode(code)
    ;     return resizedToFit
    ; }

    isInside(zone, outerZone) {
        return zone.startCol >= outerZone.startCol and
            zone.stopCol <= outerZone.stopCol and
            zone.startRow >= outerZone.startRow and
            zone.stopRow <= outerZone.stopRow
    }

    zoneRightOf(zone) {
        startCol := zone.stopCol + 1
        stopCol := this.cols

        startRow := zone.startRow
        stopRow := zone.stopRow

        zoneStart := (startRow - 1) * this.cols + startCol
        zoneStop := (stopRow - 1) * this.cols + stopCol

        if (zoneStop >= 10) {
            code := (zoneStart * 100) + zoneStop
        } else {
            code := (zoneStart * 10) + zoneStop
        }

        ; print "zoneRightOf " zone.code " " code "`n"
        zoneRightOf := this.findByCode(code)
        return zoneRightOf
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
        return ""
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

    ; generic prev/next in array 
    previousInHorizontalCycle(tile) {
        cycle := this.findHorizontalCycle(tile)
        indexInCycle := this.indexOf(tile, cycle)
        previous := indexInCycle - 1

        if ( previous == 0 )
            previous := cycle.Length

        return this.findByCode(cycle[previous])
    }

    nextInHorizontalCycle(tile) {
        cycle := this.findHorizontalCycle(tile)
        indexInCycle := this.indexOf(tile, cycle)
        next := indexInCycle + 1

        if ( next > cycle.Length )
            next := 1

        return this.findByCode(cycle[next])
    }

    findHorizontalCycle(tile) {
        ; should check for doublon
        for array in this.H_CYCLES {
            for zone in array {
                if (zone == tile.currentZone.code)
                    return array
            }
        }
        return []
    }

    previousInVerticalCycle(tile) {
        cycle := this.findVerticalCycle(tile)
        indexInCycle := this.indexOf(tile, cycle)
        previous := indexInCycle - 1

        if ( previous == 0 )
            previous := cycle.Length

        return this.findByCode(cycle[previous])
       }

    nextInVerticalCycle(tile) {
        cycle := this.findVerticalCycle(tile)
        indexInCycle := this.indexOf(tile, cycle)
        next := indexInCycle + 1

        if ( next > cycle.Length )
            next := 1

        return this.findByCode(cycle[next])
    }

    findVerticalCycle(tile) {
        ; should check for doublon
        for array in this.V_CYCLES {
            for zone in array {
                if (zone == tile.currentZone.code)
                    return array
            }
        }
        return []
    }


    indexOf(tile, array) {
        for candidate in array {
            if (candidate == tile.currentZone.code)
                return A_Index
        }
        return -1
    }

    distanceFromZone(tile) {
        WinGetPosEx(&x, &y, &w, &h, tile.handle)

        tileZone := tile.currentZone

        centerDistance := tileZone.centerDistance(x, y, x + w, y + h)
        startPosDistance := distance(x, y, tileZone.x, tileZone.y)
        finalDistance := centerDistance + startPosDistance
        ; print "Distance to " candidate.code " : "  finalDistance "`n"
        return finalDistance
    }

    findByName(name) {

    }

    debugResize := false

    debug(msg) {
        ; if (this.debugResize == true)
        print msg "`n"
    }

    growLeft(zone) {
        return this.resize(zone, -1, 0, 0, 0)
    }

    growRight(zone) {
        return this.resize(zone, 0, 1, 0, 0)
    }

    growUp(zone) {
        return this.resize(zone, 0, 0, -1, 0)
    }

    growDown(zone) {
        return this.resize(zone, 0, 0, 0, 1)
    }

    shrinkLeft(zone) {
        return this.resize(zone, 1, 0, 0, 0)
    }

    shrinkRight(zone) {
        return this.resize(zone, 0, -1, 0, 0)
    }

    shrinkUp(zone) {
        return this.resize(zone, 0, 0, 1, 0)
    }

    shrinkDown(zone) {
        return this.resize(zone, 0, 0, 0, -1)
    }

    moveRight(zone) {
        return this.resize(zone, 1, 1, 0, 0)
    }

    resize(zone, xOffsetStart, xOffseStop, yOffsetStart, yOffsetStop) {
        if (this.debugResize)
            print "From " zone.toString() "`n"

        ; shrink or grow left
        startCol := zone.startCol + xOffsetStart

        ; shrink or growright
        stopCol := zone.stopCol + xOffseStop

        ; shrink or grow up
        startRow := zone.startRow + yOffsetStart

        ; shrink or grow down
        stopRow := zone.stopRow + yOffsetStop

        if (startCol < 1) {
            print "`tERROR: start col must be >= 1`n"
            return zone
        }

        if (startCol > this.cols) {
            print "`tERROR:  start col must be <= " this.cols "`n"
            return zone
        }

        if (stopCol > this.rows) {
            print "`tERROR:  stop col must be <= " this.rows "`n"
            return zone
        }

        if (stopCol < 1) {
            print "`tERROR: stop col must be >= 1 `n"
            return zone
        }

        if (stopCol < startCol) {
            print "`tERROR: stopCol must be <= startCol `n"
            return zone
        }

        if (stopRow < startRow) {
            print "`tERROR: stopRow must be <= startRow `n"
            return zone
        }

        zoneStart := (startRow - 1) * this.cols + startCol
        zoneStop := (stopRow - 1) * this.cols + stopCol

        if (zoneStop >= 10) {
            code := (zoneStart * 100) + zoneStop
        } else {
            code := (zoneStart * 10) + zoneStop
        }

        ; print "From :`t start " zone.startCol " "  zone.startRow  " stop " zone.stopCol " " zone.stopRow "`n"

        resizedZone := this.findByCode(code)

        if (!IsObject(resizedZone)) {
            print "ERROR !  resize result not found " code "`n"
            return zone
        }

        if (this.debugResize)
            print "To   " resizedZone.toString() "`n"

        return resizedZone
    }


}


class Zone {

    __New(code, zoneStart, zoneStop, startCol, startRow, stopCol, stopRow, x, y, w, h) {
        this.code := code
        if (namedZones.Has("" this.code))
            this.name := namedZones["" this.code]
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
        this.cols := (this.stopCol - this.startCol + 1)
        this.rows := (this.stopRow - this.startRow + 1)
        this.size := this.cols * this.rows
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
        return this.name " " this.code " " this.cols "x" this.rows " (" this.x "," this.y " " this.w "x" this.h " ) " this.startCol "," this.stopCol " x " this.startRow "," this.stopRow " size " this.size " center " this.centerX() "," this.centerY()
    }

}