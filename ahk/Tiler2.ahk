print "Loading Tiler2.ahk`n"

class Tiler2 {

    __New() {
        this.zones := Zones()

        ; for key,val in namedZones
        ;     print key "`n"
        this.tiles := Tiles(this.zones)
    }

    update() {
        this.tiles.update
    }


    snap(areaCode, handle := WinGetId("A")) {
        this.tiles.snapTo(areaCode, handle)
    }
}


class Tiles extends Array {

    __New(zones) {
        this.zones := zones
        this.update()
    }

    update() {

        windows := AltTabWindows()

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
                ; print "new tile found, add to list "
                newTile := Tile(handle, process, matchedZone, class, state, this)
                this.Push(newTile)
            }
        }

        for candidate in this {
            print candidate.toString() "`n"
        }
    }

    snapTo(zoneId, handle := WinGetId("A")) {
        tile := this.findByHandle(handle)
        zone := this.zones.findByCode(zoneId)
        tile.snapTo(zone)
    }

    filterByArea(zoneId) {

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
        ; print "snap to " zone.code "(current " this.currentZone.code ")"

        ; switch to next mod if available : same shortcut with another mod key on double press
        if (zone.code == this.currentZone.code) {
            zone := this.altArea(zone)
        }

        WinMoveEx zone.x, zone.y, zone.w, zone.h, this.handle
        this.currentZone := zone
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
        }
        print "Next " next "`n"
        nextArea := this.tiler.zones.findByCode(next)
        return nextArea
    }

    toString() {
        return padEnd(this.handle,10," ") " " padEnd(this.process,20," ") " " this.currentZone.name " " this.class
    }
}