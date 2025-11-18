#Requires AutoHotkey v2.0

; Define Globals
global hotkeyCategories
global hotstringCategories
global wikiCategories
global LV_Hotkeys
global LV_Hotstrings
global LV_Wiki
global MyGui
global searchBox
global MyTab

; Define the hotkey for displaying the GUI
^!Space:: ShowHotkeyGUI()

; Define hotkey categories
global hotkeyCategories := [
    {name: "Websites", hotkeys: [
        {hotkey: "Ctrl+Alt+L", description: "Lunchy"},
        {hotkey: "Shift+F1", description: "Open Hyperspace Launcher"},
        {hotkey: "Shift+F3", description: "Reload Startup AHK File"}
    ]},
    {name: "Search", hotkeys: [
        {hotkey: "Ctrl+Alt+Win+G", description: "Google Search"},
        {hotkey: "Ctrl+Alt+G", description: "Guru Search"},
        {hotkey: "Ctrl+Alt+F", description: "INI/Item Search"},
        {hotkey: "Ctrl+Alt+M", description: "Open MeetCute"}
    ]},
    {name: "Hotkeys", hotkeys: [
        {hotkey: "Ctrl+End", description: "Home Key"},
        {hotkey: "Ctrl+Del", description: "Insert Key"},
        {hotkey: "Ctrl+Alt+W", description: "Open WikiShortcut.ahk"},
        {hotkey: "Ctrl+Alt+Shift+W", description: "Close WikiShortcut.ahk"},
        {hotkey: "Win+Alt+Ctrl+C", description: "Charging Training.pptx"},       
        {hotkey: "Win+Alt+Shift+I", description: "Old Charging Training.pptx"}
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

; Define hotstring categories
global hotstringCategories := [
    {name: "Paths", hotstrings: [
        {hotstring: ".prd", description: "Production file path"},
        {hotstring: ".nprd", description: "Non-production file path"},
        {hotstring: ".nfs", description: "FS FTP file path"},
        {hotstring: ".ftp", description: "Show path selection GUI"}
    ]},
    {name: "Emoticons", hotstrings: [
        {hotstring: ".shrug", description: "¯\_(ツ)_/¯"},
        {hotstring: ".tbl", description: "(╯°□°)╯︵ ┻━┻"},
        {hotstring: ".puttableback", description: "┬─┬ノ( º _ ºノ)"},
        {hotstring: ".lenny", description: "( ͡° ͜ʖ ͡°)"},
        {hotstring: ".disapprove", description: "ಠ_ಠ"},
        {hotstring: ".happy", description: "ヽ(^▽^)/"},
        {hotstring: ".sparkle", description: "(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"},
        {hotstring: ".dead", description: "x_x"},
        {hotstring: ".cute", description: "(｡◕‿◕｡)"},
        {hotstring: ".bear", description: "ʕ•ᴥ•ʔ"},
        {hotstring: ".music", description: "♪┏(･o･)┛♪"},
        {hotstring: ".excited", description: "\(^o^)/"},
        {hotstring: ".thinking", description: "(¬‿¬)"},
        {hotstring: ".love", description: "(♥‿♥)"},
        {hotstring: ".dealwithit", description: "(⌐■_■)"}
    ]},
    {name: "Symbols", hotstrings: [
        {hotstring: ".check", description: "✓ (checkmark)"},
        {hotstring: ".x", description: "✗ (X mark)"},
        {hotstring: ".arrow", description: "→ (right arrow)"},
        {hotstring: ".arrowleft", description: "← (left arrow)"},
        {hotstring: ".arrowup", description: "↑ (up arrow)"},
        {hotstring: ".arrowdown", description: "↓ (down arrow)"},
        {hotstring: ".star", description: "★ (filled star)"},
        {hotstring: ".staropen", description: "☆ (open star)"},
        {hotstring: ".heart", description: "♥ (heart)"},
        {hotstring: ".bullet", description: "• (bullet point)"},
        {hotstring: ".dot", description: "· (middle dot)"},
        {hotstring: ".tm", description: "™ (trademark)"},
        {hotstring: ".copyright", description: "© (copyright)"},
        {hotstring: ".registered", description: "® (registered)"},
        {hotstring: ".deg", description: "° (degree)"},
        {hotstring: ".pm", description: "± (plus-minus)"},
        {hotstring: ".infinity", description: "∞ (infinity)"},
        {hotstring: ".checkmark", description: "✅ (check mark emoji)"},
        {hotstring: ".warnicon", description: "⚠️ (warning emoji)"},
        {hotstring: ".infoicon", description: "ℹ️ (info emoji)"}
    ]},
    {name: "Dates", hotstrings: [
        {hotstring: ".td", description: "Today's date (M/dd)"},
        {hotstring: ".date", description: "ISO date (yyyy-MM-dd)"},
        {hotstring: ".time", description: "24-hour time (HH:mm)"},
        {hotstring: ".ts", description: "Full timestamp"},
        {hotstring: ".longdate", description: "Long date format"}
    ]}
]

; Define wiki shortcut categories
global wikiCategories := [
    {name: "Formatting", shortcuts: [
        {shortcut: ".bold", description: "Bold text ''''''"},
        {shortcut: ".ins", description: "Underline <u></u>"},
        {shortcut: ".ital", description: "Italic ''''"},
        {shortcut: ".big", description: "Big text <big></big>"},
        {shortcut: ".small", description: "Small text <small></small>"},
        {shortcut: ".center", description: "Center align <center></center>"},
        {shortcut: ".span", description: "Span element <span></span>"},
        {shortcut: ".br", description: "Line break <br/>"}
    ]},
    {name: "Code & Special", shortcuts: [
        {shortcut: ".syntax", description: "Syntax highlight block"},
        {shortcut: ".nowiki", description: "No wiki formatting <nowiki></nowiki>"},
        {shortcut: ".think", description: "HTML comment <!--  -->"},
        {shortcut: ".link", description: "Wiki link <link>|</link>"},
        {shortcut: ".table", description: "Wiki table structure"}
    ]},
    {name: "Message Boxes", shortcuts: [
        {shortcut: ".why", description: "{{Why}} template"},
        {shortcut: ".tip", description: "{{Tip}} template"},
        {shortcut: ".note", description: "{{Note}} template"},
        {shortcut: ".caution", description: "{{Caution}} template"},
        {shortcut: ".warning", description: "{{Warning}} template"},
        {shortcut: ".stop", description: "{{Stop}} template"},
        {shortcut: ".watchout", description: "{{Watchout}} template"},
        {shortcut: ".msgbox", description: "{{Messagebox}} template"},
        {shortcut: ".info", description: "{{Info}} template"},
        {shortcut: ".tldr", description: "{{TLDR}} template"},
        {shortcut: ".compare", description: "{{Compare}} template"},
        {shortcut: ".trap", description: "{{Trap}} template"}
    ]},
    {name: "Special Templates", shortcuts: [
        {shortcut: ".droids", description: "{{Droids}} template"},
        {shortcut: ".mariojump", description: "{{MarioJump}} template"},
        {shortcut: ".spicy", description: "{{Spicy}} template"},
        {shortcut: ".officehours", description: "{{OfficeHours}} template"},
        {shortcut: ".question", description: "{{Question}} template"},
        {shortcut: ".todo", description: "{{TODO}} template"},
        {shortcut: ".underconstruction", description: "{{Under Construction}} template"},
        {shortcut: ".outofdate", description: "{{OutOfDate}} template"}
    ]}
]

ShowHotkeyGUI() {
    ; Create a new GUI
    global MyGui := Gui("+Resize +MinSize500x400", "Hotkey & Hotstring Reference")

    ; Add a search box with placeholder text
    global searchBox := MyGui.Add("Edit", "vSearchTerm x10 y10 w580 h23", "Search...")
    searchBox.OnEvent("Focus", (*) => OnSearchFocus(searchBox))
    searchBox.OnEvent("LoseFocus", (*) => OnSearchLoseFocus(searchBox))
    searchBox.OnEvent("Change", (*) => FilterAllLists())

    ; Add Tab control
    global MyTab := MyGui.Add("Tab3", "x10 y40 w580 h325", ["Hotkeys", "Hotstrings", "Wiki Shortcuts"])

    ; === HOTKEYS TAB ===
    MyTab.UseTab(1)
    global LV_Hotkeys := MyGui.Add("ListView", "x20 y70 w560 h285 +VScroll", ["Category", "Hotkey", "Description"])
    LV_Hotkeys.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Hotkeys, LV_Hotkeys.GetNext()))

    ; === HOTSTRINGS TAB ===
    MyTab.UseTab(2)
    global LV_Hotstrings := MyGui.Add("ListView", "x20 y70 w560 h285 +VScroll", ["Category", "Hotstring", "Description"])
    LV_Hotstrings.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Hotstrings, LV_Hotstrings.GetNext()))

    ; === WIKI SHORTCUTS TAB ===
    MyTab.UseTab(3)
    global LV_Wiki := MyGui.Add("ListView", "x20 y70 w560 h285 +VScroll", ["Category", "Shortcut", "Description"])
    LV_Wiki.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Wiki, LV_Wiki.GetNext()))

    MyTab.UseTab()  ; Subsequent controls will not belong to the tab control

    ; Set up GUI resize event
    MyGui.OnEvent("Size", GuiResize)

    ; Show the GUI
    MyGui.Show("w600 h400")

    ; Populate all ListViews (without auto-sizing yet)
    LV_Hotkeys.Opt("-Redraw")
    LV_Hotkeys.Delete()
    for category in hotkeyCategories {
        for currentHotkey in category.hotkeys {
            LV_Hotkeys.Add(, category.name, currentHotkey.hotkey, currentHotkey.description)
        }
    }
    LV_Hotkeys.Opt("+Redraw")

    LV_Hotstrings.Opt("-Redraw")
    LV_Hotstrings.Delete()
    for category in hotstringCategories {
        for currentHotstring in category.hotstrings {
            LV_Hotstrings.Add(, category.name, currentHotstring.hotstring, currentHotstring.description)
        }
    }
    LV_Hotstrings.Opt("+Redraw")

    LV_Wiki.Opt("-Redraw")
    LV_Wiki.Delete()
    for category in wikiCategories {
        for currentShortcut in category.shortcuts {
            LV_Wiki.Add(, category.name, currentShortcut.shortcut, currentShortcut.description)
        }
    }
    LV_Wiki.Opt("+Redraw")

    ; Give Windows time to process the window creation
    Sleep(50)

    ; Cycle through tabs slowly to force rendering
    MyTab.Choose(2)
    Sleep(20)
    MyTab.Choose(3)
    Sleep(20)
    MyTab.Choose(1)
    Sleep(20)

    ; Now resize and auto-size columns
    GuiResize()
}

