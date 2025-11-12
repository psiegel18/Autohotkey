#Requires AutoHotkey v2.0

; Global variables
selectionGui := ""
currentGUIState := "none"
helpTooltipShowing := false
loadingGui := ""
loadingText := ""
loadingTimer := ""
; Use the directory of THIS file, not the main script
epicLauncherDir := ""
SplitPath(A_LineFile,, &epicLauncherDir)
configFile := epicLauncherDir "\epic_launcher_config.ini"
config := Map()

; Show loading indicator
ShowLoading() {
    global loadingGui, loadingTimer, loadingText
    
    try {
        if (IsObject(loadingGui) && WinExist(loadingGui.Hwnd)) {
            loadingGui.Destroy()
        }
    }
    
    loadingGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Loading")
    loadingGui.BackColor := "0x34495E"
    loadingGui.SetFont("s12 Bold", "Segoe UI")
    
    ; Store reference to text control globally
    global loadingText := loadingGui.Add("Text", "x20 y15 w160 h30 Center c0xFFFFFF", "⏳ Loading...")
    
    ; Get mouse position to show near cursor
    MouseGetPos(&mouseX, &mouseY)
    loadingGui.Show("x" . (mouseX + 20) . " y" . (mouseY + 20) . " w200 h60 NoActivate")
    
    ; Force Windows to render the GUI
    Sleep(50)
    
    ; Set timer to animate
    loadingTimer := SetTimer(AnimateLoading, 300)
    return
}

; Animate loading text
AnimateLoading() {
    global loadingGui, loadingText
    static loadingStates := ["⏳ Loading", "⏳ Loading.", "⏳ Loading..", "⏳ Loading..."]
    static currentState := 1

    try {
        if (IsObject(loadingGui) && WinExist(loadingGui.Hwnd) && IsObject(loadingText)) {
            loadingText.Value := loadingStates[currentState]
            currentState := Mod(currentState, 4) + 1
        }
    }
    return
}

; Hide loading indicator
HideLoading() {
    global loadingGui, loadingTimer, loadingText
    
    ; Stop animation timer
    if (loadingTimer) {
        SetTimer(loadingTimer, 0)
        loadingTimer := ""
    }
    
    ; Destroy loading GUI
    try {
        if (IsObject(loadingGui) && WinExist(loadingGui.Hwnd)) {
            loadingGui.Destroy()
        }
    }
    loadingGui := ""
    loadingText := ""
    return
}

; Initialize configuration
InitializeConfig() {
    global config, configFile
    
    ; Check if config file exists
    if (FileExist(configFile)) {
        ; Load from INI file
        LoadConfigFromINI()
    } else {
        ; Create default config
        CreateDefaultConfig()
        SaveConfigToINI()
    }
}

; Create default configuration
CreateDefaultConfig() {
    global config
    
    config := Map()
    
    ; Main Menu
    config["mainMenu"] := Map(
        "title", "🚀 Epic Systems Launcher",
        "buttonCount", 6
    )
    
    ; Main menu buttons
    config["mainMenu_btn1"] := Map("text", "🏗️ &Foundation System", "hotkey", "f", "action", "submenu", "target", "foundation")
    config["mainMenu_btn2"] := Map("text", "🏰 &SandCastle", "hotkey", "s", "action", "input", "target", "https://sand-pool{INPUT}.epic.com/HSWeb_SANDCASTLE{INPUT}/")
    config["mainMenu_btn3"] := Map("text", "🔬 &Microscope", "hotkey", "m", "action", "url", "target", "https://hsw-current02.epic.com/MICROSCOPEPRDT/")
    config["mainMenu_btn4"] := Map("text", "⚡ &EMC2", "hotkey", "e", "action", "url", "target", "https://emc2.epic.com/HSWeb_track/")
    config["mainMenu_btn5"] := Map("text", "💻 FS &Citrix", "hotkey", "c", "action", "url", "target", "https://storefrontlb/Citrix/XAXDWeb/")
    config["mainMenu_btn6"] := Map("text", "🎓 &Training Environments", "hotkey", "t", "action", "url", "target", "https://internalapps.epic.com/Citrix/InternalAppsWeb/")
    
    ; Foundation Menu
    config["foundation"] := Map(
        "title", "🏗️ Foundation System Options",
        "buttonCount", 5
    )
    
    ; Foundation menu buttons
    config["foundation_btn1"] := Map("text", "🎮 FS &Playground", "hotkey", "p", "action", "url", "target", "https://hsw-iis-fs.epic.com/FSPLAYFIN/")
    config["foundation_btn2"] := Map("text", "🔍 FS Master&View", "hotkey", "v", "action", "url", "target", "https://hsw-model.epic.com/HSWeb_MODELVO/")
    config["foundation_btn3"] := Map("text", "📚 FS Environment &Wiki", "hotkey", "w", "action", "url", "target", "https://wiki.epic.com/main/Foundation_System/Foundation_System_Environments#General_Access_(Green)")
    config["foundation_btn4"] := Map("text", "📋 FS Environment &List", "hotkey", "l", "action", "url", "target", "https://emc2summary/GetSummaryReport.ashx/track/XSHADOW/EnvironmentList")
    config["foundation_btn5"] := Map("text", "🚀 &Hyperdrive Local", "hotkey", "h", "action", "exe", "target", "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Hyperspace.lnk")
}

