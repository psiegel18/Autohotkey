#Requires AutoHotkey v2.0

; Define Globals
global hotkeyCategories
global hotstringCategories
global wikiCategories
global LV_Hotkeys
global LV_Hotstrings
global LV_Wiki
global LV_Favorites
global MyGui
global searchBox
global clearBtn
global MyTab
global statusBar
global favoritesList := []
global lastSortCol := Map()
global sortDirection := Map()
global tabsPopulated := Map()  ; Track which tabs have been populated

; Define the hotkey for displaying the GUI
^!Space:: ShowHotkeyGUI()

; Add Ctrl+F to focus search when GUI is active
#HotIf WinActive("Hotkey & Hotstring Reference")
^f:: {
    if (IsSet(MyGui) && MyGui.Hwnd) {
        WinActivate("ahk_id " . MyGui.Hwnd)
        searchBox.Focus()
        if (searchBox.Value == "Search...")
            searchBox.Value := ""
    }
}
#HotIf

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
    {name: "Typos", hotstrings: [
        {hotstring: "teh", description: "the"},
        {hotstring: "recieve", description: "receive"},
        {hotstring: "seperate", description: "separate"},
        {hotstring: "definately", description: "definitely"},
        {hotstring: "defualt", description: "default"}
    ]},
    {name: "Emoticons - Basic", hotstrings: [
        {hotstring: ".shrug", description: "¯\\_(ツ)_/¯"},
        {hotstring: ".tbl", description: "(╯°□°)╯︵ ┻━┻"},
        {hotstring: ".puttbl", description: "┬─┬ノ( º _ ºノ)"},
        {hotstring: ".lenny", description: "( ͡° ͜ʖ ͡°)"},
        {hotstring: ".disapprove", description: "ಠ_ಠ"},
        {hotstring: ".happy", description: "ヽ(^▽^)/"},
        {hotstring: ".sparkle", description: "(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"},
        {hotstring: ".dead", description: "x_x"},
        {hotstring: ".cute", description: "(｡◕‿◕｡)"},
        {hotstring: ".bear", description: "ʕ•ᴥ•ʔ"},
        {hotstring: ".music", description: "♪┏(･o･)┛♪"},
        {hotstring: ".excited", description: "\\(^o^)/"},
        {hotstring: ".thinking", description: "(¬‿¬)"},
        {hotstring: ".love", description: "(♥‿♥)"},
        {hotstring: ".dealwithit", description: "(⌐■_■)"}
    ]},
    {name: "Emoticons - Reactions", hotstrings: [
        {hotstring: ".cry", description: "(╥﹏╥)"},
        {hotstring: ".tears", description: "(T_T)"},
        {hotstring: ".sad", description: "(◕︵◕)"},
        {hotstring: ".sob", description: "。゜゜(´O``°)゜"},
        {hotstring: ".depressed", description: "(︶︹︶)"},
        {hotstring: ".angry", description: "(ಠ益ಠ)"},
        {hotstring: ".rage", description: "(╬ ಠ益ಠ)"},
        {hotstring: ".mad", description: "ಠ_ಠ凸"},
        {hotstring: ".annoyed", description: "(¬_¬)"},
        {hotstring: ".facepalm", description: "(－‸ლ)"},
        {hotstring: ".shock", description: "(⊙_⊙)"},
        {hotstring: ".surprised", description: "Σ(ﾟДﾟ)"},
        {hotstring: ".ohno", description: "(⊙＿⊙')"},
        {hotstring: ".gasp", description: "(๑•̀ㅂ•́)و✧"},
        {hotstring: ".confused", description: "(・_・?)"},
        {hotstring: ".worry", description: "(･_･;)"},
        {hotstring: ".nervous", description: "(◕﹏◕)"},
        {hotstring: ".awkward", description: "(ᵕ—ᴗ—)"}
    ]},
    {name: "Emoticons - Happy", hotstrings: [
        {hotstring: ".yay", description: "\\(★ω★)/"},
        {hotstring: ".celebrate", description: "٩(◕‿◕｡)۶"},
        {hotstring: ".party", description: "[̲̅$̲̅(̲̅ ͡° ͜ʖ ͡°)̲̅$̲̅]"},
        {hotstring: ".dance", description: "♪┏(・o･)┛♪┗ ( ･o･) ┓♪"},
        {hotstring: ".headbang", description: "(╯°□°）╯♪"},
        {hotstring: ".cool", description: "(•_•) ( •_•)>⌐■-■ (⌐■_■)"},
        {hotstring: ".smug", description: "(¬‿¬)"},
        {hotstring: ".wink", description: "(^_~)"},
        {hotstring: ".pleased", description: "(◕‿◕)"},
        {hotstring: ".wave", description: "(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"},
        {hotstring: ".hello", description: "(•‿•)"},
        {hotstring: ".bye", description: "ヾ(＾-＾)ノ"},
        {hotstring: ".salute", description: "(￣^￣)ゞ"}
    ]},
    {name: "Emoticons - Love", hotstrings: [
        {hotstring: ".hearts", description: "(♥ω♥*)"},
        {hotstring: ".blush", description: "(⁄ ⁄>⁄ ▽ ⁄<⁄ ⁄)"},
        {hotstring: ".kiss", description: "(づ￣ ³￣)づ"},
        {hotstring: ".hug", description: "⊂(◉‿◉)つ"},
        {hotstring: ".aww", description: "(｡♥‿♥｡)"}
    ]},
    {name: "Emoticons - Actions", hotstrings: [
        {hotstring: ".fight", description: "(ง'̀-'́)ง"},
        {hotstring: ".punch", description: "O=('-'Q)"},
        {hotstring: ".sword", description: "(ﾉಠ_ಠ)ﾉ ┫：・'.::・┻┻：・'.::・"},
        {hotstring: ".gun", description: "̿̿ ̿̿ ̿̿ ̿'̿'̵͇̿̿\\з= ( ▀ ͜͞ʖ▀) =ε/̵͇̿̿/'̿'̿ ̿ ̿̿ ̿̿ ̿̿"},
        {hotstring: ".flip", description: "(-_- )ﾉ⌒┫ ┻ ┣ ┳☆(x_x)"},
        {hotstring: ".magic", description: "*｡ﾟ(´д``｡｡)ﾟ｡*"},
        {hotstring: ".shrug2", description: "¯\\(°_o)/¯"},
        {hotstring: ".dunno", description: "¯\\_(ツ)_/¯"}
    ]},
    {name: "Emoticons - Animals", hotstrings: [
        {hotstring: ".cat", description: "(=^･ω･^=)"},
        {hotstring: ".dog", description: "U ´ᴥ`` U"},
        {hotstring: ".bunny", description: "(・×・)"},
        {hotstring: ".bird", description: "( ˘▽˘)っ♨"},
        {hotstring: ".pig", description: "( ´(00)``｀)"},
        {hotstring: ".owl", description: "{◕ ◡ ◕}"}
    ]},
    {name: "Emoticons - Misc", hotstrings: [
        {hotstring: ".sleep", description: "(-_-)zzz"},
        {hotstring: ".tired", description: "(=_=)"},
        {hotstring: ".yawn", description: "(´～``｀)"},
        {hotstring: ".nom", description: "(っ˘ڡ˘ς)"},
        {hotstring: ".tea", description: "( ͡° ͜ʖ ͡°)_旦~~"},
        {hotstring: ".coffee", description: "c[_]"},
        {hotstring: ".evil", description: "(•̀ᴗ•́)و ̑̑"},
        {hotstring: ".mischief", description: "(¬‿¬ )"},
        {hotstring: ".plotting", description: "(⊙ω⊙)"},
        {hotstring: ".derp", description: "(づ｡◕‿‿◕｡)づ"},
        {hotstring: ".nyan", description: "~=[,,_,,]:3"},
        {hotstring: ".kirby", description: "('▽')/"},
        {hotstring: ".doge", description: "▼・ᴥ・▼"},
        {hotstring: ".penguin", description: "<(°^°<)"}
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
    global MyGui := Gui("+Resize +MinSize600x560", "Hotkey & Hotstring Reference")
    
    ; Set background color for a more modern look
    MyGui.BackColor := "0xF0F0F0"

    ; Add a search box with placeholder text
    global searchBox := MyGui.Add("Edit", "vSearchTerm x10 y10 w515 h23", "Search...")
    searchBox.OnEvent("Focus", (*) => OnSearchFocus(searchBox))
    searchBox.OnEvent("LoseFocus", (*) => OnSearchLoseFocus(searchBox))
    searchBox.OnEvent("Change", (*) => FilterAllLists())

    ; Add clear button
    global clearBtn := MyGui.Add("Button", "x530 y10 w60 h23", "Clear")
    clearBtn.OnEvent("Click", (*) => ClearSearch())

    ; Add Tab control with Favorites tab (ends at y460 to leave room for buttons at y470)
    global MyTab := MyGui.Add("Tab3", "x10 y40 w580 h418", ["Hotkeys", "Hotstrings", "Wiki Shortcuts", "⭐ Favorites"])
    MyTab.OnEvent("Change", OnTabChange)  ; Add event for tab switching

    ; === HOTKEYS TAB ===
    MyTab.UseTab(1)
    global LV_Hotkeys := MyGui.Add("ListView", "x20 y70 w560 h378 +VScroll +Grid", ["Category", "Hotkey", "Description"])
    LV_Hotkeys.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Hotkeys, LV_Hotkeys.GetNext(), "Hotkeys"))
    LV_Hotkeys.OnEvent("ContextMenu", ShowContextMenu)
    LV_Hotkeys.OnEvent("ColClick", SortListView)
    ; Set initial column widths
    LV_Hotkeys.ModifyCol(1, 110)
    LV_Hotkeys.ModifyCol(2, 170)
    LV_Hotkeys.ModifyCol(3, 260)

    ; === HOTSTRINGS TAB ===
    MyTab.UseTab(2)
    global LV_Hotstrings := MyGui.Add("ListView", "x20 y70 w560 h378 +VScroll +Grid", ["Category", "Hotstring", "Description"])
    LV_Hotstrings.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Hotstrings, LV_Hotstrings.GetNext(), "Hotstrings"))
    LV_Hotstrings.OnEvent("ContextMenu", ShowContextMenu)
    LV_Hotstrings.OnEvent("ColClick", SortListView)
    ; Set initial column widths
    LV_Hotstrings.ModifyCol(1, 110)
    LV_Hotstrings.ModifyCol(2, 170)
    LV_Hotstrings.ModifyCol(3, 260)

    ; === WIKI SHORTCUTS TAB ===
    MyTab.UseTab(3)
    global LV_Wiki := MyGui.Add("ListView", "x20 y70 w560 h378 +VScroll +Grid", ["Category", "Shortcut", "Description"])
    LV_Wiki.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Wiki, LV_Wiki.GetNext(), "Wiki"))
    LV_Wiki.OnEvent("ContextMenu", ShowContextMenu)
    LV_Wiki.OnEvent("ColClick", SortListView)
    ; Set initial column widths
    LV_Wiki.ModifyCol(1, 110)
    LV_Wiki.ModifyCol(2, 170)
    LV_Wiki.ModifyCol(3, 260)

    ; === FAVORITES TAB ===
    MyTab.UseTab(4)
    global LV_Favorites := MyGui.Add("ListView", "x20 y70 w560 h378 +VScroll +Grid", ["Type", "Item", "Description"])
    LV_Favorites.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Favorites, LV_Favorites.GetNext(), "Favorites"))
    LV_Favorites.OnEvent("ContextMenu", ShowFavoritesContextMenu)
    LV_Favorites.OnEvent("ColClick", SortListView)
    ; Set initial column widths
    LV_Favorites.ModifyCol(1, 110)
    LV_Favorites.ModifyCol(2, 170)
    LV_Favorites.ModifyCol(3, 260)

    MyTab.UseTab()  ; Subsequent controls will not belong to the tab control

    ; Add quick action buttons (positioned well above status bar with large margin)
    btnY := 470
    global copyBtn := MyGui.Add("Button", "x10 y" . btnY . " w100 h30", "Copy Selected")
    copyBtn.OnEvent("Click", (*) => CopyCurrentSelection())

    global exportBtn := MyGui.Add("Button", "x120 y" . btnY . " w100 h30", "Export All")
    exportBtn.OnEvent("Click", (*) => ExportToFile())

    global helpBtn := MyGui.Add("Button", "x230 y" . btnY . " w100 h30", "Help")
    helpBtn.OnEvent("Click", (*) => ShowHelp())

    global clearFavBtn := MyGui.Add("Button", "x340 y" . btnY . " w130 h30", "Clear Favorites")
    clearFavBtn.OnEvent("Click", (*) => ClearAllFavorites())

    ; Add status bar
    global statusBar := MyGui.Add("StatusBar")
    statusBar.SetText("Ready | Press Ctrl+F to search, Enter to copy, Esc to close")

    ; Set up GUI resize event
    MyGui.OnEvent("Size", GuiResize)
    MyGui.OnEvent("Escape", (*) => MyGui.Destroy())
    MyGui.OnEvent("Close", (*) => MyGui.Destroy())

    ; Initialize sort tracking
    lastSortCol["LV_Hotkeys"] := 0
    lastSortCol["LV_Hotstrings"] := 0
    lastSortCol["LV_Wiki"] := 0
    lastSortCol["LV_Favorites"] := 0
    sortDirection["LV_Hotkeys"] := 1
    sortDirection["LV_Hotstrings"] := 1
    sortDirection["LV_Wiki"] := 1
    sortDirection["LV_Favorites"] := 1

    ; Initialize tab population tracking
    tabsPopulated[1] := false
    tabsPopulated[2] := false
    tabsPopulated[3] := false
    tabsPopulated[4] := false

    ; Load favorites data first (but don't populate the ListView yet)
    LoadFavorites()
    
    ; Only populate the first tab initially (lazy loading for performance)
    PopulateHotkeyListView(LV_Hotkeys)
    tabsPopulated[1] := true
    
    ; Switch to first tab
    MyTab.Choose(1)
    
    ; NOW show the GUI
    MyGui.Show("w600 h560")
    
    ; Update status bar
    UpdateStatusBar()
}

