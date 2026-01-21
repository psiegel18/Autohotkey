#Requires AutoHotkey v2.0

; ===========================
; GLOBAL VARIABLE DECLARATIONS
; ===========================

; Data structures (will be populated from config files or start empty)
global hotkeyCategories := []
global hotstringCategories := []
global wikiCategories := []
global customTabs := []
global favoritesList := []

; Tab metadata for customizing built-in tabs
global tabMetadata := {
    hotkeys: {name: "Hotkeys", icon: "[HK]", visible: true, order: 1},
    hotstrings: {name: "Hotstrings", icon: "[HS]", visible: true, order: 2},
    wiki: {name: "Wiki Shortcuts", icon: "[W]", visible: true, order: 3},
    favorites: {name: "Favorites", icon: "[*]", visible: true, order: 999}
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
global customLVs := Map()

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

; Tab mapping system
global tabIndexMap := Map()

; GUI Hotkey Settings (defaults)
global guiHotkeys := {
    openGui: "^!Space",
    closeGui: "^!Escape",
    focusSearch: "^f"
}

; ===========================
; INITIALIZATION
; ===========================

; Load configuration first (includes hotkey settings)
LoadAllConfiguration()

; Set up dynamic hotkeys based on settings
SetupGuiHotkeys()

; Dynamic hotkey setup happens in SetupGuiHotkeys()
; The #HotIf context is set up dynamically based on user settings

; ===========================
; DYNAMIC HOTKEY SETUP
; ===========================

SetupGuiHotkeys() {
    global guiHotkeys
    
    ; Set up Open GUI hotkey
    if (guiHotkeys.openGui != "") {
        try {
            Hotkey(guiHotkeys.openGui, (*) => ShowHotkeyGUI(), "On")
        } catch as err {
            MsgBox("Invalid Open GUI hotkey: " . guiHotkeys.openGui . "`n`nUsing default: Ctrl+Alt+Space", "Hotkey Error", 48)
            guiHotkeys.openGui := "^!Space"
            Hotkey("^!Space", (*) => ShowHotkeyGUI(), "On")
        }
    }
    
    ; Set up Close GUI hotkey
    if (guiHotkeys.closeGui != "") {
        try {
            Hotkey(guiHotkeys.closeGui, (*) => CloseGuiHotkey(), "On")
        } catch as err {
            MsgBox("Invalid Close GUI hotkey: " . guiHotkeys.closeGui . "`n`nUsing default: Ctrl+Alt+Esc", "Hotkey Error", 48)
            guiHotkeys.closeGui := "^!Escape"
            Hotkey("^!Escape", (*) => CloseGuiHotkey(), "On")
        }
    }
    
    ; Focus Search is set up dynamically when GUI is active (see below)
}

CloseGuiHotkey() {
    try {
        if (IsSet(MyGui) && MyGui.Hwnd) {
            MyGui.Destroy()
        }
    } catch {
        ; GUI already destroyed
    }
}

SetupFocusSearchHotkey() {
    global guiHotkeys
    
    ; Set up context-sensitive focus search hotkey
    if (guiHotkeys.focusSearch != "") {
        try {
            HotIfWinActive("Hotkey & Hotstring Reference")
            Hotkey(guiHotkeys.focusSearch, (*) => FocusSearchBox(), "On")
            HotIf()
        } catch as err {
            ; If invalid, just skip - no critical functionality lost
        }
    }
}

FocusSearchBox() {
    global searchBox, MyGui
    try {
        if (IsSet(MyGui) && MyGui.Hwnd) {
            WinActivate("ahk_id " . MyGui.Hwnd)
            searchBox.Focus()
            if (searchBox.Value == "Search...")
                searchBox.Value := ""
        }
    } catch {
        ; GUI already destroyed
    }
}

; Focus Search hotkey - context-sensitive
#HotIf WinActive("Hotkey & Hotstring Reference")

; This gets overridden by user setting in ShowHotkeyGUI()

#HotIf

; ===========================
; CONFIGURATION LOADING
; ===========================

LoadAllConfiguration() {
    SplitPath(A_LineFile,, &guiDir)
    defaultsFile := guiDir . "\defaults.ini"
    configFile := guiDir . "\config.ini"
    
    ; Priority 1: Check for user's config.ini (overrides everything)
    if FileExist(configFile) {
        if LoadConfiguration(configFile) {
            return ; User config loaded successfully
        }
    }
    
    ; Priority 2: Check for defaults.ini (first-time setup)
    if FileExist(defaultsFile) {
        if LoadConfiguration(defaultsFile) {
            ; Save as config.ini for future edits
            SaveConfiguration()
            return
        }
    }
    
    ; Priority 3: No files exist - start with minimal setup
    ; Already initialized as empty arrays above
    ; Only show Hotkeys and Favorites tabs
    global tabMetadata
    tabMetadata.hotstrings.visible := false
    tabMetadata.wiki.visible := false
}

; ===========================
; MAIN GUI FUNCTIONS
; ===========================

ShowHotkeyGUI() {
    global MyGui := Gui("+Resize +MinSize600x560", "Hotkey & Hotstring Reference")
    MyGui.BackColor := "0xF0F0F0"
    MyGui.SetFont("s9", "Segoe UI")

    ; Add a search box with placeholder text
    global searchBox := MyGui.Add("Edit", "vSearchTerm x10 y10 w515 h25", "Search...")
    searchBox.OnEvent("Focus", (*) => OnSearchFocus(searchBox))
    searchBox.OnEvent("LoseFocus", (*) => OnSearchLoseFocus(searchBox))
    searchBox.OnEvent("Change", (*) => FilterAllLists())

    ; Add clear button
    global clearBtn := MyGui.Add("Button", "x530 y10 w60 h25", "✕ Clear")
    clearBtn.OnEvent("Click", (*) => ClearSearch())

    ; Build tabs dynamically
    tabNames := []
    tabOrder := []
    
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
    
    ; Add favorites last
    if (tabMetadata.favorites.visible)
        tabOrder.Push({type: "builtin", key: "favorites", order: 9999, name: tabMetadata.favorites.icon . " " . tabMetadata.favorites.name})
    
    ; Sort by order
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
    
    ; Build final tab names and populate index map
    for tab in tabOrder {
        tabNames.Push(tab.name)
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
    
    global customLVs := customListViews
    MyTab.UseTab()

    ; Add quick action buttons
    btnY := 468
    
    MyGui.SetFont("s9 Bold", "Segoe UI")
    global copyBtn := MyGui.Add("Button", "x10 y" . btnY . " w100 h32", "📋 Copy")
    copyBtn.OnEvent("Click", (*) => CopyCurrentSelection())
    copyBtn.ToolTip := "Copy selected item to clipboard (Enter/Ctrl+C)"
    
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

    global clearFavBtn := MyGui.Add("Button", "x420 y" . btnY . " w90 h32", "🗑️ Clear")
    clearFavBtn.OnEvent("Click", (*) => ClearAllFavorites())
    clearFavBtn.ToolTip := "Clear all favorites"

    ; Add status bar
    global statusBar := MyGui.Add("StatusBar")
    statusBar.SetText("Ready | Press Ctrl+F to search, Enter to copy, Esc to close")

    MyGui.OnEvent("Size", GuiResize)
    MyGui.OnEvent("Escape", (*) => MyGui.Destroy())
    MyGui.OnEvent("Close", (*) => MyGui.Destroy())

    ; Load favorites
    LoadFavorites()
    
    ; Set up Focus Search hotkey dynamically
    SetupFocusSearchHotkey()
    
    ; Show GUI
    MyGui.Show("w600 h560")
    
    ; Populate first tab
    PopulateTabByIndex(1)
    tabsPopulated[1] := true
    
    UpdateStatusBar()
}

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
        if (customLVs.Has(tabInfo.key)) {
            LV := customLVs[tabInfo.key]
            for tab in customTabs {
                if (tab.name = tabInfo.key) {
                    PopulateCustomTabListView(LV, tab)
                    break
                }
            }
        }
    }
}

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
        
    MyGui.GetPos(, , &w, &h)
    
    searchBox.Move(10, 10, w - 85, 25)
    clearBtn.Move(w - 70, 10, 60, 25)
    
    statusBarHeight := 22
    buttonHeight := 32
    buttonMargin := 35
    
    bottomReserved := statusBarHeight + buttonHeight + buttonMargin
    tabHeight := h - 45 - bottomReserved - 10
    MyTab.Move(10, 45, w - 20, tabHeight)
    
    lvHeight := tabHeight - 30
    
    if (IsSet(LV_Hotkeys) && LV_Hotkeys)
        LV_Hotkeys.Move(20, 75, w - 40, lvHeight)
    if (IsSet(LV_Hotstrings) && LV_Hotstrings)
        LV_Hotstrings.Move(20, 75, w - 40, lvHeight)
    if (IsSet(LV_Wiki) && LV_Wiki)
        LV_Wiki.Move(20, 75, w - 40, lvHeight)
    
    for tabName, LV in customLVs {
        LV.Move(20, 75, w - 40, lvHeight)
    }
    
    if (IsSet(LV_Favorites) && LV_Favorites)
        LV_Favorites.Move(20, 75, w - 40, lvHeight)
    
    btnY := h - statusBarHeight - buttonHeight - buttonMargin
    copyBtn.Move(10, btnY, 100, buttonHeight)
    exportBtn.Move(120, btnY, 90, buttonHeight)
    settingsBtn.Move(220, btnY, 90, buttonHeight)
    helpBtn.Move(320, btnY, 90, buttonHeight)
    clearFavBtn.Move(420, btnY, 90, buttonHeight)
    
    if (IsSet(LV_Hotkeys) && LV_Hotkeys)
        AutoSizeColumns(LV_Hotkeys)
    if (IsSet(LV_Hotstrings) && LV_Hotstrings)
        AutoSizeColumns(LV_Hotstrings)
    if (IsSet(LV_Wiki) && LV_Wiki)
        AutoSizeColumns(LV_Wiki)
    
    for tabName, LV in customLVs {
        AutoSizeColumns(LV)
    }
    
    if (IsSet(LV_Favorites) && LV_Favorites)
        AutoSizeColumns(LV_Favorites)
}

