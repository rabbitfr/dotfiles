print "Loading constants.ahk`n"


HSHELL_WINDOWCREATED := 1
HSHELL_WINDOWDESTROYED := 2
HSHELL_ACTIVATESHELLWINDOW := 3
HSHELL_WINDOWACTIVATED := 4
HSHELL_GETMINRECT := 5
HSHELL_REDRAW := 6
HSHELL_TASKMAN := 7
HSHELL_LANGUAGE := 8
HSHELL_SYSMENU := 9
HSHELL_ENDTASK := 10
HSHELL_ACCESSIBILITYSTATE := 11
HSHELL_APPCOMMAND := 12
HSHELL_WINDOWREPLACED := 13
HSHELL_WINDOWREPLACING := 14
HSHELL_HIGHBIT := 15
HSHELL_FLASH := 16
HSHELL_RUDEAPPACTIVATED := 17
HSHELL_RUDEAPPACTIVATED_BIS := 32772


; 1...
; 5...
global L := 15
; ...4
; ...8
global R := 48
; .23.
; .67.
global C := 27
; 1234
; 5678
global F := 18
; 1234
; 5678
global LS := 16
; 12..
; 56..
global RS := 38
; ..34
; ..78
global L3 := 17
; 123.
; 567.
global R3 := 28
; 1234
; 5678
global T := 14
; 1234
; ....
global B := 58
; ....
; 5678
global CT := 23
; .23.
; ....
global CB := 67
; ....
; .67.
global TL := 12
; 12..
; ....
global TR := 34
; ..34
; ....
global BL := 56
; ....
; 56..
global BR := 78
; ....
; ..78
global TLC := 11
; 1...
; ....
global TRC := 44
; ...4
; ....
global BLC := 55
; ....
; 5...
global BRC := 88
; ....
; ...8
global CTLC := 22
; 1...
; ....
global CTRC := 33
; ...4
; ....
global CBLC := 66
; ....
; 5...
global CBRC := 77
; ....
; ...8
; global FLOATING := -1
; ....
; ...8

global namedAreas := Map()
namedAreas["L"] := L
namedAreas["R"] := R
namedAreas["C"] := C
namedAreas["F"] := F
namedAreas["LS"] := LS
namedAreas["RS"] := RS
namedAreas["L3"] := L3
namedAreas["R3"] := R3
namedAreas["T"] := T
namedAreas["B"] := B
namedAreas["CT"] := CT
namedAreas["CB"] := CB
namedAreas["TL"] := TL
namedAreas["TR"] := TR
namedAreas["BL"] := BL
namedAreas["BR"] := BR
namedAreas["TLC"] := TLC
namedAreas["TRC"] := TRC
namedAreas["BLC"] := BLC
namedAreas["BRC"] := BRC
namedAreas["CTLC"] := CTLC
namedAreas["CTRC"] := CTRC
namedAreas["CBLC"] := CBLC
namedAreas["CBRC"] := CBRC
; namedAreas["Floating"] := FLOATING

global areasToName := Map()
for key, value in namedAreas {
    areasToName["" value] :=  key
    ; print value " " areasToName["" value]
}