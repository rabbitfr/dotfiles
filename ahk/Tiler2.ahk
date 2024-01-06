print "Loading Tiler2.ahk`n"
#Include zones.ahk



class Tiler2 {

    ; move to state class
    drawActiveDisabled := false

    __New() {
        this.zones := Zones()
        this.tiles := Tiles(this.zones)
        this.commandHistory := []
    }

    update() {
        this.tiles.update
    }

    updateActive() {
        this.tiles.updateActiveWindow()
    }

    snap(areaCode, handle := WinGetId("A")) {
        action := MoveCommand(areaCode, handle)
        action.do(this)
        this.commandHistory.Push(CommandLog(action, handle, "none"))
        ; this.tiles.snapTo(areaCode, handle)
    }

    undo() {
        ; last := this.lastCommand()

        ; if (last == -1)
        ;     return


        ; ; todo reverse order
        ; for command in last.commands {
        ;     command.undo(this)
        ; }
        ; ; this.lastCommand.undo(this)
    }

    redo() {
        ; last := this.lastCommand()

        ; if (last == -1)
        ;     return

        ; ; this.lastCommand.do(this)
        ; for command in last.commands {
        ;     command.do(this)
        ; }
    }

    switch() {

    }

    
    tabsSnapshots := []
    previousHighlight := -1

    altTab() {
        print "-- highlight next window in history list  ---`n"
        ; this.drawActiveDisabled := true

        try {

            if (this.tabsSnapshots.Length == 0) {
                this.tabsSnapshots :=  AltTabWindows()
                this.previousHighligh := -1
            }

            ; show active win
            activeHandle := WinGetId("A")
            active := this.tiles.findByHandle(activeHandle)
            active.active()

            ; for h in this.tabsSnapshots
            ;     print "tabs : " h "`n"


            ; for h in this.handles
            ;     print "handles : " h "`n"


            if (this.previousHighlight == -1)
                currentHandle := WinGetId("A")
            else
                currentHandle := this.previousHighlight

            currentIndex := indexOf(this.tabsSnapshots, currentHandle)
            current := this.tiles.findByHandle(currentHandle)
            ; print "current " currentIndex " " currentHandle " : clearing border "

            current.clearBorder()

            nextIndex := currentIndex + 1

            if (nextIndex > this.tabsSnapshots.Length)
                nextIndex := 1


            nextHandle := this.tabsSnapshots[nextIndex]
            next := this.tiles.findByHandle(nextHandle)
            ; print "next " nextIndex " " nextHandle " : highlight border "
            next.activate()
            ; next.bringToFront()

            this.previousHighlight := nextHandle


        } catch as e {
            print "ERRR " e
            ; this.drawActiveDisabled := false
            ; this.previousHighligh := -1
        }

    }

    altTabStop() {

        print "-- alt tab stop ---"
        this.drawActiveDisabled := false

        if (this.previousHighlight != -1) {
            ; show active win
            activeHandle := this.previousHighlight
            WinActivate(activeHandle)
        }

        this.tabsSnapshots := []
        this.previousHighligh := -1

    }



    modLeft(handle := WinGetId("A")) {
            commands := this.tiles.modLeft(handle)

            for command in commands {
                command.do(this)
            }
    }

    modRight(handle := WinGetId("A")) {
        ; last := this.lastCommand()

        ; if (last.source == handle and last.shortcut == "modLeft") {
        ;     ; reverse last command
        ;     for command in last.commands {
        ;         command.undo(this)
        ;     }
        ; } else {
            commands := this.tiles.modRight(handle)

            for command in commands {
                command.do(this)
            }

            ; this.commandHistory.Push(CommandLog(commands, handle, "modLeft"))
        ; }
    }

    modUp(handle := WinGetId("A")) {
        commands := this.tiles.modUp(handle)

        for command in commands {
            command.do(this)
        }

        this.commandHistory.Push(CommandLog(commands, handle, "modDown"))
    }