GuiResize(*) {
    global MyGui, searchBox, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki
    
    if (!IsSet(MyGui) || !MyGui.Hwnd)
        return
        
    ; Get the current GUI size
    MyGui.GetPos(, , &w, &h)
    
    ; Resize search box to span width minus margins
    searchBox.Move(10, 10, w - 20, 23)
    
    ; Resize Tab control
    MyTab.Move(10, 40, w - 20, h - 75)
    
    ; Resize ListViews within tabs
    LV_Hotkeys.Move(20, 70, w - 40, h - 115)
    LV_Hotstrings.Move(20, 70, w - 40, h - 115)
    LV_Wiki.Move(20, 70, w - 40, h - 115)
    
    ; Auto-size columns for all ListViews
    AutoSizeColumns(LV_Hotkeys)
    AutoSizeColumns(LV_Hotstrings)
    AutoSizeColumns(LV_Wiki)
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
        FilterAllLists()  ; Reset all list views when the search box is empty
    }
}

FilterAllLists() {
    searchTerm := Trim(searchBox.Value)
    if (searchTerm == "Search..." or searchTerm == "") {
        PopulateHotkeyListView(LV_Hotkeys)
        PopulateHotstringListView(LV_Hotstrings)
        PopulateWikiListView(LV_Wiki)
        return
    }

    searchTermLower := StrLower(searchTerm)

    ; Filter Hotkeys
    LV_Hotkeys.Opt("-Redraw")
    LV_Hotkeys.Delete()
    for category in hotkeyCategories {
        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
        for currentHotkey in category.hotkeys {
            if (categoryMatched or 
                InStr(StrLower(currentHotkey.hotkey), searchTermLower) > 0 or 
                InStr(StrLower(currentHotkey.description), searchTermLower) > 0) {
                LV_Hotkeys.Add(, category.name, currentHotkey.hotkey, currentHotkey.description)
            }
        }
    }
    LV_Hotkeys.Opt("+Redraw")
    AutoSizeColumns(LV_Hotkeys)

    ; Filter Hotstrings
    LV_Hotstrings.Opt("-Redraw")
    LV_Hotstrings.Delete()
    for category in hotstringCategories {
        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
        for currentHotstring in category.hotstrings {
            if (categoryMatched or 
                InStr(StrLower(currentHotstring.hotstring), searchTermLower) > 0 or 
                InStr(StrLower(currentHotstring.description), searchTermLower) > 0) {
                LV_Hotstrings.Add(, category.name, currentHotstring.hotstring, currentHotstring.description)
            }
        }
    }
    LV_Hotstrings.Opt("+Redraw")
    AutoSizeColumns(LV_Hotstrings)

    ; Filter Wiki Shortcuts
    LV_Wiki.Opt("-Redraw")
    LV_Wiki.Delete()
    for category in wikiCategories {
        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
        for currentShortcut in category.shortcuts {
            if (categoryMatched or 
                InStr(StrLower(currentShortcut.shortcut), searchTermLower) > 0 or 
                InStr(StrLower(currentShortcut.description), searchTermLower) > 0) {
                LV_Wiki.Add(, category.name, currentShortcut.shortcut, currentShortcut.description)
            }
        }
    }
    LV_Wiki.Opt("+Redraw")
    AutoSizeColumns(LV_Wiki)
}

