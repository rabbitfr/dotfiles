

#Enter::Run("wt.exe")
#d::Send("^{Space}")
#w::Send("!{F4}")

;
; Direct move & resize shortcuts
;

; vim like 
#u:: {
    ; if (A_PriorHotkey == "#u" and A_TimeSincePriorHotkey < 300) {
    ;     print "x2`n"
    ;     tiler.snap(TL) ;
    ; } else {
        tiler.snap(TLC) ;
    ; }
}    
#i:: tiler.snap(CT) ;
#o:: tiler.snap(TRC) 

#j:: tiler.snap(LS) 
#k:: tiler.snap(C) 
#l:: tiler.snap(RS) ;

#m:: tiler.snap(BLC) ;
#,:: tiler.snap(CB) ; 
#.:: tiler.snap(BRC)

; same but on keypad 
#numpad7:: tiler.snap(TLC) ;
#numpad8:: tiler.snap(CT) ;
#numpad9:: tiler.snap(TRC) 

#numpad4:: tiler.snap(LS) 
#numpad5:: tiler.snap(C) 
#numpad6:: tiler.snap(RS) ;

#numpad1:: tiler.snap(BLC) ;
#numpad2:: tiler.snap(CB) ; 
#numpad3:: tiler.snap(BRC) 
    
;
; Enlarge, Contract base on current state
;

#Left:: tiler.modLeft()
#Right:: tiler.modRight()

;
#z:: tiler.undo()
#+z:: tiler.redo()

; #F2:: {
;     best := z.findMatches()

;     if ( best.Length == 1) {
;         print "Found unique match"
;     } else if ( best.Length > 1) {
;         print "Found more than one match"
;     } else if ( best.Length <= 0) {
;         print "No match found"
;     }
; }


#F11:: {
    z := Zones()

    print "------------------------------------------`n"
    ; test := z.findByShape(2,2)
    test := z.findBySize(1)
    
    index := 1

    for t in test {
        print "Zone" index -1  "=" t.x "," t.y "," t.x + t.w "," t.y + t.h ",`n"
        index++
    }

    test2 := []
    test2.Push(z.findByCode(C))
    test2.Push(z.findByCode(LS))
    test2.Push(z.findByCode(RS))
    test2.Push(z.findByCode(L3))
    test2.Push(z.findByCode(R3))

    for t in test2 {
        print "Zone" index -1  "=" t.x "," t.y "," t.x + t.w "," t.y + t.h ",`n"
        index++
    }

    print "------------------------------------------`n"
    z.debugZones(test)
}


; #F10:: {
;     z := Zones()

;     debugGui := Gui(, "zone_1")
;     debugGuiHandle := debugGui.Hwnd
;     debugGui.Show()
;     ; WinMoveEx 4, 42, 1271 + 16, 1000 - 8, debugGuiHandle
;     WinMove 4, 42, 1271 - 16 + 6, 1000 - 16 + 6, debugGuiHandle
;     ; WinGetPosEx(&x,&y,&w,&h,debugGuiHandle)
;     ; print zone.toString() "`n"
;     ; print "real x " x " y " y " w " w " h" h


;     debugGui2 := Gui(, "zone_2")
;     debugGuiHandle2 := debugGui2.Hwnd
;     debugGui2.Show()
;     ; WinMoveEx 1285, 42, 1271 + 16, 1000 -8 ,debugGuiHandle2
;     WinMove 1285, 42, 1271 - 16, 1000 - 16 + 6, debugGuiHandle2
;     ; WinGetPosEx(&x,&y,&w,&h,debugGuiHandle2)
;     ; print zone.toString() "`n"
;     ; print "real x " x " y " y " w " w " h" h


; }