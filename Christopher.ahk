#Requires AutoHotkey v2.0

; Ctrl + Alt + S - Send lines with Enter
^!s:: {
    Loop Parse A_Clipboard, "`n", "`r" A_Space {
        SendText A_LoopField
        Sleep 200
        Send "{Enter}"
    }
}

; Ctrl + Shift + Alt + S - Send lines with Down arrow
^+!s:: {
    Loop Parse A_Clipboard, "`n", "`r" A_Space {
        SendText A_LoopField
        Sleep 1000
        Send "{Down}"
        Sleep 1000
    }
}

