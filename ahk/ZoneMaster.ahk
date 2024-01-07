#Requires AutoHotkey v2.0
#SingleInstance Force
#WinActivateForce ; send 32772
Persistent ; This script will not exit automatically, even though it has nothing to do.

#Include constants2.ahk
#Include helpers.ahk
#Include Tiler2.ahk
#Include shortcuts.ahk
; #ErrorStdOut

ListLines 0
SendMode "Input"
SetWorkingDir A_ScriptDir
KeyHistory 0
DetectHiddenWindows false
SetWinDelay(1)

global tiler := Tiler2()


; TODO move elsewhere
HookShellEvents

HookShellEvents() {
    global
    lastEventId := -1
    lastEventHandle := -1
    hiddenEventReceiver := Gui()
    hiddenEventReceiver.Opt("+LastFound")
    receiver := WinExist()
    DllCall("RegisterShellHookWindow", "UInt", receiver)
    MsgNum := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
    OnMessage(MsgNum, onEvent)
}

onEvent(eventId, eventHandle, msg, ignore) {

    ; print "Event " eventId "  p " eventHandle ; " " msg " " handle


    if (eventId != lastEventId or eventHandle != lastEventHandle) {
        ; do nothing
        global lastEventId := eventId
        global lastEventHandle := eventHandle
    } else {
        ; print "Skip event"
        return ; ignore
    }

    switch eventId {

        case HSHELL_ACTIVATESHELLWINDOW:
        case HSHELL_GETMINRECT:
        case HSHELL_REDRAW: ; 6
        case HSHELL_TASKMAN:
        case HSHELL_LANGUAGE:
        case HSHELL_SYSMENU:
        case HSHELL_ENDTASK:
        case HSHELL_ACCESSIBILITYSTATE:
        case HSHELL_APPCOMMAND:
        case HSHELL_WINDOWREPLACED:
        case HSHELL_WINDOWREPLACING:
        case HSHELL_HIGHBIT:
        case HSHELL_FLASH: ; 16
        case HSHELL_WINDOWCREATED: ; 1
            print "> WIN CREATED " eventHandle
            tiler.update()
            ; tiler.onNewWindow(eventHandle)
        case HSHELL_WINDOWDESTROYED: ; 2
            print "> WIN DESTROYED " eventHandle
            tiler.update()
        case HSHELL_WINDOWACTIVATED,
            HSHELL_RUDEAPPACTIVATED,
            HSHELL_RUDEAPPACTIVATED_BIS: ; 32772
            print "> WIN RUDEAPPACTIVATED, " eventHandle
            tiler.update()
            ; print "updateActiveWindow WIN RUDEAPPACTIVATED"55
            ; wm.updateActiveWindow()
    }
}

ExcludeScriptMessages := "1"	; 0 to include

HookWinEvent()

HookWinEvent() {
    global
    HookProcAdr := CallbackCreate(CaptureWinEvent, "F")
    dwFlags := (0x0000 | 0x0002 | 0x0001)
    hWinEventHook := SetWinEventHook(0x800B, 0x800B, 0, HookProcAdr, 0, 0, dwFlags)
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) {
    DllCall("ole32\CoInitialize", "Uint", 0)
    return DllCall("SetWinEventHook", "Uint", eventMin, "Uint", eventMax, "Uint", hmodWinEventProc, "Uint", lpfnWinEventProc, "Uint", idProcess, "Uint", idThread, "Uint", dwFlags)
}
global lastMovedEventHandle := -1