; Save configuration to INI file
SaveConfigToINI() {
    global config, configFile
    
    try {
        ; Delete old file if exists
        if (FileExist(configFile)) {
            FileDelete(configFile)
        }
        
        ; Write main menu
        IniWrite(config["mainMenu"]["title"], configFile, "mainMenu", "title")
        IniWrite(config["mainMenu"]["buttonCount"], configFile, "mainMenu", "buttonCount")
        
        ; Write main menu buttons
        Loop config["mainMenu"]["buttonCount"] {
            btnKey := "mainMenu_btn" . A_Index
            btn := config[btnKey]
            IniWrite(btn["text"], configFile, btnKey, "text")
            IniWrite(btn["hotkey"], configFile, btnKey, "hotkey")
            IniWrite(btn["action"], configFile, btnKey, "action")
            IniWrite(btn["target"], configFile, btnKey, "target")
        }
        
        ; Write foundation menu
        IniWrite(config["foundation"]["title"], configFile, "foundation", "title")
        IniWrite(config["foundation"]["buttonCount"], configFile, "foundation", "buttonCount")
        
        ; Write foundation menu buttons
        Loop config["foundation"]["buttonCount"] {
            btnKey := "foundation_btn" . A_Index
            btn := config[btnKey]
            IniWrite(btn["text"], configFile, btnKey, "text")
            IniWrite(btn["hotkey"], configFile, btnKey, "hotkey")
            IniWrite(btn["action"], configFile, btnKey, "action")
            IniWrite(btn["target"], configFile, btnKey, "target")
        }
        
    } catch as e {
        MsgBox("Error saving configuration: " . e.Message, "Save Error", "OK IconX")
    }
}

; Load configuration from INI file
LoadConfigFromINI() {
    global config, configFile
    
    try {
        config := Map()
        
        ; Load main menu
        mainTitle := IniRead(configFile, "mainMenu", "title", "🚀 Epic Systems Launcher")
        mainBtnCount := IniRead(configFile, "mainMenu", "buttonCount", "6")
        
        config["mainMenu"] := Map(
            "title", mainTitle,
            "buttonCount", Integer(mainBtnCount)
        )
        
        ; Load main menu buttons
        Loop Integer(mainBtnCount) {
            btnKey := "mainMenu_btn" . A_Index
            config[btnKey] := Map(
                "text", IniRead(configFile, btnKey, "text", ""),
                "hotkey", IniRead(configFile, btnKey, "hotkey", ""),
                "action", IniRead(configFile, btnKey, "action", ""),
                "target", IniRead(configFile, btnKey, "target", "")
            )
        }
        
        ; Load foundation menu
        foundTitle := IniRead(configFile, "foundation", "title", "🏗️ Foundation System Options")
        foundBtnCount := IniRead(configFile, "foundation", "buttonCount", "5")
        
        config["foundation"] := Map(
            "title", foundTitle,
            "buttonCount", Integer(foundBtnCount)
        )
        
        ; Load foundation menu buttons
        Loop Integer(foundBtnCount) {
            btnKey := "foundation_btn" . A_Index
            config[btnKey] := Map(
                "text", IniRead(configFile, btnKey, "text", ""),
                "hotkey", IniRead(configFile, btnKey, "hotkey", ""),
                "action", IniRead(configFile, btnKey, "action", ""),
                "target", IniRead(configFile, btnKey, "target", "")
            )
        }
        
    } catch as e {
        MsgBox("Error loading configuration: " . e.Message . "`n`nUsing defaults.", "Load Error", "OK IconX")
        CreateDefaultConfig()
    }
}