    modDown(handle := WinGetId("A")) {
        commands := this.tiles.modDown(handle)

        for command in commands {
            command.do(this)
        }
        this.commandHistory.Push(CommandLog(commands, handle, "modUp"))
    }

    nextInStack(handle := WinGetId("A")) {
        ; on veut dans l'ordre de alt tab 

        ; next := this.tiles.nextInZone(handle) 

        ; if ( IsObject(next))
        ;     next.activate()
        ; current := this.tiles.findByHandle(handle) 

        
        ; inStack := this.tiles.findByZone(current.currentZone.code) ; replace all with a tilesList and next() prev() ?

        ; if ( inStack.Length <= 1 )
        ;     return 

        ; print "Apps in same area : " inStack.Length

        ; currentIndex := indexOf(inStack, current)

        ; print "currentIndex " currentIndex "/" inStack.Length

        ; next := currentIndex + 1

        ; print "next " next 
     
        ; if (next > inStack.Length) {
        ;     next := 1
        ; }

        ; inStack[currentIndex].activate()
    }

    previousInStack(handle := WinGetId("A")) {

        ; current := this.tiles.findByHandle(handle)

        ; inStack := this.tiles.findByZone(current.currentZone.code)

        ; if ( inStack.Length <= 1 )
        ;     return 

        ; print "Apps in same area : " inStack.Length

        ; currentIndex := indexOf(inStack, current)

        ; print "currentIndex " currentIndex "/" inStack.Length

        ; previous := currentIndex - 1

        ; print "previous " previous 
     
        ; if (previous < 1) {
        ;     previous :=  inStack.Length
        ; }

        ; inStack[currentIndex].activate()
    }

}


class Tiles extends Array {

    disableAltArea := false

    __New(zones) {
        this.zones := zones
        this.update()
    }