PopulateHotkeyListView(LV) {
    LV.Opt("-Redraw")
    LV.Delete()
    for category in hotkeyCategories {
        for currentHotkey in category.hotkeys {
            LV.Add(, category.name, currentHotkey.hotkey, currentHotkey.description)
        }
    }
    LV.Opt("+Redraw")
    AutoSizeColumns(LV)
}

PopulateHotstringListView(LV) {
    LV.Opt("-Redraw")
    LV.Delete()
    for category in hotstringCategories {
        for currentHotstring in category.hotstrings {
            LV.Add(, category.name, currentHotstring.hotstring, currentHotstring.description)
        }
    }
    LV.Opt("+Redraw")
    AutoSizeColumns(LV)
}

PopulateWikiListView(LV) {
    LV.Opt("-Redraw")
    LV.Delete()
    for category in wikiCategories {
        for currentShortcut in category.shortcuts {
            LV.Add(, category.name, currentShortcut.shortcut, currentShortcut.description)
        }
    }
    LV.Opt("+Redraw")
    AutoSizeColumns(LV)
}

LV_DoubleClick(LV, RowNumber) {
    if (RowNumber > 0) {
        selectedItem := LV.GetText(RowNumber, 2)  ; Get the hotkey/hotstring from the second column
        A_Clipboard := selectedItem
        ToolTip("Copied to clipboard: " . selectedItem)
        SetTimer(() => ToolTip(), -2000)  ; Remove tooltip after 2 seconds
    }
}

; Optional: Add hotkey to close the GUI
^!Escape:: {
    if (IsSet(MyGui) && MyGui.Hwnd) {
        MyGui.Destroy()
    }
}