; Reload configuration
ReloadConfig() {
    global config, configFile, selectionGui, currentGUIState
    
    ; Show loading
    ShowLoading()
    
    ; Close any open GUI
    try {
        if (IsObject(selectionGui) && WinExist(selectionGui.Hwnd)) {
            selectionGui.Destroy()
        }
    }
    currentGUIState := "none"
    
    ; Reload from file
    if (FileExist(configFile)) {
        LoadConfigFromINI()
        HideLoading()
        MsgBox("Configuration reloaded successfully!", "Reload Complete", "OK Iconi")
    } else {
        HideLoading()
        MsgBox("Configuration file not found! Using defaults.", "Reload", "OK IconX")
        CreateDefaultConfig()
    }
    
    LaunchBrowser()
}

; Function to open URL/exe
OpenBrowser(url) {
    try {
        Run(url)
    } catch as e {
        MsgBox("Failed to open: " . url . "`n`nError: " . e.Message, "Error", "OK IconX")
    }
}

; Function to show configuration GUI
ShowConfigGUI(menuId) {
    global config, configFile
    
    configGui := Gui("+AlwaysOnTop", "⚙️ Configure " . menuId . " Menu")
    configGui.BackColor := "0x2C3E50"
    configGui.SetFont("s10", "Segoe UI")
    
    ; Get menu config
    menuConfig := config[menuId]
    buttonCount := menuConfig["buttonCount"]
    
    ; Title
    titleText := configGui.Add("Text", "x20 y20 w560 h25 Center c0xFFFFFF", "Configure Buttons (Click to edit)")
    titleText.SetFont("s12 Bold")
    
    ; Add ListView
    lv := configGui.Add("ListView", "x20 y55 w560 h250", ["Button Text", "Hotkey", "Action", "Target"])
    
    ; Populate ListView
    Loop buttonCount {
        btnKey := menuId . "_btn" . A_Index
        btn := config[btnKey]
        lv.Add("", btn["text"], btn["hotkey"], btn["action"], btn["target"])
    }
    
    lv.ModifyCol(1, 200)
    lv.ModifyCol(2, 60)
    lv.ModifyCol(3, 80)
    lv.ModifyCol(4, 220)
    
    ; Buttons
    editBtn := configGui.Add("Button", "x20 y320 w110 h35", "✏️ Edit Selected")
    editBtn.OnEvent("Click", (*) => EditButton(menuId, lv, configGui))
    
    addBtn := configGui.Add("Button", "x140 y320 w110 h35", "➕ Add Button")
    addBtn.OnEvent("Click", (*) => AddButton(menuId, lv, configGui))
    
    deleteBtn := configGui.Add("Button", "x260 y320 w110 h35", "🗑️ Delete Selected")
    deleteBtn.OnEvent("Click", (*) => DeleteButton(menuId, lv, configGui))
    
    saveBtn := configGui.Add("Button", "x380 y320 w90 h35", "💾 Save")
    saveBtn.OnEvent("Click", (*) => SaveAndClose(configGui))
    
    closeBtn := configGui.Add("Button", "x480 y320 w100 h35", "✕ Cancel")
    closeBtn.OnEvent("Click", (*) => configGui.Destroy())
    
    ; Add separator
    configGui.Add("Text", "x20 y365 w560 h2 Background0x34495E")
    
    ; Add config file path label with wrapping
    configGui.Add("Text", "x20 y375 w80 h20 c0xCCCCCC", "Config File:")
    configPathText := configGui.Add("Text", "x20 y395 w460 h40 c0xFFFFFF Wrap", configFile)
    configPathText.SetFont("s8")
    
    ; Add Open in Explorer button
    explorerBtn := configGui.Add("Button", "x490 y390 w90 h35", "📂 Open`nFolder")
    explorerBtn.OnEvent("Click", (*) => OpenConfigInExplorer())
    
    configGui.Show("w600 h445")
}