GuiResize(*) {
    global MyGui, searchBox, clearBtn, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites
    global copyBtn, exportBtn, helpBtn, clearFavBtn, statusBar
    
    if (!IsSet(MyGui) || !MyGui.Hwnd)
        return
        
    ; Get the current GUI size
    MyGui.GetPos(, , &w, &h)
    
    ; Resize search box to span width minus clear button and margins (fixed cutoff)
    searchBox.Move(10, 10, w - 85, 23)
    clearBtn.Move(w - 70, 10, 60, 23)
    
    ; Fixed dimensions - increased margins to prevent overlap
    statusBarHeight := 22  ; Actual status bar height
    buttonHeight := 30
    buttonMargin := 35  ; Increased margin between buttons and status bar
    
    ; Calculate tab height - leave plenty of room at bottom for buttons and status bar
    bottomReserved := statusBarHeight + buttonHeight + buttonMargin
    tabHeight := h - 40 - bottomReserved - 10  ; 40 for search area, 10 for spacing
    MyTab.Move(10, 40, w - 20, tabHeight)
    
    ; Resize ListViews within tabs (they start at y70, which is 30px below tab start)
    lvHeight := tabHeight - 30
    LV_Hotkeys.Move(20, 70, w - 40, lvHeight)
    LV_Hotstrings.Move(20, 70, w - 40, lvHeight)
    LV_Wiki.Move(20, 70, w - 40, lvHeight)
    LV_Favorites.Move(20, 70, w - 40, lvHeight)
    
    ; Position buttons well above status bar with large margin
    btnY := h - statusBarHeight - buttonHeight - buttonMargin
    copyBtn.Move(10, btnY, 100, buttonHeight)
    exportBtn.Move(120, btnY, 100, buttonHeight)
    helpBtn.Move(230, btnY, 100, buttonHeight)
    clearFavBtn.Move(340, btnY, 130, buttonHeight)
    
    ; Auto-size columns for all ListViews
    AutoSizeColumns(LV_Hotkeys)
    AutoSizeColumns(LV_Hotstrings)
    AutoSizeColumns(LV_Wiki)
    AutoSizeColumns(LV_Favorites)
}

