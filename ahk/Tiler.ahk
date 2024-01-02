#Requires AutoHotkey v2.0
#SingleInstance Force
; #WinActivateForce ; send 32772 ?
#ErrorStdOut
#Include helpers.ahk

class Tiler {

    updatingDisabled := false

    __New(columns := 4, rows := 2, spacing := 4) {
        this.spacing := spacing
        this.columns := columns
        this.rows := rows

        ; eventListener := Tiler.WindowsUpdater()
    }


    winMoved(handle) {
        ; print "Updating on winMoved event for " handle " " WinGetClass(handle)
       
        
        try {
            process := WinGetProcessName(handle)
            ; print "`t WinMove : " process " " WinGetTitle("ahk_id " handle)
            print "Updating WIN MOVE :  '" process "'  " WinGetTitle("ahk_id " handle)
            this.update()
            print "updateActiveWindow  WIN MOVE"
            this.updateActiveWindow()
          
        } catch as e {
            print "Updating WIN MOVE : process not found "
        }   

       
        ; if (this.handles.Has(handle)) {
        ;     this.updateActiveWindow()
        ; }
    }

    debugApps := true 

    update() {

        ; if (this.updatingDisabled)
        ;     return

        ; print "Updating... ()"

        MonitorGetWorkArea(1, &wl, &wt, &wr, &wb)

        ; Compute tiles globabl properties from current screen
        originX := 0 + wl
        originY := 0 + wt

        areaWidth := (wr - wl)
        areaWHeight := (wb - wt)

        this.cellWidth := (areaWidth - ((this.columns + 1) * this.spacing)) // this.columns
        this.cellHeight := (areaWHeight - ((this.rows + 1) * this.spacing)) // this.rows

        ; Compute declared areas properties
        ; print "Computing areas ..."
        this.areas := Map()

        for name, area in namedAreas {

            ; print "Building " name " " area

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

            if (name == "F") {
                w := areaWidth - (2 * spacing)
            }

            newArea := Tiler.Area(name, area, startCell, stopCell, startCol, startRow, stopCol, stopRow, x, y, w, h)

            ; print "`tAdding " area " as " newArea.toString()

            this.areas[area] := newArea

            ; print "`tAdded " area " : "  this.areas[area].name " " this.areas[area].area
            ; print "pouet " this.areas[area].name
        }

        ; print this.areas.Count " areas found"

        if (this.debugApps)
            print "--------- Searching for apps ---------

        winHandles := WinGetList(, ,)

        ; Build current windows map for current screen
        this.handles := Map()

        for handle in winHandles
        {

            class := WinGetClass(handle)

            ; ignore some system classes
            if (class ~= "Progman|WorkerW|Shell_TrayWnd|NarratorHelperWindow|Button|PseudoConsoleWindow") {
                if (this.debugApps)
                print handle " ignored (System)"
                continue
            }

            try
                process := WinGetProcessName(handle)
            catch as e {
                if (this.debugApps)
                print handle " ignored (No Process)"
                continue
            }

            ; get window state Min/Max
            state := WinGetMinMax(handle)

            title := WinGetTitle(handle)

            if (state == 0) {

                ; get position
                this.WinGetPosEx &x, &y, &width, &height, handle

                if (w == 0 and h == 0) {
                    if (this.debugApps)
                    print handle " ignored (size 0)"
                    continue
                }

                ; guess area
                startCol := Round(x / this.cellWidth) + 1
                startRow := Round(y / this.cellHeight) + 1

                stopCol := startCol + Round(width / this.cellWidth) - 1
                stopRow := startRow + Round(height / this.cellHeight) - 1

                startZone := startCol + ((startRow - 1) * this.columns)
                stopZone := stopCol + ((stopRow - 1) * this.columns)

                if (startZone < 1 or startZone > this.columns * this.rows or stopZone < 1 or stopZone > this.columns * this.rows) {
                    if (this.debugApps)
                    print "[" handle "] ignored (bad zones) " startZone " " stopZone
                    continue
                }

                areaId := startZone * 10 + stopZone ; will fail ? if more than 10 columns

                if (this.areas.Has(areaId)) {
                    area := this.areas[areaId]
                    ; desc := "[" handle "] '" class " " area.name " " area.area " " startCol "," startRow " " stopCol "," stopRow " " startZone " " stopZone " " areaId "' `t" process " " title
                    ; print desc
                    tile := Tiler.Tile(handle, process, area, class, state, this)
                    this.handles[handle] := tile
                } else {
                    if (this.debugApps)
                    print "[" handle "] ignored (unknown or not registered area)"
                }

            } if (state == 1) {
                ; print "[" handle "] Maximized"
                area := this.areas[F]
                tile := Tiler.Tile(handle, process, area, class, state, this)
                this.handles[handle] := tile
            } else if (state == -1) {
                ; print "[" handle "] Minimized"
                continue

            }

            
        }

        ; print this.handles.Count " apps found"

        ; for id, handle in this.handles
        ;     print handle.toString()
    }