; Open config folder in Explorer
OpenConfigInExplorer() {
    global configFile
    SplitPath(configFile, , &configDir)
    try {
        Run('explorer.exe /select,"' . configFile . '"')
    } catch {
        try {
            Run('explorer.exe "' . configDir . '"')
        } catch as e {
            MsgBox("Could not open folder: " . e.Message, "Error", "OK IconX")
        }
    }
}

; Browse for file
BrowseForFile(editControl) {
    selectedFile := FileSelect(3, "", "Select Executable or File", "Executables (*.exe; *.lnk)")
    if (selectedFile != "") {
        editControl.Value := selectedFile
    }
}

; Edit button
EditButton(menuId, lv, parentGui) {
    global config
    
    selected := lv.GetNext()
    if (selected = 0) {
        parentGui.Opt("+OwnDialogs")
        MsgBox("Please select a button to edit.", "Edit Button", "OK")
        return
    }
    
    btnKey := menuId . "_btn" . selected
    btn := config[btnKey]
    
    editGui := Gui("+AlwaysOnTop +Owner" . parentGui.Hwnd, "✏️ Edit Button")
    editGui.BackColor := "0x34495E"
    editGui.SetFont("s10", "Segoe UI")
    
    editGui.Add("Text", "x20 y20 w360 h20 c0xFFFFFF", "Button Text (with &hotkey):")
    textEdit := editGui.Add("Edit", "x20 y45 w360 h25", btn["text"])
    
    editGui.Add("Text", "x20 y80 w360 h20 c0xFFFFFF", "Hotkey Letter (single char):")
    hotkeyEdit := editGui.Add("Edit", "x20 y105 w360 h25", btn["hotkey"])
    
    editGui.Add("Text", "x20 y140 w360 h20 c0xFFFFFF", "Action Type:")
    ; FIXED: Added AltSubmit option to get the actual text value
    actionDDL := editGui.Add("DropDownList", "x20 y165 w360", ["url", "input", "submenu", "exe"])
    if (btn["action"] = "input")
        actionDDL.Choose(2)
    else if (btn["action"] = "submenu")
        actionDDL.Choose(3)
    else if (btn["action"] = "exe")
        actionDDL.Choose(4)
    else
        actionDDL.Choose(1)
    
    editGui.Add("Text", "x20 y200 w360 h20 c0xFFFFFF", "Target (URL/Template/Submenu/EXE):")
    editGui.Add("Text", "x20 y220 w360 h15 c0xCCCCCC", "Use {INPUT} for input placeholders")
    targetEdit := editGui.Add("Edit", "x20 y235 w360 h25", btn["target"])
    
    browseBtn := editGui.Add("Button", "x20 y270 w100 h30", "📁 Browse...")
    browseBtn.OnEvent("Click", (*) => BrowseForFile(targetEdit))
    
    saveBtn := editGui.Add("Button", "x230 y310 w70 h35", "💾 Save")
    cancelBtn := editGui.Add("Button", "x310 y310 w70 h35", "✕ Cancel")
    
    saveBtn.OnEvent("Click", (*) => SaveButtonEdit(editGui, btnKey, selected, textEdit, hotkeyEdit, actionDDL, targetEdit, lv))
    cancelBtn.OnEvent("Click", (*) => editGui.Destroy())
    
    editGui.Show("w400 h365")
}

; Save button edit
SaveButtonEdit(editGui, btnKey, index, textEdit, hotkeyEdit, actionDDL, targetEdit, lv) {
    global config
    
    newText := textEdit.Value
    newHotkey := hotkeyEdit.Value
    newAction := actionDDL.Text
    newTarget := targetEdit.Value
    
    if (newText = "" || newHotkey = "" || newTarget = "") {
        editGui.Opt("+OwnDialogs")
        MsgBox("All fields are required!", "Validation Error", "OK IconX")
        return
    }
    
    ; Update config
    btn := config[btnKey]
    btn["text"] := newText
    btn["hotkey"] := newHotkey
    btn["action"] := newAction
    btn["target"] := newTarget
    
    ; Update ListView
    lv.Modify(index, "", newText, newHotkey, newAction, newTarget)
    
    editGui.Destroy()
}

