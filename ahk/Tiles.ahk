class Tiles extends Array {

    disableAltArea := false

    __New(zones) {
        this.zones := zones
        this.update()
        this.scratchPad := false
    }

    update() {

        windows := AltTabWindows()

        ;
        ; Removing closed apps
        ;
        for existingTile in this {

            if (existingTile.inScratchPad and existingTile.isHidden) {
                ; tile still exists but is hidden
            } else {
                exists := WinExist(existingTile.handle)

                if (!exists) {
                    print "Tile destroyed, removing " existingTile.handle "`n"
                    index := this.indexOf(existingTile.handle)
                    this.RemoveAt(index)
                }

            }

        }

        created := []

        ;
        ; Add or update existing apps
        ;
        for handle in windows {
            process := WinGetProcessName(handle)
            class := WinGetClass(handle)
            title := WinGetTitle(handle)
            state := WinGetMinMax(handle)
            matchedZone := -1

            guessedAreas := this.zones.findMatches(handle)

            if (guessedAreas.Length == 1) {
                ; print process " : area " guessedAreas[1].code "`n" ; first ?
                matchedZone := guessedAreas[1]
            } else if (guessedAreas.Length > 1) {
                print process " : more than 1 area matches  " guessedAreas.Length "`n"
            }

            existingIndex := this.indexOf(handle)

            if (existingIndex != -1) {

                existingTile := this[existingIndex]

                if (existingTile.currentZone.code != matchedZone.code) {
                    existingTile.currentZone := matchedZone
                    ; existingTile.history.add(existingTile.currentZone)
                    this[existingIndex] := existingTile
                    ; print "Updated index " existingIndex ", to " this[existingIndex].toString()
                }


            } else {
                newTile := Tile(handle, process, matchedZone, class, state, this)
                print "Tile created, adding " handle " " process " (distance " this.zones.distanceFromZone(newTile) ")`t"
                this.Push(newTile)
                created.Push(handle)
            }
        }

        for newTile in created
            this.onNewWindow(newTile)

        this.updateActiveWindow()
    }

    onNewWindow(newHandle) {

        if (this.isEmpty(newHandle)) {
            this.disableAltArea := true
            this.snapTo(C, newHandle)
            this.disableAltArea := false
        } else {
            ; find open slots ?
            freeZones := this.freeZones()

            ; custom behaviors
            placed := this.tryToPlacecOnePreferred(C, newHandle, this.preferredNewTilesC)

            if (!placed)
                placed := this.tryToPlacecOnePreferred(R3, newHandle, this.preferredNewTilesR3)
            if (!placed)
                placed := this.tryToPlacecOnePreferred(L3, newHandle, this.preferredNewTilesL3)
            if (!placed)
                placed := this.tryToPlacecOnePreferred(LS, newHandle, this.preferredNewTilesLS)
            if (!placed)
                placed := this.tryToPlacecOnePreferred(RS, newHandle, this.preferredNewTilesRS)


            if (!placed) {
                ;  use preferred using existing process ?
            }
        }
    }

    tryToPlacecOnePreferred(mainZone, newHandle, preferred) {
        if (this.isZoneUsed(mainZone)) {
            for zone in preferred {
                if (this.isZoneUsed(zone) == 0) {
                    this.snapTo(zone, newHandle)
                    return true
                }
            }
        }
        return false
    }

    preferredNewTilesC := [TRC, BRC, TLC, BLC]
    preferredNewTilesL3 := [TRC, BRC,]
    preferredNewTilesR3 := [TLC, BLC]
    preferredNewTilesLS := [TR, BR]
    preferredNewTilesRS := [TL, BL]

    freeZones() {
        usedSlots := []

        for index in range(1, this.zones.cols * this.zones.rows)
            usedSlots.Push(0) ; add initArray

        for tile in this {

            zone := tile.currentZone

            if (zone.code == 00 or zone.code == -1)
                continue

            for row in range(zone.startRow, zone.stopRow) {
                for col in range(zone.startCol, zone.stopCol) {
                    usedIndex := (row - 1) * this.zones.cols + col
                    usedSlots[usedIndex] := 1
                }
            }

        }
        available_zones := this.zones.availableZones(usedSlots)

        return available_zones
    }

    ; true is any windows has status -2 SCRATCHPAD_HIDDEN
    hasTilesInScratchpad() {
        for tile in this {
            if (tile.isInScratchPad())
                return true
        }
        return false
    }

    toggleScratchPad() {

        if (this.scratchPad) {
            ; print "SCRATCHPAD on. toggling off `n"

            ; show all tiles not in scratchpad
            for tile in this {
                if (!tile.isInScratchPad()) {
                    tile.show()
                }
            }

            ; hide all tiles in scratchpad
            for tile in this {
                if (tile.isInScratchPad()) {
                    tile.hide()
                }
            }
            this.scratchPad := false
        } else {
            ; print "SCRATCHPAD off. toggling on`n"
            ; hide all tiles not in scratchpad
            for tile in this {
                if (!tile.isInScratchPad()) {
                    tile.hide()
                }
            }

            ; hide all tiles in scratchpad
            for tile in this {
                if (tile.isInScratchPad()) {
                    tile.show()
                }
            }

            this.scratchPad := true
        }
    }

    addToScratchPad(handle) {
        toAdd := this.findByHandle(handle)

        if (toAdd.isInScratchPad()) {
            toAdd.removeFromScratchPad()
        } else {
            toAdd.addToScratchPad()
        }
    }

    modLeft(handle := WinGetId("A")) {

        tile := this.findByHandle(handle)

        commands := []

        switch tile.currentZone.code {
            ; expand
            case C:
                commands.Push(MoveCommand(L3, handle))
            case RS:
                onTheLeft := this.tilesLeftOf(tile)

                for h in onTheLeft {
                    left := this.findByHandle(h)
                    newZone := this.zones.shrinkRight(left.currentZone)

                    if (newZone.code != left.currentZone.code) ; avoid altSnap
                        commands.Push(MoveCommand(newZone.code, h))
                }

                commands.Push(MoveCommand(R3, handle))
            case R3:
                commands.Push(MoveCommand(C, handle))
                ; unexpand
                ; case R3: this.snapTo(C, handle)
                ;     ; glue and unexpand
            case L3:
                currentZone := this.zones.findByCode(L3)
                currentZoneOnTheRight := this.zones.zoneRightOf(currentZone)
                nextZone := this.zones.findByCode(LS)
                nextZoneOnTheRight := this.zones.zoneRightOf(nextZone)

                tilesOnTheRight := this.tilesRightOf(tile)

                for h in tilesOnTheRight {

                    candidate := this.findByHandle(h)

                    lastKnowPosition := candidate.history.findLastKnonwPosition(nextZoneOnTheRight)

                    if (lastKnowPosition != -1) {
                        print "`t Last known position in this area : " lastKnowPosition.code "`n"
                        newZone := lastKnowPosition
                    } else {
                        newZone := this.zones.fitToZone(candidate.currentZone, nextZoneOnTheRight)

                        ; Tile zone has been updated by the expand/contract of another tile
                        ; store previous position in given zone to eventually restore if needed

                        candidate.history.add(currentZoneOnTheRight, candidate.currentZone)
                    }

                    ; if (newZone.code != candidate.currentZone.code) {
                    commands.Push(MoveCommand(newZone.code, h))


                    ; }

                    ; candidate.history.add(candidate.currentZone)
                }

                commands.Push(MoveCommand(LS, handle))
                ; swap
            case LS:
                ; onTheLeft := this.tilesRightOf(tile)

                ; for h in onTheLeft {
                ;     left := this.findByHandle(h)
                ;     newZone := this.zones.shrinkRight(left.currentZone)
                ;     commands.Push(MoveCommand(newZone.code, h))

                ; }
                commands.Push(MoveCommand(R3, handle))
        }

        return commands
    }


    modRight(handle := WinGetId("A")) {
        tile := this.findByHandle(handle)
        commands := []

        switch tile.currentZone.code {
            ; expand
            case C:
                commands.Push(MoveCommand(R3, handle))
            case LS:
                currentZone := this.zones.findByCode(LS)
                nextZone := this.zones.findByCode(L3)
                currentZoneOnTheRight := this.zones.zoneRightOf(currentZone)
                nextZoneOnTheRight := this.zones.zoneRightOf(nextZone)
                tilesOnTheRight := this.tilesRightOf(tile)

                for h in tilesOnTheRight {

                    candidate := this.findByHandle(h)
                    newZone := this.zones.fitToZone(candidate.currentZone, nextZoneOnTheRight)

                    ; if (newZone.code != candidate.currentZone.code) { ; avoid altSnap
                    commands.Push(MoveCommand(newZone.code, h))

                    ; Tile zone has been updated by the expand/contract of another tile
                    ; store previous position in given zone to eventually restore if needed

                    candidate.history.add(currentZoneOnTheRight, candidate.currentZone)
                }

                commands.Push(MoveCommand(L3, handle))
                ; unexpand
            case L3:
                commands.Push(MoveCommand(C, handle))

                ; glue and unexpand
            case R3:
                onTheLeft := this.tilesLeftOf(tile)

                for h in onTheLeft {
                    left := this.findByHandle(h)

                    newZone := this.growRight(left)

                    this.snapTo(newZone.code, h)
                    left.currentZone := newZone

                }
                this.snapTo(RS, handle)
                ; swap
            case RS: this.snapTo(LS, handle)
        }

        return commands
    }

    modDown(handle := WinGetId("A")) {

        tile := this.findByHandle(handle)

        commands := []

        switch tile.currentZone.code {
            ; expand
            case TRC:
                commands.Push(MoveCommand(R, handle))
            case TLC:
                commands.Push(MoveCommand(L, handle))
            case TR:
                commands.Push(MoveCommand(RS, handle))
            case TL:
                commands.Push(MoveCommand(LS, handle))
            default:
                newZone := this.zones.growDown(tile.currentZone)
                commands.Push(MoveCommand(newZone.code, handle))
        }

        return commands
    }

    modUp(handle := WinGetId("A")) {

        tile := this.findByHandle(handle)

        commands := []

        switch tile.currentZone.code {
            ; expand
            case R:
                commands.Push(MoveCommand(TRC, handle))
            case L:
                commands.Push(MoveCommand(TLC, handle))
            case RS:
                commands.Push(MoveCommand(TR, handle))
            case LS:
                commands.Push(MoveCommand(TL, handle))
            case BLC:
                commands.Push(MoveCommand(L, handle))
            case BRC:
                commands.Push(MoveCommand(R, handle))
            default:
                newZone := this.zones.growUp(tile.currentZone)
                commands.Push(MoveCommand(newZone.code, handle))
        }

        return commands
    }


    growLeft(tile) {
        ; print "grow left " area.name " " area.area

        zone := tile.currentZone

        newZoneStart := zone.zoneStart - 1
        newZoneStop := zone.zoneStop

        if (newZoneStop >= 10) {
            code := (newZoneStart * 100) + newZoneStop
        } else {
            code := (newZoneStart * 10) + newZoneStop
        }

        newZone := this.zones.findByCode(code)
        ; print "New zone ? " newZone.code
        ; print "Grow left :" zone.code " to " newZone.code

        return newZone
    }


    shrinkLeft(tile) {
        print "shrinkLeft " tile.currentZone.code " colWidth " tile.currentZone.cols

        if (tile.currentZone.cols < 2)
            return

        zone := tile.currentZone

        newZoneStart := zone.zoneStart + 1
        newZoneStop := zone.zoneStop

        if (newZoneStop >= 10) {
            code := (newZoneStart * 100) + newZoneStop
        } else {
            code := (newZoneStart * 10) + newZoneStop
        }

        newZone := this.zones.findByCode(code)
        ; print "New zone ? " newZone.code
        ; print "Grow left :" zone.code " to " newZone.code

        return newZone
    }

    growRight(tile) {

        zone := tile.currentZone

        ; print "grow right " zone.zoneStart " " zone.zoneStop "`n"

        newZoneStart := zone.zoneStart
        newZoneStop := zone.zoneStop + 1

        if (newZoneStop >= 10) {
            code := (newZoneStart * 100) + newZoneStop
        } else {
            code := (newZoneStart * 10) + newZoneStop
        }

        ; print "Getting zone " code "`n"
        newZone := this.zones.findByCode(code)

        ; print "New zone ? " newZone.code "`n"
        ; print "Grow right :" zone.code " to " newZone.code "`n"

        return newZone
    }

    tilesRightOf(tile) {

        tilesOnTheRight := []

        for candidate in this {
            if (candidate.currentZone.code == -1
                or candidate.currentZone.code == 9000
                or candidate.currentZone.code == 0
                or candidate.currentZone.code == 116)
                continue

            if (candidate.currentZone.startCol > tile.currentZone.stopCol) {
                tilesOnTheRight.Push(candidate.handle)
            }
        }

        return tilesOnTheRight
    }

    tilesLeftOf(tile) {

        tilesOnTheLeft := []

        for candidate in this {
            if (candidate.currentZone.code ~= "-1|9000|0|116")
                continue

            if (candidate.currentZone.startCol < tile.currentZone.startCol
                and candidate.currentZone.stopCol < tile.currentZone.startCol) {
                    tilesOnTheLeft.Push(candidate.handle)
            }
        }

        return tilesOnTheLeft
    }


    isEmpty(exclude := "") {

        for tile in this {
            if (tile.handle ~= exclude) {
                continue
            }
            if (tile.currentZone.code == MINIMIZED) {
                continue
            }
            return false
        }
        return true
    }

    updateActiveWindow() {
        ; get the active window
        active := WinExist("A")

        ; Start by removing the borders from all windows, since we do not know which window was previously active
        for tile in this {
            tile.clearBorder()
        }

        activeTile := this.findByHandle(active)

        if (IsObject(activeTile))
            activeTile.drawBorder()
        else
            print "No active tile found (" active ")`n"
    }

    snapTo(zoneId, handle := WinGetId("A")) {
        ; print "Tiles.snapTo zoneId " zoneId "`n"
        tile := this.findByHandle(handle)
        ; print "Tiles.snapTo tile " tile.handle "`n"
        zone := this.zones.findByCode(zoneId)
        ; print "Tiles.snapTo zone " zone.code "`n"
        tile.snapTo(zone)
    }

    isZoneUsed(zone) {
        return this.findByZone(zone).Length > 0
    }

    nextInZone(handle) {
        ; tiles := []

        ; current := this.findByHandle(handle)

        ; for tile in this {
        ;     if (tile.handle == handle)
        ;         currentIndex := A_Index
        ;     if tile.currentZone.code == current.currentZone.code
        ;         tiles.Push(tile)
        ; }

        ; if (tiles.Length == 1)
        ;     return

        ; nextIndex := currentIndex + 1

        ; if (nextIndex > tiles.Length ) {
        ;     nextIndex := 1
        ; }

        ; return tiles[nextIndex]
    }

    findByZone(zone) {
        tiles := []
        for tile in this {
            if tile.currentZone.code == zone
                tiles.Push(tile)
        }
        return tiles
    }

    indexOf(handle) {
        for tile in this {
            if tile.handle == handle
                return A_Index
        }
        return -1
    }

    findByHandle(handle) {
        for tile in this {
            if tile.handle == handle
                return tile
        }
    }


}