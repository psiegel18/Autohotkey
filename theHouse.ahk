#Requires Autohotkey v2.0

;win+alt+h
#!h:: {
    if WinExist("ahk_exe msedge.exe") {
        WinActivate "ahk_exe msedge.exe"
        WinWaitActive "ahk_exe msedge.exe"
        theHouse()
    } else if WinExist("ahk_exe chrome.exe") {
        WinActivate "ahk_exe chrome.exe"
        WinWaitActive "ahk_exe chrome.exe"
        theHouse()
    } else {
        if FileExist("C:\Program files (x86)\Microsoft\Edge\Application\msedge.exe") {
            Run "msedge.exe"
            WinWait "ahk_exe msedge.exe"
            WinActivate "ahk_exe msedge.exe"
            theHouse()
        } else if FileExist("C:\Program Files\Google\Chrome\Application\chrome.exe") {
            Run "chrome.exe"
            WinWait "ahk_exe chrome.exe"
            WinActivate "ahk_exe chrome.exe"
            theHouse()
        } else {
            MsgBox "Neither Edge nor Chrome could be found. Please install one of these browsers."
        }
    }
}

theHouse() {
    Run "slack:"
    Run "code"
    Run "https://vercel.com/the-house/user_database/deployments"
    Run "https://cloud.mongodb.com/v2/668caa771b77a8026cbe8ac1#/overview"
    Run "C:\Users\prest\OneDrive\Desktop\Claude.lnk"
    Run "https://outlook.office.com/mail/"
}