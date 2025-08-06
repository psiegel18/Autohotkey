#Requires AutoHotkey v2.0

; Global variable for the selection GUI
selectionGui := ""

; Function to open URL in default browser
OpenBrowser(url) {
    try {
        Run(url)
    } catch as e {
        MsgBox("Failed to open URL: " . url . "`n`nError: " . e.Message, "Error", "OK IconX")
    }
}

; Foundation button handler
FoundationButton(*) {
    global selectionGui
    if (selectionGui) {
        selectionGui.Destroy()
    }
    url := "https://hsw-iis-fs.epic.com/FSPLAYFIN/"
    OpenBrowser(url)
}

; SandCastle button handler
SandCastleButton(*) {
    global selectionGui
    if (selectionGui) {
        selectionGui.Destroy()
    }
    
    ; Prompt for SandCastle number
    result := InputBox("Enter the SandCastle number:", "SandCastle Number", "w300 h100")
    
    if (result.Result = "OK" && result.Value != "") {
        scNumber := result.Value
        ; Replace both # characters in the URL with the user's input
        url := "https://sand-pool" scNumber ".epic.com/HSWeb_SANDCASTLE" scNumber "/"
        OpenBrowser(url)
    } else if (result.Result = "Cancel") {
        ; If user cancelled, show the selection GUI again
        LaunchBrowser()
    }
}

; Define the main function to launch the browser
LaunchBrowser() {
    ; Close any existing selection GUI
    try {
        if (selectionGui && WinExist(selectionGui.Hwnd)) {
            selectionGui.Destroy()
        }
    }
    
    ; Create a custom dialog with proper button labels
    global selectionGui := Gui("+AlwaysOnTop", "System Selection")
    selectionGui.SetFont("s10")
    selectionGui.Add("Text", "w300 Center", "Which system would you like to launch?")
    
    selectionGui.Add("Button", "x20 y+20 w120 h30", "Foundation System").OnEvent("Click", FoundationButton)
    selectionGui.Add("Button", "x+40 y+-30 w120 h30", "SandCastle").OnEvent("Click", SandCastleButton)
    
    ; Add close button
    selectionGui.Add("Button", "x20 y+10 w260 h30", "Close").OnEvent("Click", (*) => selectionGui.Destroy())
    
    ; Handle window close event
    selectionGui.OnEvent("Close", (*) => selectionGui.Destroy())
    
    selectionGui.Show()
}

; Shift+F1 hotkey to open the GUI
+F1:: LaunchBrowser()

