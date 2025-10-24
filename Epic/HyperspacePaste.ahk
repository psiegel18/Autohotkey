#Requires AutoHotkey v2.0

; Global variable to control loop execution
global StopLoop := false

; Ctrl + Escape - Kill switch to stop any running loops
^Escape:: {
    global StopLoop := true
    ToolTip "Loop stopped by kill switch!", 100, 100
    SetTimer () => ToolTip(), -2000  ; Hide tooltip after 2 seconds
}

; Ctrl + Alt + S - Send lines with Enter
^!s:: {
    global StopLoop := false  ; Reset the kill switch
    ToolTip "Starting loop... Press Ctrl+Escape to stop", 100, 100
    SetTimer () => ToolTip(), -1000  ; Hide tooltip after 1 second
    
    Loop Parse A_Clipboard, "`n", "`r" A_Space {
        if (StopLoop) {
            ToolTip "Loop terminated by kill switch", 100, 100
            SetTimer () => ToolTip(), -2000
            break
        }
        SendText A_LoopField
        Sleep 200
        Send "{Enter}"
    }
}

; Ctrl + Shift + Alt + S - Send lines with Down arrow (Fixed version)
^+!s:: {
    global StopLoop := false  ; Reset the kill switch
    ToolTip "Starting loop... Press Ctrl+Escape to stop", 100, 100
    SetTimer () => ToolTip(), -1000  ; Hide tooltip after 1 second
    
    Loop Parse A_Clipboard, "`n", "`r" A_Space {
        if (StopLoop) {
            ToolTip "Loop terminated by kill switch", 100, 100
            SetTimer () => ToolTip(), -2000
            break
        }
        ; Use SendText to send the text (already raw in v2.0)
        SendText A_LoopField
        Sleep 500  ; Longer pause to let any auto-complete settle
        ; Send Escape first to clear any auto-complete suggestions
        Send "{Escape}"
        Sleep 100
        Send "{Down}"
        Sleep 1000
    }
}