#Requires AutoHotkey v2.0

; ===========================
; GLOBAL VARIABLE DECLARATIONS
; ===========================

; Data structures
global hotkeyCategories
global hotstringCategories
global wikiCategories
global customTabs := []  ; User-created custom tabs
global favoritesList := []

; Tab metadata for customizing built-in tabs
global tabMetadata := {
    hotkeys: {name: "Hotkeys", icon: "📋", visible: true, order: 1},
    hotstrings: {name: "Hotstrings", icon: "💬", visible: true, order: 2},
    wiki: {name: "Wiki Shortcuts", icon: "📝", visible: true, order: 3},
    favorites: {name: "Favorites", icon: "⭐", visible: true, order: 999}
}

; GUI controls
global MyGui
global MyTab
global searchBox
global clearBtn
global statusBar

; ListView controls
global LV_Hotkeys
global LV_Hotstrings
global LV_Wiki
global LV_Favorites
global customLVs := Map()  ; Store custom tab ListViews

; Button controls
global copyBtn
global exportBtn
global settingsBtn
global helpBtn
global clearFavBtn

; State tracking
global lastSortCol := Map()
global sortDirection := Map()
global tabsPopulated := Map()

; *** NEW: Tab mapping system ***
global tabIndexMap := Map()  ; Maps tab index to {type: "builtin/custom", key: "hotkeys/hotstrings/wiki/favorites/customname"}

; ===========================
; DATA DEFINITIONS
; ===========================

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
        {hotkey: "Win+Alt+Ctrl+A", description: "340B Fit Call pptx"},   
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
        {hotkey: "Ctrl+Alt+v", description: "Paste List w Enter"},
        {hotkey: "Ctrl+Alt+Shift+v", description: "Paste List w Down"},
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
        {hotstring: ".shrug", description: "¯\_(ツ)_/¯"},
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
        {hotstring: ".excited", description: "\(^o^)/"},
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
        {hotstring: ".yay", description: "\(★ω★)/"},
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
        {hotstring: ".shrug2", description: "¯\(°_o)/¯"},
        {hotstring: ".dunno", description: "¯\_(ツ)_/¯"}
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

; ===========================
; INITIALIZATION
; ===========================

; Define the hotkey for displaying the GUI
^!Space:: ShowHotkeyGUI()

; Load saved configuration if it exists (returns false if no config exists)
configLoaded := LoadConfiguration()

; If no config existed, save the hardcoded defaults now that they're loaded
if (!configLoaded) {
    SaveConfiguration()
}

; Add Ctrl+F to focus search when GUI is active
#HotIf WinActive("Hotkey & Hotstring Reference")
^f:: {
    try {
        if (IsSet(MyGui) && MyGui.Hwnd) {
            WinActivate("ahk_id " . MyGui.Hwnd)
            searchBox.Focus()
            if (searchBox.Value == "Search...")
                searchBox.Value := ""
        }
    } catch {
        ; GUI has been destroyed, do nothing
    }
}
#HotIf

; ===========================
; MAIN GUI FUNCTIONS
; ===========================

ShowHotkeyGUI() {
    ; Create a new GUI
    global MyGui := Gui("+Resize +MinSize600x560", "Hotkey & Hotstring Reference")
    
    ; Set background color for a more modern look
    MyGui.BackColor := "0xF0F0F0"
    
    ; Set default font for better readability
    MyGui.SetFont("s9", "Segoe UI")

    ; Add a search box with placeholder text
    global searchBox := MyGui.Add("Edit", "vSearchTerm x10 y10 w515 h25", "Search...")
    searchBox.OnEvent("Focus", (*) => OnSearchFocus(searchBox))
    searchBox.OnEvent("LoseFocus", (*) => OnSearchLoseFocus(searchBox))
    searchBox.OnEvent("Change", (*) => FilterAllLists())

    ; Add clear button with styling
    global clearBtn := MyGui.Add("Button", "x530 y10 w60 h25", "✕ Clear")
    clearBtn.OnEvent("Click", (*) => ClearSearch())

    ; Build tabs dynamically using tabMetadata and customTabs
    tabNames := []
    tabOrder := []
    
    ; *** CLEAR the tab index map ***
    global tabIndexMap
    tabIndexMap := Map()
    
    ; Add built-in tabs (if visible)
    global tabMetadata
    if (tabMetadata.hotkeys.visible)
        tabOrder.Push({type: "builtin", key: "hotkeys", order: tabMetadata.hotkeys.order, name: tabMetadata.hotkeys.icon . " " . tabMetadata.hotkeys.name})
    if (tabMetadata.hotstrings.visible)
        tabOrder.Push({type: "builtin", key: "hotstrings", order: tabMetadata.hotstrings.order, name: tabMetadata.hotstrings.icon . " " . tabMetadata.hotstrings.name})
    if (tabMetadata.wiki.visible)
        tabOrder.Push({type: "builtin", key: "wiki", order: tabMetadata.wiki.order, name: tabMetadata.wiki.icon . " " . tabMetadata.wiki.name})
    
    ; Add custom tabs
    global customTabs
    for customTab in customTabs {
        tabOrder.Push({type: "custom", key: customTab.name, tab: customTab, order: customTab.order ? customTab.order : (50 + A_Index), name: customTab.icon . " " . customTab.name})
    }
    
    ; Add favorites last (if visible) - ALWAYS last regardless of order value
    if (tabMetadata.favorites.visible)
        tabOrder.Push({type: "builtin", key: "favorites", order: 9999, name: tabMetadata.favorites.icon . " " . tabMetadata.favorites.name})
    
    ; Sort by order using bubble sort for simplicity
    Loop tabOrder.Length - 1 {
        swapped := false
        Loop tabOrder.Length - A_Index {
            if (tabOrder[A_Index].order > tabOrder[A_Index + 1].order) {
                temp := tabOrder[A_Index]
                tabOrder[A_Index] := tabOrder[A_Index + 1]
                tabOrder[A_Index + 1] := temp
                swapped := true
            }
        }
        if (!swapped)
            break
    }
    
    ; Build final tab names array AND populate tab index map
    for tab in tabOrder {
        tabNames.Push(tab.name)
        ; *** MAP tab index to tab info ***
        tabIndexMap[A_Index] := {type: tab.type, key: tab.key}
    }
    
    ; Add Tab control
    global MyTab := MyGui.Add("Tab3", "x10 y45 w580 h413", tabNames)
    MyTab.OnEvent("Change", OnTabChange)

    ; Create ListViews for each tab
    global LV_Hotkeys := "", LV_Hotstrings := "", LV_Wiki := "", LV_Favorites := ""
    static customListViews := Map()
    customListViews.Clear()
    
    tabIndex := 1
    for tab in tabOrder {
        MyTab.UseTab(tabIndex)
        
        if (tab.type = "builtin") {
            switch tab.key {
                case "hotkeys":
                    global LV_Hotkeys := MyGui.Add("ListView", "x20 y75 w560 h373 +VScroll +Grid +LV0x10000", ["Category", "Hotkey", "Description"])
                    LV_Hotkeys.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Hotkeys, LV_Hotkeys.GetNext(), "Hotkeys"))
                    LV_Hotkeys.OnEvent("ContextMenu", ShowContextMenu)
                    LV_Hotkeys.OnEvent("ColClick", SortListView)
                    LV_Hotkeys.ModifyCol(1, 110)
                    LV_Hotkeys.ModifyCol(2, 170)
                    LV_Hotkeys.ModifyCol(3, 260)
                    lastSortCol["LV_Hotkeys"] := 0
                    sortDirection["LV_Hotkeys"] := 1
                    
                case "hotstrings":
                    global LV_Hotstrings := MyGui.Add("ListView", "x20 y75 w560 h373 +VScroll +Grid +LV0x10000", ["Category", "Hotstring", "Description"])
                    LV_Hotstrings.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Hotstrings, LV_Hotstrings.GetNext(), "Hotstrings"))
                    LV_Hotstrings.OnEvent("ContextMenu", ShowContextMenu)
                    LV_Hotstrings.OnEvent("ColClick", SortListView)
                    LV_Hotstrings.ModifyCol(1, 110)
                    LV_Hotstrings.ModifyCol(2, 170)
                    LV_Hotstrings.ModifyCol(3, 260)
                    lastSortCol["LV_Hotstrings"] := 0
                    sortDirection["LV_Hotstrings"] := 1
                    
                case "wiki":
                    global LV_Wiki := MyGui.Add("ListView", "x20 y75 w560 h373 +VScroll +Grid +LV0x10000", ["Category", "Shortcut", "Description"])
                    LV_Wiki.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Wiki, LV_Wiki.GetNext(), "Wiki"))
                    LV_Wiki.OnEvent("ContextMenu", ShowContextMenu)
                    LV_Wiki.OnEvent("ColClick", SortListView)
                    LV_Wiki.ModifyCol(1, 110)
                    LV_Wiki.ModifyCol(2, 170)
                    LV_Wiki.ModifyCol(3, 260)
                    lastSortCol["LV_Wiki"] := 0
                    sortDirection["LV_Wiki"] := 1
                    
                case "favorites":
                    global LV_Favorites := MyGui.Add("ListView", "x20 y75 w560 h373 +VScroll +Grid +LV0x10000", ["Type", "Item", "Description"])
                    LV_Favorites.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV_Favorites, LV_Favorites.GetNext(), "Favorites"))
                    LV_Favorites.OnEvent("ContextMenu", ShowFavoritesContextMenu)
                    LV_Favorites.OnEvent("ColClick", SortListView)
                    LV_Favorites.ModifyCol(1, 110)
                    LV_Favorites.ModifyCol(2, 170)
                    LV_Favorites.ModifyCol(3, 260)
                    lastSortCol["LV_Favorites"] := 0
                    sortDirection["LV_Favorites"] := 1
            }
        } else {
            ; Custom tab
            LV := MyGui.Add("ListView", "x20 y75 w560 h373 +VScroll +Grid +LV0x10000", ["Category", "Item", "Description"])
            LV.OnEvent("DoubleClick", (*) => LV_DoubleClick(LV, LV.GetNext(), tab.tab.name))
            LV.OnEvent("ContextMenu", ShowContextMenu)
            LV.OnEvent("ColClick", SortListView)
            LV.ModifyCol(1, 110)
            LV.ModifyCol(2, 170)
            LV.ModifyCol(3, 260)
            
            customListViews[tab.tab.name] := LV
            lastSortCol["LV_" . tab.tab.name] := 0
            sortDirection["LV_" . tab.tab.name] := 1
        }
        
        tabsPopulated[tabIndex] := false
        tabIndex++
    }
    
    ; Store custom ListViews in global scope
    global customLVs := customListViews

    MyTab.UseTab()  ; Subsequent controls will not belong to the tab control

    ; Add quick action buttons with improved styling
    btnY := 468
    
    ; Primary action button - Copy (green theme)
    MyGui.SetFont("s9 Bold", "Segoe UI")
    global copyBtn := MyGui.Add("Button", "x10 y" . btnY . " w100 h32", "📋 Copy")
    copyBtn.OnEvent("Click", (*) => CopyCurrentSelection())
    copyBtn.ToolTip := "Copy selected item to clipboard (Enter/Ctrl+C)"
    
    ; Secondary action buttons (reset to normal font weight)
    MyGui.SetFont("s9", "Segoe UI")
    global exportBtn := MyGui.Add("Button", "x120 y" . btnY . " w90 h32", "💾 Export")
    exportBtn.OnEvent("Click", (*) => ExportToFile())
    exportBtn.ToolTip := "Export all shortcuts to a text file"

    global settingsBtn := MyGui.Add("Button", "x220 y" . btnY . " w90 h32", "⚙️ Settings")
    settingsBtn.OnEvent("Click", (*) => ShowSettings())
    settingsBtn.ToolTip := "Configure hotkeys, hotstrings, and categories"

    global helpBtn := MyGui.Add("Button", "x320 y" . btnY . " w90 h32", "❓ Help")
    helpBtn.OnEvent("Click", (*) => ShowHelp())
    helpBtn.ToolTip := "Show keyboard shortcuts and tips"

    ; Destructive action button - Clear Favorites
    global clearFavBtn := MyGui.Add("Button", "x420 y" . btnY . " w90 h32", "🗑️ Clear")
    clearFavBtn.OnEvent("Click", (*) => ClearAllFavorites())
    clearFavBtn.ToolTip := "Clear all favorites"

    ; Add status bar
    global statusBar := MyGui.Add("StatusBar")
    SafeUpdateStatusBar("Ready | Press Ctrl+F to search, Enter to copy, Esc to close")

    ; Set up GUI resize event
    MyGui.OnEvent("Size", GuiResize)
    MyGui.OnEvent("Escape", (*) => MyGui.Destroy())
    MyGui.OnEvent("Close", (*) => MyGui.Destroy())

    ; Load favorites data first (but don't populate the ListView yet)
    LoadFavorites()
    
    ; Show the GUI FIRST before populating (fixes rendering issues)
    MyGui.Show("w600 h560")
    
    ; *** POPULATE FIRST TAB IMMEDIATELY using the tab index map ***
    PopulateTabByIndex(1)
    tabsPopulated[1] := true
    
    ; Update status bar
    UpdateStatusBar()
}

