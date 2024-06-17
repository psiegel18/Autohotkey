#Requires AutoHotkey v2.0

^!l:: {
    Send "^c" ; Copy the highlighted text
    if WinExist("ahk_class Chrome_WidgetWin_1") {
        ; If Chrome is running, activate the window and open a new tab
        WinActivate "ahk_class Chrome_WidgetWin_1"
        WinWaitActive "ahk_class Chrome_WidgetWin_1"
        Send "^t"
        Sleep 500
        Send "https://google.com{Enter}"
        Sleep 1000
        Send "^v{Enter}"
    } else {
        ; If Chrome is not running, open it
        Run "chrome.exe"
        WinWaitActive "ahk_class Chrome_WidgetWin_1"
        Sleep 500
        Send "^t"
        Sleep 500
        Send "https://google.com{Enter}"
        Sleep 1000
        Send "^v{Enter}"
    }
}