; Add button
AddButton(menuId, lv, parentGui) {
    global config
    
    editGui := Gui("+AlwaysOnTop +Owner" . parentGui.Hwnd, "➕ Add New Button")
    editGui.BackColor := "0x34495E"
    editGui.SetFont("s10", "Segoe UI")
    
    editGui.Add("Text", "x20 y20 w360 h20 c0xFFFFFF", "Button Text (with &hotkey):")
    textEdit := editGui.Add("Edit", "x20 y45 w360 h25", "")
    
    editGui.Add("Text", "x20 y80 w360 h20 c0xFFFFFF", "Hotkey Letter (single char):")
    hotkeyEdit := editGui.Add("Edit", "x20 y105 w360 h25", "")
    
    editGui.Add("Text", "x20 y140 w360 h20 c0xFFFFFF", "Action Type:")
    ; FIXED: Removed R4 parameter and let it show all options naturally
    actionDDL := editGui.Add("DropDownList", "x20 y165 w360", ["url", "input", "submenu", "exe"])
    actionDDL.Choose(1)
    
    editGui.Add("Text", "x20 y200 w360 h20 c0xFFFFFF", "Target (URL/Template/EXE Path):")
    editGui.Add("Text", "x20 y220 w360 h15 c0xCCCCCC", "Use {INPUT} for input placeholders")
    targetEdit := editGui.Add("Edit", "x20 y235 w360 h25", "")
    
    browseBtn := editGui.Add("Button", "x20 y270 w100 h30", "📁 Browse...")
    browseBtn.OnEvent("Click", (*) => BrowseForFile(targetEdit))
    
    saveBtn := editGui.Add("Button", "x230 y310 w70 h35", "➕ Add")
    cancelBtn := editGui.Add("Button", "x310 y310 w70 h35", "✕ Cancel")
    
    saveBtn.OnEvent("Click", (*) => SaveNewButton(editGui, menuId, textEdit, hotkeyEdit, actionDDL, targetEdit, lv))
    cancelBtn.OnEvent("Click", (*) => editGui.Destroy())
    
    editGui.Show("w400 h365")
}

; Save new button
SaveNewButton(editGui, menuId, textEdit, hotkeyEdit, actionDDL, targetEdit, lv) {
    global config, configFile
    
    newText := textEdit.Value
    newHotkey := hotkeyEdit.Value
    newAction := actionDDL.Text
    newTarget := targetEdit.Value
    
    if (newText = "" || newHotkey = "" || newTarget = "") {
        editGui.Opt("+OwnDialogs")
        MsgBox("All fields are required!", "Validation Error", "OK IconX")
        return
    }
    
    ; If action is submenu, create the submenu if it doesn't exist
    if (newAction = "submenu") {
        if (!config.Has(newTarget)) {
            ; Create new submenu
            editGui.Opt("+OwnDialogs")
            result := MsgBox("The submenu '" . newTarget . "' doesn't exist yet.`n`nDo you want to create it now?", "Create Submenu", "YesNo 32")
            if (result = "Yes") {
                ; Create empty submenu
                config[newTarget] := Map(
                    "title", "📁 " . newTarget,
                    "buttonCount", 0
                )
                
                ; Save to INI
                IniWrite(config[newTarget]["title"], configFile, newTarget, "title")
                IniWrite("0", configFile, newTarget, "buttonCount")
                
                editGui.Opt("+OwnDialogs")
                MsgBox("Submenu '" . newTarget . "' created!`n`nYou can configure it later by clicking that button and selecting 'Config'.", "Created", "OK Iconi")
            } else {
                return
            }
        }
    }
    
    ; Get current button count
    menuConfig := config[menuId]
    oldCount := menuConfig["buttonCount"]
    newCount := oldCount + 1
    
    ; Create new button
    btnKey := menuId . "_btn" . newCount
    config[btnKey] := Map(
        "text", newText,
        "hotkey", newHotkey,
        "action", newAction,
        "target", newTarget
    )
    
    ; Update button count
    menuConfig["buttonCount"] := newCount
    
    ; Update ListView
    lv.Add("", newText, newHotkey, newAction, newTarget)
    
    editGui.Destroy()
}