CaptureWinEvent(hWinEventHook, Event, hWnd, idObject, idChild, dwEventThread, dwmsEventTime) {
    ; Global PauseStatus := -1 , WM_VSCROLL := -1  , SB_BOTTOM := -1 , ogLV_WMessages:= -1 , winMessageList:= -1

    if (hWnd == 0)
        return

    if (Event != 32779)
        return

    ; global lastMovedEventHandle
    ;
    ; If WinExist("ahk_id " hWnd) {
    ; if (lastMovedEventHandle != hWnd) {

    ; if ( tiler.tiles.Has(hWnd) ) {5

    if (WinExist(hWnd)) {
        if (WinGetClass(hWnd) != "AltSnap") {
            ; print "> WIN MOVED, " hWnd " " WinGetTitle(hWnd) " " WinGetClass(hWnd)
            ; print WinGetTitle(hWnd)

            tiler.update()
        }
    }

    ; lastMovedEventHandle := hWnd

    ; } else {
    ;     print "no tile " hWnd
    ; }

    ; }

    ; } else {0
    ; return
    ; }

    ; Event += 0
    ; message := ""


    ; if (Event = 1)
    ;     Message := "EVENT_SYSTEM_SOUND"
    ; else if (Event = 2)
    ;     Message := "EVENT_SYSTEM_ALERT"
    ; else if (Event = 3)
    ;     Message := "EVENT_SYSTEM_FOREGROUND"
    ; else if (Event = 4)•4
    ;     Message := "EVENT_SYSTEM_MENUSTART"
    ; else if (Event = 5)
    ;     Message := "EVENT_SYSTEM_MENUEND"
    ; else if (Event = 6)
    ;     Message := "EVENT_SYSTEM_MENUPOPUPSTART"
    ; else if (Event = 7)
    ;     Message := "EVENT_SYSTEM_MENUPOPUPEND"
    ; else if (Event = 8)
    ;     Message := "EVENT_SYSTEM_CAPTURESTART"
    ; else if (Event = 9)
    ;     Message := "EVENT_SYSTEM_CAPTUREEND"
    ; else if (Event = 10)
    ;     Message := "EVENT_SYSTEM_MOVESIZESTART"
    ; else if (Event = 11)
    ;     Message := "EVENT_SYSTEM_MOVESIZEEND"♣
    ; else if (Event = 12)
    ;     Message := "EVENT_SYSTEM_CONTEXTHELPSTART"
    ; else if (Event = 13)
    ;     Message := "EVENT_SYSTEM_CONTEXTHELPEND"
    ; else if (Event = 14)
    ;     Message := "EVENT_SYSTEM_DRAGDROPSTART"
    ; else if (Event = 15)
    ;     Message := "EVENT_SYSTEM_DRAGDROPEND"
    ; else if (Event = 16)
    ;     Message := "EVENT_SYSTEM_DIALOGSTART"
    ; else if (Event = 17)
    ;     Message := "EVENT_SYSTEM_DIALOGEND"
    ; else if (Event = 18)
    ;     Message := "EVENT_SYSTEM_SCROLLINGSTART"
    ; else if (Event = 19)
    ;     Message := "EVENT_SYSTEM_SCROLLINGEND"
    ; else if (Event = 20)
    ;     Message := "EVENT_SYSTEM_SWITCHSTART"
    ; else if (Event = 21)
    ;     Message := "EVENT_SYSTEM_SWITCHEND"
    ; else if (Event = 22)
    ;     Message := "EVENT_SYSTEM_MINIMIZESTART"
    ; else if (Event = 23)
    ;     Message := "EVENT_SYSTEM_MINIMIZEEND"
    ; else if (Event = 32779)
    ;     Message := "EVENT_OBJECT_LOCATIONCHANGE"

    ; ; print "Event " Event " Message " Message " hWnd " hWnd " idObject " idObject " idChild " idChild " dwEventThread " dwEventThread " dwmsEventTime " dwmsEventTime

    ; Sleep(0)
    ; EventHex := Event

    ; if(message!=""){
    ;     try{
    ;         if (myGui.filterMsg.Has(message) and myGui.filterMsg[message]=1){
    ;             return
    ;         }
    ;         	; give a little time for WinGetTitle/WinGetActiveTitle functions, otherwise they return blank
    ;         WinhWnd := WinGetTitle(hWnd) = "" ? DllCall("user32\GetAncestor", "Ptr", hWnd, "UInt", 1, "Ptr") : hWnd
    ;         phWnd := WinGetPID(WinhWnd)
    ;         if (myGui.ExcludeOwnMessages and myGui.phwnd+0=phWnd){
    ;             return
    ;         }
    ;         WinClass := WinGetClass(hWnd)
    ;         ogLV_WMessages.Add("", format("0x{:x}",hWnd), format("0x{:x}",idObject), format("0x{:x}",idChild), WinGetTitle(hWnd), WinClass, format("0x{:x}",EventHex), Message,WinGetProcessName(hWnd),format("0x{:x}", phWnd),WinGetTitle(WinhWnd))

    ;         if (!WinActive(myGui)){
    ;             SendMessage(WM_VSCROLL, SB_BOTTOM, 0, "SysListView321", "ahk_id " myGui.Hwnd)
    ;         }
    ;     }
    ; }
}