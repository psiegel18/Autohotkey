#Requires AutoHotkey v2.0

; Global variables
selectionGui := ""
currentGUIState := "none"  ; "none", "main", "foundation", "sandcastle"
helpTooltipShowing := false

; Function to open URL in default browser
OpenBrowser(url) {
    try {
        Run(url)
    } catch as e {
        MsgBox("Failed to open URL: " . url . "`n`nError: " . e.Message, "Error", "OK IconX")
    }
}

; Function to toggle help tooltip for main menu
ShowMainHelpTooltip() {
    global helpTooltipShowing
    helpTooltip := "Keyboard Shortcuts:`n" .
                   "Shift+F1 - Open Launcher`n" .
                   "Shift+F - Foundation System`n" .
                   "Shift+S - SandCastle`n" .
                   "Shift+M - Microscope`n" .
                   "Shift+E - EMC2`n" .
                   "Shift+C - FS Citrix`n" .
                   "Shift+T - Training Environments`n" .
                   "Shift+← - Back/Close`n" .
                   "F1 - Show Help`n" .
                   "Shift+Esc - Close"
    
    if (!helpTooltipShowing) {
        ToolTip(helpTooltip, 300, 200)
        helpTooltipShowing := true
        SetTimer(HideHelpTooltip, -8000)  ; Auto-hide after 8 seconds
    } else {
        HideHelpTooltip()
    }
}

; Function to toggle help tooltip for foundation menu
ShowFoundationHelpTooltip() {
    global helpTooltipShowing
    helpTooltip := "Keyboard Shortcuts:`n" .
                   "Shift+P - FS Playground`n" .
                   "Shift+V - FS MasterView`n" .
                   "Shift+W - FS Environment Wiki`n" .
                   "Shift+L - FS Environment List`n" .
                   "Shift+← - Back to Main Menu`n" .
                   "F1 - Show Help`n" .
                   "Shift+Esc - Close"
    
    if (!helpTooltipShowing) {
        ToolTip(helpTooltip, 200, 150)
        helpTooltipShowing := true
        SetTimer(HideHelpTooltip, -8000)  ; Auto-hide after 8 seconds
    } else {
        HideHelpTooltip()
    }
}

; Function to toggle help tooltip for sandcastle menu
ShowSandCastleHelpTooltip() {
    global helpTooltipShowing
    helpTooltip := "Keyboard Shortcuts:`n" .
                   "Enter - Confirm Number`n" .
                   "Shift+← - Back to Main Menu`n" .
                   "F1 - Show Help`n" .
                   "Shift+Esc - Close"
    
    if (!helpTooltipShowing) {
        ToolTip(helpTooltip, 200, 100)
        helpTooltipShowing := true
        SetTimer(HideHelpTooltip, -8000)  ; Auto-hide after 8 seconds
    } else {
        HideHelpTooltip()
    }
}

; Function to hide help tooltip
HideHelpTooltip() {
    global helpTooltipShowing
    ToolTip()
    helpTooltipShowing := false
}

; Global hotkeys for navigation
+Escape:: {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    try {
        if (IsObject(selectionGui) && WinExist(selectionGui.Hwnd)) {
            selectionGui.Destroy()
        }
    } catch {
        ; GUI object exists but window is already destroyed
    }
    currentGUIState := "none"
}

+Left:: {
    global currentGUIState, selectionGui, helpTooltipShowing
    if (currentGUIState = "foundation") {
        ToolTip()  ; Clear any active tooltips
        helpTooltipShowing := false
        LaunchBrowser()  ; Go back to main menu
    } else if (currentGUIState = "sandcastle") {
        ToolTip()  ; Clear any active tooltips
        helpTooltipShowing := false
        LaunchBrowser()  ; Go back to main menu from SandCastle input
    } else if (currentGUIState = "main") {
        ; Close from main menu
        ToolTip()  ; Clear any active tooltips
        helpTooltipShowing := false
        try {
            if (IsObject(selectionGui) && WinExist(selectionGui.Hwnd)) {
                selectionGui.Destroy()
            }
        } catch {
            ; GUI object exists but window is already destroyed
        }
        currentGUIState := "none"
    } else {
        ; When GUI is not active (currentGUIState = "none"), send the original keystroke to the system
        Send("+{Left}")
    }
}

