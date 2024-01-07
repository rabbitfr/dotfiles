print "Loading Tiler2.ahk`n"
#Include zones.ahk


class TileManager {

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

    snap(areaCode, handle := WinGetId("A"), internal := false) {
        action := MoveCommand(areaCode, handle, internal)
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
                this.tabsSnapshots := AltTabWindows()
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

    scratchPad() {
        this.tiles.toggleScratchPad()
    }

    addToScratchPad(handle := WinGetId("A")) {
        this.tiles.addToScratchPad(handle)
    }

}

class PositionHistory extends Map {

    debugHistory := false

    add(outerZone, zone) {

        if (this.Has(outerZone.code)) {
            outerZoneHistory := this[outerZone.code]
        } else {
            outerZoneHistory := []
        }

        ; keep zone ordered by time
        zoneIndex := this.indexOf(zone, outerZoneHistory)

        if (zoneIndex != -1) {
            outerZoneHistory.RemoveAt(zoneIndex)
            outerZoneHistory.Push(zone)
            print "Updated zone " zone.code " in history to last entry`n"
        } else {
            outerZoneHistory.Push(zone)
            print "Added pos " zone.code " to zone " outerZone.code " history `n"
        }

        this[outerZone.code] := outerZoneHistory

        if (this.debugHistory) {
            for key, array in this {
                print "OuterZone " key "`n"
                for (pos in array) {
                    print "  pos " pos.code "`n"
                }
            }
        }

    }

    clear() {

    }

    findLastKnonwPosition(outerZone) {

        if (this.Has(outerZone.code)) {
            outerZoneHistory := this[outerZone.code]

            last := outerZoneHistory.Length
            return outerZoneHistory[last]

        } else {
            return -1
        }

    }

    indexOf(zone, outerZoneHistory) {
        for position in outerZoneHistory {
            if (position.code == zone.code) {
                return A_Index
            }
        }
        return -1
    }
}


class MoveCommand {

    __New(zone, target, internal) {

        this.zone := zone
        this.target := target
        this.done := false
        this.undone := false
        this.internal := internal
    }

    do(tiler) {

        if (this.done) {
            print "Cannot do same action twice`n"
            return
        }
        ; print "Do MoveCommand : " this.target " to " this.zone "`n"
        this.previousArea := tiler.tiles.findByHandle(this.target).currentZone.code

        if ( this.internal) {
        tiler.tiles.internalSnapTo(this.zone, this.target)
    } else {
            tiler.tiles.snapTo(this.zone, this.target)

        }
        this.done := true
        this.undone := false

    }

    undo(tiler) {
        if (this.undone) {
            print "Cannot undo same action twice`n"
            return
        }

        print "Undo MoveCommand `n"
        tiler.tiles.internalSnapTo(this.previousArea, this.target)
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