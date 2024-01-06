print "Loading constants2.ahk`n"


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
global L := 113
; ...4
; ...8
global R := 416
; .23.
; .67.
global C := 215
; global CE := 270
; 1234
; 5678
global ALMOST_FULLSCREEN := 116
; 1234
; 5678
global LS := 114
; 12..
; 56..
global RS := 316
; ..34
; ..78
global L3 := 1150
; 123.
; 567.
global R3 := 216
; 1234
; 5678
global T := 18
; 1234
; ....
global B := 916
; ....
; 5678
global CT := 27
; .23.
; ....
global CB := 1015
; ....
; .67.
global TL := 16
; 12..
; ....
global TR := 38
; ..34
; ....
global BL := 914
; ....
; 56..
global BR := 1116
; ....
; ..78
global TLC := 15
; 1...
; ....
global TRC := 48
; ...4
; ....
global BLC := 913
; ....
; 5...
global BRC := 1216
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
global FLOATING := 0
global FULLSCREEN := 9000
global MINIMIZED := -1


global namedZones := Map()
namedZones[L] := "L"
namedZones[R] := "R"
namedZones[C] := "C"
namedZones[ALMOST_FULLSCREEN] := "ALMOST_FULLSCREEN"
namedZones[LS] := "LS"
namedZones[RS] := "RS"
namedZones[L3] := "L3"
namedZones[R3] := "R3"
namedZones[T] := "T"
namedZones[B] := "B"
namedZones[CT] := "CT"
namedZones[CB] := "CB"
namedZones[TL] := "TL"
namedZones[TR] := "TR"
namedZones[BL] := "BL"
namedZones[BR] := "BR"
namedZones[TLC] := "TLC"
namedZones[TRC] := "TRC"
namedZones[BLC] := "BLC"
namedZones[BRC] := "BRC"
namedZones[CTLC] := "CTLC"
namedZones[CTRC] := "CTRC"
namedZones[CBLC] := "CBLC"
namedZones[CBRC] := "CBRC"
namedZones[FLOATING] := "FLOATING"
namedZones[FULLSCREEN] := "FULLSCREEN"
namedZones[MINIMIZED] := "MINIMIZED"