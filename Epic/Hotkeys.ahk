#Requires AutoHotkey v2.0

;ctrl+alt+w
^!w:: Run "C:\Users\psiegel\OneDrive - Epic\Documents\AutoHotkey\Autohotkey\Epic\WikiShortcuts.ahk"

;ctl+alt+M
^!m:: Run "C:\MeetCute\meetcute"

;ctl+alt+.
^!.:: Run "C:\Users\psiegel\OneDrive - Epic\Documents\AutoHotkey\Autohotkey\Epic\MyAutoHotkeyFolder.ahk"

;win+alt+ctrl+C
#^!c:: Run "\\epic.com\files\Training\Internal\New Hire\Role-based Training\IS\IS Onboarding\Application Deep Dives\DRAFT Class PPTs\Willow IP\2025 Advanced Application Topics #2 - Charging.pptx"

;win+alt+ctrl+I
#^!I:: Run "\\epic.com\files\Training\Internal\New Hire\Role-based Training\IS\IS Onboarding\Application Deep Dives\DRAFT Class PPTs\Willow IP\Archive\Advanced Application Topics #2 - Charging - pre 2025.pptx"

;alt+ctrl+u
!^u::send "psiegel@epic.com"

;Ctrl+End
^End::Home

;Ctrl+Del
^Del::Ins

;ctrl+shft+alt+E - UMC Generic Epic User Password
^+!E::send "UMCepicepic{!}"

; alt+ctl+l - Lunchy
!^l:: Run "https://epic1.sharepoint.com/sites/culinary/SitePages/Menu%20Dashboard.aspx"

;Hotstrings
:o:.nprd::/epic/nonprdfiles/stage/Willow/psiegel/
:o:.prd::/epic/prdfiles/stage/Willow/psiegel/
:o:.nfs::/nfs/3day/
::teh::the
::recieve::receive
::seperate::separate
::definately::definitely
::defualt::default

; ========================================
; EMOTICONS & KAOMOJI
; ========================================
:o:.shrug::{U+00AF}\_({u+30c4})_/{U+00AF}
:o:.tbl::(╯°□°)╯︵ ┻━┻
:o:.puttableback::┬─┬ノ( º _ ºノ)
:o:.lenny::( ͡° ͜ʖ ͡°)
:o:.disapprove::ಠ_ಠ
:o:.happy::ヽ({^}▽{^})/
:o:.sparkle::(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧
:o:.dead::x_x
:o:.cute::(｡◕‿◕｡)
:o:.bear::ʕ•ᴥ•ʔ
:o:.music::♪┏(･o･)┛♪
:o:.excited::\(^o^)/
:o:.thinking::(¬‿¬)
:o:.love::(♥‿♥)
:o:.dealwithit::(⌐■_■)

; ========================================
; USEFUL UNICODE SYMBOLS
; ========================================

:o:.check::✓
:o:.x::✗
:o:.arrow::→
:o:.arrowleft::←
:o:.arrowup::↑
:o:.arrowdown::↓
:o:.star::★
:o:.staropen::☆
:o:.heart::♥
:o:.bullet::•
:o:.dot::·
:o:.tm::™
:o:.copyright::©
:o:.registered::®
:o:.deg::°
:o:.pm::±
:o:.infinity::∞
:o:.checkmark::✅
:o:.warnicon::⚠️
:o:.infoicon::ℹ️

;DateHotstrings
:o:.date:: {
    Send(FormatTime(, "yyyy-MM-dd"))  ; ISO format: 2025-11-18
}

:o:.time:: {
    Send(FormatTime(, "HH:mm"))  ; 24-hour time
}

:o:.ts:: {
    Send(FormatTime(, "yyyy-MM-dd HH:mm:ss"))  ; Full timestamp
}

:o:.longdate:: {
    Send(FormatTime(, "MMMM d, yyyy"))  ; November 18, 2025
}

:o:.ftp:: {
    ShowPathGUI()
}

ShowPathGUI() {
    ; Create the GUI
    pathGUI := Gui("+AlwaysOnTop", "Select Environment")
    pathGUI.SetFont("s12")
    
    ; Add instruction text
    pathGUI.Add("Text", "w300 Center", "Select Environment:")
    
    ; Add buttons with keyboard shortcuts (3 buttons in a row)
    pathGUI.Add("Button", "w95 h40 Default", "&Production (P)").OnEvent("Click", (*) => SelectPath("prd", pathGUI))
    pathGUI.Add("Button", "w95 h40 x+5", "&NonProd (N)").OnEvent("Click", (*) => SelectPath("nonprd", pathGUI))
    pathGUI.Add("Button", "w95 h40 x+5", "&Internal (I)").OnEvent("Click", (*) => SelectPath("nfs", pathGUI))
    
    ; Add cancel button
    pathGUI.Add("Button", "w300 h30 xm", "Cancel (Esc)").OnEvent("Click", (*) => pathGUI.Destroy())
    
    ; Handle keyboard shortcuts
    pathGUI.OnEvent("Escape", (*) => pathGUI.Destroy())
    
    ; Show the GUI centered
    pathGUI.Show()
}

SelectPath(env, guiObj) {
    ; Close the GUI first
    guiObj.Destroy()
    
    ; Send the appropriate path
    if env = "prd"
        Send("/epic/prdfiles/stage/Willow/psiegel/")
    else if env = "nonprd"
        Send("/epic/nonprdfiles/stage/Willow/psiegel/")
    else if env = "nfs"
        Send("/nfs/3day/")
}