    snapTo(areaId, handle := WinGetId("A")) {
        tile := this.handles[handle]
        area := this.areas[areaId]
        tile.snapTo(area)
    }

    modLeft(handle := WinGetId("A")) {
        tile := this.handles[handle]

        switch tile.area.area {
            ; expand
            case C: this.snapTo(L3, handle)
            case RS: this.snapTo(C, handle)
                ; unexpand
            case R3: this.snapTo(C, handle)
                ; glue and unexpand
            case L3:
                ; print "------------- GLUE EXPAND ------------------"
                ; this.updatingDisabled := true
                ; tilesToExpand := this.tilesRightOf(tile)
        

                ; WinSetTransparent 0, tile.handle
                ; for h, tileOnRight in tilesToExpand  {
                ;     WinSetTransparent 0,h
                ; }

                ; for h, tileOnRight in tilesToExpand {
                ;     expandedArea := this.growLeft(tileOnRight.area)
                ;     this.snapTo(expandedArea.area, h)
                ;     WinMoveTop(h)
                ; }

                this.snapTo(LS, handle)

                ; WinSetTransparent 255,tile.handle
                ; for h, tileOnRight in tilesToExpand 
                ;     WinSetTransparent 255,h 

                ; this.updatingDisabled := false
                ; print "------------- GLUE EXPAND ------------------"
                ; swap
            case LS: this.snapTo(RS, handle)
        }
    }


    tilesRightOf(tile) {

        tilesOnTheRight := Map()

        for handle, candidate in this.handles {

            if (candidate.area.startCol > tile.area.stopCol) {
                tilesOnTheRight[handle] := candidate
            }
        }

        return tilesOnTheRight
    }

    growLeft(area) {
        ; print "grow left " area.name " " area.area

        switch area.area {
            case R: next := RS
            case TRC: next := TR
            case BRC: next := BR
            default: next := -1
        }
        ; print "grow left ->  " next
        nextArea := this.areas[next]
        return nextArea
    }


    ; growRight(area) {
    ;     ; print "grow left " area.name " " area.area

    ;     switch area.area {
    ;         case R: next := RS
    ;         case TRC: next := TR
    ;         case BRC: next := BR
    ;         default: next := -1
    ;     }
    ;     ; print "grow left ->  " next
    ;     nextArea := this.areas[next]
    ;     return nextArea
    ; }

    modRight(handle := WinGetId("A")) {
        tile := this.handles[handle]

        switch tile.area.area {
            ; expand
            case C: this.snapTo(R3, handle)
            case R3: this.snapTo(RS, handle)
            case LS: this.snapTo(L3, handle)
                ; unexpand
            case L3: this.snapTo(C, handle)
                ; swap
            case RS: this.snapTo(LS, handle)
        }
    }


    tilesAtPos(area) {
        tilesAtPos := Map()

        for handle, tile in this.handles {

            if (tile.area.area == area) {
                tilesAtPos[handle] := tile
            }
        }

        return tilesAtPos
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

        __New(handle, process, area, class, state, tiler) {
            this.handle := handle
            this.process := process
            this.area := area
            this.class := class
            this.state := state
            this.tiler := tiler
        }

        clearBorder() {
            DrawBorder(this.handle, , 0)
        }

        isActive() {
            ; active := WinActive(this.id)
            current := WinGetId("A")
            isActive := WinActive(this.handle)
            ; print "current " current " id " this.handle " isActive " isActive
            return true
        }

        getSiblingsOnArea() {
            siblings := Map()

            for handle, tile in this.tiler.handles {
                if (handle != this.handle and tile.area == this.area) {
                    siblings[handle] := tile
                    ; print "On same area " tile.toString()
                }
            }

            return siblings
        }

        hasSiblingsOnArea() {
            return this.getSiblingsOnArea().Count > 0
        }

        drawBorder() {

            if (this.hasSiblingsOnArea()) {
                ; border_color := "0xFFE62D" ; yellow
                ; border_color := "0x6238FF" ; violet
                border_color := "0xf9cbe5" ; pink
            } else {
                border_color := "0x7ce38b" ; green
            }
            DrawBorder(this.handle, border_color, 1)

        }

        snapTo(area) {

            ; switch to next mod if available : same shortcut with another mod key on double press
            if (area == this.area) {
                area := this.altArea(this.area)
            } else {
                ; do nothing
            }


            WinMoveEx area.x, area.y, area.w, area.h, this.handle

            ; ; moving should update tiless

            ; this.tiler.update()


        }

        altArea(area) {
            switch area.area {
                case BLC: next := BL
                case CB: next := B
                case BRC: next := BR
                case L: next := LS
                case C: next := F
                case R: next := RS
                case TLC: next := TL
                case CT: next := T
                case TRC: next := TR
                case BLC: next := BL
            }
            nextArea := this.tiler.areas[next]
            return nextArea
        }

        toString() {
            return this.area.name "`t" this.area.area " `t" this.process " [" this.handle "]"
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