; Quick access hotkeys for main menu
+!f:: {
    global currentGUIState
    if (currentGUIState = "main") {
        FoundationButton()
    }
}

+!s:: {
    global currentGUIState
    if (currentGUIState = "main") {
        SandCastleButton()
    }
}

+!m:: {
    global currentGUIState
    if (currentGUIState = "main") {
        MicroscopeButton()
    }
}

+!e:: {
    global currentGUIState
    if (currentGUIState = "main") {
        EMC2Button()
    }
}

+!c:: {
    global currentGUIState
    if (currentGUIState = "main") {
        FSCitrixButton()
    }
}

+!t:: {
    global currentGUIState
    if (currentGUIState = "main") {
        TrainingButton()
    }
}

; Quick access hotkeys for Foundation submenu
+!p:: {
    global currentGUIState
    if (currentGUIState = "foundation") {
        FSPlaygroundButton()
    }
}

+!v:: {
    global currentGUIState
    if (currentGUIState = "foundation") {
        FSMasterViewButton()
    }
}

+!w:: {
    global currentGUIState
    if (currentGUIState = "foundation") {
        FSWikiButton()
    }
}

+!l:: {
    global currentGUIState
    if (currentGUIState = "foundation") {
        FSEnvironmentListButton()
    }
}

; Global hotkey for help (F1 key instead of Shift+?)
F1:: {
    global currentGUIState
    if (currentGUIState = "main") {
        ShowMainHelpTooltip()
    } else if (currentGUIState = "foundation") {
        ShowFoundationHelpTooltip()
    } else if (currentGUIState = "sandcastle") {
        ShowSandCastleHelpTooltip()
    } else {
        ; When GUI is not active, send F1 to the system for normal help functionality
        Send("{F1}")
    }
}

; Foundation button handler - now shows sub-menu
FoundationButton(*) {
    global selectionGui
    if (selectionGui) {
        selectionGui.Destroy()
    }
    ShowFoundationMenu()
}

; Function to show Foundation System sub-menu
ShowFoundationMenu() {
    global helpTooltipShowing
    ; Clear any active tooltips first
    ToolTip()
    helpTooltipShowing := false
    
    global selectionGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "🏗️ Foundation System Options")
    global currentGUIState := "foundation"
    selectionGui.BackColor := "0x2C3E50"  ; Dark blue-gray background
    selectionGui.SetFont("s12 Bold", "Segoe UI")
    
    ; Title with white text
    titleText := selectionGui.Add("Text", "x20 y20 w280 h30 Center c0xFFFFFF", "Select Foundation System Option:")
    titleText.SetFont("s14 Bold")
    
    ; Add Foundation System sub-menu buttons with underlined letters
    playgroundBtn := selectionGui.Add("Button", "x40 y70 w240 h45", "🎮 FS &Playground")
    playgroundBtn.OnEvent("Click", FSPlaygroundButton)
    
    masterviewBtn := selectionGui.Add("Button", "x40 y125 w240 h45", "🔍 FS Master&View")
    masterviewBtn.OnEvent("Click", FSMasterViewButton)
    
    wikiBtn := selectionGui.Add("Button", "x40 y180 w240 h45", "📚 FS Environment &Wiki")
    wikiBtn.OnEvent("Click", FSWikiButton)
    
    envlistBtn := selectionGui.Add("Button", "x40 y235 w240 h45", "📋 FS Environment &List")
    envlistBtn.OnEvent("Click", FSEnvironmentListButton)
    
    ; Add separator line
    selectionGui.Add("Text", "x20 y295 w280 h2 Background0x34495E")
    
    ; Add back and close buttons
    backBtn := selectionGui.Add("Button", "x40 y310 w110 h35", "← Back")
    backBtn.OnEvent("Click", BackToMainMenu)
    
    closeBtn := selectionGui.Add("Button", "x170 y310 w110 h35", "✕ Close")
    closeBtn.OnEvent("Click", CloseGUI)
    
    ; Add help icon with tooltip - positioned in bottom right corner, clear of other buttons
    helpBtn := selectionGui.Add("Button", "x280 y350 w35 h30", "?")
    helpBtn.SetFont("s12 Bold")
    helpBtn.OnEvent("Click", ShowFoundationHelpClick)
    
    ; Handle window close event
    selectionGui.OnEvent("Close", CloseGUIEvent)
    
    selectionGui.Show("w320 h390")
}