; *** NEW FUNCTION: Populate tab by index using the mapping ***
PopulateTabByIndex(tabIndex) {
    global tabIndexMap, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs, customTabs
    
    if (!tabIndexMap.Has(tabIndex))
        return
    
    tabInfo := tabIndexMap[tabIndex]
    
    if (tabInfo.type = "builtin") {
        switch tabInfo.key {
            case "hotkeys":
                if (IsSet(LV_Hotkeys) && LV_Hotkeys)
                    PopulateHotkeyListView(LV_Hotkeys)
            case "hotstrings":
                if (IsSet(LV_Hotstrings) && LV_Hotstrings)
                    PopulateHotstringListView(LV_Hotstrings)
            case "wiki":
                if (IsSet(LV_Wiki) && LV_Wiki)
                    PopulateWikiListView(LV_Wiki)
            case "favorites":
                if (IsSet(LV_Favorites) && LV_Favorites)
                    PopulateFavoritesListView()
        }
    } else if (tabInfo.type = "custom") {
        ; Find the custom tab and populate it
        if (customLVs.Has(tabInfo.key)) {
            LV := customLVs[tabInfo.key]
            ; Find the custom tab data
            for tab in customTabs {
                if (tab.name = tabInfo.key) {
                    PopulateCustomTabListView(LV, tab)
                    break
                }
            }
        }
    }
}

; *** NEW FUNCTION: Populate custom tab ListView ***
PopulateCustomTabListView(LV, tabData) {
    LV.Opt("-Redraw")
    LV.Delete()
    
    if (tabData.HasOwnProp("categories") && IsObject(tabData.categories)) {
        for category in tabData.categories {
            if (category.HasOwnProp("items") && IsObject(category.items)) {
                for item in category.items {
                    LV.Add("", category.name, item.item, item.description)
                }
            }
        }
    }
    
    LV.Opt("+Redraw")
}

GuiResize(*) {
    global MyGui, searchBox, clearBtn, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs
    global copyBtn, exportBtn, settingsBtn, helpBtn, clearFavBtn, statusBar

    try {
        if (!IsSet(MyGui) || !MyGui.Hwnd)
            return
    } catch {
        return
    }
        
    ; Get the current GUI size
    MyGui.GetPos(, , &w, &h)
    
    ; Resize search box to span width minus clear button and margins
    searchBox.Move(10, 10, w - 85, 25)
    clearBtn.Move(w - 70, 10, 60, 25)
    
    ; Fixed dimensions - increased margins to prevent overlap
    statusBarHeight := 22  ; Actual status bar height
    buttonHeight := 32    ; Updated button height
    buttonMargin := 35    ; Margin between buttons and status bar
    
    ; Calculate tab height - leave plenty of room at bottom for buttons and status bar
    bottomReserved := statusBarHeight + buttonHeight + buttonMargin
    tabHeight := h - 45 - bottomReserved - 10  ; 45 for search area, 10 for spacing
    MyTab.Move(10, 45, w - 20, tabHeight)
    
    ; Resize ListViews within tabs (they start at y75, which is 30px below tab start)
    lvHeight := tabHeight - 30
    
    ; Only resize if they exist (they might not if tabs are hidden)
    if (IsSet(LV_Hotkeys) && LV_Hotkeys)
        LV_Hotkeys.Move(20, 75, w - 40, lvHeight)
    if (IsSet(LV_Hotstrings) && LV_Hotstrings)
        LV_Hotstrings.Move(20, 75, w - 40, lvHeight)
    if (IsSet(LV_Wiki) && LV_Wiki)
        LV_Wiki.Move(20, 75, w - 40, lvHeight)
    
    ; Resize custom tab ListViews
    for tabName, LV in customLVs {
        LV.Move(20, 75, w - 40, lvHeight)
    }
    
    if (IsSet(LV_Favorites) && LV_Favorites)
        LV_Favorites.Move(20, 75, w - 40, lvHeight)
    
    ; Position buttons with proper spacing (5 buttons now)
    btnY := h - statusBarHeight - buttonHeight - buttonMargin
    copyBtn.Move(10, btnY, 100, buttonHeight)
    exportBtn.Move(120, btnY, 90, buttonHeight)
    settingsBtn.Move(220, btnY, 90, buttonHeight)
    helpBtn.Move(320, btnY, 90, buttonHeight)
    clearFavBtn.Move(420, btnY, 90, buttonHeight)
    
    ; Auto-size columns for all ListViews
    if (IsSet(LV_Hotkeys) && LV_Hotkeys)
        AutoSizeColumns(LV_Hotkeys)
    if (IsSet(LV_Hotstrings) && LV_Hotstrings)
        AutoSizeColumns(LV_Hotstrings)
    if (IsSet(LV_Wiki) && LV_Wiki)
        AutoSizeColumns(LV_Wiki)
    
    ; Auto-size custom ListViews
    for tabName, LV in customLVs {
        AutoSizeColumns(LV)
    }
    
    if (IsSet(LV_Favorites) && LV_Favorites)
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

; ===========================
; EVENT HANDLERS
; ===========================

OnSearchFocus(searchBox) {
    if (searchBox.Value == "Search...") {
        searchBox.Value := ""
    }
}

; *** FIXED: OnTabChange now uses the tab index map ***
OnTabChange(*) {
    global MyTab, tabsPopulated
    
    ; Get current tab
    currentTab := MyTab.Value
    
    ; Only populate if not already populated
    if (!tabsPopulated[currentTab]) {
        PopulateTabByIndex(currentTab)
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
    global searchBox
    searchBox.Value := ""
    searchBox.Focus()
    FilterAllLists()
}

FilterAllLists() {
    global tabsPopulated, searchBox, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs
    global hotkeyCategories, hotstringCategories, wikiCategories, customTabs, favoritesList, statusBar
    
    searchTerm := Trim(searchBox.Value)
    if (searchTerm == "Search..." or searchTerm == "") {
        ; Reset to lazy loading - clear populated flags
        for tabIdx in tabsPopulated {
            tabsPopulated[tabIdx] := false
        }
        
        ; Only populate the current tab
        currentTab := MyTab.Value
        PopulateTabByIndex(currentTab)
        tabsPopulated[currentTab] := true
        
        UpdateStatusBar()
        return
    }

    searchTermLower := StrLower(searchTerm)

    ; Filter Hotkeys (if it exists)
    if (IsSet(LV_Hotkeys) && LV_Hotkeys) {
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
    }

    ; Filter Hotstrings (if it exists)
    if (IsSet(LV_Hotstrings) && LV_Hotstrings) {
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
    }

    ; Filter Wiki Shortcuts (if it exists)
    if (IsSet(LV_Wiki) && LV_Wiki) {
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
    }

    ; Filter custom tabs
    for tabName, LV in customLVs {
        LV.Opt("-Redraw")
        LV.Delete()
        
        ; Find the custom tab data
        for tab in customTabs {
            if (tab.name = tabName) {
                if (tab.HasOwnProp("categories") && IsObject(tab.categories)) {
                    for category in tab.categories {
                        categoryMatched := InStr(StrLower(category.name), searchTermLower) > 0
                        if (category.HasOwnProp("items") && IsObject(category.items)) {
                            for item in category.items {
                                if (categoryMatched or 
                                    InStr(StrLower(item.item), searchTermLower) > 0 or 
                                    InStr(StrLower(item.description), searchTermLower) > 0) {
                                    LV.Add(, category.name, item.item, item.description)
                                }
                            }
                        }
                    }
                }
                break
            }
        }
        
        LV.Opt("+Redraw")
    }

    ; Filter Favorites (if it exists)
    if (IsSet(LV_Favorites) && LV_Favorites) {
        LV_Favorites.Opt("-Redraw")
        LV_Favorites.Delete()
        for fav in favoritesList {
            if (InStr(StrLower(fav.type), searchTermLower) > 0 or 
                InStr(StrLower(fav.item), searchTermLower) > 0 or 
                InStr(StrLower(fav.desc), searchTermLower) > 0) {
                LV_Favorites.Add(, fav.type, fav.item, fav.desc)
            }
        }
        LV_Favorites.Opt("+Redraw")
    }
    
    ; Mark all tabs as populated after filtering
    for tabIdx in tabsPopulated {
        tabsPopulated[tabIdx] := true
    }

    ; Update status with counts
    hotkeyCount := IsSet(LV_Hotkeys) && LV_Hotkeys ? LV_Hotkeys.GetCount() : 0
    hotstringCount := IsSet(LV_Hotstrings) && LV_Hotstrings ? LV_Hotstrings.GetCount() : 0
    wikiCount := IsSet(LV_Wiki) && LV_Wiki ? LV_Wiki.GetCount() : 0
    favCount := IsSet(LV_Favorites) && LV_Favorites ? LV_Favorites.GetCount() : 0
    
    ; Count custom tabs
    customCount := 0
    for tabName, LV in customLVs {
        customCount += LV.GetCount()
    }
    
    totalResults := hotkeyCount + hotstringCount + wikiCount + customCount + favCount
    SafeUpdateStatusBar("Found " . totalResults . " results | Hotkeys: " . hotkeyCount . " | Hotstrings: " . hotstringCount . " | Wiki: " . wikiCount . " | Custom: " . customCount . " | Favorites: " . favCount)
}

; ===========================
; LISTVIEW POPULATION
; ===========================

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
    global LV_Favorites, favoritesList
    LV_Favorites.Opt("-Redraw")
    LV_Favorites.Delete()
    for fav in favoritesList {
        LV_Favorites.Add(, fav.type, fav.item, fav.desc)
    }
    LV_Favorites.Opt("+Redraw")
}

; ===========================
; HELPER FUNCTIONS
; ===========================

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
    ; Count custom tab items
    for tab in customTabs {
        if (tab.HasOwnProp("categories") && IsObject(tab.categories)) {
            for category in tab.categories {
                if (category.HasOwnProp("items") && IsObject(category.items)) {
                    count += category.items.Length
                }
            }
        }
    }
    return count
}

UpdateStatusBar() {
    global tabsPopulated, LV_Hotkeys, LV_Hotstrings, LV_Wiki, favoritesList, customLVs, searchBox, statusBar, MyGui

    ; Safety check - if GUI is destroyed, exit immediately
    try {
        if (!IsSet(MyGui) || !MyGui || !MyGui.Hwnd)
            return

        ; Check if GUI window still exists
        if (!WinExist("ahk_id " . MyGui.Hwnd))
            return
    } catch {
        return
    }
    
    ; Verify statusBar and searchBox still exist
    if (!IsSet(statusBar) || !statusBar || !IsSet(searchBox) || !searchBox)
        return
    
    try {
        ; Get counts - with additional safety checks
        hotkeyCount := 0
        hotstringCount := 0
        wikiCount := 0
        customCount := 0
        
        if (IsSet(LV_Hotkeys) && LV_Hotkeys && LV_Hotkeys.Hwnd) {
            try {
                hotkeyCount := LV_Hotkeys.GetCount()
            } catch {
                hotkeyCount := CountHotkeys()
            }
        } else {
            hotkeyCount := CountHotkeys()
        }
        
        if (IsSet(LV_Hotstrings) && LV_Hotstrings && LV_Hotstrings.Hwnd) {
            try {
                hotstringCount := LV_Hotstrings.GetCount()
            } catch {
                hotstringCount := CountHotstrings()
            }
        } else {
            hotstringCount := CountHotstrings()
        }
        
        if (IsSet(LV_Wiki) && LV_Wiki && LV_Wiki.Hwnd) {
            try {
                wikiCount := LV_Wiki.GetCount()
            } catch {
                wikiCount := CountWikiShortcuts()
            }
        } else {
            wikiCount := CountWikiShortcuts()
        }
        
        favCount := favoritesList.Length
        
        ; Count custom tabs
        if (IsSet(customLVs)) {
            for tabName, LV in customLVs {
                if (LV && LV.Hwnd) {
                    try {
                        customCount += LV.GetCount()
                    }
                }
            }
        }
        
        searchTerm := Trim(searchBox.Value)
        if (searchTerm != "" && searchTerm != "Search...") {
            totalResults := hotkeyCount + hotstringCount + wikiCount + customCount + favCount
            SafeUpdateStatusBar("Found " . totalResults . " results | Hotkeys: " . hotkeyCount . " | Hotstrings: " . hotstringCount . " | Wiki: " . wikiCount . " | Custom: " . customCount . " | Favorites: " . favCount)
        } else {
            totalItems := CountAllItems()
            SafeUpdateStatusBar("Ready | Total: " . totalItems . " items | Press Ctrl+F to search")
        }
    } catch as err {
        ; Silently handle any errors if controls are being destroyed
        return
    }
}

; Add this helper function near the top with other helper functions
SafeUpdateStatusBar(initialMessage := "") {
    global MyGui, statusBar
    
    ; Set initial message if provided
    if (initialMessage != "" && IsSet(statusBar) && statusBar && statusBar.Hwnd) {
        try {
            statusBar.SetText(initialMessage)
        }
    }
    
    ; Set timer to update status bar, but verify GUI still exists when timer fires
    SetTimer(() => SafeTimerUpdate(), -3000)
}

