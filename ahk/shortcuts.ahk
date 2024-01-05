

#u:: tiler.snap(TLC) ;
#i:: tiler.snap(CT) ;
#o:: tiler.snap(TRC) 

#j:: tiler.snap(LS) 
#k:: tiler.snap(C) 
#l:: tiler.snap(RS) ;

#m:: tiler.snap(BLC) ;
#,:: tiler.snap(CB) ; 
#.:: tiler.snap(BRC)


#numpad7:: tiler.snap(TLC) ;
#numpad8:: tiler.snap(CT) ;
#numpad9:: tiler.snap(TRC) 

#numpad4:: tiler.snap(LS) 
#numpad5:: tiler.snap(C) 
#numpad6:: tiler.snap(RS) ;

#numpad1:: tiler.snap(BLC) ;
#numpad2:: tiler.snap(CB) ; 
#numpad3:: tiler.snap(BRC)

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

    for t in test
        print t.toString() "`n"
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