; Delete button
DeleteButton(menuId, lv, parentGui) {
    global config
    
    selected := lv.GetNext()
    if (selected = 0) {
        parentGui.Opt("+OwnDialogs")
        MsgBox("Please select a button to delete.", "Delete Button", "OK")
        return
    }
    
    parentGui.Opt("+OwnDialogs")
    result := MsgBox("Are you sure you want to delete this button?", "Confirm Delete", "YesNo 32")
    if (result = "No")
        return
    
    ; Get button count
    menuConfig := config[menuId]
    buttonCount := menuConfig["buttonCount"]
    
    ; Shift all buttons after the deleted one
    Loop (buttonCount - selected) {
        currentIdx := selected + A_Index - 1
        nextIdx := currentIdx + 1
        currentKey := menuId . "_btn" . currentIdx
        nextKey := menuId . "_btn" . nextIdx
        
        config[currentKey] := config[nextKey]
    }
    
    ; Remove last button and update count
    lastKey := menuId . "_btn" . buttonCount
    config.Delete(lastKey)
    menuConfig["buttonCount"] := buttonCount - 1
    
    ; Remove from ListView
    lv.Delete(selected)
}

; Save and close
SaveAndClose(configGui) {
    SaveConfigToINI()
    configGui.Opt("+OwnDialogs")
    
    result := MsgBox("Configuration saved!`n`nReload the launcher now to see your changes?", 
                     "Reload?", 
                     "YesNo Iconi")
    
    configGui.Destroy()
    
    if (result = "Yes") {
        ReloadConfig()
    }
}

; Help tooltip
ShowMainHelpTooltip() {
    global helpTooltipShowing
    helpTooltip := "Keyboard Shortcuts:`n" .
                   "Shift + F1 - Open Launcher`n" .
                   "Shift + ← - Back/Close`n" .
                   "F1 - Show Help`n" .
                   "Shift + Esc - Close`n" .
                   "Shift + <underlined_Letter> - Toggle that Button"
    
    if (!helpTooltipShowing) {
        ToolTip(helpTooltip, 300, 200)
        helpTooltipShowing := true
        SetTimer(HideHelpTooltip, -8000)
    } else {
        HideHelpTooltip()
    }
}

HideHelpTooltip() {
    global helpTooltipShowing
    ToolTip()
    helpTooltipShowing := false
}

; Global hotkeys
+Escape:: {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()
    helpTooltipShowing := false
    HideLoading()
    try {
        if (IsObject(selectionGui) && WinExist(selectionGui.Hwnd)) {
            selectionGui.Destroy()
        }
    } catch {
    }
    currentGUIState := "none"
}

+Left:: {
    global currentGUIState, selectionGui, helpTooltipShowing
    if (currentGUIState != "none" && currentGUIState != "main") {
        ToolTip()
        helpTooltipShowing := false
        HideLoading()
        LaunchBrowser()
    } else if (currentGUIState = "main") {
        ToolTip()
        helpTooltipShowing := false
        HideLoading()
        try {
            if (IsObject(selectionGui) && WinExist(selectionGui.Hwnd)) {
                selectionGui.Destroy()
            }
        } catch {
        }
        currentGUIState := "none"
    } else {
        Send("+{Left}")
    }
}

F1:: {
    global currentGUIState
    if (currentGUIState != "none") {
        ShowMainHelpTooltip()
    } else {
        Send("{F1}")
    }
}

