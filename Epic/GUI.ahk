#Requires AutoHotkey v2.0

; Define Globals
global categories
global LV
global MyGui
global searchBox

; Define the hotkey for displaying the GUI
^!Space:: ShowHotkeyGUI()

; Define categories and their hotkeys
global categories := [
    {name: "Websites", hotkeys: [
        {hotkey: "Ctrl+Alt+L", description: "Lunchy"},
        {hotkey: "Shift+F1", description: "Open Hyperspace Launcher"},
        {hotkey: "Shift+F3", description: "Reload Startup AHK File"}
    ]},
    {name: "Search", hotkeys: [
        {hotkey: "Ctrl+Alt+Win+G", description: "Google Search"},
        {hotkey: "Ctrl+Alt+G", description: "Guru Search"},
        {hotkey: "Ctrl+Alt+F", description: "INI/Item Search"},
        {Hotkey: "Ctr+Alt+M", description: "Open MeetCute"}
    ]},
    {name: "Hotkeys", hotkeys: [
        {hotkey: "Ctrl+End", description: "Home Key"},
        {hotkey: "Ctrl+Del", description: "Insert Key"},
        {hotkey: "Ctrl+Alt+W", description: "Open WikiShortcut.ahk"},
        {hotkey: "Ctrl+Alt+Shift+W", description: "Close WikiShortcut.ahk"},
        {hotkey: "Win+Alt+Ctrl+C", description: "Charging Training.pptx"},       
        {hotkey: "Win+Alt+Shift+I", description: "Old Charging Training.pptx"},
        {hotkey: ".prd", description: "prd file path"},
        {hotkey: ".nprd", description: "non-prd file path"},
        {hotkey: ".nfs", description: "FS FTP file path"}
    ]},
    {name: "Credentials", hotkeys: [
        {hotkey: "Ctrl+Alt+/", description: "Epic Login Gui"},
        {hotkey: "Ctrl+Alt+T", description: "Thunder"},
        {hotkey: "Ctrl+Alt+U", description: "Epic email"},
        {hotkey: "Ctrl+Alt+P", description: "Epic Password"},
        {hotkey: "Ctrl+Alt+A", description: "NEMS Hyperspace login"},
        {hotkey: "Ctrl+Alt+Q", description: "NEMS Text login"},
        {hotkey: "Ctrl+Alt+Shift+U", description: "UMC Hyperspace login"},
        {hotkey: "Ctrl+Alt+Shift+T", description: "UMC Text login"},
        {hotkey: "Ctrl+Alt+Shift+E", description: "UMC Epic Generic login"}
    ]},
    {name: "Functions", hotkeys: [
        {hotkey: "Ctrl+Alt+Shift+M", description: "Convert .xml to .xlsx"},
        {hotkey: "Ctrl+Alt+.", description: "Open AHKFolder"},
        {hotkey: "Ctrl+Alt+S", description: "Paste List w Enter"},
        {hotkey: "Ctrl+Alt+Shift+S", description: "Paste List w Down"},
        {hotkey: "Ctrl+Alt+Esc", description: "Close AHK Help GUI"}
    ]}
]

ShowHotkeyGUI() {
    ; Create a new GUI
    global MyGui := Gui("+Resize +MinSize400x300", "Hotkey Reference")

    ; Add a search box with placeholder text
    global searchBox := MyGui.Add("Edit", "vSearchTerm x10 y10 w580 h23", "Search...")
    searchBox.OnEvent("Focus", (*) => OnSearchFocus(searchBox))
    searchBox.OnEvent("LoseFocus", (*) => OnSearchLoseFocus(searchBox))
    searchBox.OnEvent("Change", (*) => FilterList(LV, searchBox))

    ; Add a ListView to display hotkeys with scrollbars
    global LV := MyGui.Add("ListView", "x10 y40 w580 h325 +VScroll", ["Category", "Hotkey", "Description"])
    LV.OnEvent("DoubleClick", LV_DoubleClick)

    ; Populate the ListView
    PopulateListView(LV)

    ; Set up GUI resize event
    MyGui.OnEvent("Size", GuiResize)

    ; Show the GUI
    MyGui.Show("w600 h400")
    
    ; Initial resize
    GuiResize()
}

GuiResize(*) {
    global MyGui, searchBox, LV
    
    if (!IsSet(MyGui) || !MyGui.Hwnd)
        return
        
    ; Get the current GUI size
    MyGui.GetPos(, , &w, &h)
    
    ; Resize search box to span width minus margins
    searchBox.Move(10, 10, w - 20, 23)
    
    ; Resize ListView to fill remaining space with extra padding at bottom
    ; Increased bottom margin from 60 to 75 to ensure last line is fully visible
    LV.Move(10, 40, w - 20, h - 75)
    
    ; Auto-size columns
    AutoSizeColumns(LV)
}

AutoSizeColumns(LV) {
    ; Get ListView width
    LV.GetPos(, , &lvWidth, )
    
    ; Calculate column widths (accounting for scrollbar)
    totalWidth := lvWidth - 25  ; Reserve space for scrollbar
    
    categoryWidth := Integer(totalWidth * 0.2)      ; 20%
    hotkeyWidth := Integer(totalWidth * 0.3)        ; 30% 
    descriptionWidth := Integer(totalWidth * 0.5)   ; 50%
    
    ; Set column widths
    LV.ModifyCol(1, categoryWidth)
    LV.ModifyCol(2, hotkeyWidth)
    LV.ModifyCol(3, descriptionWidth)
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

    LV.Opt("-Redraw")
    LV.Delete()

    searchTermLower := StrLower(searchTerm)

    for category in categories {
        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
        for currentHotkey in category.hotkeys {
            if (categoryMatched or 
                InStr(StrLower(currentHotkey.hotkey), searchTermLower) > 0 or 
                InStr(StrLower(currentHotkey.description), searchTermLower) > 0) {
                LV.Add(, category.name, currentHotkey.hotkey, currentHotkey.description)
            }
        }
    }

    LV.Opt("+Redraw")
    AutoSizeColumns(LV)
}

PopulateListView(LV) {
    LV.Opt("-Redraw")  ; Pause redrawing
    LV.Delete()  ; Clear all rows
    for category in categories {
        for currentHotkey in category.hotkeys {
            LV.Add(, category.name, currentHotkey.hotkey, currentHotkey.description)
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
        SetTimer(() => ToolTip(), -2000)  ; Remove tooltip after 2 seconds
    }
}

; Optional: Add hotkey to close the GUI
^!Escape:: {
    if (IsSet(MyGui) && MyGui.Hwnd) {
        MyGui.Destroy()
    }
}