#Requires AutoHotkey v2.0

;ctrl+shft+alt+g
^+!g:: {
    Send "^c" ; Copy the highlighted text
    if WinExist("ahk_exe chrome.exe") {
        ; If Chrome is running, activate the window and open a new tab
        WinActivate "ahk_exe chrome.exe"
        WinWaitActive "ahk_exe chrome.exe"
        PerformSearch()
    } else if WinExist("ahk_exe msedge.exe") {
        ; If Edge is running, activate the window and open a new tab
        WinActivate "ahk_exe msedge.exe"
        WinWaitActive "ahk_exe msedge.exe"
        PerformSearch()
    } else {
        ; If neither Chrome nor Edge is running, try to open Chrome first, then Edge if Chrome fails
        if FileExist("C:\Program Files\Google\Chrome\Application\chrome.exe") {
            Run "chrome.exe"
            WinWaitActive "ahk_exe chrome.exe"
            PerformSearch()
        } else if FileExist("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe") {
            Run "msedge.exe"
            WinWaitActive "ahk_exe msedge.exe"
            PerformSearch()
        } else {
            MsgBox "Neither Chrome nor Edge could be found. Please install one of these browsers."
        }
    }
}

PerformSearch() {
    Send "^t"
    Sleep 500
    Send "https://google.com{Enter}"
    Sleep 1000
    Send "^v{Enter}"
}