; Handle button action
HandleButtonAction(btn) {
    global selectionGui, currentGUIState, helpTooltipShowing
    
    ToolTip()
    helpTooltipShowing := false
    
    if (btn["action"] = "url" || btn["action"] = "exe") {
        ; Show loading indicator
        ShowLoading()
        ; Give GUI time to render
        Sleep(150)
        
        if (selectionGui) {
            selectionGui.Destroy()
            currentGUIState := "none"
        }
        
        OpenBrowser(btn["target"])
        ; Keep loading visible for a bit
        SetTimer(() => HideLoading(), -800)
    }
    else if (btn["action"] = "input") {
        ; No loading for instant dialog
        ShowInputDialog(btn)
    }
    else if (btn["action"] = "submenu") {
        ; No loading for instant submenu
        ShowSubMenu(btn["target"])
    }
}

; Show input dialog
ShowInputDialog(btn) {
    global selectionGui, helpTooltipShowing
    
    ToolTip()
    helpTooltipShowing := false
    
    if (selectionGui) {
        selectionGui.Destroy()
    }
    
    global selectionGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", "Input Required")
    global currentGUIState := "input"
    selectionGui.BackColor := "0x2C3E50"
    selectionGui.SetFont("s11", "Segoe UI")
    
    selectionGui.Add("Text", "x20 y20 w260 h25 Center c0xFFFFFF", "Enter value:")
    selectionGui.SetFont("s12")
    inputEdit := selectionGui.Add("Edit", "x40 y55 w220 h25 Center")
    
    okBtn := selectionGui.Add("Button", "x40 y95 w100 h35 Default", "✓ OK")
    cancelBtn := selectionGui.Add("Button", "x160 y95 w100 h35", "← Back")
    
    inputEdit.Focus()
    
    okBtn.OnEvent("Click", (*) => ProcessInput(btn, inputEdit))
    cancelBtn.OnEvent("Click", (*) => CancelInput())
    selectionGui.OnEvent("Close", (*) => CancelInput())
    
    selectionGui.Show("w300 h150")
}

ProcessInput(btn, inputEdit) {
    global selectionGui, currentGUIState
    
    inputValue := inputEdit.Value
    selectionGui.Destroy()
    currentGUIState := "none"
    
    if (inputValue != "") {
        url := StrReplace(btn["target"], "{INPUT}", inputValue)
        OpenBrowser(url)
    } else {
        LaunchBrowser()
    }
}

CancelInput() {
    global selectionGui, currentGUIState
    selectionGui.Destroy()
    currentGUIState := "none"
    LaunchBrowser()
}

; Show submenu - FIXED VERSION
ShowSubMenu(menuId) {
    global config, selectionGui, helpTooltipShowing
    
    ToolTip()
    helpTooltipShowing := false
    
    if (selectionGui) {
        selectionGui.Destroy()
    }
    
    menuConfig := config[menuId]
    buttonCount := menuConfig["buttonCount"]
    
    global selectionGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", menuConfig["title"])
    global currentGUIState := menuId
    selectionGui.BackColor := "0x2C3E50"
    selectionGui.SetFont("s12 Bold", "Segoe UI")
    
    ; FIXED: Help button now positioned clearly at the top right, AFTER other elements
    titleText := selectionGui.Add("Text", "x20 y20 w280 h30 Center c0xFFFFFF", "Select an option:")
    titleText.SetFont("s14 Bold")
    
    ; Help button - positioned at top right corner with better visibility
    helpBtn := selectionGui.Add("Button", "x310 y15 w70 h35", "❓ Help")
    helpBtn.SetFont("s10")
    helpBtn.OnEvent("Click", (*) => ShowMainHelpTooltip())
    
    ; Add buttons dynamically
    yPos := 70
    Loop buttonCount {
        btnKey := menuId . "_btn" . A_Index
        btn := config[btnKey]
        btnCtrl := selectionGui.Add("Button", "x40 y" . yPos . " w320 h45", btn["text"])
        btnCtrl.OnEvent("Click", ((b) => (*) => HandleButtonAction(b))(btn))
        yPos += 55
    }
    
    ; Add separator
    selectionGui.Add("Text", "x20 y" . yPos . " w360 h2 Background0x34495E")
    yPos += 15
    
    ; Add buttons in a cleaner layout
    backBtn := selectionGui.Add("Button", "x20 y" . yPos . " w85 h35", "← Back")
    backBtn.OnEvent("Click", (*) => LaunchBrowser())
    
    reloadBtn := selectionGui.Add("Button", "x115 y" . yPos . " w85 h35", "🔄 Reload")
    reloadBtn.OnEvent("Click", (*) => ReloadConfig())
    
    configBtn := selectionGui.Add("Button", "x210 y" . yPos . " w85 h35", "⚙️ Config")
    configBtn.OnEvent("Click", (*) => ShowConfigGUI(menuId))
    
    closeBtn := selectionGui.Add("Button", "x305 y" . yPos . " w75 h35", "✕ Close")
    closeBtn.OnEvent("Click", (*) => CloseGUI())
    
    yPos += 50
    
    selectionGui.OnEvent("Close", (*) => CloseGUIEvent())
    
    selectionGui.Show("w400 h" . yPos)
}