AutoSizeColumns(LV) {
    LV.GetPos(, , &lvWidth, )
    totalWidth := lvWidth - 30
    
    categoryWidth := Integer(totalWidth * 0.2)
    hotkeyWidth := Integer(totalWidth * 0.3)
    descriptionWidth := Integer(totalWidth * 0.5)
    
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

OnTabChange(*) {
    global MyTab, tabsPopulated
    
    currentTab := MyTab.Value
    
    if (!tabsPopulated[currentTab]) {
        PopulateTabByIndex(currentTab)
        tabsPopulated[currentTab] := true
    }
    
    UpdateStatusBar()
}

OnSearchLoseFocus(searchBox) {
    if (searchBox.Value == "") {
        searchBox.Value := "Search..."
        FilterAllLists()
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
        for tabIdx in tabsPopulated {
            tabsPopulated[tabIdx] := false
        }
        
        currentTab := MyTab.Value
        PopulateTabByIndex(currentTab)
        tabsPopulated[currentTab] := true
        
        UpdateStatusBar()
        return
    }

    searchTermLower := StrLower(searchTerm)

    ; Filter Hotkeys
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

    ; Filter Hotstrings
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

    ; Filter Wiki
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

    ; Filter Favorites
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
    
    for tabIdx in tabsPopulated {
        tabsPopulated[tabIdx] := true
    }

    hotkeyCount := IsSet(LV_Hotkeys) && LV_Hotkeys ? LV_Hotkeys.GetCount() : 0
    hotstringCount := IsSet(LV_Hotstrings) && LV_Hotstrings ? LV_Hotstrings.GetCount() : 0
    wikiCount := IsSet(LV_Wiki) && LV_Wiki ? LV_Wiki.GetCount() : 0
    favCount := IsSet(LV_Favorites) && LV_Favorites ? LV_Favorites.GetCount() : 0
    
    customCount := 0
    for tabName, LV in customLVs {
        customCount += LV.GetCount()
    }
    
    totalResults := hotkeyCount + hotstringCount + wikiCount + customCount + favCount
    statusBar.SetText("Found " . totalResults . " results | Hotkeys: " . hotkeyCount . " | Hotstrings: " . hotstringCount . " | Wiki: " . wikiCount . " | Custom: " . customCount . " | Favorites: " . favCount)
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
    global tabsPopulated, LV_Hotkeys, LV_Hotstrings, LV_Wiki, favoritesList, customLVs, searchBox, statusBar
    
    hotkeyCount := (IsSet(LV_Hotkeys) && LV_Hotkeys) ? LV_Hotkeys.GetCount() : CountHotkeys()
    hotstringCount := (IsSet(LV_Hotstrings) && LV_Hotstrings) ? LV_Hotstrings.GetCount() : CountHotstrings()
    wikiCount := (IsSet(LV_Wiki) && LV_Wiki) ? LV_Wiki.GetCount() : CountWikiShortcuts()
    favCount := favoritesList.Length
    
    customCount := 0
    for tabName, LV in customLVs {
        customCount += LV.GetCount()
    }
    
    searchTerm := Trim(searchBox.Value)
    if (searchTerm != "" && searchTerm != "Search...") {
        totalResults := hotkeyCount + hotstringCount + wikiCount + customCount + favCount
        statusBar.SetText("Found " . totalResults . " results | Hotkeys: " . hotkeyCount . " | Hotstrings: " . hotstringCount . " | Wiki: " . wikiCount . " | Custom: " . customCount . " | Favorites: " . favCount)
    } else {
        totalItems := CountAllItems()
        statusBar.SetText("Ready | Total: " . totalItems . " items | Press Ctrl+F to search")
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
        selectedItem := LV.GetText(RowNumber, 2)
        A_Clipboard := selectedItem
        
        LV.Modify(RowNumber, "Select Focus Vis")
        ShowCopyNotification(selectedItem)
        
        statusBar.SetText("✓ Copied: " . selectedItem)
        SetTimer(() => UpdateStatusBar(), -3000)
    }
}

ShowCopyNotification(text) {
    notifyGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Notification")
    notifyGui.BackColor := "0x4CAF50"
    notifyGui.SetFont("s10 Bold", "Segoe UI")
    
    displayText := (StrLen(text) > 50) ? SubStr(text, 1, 47) . "..." : text
    notifyGui.Add("Text", "cWhite x15 y10 w300", "✓ Copied: " . displayText)
    
    notifyGui.Show("NoActivate x" . (A_ScreenWidth - 350) . " y" . (A_ScreenHeight - 100) . " w330 h40")
    SetTimer(() => notifyGui.Destroy(), -2000)
}

ShowContextMenu(LV, Item, IsRightClick, X, Y) {
    if (Item > 0) {
        contextMenu := Menu()
        contextMenu.Add("📋 Copy Item", (*) => LV_DoubleClick(LV, Item, ""))
        contextMenu.Add("📝 Copy Description", (*) => CopyDescription(LV, Item))
        contextMenu.Add()
        
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
    statusBar.SetText("✓ Copied description: " . description)
    SetTimer(() => UpdateStatusBar(), -3000)
}

SortListView(LV, ColNumber) {
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
        for tabName, customLV in customLVs {
            if (LV = customLV) {
                lvName := "LV_" . tabName
                break
            }
        }
    }
    
    if (lvName = "")
        return
    
    if (!lastSortCol.Has(lvName))
        lastSortCol[lvName] := 0
    if (!sortDirection.Has(lvName))
        sortDirection[lvName] := 1
    
    if (ColNumber = lastSortCol[lvName]) {
        sortDirection[lvName] := -sortDirection[lvName]
    } else {
        lastSortCol[lvName] := ColNumber
        sortDirection[lvName] := 1
    }
    
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
    
    if (IsFavorite(item)) {
        MsgBox("This item is already in your favorites!", "Already Favorited", 64)
        return
    }
    
    tabIndex := MyTab.Value
    tabType := "Custom"
    
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
    
    statusBar.SetText("⭐ Added to favorites: " . item)
    SetTimer(() => UpdateStatusBar(), -3000)
}

RemoveFavorite(LV, RowNumber) {
    global tabsPopulated, favoritesList, MyTab, statusBar, tabIndexMap
    
    item := LV.GetText(RowNumber, 2)
    
    for index, fav in favoritesList {
        if (fav.item == item) {
            favoritesList.RemoveAt(index)
            SaveFavorites()
            
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
            statusBar.SetText("Removed from favorites: " . item)
            SetTimer(() => UpdateStatusBar(), -3000)
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
        statusBar.SetText("Removed from favorites: " . item)
        SetTimer(() => UpdateStatusBar(), -3000)
    }
}

ClearAllFavorites() {
    global tabsPopulated, favoritesList, MyTab, statusBar, tabIndexMap
    
    if (favoritesList.Length > 0) {
        result := MsgBox("Are you sure you want to clear all favorites?", "Clear Favorites", 4 + 32)
        if (result = "Yes") {
            favoritesList := []
            SaveFavorites()
            
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
            statusBar.SetText("All favorites cleared")
            SetTimer(() => UpdateStatusBar(), -3000)
        }
    } else {
        MsgBox("No favorites to clear!", "Clear Favorites", 64)
    }
}

SaveFavorites() {
    global favoritesList
    SplitPath(A_LineFile,, &guiDir)
    favFile := guiDir . "\favorites.ini"
    
    try {
        if FileExist(favFile)
            FileDelete(favFile)
    }
    
    if (favoritesList.Length = 0)
        return
    
    ; Write count
    IniWrite(favoritesList.Length, favFile, "Settings", "Count")
    
    ; Write each favorite
    for index, fav in favoritesList {
        section := "Favorite" . index
        IniWrite(fav.type, favFile, section, "Type")
        IniWrite(fav.item, favFile, section, "Item")
        IniWrite(fav.desc, favFile, section, "Description")
    }
}

LoadFavorites() {
    global favoritesList := []
    
    SplitPath(A_LineFile,, &guiDir)
    favFile := guiDir . "\favorites.ini"
    
    if (!FileExist(favFile))
        return
    
    try {
        count := IniRead(favFile, "Settings", "Count", 0)
        
        Loop count {
            section := "Favorite" . A_Index
            favType := IniRead(favFile, section, "Type", "")
            favItem := IniRead(favFile, section, "Item", "")
            favDesc := IniRead(favFile, section, "Description", "")
            
            if (favType != "" && favItem != "" && favDesc != "") {
                favoritesList.Push({type: favType, item: favItem, desc: favDesc})
            }
        }
    } catch as err {
        ; If favorites file is corrupted, start fresh
        favoritesList := []
    }
}

; ===========================
; BUTTON ACTIONS
; ===========================

CopyCurrentSelection() {
    global MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs, tabIndexMap
    currentTab := MyTab.Value
    
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
    
    exportFile := FileSelect("S16", "HotkeyReference_Export.txt", "Export Hotkey Reference", "Text Files (*.txt)")
    
    if (exportFile = "")
        return
    
    if (!InStr(exportFile, ".txt"))
        exportFile .= ".txt"
    
    fileContent := "HOTKEY & HOTSTRING REFERENCE EXPORT`n"
    fileContent .= "Generated: " . FormatTime(, "yyyy-MM-dd HH:mm:ss") . "`n"
    fileContent .= "=" . StrReplace(Format("{:80s}", ""), " ", "=") . "`n`n"
    
    ; Export Hotkeys
    if (hotkeyCategories.Length > 0) {
        fileContent .= "HOTKEYS`n"
        fileContent .= "-" . StrReplace(Format("{:80s}", ""), " ", "-") . "`n"
        for category in hotkeyCategories {
            fileContent .= "`n[" . category.name . "]`n"
            for hk in category.hotkeys {
                fileContent .= "  " . Format("{:-30s}", hk.hotkey) . " - " . hk.description . "`n"
            }
        }
    }
    
    ; Export Hotstrings
    if (hotstringCategories.Length > 0) {
        fileContent .= "`n`nHOTSTRINGS`n"
        fileContent .= "-" . StrReplace(Format("{:80s}", ""), " ", "-") . "`n"
        for category in hotstringCategories {
            fileContent .= "`n[" . category.name . "]`n"
            for hs in category.hotstrings {
                fileContent .= "  " . Format("{:-30s}", hs.hotstring) . " - " . hs.description . "`n"
            }
        }
    }
    
    ; Export Wiki
    if (wikiCategories.Length > 0) {
        fileContent .= "`n`nWIKI SHORTCUTS`n"
        fileContent .= "-" . StrReplace(Format("{:80s}", ""), " ", "-") . "`n"
        for category in wikiCategories {
            fileContent .= "`n[" . category.name . "]`n"
            for ws in category.shortcuts {
                fileContent .= "  " . Format("{:-30s}", ws.shortcut) . " - " . ws.description . "`n"
            }
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
        if (FileExist(exportFile))
            FileDelete(exportFile)
        
        FileAppend(fileContent, exportFile)
        
        result := MsgBox("Export successful!`n`nFile saved to:`n" . exportFile . "`n`nWould you like to open it now?", "Export Complete", 4 + 64)
        if (result = "Yes")
            Run(exportFile)
            
        statusBar.SetText("✓ Exported to: " . exportFile)
        SetTimer(() => UpdateStatusBar(), -5000)
    } catch as err {
        MsgBox("Export failed: " . err.Message, "Export Error", 16)
    }
}

ShowHelp() {
    global guiHotkeys
    
    ; Get current hotkey display names
    openGuiDisplay := FormatHotkeyForDisplay(guiHotkeys.openGui)
    closeGuiDisplay := FormatHotkeyForDisplay(guiHotkeys.closeGui)
    focusSearchDisplay := FormatHotkeyForDisplay(guiHotkeys.focusSearch)
    
    helpText := "
    (
    HOTKEY & HOTSTRING REFERENCE - HELP
    
    KEYBOARD SHORTCUTS (Customizable in Settings):
    • " . openGuiDisplay . "    Open this GUI
    • " . focusSearchDisplay . "            Focus search box
    • Enter             Copy selected item
    • Ctrl+C            Copy selected item
    • Delete            Remove from favorites (Favorites tab only)
    • Esc               Close GUI
    • " . closeGuiDisplay . "    Close GUI (alternative)
    
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
    • ⌨️ Customize GUI hotkeys to your preference
    
    SETTINGS:
    • Add, edit, or delete hotkeys, hotstrings, and wiki shortcuts
    • Create and manage custom categories
    • Customize tab names, icons, order, and visibility
    • Create custom tabs for your own shortcuts
    • Add content to custom tabs via 'Custom Tab Content' settings
    • Customize GUI hotkeys in 'GUI Hotkeys' tab
    • Export/import your configuration
    • All changes are saved automatically
    
    FAVORITES:
    • Right-click any item and select "Add to Favorites"
    • Access favorites from the ⭐ Favorites tab
    • Remove items by right-clicking or pressing Delete
    • Favorites are saved between sessions
    
    CONFIGURATION FILES:
    • defaults.ini - Default shortcuts (optional, copy provided file)
    • config.ini - Your customizations (auto-generated)
    • favorites.ini - Your favorite items (auto-saved)
    
    TIPS:
    • If no config exists, GUI starts with just Hotkeys & Favorites tabs
    • Use defaults.ini to provide starter shortcuts
    • All edits save to config.ini automatically
    • Export/Import features help share configurations
    • Customize GUI hotkeys to avoid conflicts with other software
    
    VERSION: v3.1 (Customizable Hotkeys & .ini Favorites)
    )"
    
    MsgBox(helpText, "Help - Hotkey Reference", 64)
}

FormatHotkeyForDisplay(hotkeyStr) {
    ; Convert hotkey string to readable format
    displayStr := hotkeyStr
    displayStr := StrReplace(displayStr, "^", "Ctrl+")
    displayStr := StrReplace(displayStr, "!", "Alt+")
    displayStr := StrReplace(displayStr, "+", "Shift+")
    displayStr := StrReplace(displayStr, "#", "Win+")
    return displayStr
}

; ===========================
; CONFIGURATION MANAGEMENT
; ===========================

SaveConfiguration() {
    global hotkeyCategories, hotstringCategories, wikiCategories, customTabs, tabMetadata, guiHotkeys
    
    SplitPath(A_LineFile,, &guiDir)
    configFile := guiDir . "\config.ini"
    
    try {
        if FileExist(configFile)
            FileDelete(configFile)
        
        ; Save GUI Hotkeys
        IniWrite(guiHotkeys.openGui, configFile, "GuiHotkeys", "OpenGui")
        IniWrite(guiHotkeys.closeGui, configFile, "GuiHotkeys", "CloseGui")
        IniWrite(guiHotkeys.focusSearch, configFile, "GuiHotkeys", "FocusSearch")
        
        ; Save Tab Metadata
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

LoadConfiguration(configPath) {
    global hotkeyCategories, hotstringCategories, wikiCategories, customTabs, tabMetadata, guiHotkeys
    
    if !FileExist(configPath) {
        return false
    }
    
    try {
        ; Load GUI Hotkeys
        openGui := IniRead(configPath, "GuiHotkeys", "OpenGui", "")
        if (openGui != "")
            guiHotkeys.openGui := openGui
        
        closeGui := IniRead(configPath, "GuiHotkeys", "CloseGui", "")
        if (closeGui != "")
            guiHotkeys.closeGui := closeGui
        
        focusSearch := IniRead(configPath, "GuiHotkeys", "FocusSearch", "")
        if (focusSearch != "")
            guiHotkeys.focusSearch := focusSearch
        
        ; Load Tab Metadata
        for key in ["hotkeys", "hotstrings", "wiki", "favorites"] {
            sectionName := "TabMeta-" . key
            name := IniRead(configPath, sectionName, "Name", "")
            if (name != "") {
                icon := IniRead(configPath, sectionName, "Icon", "📌")
                visible := IniRead(configPath, sectionName, "Visible", "1")
                order := IniRead(configPath, sectionName, "Order", "1")
                
                tabMetadata.%key% := {
                    name: name,
                    icon: icon,
                    visible: (visible = "1"),
                    order: Integer(order)
                }
            }
        }
        
        ; Load Hotkey Categories
        hotkeyCount := IniRead(configPath, "Settings", "HotkeyCategories", 0)
        if (hotkeyCount > 0) {
            newHotkeyCategories := []
            
            Loop hotkeyCount {
                catIndex := A_Index
                sectionName := "Hotkeys-Cat" . catIndex
                
                catName := IniRead(configPath, sectionName, "Name", "")
                itemCount := IniRead(configPath, sectionName, "Count", 0)
                
                if (catName = "")
                    continue
                
                items := []
                Loop itemCount {
                    itemIndex := A_Index
                    key := IniRead(configPath, sectionName, "Item" . itemIndex . "_Key", "")
                    desc := IniRead(configPath, sectionName, "Item" . itemIndex . "_Desc", "")
                    
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
        hotstringCount := IniRead(configPath, "Settings", "HotstringCategories", 0)
        if (hotstringCount > 0) {
            newHotstringCategories := []
            
            Loop hotstringCount {
                catIndex := A_Index
                sectionName := "Hotstrings-Cat" . catIndex
                
                catName := IniRead(configPath, sectionName, "Name", "")
                itemCount := IniRead(configPath, sectionName, "Count", 0)
                
                if (catName = "")
                    continue
                
                items := []
                Loop itemCount {
                    itemIndex := A_Index
                    key := IniRead(configPath, sectionName, "Item" . itemIndex . "_Key", "")
                    desc := IniRead(configPath, sectionName, "Item" . itemIndex . "_Desc", "")
                    
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
        wikiCount := IniRead(configPath, "Settings", "WikiCategories", 0)
        if (wikiCount > 0) {
            newWikiCategories := []
            
            Loop wikiCount {
                catIndex := A_Index
                sectionName := "Wiki-Cat" . catIndex
                
                catName := IniRead(configPath, sectionName, "Name", "")
                itemCount := IniRead(configPath, sectionName, "Count", 0)
                
                if (catName = "")
                    continue
                
                items := []
                Loop itemCount {
                    itemIndex := A_Index
                    key := IniRead(configPath, sectionName, "Item" . itemIndex . "_Key", "")
                    desc := IniRead(configPath, sectionName, "Item" . itemIndex . "_Desc", "")
                    
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
        customTabCount := IniRead(configPath, "Settings", "CustomTabs", 0)
        if (customTabCount > 0) {
            newCustomTabs := []
            
            Loop customTabCount {
                tabIndex := A_Index
                sectionName := "CustomTab" . tabIndex
                
                tabName := IniRead(configPath, sectionName, "Name", "")
                tabIcon := IniRead(configPath, sectionName, "Icon", "📌")
                tabOrder := IniRead(configPath, sectionName, "Order", 50 + tabIndex)
                catCount := IniRead(configPath, sectionName, "CategoryCount", 0)
                
                if (tabName = "")
                    continue
                
                categories := []
                if (catCount > 0) {
                    Loop catCount {
                        catIndex := A_Index
                        catSection := sectionName . "-Cat" . catIndex
                        
                        catName := IniRead(configPath, catSection, "Name", "")
                        itemCount := IniRead(configPath, catSection, "Count", 0)
                        
                        if (catName = "")
                            continue
                        
                        items := []
                        Loop itemCount {
                            itemIndex := A_Index
                            key := IniRead(configPath, catSection, "Item" . itemIndex . "_Key", "")
                            desc := IniRead(configPath, catSection, "Item" . itemIndex . "_Desc", "")
                            
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
        MsgBox("Configuration file is corrupted or invalid.`n`nError: " . err.Message . "`n`nStarting with empty configuration.", "Config Load Error", 48)
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
        if LoadConfiguration(configFile) {
            MsgBox("Configuration imported successfully! Please restart the application.", "Import Complete", 64)
        }
    } catch as err {
        MsgBox("Import failed: " . err.Message, "Import Error", 16)
    }
}

RestoreAllDefaults() {
    result := MsgBox("⚠️ WARNING ⚠️`n`nThis will reset EVERYTHING to default settings:`n`n• All hotkeys`n• All hotstrings`n• All wiki shortcuts`n• All tab customizations`n• All custom tabs will be deleted`n`nYour favorites will be preserved.`n`nThis CANNOT be undone!`n`nAre you sure?", "Restore ALL Defaults", 4 + 48)
    if (result = "No")
        return
    
    result2 := MsgBox("Are you REALLY sure?`n`nAll your customizations will be lost!", "Final Confirmation", 4 + 48)
    if (result2 = "No")
        return
    
    SplitPath(A_LineFile,, &guiDir)
    configFile := guiDir . "\config.ini"
    
    try {
        if FileExist(configFile)
            FileDelete(configFile)
        
        global customTabs := []
        global tabMetadata := {
            hotkeys: {name: "Hotkeys", icon: "[HK]", visible: true, order: 1},
            hotstrings: {name: "Hotstrings", icon: "[HS]", visible: false, order: 2},
            wiki: {name: "Wiki Shortcuts", icon: "[W]", visible: false, order: 3},
            favorites: {name: "Favorites", icon: "[*]", visible: true, order: 999}
        }
        
        MsgBox("All settings restored to defaults!`n`nThe application will now reload.", "Restored", 64)
        Reload()
    } catch as err {
        MsgBox("Failed to restore defaults: " . err.Message, "Error", 16)
    }
}

; [Settings GUI functions continue in next file due to length - see SettingsFunctions.ahk]
; Include the settings functions file
#Include SettingsFunctions.ahk

; ===========================
; GUI HOTKEYS
; ===========================
; All GUI hotkeys are now set up dynamically in SetupGuiHotkeys()
; and SetupFocusSearchHotkey() based on user settings

#HotIf WinActive("Hotkey & Hotstring Reference")

Enter:: {
    global MyGui, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs, tabIndexMap

    try {
        if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
            return
    } catch {
        return
    }
    
    try {
        currentTab := MyTab.Value
        
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
    }
}

^c:: {
    global MyGui, MyTab, LV_Hotkeys, LV_Hotstrings, LV_Wiki, LV_Favorites, customLVs, searchBox, tabIndexMap

    try {
        if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
            return

        focusedControl := ControlGetFocus("ahk_id " . MyGui.Hwnd)
        if (InStr(focusedControl, "Edit"))
            return
    } catch {
        return
    }
    
    try {
        currentTab := MyTab.Value
        
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
    }
}

Delete:: {
    global MyGui, MyTab, LV_Favorites, tabIndexMap

    try {
        if (!IsSet(MyGui) || !MyGui.Hwnd || !WinExist("ahk_id " . MyGui.Hwnd))
            return
    } catch {
        return
    }
    
    try {
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
    }
}

#HotIf

; End of script - all hotkeys are now dynamic