    update() {

        windows := AltTabWindows()

        ;
        ; Removing closed apps
        ;
        for existingTile in this {
            exists := WinExist(existingTile.handle)

            if (!exists) {
                print "Tile destroyed, removing " existingTile.handle "`n"
                index := this.indexOf(existingTile.handle)
                this.RemoveAt(index)
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
                existingTile.currentZone := matchedZone
                this[existingIndex] := existingTile
                ; print "Updated index " existingIndex ", to " this[existingIndex].toString()

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
                    commands.Push(MoveCommand(newZone.code, h))

                }
                commands.Push(MoveCommand(R3, handle))
            case R3:
                commands.Push(MoveCommand(C, handle))
                ; unexpand
                ; case R3: this.snapTo(C, handle)
                ;     ; glue and unexpand
            case L3:
                onTheRight := this.tilesRightOf(tile)

                for h in onTheRight {
                    right := this.findByHandle(h)
                    newZone := this.zones.growLeft(right.currentZone)
                    commands.Push(MoveCommand(newZone.code, h))

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
                onTheRight := this.tilesRightOf(tile)

                for h in onTheRight {
                    right := this.findByHandle(h)
                    print "`t " right.toString()

                    if (right.currentZone.cols == 2) {
                        newZone := this.zones.shrinkLeft(right.currentZone)
                    } else if (right.currentZone.cols == 1) {
                        newZone := this.zones.moveRight(right.currentZone)

                    }
                    commands.Push(MoveCommand(newZone.code, h))
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
        tile := this.findByHandle(handle)
        zone := this.zones.findByCode(zoneId)
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


class Tile {

    __New(handle, process, zone, class, state, tiler) {
        this.handle := handle
        this.process := process
        this.currentZone := zone
        this.class := class
        this.state := state
        this.tiler := tiler
    }

    snapTo(zone) {
        print "snap to " zone.code "(current " this.currentZone.code ")"

        ; switch to next mod if available : same shortcut with another mod key on double press
        if (!this.tiler.disableAltArea) {
            if (zone.code == this.currentZone.code) {
                zone := this.altArea(zone)
            }
        }

        WinMoveEx zone.x, zone.y, zone.w, zone.h, this.handle
        this.currentZone := zone
    }

    getSiblingsOnArea() {
        siblings := []

        for tile in this.tiler {
            if (tile.handle != this.handle and tile.currentZone.code == this.currentZone.code) {
            ; if (tile.currentZone.code == this.currentZone.code) {
                siblings.Push(tile.handle)
            }
        }

        return siblings
    }


    hasSiblingsOnArea() {
        return this.getSiblingsOnArea().Length > 0
    }

    altArea(zone) {
        switch zone.code {
            case BLC: next := BL
            case CB: next := B
            case BRC: next := BR
            case L: next := LS
            case LS: next := L3
            case C: next := ALMOST_FULLSCREEN
            case R: next := RS
            case RS: next := R3
            case TLC: next := TL
            case CT: next := T
            case TRC: next := TR
            case BLC: next := BL
            default:
                print zone.code " has not alt area configured"
                return zone
        }
        print "Next " next "`n"
        nextArea := this.tiler.zones.findByCode(next)
        return nextArea
    }

    clearBorder() {
        DrawBorder(this.handle, , 0)
    }

    pink_color := "0xf9cbe5"
    yellow_color := "0xFFE62D"
    violet_color := "0x6238FF"
    green_color := "0x7ce38b"

    drawBorder() {
        if (this.hasSiblingsOnArea()) {
            border_color := this.pink_color
        } else {
            border_color := this.green_color
        }
        DrawBorder(this.handle, border_color, 1)
    }

    

    highlight() {
        DrawBorder(this.handle, this.yellow_color, 1)
    }

    active() {
        DrawBorder(this.handle, this.green_color, 1)
    }

    
    activate() {
        WinActivate(this.handle)
    }


    toString() {
        return padEnd(this.handle, 10, " ") " " padEnd(this.process, 20, " ") " " this.currentZone.name " " this.class
    }
}



class MoveCommand {

    __New(zone, target) {

        this.zone := zone
        this.target := target
        this.done := false
        this.undone := false
    }

    do(tiler) {

        if (this.done) {
            print "Cannot do same action twice`n"
            return
        }
        print "Do MoveCommand : " this.target " to " this.zone "`n"
        this.previousArea := tiler.tiles.findByHandle(this.target).currentZone.code
        tiler.tiles.snapTo(this.zone, this.target)

        this.done := true
        this.undone := false

    }

    undo(tiler) {
        if (this.undone) {
            print "Cannot undo same action twice`n"
            return
        }

        print "Undo MoveCommand `n"
        tiler.tiles.snapTo(this.previousArea, this.target)
        this.done := false
        this.undone := true
    }
}

class ResizeCommand {

    __New(xOffsetStart, xOffseStop, yOffsetStart, yOffsetStop, target) {
        this.xOffsetStart := xOffsetStart
        this.xOffseStop := xOffseStop
        this.yOffsetStart := yOffsetStart
        this.yOffsetStop := yOffsetStop
        this.target := target
        this.done := false
        this.undone := false
    }

    do(tiler) {

        if (this.done) {
            print "Cannot do same action twice`n"
            return
        }

        print "Do ResizeCommand : " this.target " to " this.zone "`n"

        this.previousZone := tiler.tiles.findByHandle(this.target).currentZone.code

        newZone := tiler.zones.resize(this.xOffsetStart, this.xOffseStop, this.yOffsetStart, this.yOffsetStop, this.target)

        this.done := true
        this.undone := false

    }

    undo(tiler) {
        if (this.undone) {
            print "Cannot undo same action twice`n"
            return
        }
        print "uno ResizeCommand `n"

        tiler.tiles.snapTo(this.previousArea, this.target)

        this.done := false
        this.undone := true

    }
}

class CommandLog {

    __New(commands, source, shortcut) {
        this.commands := commands
        this.source := source
        this.shortcut := shortcut
    }


}