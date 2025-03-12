#Requires AutoHotkey v2.0
; Item Lookup Script
; Ctrl+Alt+F hotkey to open a dialog and navigate to a specific URL with user input
; Also provides option to navigate directly to the Item Info page

; Define the hotkey
^!f::
{
    ; Create a custom GUI with two input fields
    MyGui := Gui("", "Item Lookup")
    MyGui.SetFont("s10")
    
    ; Add text labels and input fields
    MyGui.Add("Text", "x20 y20 w80 h25", "INI:")
    iniInput := MyGui.Add("Edit", "x110 y20 w200 h25")
    
    MyGui.Add("Text", "x20 y60 w80 h25", "Item #:")
    itemInput := MyGui.Add("Edit", "x110 y60 w200 h25")
    
    ; Add buttons
    MyGui.Add("Button", "x20 y100 w100 h30", "Item Info Page").OnEvent("Click", ButtonItemInfo)
    MyGui.Add("Button", "x140 y100 w90 h30 Default", "Search").OnEvent("Click", ButtonOK)
    MyGui.Add("Button", "x240 y100 w90 h30", "Cancel").OnEvent("Click", ButtonCancel)
    
    ; Center the GUI on screen
    MyGui.OnEvent("Close", ButtonCancel)
    MyGui.OnEvent("Escape", ButtonCancel)
    
    ; Show the GUI
    MyGui.Show("w350 h150 Center")
    
    ButtonOK(*)
    {
        iniValue := iniInput.Value
        itemValue := itemInput.Value
        
        ; Check if both fields have values
        if (iniValue = "" || itemValue = "") {
            MsgBox("Please enter both INI and Item # values.", "Missing Input", "Icon!")
            return
        }
        
        ; Construct the URL with the user inputs
        url := "https://emc2summary/GetSummaryReport.ashx/track/XSHADOW/Item%20Report/I%20" . iniValue . "%20" . itemValue
        
        ; Close the GUI
        MyGui.Destroy()
        
        ; Open the URL in the default browser
        Run(url)
    }
    
    ButtonCancel(*)
    {
        MyGui.Destroy()
    }
    
    ButtonItemInfo(*)
    {
        iniValue := iniInput.Value
        itemValue := itemInput.Value
        
        ; Check if both fields have values
        if (iniValue != "" && itemValue != "") {
            ; If both values are provided, navigate to the specific item info page
            Run("https://emc2summary/GetSummaryReport.ashx/track/XSHADOW/Item%20Info/" . iniValue . "-" . itemValue)
        } else {
            ; If any field is empty, navigate to the general item info page
            Run("https://emc2summary/GetSummaryReport.ashx/track/XSHADOW/Item%20Info")
        }
        
        ; Close the GUI after navigating
        MyGui.Destroy()
    }
    
    return
}