; Button event handlers
BackToMainMenu(*) {
    global helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    LaunchBrowser()
}

CloseGUI(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    selectionGui.Destroy()
    currentGUIState := "none"
}

CloseGUIEvent(*) {
    global currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    currentGUIState := "none"
}

ShowFoundationHelpClick(*) {
    ShowFoundationHelpTooltip()
}

ShowMainHelpClick(*) {
    ShowMainHelpTooltip()
}

ShowSandCastleHelpClick(*) {
    ShowSandCastleHelpTooltip()
}

; FS Playground button handler
FSPlaygroundButton(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    if (selectionGui) {
        selectionGui.Destroy()
        currentGUIState := "none"
    }
    url := "https://hsw-iis-fs.epic.com/FSPLAYFIN/"
    OpenBrowser(url)
}

; FS MasterView button handler
FSMasterViewButton(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    if (selectionGui) {
        selectionGui.Destroy()
        currentGUIState := "none"
    }
    url := "https://hsw-model.epic.com/HSWeb_MODELVO/"
    OpenBrowser(url)
}

; FS Environment Wiki button handler
FSWikiButton(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    if (selectionGui) {
        selectionGui.Destroy()
        currentGUIState := "none"
    }
    url := "https://wiki.epic.com/main/Foundation_System/Foundation_System_Environments#General_Access_(Green)"
    OpenBrowser(url)
}

; FS Environment List button handler
FSEnvironmentListButton(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    if (selectionGui) {
        selectionGui.Destroy()
        currentGUIState := "none"
    }
    url := "https://emc2summary/GetSummaryReport.ashx/track/XSHADOW/EnvironmentList"
    OpenBrowser(url)
}

; SandCastle button handler
SandCastleButton(*) {
    global selectionGui, helpTooltipShowing
    ; Clear any active tooltips first
    ToolTip()
    helpTooltipShowing := false
    
    if (selectionGui) {
        selectionGui.Destroy()
    }
    
    ; Create styled input dialog with consistent color scheme
    global selectionGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "🏰 SandCastle Number")
    global currentGUIState := "sandcastle"
    selectionGui.BackColor := "0x2C3E50"  ; Consistent dark blue-gray background
    selectionGui.SetFont("s11", "Segoe UI")
    
    selectionGui.Add("Text", "x20 y20 w260 h25 Center c0xFFFFFF", "Enter the SandCastle number:")
    selectionGui.SetFont("s12")
    inputEdit := selectionGui.Add("Edit", "x40 y55 w220 h25 Center")
    
    okBtn := selectionGui.Add("Button", "x40 y95 w100 h35 Default", "✓ OK")
    cancelBtn := selectionGui.Add("Button", "x160 y95 w100 h35", "← Back")
    
    inputEdit.Focus()
    
    okBtn.OnEvent("Click", ProcessSandCastleOK)
    cancelBtn.OnEvent("Click", ProcessSandCastleCancel)
    selectionGui.OnEvent("Close", ProcessSandCastleCancel)
    
    ; Add help button to SandCastle screen
    helpBtn := selectionGui.Add("Button", "x260 y130 w30 h30", "?")
    helpBtn.SetFont("s10 Bold")
    helpBtn.OnEvent("Click", ShowSandCastleHelpClick)
    
    selectionGui.Show("w300 h170")
}

; Process SandCastle input
ProcessSandCastleOK(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    scNumber := ""
    try {
        ; Get the edit control value
        for ctrl in selectionGui {
            if (ctrl.Type = "Edit") {
                scNumber := ctrl.Text
                break
            }
        }
    }
    selectionGui.Destroy()
    currentGUIState := "none"
    if (scNumber != "") {
        url := "https://sand-pool" scNumber ".epic.com/HSWeb_SANDCASTLE" scNumber "/"
        OpenBrowser(url)
    } else {
        LaunchBrowser()
    }
}

; Cancel SandCastle input
ProcessSandCastleCancel(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    selectionGui.Destroy()
    currentGUIState := "none"
    LaunchBrowser()
}

; Microscope button handler
MicroscopeButton(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    if (selectionGui) {
        selectionGui.Destroy()
        currentGUIState := "none"
    }
    url := "https://hsw-current02.epic.com/MICROSCOPEPRDT/"
    OpenBrowser(url)
}

