#Requires AutoHotkey v2.0

; Video Embed Code Formatter for MediaWiki
; Hotkey: Win + Alt + W

; Global variables
MyGui := ""

; Hotkey: Win + Alt + W
#!w:: {
    ShowFormatter()
}

; Function to show the formatter
ShowFormatter() {
    global MyGui

    ; If GUI already exists and is valid, just show it and clear fields
    try {
        if (MyGui && MyGui.Hwnd) {
            ClearFields()
            MyGui.Show()
            return
        }
    } catch {
        ; GUI was destroyed, recreate it
        MyGui := ""
    }
    
    ; Create GUI
    MyGui := Gui(, "SharePoint to MediaWiki Video Formatter")
    MyGui.SetFont("s10")
    
    ; Instructions
    MyGui.Add("Text", "w600", "Paste your SharePoint embed code below:")
    
    ; Input box for embed code
    MyGui.Add("Text", "w600 y+10", "Embed Code:")
    global EmbedInput := MyGui.Add("Edit", "w600 h150 vEmbedCode")
    
    ; Custom title option
    MyGui.Add("Text", "w600 y+15", "Video Title (leave blank to auto-extract from embed code):")
    global TitleInput := MyGui.Add("Edit", "w600 vCustomTitle")
    
    ; Buttons
    MyGui.Add("Button", "w140 y+15", "Format Code").OnEvent("Click", FormatCode)
    MyGui.Add("Button", "w140 x+10", "Clear").OnEvent("Click", ClearFields)
    MyGui.Add("Button", "w140 x+10", "Close").OnEvent("Click", HideFormatter)
    
    ; Output section
    MyGui.Add("Text", "xm w600 y+20", "Formatted Code (automatically copied to clipboard):")
    global OutputBox := MyGui.Add("Edit", "w600 h200 vOutput ReadOnly")
    
    ; Show the GUI
    MyGui.Show("w640")
}

; Function to hide the formatter
HideFormatter(*) {
    global MyGui
    try {
        if (MyGui && MyGui.Hwnd)
            MyGui.Hide()
    } catch {
        ; GUI already destroyed
    }
}

; Function to format the code
FormatCode(*) {
    global EmbedInput, TitleInput, OutputBox
    
    ; Get the input values
    embedCode := EmbedInput.Value
    customTitle := TitleInput.Value
    
    ; Validate input
    if (embedCode = "") {
        MsgBox("Please paste an embed code first!", "Error", 16)
        return
    }
    
    ; Extract iframe tag from the embed code
    if (RegExMatch(embedCode, "i)<iframe[^>]*>.*?</iframe>", &iframeMatch)) {
        iframe := iframeMatch[0]
    } else if (RegExMatch(embedCode, "i)<iframe[^>]*/>", &iframeMatch)) {
        iframe := iframeMatch[0]
    } else {
        MsgBox("Could not find iframe tag in the embed code!", "Error", 16)
        return
    }
    
    ; Extract title from iframe if custom title not provided
    if (customTitle = "") {
        if (RegExMatch(iframe, 'title="([^"]*)"', &titleMatch)) {
            rawTitle := titleMatch[1]
            ; Remove file extension
            title := RegExReplace(rawTitle, "\.(mp4|avi|mov|wmv|flv|webm)$", "")
            ; Replace underscores and hyphens with spaces
            title := StrReplace(title, "_", " ")
            title := StrReplace(title, "-", " ")
            ; Capitalize first letter of each word (title case)
            title := StrTitle(title)
        } else {
            title := "Untitled Video"
        }
    } else {
        title := customTitle
    }
    
    ; Format the output
    output := "{"
    output .= "`n    title: `"" . title . "`","
    output .= "`n    embedCode: ``" . iframe . "``"
    output .= "`n},"
    
    ; Display in output box
    OutputBox.Value := output
    
    ; Copy to clipboard
    A_Clipboard := output
    
    ; Show success message
    MsgBox("Formatted code copied to clipboard!`n`nYou can now paste it into your MediaWiki page's video array.", "Success", 64)
}

; Function to clear all fields
ClearFields(*) {
    global EmbedInput, TitleInput, OutputBox
    
    if (EmbedInput)
        EmbedInput.Value := ""
    if (TitleInput)
        TitleInput.Value := ""
    if (OutputBox)
        OutputBox.Value := ""
}

; Helper function to capitalize first letter of each word (proper title case)
StrTitle(str) {
    ; First, convert entire string to lowercase
    str := StrLower(str)
    
    result := ""
    capitalizeNext := true
    
    Loop Parse, str {
        char := A_LoopField
        
        if (capitalizeNext && RegExMatch(char, "[a-z]")) {
            result .= StrUpper(char)
            capitalizeNext := false
        } else {
            result .= char
        }
        
        ; Capitalize after spaces, tabs, or start of string
        if (char = " " || char = "`t") {
            capitalizeNext := true
        }
    }
    
    return result
}