CloseGUI(*) {
    global selectionGui, currentGUIState, helpTooltipShowing
    ToolTip()
    helpTooltipShowing := false
    HideLoading()
    selectionGui.Destroy()
    currentGUIState := "none"
}

CloseGUIEvent(*) {
    global currentGUIState, helpTooltipShowing
    ToolTip()
    helpTooltipShowing := false
    HideLoading()
    currentGUIState := "none"
}

; Launch main browser - FIXED VERSION
LaunchBrowser() {
    global config, helpTooltipShowing
    
    ToolTip()
    helpTooltipShowing := false
    
    try {
        if (IsObject(selectionGui) && WinExist(selectionGui.Hwnd)) {
            selectionGui.Destroy()
        }
    }
    
    menuConfig := config["mainMenu"]
    buttonCount := menuConfig["buttonCount"]
    
    global selectionGui := Gui("+AlwaysOnTop -MaximizeBox -MinimizeBox", menuConfig["title"])
    global currentGUIState := "main"
    selectionGui.BackColor := "0x34495E"
    selectionGui.SetFont("s12 Bold", "Segoe UI")
    
    ; FIXED: Title repositioned to make room for help button
    titleText := selectionGui.Add("Text", "x10 y15 w390 h40 Center c0xFFFFFF", "Which system would you like to launch?")
    titleText.SetFont("s13 Bold")
    
    ; Help button in top-right corner with better positioning
    helpBtn := selectionGui.Add("Button", "x410 y10 w70 h40", "❓ Help")
    helpBtn.SetFont("s10")
    helpBtn.OnEvent("Click", (*) => ShowMainHelpTooltip())
    
    ; Add buttons in 2-column layout
    col1X := 40
    col2X := 260
    yPos := 70
    col := 1
    
    Loop buttonCount {
        btnKey := "mainMenu_btn" . A_Index
        btn := config[btnKey]
        xPos := (col = 1) ? col1X : col2X
        btnCtrl := selectionGui.Add("Button", "x" . xPos . " y" . yPos . " w200 h50", btn["text"])
        btnCtrl.OnEvent("Click", ((b) => (*) => HandleButtonAction(b))(btn))
        
        col++
        if (col > 2) {
            col := 1
            yPos += 60
        }
    }
    
    if (col = 2)
        yPos += 60
    
    yPos += 10
    
    selectionGui.Add("Text", "x20 y" . yPos . " w460 h3 Background0x2C3E50")
    yPos += 15
    
    reloadBtn := selectionGui.Add("Button", "x110 y" . yPos . " w90 h40", "🔄 Reload")
    reloadBtn.OnEvent("Click", (*) => ReloadConfig())
    
    configBtn := selectionGui.Add("Button", "x210 y" . yPos . " w90 h40", "⚙️ Configure")
    configBtn.OnEvent("Click", (*) => ShowConfigGUI("mainMenu"))
    
    closeBtn := selectionGui.Add("Button", "x310 y" . yPos . " w90 h40", "✕ Close")
    closeBtn.OnEvent("Click", (*) => CloseGUI())
    
    yPos += 55
    
    selectionGui.OnEvent("Close", (*) => CloseGUIEvent())
    
    selectionGui.Show("w500 h" . yPos)
}

; Hotkey to open
+F1:: LaunchBrowser()

; Initialize
InitializeConfig()

; Set icon
try {
    TraySetIcon(epicLauncherDir "\Epic.ico")
} catch {
}