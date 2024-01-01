#Requires AutoHotkey v2.0
#SingleInstance Force
; #WinActivateForce ; send 32772
#ErrorStdOut
#Include helpers.ahk

class Tiler {

    ; spacing := 0
    ; columns := 0
    ; rows := 0
    ; originX := 0
    ; originY := 0
    ; areaWidth := 0
    ; areaWHeight := 0
    ; cellWidth := 0
    ; cellHeight := 0

    __New(columns := 4, rows := 2, spacing := 4) {
        this.spacing := spacing
        this.columns := columns
        this.rows := rows

        ; eventListener := Tiler.WindowsUpdater()

    }

    update() {
        print "Updating..."

        MonitorGetWorkArea(1, &wl, &wt, &wr, &wb)

        ; Compute tiles globabl properties from current screen
        originX := 0 + wl
        originY := 0 + wt

        areaWidth := (wr - wl)
        areaWHeight := (wb - wt)

        this.cellWidth := (areaWidth - ((this.columns + 1) * this.spacing)) // this.columns
        this.cellHeight := (areaWHeight - ((this.rows + 1) * this.spacing)) // this.rows

        ; Compute declared areas properties
        this.areas := Map()

        for name, area in namedAreas {

            print "Building " name " " area

            startCell := SubStr(area, 1, 1)

            startCol := Mod(startCell - 1, columns) + 1
            startRow := ((startCell - 1) // columns) + 1

            x := originX + ((startCol - 1) * this.cellWidth) + (startCol * spacing)
            y := originY + ((startRow - 1) * this.cellHeight) + (startRow * spacing)

            stopCell := SubStr(area, 2, 1)

            stopCol := Mod(stopCell - 1, columns) + 1
            stopRow := ((stopCell - 1) // columns) + 1

            w := ((stopCol - startCol) + 1) * this.cellWidth
            h := ((stopRow - startRow) + 1) * this.cellHeight

            newArea := Tiler.Area(name, area, startCell, stopCell, startCol, startRow, stopCol, stopRow, x, y, w, h)

            print "Adding " name " area"
            this.areas[name] := newArea

            print newArea.toString()
        }


        winHandles := WinGetList(, ,)

        ; Build current windows map for current screen
        this.handles := Map()

        for handle in winHandles
        {
            tile := this.getTile(handle)

            if (IsObject(tile))
                this.handles[handle] := tile
            else
                print handle " is not an object"

        }

        for id, handle in this.handles
            print handle.toString()
    }

    snapTo(area, id := WinGetId("A")) {
        tile := this.handles[id]
        tile.snapTo(area)

        ; print "Snap " tile.toString() " to " area

        ; if ( tile.a)

    }

    currentHandles() {
        winHandles := WinGetList(, ,)

        this.handles := Map()

        for handle in winHandles
        {
            tile := this.getTile(handle)

            if (IsObject(tile))
                this.handles[handle] := tile


        }

    }

    getArea(area) {
        ; print "-- areasToName"
        ; for key, value in areasToName {
        ;     print key " " value
        ; }
        ; print "-- areasToName"

        if (this.areas.Has("" area)) {
            foundArea := this.areas["" area]
            print "Found " foundArea.name " " foundArea.area

            return foundArea
        } else {
            print "1 Cannot find area for value '" area "'"
            return
        }

    }

    ; helper
    getTile(handle := WinGetId("A")) {

        class := WinGetClass(handle)

        ; ignore some system classes
        if (class ~= "WorkerW|Shell_TrayWnd|NarratorHelperWindow|Button|PseudoConsoleWindow")
            return

        try
            process := WinGetProcessName(handle)
        catch as e {
        }

        ; get window state Min/Max
        state := WinGetMinMax(handle)

        ; get position
        this.WinGetPosEx &x, &y, &width, &height, handle

        ; guess area
        startCol := Round(x / this.cellWidth) + 1
        startRow := Round(y / this.cellHeight) + 1

        stopCol := startCol + Round(width / this.cellWidth) - 1
        stopRow := startRow + Round(height / this.cellHeight) - 1

        startZone := startCol + ((startRow - 1) * this.columns)
        stopZone := stopCol + ((stopRow - 1) * this.columns)

        area := startZone stopZone
        ; print "Getting " area


        if (areasToName.Has(area)) {
            area := areasToName[area]
            tile := Tiler.Tile(handle, process, area, class, state, this)
            return tile
        } else {
            print "Cannot find area for " area " : " process
            return
        }

    }

    updateActiveWindow() {

        ; get the active window
        active := WinExist("A")

        ; Start by removing the borders from all windows, since we do not know which window was previously active
        for id, tile in this.handles {
            tile.clearBorder()
        }

        if (this.handles.Has(active)) {
            this.handles[active].drawBorder()
        } else {
            print "Cannot find handle " active " in current list ??"
        }

    }


    ; get window position without the invisible border
    WinGetPosEx(&x?, &y?, &w?, &h?, hwnd?) {
        static DWMWA_EXTENDED_FRAME_BOUNDS := 9

        if !(hwnd is integer)
            hwnd := WinExist(hwnd)
        if !IsSet(hwnd)
            hwnd := WinExist() ; last found window

        DllCall("dwmapi\DwmGetWindowAttribute",
            "ptr", hwnd,
            "uint", DWMWA_EXTENDED_FRAME_BOUNDS,
            "ptr", RECT := Buffer(16, 0),
            "int", RECT.size,
            "uint")
        x := NumGet(RECT, 0, "int")
        y := NumGet(RECT, 4, "int")
        w := NumGet(RECT, 8, "int") - x
        h := NumGet(RECT, 12, "int") - y
    }

    class Area {

        __New(name, area, startCell, stopCell, startCol, startRow, stopCol, stopRow, x, y, w, h) {
            this.name := name
            this.area := area
            this.startCell := startCell
            this.stopCell := stopCell
            this.startCol := startCol
            this.startRow := startRow
            this.stopCol := stopCol
            this.stopRow := stopRow
            this.x := x
            this.y := y
            this.w := w
            this.h := h
        }

        toString() {
            return this.name " " this.area " " this.startCol "," this.startRow " " this.stopCol " " this.stopRow "  pos " this.x "," this.y " " this.w "x" this.h
        }

    }

    class Tile {

        __New(id, process, area, class, state, tiler) {
            this.id := id
            this.process := process
            this.area := area
            this.class := class
            this.state := state
            this.tiler := tiler
        }

        clearBorder() {
            DrawBorder(this.id, , 0)
        }

        isActive() {
            ; active := WinActive(this.id)
            current := WinGetId("A")
            isActive := WinActive(this.id)
            print "current " current " id " this.id " isActive " isActive
            return true
        }

        getSiblingsOnArea() {
            siblings := Map()

            for id, tile in this.tiler.handles {
                if (id != this.id and tile.area == this.area) {
                    siblings[id] := tile
                    print "On same area " tile.toString()
                }
            }

            return siblings
        }

        hasSiblingsOnArea() {
            return this.getSiblingsOnArea().Count > 0
        }

        drawBorder() {

            if (this.hasSiblingsOnArea()) {
                border_color := "0xFFE62D" ; yellow
                ; border_color := "0x6238FF" ; violet
            } else {
                border_color := "0x7ce38b" ; green
            }
            DrawBorder(this.id, border_color, 1)

        }

        snapTo(area) {
            print "Snap " this.toString() " to '" area "'"


            ; if (area == this.area) {
            ;     ; switch to next mod if available : same shortcut with another mod key on double press
            ; }

            areaName := areasToName.Get("" area)
            nextArea := this.tiler.getArea(areaName)

            if (IsObject(nextArea)) {
                print "( Tile.snapTo(area) ) Found " nextArea.name " " nextArea.area
            } else {
                print "( Tile.snapTo(area) ) not an object " nextArea
            }


            WinMoveEx nextArea.x, nextArea.y, nextArea.w, nextArea.h, this.id


        }

        toString() {
            return this.id " " this.process " " this.area " " this.state
        }


    }


    ; class WindowsUpdater {

    ;     __New() {
    ;         hiddenEventReceiver := Gui()
    ;         hiddenEventReceiver.Opt("+LastFound")
    ;         receiver := WinExist()

    ;         DllCall("RegisterShellHookWindow", "UInt", receiver)
    ;         MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
    ;         OnMessage(MsgNum, OnEvent)
    ;     }


    ; }

}