print "Loading Tiler2.ahk`n"
#Include zones.ahk

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

    updateActive() {
        this.tiles.updateActiveWindow()
    }

    snap(areaCode, handle := WinGetId("A")) {
        this.tiles.snapTo(areaCode, handle)
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

        for existingTile in this {
            exists := WinExist(existingTile.handle)

            if (!exists) {
                print "Tile destroyed, removing " existingTile.handle "`n"
                index := this.indexOf(existingTile.handle)
                this.RemoveAt(index)
            }
        }

        created := []

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
                print "Tile created, adding " handle " " process "`t"
                newTile := Tile(handle, process, matchedZone, class, state, this)
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
            if ( this.isZoneUsed(C)) {
                print "Custom C "

                for zone in this.preferredNewTilesC {

                    if ( this.isZoneUsed(zone) == 0 ) {
                        this.snapTo(zone, newHandle)
                        return
                    }
                }
             } else if ( this.isZoneUsed(L3)) {
                print "Custom C "

                for zone in this.preferredNewTilesL3 {

                    if ( this.isZoneUsed(zone) == 0 ) {
                        this.snapTo(zone, newHandle)
                        return
                    }
                }
             } else if ( this.isZoneUsed(R3)) {
                print "Custom C "

                for zone in this.preferredNewTilesR3 {

                    if ( this.isZoneUsed(zone) == 0 ) {
                        this.snapTo(zone, newHandle)
                        return
                    }
                }
             }
             else if ( this.isZoneUsed(LS)) {
                print "Custom C "

                for zone in this.preferredNewTilesLS {

                    if ( this.isZoneUsed(zone) == 0 ) {
                        this.snapTo(zone, newHandle)
                        return
                    }
                }
             }
             else if ( this.isZoneUsed(RS)) {
                print "Custom RS "

                for zone in this.preferredNewTilesRS {

                    if ( this.isZoneUsed(zone) == 0 ) {
                        this.snapTo(zone, newHandle)
                        return
                    }
                }
             }

        }
    }

    preferredNewTilesC := [ TRC, BRC, TLC, BLC ]
    preferredNewTilesL3 := [TRC, BRC,]
    preferredNewTilesR3 := [ TLC, BLC ]
    preferredNewTilesLS := [ TR, BR ]
    preferredNewTilesRS := [ TL, BL ]

    freeZones() {
        usedSlots := []

        for index in range(1, this.zones.cols * this.zones.rows)
            usedSlots.Push(0) ; add initArray

        for tile in this {

            zone := tile.currentZone

            if (zone.code == 00 or zone.code == -1 )
                continue

            for row in range(zone.startRow, zone.stopRow) {
                for col in range(zone.startCol, zone.stopCol) {
                    usedIndex := (row -1 ) * this.zones.cols + col 
                    usedSlots[usedIndex] := 1
                }
            }

        }
        available_zones := this.zones.availableZones(usedSlots)

        return available_zones
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
        ; print "snap to " zone.code "(current " this.currentZone.code ")"

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

    toString() {
        return padEnd(this.handle, 10, " ") " " padEnd(this.process, 20, " ") " " this.currentZone.name " " this.class
    }
}