; EMC2 button handler
EMC2Button(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    if (selectionGui) {
        selectionGui.Destroy()
        currentGUIState := "none"
    }
    url := "https://emc2.epic.com/HSWeb_track/"
    OpenBrowser(url)
}

; FS Citrix button handler
FSCitrixButton(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    if (selectionGui) {
        selectionGui.Destroy()
        currentGUIState := "none"
    }
    url := "https://storefrontlb/Citrix/XAXDWeb/"
    OpenBrowser(url)
}

; Training Environments button handler
TrainingButton(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()  ; Clear any active tooltips
    helpTooltipShowing := false
    if (selectionGui) {
        selectionGui.Destroy()
        currentGUIState := "none"
    }
    url := "https://internalapps.epic.com/Citrix/InternalAppsWeb/"
    OpenBrowser(url)
}

; Define the main function to launch the browser
LaunchBrowser() {
    global helpTooltipShowing
    ; Clear any active tooltips first
    ToolTip()
    helpTooltipShowing := false
    
    ; Close any existing selection GUI
    try {
        if (IsObject(selectionGui) && WinExist(selectionGui.Hwnd)) {
            selectionGui.Destroy()
        }
    }
    
    ; Create a custom dialog with modern styling
    global selectionGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "🚀 Epic Systems Launcher")
    global currentGUIState := "main"
    selectionGui.BackColor := "0x34495E"  ; Dark blue-gray background
    selectionGui.SetFont("s12 Bold", "Segoe UI")
    
    ; Main title with white text and larger font
    titleText := selectionGui.Add("Text", "x10 y15 w420 h40 Center c0xFFFFFF", "Which system would you like to launch?")
    titleText.SetFont("s13 Bold")
    
    ; System buttons with emojis, underlined letters, and consistent sizing
    foundationBtn := selectionGui.Add("Button", "x40 y70 w150 h50", "🏗️ &Foundation System")
    foundationBtn.OnEvent("Click", FoundationButton)
    
    sandcastleBtn := selectionGui.Add("Button", "x210 y70 w150 h50", "🏰 &SandCastle")
    sandcastleBtn.OnEvent("Click", SandCastleButton)
    
    microscopeBtn := selectionGui.Add("Button", "x40 y130 w150 h50", "🔬 &Microscope")
    microscopeBtn.OnEvent("Click", MicroscopeButton)
    
    emc2Btn := selectionGui.Add("Button", "x210 y130 w150 h50", "⚡ &EMC2")
    emc2Btn.OnEvent("Click", EMC2Button)
    
    fsCitrixBtn := selectionGui.Add("Button", "x40 y190 w150 h50", "💻 FS &Citrix")
    fsCitrixBtn.OnEvent("Click", FSCitrixButton)
    
    trainingBtn := selectionGui.Add("Button", "x210 y190 w150 h50", "🎓 &Training Environments")
    trainingBtn.OnEvent("Click", TrainingButton)
    
    ; Add separator line
    selectionGui.Add("Text", "x20 y255 w380 h3 Background0x2C3E50")
    
    ; Close button with custom styling
    closeBtn := selectionGui.Add("Button", "x170 y270 w100 h40", "✕ Close")
    closeBtn.OnEvent("Click", CloseGUI)
    
    ; Add help icon in bottom right corner
    helpBtn := selectionGui.Add("Button", "x400 y305 w35 h30", "?")
    helpBtn.SetFont("s12 Bold")
    helpBtn.OnEvent("Click", ShowMainHelpClick)
    
    ; Handle window close event
    selectionGui.OnEvent("Close", CloseGUIEvent)
    
    ; Show the GUI with fixed size
    selectionGui.Show("w445 h345")
}

; Shift+F1 hotkey to open the GUI
+F1:: LaunchBrowser()

; Set icon with error handling
try {
    TraySetIcon("C:\Users\psiegel\OneDrive - Epic\Documents\AutoHotkey\Autohotkey\Epic\Epic.ico")
} catch as e {
    ; If icon fails to load, continue without custom icon
    ; MsgBox("Failed to load icon: " . e.Message . "`n`nScript will continue with default icon.", "Icon Error", "OK")
}