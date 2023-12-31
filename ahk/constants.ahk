print "Loading constants.ahk"

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

global areasToZones := Map()
areasToZones["L"] := L
areasToZones["R"] := R
areasToZones["C"] := C
areasToZones["F"] := F
areasToZones["LS"] := LS
areasToZones["RS"] := RS
areasToZones["L3"] := L3
areasToZones["R3"] := R3
areasToZones["T"] := T
areasToZones["B"] := B
areasToZones["CT"] := CT
areasToZones["CB"] := CB
areasToZones["TL"] := TL
areasToZones["TR"] := TR
areasToZones["BL"] := BL
areasToZones["BR"] := BR
areasToZones["TLC"] := TLC
areasToZones["TRC"] := TRC
areasToZones["BLC"] := BLC
areasToZones["BRC"] := BRC
areasToZones["CTLC"] := CTLC
areasToZones["CTRC"] := CTRC
areasToZones["CBLC"] := CBLC
areasToZones["CBRC"] := CBRC

global zonesToAreas := Map()

For key, value in areasToZones {
    zonesToAreas["" value] := key
    ; print value " " zonesToAreas["" value]
}
