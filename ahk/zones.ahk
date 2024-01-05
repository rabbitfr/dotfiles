print "Loading Zones.ahk`n"

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

                        ; print zoneStart " "  zoneStop "`n"
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

                if (usedSlots[startIndex] == 1 ) {
                    ; print startCol "," startRow " used`n"
                    continue
                }

                for stopRow in range(startRow, this.rows) {

                    for stopCol in range(startCol, this.cols) {

                        stopIndex := (stopRow - 1) * this.cols + stopCol
                        zoneStop := stopIndex

                        if (usedSlots[stopIndex] == 1 ) {
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

    findByName(name) {

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
    }

    cols() {
        return (this.stopCol - this.startCol + 1)
    }

    rows() {
        return (this.stopRow - this.startRow + 1)
    }


    size() {
        return this.cols() * this.rows()
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
        return this.name " " this.code " " this.cols() "x" this.rows() " (" this.x "," this.y " " this.w "x" this.h " ) " this.startCol "," this.stopCol " x " this.startRow "," this.stopRow " size " this.size() " center " this.centerX() "," this.centerY()
    }

}