#Requires AutoHotkey v2.0

; Define the hotkey for displaying the GUI
^!Space:: {

    ; Create a new GUI
    MyGui := Gui(,"Hotkeys")

    ; Add text to the GUI
    MyGui.Add("Text", , "Websites:")
    MyGui.Add("Text", , "ctrl+alt+L = Lunchy")
    MyGui.Add("Text", , "shft+F1 = myWiki Window")
    MyGui.Add("Text", , "shft+F2 = Close myWiki Window")
    MyGui.Add("Text", , "")
    MyGui.Add("Text", , "Searches:")
    MyGui.Add("Text", , "ctrl+alt+shft+G = Google Search")
    MyGui.Add("Text", , "ctrl+shft+G = Guru Search")
    MyGui.Add("Text", , "")
    MyGui.Add("Text", , "CustFilePath:")
    MyGui.Add("Text", , ".prd = AMHS prd file path")
    MyGui.Add("Text", , ".nonprd = AMHS prd file path")
    MyGui.Add("Text", , "")
    MyGui.Add("Text", , "Thunder Passwords:")
    MyGui.Add("Text", , "ctrl+alt+C = AMHS Hyperspace/FTP login")
    MyGui.Add("Text", , "ctrl+alt+V = AMHS Text login")
    MyGui.Add("Text", , "")
    MyGui.Add("Text", , "Other Passwords:")
    MyGui.Add("Text", , "ctrl+alt+T = Thunder password")
    MyGui.Add("Text", , "ctrl+alt+U = Epic email")
    MyGui.Add("Text", , "ctrl+alt+P = Epic password")
    MyGui.Add("Text", , "ctrl+alt+shft+P = Epic email + password")
    MyGui.Add("Text", , "")
    MyGui.Add("Text", , "Startup:")
    MyGui.Add("Text", , "ctrl+alt+W = Open WikiShortcut.ahk")
    MyGui.Add("Text", , "ctrl+alt+shft+W = Close WikiShortcut.ahk")

    ; Show the GUI
    MyGui.Show()
}