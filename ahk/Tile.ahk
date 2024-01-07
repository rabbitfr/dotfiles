class Tile {

    __New(handle, process, zone, class, state, tiler, inScratchPad := false) {
        this.handle := handle
        this.process := process
        this.currentZone := zone
        this.class := class
        this.state := state
        this.tiler := tiler
        this.history := PositionHistory()
        ; this.history.add(this.currentZone)
        this.inScratchPad := inScratchPad
    }


    snapTo(zone, altSnap := false) {
        print "snap to " zone.code "(current " this.currentZone.code ")"

        ; switch to next mod if available : same shortcut with another mod key on double press
        if (altSnap) {
            if (!this.tiler.disableAltArea) {
                if (zone.code == this.currentZone.code) {
                    zone := this.altArea(zone)
                }
            }
        }

        WinMoveEx zone.x, zone.y, zone.w, zone.h, this.handle
        this.currentZone := zone
    }

    ; will snap without triggering the altsnap feature
    internalSnapTo(zone) {
        this.snapTo(zone, false)
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

    isNotMinimized() {
        return this.state != -1
    }

    isVisible() {
        WinExist("ahk_id " this.handle) != 0

    }

    isHidden() {
        WinExist("ahk_id " this.handle) == 0
    }
    ;
    ; ScratchPad Stuff
    ;

    isInScratchPad() {
        return this.inScratchPad
    }

    addToScratchPad() {
        if (!this.isInScratchPad()) {
            print "SCRATCH   ADD " this.toString() "`n"
            this.hide()
            this.inScratchPad := true
        }
    }

    removeFromScratchPad() {
        if (this.isInScratchPad()) {
            print "SCRATCH   REMOVE " this.toString() "`n"
            this.hide()
            this.inScratchPad := false
        }
    }

    show() {
        WinShow(this.handle)
    }

    hide() {
        WinHide(this.handle)
    }

    activate() {
        WinActivate(this.handle)
    }

    minimize() {
        WinMinimize(this.handle)
    }

    restore() {
        WinRestore(this.handle)
    }

    toString() {
        return padEnd(this.handle, 10, " ") " " padEnd(this.process, 20, " ") " " this.currentZone.name " " this.class
    }
}
