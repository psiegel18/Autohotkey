#Requires AutoHotkey v2.0

; Define Globals
global categories
global LV

; Define the hotkey for displaying the GUI
^!Space:: ShowHotkeyGUI()

; Define categories and their hotkeys
global categories := [
    {name: "Websites", hotkeys: [
        {hotkey: "Ctrl+Alt+L", description: "Lunchy"},
        {hotkey: "Shift+F1", description: "Open myWiki Window"},
        {hotkey: "Shift+F2", description: "Close myWiki Window"}
    ]},
    {name: "Search", hotkeys: [
        {hotkey: "Ctrl+Alt+Win+G", description: "Google Search"},
        {hotkey: "Ctrl+Shift+G", description: "Guru Search"}
    ]},
    {name: "CustFilePath", hotkeys: [
        {hotkey: ".prd", description: "AMHS prd file path"},
        {hotkey: ".nonprd", description: "AMHS non-prd file path"}
    ]},
    {name: "Thunder Passwords", hotkeys: [
        {hotkey: "Ctrl+Alt+C", description: "AMHS Hyperspace/FTP login"},
        {hotkey: "Ctrl+Alt+V", description: "AMHS Text login"},
        {hotkey: "Ctrl+Alt+Z", description: "NCH Remote Desktop login"},
        {hotkey: "Ctrl+Alt+A", description: "NCH Hyperspace login"},
        {hotkey: "Ctrl+Alt+Q", description: "NCH Text login"}
    ]},
    {name: "Other Passwords", hotkeys: [
        {hotkey: "Ctrl+Alt+T", description: "Thunder password"},
        {hotkey: "Ctrl+Alt+U", description: "Epic email"},
        {hotkey: "Ctrl+Alt+P", description: "Epic password"},
        {hotkey: "Ctrl+Alt+Shift+P", description: "Epic email + password"},
        {hotkey: "Ctrl+Alt+Shift+N", description: "NCH email"}
    ]},
    {name: "Startup", hotkeys: [
        {hotkey: "Ctrl+Alt+W", description: "Open WikiShortcut.ahk"},
        {hotkey: "Ctrl+Alt+Shift+W", description: "Close WikiShortcut.ahk"},
        {hotkey: "Win+Alt+Shift+C", description: "Charging Training.pptx"},
        {hotkey: "Ctrl+Alt+N", description: "Open Text Editor"},
        {hotkey: "Ctrl+Alt+.", description: "Open AHKFolder"},
        {hotkey: "Win+Shft+Z", description: "Open Primary NCH Server"},
        {hotkey: "Win+Alt+Shift+Z", description: "Open Secondary NCH Server"}
    ]}
]

ShowHotkeyGUI() {
    ; Create a new GUI
    MyGui := Gui("+Resize +MinSize400x300", "Hotkey Reference")

    ; Add a search box with placeholder text
    searchBox := MyGui.Add("Edit", "vSearchTerm w590", "Search...")
    searchBox.OnEvent("Focus", (*) => OnSearchFocus(searchBox))
    searchBox.OnEvent("LoseFocus", (*) => OnSearchLoseFocus(searchBox))
    searchBox.OnEvent("Change", (*) => FilterList(LV, searchBox))

    ; Add a ListView to display hotkeys
    global LV := MyGui.Add("ListView", "r20 w590", ["Category", "Hotkey", "Description"])
    LV.OnEvent("DoubleClick", LV_DoubleClick)

    ; Populate the ListView
    PopulateListView(LV)

    ; Set up auto-sizing columns
    AutoSizeColumns(LV)

    ; Set up GUI resize event
    MyGui.OnEvent("Size", (*) => GuiResize(MyGui, searchBox, LV))

    ; Show the GUI
    MyGui.Show("w600 h400")
}

GuiResize(MyGui, searchBox, LV, *) {
    if (MyGui.Hwnd) {  ; Ensure the window still exists
        ; Get window dimensions
        windowWidth := 0
        windowHeight := 0
        try {
            WinGetClientPos(&x, &y, &windowWidth, &windowHeight, MyGui)
        }
        
        ; Calculate positions and sizes
        searchBoxHeight := 23  ; Typical height for an Edit control
        listViewTop := searchBoxHeight + 5  ; 5 pixels padding
        listViewHeight := windowHeight - listViewTop - 5  ; 5 pixels padding at bottom

        ; Resize and reposition controls
        searchBox.Move(5, 5, windowWidth - 10)
        LV.Move(5, listViewTop, windowWidth - 10, listViewHeight)
        
        ; Adjust column widths
        AutoSizeColumns(LV)
    }
}

AutoSizeColumns(LV) {
    LV.GetPos(&x, &y, &w, &h)
    totalWidth := w
    
    ; Set Category and Hotkey columns to AutoHdr
    LV.ModifyCol(1, "AutoHdr")
    LV.ModifyCol(2, "AutoHdr")
    
    ; Get the width of the first two columns
    categoryWidth := SendMessage(4125, 0, 0, LV)  ; LVM_GETCOLUMNWIDTH = 4125
    hotkeyWidth := SendMessage(4125, 1, 0, LV)
    
    ; Calculate the width for the Description column
    descriptionWidth := totalWidth - categoryWidth - hotkeyWidth - 20  ; 20 pixels for margins and scrollbar
    
    ; Set the width of the Description column
    if (descriptionWidth > 0) {
        LV.ModifyCol(3, descriptionWidth)
    }
}

OnSearchFocus(searchBox) {
    if (searchBox.Value == "Search...") {
        searchBox.Value := ""
    }
}

OnSearchLoseFocus(searchBox) {
    if (searchBox.Value == "") {
        searchBox.Value := "Search..."
        FilterList(LV, searchBox)  ; Reset the list view when the search box is empty
    }
}

FilterList(LV, searchBox) {
    searchTerm := Trim(searchBox.Value)
    if (searchTerm == "Search..." or searchTerm == "") {
        PopulateListView(LV)
        return
    }

    LV.Opt("-Redraw")  ; Pause redrawing
    LV.Delete()  ; Clear all rows

    searchTermLower := StrLower(searchTerm)

    for category in categories {
        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
        for hotkey in category.hotkeys {
            if (categoryMatched or 
                InStr(StrLower(hotkey.hotkey), searchTermLower) > 0 or 
                InStr(StrLower(hotkey.description), searchTermLower) > 0) {
                LV.Add(, category.name, hotkey.hotkey, hotkey.description)
            }
        }
    }

    LV.Opt("+Redraw")  ; Resume redrawing
    AutoSizeColumns(LV)
}

PopulateListView(LV) {
    LV.Opt("-Redraw")  ; Pause redrawing
    LV.Delete()  ; Clear all rows
    for category in categories {
        for hotkey in category.hotkeys {
            LV.Add(, category.name, hotkey.hotkey, hotkey.description)
        }
    }
    LV.Opt("+Redraw")  ; Resume redrawing
    AutoSizeColumns(LV)
}

LV_DoubleClick(LV, RowNumber) {
    if (RowNumber > 0) {
        selectedHotkey := LV.GetText(RowNumber, 2)  ; Get the hotkey from the second column
        A_Clipboard := selectedHotkey
        ToolTip("Copied to clipboard: " . selectedHotkey)
        SetTimer () => ToolTip(), -2000  ; Remove tooltip after 2 seconds
    }
}