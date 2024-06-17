#Requires AutoHotkey v2.0

^+l:: {
    Send "^c"
    Run "chrome.exe"
    WinWaitActive "ahk_class Chrome_WidgetWin_1"
    Send "^t"
    Sleep 500
    Send "https://google.com{Enter}"
    Sleep 1000
    Send "^v{Enter}"
}