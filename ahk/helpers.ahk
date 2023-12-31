print "Loading helpers.ahk"
;
; Log helpers
;
print(message) {
    try {
        FileAppend message "`n", "*"
    } catch {

    }
}

info(message) {
    if (logLevel == "INFO")
        print message
}


debug(message) {
    if (logLevel == "DEBUG")
        print message
}

;
; Loop helpers
;


range(start, stop) {
    range := []
    loops := stop - start + 1
    loop loops {
        range.Push(start + A_Index - 1)
    }
    return range
}


;
; Map helpers
;

put(map, key, value) {
    values := map.Get(key, [])
    values.Push(value)
    map.Set(key, values)
}

;