SafeTimerUpdate() {
    global MyGui

    ; Only update if GUI still exists
    try {
        if (IsSet(MyGui) && MyGui && MyGui.Hwnd && WinExist("ahk_id " . MyGui.Hwnd)) {
            UpdateStatusBar()
        }
    } catch {
        ; GUI has been destroyed, do nothing
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

; ===========================
; LISTVIEW INTERACTIONS
; ===========================

LV_DoubleClick(LV, RowNumber, TabType) {
    global statusBar
    if (RowNumber > 0) {
        selectedItem := LV.GetText(RowNumber, 2)  ; Get the hotkey/hotstring from the second column
        A_Clipboard := selectedItem
        
        ; Highlight the selected row
        LV.Modify(RowNumber, "Select Focus Vis")
        
        ; Show visual feedback
        ShowCopyNotification(selectedItem)
        
        ; Update status bar
        SafeUpdateStatusBar("✓ Copied: " . selectedItem)
    }
}

ShowCopyNotification(text) {
    ; Create a small toast notification with improved styling
    notifyGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Notification")
    notifyGui.BackColor := "0x4CAF50"  ; Material green color
    notifyGui.SetFont("s10 Bold", "Segoe UI")
    
    ; Truncate text if too long
    displayText := (StrLen(text) > 50) ? SubStr(text, 1, 47) . "..." : text
    notifyGui.Add("Text", "cWhite x15 y10 w300", "✓ Copied: " . displayText)
    
    ; Position in bottom-right of screen
    notifyGui.Show("NoActivate x" . (A_ScreenWidth - 350) . " y" . (A_ScreenHeight - 100) . " w330 h40")
    
    ; Auto-close after 2 seconds
    SetTimer(() => notifyGui.Destroy(), -2000)
}

ShowContextMenu(LV, Item, IsRightClick, X, Y) {
    if (Item > 0) {
        contextMenu := Menu()
        contextMenu.Add("📋 Copy Item", (*) => LV_DoubleClick(LV, Item, ""))
        contextMenu.Add("📝 Copy Description", (*) => CopyDescription(LV, Item))
        contextMenu.Add()
        
        ; Check if already favorited
        itemText := LV.GetText(Item, 2)
        isFavorited := IsFavorite(itemText)
        
        if (isFavorited) {
            contextMenu.Add("❌ Remove from Favorites", (*) => RemoveFavorite(LV, Item))
        } else {
            contextMenu.Add("⭐ Add to Favorites", (*) => MarkFavorite(LV, Item))
        }
        
        contextMenu.Show(X, Y)
    }
}

ShowFavoritesContextMenu(LV, Item, IsRightClick, X, Y) {
    if (Item > 0) {
        contextMenu := Menu()
        contextMenu.Add("📋 Copy Item", (*) => LV_DoubleClick(LV, Item, "Favorites"))
        contextMenu.Add("📝 Copy Description", (*) => CopyDescription(LV, Item))
        contextMenu.Add()
        contextMenu.Add("❌ Remove from Favorites", (*) => RemoveFavoriteByRow(Item))
        contextMenu.Show(X, Y)
    }
}

CopyDescription(LV, RowNumber) {
    global statusBar
    description := LV.GetText(RowNumber, 3)
    A_Clipboard := description
    ShowCopyNotification(description)
    SafeUpdateStatusBar("✓ Copied description: " . description)
}

SortListView(LV, ColNumber) {
    ; Get the control name to track sort state
    lvName := ""
    if (IsSet(LV_Hotkeys) && LV = LV_Hotkeys)
        lvName := "LV_Hotkeys"
    else if (IsSet(LV_Hotstrings) && LV = LV_Hotstrings)
        lvName := "LV_Hotstrings"
    else if (IsSet(LV_Wiki) && LV = LV_Wiki)
        lvName := "LV_Wiki"
    else if (IsSet(LV_Favorites) && LV = LV_Favorites)
        lvName := "LV_Favorites"
    else {
        ; Check custom ListViews
        for tabName, customLV in customLVs {
            if (LV = customLV) {
                lvName := "LV_" . tabName
                break
            }
        }
    }
    
    if (lvName = "")
        return
    
    ; Initialize if not exists
    if (!lastSortCol.Has(lvName))
        lastSortCol[lvName] := 0
    if (!sortDirection.Has(lvName))
        sortDirection[lvName] := 1
    
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

; ===========================
; FAVORITES MANAGEMENT
; ===========================

IsFavorite(itemText) {
    global favoritesList
    for fav in favoritesList {
        if (fav.item == itemText) {
            return true
        }
    }
    return false
}

MarkFavorite(LV, RowNumber) {
    global tabsPopulated, favoritesList, MyTab, statusBar, tabIndexMap
    
    category := LV.GetText(RowNumber, 1)
    item := LV.GetText(RowNumber, 2)
    description := LV.GetText(RowNumber, 3)
    
    ; Check if already favorited
    if (IsFavorite(item)) {
        MsgBox("This item is already in your favorites!", "Already Favorited", 64)
        return
    }
    
    ; Determine type based on current tab using tab index map
    tabIndex := MyTab.Value
    tabType := "Custom"  ; Default
    
    if (tabIndexMap.Has(tabIndex)) {
        tabInfo := tabIndexMap[tabIndex]
        if (tabInfo.type = "builtin") {
            switch tabInfo.key {
                case "hotkeys":
                    tabType := "Hotkey"
                case "hotstrings":
                    tabType := "Hotstring"
                case "wiki":
                    tabType := "Wiki"
                default:
                    tabType := "Custom"
            }
        } else {
            tabType := "Custom: " . tabInfo.key
        }
    }
    
    favoritesList.Push({type: tabType, item: item, desc: description})
    SaveFavorites()
    
    ; Mark Favorites tab as needing repopulation if it exists
    for idx, info in tabIndexMap {
        if (info.type = "builtin" && info.key = "favorites") {
            tabsPopulated[idx] := false
            if (MyTab.Value = idx && IsSet(LV_Favorites) && LV_Favorites) {
                PopulateFavoritesListView()
                tabsPopulated[idx] := true
            }
            break
        }
    }
    
    UpdateStatusBar()
    
    SafeUpdateStatusBar("⭐ Added to favorites: " . item)
}

RemoveFavorite(LV, RowNumber) {
    global tabsPopulated, favoritesList, MyTab, statusBar, tabIndexMap
    
    item := LV.GetText(RowNumber, 2)
    
    for index, fav in favoritesList {
        if (fav.item == item) {
            favoritesList.RemoveAt(index)
            SaveFavorites()
            
            ; Mark Favorites tab as needing repopulation if it exists
            for idx, info in tabIndexMap {
                if (info.type = "builtin" && info.key = "favorites") {
                    tabsPopulated[idx] := false
                    if (MyTab.Value = idx && IsSet(LV_Favorites) && LV_Favorites) {
                        PopulateFavoritesListView()
                        tabsPopulated[idx] := true
                    }
                    break
                }
            }
            
            UpdateStatusBar()
            SafeUpdateStatusBar("Removed from favorites: " . item)
            return
        }
    }
}

RemoveFavoriteByRow(RowNumber) {
    global tabsPopulated, favoritesList, MyTab, statusBar, tabIndexMap
    
    if (RowNumber > 0 && RowNumber <= favoritesList.Length) {
        item := favoritesList[RowNumber].item
        favoritesList.RemoveAt(RowNumber)
        SaveFavorites()
        
        ; Mark Favorites tab as needing repopulation if it exists
        for idx, info in tabIndexMap {
            if (info.type = "builtin" && info.key = "favorites") {
                tabsPopulated[idx] := false
                if (MyTab.Value = idx && IsSet(LV_Favorites) && LV_Favorites) {
                    PopulateFavoritesListView()
                    tabsPopulated[idx] := true
                }
                break
            }
        }
        
        UpdateStatusBar()
        SafeUpdateStatusBar("Removed from favorites: " . item)
    }
}

ClearAllFavorites() {
    global tabsPopulated, favoritesList, MyTab, statusBar, tabIndexMap
    
    if (favoritesList.Length > 0) {
        result := MsgBox("Are you sure you want to clear all favorites?", "Clear Favorites", 4 + 32)
        if (result = "Yes") {
            favoritesList := []
            SaveFavorites()
            
            ; Mark Favorites tab as needing repopulation if it exists
            for idx, info in tabIndexMap {
                if (info.type = "builtin" && info.key = "favorites") {
                    tabsPopulated[idx] := false
                    if (MyTab.Value = idx && IsSet(LV_Favorites) && LV_Favorites) {
                        PopulateFavoritesListView()
                        tabsPopulated[idx] := true
                    }
                    break
                }
            }
            
            UpdateStatusBar()
            SafeUpdateStatusBar("All favorites cleared")
        }
    } else {
        MsgBox("No favorites to clear!", "Clear Favorites", 64)
    }
}

SaveFavorites() {
    global favoritesList
    ; Get the directory of THIS file (not the main script)
    SplitPath(A_LineFile,, &guiDir)
    favFile := guiDir . "\favorites.ini"
    
    try {
        ; Delete old favorites file
        if FileExist(favFile)
            FileDelete(favFile)
        
        ; Save count
        IniWrite(favoritesList.Length, favFile, "Settings", "Count")
        
        ; Save each favorite
        for index, fav in favoritesList {
            sectionName := "Favorite" . index
            IniWrite(fav.type, favFile, sectionName, "Type")
            IniWrite(fav.item, favFile, sectionName, "Item")
            IniWrite(fav.desc, favFile, sectionName, "Description")
        }
    } catch as err {
        MsgBox("Failed to save favorites: " . err.Message, "Save Error", 16)
    }
}

LoadFavorites() {
    global favoritesList := []
    
    ; Get the directory of THIS file (not the main script)
    SplitPath(A_LineFile,, &guiDir)
    favFile := guiDir . "\favorites.ini"
    
    if (!FileExist(favFile))
        return
    
    try {
        ; Read count
        count := IniRead(favFile, "Settings", "Count", 0)
        
        ; Load each favorite
        Loop count {
            sectionName := "Favorite" . A_Index
            type := IniRead(favFile, sectionName, "Type", "")
            item := IniRead(favFile, sectionName, "Item", "")
            desc := IniRead(favFile, sectionName, "Description", "")
            
            if (type != "" && item != "") {
                favoritesList.Push({type: type, item: item, desc: desc})
            }
        }
    } catch as err {
        ; Silently handle errors - will just start with empty favorites
    }
}

; ===========================
; BUTTON ACTIONS
; ===========================

CopyCurrentSelection() {
    global MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs, tabIndexMap
    currentTab := MyTab.Value
    
    ; Get the correct ListView using tab index map
    LV := ""
    if (tabIndexMap.Has(currentTab)) {
        tabInfo := tabIndexMap[currentTab]
        if (tabInfo.type = "builtin") {
            switch tabInfo.key {
                case "hotkeys":
                    LV := LV_Hotkeys
                case "hotstrings":
                    LV := LV_Hotstrings
                case "wiki":
                    LV := LV_Wiki
                case "favorites":
                    LV := LV_Favorites
            }
        } else {
            ; Custom tab
            if (customLVs.Has(tabInfo.key))
                LV := customLVs[tabInfo.key]
        }
    }
    
    if (LV = "" || !IsObject(LV)) {
        MsgBox("Could not access the current tab's list!", "Error", 48)
        return
    }
    
    rowNumber := LV.GetNext()
    
    if (rowNumber > 0) {
        LV_DoubleClick(LV, rowNumber, "")
    } else {
        MsgBox("No item selected!", "Copy Selected", 48)
    }
}

ExportToFile() {
    global favoritesList, hotkeyCategories, hotstringCategories, wikiCategories, customTabs, statusBar
    ; Prompt user to select save location with file type filter
    exportFile := FileSelect("S16", "HotkeyReference_Export.txt", "Export Hotkey Reference", "Text Files (*.txt)")
    
    ; If user cancelled, exit
    if (exportFile = "")
        return
    
    ; Ensure .txt extension
    if (!InStr(exportFile, ".txt"))
        exportFile .= ".txt"
    
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
    
    ; Export Custom Tabs
    if (customTabs.Length > 0) {
        fileContent .= "`n`nCUSTOM TABS`n"
        fileContent .= "-" . StrReplace(Format("{:80s}", ""), " ", "-") . "`n"
        for tab in customTabs {
            fileContent .= "`n" . tab.icon . " " . tab.name . "`n"
            if (tab.HasOwnProp("categories") && IsObject(tab.categories)) {
                for category in tab.categories {
                    fileContent .= "  [" . category.name . "]`n"
                    if (category.HasOwnProp("items") && IsObject(category.items)) {
                        for item in category.items {
                            fileContent .= "    " . Format("{:-25s}", item.item) . " - " . item.description . "`n"
                        }
                    }
                }
            }
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
        ; Delete existing file if it exists
        if (FileExist(exportFile))
            FileDelete(exportFile)
        
        FileAppend(fileContent, exportFile)
        
        result := MsgBox("Export successful!`n`nFile saved to:`n" . exportFile . "`n`nWould you like to open it now?", "Export Complete", 4 + 64)
        if (result = "Yes")
            Run(exportFile)
            
        SafeUpdateStatusBar("✓ Exported to: " . exportFile)
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
    • ⚙️ Configure everything via Settings button
    • 🎨 Create custom tabs with your own shortcuts
    
    SETTINGS:
    • Add, edit, or delete hotkeys, hotstrings, and wiki shortcuts
    • Create and manage custom categories
    • Customize tab names, icons, order, and visibility
    • Create custom tabs for your own shortcuts
    • Add content to custom tabs via 'Custom Tab Content' settings
    • Export/import your configuration
    • All changes are saved automatically
    
    FAVORITES:
    • Right-click any item and select "Add to Favorites"
    • Access favorites from the ⭐ Favorites tab
    • Remove items by right-clicking or pressing Delete
    • Favorites are saved between sessions
    
    TIPS:
    • Use the search box to quickly find what you need
    • Status bar shows counts and helpful information
    • Export feature lets you choose save location
    • Buttons include visual icons for easy identification
    • Settings allow full customization of all shortcuts
    • Tab order and visibility can be customized
    
    VERSION: Complete v2.7 (Custom Tab Content Management Added)
    )"
    
    MsgBox(helpText, "Help - Hotkey Reference", 64)
}

; ===========================
; CONFIGURATION MANAGEMENT
; ===========================

SaveConfiguration() {
    global hotkeyCategories, hotstringCategories, wikiCategories, customTabs, tabMetadata
    
    ; Validate that all required global variables are initialized
    if (!IsSet(hotkeyCategories) || !IsObject(hotkeyCategories)) {
        MsgBox("Error: hotkeyCategories not initialized", "Save Error", 16)
        return false
    }
    if (!IsSet(hotstringCategories) || !IsObject(hotstringCategories)) {
        MsgBox("Error: hotstringCategories not initialized", "Save Error", 16)
        return false
    }
    if (!IsSet(wikiCategories) || !IsObject(wikiCategories)) {
        MsgBox("Error: wikiCategories not initialized", "Save Error", 16)
        return false
    }
    if (!IsSet(customTabs) || !IsObject(customTabs)) {
        MsgBox("Error: customTabs not initialized", "Save Error", 16)
        return false
    }
    if (!IsSet(tabMetadata) || !IsObject(tabMetadata)) {
        MsgBox("Error: tabMetadata not initialized", "Save Error", 16)
        return false
    }
    
    SplitPath(A_LineFile,, &guiDir)
    configFile := guiDir . "\config.ini"
    
    try {
        ; Delete old config file
        if FileExist(configFile)
            FileDelete(configFile)
        
        ; Save Tab Metadata (Built-in tab customization)
        for key in ["hotkeys", "hotstrings", "wiki", "favorites"] {
            if (!tabMetadata.HasOwnProp(key))
                continue
                
            meta := tabMetadata.%key%
            sectionName := "TabMeta-" . key
            IniWrite(meta.name, configFile, sectionName, "Name")
            IniWrite(meta.icon, configFile, sectionName, "Icon")
            IniWrite(meta.visible ? 1 : 0, configFile, sectionName, "Visible")
            IniWrite(meta.order, configFile, sectionName, "Order")
        }
        
        ; Save Hotkey Categories
        for catIndex, cat in hotkeyCategories {
            sectionName := "Hotkeys-Cat" . catIndex
            IniWrite(cat.name, configFile, sectionName, "Name")
            IniWrite(cat.hotkeys.Length, configFile, sectionName, "Count")
            
            for itemIndex, hk in cat.hotkeys {
                IniWrite(hk.hotkey, configFile, sectionName, "Item" . itemIndex . "_Key")
                IniWrite(hk.description, configFile, sectionName, "Item" . itemIndex . "_Desc")
            }
        }
        IniWrite(hotkeyCategories.Length, configFile, "Settings", "HotkeyCategories")
        
        ; Save Hotstring Categories
        for catIndex, cat in hotstringCategories {
            sectionName := "Hotstrings-Cat" . catIndex
            IniWrite(cat.name, configFile, sectionName, "Name")
            IniWrite(cat.hotstrings.Length, configFile, sectionName, "Count")
            
            for itemIndex, hs in cat.hotstrings {
                IniWrite(hs.hotstring, configFile, sectionName, "Item" . itemIndex . "_Key")
                IniWrite(hs.description, configFile, sectionName, "Item" . itemIndex . "_Desc")
            }
        }
        IniWrite(hotstringCategories.Length, configFile, "Settings", "HotstringCategories")
        
        ; Save Wiki Categories
        for catIndex, cat in wikiCategories {
            sectionName := "Wiki-Cat" . catIndex
            IniWrite(cat.name, configFile, sectionName, "Name")
            IniWrite(cat.shortcuts.Length, configFile, sectionName, "Count")
            
            for itemIndex, ws in cat.shortcuts {
                IniWrite(ws.shortcut, configFile, sectionName, "Item" . itemIndex . "_Key")
                IniWrite(ws.description, configFile, sectionName, "Item" . itemIndex . "_Desc")
            }
        }
        IniWrite(wikiCategories.Length, configFile, "Settings", "WikiCategories")
        
        ; Save Custom Tabs
        IniWrite(customTabs.Length, configFile, "Settings", "CustomTabs")
        for tabIndex, tab in customTabs {
            sectionName := "CustomTab" . tabIndex
            IniWrite(tab.name, configFile, sectionName, "Name")
            IniWrite(tab.icon, configFile, sectionName, "Icon")
            IniWrite(tab.order ? tab.order : (50 + tabIndex), configFile, sectionName, "Order")
            
            catCount := tab.HasOwnProp("categories") && IsObject(tab.categories) ? tab.categories.Length : 0
            IniWrite(catCount, configFile, sectionName, "CategoryCount")
            
            if (catCount > 0) {
                for catIndex, category in tab.categories {
                    catSection := sectionName . "-Cat" . catIndex
                    IniWrite(category.name, configFile, catSection, "Name")
                    itemCount := category.HasOwnProp("items") && IsObject(category.items) ? category.items.Length : 0
                    IniWrite(itemCount, configFile, catSection, "Count")
                    
                    if (itemCount > 0) {
                        for itemIndex, item in category.items {
                            IniWrite(item.item, configFile, catSection, "Item" . itemIndex . "_Key")
                            IniWrite(item.description, configFile, catSection, "Item" . itemIndex . "_Desc")
                        }
                    }
                }
            }
        }
        
        return true
    } catch as err {
        MsgBox("Failed to save configuration: " . err.Message, "Save Error", 16)
        return false
    }
}

LoadConfiguration() {
    global hotkeyCategories, hotstringCategories, wikiCategories, customTabs, tabMetadata
    
    SplitPath(A_LineFile,, &guiDir)
    configFile := guiDir . "\config.ini"
    
    if !FileExist(configFile) {
        ; Config doesn't exist - this is normal on first run or after deletion
        ; The hardcoded defaults will be used, and we'll save them after they're loaded
        return false
    }
    
    ; Store defaults BEFORE try block (only if they're already initialized)
    ; This protects against corruption during loading
    defaultHotkeys := IsSet(hotkeyCategories) ? hotkeyCategories : []
    defaultHotstrings := IsSet(hotstringCategories) ? hotstringCategories : []
    defaultWiki := IsSet(wikiCategories) ? wikiCategories : []
    defaultTabs := IsSet(customTabs) ? customTabs : []
    defaultTabMeta := IsSet(tabMetadata) ? tabMetadata : {
        hotkeys: {name: "Hotkeys", icon: "📋", visible: true, order: 1},
        hotstrings: {name: "Hotstrings", icon: "💬", visible: true, order: 2},
        wiki: {name: "Wiki Shortcuts", icon: "📝", visible: true, order: 3},
        favorites: {name: "Favorites", icon: "⭐", visible: true, order: 999}
    }
    
    try {
        ; Load Tab Metadata (Built-in tab customization)
        for key in ["hotkeys", "hotstrings", "wiki", "favorites"] {
            sectionName := "TabMeta-" . key
            name := IniRead(configFile, sectionName, "Name", "")
            if (name != "") {
                icon := IniRead(configFile, sectionName, "Icon", "📌")
                visible := IniRead(configFile, sectionName, "Visible", "1")
                order := IniRead(configFile, sectionName, "Order", "1")
                
                tabMetadata.%key% := {
                    name: name,
                    icon: icon,
                    visible: (visible = "1"),
                    order: Integer(order)
                }
            }
        }
        
        ; Load Hotkey Categories
        hotkeyCount := IniRead(configFile, "Settings", "HotkeyCategories", 0)
        if (hotkeyCount > 0) {
            newHotkeyCategories := []
            
            Loop hotkeyCount {
                catIndex := A_Index
                sectionName := "Hotkeys-Cat" . catIndex
                
                catName := IniRead(configFile, sectionName, "Name", "")
                itemCount := IniRead(configFile, sectionName, "Count", 0)
                
                if (catName = "")
                    continue
                
                items := []
                Loop itemCount {
                    itemIndex := A_Index
                    key := IniRead(configFile, sectionName, "Item" . itemIndex . "_Key", "")
                    desc := IniRead(configFile, sectionName, "Item" . itemIndex . "_Desc", "")
                    
                    if (key != "" && desc != "") {
                        items.Push({hotkey: key, description: desc})
                    }
                }
                
                newHotkeyCategories.Push({name: catName, hotkeys: items})
            }
            
            if (newHotkeyCategories.Length > 0)
                hotkeyCategories := newHotkeyCategories
        }
        
        ; Load Hotstring Categories
        hotstringCount := IniRead(configFile, "Settings", "HotstringCategories", 0)
        if (hotstringCount > 0) {
            newHotstringCategories := []
            
            Loop hotstringCount {
                catIndex := A_Index
                sectionName := "Hotstrings-Cat" . catIndex
                
                catName := IniRead(configFile, sectionName, "Name", "")
                itemCount := IniRead(configFile, sectionName, "Count", 0)
                
                if (catName = "")
                    continue
                
                items := []
                Loop itemCount {
                    itemIndex := A_Index
                    key := IniRead(configFile, sectionName, "Item" . itemIndex . "_Key", "")
                    desc := IniRead(configFile, sectionName, "Item" . itemIndex . "_Desc", "")
                    
                    if (key != "" && desc != "") {
                        items.Push({hotstring: key, description: desc})
                    }
                }
                
                newHotstringCategories.Push({name: catName, hotstrings: items})
            }
            
            if (newHotstringCategories.Length > 0)
                hotstringCategories := newHotstringCategories
        }
        
        ; Load Wiki Categories
        wikiCount := IniRead(configFile, "Settings", "WikiCategories", 0)
        if (wikiCount > 0) {
            newWikiCategories := []
            
            Loop wikiCount {
                catIndex := A_Index
                sectionName := "Wiki-Cat" . catIndex
                
                catName := IniRead(configFile, sectionName, "Name", "")
                itemCount := IniRead(configFile, sectionName, "Count", 0)
                
                if (catName = "")
                    continue
                
                items := []
                Loop itemCount {
                    itemIndex := A_Index
                    key := IniRead(configFile, sectionName, "Item" . itemIndex . "_Key", "")
                    desc := IniRead(configFile, sectionName, "Item" . itemIndex . "_Desc", "")
                    
                    if (key != "" && desc != "") {
                        items.Push({shortcut: key, description: desc})
                    }
                }
                
                newWikiCategories.Push({name: catName, shortcuts: items})
            }
            
            if (newWikiCategories.Length > 0)
                wikiCategories := newWikiCategories
        }
        
        ; Load Custom Tabs
        customTabCount := IniRead(configFile, "Settings", "CustomTabs", 0)
        if (customTabCount > 0) {
            newCustomTabs := []
            
            Loop customTabCount {
                tabIndex := A_Index
                sectionName := "CustomTab" . tabIndex
                
                tabName := IniRead(configFile, sectionName, "Name", "")
                tabIcon := IniRead(configFile, sectionName, "Icon", "📌")
                tabOrder := IniRead(configFile, sectionName, "Order", 50 + tabIndex)
                catCount := IniRead(configFile, sectionName, "CategoryCount", 0)
                
                if (tabName = "")
                    continue
                
                categories := []
                if (catCount > 0) {
                    Loop catCount {
                        catIndex := A_Index
                        catSection := sectionName . "-Cat" . catIndex
                        
                        catName := IniRead(configFile, catSection, "Name", "")
                        itemCount := IniRead(configFile, catSection, "Count", 0)
                        
                        if (catName = "")
                            continue
                        
                        items := []
                        Loop itemCount {
                            itemIndex := A_Index
                            key := IniRead(configFile, catSection, "Item" . itemIndex . "_Key", "")
                            desc := IniRead(configFile, catSection, "Item" . itemIndex . "_Desc", "")
                            
                            if (key != "" && desc != "") {
                                items.Push({item: key, description: desc})
                            }
                        }
                        
                        categories.Push({name: catName, items: items})
                    }
                }
                
                newCustomTabs.Push({name: tabName, icon: tabIcon, order: Integer(tabOrder), categories: categories})
            }
            
            if (newCustomTabs.Length > 0)
                customTabs := newCustomTabs
        }
        
        return true
    } catch as err {
        MsgBox("Configuration file is corrupted or invalid.`n`nError: " . err.Message . "`n`nThe default configuration will be used.", "Config Load Error", 48)
        
        ; Restore defaults (only if we had them backed up)
        if (defaultHotkeys.Length > 0)
            hotkeyCategories := defaultHotkeys
        if (defaultHotstrings.Length > 0)
            hotstringCategories := defaultHotstrings
        if (defaultWiki.Length > 0)
            wikiCategories := defaultWiki
        if (defaultTabs.Length > 0)
            customTabs := defaultTabs
        
        tabMetadata := defaultTabMeta
        
        return false
    }
}

ExportConfig() {
    exportFile := FileSelect("S16", "hotkey_config_backup.ini", "Export Configuration", "INI Files (*.ini)")
    if (exportFile = "")
        return
    
    if (!InStr(exportFile, ".ini"))
        exportFile .= ".ini"
    
    if SaveConfiguration() {
        SplitPath(A_LineFile,, &guiDir)
        configFile := guiDir . "\config.ini"
        
        try {
            FileCopy(configFile, exportFile, 1)
            MsgBox("Configuration exported successfully to:`n" . exportFile, "Export Complete", 64)
        } catch as err {
            MsgBox("Export failed: " . err.Message, "Export Error", 16)
        }
    }
}

ImportConfig() {
    importFile := FileSelect(3, , "Import Configuration", "INI Files (*.ini)")
    if (importFile = "")
        return
    
    result := MsgBox("This will replace your current configuration. Continue?", "Confirm Import", 4 + 48)
    if (result = "No")
        return
    
    SplitPath(A_LineFile,, &guiDir)
    configFile := guiDir . "\config.ini"
    
    try {
        FileCopy(importFile, configFile, 1)
        if LoadConfiguration() {
            MsgBox("Configuration imported successfully! Please restart the application.", "Import Complete", 64)
        }
    } catch as err {
        MsgBox("Import failed: " . err.Message, "Import Error", 16)
    }
}

; ===========================
; TAB MANAGEMENT (Built-in & Custom)
; ===========================

AddCustomTab(tabListView, customTabDropdown := "") {
    global customTabs, MyGui

    try {
        ownerHwnd := MyGui.Hwnd
    } catch {
        MsgBox("Main GUI not available.", "Error", 48)
        return
    }

    inputGui := Gui("+Owner" . ownerHwnd, "Add Custom Tab")
    inputGui.SetFont("s9", "Segoe UI")
    
    inputGui.Add("Text", "x10 y10 w300", "Tab Name:")
    nameEdit := inputGui.Add("Edit", "x10 y30 w300 h25")
    
    inputGui.Add("Text", "x10 y65 w300", "Icon (single emoji or character):")
    iconEdit := inputGui.Add("Edit", "x10 y85 w300 h25", "📌")
    
    inputGui.Add("Text", "x10 y120 w300", "Display Order (lower numbers appear first):")
    orderEdit := inputGui.Add("Edit", "x10 y140 w300 h25", "50")
    
    addBtn := inputGui.Add("Button", "x10 y175 w145 h30 Default", "Add Tab")
    cancelBtn := inputGui.Add("Button", "x165 y175 w145 h30", "Cancel")
    
    addBtn.OnEvent("Click", (*) => SaveNewTab())
    cancelBtn.OnEvent("Click", (*) => inputGui.Destroy())
    
    SaveNewTab() {
        tabName := Trim(nameEdit.Value)
        tabIcon := Trim(iconEdit.Value)
        tabOrder := orderEdit.Value
        
        if (tabName = "") {
            MsgBox("Please enter a tab name.", "Invalid Input", 48)
            return
        }
        
        if (tabIcon = "")
            tabIcon := "📌"
        
        if (tabOrder = "" || !IsNumber(tabOrder))
            tabOrder := 50
        
        ; Check for duplicate names
        global tabMetadata
        if (tabMetadata.hotkeys.name = tabName || tabMetadata.hotstrings.name = tabName || 
            tabMetadata.wiki.name = tabName || tabMetadata.favorites.name = tabName) {
            MsgBox("A tab with this name already exists!", "Duplicate Name", 48)
            return
        }
        
        for tab in customTabs {
            if (tab.name = tabName) {
                MsgBox("A tab with this name already exists!", "Duplicate Name", 48)
                return
            }
        }
        
        newTab := {name: tabName, icon: tabIcon, order: Integer(tabOrder), categories: []}
        customTabs.Push(newTab)
        
        tabListView.Add("", "Custom", tabName, tabIcon, "✓", tabOrder)
        
        ; Refresh the custom tab content dropdown if it was passed
        if (customTabDropdown != "" && IsObject(customTabDropdown)) {
            customTabDropdown.Delete()
            for tab in customTabs {
                customTabDropdown.Add([tab.name])
            }
            ; Select the newly added tab
            customTabDropdown.Choose(customTabs.Length)
        }
        
        inputGui.Destroy()
        MsgBox("Tab added successfully!`n`nNow go to the 'Custom Tab Content' settings tab to add categories and items to this tab.", "Success", 64)
    }
    
    inputGui.Show("w320 h215")
}

EditAnyTab(tabListView, customTabDropdown := "") {
    global customTabs, tabMetadata, MyGui
    
    selectedRow := tabListView.GetNext()
    if (selectedRow = 0) {
        MsgBox("Please select a tab to edit.", "No Selection", 48)
        return
    }
    
    tabType := tabListView.GetText(selectedRow, 1)
    tabName := tabListView.GetText(selectedRow, 2)
    tabIcon := tabListView.GetText(selectedRow, 3)
    tabOrder := tabListView.GetText(selectedRow, 5)
    
    ; Determine which tab we're editing
    isBuiltin := (tabType = "Built-in")
    builtinKey := ""
    customIndex := 0
    
    if (isBuiltin) {
        ; Find which built-in tab
        if (tabMetadata.hotkeys.name = tabName)
            builtinKey := "hotkeys"
        else if (tabMetadata.hotstrings.name = tabName)
            builtinKey := "hotstrings"
        else if (tabMetadata.wiki.name = tabName)
            builtinKey := "wiki"
        else if (tabMetadata.favorites.name = tabName)
            builtinKey := "favorites"
    } else {
        ; Find custom tab index
        for index, tab in customTabs {
            if (tab.name = tabName) {
                customIndex := index
                break
            }
        }
    }

    try {
        ownerHwnd := MyGui.Hwnd
    } catch {
        MsgBox("Main GUI not available.", "Error", 48)
        return
    }

    inputGui := Gui("+Owner" . ownerHwnd, "Edit Tab")
    inputGui.SetFont("s9", "Segoe UI")
    
    inputGui.Add("Text", "x10 y10 w300", "Tab Name:")
    nameEdit := inputGui.Add("Edit", "x10 y30 w300 h25", tabName)
    
    inputGui.Add("Text", "x10 y65 w300", "Icon (single emoji or character):")
    iconEdit := inputGui.Add("Edit", "x10 y85 w300 h25", tabIcon)
    
    inputGui.Add("Text", "x10 y120 w300", "Display Order (lower numbers appear first):")
    orderEdit := inputGui.Add("Edit", "x10 y140 w300 h25", tabOrder)
    
    saveBtn := inputGui.Add("Button", "x10 y175 w145 h30 Default", "Save")
    cancelBtn := inputGui.Add("Button", "x165 y175 w145 h30", "Cancel")
    
    saveBtn.OnEvent("Click", (*) => SaveEditedTab())
    cancelBtn.OnEvent("Click", (*) => inputGui.Destroy())
    
    SaveEditedTab() {
        newName := Trim(nameEdit.Value)
        newIcon := Trim(iconEdit.Value)
        newOrder := orderEdit.Value
        
        if (newName = "") {
            MsgBox("Please enter a tab name.", "Invalid Input", 48)
            return
        }
        
        if (newIcon = "")
            newIcon := "📌"
        
        if (newOrder = "" || !IsNumber(newOrder))
            newOrder := tabOrder
        
        ; Check for duplicate names (excluding current tab)
        if (newName != tabName) {
            if (isBuiltin) {
                ; Check against other built-in tabs
                for key, meta in tabMetadata.OwnProps() {
                    if (key != builtinKey && meta.name = newName) {
                        MsgBox("A tab with this name already exists!", "Duplicate Name", 48)
                        return
                    }
                }
            }
            ; Check against custom tabs
            for index, tab in customTabs {
                if ((!isBuiltin && index != customIndex) || isBuiltin) {
                    if (tab.name = newName) {
                        MsgBox("A tab with this name already exists!", "Duplicate Name", 48)
                        return
                    }
                }
            }
        }
        
        ; Update the tab
        if (isBuiltin) {
            tabMetadata.%builtinKey%.name := newName
            tabMetadata.%builtinKey%.icon := newIcon
            tabMetadata.%builtinKey%.order := Integer(newOrder)
        } else if (customIndex > 0) {
            customTabs[customIndex].name := newName
            customTabs[customIndex].icon := newIcon
            customTabs[customIndex].order := Integer(newOrder)
            
            ; Refresh the custom tab content dropdown if it was passed (and this is a custom tab)
            if (customTabDropdown != "" && IsObject(customTabDropdown)) {
                currentSelection := customTabDropdown.Value
                customTabDropdown.Delete()
                for tab in customTabs {
                    customTabDropdown.Add([tab.name])
                }
                ; Reselect the same index
                if (currentSelection > 0 && currentSelection <= customTabs.Length) {
                    customTabDropdown.Choose(currentSelection)
                }
            }
        }
        
        tabListView.Modify(selectedRow, "", tabType, newName, newIcon, tabListView.GetText(selectedRow, 4), newOrder)
        
        inputGui.Destroy()
        MsgBox("Tab updated successfully! Save and reload to see changes.", "Success", 64)
    }
    
    inputGui.Show("w320 h215")
}

ToggleTabVisibility(tabListView) {
    global tabMetadata
    
    selectedRow := tabListView.GetNext()
    if (selectedRow = 0) {
        MsgBox("Please select a tab to show/hide.", "No Selection", 48)
        return
    }
    
    tabType := tabListView.GetText(selectedRow, 1)
    
    if (tabType != "Built-in") {
        MsgBox("Only built-in tabs can be hidden. Custom tabs must be deleted.", "Invalid Operation", 48)
        return
    }
    
    tabName := tabListView.GetText(selectedRow, 2)
    
    ; Find which built-in tab
    builtinKey := ""
    if (tabMetadata.hotkeys.name = tabName)
        builtinKey := "hotkeys"
    else if (tabMetadata.hotstrings.name = tabName)
        builtinKey := "hotstrings"
    else if (tabMetadata.wiki.name = tabName)
        builtinKey := "wiki"
    else if (tabMetadata.favorites.name = tabName)
        builtinKey := "favorites"
    
    if (builtinKey = "") {
        MsgBox("Could not find tab to toggle.", "Error", 16)
        return
    }
    
    ; Toggle visibility
    tabMetadata.%builtinKey%.visible := !tabMetadata.%builtinKey%.visible
    newVisibleText := tabMetadata.%builtinKey%.visible ? "✓" : "✗"
    
    tabListView.Modify(selectedRow, "", , , , newVisibleText, )
    
    MsgBox("Tab visibility toggled! Save and reload to see changes.", "Success", 64)
}

DeleteAnyTab(tabListView, customTabDropdown := "") {
    global customTabs
    
    selectedRow := tabListView.GetNext()
    if (selectedRow = 0) {
        MsgBox("Please select a tab to delete.", "No Selection", 48)
        return
    }
    
    tabType := tabListView.GetText(selectedRow, 1)
    tabName := tabListView.GetText(selectedRow, 2)
    
    if (tabType = "Built-in") {
        MsgBox("Built-in tabs cannot be deleted. Use 'Show/Hide' to hide them instead.", "Cannot Delete", 48)
        return
    }
    
    ; Find custom tab index
    customIndex := 0
    for index, tab in customTabs {
        if (tab.name = tabName) {
            customIndex := index
            break
        }
    }
    
    if (customIndex = 0) {
        MsgBox("Could not find tab to delete.", "Error", 16)
        return
    }
    
    catCount := customTabs[customIndex].HasOwnProp("categories") && IsObject(customTabs[customIndex].categories) ? customTabs[customIndex].categories.Length : 0
    
    msg := "Are you sure you want to delete the tab '" . tabName . "'?"
    if (catCount > 0)
        msg .= "`n`nThis tab has " . catCount . " categories with items that will be lost!"
    
    result := MsgBox(msg, "Confirm Delete", 4 + 48)
    if (result = "No")
        return
    
    customTabs.RemoveAt(customIndex)
    tabListView.Delete(selectedRow)
    
    ; Refresh the custom tab content dropdown if it was passed
    if (customTabDropdown != "" && IsObject(customTabDropdown)) {
        customTabDropdown.Delete()
        for tab in customTabs {
            customTabDropdown.Add([tab.name])
        }
        ; Select first tab if any remain
        if (customTabs.Length > 0) {
            customTabDropdown.Choose(1)
        }
    }
    
    MsgBox("Tab deleted successfully! Save settings and reload to apply changes.", "Success", 64)
}

RestoreDefaultTabs(tabListView) {
    global tabMetadata
    
    result := MsgBox("This will restore all built-in tabs to their default names, icons, order, and visibility.`n`nCustom tabs will not be affected.`n`nContinue?", "Restore Defaults", 4 + 48)
    if (result = "No")
        return
    
    ; Reset to defaults
    tabMetadata.hotkeys := {name: "Hotkeys", icon: "📋", visible: true, order: 1}
    tabMetadata.hotstrings := {name: "Hotstrings", icon: "💬", visible: true, order: 2}
    tabMetadata.wiki := {name: "Wiki Shortcuts", icon: "📝", visible: true, order: 3}
    tabMetadata.favorites := {name: "Favorites", icon: "⭐", visible: true, order: 999}
    
    ; Refresh the ListView
    tabListView.Delete()
    
    ; Re-add built-in tabs
    tabListView.Add("", "Built-in", tabMetadata.hotkeys.name, tabMetadata.hotkeys.icon, "✓", tabMetadata.hotkeys.order)
    tabListView.Add("", "Built-in", tabMetadata.hotstrings.name, tabMetadata.hotstrings.icon, "✓", tabMetadata.hotstrings.order)
    tabListView.Add("", "Built-in", tabMetadata.wiki.name, tabMetadata.wiki.icon, "✓", tabMetadata.wiki.order)
    tabListView.Add("", "Built-in", tabMetadata.favorites.name, tabMetadata.favorites.icon, "✓", tabMetadata.favorites.order)
    
    ; Re-add custom tabs
    global customTabs
    for tab in customTabs {
        tabListView.Add("", "Custom", tab.name, tab.icon, "✓", tab.order ? tab.order : (50 + A_Index))
    }
    
    MsgBox("Default tab settings restored! Save and reload to see changes.", "Success", 64)
}

RestoreAllDefaults() {
    result := MsgBox("⚠️ WARNING ⚠️`n`nThis will reset EVERYTHING to default settings:`n`n• All hotkeys`n• All hotstrings`n• All wiki shortcuts`n• All tab customizations`n• All custom tabs will be deleted`n`nYour favorites will be preserved.`n`nThis CANNOT be undone!`n`nAre you sure?", "Restore ALL Defaults", 4 + 48)
    if (result = "No")
        return
    
    ; Confirm again
    result2 := MsgBox("Are you REALLY sure?`n`nAll your customizations will be lost!", "Final Confirmation", 4 + 48)
    if (result2 = "No")
        return
    
    ; Delete the config file
    SplitPath(A_LineFile,, &guiDir)
    configFile := guiDir . "\config.ini"
    
    try {
        if FileExist(configFile)
            FileDelete(configFile)
        
        ; Reinitialize global variables to defaults
        global customTabs := []
        global tabMetadata := {
            hotkeys: {name: "Hotkeys", icon: "📋", visible: true, order: 1},
            hotstrings: {name: "Hotstrings", icon: "💬", visible: true, order: 2},
            wiki: {name: "Wiki Shortcuts", icon: "📝", visible: true, order: 3},
            favorites: {name: "Favorites", icon: "⭐", visible: true, order: 999}
        }
        
        MsgBox("All settings restored to defaults!`n`nThe application will now reload.", "Restored", 64)
        
        ; Reload the script
        Reload()
    } catch as err {
        MsgBox("Failed to restore defaults: " . err.Message, "Error", 16)
    }
}

; ===========================
; SETTINGS GUI
; ===========================

ShowSettings() {
    global hotkeyCategories, hotstringCategories, wikiCategories, customTabs, MyGui

    ; Ensure MyGui exists
    try {
        if (!IsSet(MyGui) || !MyGui.Hwnd) {
            MsgBox("Main GUI not available. Please open the main window first.", "Error", 48)
            return
        }
        ownerHwnd := MyGui.Hwnd
    } catch {
        MsgBox("Main GUI not available. Please open the main window first.", "Error", 48)
        return
    }

    settingsGui := Gui("+Resize +Owner" . ownerHwnd, "⚙️ Settings - Configure Shortcuts")
    settingsGui.SetFont("s9", "Segoe UI")
    settingsGui.BackColor := "0xF0F0F0"
    
    ; Add tabs for different settings - NOW INCLUDES Custom Tab Content
    settingsTab := settingsGui.Add("Tab3", "x10 y10 w680 h500", ["Hotkeys", "Hotstrings", "Wiki Shortcuts", "🎨 Customize Tabs", "🎯 Custom Tab Content"])
    
    ; === HOTKEYS SETTINGS TAB ===
    settingsTab.UseTab(1)
    settingsGui.Add("Text", "x20 y40 w200", "Categories:")
    categoryListHK := settingsGui.Add("ListBox", "x20 y60 w200 h350", [])
    
    settingsGui.Add("Text", "x240 y40 w440", "Items in Selected Category:")
    itemListHK := settingsGui.Add("ListView", "x240 y60 w440 h350 +Grid", ["Hotkey", "Description"])
    itemListHK.ModifyCol(1, 180)
    itemListHK.ModifyCol(2, 240)
    
    ; Category buttons
    addCatBtnHK := settingsGui.Add("Button", "x20 y420 w95 h30", "➕ Add Category")
    addCatBtnHK.OnEvent("Click", (*) => AddCategory("Hotkeys", categoryListHK))
    
    renameCatBtnHK := settingsGui.Add("Button", "x120 y420 w95 h30", "✏️ Rename")
    renameCatBtnHK.OnEvent("Click", (*) => RenameCategory("Hotkeys", categoryListHK))
    
    delCatBtnHK := settingsGui.Add("Button", "x20 y455 w95 h30", "🗑️ Delete")
    delCatBtnHK.OnEvent("Click", (*) => DeleteCategory("Hotkeys", categoryListHK, itemListHK))
    
    ; Item buttons
    addItemBtnHK := settingsGui.Add("Button", "x240 y420 w140 h30", "➕ Add Hotkey")
    addItemBtnHK.OnEvent("Click", (*) => AddItem("Hotkeys", categoryListHK, itemListHK))
    
    editItemBtnHK := settingsGui.Add("Button", "x390 y420 w140 h30", "✏️ Edit Hotkey")
    editItemBtnHK.OnEvent("Click", (*) => EditItem("Hotkeys", categoryListHK, itemListHK))
    
    delItemBtnHK := settingsGui.Add("Button", "x540 y420 w140 h30", "🗑️ Delete Hotkey")
    delItemBtnHK.OnEvent("Click", (*) => DeleteItem("Hotkeys", categoryListHK, itemListHK))
    
    ; === HOTSTRINGS SETTINGS TAB ===
    settingsTab.UseTab(2)
    settingsGui.Add("Text", "x20 y40 w200", "Categories:")
    categoryListHS := settingsGui.Add("ListBox", "x20 y60 w200 h350", [])
    
    settingsGui.Add("Text", "x240 y40 w440", "Items in Selected Category:")
    itemListHS := settingsGui.Add("ListView", "x240 y60 w440 h350 +Grid", ["Hotstring", "Description"])
    itemListHS.ModifyCol(1, 180)
    itemListHS.ModifyCol(2, 240)
    
    ; Category buttons
    addCatBtnHS := settingsGui.Add("Button", "x20 y420 w95 h30", "➕ Add Category")
    addCatBtnHS.OnEvent("Click", (*) => AddCategory("Hotstrings", categoryListHS))
    
    renameCatBtnHS := settingsGui.Add("Button", "x120 y420 w95 h30", "✏️ Rename")
    renameCatBtnHS.OnEvent("Click", (*) => RenameCategory("Hotstrings", categoryListHS))
    
    delCatBtnHS := settingsGui.Add("Button", "x20 y455 w95 h30", "🗑️ Delete")
    delCatBtnHS.OnEvent("Click", (*) => DeleteCategory("Hotstrings", categoryListHS, itemListHS))
    
    ; Item buttons
    addItemBtnHS := settingsGui.Add("Button", "x240 y420 w140 h30", "➕ Add Hotstring")
    addItemBtnHS.OnEvent("Click", (*) => AddItem("Hotstrings", categoryListHS, itemListHS))
    
    editItemBtnHS := settingsGui.Add("Button", "x390 y420 w140 h30", "✏️ Edit Hotstring")
    editItemBtnHS.OnEvent("Click", (*) => EditItem("Hotstrings", categoryListHS, itemListHS))
    
    delItemBtnHS := settingsGui.Add("Button", "x540 y420 w140 h30", "🗑️ Delete Hotstring")
    delItemBtnHS.OnEvent("Click", (*) => DeleteItem("Hotstrings", categoryListHS, itemListHS))
    
    ; === WIKI SHORTCUTS SETTINGS TAB ===
    settingsTab.UseTab(3)
    settingsGui.Add("Text", "x20 y40 w200", "Categories:")
    categoryListWS := settingsGui.Add("ListBox", "x20 y60 w200 h350", [])
    
    settingsGui.Add("Text", "x240 y40 w440", "Items in Selected Category:")
    itemListWS := settingsGui.Add("ListView", "x240 y60 w440 h350 +Grid", ["Shortcut", "Description"])
    itemListWS.ModifyCol(1, 180)
    itemListWS.ModifyCol(2, 240)
    
    ; Category buttons
    addCatBtnWS := settingsGui.Add("Button", "x20 y420 w95 h30", "➕ Add Category")
    addCatBtnWS.OnEvent("Click", (*) => AddCategory("Wiki", categoryListWS))
    
    renameCatBtnWS := settingsGui.Add("Button", "x120 y420 w95 h30", "✏️ Rename")
    renameCatBtnWS.OnEvent("Click", (*) => RenameCategory("Wiki", categoryListWS))
    
    delCatBtnWS := settingsGui.Add("Button", "x20 y455 w95 h30", "🗑️ Delete")
    delCatBtnWS.OnEvent("Click", (*) => DeleteCategory("Wiki", categoryListWS, itemListWS))
    
    ; Item buttons
    addItemBtnWS := settingsGui.Add("Button", "x240 y420 w140 h30", "➕ Add Shortcut")
    addItemBtnWS.OnEvent("Click", (*) => AddItem("Wiki", categoryListWS, itemListWS))
    
    editItemBtnWS := settingsGui.Add("Button", "x390 y420 w140 h30", "✏️ Edit Shortcut")
    editItemBtnWS.OnEvent("Click", (*) => EditItem("Wiki", categoryListWS, itemListWS))
    
    delItemBtnWS := settingsGui.Add("Button", "x540 y420 w140 h30", "🗑️ Delete Shortcut")
    delItemBtnWS.OnEvent("Click", (*) => DeleteItem("Wiki", categoryListWS, itemListWS))
    
    ; === CUSTOMIZE TABS ===
    settingsTab.UseTab(4)
    settingsGui.Add("Text", "x20 y40 w660", "Customize Tabs - Rename, reorder, hide/show, or create new tabs:")
    
    tabListView := settingsGui.Add("ListView", "x20 y65 w660 h350 +Grid", ["Type", "Tab Name", "Icon", "Visible", "Order"])
    tabListView.ModifyCol(1, 80)
    tabListView.ModifyCol(2, 250)
    tabListView.ModifyCol(3, 80)
    tabListView.ModifyCol(4, 80)
    tabListView.ModifyCol(5, 150)
    
    ; Populate with built-in tabs first
    global tabMetadata
    tabListView.Add("", "Built-in", tabMetadata.hotkeys.name, tabMetadata.hotkeys.icon, tabMetadata.hotkeys.visible ? "✓" : "✗", tabMetadata.hotkeys.order)
    tabListView.Add("", "Built-in", tabMetadata.hotstrings.name, tabMetadata.hotstrings.icon, tabMetadata.hotstrings.visible ? "✓" : "✗", tabMetadata.hotstrings.order)
    tabListView.Add("", "Built-in", tabMetadata.wiki.name, tabMetadata.wiki.icon, tabMetadata.wiki.visible ? "✓" : "✗", tabMetadata.wiki.order)
    tabListView.Add("", "Built-in", tabMetadata.favorites.name, tabMetadata.favorites.icon, tabMetadata.favorites.visible ? "✓" : "✗", tabMetadata.favorites.order)
    
    ; Then add custom tabs
    for tab in customTabs {
        tabListView.Add("", "Custom", tab.name, tab.icon, "✓", tab.order ? tab.order : (50 + A_Index))
    }
    
    settingsGui.Add("Text", "x20 y465 w660 cGray", "Note: Built-in tabs can be renamed/hidden/reordered. Custom tabs can be fully deleted. Save to apply changes.")
    
    ; === CUSTOM TAB CONTENT ===
    settingsTab.UseTab(5)
    settingsGui.Add("Text", "x20 y40 w200", "Select Custom Tab:")
    customTabDropdown := settingsGui.Add("DropDownList", "x20 y60 w200", [])
    
    ; Populate dropdown with custom tabs
    for tab in customTabs {
        customTabDropdown.Add([tab.name])
    }
    
    settingsGui.Add("Text", "x20 y100 w200", "Categories:")
    categoryListCustom := settingsGui.Add("ListBox", "x20 y120 w200 h260", [])
    
    settingsGui.Add("Text", "x240 y100 w440", "Items in Selected Category:")
    itemListCustom := settingsGui.Add("ListView", "x240 y120 w440 h260 +Grid", ["Item", "Description"])
    itemListCustom.ModifyCol(1, 180)
    itemListCustom.ModifyCol(2, 240)
    
    ; Category buttons for custom tabs
    addCatBtnCustom := settingsGui.Add("Button", "x20 y390 w95 h30", "➕ Add Category")
    addCatBtnCustom.OnEvent("Click", (*) => AddCustomCategory(customTabDropdown, categoryListCustom))
    
    renameCatBtnCustom := settingsGui.Add("Button", "x120 y390 w95 h30", "✏️ Rename")
    renameCatBtnCustom.OnEvent("Click", (*) => RenameCustomCategory(customTabDropdown, categoryListCustom))
    
    delCatBtnCustom := settingsGui.Add("Button", "x20 y425 w95 h30", "🗑️ Delete")
    delCatBtnCustom.OnEvent("Click", (*) => DeleteCustomCategory(customTabDropdown, categoryListCustom, itemListCustom))
    
    ; Item buttons for custom tabs
    addItemBtnCustom := settingsGui.Add("Button", "x240 y390 w140 h30", "➕ Add Item")
    addItemBtnCustom.OnEvent("Click", (*) => AddCustomItem(customTabDropdown, categoryListCustom, itemListCustom))
    
    editItemBtnCustom := settingsGui.Add("Button", "x390 y390 w140 h30", "✏️ Edit Item")
    editItemBtnCustom.OnEvent("Click", (*) => EditCustomItem(customTabDropdown, categoryListCustom, itemListCustom))
    
    delItemBtnCustom := settingsGui.Add("Button", "x540 y390 w140 h30", "🗑️ Delete Item")
    delItemBtnCustom.OnEvent("Click", (*) => DeleteCustomItem(customTabDropdown, categoryListCustom, itemListCustom))
    
    ; Note at bottom
    settingsGui.Add("Text", "x20 y465 w660 cGray", "Note: First create a custom tab in the 'Customize Tabs' section, then add content to it here.")
    
    ; NOW create the tab management buttons for Tab 4 (after customTabDropdown exists)
    settingsTab.UseTab(4)
    addTabBtn := settingsGui.Add("Button", "x20 y425 w100 h30", "➕ New Tab")
    addTabBtn.OnEvent("Click", (*) => AddCustomTab(tabListView, customTabDropdown))
    
    editTabBtn := settingsGui.Add("Button", "x130 y425 w100 h30", "✏️ Edit Tab")
    editTabBtn.OnEvent("Click", (*) => EditAnyTab(tabListView, customTabDropdown))
    
    toggleVisBtn := settingsGui.Add("Button", "x240 y425 w120 h30", "👁️ Show/Hide")
    toggleVisBtn.OnEvent("Click", (*) => ToggleTabVisibility(tabListView))
    
    delTabBtn := settingsGui.Add("Button", "x370 y425 w140 h30", "🗑️ Delete Tab")
    delTabBtn.OnEvent("Click", (*) => DeleteAnyTab(tabListView, customTabDropdown))
    
    restoreBtn := settingsGui.Add("Button", "x520 y425 w160 h30", "🔄 Restore Defaults")
    restoreBtn.OnEvent("Click", (*) => RestoreDefaultTabs(tabListView))
    
    ; Set up change events
    customTabDropdown.OnEvent("Change", (*) => LoadCustomTabContent(customTabDropdown, categoryListCustom))
    
    settingsTab.UseTab()
    
    ; Bottom buttons
    saveBtn := settingsGui.Add("Button", "x10 y520 w120 h35", "💾 Save & Close")
    saveBtn.OnEvent("Click", (*) => SaveSettings(settingsGui))
    
    cancelBtn := settingsGui.Add("Button", "x140 y520 w120 h35", "❌ Cancel")
    cancelBtn.OnEvent("Click", (*) => settingsGui.Destroy())
    
    restoreAllBtn := settingsGui.Add("Button", "x270 y520 w150 h35", "🔄 Restore ALL")
    restoreAllBtn.OnEvent("Click", (*) => RestoreAllDefaults())
    restoreAllBtn.ToolTip := "Restore ALL settings to original defaults"
    
    exportConfigBtn := settingsGui.Add("Button", "x430 y520 w130 h35", "📤 Export")
    exportConfigBtn.OnEvent("Click", (*) => ExportConfig())
    
    importConfigBtn := settingsGui.Add("Button", "x570 y520 w120 h35", "📥 Import")
    importConfigBtn.OnEvent("Click", (*) => ImportConfig())
    
    ; Set up change events
    categoryListHK.OnEvent("Change", (*) => LoadCategoryItems("Hotkeys", categoryListHK, itemListHK))
    categoryListHS.OnEvent("Change", (*) => LoadCategoryItems("Hotstrings", categoryListHS, itemListHS))
    categoryListWS.OnEvent("Change", (*) => LoadCategoryItems("Wiki", categoryListWS, itemListWS))
    categoryListCustom.OnEvent("Change", (*) => LoadCustomCategoryItems(customTabDropdown, categoryListCustom, itemListCustom))
    
    ; Load initial data
    LoadSettingsCategories(categoryListHK, categoryListHS, categoryListWS)
    
    ; Load first custom tab if available
    if (customTabs.Length > 0) {
        customTabDropdown.Choose(1)
        LoadCustomTabContent(customTabDropdown, categoryListCustom)
    }
    
    settingsGui.Show("w700 h565")
}

; === CUSTOM TAB CONTENT FUNCTIONS ===

LoadCustomTabContent(dropdown, categoryList) {
    global customTabs
    
    tabIndex := dropdown.Value
    if (tabIndex = 0 || tabIndex > customTabs.Length)
        return
    
    tab := customTabs[tabIndex]
    
    categoryList.Delete()
    
    if (tab.HasOwnProp("categories") && IsObject(tab.categories)) {
        for cat in tab.categories {
            categoryList.Add([cat.name])
        }
    }
}

LoadCustomCategoryItems(dropdown, categoryList, itemList) {
    global customTabs
    
    tabIndex := dropdown.Value
    catIndex := categoryList.Value
    
    if (tabIndex = 0 || catIndex = 0)
        return
    
    tab := customTabs[tabIndex]
    itemList.Delete()
    
    if (tab.HasOwnProp("categories") && IsObject(tab.categories)) {
        if (catIndex <= tab.categories.Length) {
            category := tab.categories[catIndex]
            if (category.HasOwnProp("items") && IsObject(category.items)) {
                for item in category.items {
                    itemList.Add("", item.item, item.description)
                }
            }
        }
    }
}

AddCustomCategory(dropdown, categoryList) {
    global customTabs
    
    tabIndex := dropdown.Value
    if (tabIndex = 0) {
        MsgBox("Please select a custom tab first.", "No Tab Selected", 48)
        return
    }
    
    newCat := InputBox("Enter new category name:", "Add Category")
    if (newCat.Result = "Cancel")
        return
    
    if (!customTabs[tabIndex].HasOwnProp("categories"))
        customTabs[tabIndex].categories := []
    
    customTabs[tabIndex].categories.Push({name: newCat.Value, items: []})
    categoryList.Add([newCat.Value])
    
    MsgBox("Category added successfully!", "Success", 64)
}

RenameCustomCategory(dropdown, categoryList) {
    global customTabs
    
    tabIndex := dropdown.Value
    catIndex := categoryList.Value
    
    if (tabIndex = 0 || catIndex = 0) {
        MsgBox("Please select a category to rename.", "No Selection", 48)
        return
    }
    
    tab := customTabs[tabIndex]
    if (!tab.HasOwnProp("categories") || catIndex > tab.categories.Length)
        return
    
    oldName := tab.categories[catIndex].name
    newName := InputBox("Enter new name for category:", "Rename Category", , oldName)
    
    if (newName.Result = "Cancel")
        return
    
    tab.categories[catIndex].name := newName.Value
    
    ; Refresh list
    categoryList.Delete()
    for cat in tab.categories {
        categoryList.Add([cat.name])
    }
    categoryList.Choose(catIndex)
    
    MsgBox("Category renamed successfully!", "Success", 64)
}

DeleteCustomCategory(dropdown, categoryList, itemList) {
    global customTabs
    
    tabIndex := dropdown.Value
    catIndex := categoryList.Value
    
    if (tabIndex = 0 || catIndex = 0) {
        MsgBox("Please select a category to delete.", "No Selection", 48)
        return
    }
    
    result := MsgBox("Are you sure you want to delete this category and all its items?", "Confirm Delete", 4 + 48)
    if (result = "No")
        return
    
    tab := customTabs[tabIndex]
    if (tab.HasOwnProp("categories")) {
        tab.categories.RemoveAt(catIndex)
    }
    
    categoryList.Delete()
    for cat in tab.categories {
        categoryList.Add([cat.name])
    }
    
    itemList.Delete()
    MsgBox("Category deleted successfully!", "Success", 64)
}

AddCustomItem(dropdown, categoryList, itemList) {
    global MyGui, customTabs
    
    tabIndex := dropdown.Value
    catIndex := categoryList.Value
    
    if (tabIndex = 0 || catIndex = 0) {
        MsgBox("Please select a category first.", "No Category Selected", 48)
        return
    }

    try {
        ownerHwnd := MyGui.Hwnd
    } catch {
        MsgBox("Main GUI not available.", "Error", 48)
        return
    }

    inputGui := Gui("+Owner" . ownerHwnd, "Add Item")
    inputGui.SetFont("s9", "Segoe UI")
    
    inputGui.Add("Text", "x10 y10 w100", "Item:")
    keyEdit := inputGui.Add("Edit", "x10 y30 w300 h25")
    
    inputGui.Add("Text", "x10 y65 w100", "Description:")
    descEdit := inputGui.Add("Edit", "x10 y85 w300 h25")
    
    addBtn := inputGui.Add("Button", "x10 y120 w145 h30 Default", "Add")
    cancelBtn := inputGui.Add("Button", "x165 y120 w145 h30", "Cancel")
    
    addBtn.OnEvent("Click", (*) => SaveNewCustomItem())
    cancelBtn.OnEvent("Click", (*) => inputGui.Destroy())
    
    SaveNewCustomItem() {
        keyVal := keyEdit.Value
        descVal := descEdit.Value
        
        if (keyVal = "" || descVal = "") {
            MsgBox("Please fill in all fields.", "Invalid Input", 48)
            return
        }
        
        tab := customTabs[tabIndex]
        if (!tab.categories[catIndex].HasOwnProp("items"))
            tab.categories[catIndex].items := []
        
        tab.categories[catIndex].items.Push({item: keyVal, description: descVal})
        itemList.Add("", keyVal, descVal)
        
        inputGui.Destroy()
        MsgBox("Item added successfully!", "Success", 64)
    }
    
    inputGui.Show("w320 h160")
}

EditCustomItem(dropdown, categoryList, itemList) {
    global MyGui, customTabs
    
    tabIndex := dropdown.Value
    catIndex := categoryList.Value
    itemIndex := itemList.GetNext()
    
    if (tabIndex = 0 || catIndex = 0 || itemIndex = 0) {
        MsgBox("Please select an item to edit.", "No Selection", 48)
        return
    }

    tab := customTabs[tabIndex]
    item := tab.categories[catIndex].items[itemIndex]

    try {
        ownerHwnd := MyGui.Hwnd
    } catch {
        MsgBox("Main GUI not available.", "Error", 48)
        return
    }

    inputGui := Gui("+Owner" . ownerHwnd, "Edit Item")
    inputGui.SetFont("s9", "Segoe UI")
    
    inputGui.Add("Text", "x10 y10 w100", "Item:")
    keyEdit := inputGui.Add("Edit", "x10 y30 w300 h25", item.item)
    
    inputGui.Add("Text", "x10 y65 w100", "Description:")
    descEdit := inputGui.Add("Edit", "x10 y85 w300 h25", item.description)
    
    saveBtn := inputGui.Add("Button", "x10 y120 w145 h30 Default", "Save")
    cancelBtn := inputGui.Add("Button", "x165 y120 w145 h30", "Cancel")
    
    saveBtn.OnEvent("Click", (*) => SaveEditedCustomItem())
    cancelBtn.OnEvent("Click", (*) => inputGui.Destroy())
    
    SaveEditedCustomItem() {
        keyVal := keyEdit.Value
        descVal := descEdit.Value
        
        if (keyVal = "" || descVal = "") {
            MsgBox("Please fill in all fields.", "Invalid Input", 48)
            return
        }
        
        item.item := keyVal
        item.description := descVal
        
        itemList.Modify(itemIndex, "", keyVal, descVal)
        
        inputGui.Destroy()
        MsgBox("Item updated successfully!", "Success", 64)
    }
    
    inputGui.Show("w320 h160")
}

DeleteCustomItem(dropdown, categoryList, itemList) {
    global customTabs
    
    tabIndex := dropdown.Value
    catIndex := categoryList.Value
    itemIndex := itemList.GetNext()
    
    if (tabIndex = 0 || catIndex = 0 || itemIndex = 0) {
        MsgBox("Please select an item to delete.", "No Selection", 48)
        return
    }
    
    result := MsgBox("Are you sure you want to delete this item?", "Confirm Delete", 4 + 48)
    if (result = "No")
        return
    
    tab := customTabs[tabIndex]
    tab.categories[catIndex].items.RemoveAt(itemIndex)
    itemList.Delete(itemIndex)
    
    MsgBox("Item deleted successfully!", "Success", 64)
}

LoadSettingsCategories(catListHK, catListHS, catListWS) {
    global hotkeyCategories, hotstringCategories, wikiCategories
    
    ; Load Hotkey categories
    catListHK.Delete()
    for cat in hotkeyCategories
        catListHK.Add([cat.name])
    
    ; Load Hotstring categories
    catListHS.Delete()
    for cat in hotstringCategories
        catListHS.Add([cat.name])
    
    ; Load Wiki categories
    catListWS.Delete()
    for cat in wikiCategories
        catListWS.Add([cat.name])
}

LoadCategoryItems(type, catList, itemList) {
    global hotkeyCategories, hotstringCategories, wikiCategories
    
    selectedIdx := catList.Value
    if (selectedIdx = 0)
        return
    
    itemList.Delete()
    
    categories := (type = "Hotkeys") ? hotkeyCategories : (type = "Hotstrings") ? hotstringCategories : wikiCategories
    
    if (selectedIdx > categories.Length)
        return
    
    category := categories[selectedIdx]
    itemsProp := (type = "Hotkeys") ? "hotkeys" : (type = "Hotstrings") ? "hotstrings" : "shortcuts"
    keyProp := (type = "Hotkeys") ? "hotkey" : (type = "Hotstrings") ? "hotstring" : "shortcut"
    
    ; For regular objects, use HasOwnProp or just check if property exists
    try {
        items := category.%itemsProp%
        if (IsObject(items)) {
            for item in items {
                itemList.Add("", item.%keyProp%, item.description)
            }
        }
    }
}

AddCategory(type, catList) {
    newCat := InputBox("Enter new category name:", "Add Category")
    if (newCat.Result = "Cancel")
        return
    
    global hotkeyCategories, hotstringCategories, wikiCategories
    
    categories := (type = "Hotkeys") ? hotkeyCategories : (type = "Hotstrings") ? hotstringCategories : wikiCategories
    itemsProp := (type = "Hotkeys") ? "hotkeys" : (type = "Hotstrings") ? "hotstrings" : "shortcuts"
    
    newCategory := {name: newCat.Value}
    newCategory.%itemsProp% := []
    
    categories.Push(newCategory)
    catList.Add([newCat.Value])
    
    MsgBox("Category added successfully!", "Success", 64)
}

RenameCategory(type, catList) {
    selectedIdx := catList.Value
    if (selectedIdx = 0) {
        MsgBox("Please select a category to rename.", "No Selection", 48)
        return
    }
    
    global hotkeyCategories, hotstringCategories, wikiCategories
    categories := (type = "Hotkeys") ? hotkeyCategories : (type = "Hotstrings") ? hotstringCategories : wikiCategories
    
    oldName := categories[selectedIdx].name
    newName := InputBox("Enter new name for category:", "Rename Category", , oldName)
    
    if (newName.Result = "Cancel")
        return
    
    categories[selectedIdx].name := newName.Value
    
    ; Refresh list
    catList.Delete()
    for cat in categories
        catList.Add([cat.name])
    catList.Choose(selectedIdx)
    
    MsgBox("Category renamed successfully!", "Success", 64)
}

DeleteCategory(type, catList, itemList) {
    selectedIdx := catList.Value
    if (selectedIdx = 0) {
        MsgBox("Please select a category to delete.", "No Selection", 48)
        return
    }
    
    global hotkeyCategories, hotstringCategories, wikiCategories
    categories := (type = "Hotkeys") ? hotkeyCategories : (type = "Hotstrings") ? hotstringCategories : wikiCategories
    
    result := MsgBox("Are you sure you want to delete this category and all its items?", "Confirm Delete", 4 + 48)
    if (result = "No")
        return
    
    categories.RemoveAt(selectedIdx)
    catList.Delete()
    
    for cat in categories
        catList.Add([cat.name])
    
    itemList.Delete()
    MsgBox("Category deleted successfully!", "Success", 64)
}

AddItem(type, catList, itemList) {
    global MyGui
    selectedIdx := catList.Value
    if (selectedIdx = 0) {
        MsgBox("Please select a category first.", "No Category Selected", 48)
        return
    }
    
    global hotkeyCategories, hotstringCategories, wikiCategories
    categories := (type = "Hotkeys") ? hotkeyCategories : (type = "Hotstrings") ? hotstringCategories : wikiCategories

    keyLabel := (type = "Hotkeys") ? "Hotkey" : (type = "Hotstrings") ? "Hotstring" : "Shortcut"

    try {
        ownerHwnd := MyGui.Hwnd
    } catch {
        MsgBox("Main GUI not available.", "Error", 48)
        return
    }

    inputGui := Gui("+Owner" . ownerHwnd, "Add " . keyLabel)
    inputGui.SetFont("s9", "Segoe UI")
    
    inputGui.Add("Text", "x10 y10 w100", keyLabel . ":")
    keyEdit := inputGui.Add("Edit", "x10 y30 w300 h25")
    
    inputGui.Add("Text", "x10 y65 w100", "Description:")
    descEdit := inputGui.Add("Edit", "x10 y85 w300 h25")
    
    addBtn := inputGui.Add("Button", "x10 y120 w145 h30 Default", "Add")
    cancelBtn := inputGui.Add("Button", "x165 y120 w145 h30", "Cancel")
    
    addBtn.OnEvent("Click", (*) => SaveNewItem())
    cancelBtn.OnEvent("Click", (*) => inputGui.Destroy())
    
    SaveNewItem() {
        keyVal := keyEdit.Value
        descVal := descEdit.Value
        
        if (keyVal = "" || descVal = "") {
            MsgBox("Please fill in all fields.", "Invalid Input", 48)
            return
        }
        
        itemsProp := (type = "Hotkeys") ? "hotkeys" : (type = "Hotstrings") ? "hotstrings" : "shortcuts"
        keyProp := (type = "Hotkeys") ? "hotkey" : (type = "Hotstrings") ? "hotstring" : "shortcut"
        
        newItem := {}
        newItem.%keyProp% := keyVal
        newItem.description := descVal
        
        categories[selectedIdx].%itemsProp%.Push(newItem)
        itemList.Add("", keyVal, descVal)
        
        inputGui.Destroy()
        MsgBox("Item added successfully!", "Success", 64)
    }
    
    inputGui.Show("w320 h160")
}

EditItem(type, catList, itemList) {
    global MyGui
    catIdx := catList.Value
    itemIdx := itemList.GetNext()
    
    if (catIdx = 0 || itemIdx = 0) {
        MsgBox("Please select an item to edit.", "No Selection", 48)
        return
    }
    
    global hotkeyCategories, hotstringCategories, wikiCategories
    categories := (type = "Hotkeys") ? hotkeyCategories : (type = "Hotstrings") ? hotstringCategories : wikiCategories
    
    itemsProp := (type = "Hotkeys") ? "hotkeys" : (type = "Hotstrings") ? "hotstrings" : "shortcuts"
    keyProp := (type = "Hotkeys") ? "hotkey" : (type = "Hotstrings") ? "hotstring" : "shortcut"
    keyLabel := (type = "Hotkeys") ? "Hotkey" : (type = "Hotstrings") ? "Hotstring" : "Shortcut"

    item := categories[catIdx].%itemsProp%[itemIdx]

    try {
        ownerHwnd := MyGui.Hwnd
    } catch {
        MsgBox("Main GUI not available.", "Error", 48)
        return
    }

    inputGui := Gui("+Owner" . ownerHwnd, "Edit " . keyLabel)
    inputGui.SetFont("s9", "Segoe UI")
    
    inputGui.Add("Text", "x10 y10 w100", keyLabel . ":")
    keyEdit := inputGui.Add("Edit", "x10 y30 w300 h25", item.%keyProp%)
    
    inputGui.Add("Text", "x10 y65 w100", "Description:")
    descEdit := inputGui.Add("Edit", "x10 y85 w300 h25", item.description)
    
    saveBtn := inputGui.Add("Button", "x10 y120 w145 h30 Default", "Save")
    cancelBtn := inputGui.Add("Button", "x165 y120 w145 h30", "Cancel")
    
    saveBtn.OnEvent("Click", (*) => SaveEditedItem())
    cancelBtn.OnEvent("Click", (*) => inputGui.Destroy())
    
    SaveEditedItem() {
        keyVal := keyEdit.Value
        descVal := descEdit.Value
        
        if (keyVal = "" || descVal = "") {
            MsgBox("Please fill in all fields.", "Invalid Input", 48)
            return
        }
        
        item.%keyProp% := keyVal
        item.description := descVal
        
        itemList.Modify(itemIdx, "", keyVal, descVal)
        
        inputGui.Destroy()
        MsgBox("Item updated successfully!", "Success", 64)
    }
    
    inputGui.Show("w320 h160")
}

DeleteItem(type, catList, itemList) {
    catIdx := catList.Value
    itemIdx := itemList.GetNext()
    
    if (catIdx = 0 || itemIdx = 0) {
        MsgBox("Please select an item to delete.", "No Selection", 48)
        return
    }
    
    result := MsgBox("Are you sure you want to delete this item?", "Confirm Delete", 4 + 48)
    if (result = "No")
        return
    
    global hotkeyCategories, hotstringCategories, wikiCategories
    categories := (type = "Hotkeys") ? hotkeyCategories : (type = "Hotstrings") ? hotstringCategories : wikiCategories
    
    itemsProp := (type = "Hotkeys") ? "hotkeys" : (type = "Hotstrings") ? "hotstrings" : "shortcuts"
    
    categories[catIdx].%itemsProp%.RemoveAt(itemIdx)
    itemList.Delete(itemIdx)
    
    MsgBox("Item deleted successfully!", "Success", 64)
}

SaveSettings(settingsGui) {
    ; Show progress indicator
    progressGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Owner" . settingsGui.Hwnd, "Saving")
    progressGui.BackColor := "0x2196F3"
    progressGui.SetFont("s10 Bold", "Segoe UI")
    progressGui.Add("Text", "cWhite x20 y15 w200 Center", "💾 Saving configuration...")
    progressGui.Show("w240 h50 NoActivate")
    
    ; Save in background
    SetTimer(() => DoSave(settingsGui, progressGui), -50)
}

DoSave(settingsGui, progressGui) {
    if SaveConfiguration() {
        progressGui.Destroy()
        
        result := MsgBox("Settings saved successfully!`n`nWould you like to reload the main window now?`n(Click 'No' to continue editing)", "Settings Saved", 4 + 64)
        
        if (result = "Yes") {
            settingsGui.Destroy()
            ; Reload the main GUI
            try {
                if IsSet(MyGui) && MyGui.Hwnd
                    MyGui.Destroy()
            } catch {
                ; GUI already destroyed
            }
            ShowHotkeyGUI()
        }
    } else {
        progressGui.Destroy()
    }
}

; ===========================
; GUI HOTKEYS
; ===========================

#HotIf WinActive("Hotkey & Hotstring Reference")

Enter:: {
    global MyGui, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs, tabIndexMap

    ; Safety check
    try {
        if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
            return
    } catch {
        return
    }
    
    try {
        currentTab := MyTab.Value
        
        ; Get the correct ListView using tab index map
        LV := ""
        if (tabIndexMap.Has(currentTab)) {
            tabInfo := tabIndexMap[currentTab]
            if (tabInfo.type = "builtin") {
                switch tabInfo.key {
                    case "hotkeys":
                        LV := LV_Hotkeys
                    case "hotstrings":
                        LV := LV_Hotstrings
                    case "wiki":
                        LV := LV_Wiki
                    case "favorites":
                        LV := LV_Favorites
                }
            } else {
                ; Custom tab
                if (customLVs.Has(tabInfo.key))
                    LV := customLVs[tabInfo.key]
            }
        }
        
        if (LV != "" && IsObject(LV)) {
            rowNumber := LV.GetNext()
            if (rowNumber > 0) {
                LV_DoubleClick(LV, rowNumber, "")
            }
        }
    } catch as err {
        ; Silently handle any errors
    }
}

^c:: {
    global MyGui, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs, searchBox, tabIndexMap

    ; Safety check
    try {
        if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
            return

        ; Check if search box has focus - if so, let normal Ctrl+C work
        focusedControl := ControlGetFocus("ahk_id " . MyGui.Hwnd)
        ; If search box is focused, don't intercept Ctrl+C
        if (InStr(focusedControl, "Edit"))
            return
    } catch {
        return
    }
    
    try {
        currentTab := MyTab.Value
        
        ; Get the correct ListView using tab index map
        LV := ""
        if (tabIndexMap.Has(currentTab)) {
            tabInfo := tabIndexMap[currentTab]
            if (tabInfo.type = "builtin") {
                switch tabInfo.key {
                    case "hotkeys":
                        LV := LV_Hotkeys
                    case "hotstrings":
                        LV := LV_Hotstrings
                    case "wiki":
                        LV := LV_Wiki
                    case "favorites":
                        LV := LV_Favorites
                }
            } else {
                ; Custom tab
                if (customLVs.Has(tabInfo.key))
                    LV := customLVs[tabInfo.key]
            }
        }
        
        if (LV != "" && IsObject(LV)) {
            rowNumber := LV.GetNext()
            if (rowNumber > 0) {
                LV_DoubleClick(LV, rowNumber, "")
            }
        }
    } catch as err {
        ; Silently handle any errors
    }
}

Delete:: {
    global MyGui, MyTab, LV_Favorites, tabIndexMap

    ; Safety check
    try {
        if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
            return
    } catch {
        return
    }

    try {
        ; Only works in Favorites tab - use tab index map to check
        currentTab := MyTab.Value
        if (tabIndexMap.Has(currentTab)) {
            tabInfo := tabIndexMap[currentTab]
            if (tabInfo.type = "builtin" && tabInfo.key = "favorites") {
                if (IsSet(LV_Favorites) && LV_Favorites) {
                    rowNumber := LV_Favorites.GetNext()
                    if (rowNumber > 0)
                        RemoveFavoriteByRow(rowNumber)
                }
            }
        }
    } catch as err {
        ; Silently handle any errors
    }
}

#HotIf

; Optional: Add hotkey to close the GUI
^!Escape:: {
    try {
        if (IsSet(MyGui) && MyGui.Hwnd) {
            MyGui.Destroy()
        }
    } catch {
        ; GUI already destroyed
    }
}