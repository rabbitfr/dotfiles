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
        case HSHELL_WINDOWDESTROYED: ; 2
            print "> WIN DESTROYED " eventHandle
            tiler.update
        case HSHELL_WINDOWACTIVATED, 
            HSHELL_RUDEAPPACTIVATED,
            HSHELL_RUDEAPPACTIVATED_BIS: ; 32772
            print "> WIN RUDEAPPACTIVATED, " eventHandle
            tiler.update
            ; print "updateActiveWindow WIN RUDEAPPACTIVATED"
            ; wm.updateActiveWindow()
    }
}