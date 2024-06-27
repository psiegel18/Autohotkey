#Requires AutoHotkey v2.0
SetTitleMatchMode 2  ; Makes window detection more flexible

;ctrl+shft+alt+g
^+!g:: {
    A_Clipboard := ""  ; Clear the clipboard
    Send "^c"  ; Copy the highlighted text
    if !ClipWait(2) {  ; Wait for the clipboard to contain data
        MsgBox "No text selected. Please select some text and try again."
        return
    }

    if WinExist("ahk_exe chrome.exe") {
        WinActivate "ahk_exe chrome.exe"
        WinWaitActive "ahk_exe chrome.exe"
        PerformSearch()
    } else if WinExist("ahk_exe msedge.exe") {
        WinActivate "ahk_exe msedge.exe"
        WinWaitActive "ahk_exe msedge.exe"
        PerformSearch()
    } else {
        if FileExist("C:\Program Files\Google\Chrome\Application\chrome.exe") {
            Run "chrome.exe"
            WinWait "ahk_exe chrome.exe"
            WinActivate "ahk_exe chrome.exe"
            PerformSearch()
        } else if FileExist("C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe") {
            Run "msedge.exe"
            WinWait "ahk_exe msedge.exe"
            WinActivate "ahk_exe msedge.exe"
            PerformSearch()
        } else {
            MsgBox "Neither Chrome nor Edge could be found. Please install one of these browsers."
        }
    }
}

PerformSearch() {
    searchTerm := UrlEncode(A_Clipboard)
    Run "https://www.google.com/search?q=" . searchTerm
}

UrlEncode(str) {
    return StrReplace(StrReplace(str, "&", "%26"), " ", "+")
}