AutoSizeColumns(LV) {
    ; Get ListView width
    LV.GetPos(, , &lvWidth, )
    
    ; Calculate column widths (accounting for scrollbar and grid lines)
    totalWidth := lvWidth - 30  ; Reserve space for scrollbar and grid
    
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

OnTabChange(*) {
    global MyTab, tabsPopulated, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites
    
    ; Get current tab
    currentTab := MyTab.Value
    
    ; Only populate if not already populated
    if (!tabsPopulated[currentTab]) {
        switch currentTab {
            case 1:
                PopulateHotkeyListView(LV_Hotkeys)
            case 2:
                PopulateHotstringListView(LV_Hotstrings)
            case 3:
                PopulateWikiListView(LV_Wiki)
            case 4:
                PopulateFavoritesListView()
        }
        tabsPopulated[currentTab] := true
    }
    
    UpdateStatusBar()
}

OnSearchLoseFocus(searchBox) {
    if (searchBox.Value == "") {
        searchBox.Value := "Search..."
        FilterAllLists()  ; Reset all list views when the search box is empty
    }
}

ClearSearch() {
    searchBox.Value := ""
    searchBox.Focus()
    FilterAllLists()
}

FilterAllLists() {
    global tabsPopulated
    
    searchTerm := Trim(searchBox.Value)
    if (searchTerm == "Search..." or searchTerm == "") {
        ; Reset to lazy loading - clear populated flags
        tabsPopulated[1] := false
        tabsPopulated[2] := false
        tabsPopulated[3] := false
        tabsPopulated[4] := false
        
        ; Only populate the current tab
        currentTab := MyTab.Value
        switch currentTab {
            case 1:
                PopulateHotkeyListView(LV_Hotkeys)
            case 2:
                PopulateHotstringListView(LV_Hotstrings)
            case 3:
                PopulateWikiListView(LV_Wiki)
            case 4:
                PopulateFavoritesListView()
        }
        tabsPopulated[currentTab] := true
        
        UpdateStatusBar()
        return
    }

    searchTermLower := StrLower(searchTerm)

    ; Filter Hotkeys
    LV_Hotkeys.Opt("-Redraw")
    LV_Hotkeys.Delete()
    hotkeyCount := 0
    for category in hotkeyCategories {
        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
        for currentHotkey in category.hotkeys {
            if (categoryMatched or 
                InStr(StrLower(currentHotkey.hotkey), searchTermLower) > 0 or 
                InStr(StrLower(currentHotkey.description), searchTermLower) > 0) {
                LV_Hotkeys.Add(, category.name, currentHotkey.hotkey, currentHotkey.description)
                hotkeyCount++
            }
        }
    }
    LV_Hotkeys.Opt("+Redraw")

    ; Filter Hotstrings
    LV_Hotstrings.Opt("-Redraw")
    LV_Hotstrings.Delete()
    hotstringCount := 0
    for category in hotstringCategories {
        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
        for currentHotstring in category.hotstrings {
            if (categoryMatched or 
                InStr(StrLower(currentHotstring.hotstring), searchTermLower) > 0 or 
                InStr(StrLower(currentHotstring.description), searchTermLower) > 0) {
                LV_Hotstrings.Add(, category.name, currentHotstring.hotstring, currentHotstring.description)
                hotstringCount++
            }
        }
    }
    LV_Hotstrings.Opt("+Redraw")

    ; Filter Wiki Shortcuts
    LV_Wiki.Opt("-Redraw")
    LV_Wiki.Delete()
    wikiCount := 0
    for category in wikiCategories {
        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
        for currentShortcut in category.shortcuts {
            if (categoryMatched or 
                InStr(StrLower(currentShortcut.shortcut), searchTermLower) > 0 or 
                InStr(StrLower(currentShortcut.description), searchTermLower) > 0) {
                LV_Wiki.Add(, category.name, currentShortcut.shortcut, currentShortcut.description)
                wikiCount++
            }
        }
    }
    LV_Wiki.Opt("+Redraw")

    ; Filter Favorites
    LV_Favorites.Opt("-Redraw")
    LV_Favorites.Delete()
    favCount := 0
    for fav in favoritesList {
        if (InStr(StrLower(fav.type), searchTermLower) > 0 or 
            InStr(StrLower(fav.item), searchTermLower) > 0 or 
            InStr(StrLower(fav.desc), searchTermLower) > 0) {
            LV_Favorites.Add(, fav.type, fav.item, fav.desc)
            favCount++
        }
    }
    LV_Favorites.Opt("+Redraw")
    
    ; Mark all tabs as populated after filtering
    tabsPopulated[1] := true
    tabsPopulated[2] := true
    tabsPopulated[3] := true
    tabsPopulated[4] := true

    ; Update status
    totalResults := hotkeyCount + hotstringCount + wikiCount + favCount
    statusBar.SetText("Found " . totalResults . " results | Hotkeys: " . hotkeyCount . " | Hotstrings: " . hotstringCount . " | Wiki: " . wikiCount . " | Favorites: " . favCount)
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
}

PopulateFavoritesListView() {
    LV_Favorites.Opt("-Redraw")
    LV_Favorites.Delete()
    for fav in favoritesList {
        LV_Favorites.Add(, fav.type, fav.item, fav.desc)
    }
    LV_Favorites.Opt("+Redraw")
}

CountAllItems() {
    count := 0
    for category in hotkeyCategories {
        count += category.hotkeys.Length
    }
    for category in hotstringCategories {
        count += category.hotstrings.Length
    }
    for category in wikiCategories {
        count += category.shortcuts.Length
    }
    return count
}

UpdateStatusBar() {
    global tabsPopulated
    
    ; Get counts - if tab not populated, count from data arrays
    hotkeyCount := tabsPopulated[1] ? LV_Hotkeys.GetCount() : CountHotkeys()
    hotstringCount := tabsPopulated[2] ? LV_Hotstrings.GetCount() : CountHotstrings()
    wikiCount := tabsPopulated[3] ? LV_Wiki.GetCount() : CountWikiShortcuts()
    favCount := favoritesList.Length
    
    searchTerm := Trim(searchBox.Value)
    if (searchTerm != "" && searchTerm != "Search...") {
        totalResults := hotkeyCount + hotstringCount + wikiCount + favCount
        statusBar.SetText("Found " . totalResults . " results | Hotkeys: " . hotkeyCount . " | Hotstrings: " . hotstringCount . " | Wiki: " . wikiCount . " | Favorites: " . favCount)
    } else {
        totalItems := CountAllItems()
        statusBar.SetText("Ready | Total: " . totalItems . " items (Hotkeys: " . hotkeyCount . " | Hotstrings: " . hotstringCount . " | Wiki: " . wikiCount . " | Favorites: " . favCount . ") | Press Ctrl+F to search")
    }
}

CountHotkeys() {
    count := 0
    for category in hotkeyCategories {
        count += category.hotkeys.Length
    }
    return count
}

CountHotstrings() {
    count := 0
    for category in hotstringCategories {
        count += category.hotstrings.Length
    }
    return count
}

CountWikiShortcuts() {
    count := 0
    for category in wikiCategories {
        count += category.shortcuts.Length
    }
    return count
}

LV_DoubleClick(LV, RowNumber, TabType) {
    if (RowNumber > 0) {
        selectedItem := LV.GetText(RowNumber, 2)  ; Get the hotkey/hotstring from the second column
        A_Clipboard := selectedItem
        
        ; Highlight the selected row
        LV.Modify(RowNumber, "Select Focus Vis")
        
        ; Show visual feedback
        ShowCopyNotification(selectedItem)
        
        ; Update status bar
        statusBar.SetText("✓ Copied: " . selectedItem)
        SetTimer(() => UpdateStatusBar(), -3000)
    }
}

ShowCopyNotification(text) {
    ; Create a small toast notification
    notifyGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Notification")
    notifyGui.BackColor := "0x90EE90"
    notifyGui.SetFont("s10", "Segoe UI")
    
    ; Truncate text if too long
    displayText := (StrLen(text) > 50) ? SubStr(text, 1, 47) . "..." : text
    notifyGui.Add("Text", "c0x000000 x15 y10 w300", "✓ Copied: " . displayText)
    
    ; Position in bottom-right of screen
    notifyGui.Show("NoActivate x" . (A_ScreenWidth - 350) . " y" . (A_ScreenHeight - 100) . " w330 h40")
    
    ; Auto-close after 2 seconds
    SetTimer(() => notifyGui.Destroy(), -2000)
}

ShowContextMenu(LV, Item, IsRightClick, X, Y) {
    if (Item > 0) {
        contextMenu := Menu()
        contextMenu.Add("Copy Item", (*) => LV_DoubleClick(LV, Item, ""))
        contextMenu.Add("Copy Description", (*) => CopyDescription(LV, Item))
        contextMenu.Add()
        
        ; Check if already favorited
        itemText := LV.GetText(Item, 2)
        isFavorited := IsFavorite(itemText)
        
        if (isFavorited) {
            contextMenu.Add("Remove from Favorites", (*) => RemoveFavorite(LV, Item))
        } else {
            contextMenu.Add("⭐ Add to Favorites", (*) => MarkFavorite(LV, Item))
        }
        
        contextMenu.Show(X, Y)
    }
}

ShowFavoritesContextMenu(LV, Item, IsRightClick, X, Y) {
    if (Item > 0) {
        contextMenu := Menu()
        contextMenu.Add("Copy Item", (*) => LV_DoubleClick(LV, Item, "Favorites"))
        contextMenu.Add("Copy Description", (*) => CopyDescription(LV, Item))
        contextMenu.Add()
        contextMenu.Add("Remove from Favorites", (*) => RemoveFavoriteByRow(Item))
        contextMenu.Show(X, Y)
    }
}

CopyDescription(LV, RowNumber) {
    description := LV.GetText(RowNumber, 3)
    A_Clipboard := description
    ShowCopyNotification(description)
    statusBar.SetText("✓ Copied description: " . description)
    SetTimer(() => UpdateStatusBar(), -3000)
}

IsFavorite(itemText) {
    for fav in favoritesList {
        if (fav.item == itemText) {
            return true
        }
    }
    return false
}

MarkFavorite(LV, RowNumber) {
    global tabsPopulated
    
    category := LV.GetText(RowNumber, 1)
    item := LV.GetText(RowNumber, 2)
    description := LV.GetText(RowNumber, 3)
    
    ; Check if already favorited
    if (IsFavorite(item)) {
        MsgBox("This item is already in your favorites!", "Already Favorited", 64)
        return
    }
    
    ; Determine type based on which ListView
    tabIndex := MyTab.Value
    tabType := (tabIndex = 1) ? "Hotkey" : (tabIndex = 2) ? "Hotstring" : "Wiki"
    
    favoritesList.Push({type: tabType, item: item, desc: description})
    SaveFavorites()
    
    ; Mark Favorites tab as needing repopulation
    tabsPopulated[4] := false
    if (MyTab.Value = 4) {
        PopulateFavoritesListView()
        tabsPopulated[4] := true
    }
    
    UpdateStatusBar()
    
    statusBar.SetText("⭐ Added to favorites: " . item)
    SetTimer(() => UpdateStatusBar(), -3000)
}

RemoveFavorite(LV, RowNumber) {
    global tabsPopulated
    
    item := LV.GetText(RowNumber, 2)
    
    for index, fav in favoritesList {
        if (fav.item == item) {
            favoritesList.RemoveAt(index)
            SaveFavorites()
            
            ; Mark Favorites tab as needing repopulation
            tabsPopulated[4] := false
            if (MyTab.Value = 4) {
                PopulateFavoritesListView()
                tabsPopulated[4] := true
            }
            
            UpdateStatusBar()
            statusBar.SetText("Removed from favorites: " . item)
            SetTimer(() => UpdateStatusBar(), -3000)
            return
        }
    }
}

RemoveFavoriteByRow(RowNumber) {
    global tabsPopulated
    
    if (RowNumber > 0 && RowNumber <= favoritesList.Length) {
        item := favoritesList[RowNumber].item
        favoritesList.RemoveAt(RowNumber)
        SaveFavorites()
        
        ; Mark Favorites tab as needing repopulation
        tabsPopulated[4] := false
        if (MyTab.Value = 4) {
            PopulateFavoritesListView()
            tabsPopulated[4] := true
        }
        
        UpdateStatusBar()
        statusBar.SetText("Removed from favorites: " . item)
        SetTimer(() => UpdateStatusBar(), -3000)
    }
}

ClearAllFavorites() {
    global tabsPopulated
    
    if (favoritesList.Length > 0) {
        result := MsgBox("Are you sure you want to clear all favorites?", "Clear Favorites", 4 + 32)
        if (result = "Yes") {
            favoritesList := []
            SaveFavorites()
            
            ; Mark Favorites tab as needing repopulation
            tabsPopulated[4] := false
            if (MyTab.Value = 4) {
                PopulateFavoritesListView()
                tabsPopulated[4] := true
            }
            
            UpdateStatusBar()
            statusBar.SetText("All favorites cleared")
            SetTimer(() => UpdateStatusBar(), -3000)
        }
    } else {
        MsgBox("No favorites to clear!", "Clear Favorites", 64)
    }
}

SaveFavorites() {
    ; Get the directory of THIS file (not the main script)
    SplitPath(A_LineFile,, &guiDir)
    favFile := guiDir . "\favorites.txt"
    fileContent := ""
    
    for fav in favoritesList {
        fileContent .= fav.type . "|" . fav.item . "|" . fav.desc . "`n"
    }
    
    try {
        FileDelete(favFile)
    }
    
    if (fileContent != "") {
        FileAppend(fileContent, favFile)
    }
}

; GUI Hotkeys - These work when the GUI is active
#HotIf WinActive("Hotkey & Hotstring Reference")

Enter:: {
    global MyGui, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites
    
    ; Safety check
    if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
        return
    
    try {
        currentTab := MyTab.Value
        LV := (currentTab = 1) ? LV_Hotkeys : (currentTab = 2) ? LV_Hotstrings : (currentTab = 3) ? LV_Wiki : LV_Favorites
        rowNumber := LV.GetNext()
        
        if (rowNumber > 0) {
            tabType := (currentTab = 1) ? "Hotkeys" : (currentTab = 2) ? "Hotstrings" : (currentTab = 3) ? "Wiki" : "Favorites"
            LV_DoubleClick(LV, rowNumber, tabType)
        }
    } catch as err {
        ; Silently handle any errors
    }
}

^c:: {
    global MyGui, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, searchBox
    
    ; Safety check
    if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
        return
    
    ; Check if search box has focus - if so, let normal Ctrl+C work
    try {
        focusedControl := ControlGetFocus("ahk_id " . MyGui.Hwnd)
        ; If search box is focused, don't intercept Ctrl+C
        if (InStr(focusedControl, "Edit"))
            return
    }
    
    try {
        currentTab := MyTab.Value
        LV := (currentTab = 1) ? LV_Hotkeys : (currentTab = 2) ? LV_Hotstrings : (currentTab = 3) ? LV_Wiki : LV_Favorites
        rowNumber := LV.GetNext()
        
        if (rowNumber > 0) {
            tabType := (currentTab = 1) ? "Hotkeys" : (currentTab = 2) ? "Hotstrings" : (currentTab = 3) ? "Wiki" : "Favorites"
            LV_DoubleClick(LV, rowNumber, tabType)
        }
    } catch as err {
        ; Silently handle any errors
    }
}

Delete:: {
    global MyGui, MyTab, LV_Favorites
    
    ; Safety check
    if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
        return
    
    try {
        ; Only works in Favorites tab
        if (MyTab.Value = 4) {
            rowNumber := LV_Favorites.GetNext()
            if (rowNumber > 0)
                RemoveFavoriteByRow(rowNumber)
        }
    } catch as err {
        ; Silently handle any errors
    }
}

#HotIf

LoadFavorites() {
    global favoritesList := []
    
    ; Get the directory of THIS file (not the main script)
    SplitPath(A_LineFile,, &guiDir)
    favFile := guiDir . "\favorites.txt"
    
    if (!FileExist(favFile))
        return
    
    fileContent := FileRead(favFile)
    Loop Parse, fileContent, "`n", "`r" {
        if (A_LoopField = "")
            continue
        
        parts := StrSplit(A_LoopField, "|")
        if (parts.Length = 3) {
            favoritesList.Push({type: parts[1], item: parts[2], desc: parts[3]})
        }
    }
}

SortListView(LV, ColNumber) {
    ; Get the control name to track sort state
    lvName := ""
    if (LV = LV_Hotkeys)
        lvName := "LV_Hotkeys"
    else if (LV = LV_Hotstrings)
        lvName := "LV_Hotstrings"
    else if (LV = LV_Wiki)
        lvName := "LV_Wiki"
    else if (LV = LV_Favorites)
        lvName := "LV_Favorites"
    
    if (lvName = "")
        return
    
    ; Toggle sort direction if clicking same column
    if (ColNumber = lastSortCol[lvName]) {
        sortDirection[lvName] := -sortDirection[lvName]
    } else {
        lastSortCol[lvName] := ColNumber
        sortDirection[lvName] := 1
    }
    
    ; Apply sort
    if (sortDirection[lvName] = 1)
        LV.ModifyCol(ColNumber, "Sort")
    else
        LV.ModifyCol(ColNumber, "SortDesc")
}

CopyCurrentSelection() {
    currentTab := MyTab.Value
    LV := (currentTab = 1) ? LV_Hotkeys : (currentTab = 2) ? LV_Hotstrings : (currentTab = 3) ? LV_Wiki : LV_Favorites
    rowNumber := LV.GetNext()
    
    if (rowNumber > 0) {
        tabType := (currentTab = 1) ? "Hotkeys" : (currentTab = 2) ? "Hotstrings" : (currentTab = 3) ? "Wiki" : "Favorites"
        LV_DoubleClick(LV, rowNumber, tabType)
    } else {
        MsgBox("No item selected!", "Copy Selected", 48)
    }
}

ExportToFile() {
    ; Get the directory of THIS file (not the main script)
    SplitPath(A_LineFile,, &guiDir)
    exportFile := guiDir . "\HotkeyReference_Export.txt"
    
    fileContent := "HOTKEY & HOTSTRING REFERENCE EXPORT`n"
    fileContent .= "Generated: " . FormatTime(, "yyyy-MM-dd HH:mm:ss") . "`n"
    fileContent .= "=" . StrReplace(Format("{:80s}", ""), " ", "=") . "`n`n"
    
    ; Export Hotkeys
    fileContent .= "HOTKEYS`n"
    fileContent .= "-" . StrReplace(Format("{:80s}", ""), " ", "-") . "`n"
    for category in hotkeyCategories {
        fileContent .= "`n[" . category.name . "]`n"
        for hk in category.hotkeys {
            fileContent .= "  " . Format("{:-30s}", hk.hotkey) . " - " . hk.description . "`n"
        }
    }
    
    ; Export Hotstrings
    fileContent .= "`n`nHOTSTRINGS`n"
    fileContent .= "-" . StrReplace(Format("{:80s}", ""), " ", "-") . "`n"
    for category in hotstringCategories {
        fileContent .= "`n[" . category.name . "]`n"
        for hs in category.hotstrings {
            fileContent .= "  " . Format("{:-30s}", hs.hotstring) . " - " . hs.description . "`n"
        }
    }
    
    ; Export Wiki Shortcuts
    fileContent .= "`n`nWIKI SHORTCUTS`n"
    fileContent .= "-" . StrReplace(Format("{:80s}", ""), " ", "-") . "`n"
    for category in wikiCategories {
        fileContent .= "`n[" . category.name . "]`n"
        for ws in category.shortcuts {
            fileContent .= "  " . Format("{:-30s}", ws.shortcut) . " - " . ws.description . "`n"
        }
    }
    
    ; Export Favorites
    if (favoritesList.Length > 0) {
        fileContent .= "`n`nFAVORITES`n"
        fileContent .= "-" . StrReplace(Format("{:80s}", ""), " ", "-") . "`n"
        for fav in favoritesList {
            fileContent .= "  [" . fav.type . "] " . Format("{:-25s}", fav.item) . " - " . fav.desc . "`n"
        }
    }
    
    try {
        FileDelete(exportFile)
        FileAppend(fileContent, exportFile)
        MsgBox("Export successful!`n`nFile saved to:`n" . exportFile, "Export Complete", 64)
        Run(exportFile)
    } catch as err {
        MsgBox("Export failed: " . err.Message, "Export Error", 16)
    }
}

ShowHelp() {
    helpText := "
    (
    HOTKEY & HOTSTRING REFERENCE - HELP
    
    KEYBOARD SHORTCUTS:
    • Ctrl+Alt+Space    Open this GUI
    • Ctrl+F            Focus search box
    • Enter             Copy selected item
    • Ctrl+C            Copy selected item
    • Delete            Remove from favorites (Favorites tab only)
    • Esc               Close GUI
    
    MOUSE ACTIONS:
    • Double-click      Copy item to clipboard
    • Right-click       Show context menu
    
    FEATURES:
    • Search across all categories in real-time
    • Click column headers to sort
    • Add frequently-used items to Favorites
    • Export all shortcuts to a text file
    
    FAVORITES:
    • Right-click any item and select "Add to Favorites"
    • Access favorites from the ⭐ Favorites tab
    • Remove items by right-clicking or pressing Delete
    • Favorites are saved between sessions
    
    TIPS:
    • Use the search box to quickly find what you need
    • Status bar shows counts and helpful information
    
    VERSION: Enhanced v2.2 (Optimized Performance)
    )"
    
    MsgBox(helpText, "Help - Hotkey Reference", 64)
}

; Optional: Add hotkey to close the GUI
^!Escape:: {
    if (IsSet(MyGui) && MyGui.Hwnd) {
        MyGui.Destroy()
    }
}