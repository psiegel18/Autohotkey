#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ==============================================================================
; ClaudeCodeLauncher.ahk
; Toggle hotkey: Ctrl+Alt+C
; To change the hotkey, update the ^!c:: line below
; ==============================================================================

; --- Globals ------------------------------------------------------------------
global INI_FILE := A_ScriptDir "\claude_projects.ini"
global LAUNCHER := unset
global LV := unset
global STATUS_TXT := unset
global SEARCH_BOX := unset
global BTN_CLEAR := unset
global BTN_LAUNCH := unset
global BTN_ADD := unset
global BTN_REMOVE := unset
global BTN_REFRESH := unset
global SORT_COL := 0      ; 0=last-used, 1=name, 2=path (3=notes is unsortable)
global SORT_ASC := true

; Create INI with starter entry if missing
if !FileExist(INI_FILE)
    IniWrite("C:\Users\psiegel\OneDrive\Code", INI_FILE, "Projects", "Code")

; ==============================================================================
; Tray icon
; ==============================================================================
A_TrayMenu.Delete()
A_TrayMenu.Add("Show Launcher", (*) => ShowLauncher())
A_TrayMenu.Add("Refresh Projects", (*) => RefreshList())
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_IconTip := "Claude Code Launcher — Ctrl+Alt+C"

; ==============================================================================
; Hotkey
; ==============================================================================
^!c:: ToggleGUI()

; GUI-scoped keyboard shortcuts
HotIfWinActive("Claude Code Launcher")
Hotkey("Enter", (*) => LaunchSelected())
Hotkey("F2", (*) => RenameSelected())
Hotkey("Delete", (*) => RemoveSelected())   ; guarded inside RemoveSelected
HotIf()

; ==============================================================================
; Toggle / Show helpers
; ==============================================================================
ToggleGUI() {
    global LAUNCHER
    if !IsSet(LAUNCHER) {
        BuildGUI()
        LAUNCHER.Show(GetShowOpts())
        return
    }
    try {
        hwnd := LAUNCHER.Hwnd
        if WinActive("ahk_id " hwnd)
            HideAndSave()
        else {
            LAUNCHER.Show(GetShowOpts())
            WinActivate("ahk_id " hwnd)
        }
    } catch {
        BuildGUI()
        LAUNCHER.Show(GetShowOpts())
    }
}

ShowLauncher() {
    global LAUNCHER
    if !IsSet(LAUNCHER) {
        BuildGUI()
        LAUNCHER.Show(GetShowOpts())
        return
    }
    try {
        LAUNCHER.Show(GetShowOpts())
        WinActivate("ahk_id " LAUNCHER.Hwnd)
    } catch {
        BuildGUI()
        LAUNCHER.Show(GetShowOpts())
    }
}

HideAndSave() {
    global LAUNCHER
    try {
        SaveWindowPos()
        LAUNCHER.Hide()
    }
}

; ==============================================================================
; Window position / size persistence
; ==============================================================================
GetShowOpts() {
    global INI_FILE
    x := IniRead(INI_FILE, "Window", "X", "")
    y := IniRead(INI_FILE, "Window", "Y", "")
    w := IniRead(INI_FILE, "Window", "W", "640")
    h := IniRead(INI_FILE, "Window", "H", "460")

    ; Clamp size to reasonable bounds
    w := Max(400, Min(w, 1200))
    h := Max(300, Min(h, 900))

    ; Only use saved position if it lands on a real monitor
    if x != "" && y != "" {
        if MonitorGetCount() > 0 {
            onScreen := false
            loop MonitorGetCount() {
                MonitorGet(A_Index, &mL, &mT, &mR, &mB)
                if (x + 50 >= mL && x < mR - 50 && y + 30 >= mT && y < mB - 30)
                    onScreen := true
            }
            if onScreen
                return "x" x " y" y " w" w " h" h
        }
    }
    return "w" w " h" h
}

SaveWindowPos() {
    global LAUNCHER, INI_FILE
    try {
        WinGetPos(&x, &y, &w, &h, "ahk_id " LAUNCHER.Hwnd)
        IniWrite(x, INI_FILE, "Window", "X")
        IniWrite(y, INI_FILE, "Window", "Y")
        IniWrite(w, INI_FILE, "Window", "W")
        IniWrite(h, INI_FILE, "Window", "H")
    }
}

; ==============================================================================
; GUI Construction
; ==============================================================================
BuildGUI() {
    global LAUNCHER, LV, STATUS_TXT, SEARCH_BOX, BTN_CLEAR
    global BTN_LAUNCH, BTN_ADD, BTN_REMOVE, BTN_REFRESH

    LAUNCHER := Gui("+Resize +AlwaysOnTop -MaximizeBox", "Claude Code Launcher")
    LAUNCHER.BackColor := "F2F2F7"

    LAUNCHER.SetFont("s11 c1a1a2e Bold", "Segoe UI")
    LAUNCHER.Add("Text", "x12 y10 w616", "Claude Code — Project Launcher")

    LAUNCHER.SetFont("s9 c555570 norm", "Segoe UI")
    LAUNCHER.Add("Text", "x12 y32 w616", "Double-click or Enter to launch  ·  F2=Rename  Del=Remove  Right-click for more")

    ; Search bar
    LAUNCHER.SetFont("s9 c1a1a2e norm", "Segoe UI")
    SEARCH_BOX := LAUNCHER.Add("Edit", "x12 y58 w578 h24 BackgroundFFFFFF c1a1a2e")
    SEARCH_BOX.OnEvent("Change", (*) => FilterList())
    SendMessage(0x1501, true, StrPtr("  Search projects..."), SEARCH_BOX)   ; EM_SETCUEBANNER

    BTN_CLEAR := LAUNCHER.Add("Button", "x598 y58 w30 h24", "×")
    BTN_CLEAR.OnEvent("Click", (*) => CCL_ClearSearch())

    ; ListView — 3 columns: Name | Path | Notes
    LV := LAUNCHER.Add("ListView",
        "x12 y88 w616 h290 BackgroundFFFFFF c1a1a2e +Grid +LV0x10000 AltSubmit",
        ["Project Name", "Path", "Notes"])
    LV.ModifyCol(1, 155)
    LV.ModifyCol(2, 300)
    LV.ModifyCol(3, 135)
    LV.OnEvent("DoubleClick", CCL_LV_DoubleClick)
    LV.OnEvent("ContextMenu", LV_ContextMenu)
    LV.OnEvent("ColClick", LV_ColClick)

    ; Buttons
    LAUNCHER.SetFont("s9 c1a1a2e norm", "Segoe UI")
    bOpts := "h28 w105"
    BTN_LAUNCH := LAUNCHER.Add("Button", "x12  y388 " bOpts, "▶  Launch")
    BTN_ADD := LAUNCHER.Add("Button", "x125 y388 " bOpts, "+  Add Project")
    BTN_REMOVE := LAUNCHER.Add("Button", "x238 y388 " bOpts, "−  Remove")
    BTN_REFRESH := LAUNCHER.Add("Button", "x351 y388 " bOpts, "↻  Refresh")

    BTN_LAUNCH.OnEvent("Click", (*) => LaunchSelected())
    BTN_ADD.OnEvent("Click", (*) => AddProject())
    BTN_REMOVE.OnEvent("Click", (*) => RemoveSelected())
    BTN_REFRESH.OnEvent("Click", (*) => RefreshList())

    ; Status bar
    LAUNCHER.SetFont("s8 c777790 norm", "Segoe UI")
    STATUS_TXT := LAUNCHER.Add("Text", "x12 y426 w616 h20", "Ctrl+Alt+C to toggle  ·  Esc to close")

    LAUNCHER.OnEvent("Close", (*) => HideAndSave())
    LAUNCHER.OnEvent("Escape", (*) => HideAndSave())
    LAUNCHER.OnEvent("Size", OnResize)

    RefreshList()
}

; ==============================================================================
; Core actions
; ==============================================================================
RefreshList() {
    global LV, INI_FILE, SORT_COL, SORT_ASC, SEARCH_BOX

    allProjects := ReadProjects()
    projArray := []
    for name, path in allProjects {
        lastUsed := IniRead(INI_FILE, "LastUsed", name, "0")
        notes := IniRead(INI_FILE, "Descriptions", name, "")
        projArray.Push({ name: name, path: path, lastUsed: lastUsed, notes: notes })
    }

    ; Sort (col 3 / Notes is intentionally unsortable — clicking it is a no-op)
    if SORT_COL = 1
        projArray := SortProjectArray(projArray, "name", SORT_ASC)
    else if SORT_COL = 2
        projArray := SortProjectArray(projArray, "path", SORT_ASC)
    else
        projArray := SortProjectArray(projArray, "lastUsed", false)  ; newest first

    ; Search filter — matches name, path, or notes
    filter := ""
    try filter := Trim(SEARCH_BOX.Value)

    LV.Delete()
    matched := 0
    for item in projArray {
        if filter != ""
            && !InStr(item.name, filter, false)
            && !InStr(item.path, filter, false)
            && !InStr(item.notes, filter, false)
            continue
        LV.Add("", item.name, item.path, item.notes)
        matched++
    }

    total := projArray.Length
    SetStatus(filter != ""
        ? matched " of " total " project(s) match  ·  Ctrl+Alt+C to toggle  ·  Esc to close"
        : total " project(s) loaded  ·  Ctrl+Alt+C to toggle  ·  Esc to close")

    UpdateColHeaders()
}

FilterList() {
    RefreshList()
}

CCL_ClearSearch() {
    global SEARCH_BOX
    SEARCH_BOX.Value := ""
    RefreshList()
}

; --- Launch (new tab) ---------------------------------------------------------
LaunchSelected() {
    global LV, INI_FILE
    row := GetSelectedRow()
    if !row
        return
    name := LV.GetText(row, 1)
    path := LV.GetText(row, 2)
    if !ValidatePath(name, path)
        return
    IniWrite(A_Now, INI_FILE, "LastUsed", name)
    Run('wt.exe -w 0 nt -d "' path '" claude')
    SetStatus("Launched: " name)
    HideAndSave()
}

; --- Launch (new window) ------------------------------------------------------
LaunchInNewWindow() {
    global LV, INI_FILE
    row := GetSelectedRow()
    if !row
        return
    name := LV.GetText(row, 1)
    path := LV.GetText(row, 2)
    if !ValidatePath(name, path)
        return
    IniWrite(A_Now, INI_FILE, "LastUsed", name)
    Run('wt.exe -w new nt -d "' path '" claude')
    SetStatus("Launched in new window: " name)
    HideAndSave()
}

; --- Add ----------------------------------------------------------------------
AddProject() {
    global INI_FILE

    folder := DirSelect("*" A_MyDocuments, 3, "Select Project Folder")
    if !folder
        return

    defaultName := RegExReplace(folder, ".*[\\/]", "")
    ib := InputBox("Friendly name for this project:", "Add Project", "w340 h120", defaultName)
    if ib.Result = "Cancel" || Trim(ib.Value) = ""
        return

    name := Trim(ib.Value)
    if ReadProjects().Has(name) {
        MsgBox("A project named '" name "' already exists.", "Duplicate", "Iconi")
        return
    }

    IniWrite(folder, INI_FILE, "Projects", name)
    RefreshList()
    SetStatus("Added: " name)
}

; --- Remove -------------------------------------------------------------------
RemoveSelected() {
    global LV, SEARCH_BOX, LAUNCHER

    ; Don't steal Delete from the search box
    try {
        if IsSet(LAUNCHER) && IsSet(SEARCH_BOX) {
            focusClass := ControlGetFocus("ahk_id " LAUNCHER.Hwnd)
            if ControlGetHwnd(focusClass, "ahk_id " LAUNCHER.Hwnd) = SEARCH_BOX.Hwnd
                return
        }
    }

    row := GetSelectedRow()
    if !row
        return
    name := LV.GetText(row, 1)
    path := LV.GetText(row, 2)

    ans := MsgBox(
        "Remove '" name "' from the launcher?`n`nPath: " path
        "`n`n(No files will be deleted — only the launcher entry.)",
        "Remove Project", "YesNo Icon?")
    if ans = "Yes" {
        DeleteProject(name)
        SetStatus("Removed: " name)
    }
}

; --- Rename -------------------------------------------------------------------
RenameSelected() {
    global LV, INI_FILE
    row := GetSelectedRow()
    if !row
        return
    oldName := LV.GetText(row, 1)
    path := LV.GetText(row, 2)

    ib := InputBox("New name for this project:", "Rename Project", "w340 h120", oldName)
    if ib.Result = "Cancel" || Trim(ib.Value) = "" || Trim(ib.Value) = oldName
        return

    newName := Trim(ib.Value)
    if ReadProjects().Has(newName) {
        MsgBox("A project named '" newName "' already exists.", "Duplicate", "Iconi")
        return
    }

    ; Carry over last-used timestamp and notes
    oldTS := IniRead(INI_FILE, "LastUsed", oldName, "0")
    oldDesc := IniRead(INI_FILE, "Descriptions", oldName, "")
    IniDelete(INI_FILE, "Projects", oldName)
    IniDelete(INI_FILE, "LastUsed", oldName)
    IniDelete(INI_FILE, "Descriptions", oldName)
    IniWrite(path, INI_FILE, "Projects", newName)
    if oldTS != "0"
        IniWrite(oldTS, INI_FILE, "LastUsed", newName)
    if oldDesc != ""
        IniWrite(oldDesc, INI_FILE, "Descriptions", newName)

    RefreshList()
    ReselectRow(newName)
    SetStatus("Renamed: " oldName " → " newName)
}

; --- Edit Path ----------------------------------------------------------------
EditPath() {
    global LV, INI_FILE
    row := GetSelectedRow()
    if !row
        return
    name := LV.GetText(row, 1)
    curPath := LV.GetText(row, 2)

    ; Start picker in the current directory
    newPath := DirSelect("*" curPath, 3, "Select New Folder for '" name "'")
    if !newPath || newPath = curPath
        return

    IniWrite(newPath, INI_FILE, "Projects", name)
    RefreshList()
    ReselectRow(name)
    SetStatus("Path updated: " name)
}

; --- Edit Notes ---------------------------------------------------------------
EditNotes() {
    global LV, INI_FILE
    row := GetSelectedRow()
    if !row
        return
    name := LV.GetText(row, 1)
    curNotes := LV.GetText(row, 3)

    ib := InputBox("Notes for '" name "':", "Edit Notes", "w400 h120", curNotes)
    if ib.Result = "Cancel"
        return

    newNotes := Trim(ib.Value)
    if newNotes = ""
        IniDelete(INI_FILE, "Descriptions", name)
    else
        IniWrite(newNotes, INI_FILE, "Descriptions", name)

    RefreshList()
    ReselectRow(name)
    SetStatus("Notes updated: " name)
}

; --- Open in Explorer ---------------------------------------------------------
OpenInExplorer() {
    global LV
    row := GetSelectedRow()
    if !row
        return
    path := LV.GetText(row, 2)
    if !DirExist(path) {
        SetStatus("Path not found: " path)
        return
    }
    Run('explorer.exe "' path '"')
}

; --- Delete (internal) --------------------------------------------------------
DeleteProject(name) {
    global INI_FILE
    IniDelete(INI_FILE, "Projects", name)
    IniDelete(INI_FILE, "LastUsed", name)
    IniDelete(INI_FILE, "Descriptions", name)
    RefreshList()
}

; ==============================================================================
; Right-click context menu
; ==============================================================================
LV_ContextMenu(ctrl, row, isRightClick, x, y) {
    if !row
        return
    ctxMenu := Menu()
    ctxMenu.Add("▶  Launch (new tab)", (*) => LaunchSelected())
    ctxMenu.Add("▶  Launch (new window)", (*) => LaunchInNewWindow())
    ctxMenu.Add("📂  Open in Explorer", (*) => OpenInExplorer())
    ctxMenu.Add()
    ctxMenu.Add("✎  Rename", (*) => RenameSelected())
    ctxMenu.Add("📁  Edit Path", (*) => EditPath())
    ctxMenu.Add("🗒  Edit Notes", (*) => EditNotes())
    ctxMenu.Add()
    ctxMenu.Add("−  Remove", (*) => RemoveSelected())
    ctxMenu.Show(x, y)
}

; ==============================================================================
; Column sort (col 3 / Notes is intentionally unsortable)
; ==============================================================================
LV_ColClick(ctrl, col) {
    global SORT_COL, SORT_ASC
    if col = 3
        return
    if SORT_COL = col
        SORT_ASC := !SORT_ASC
    else {
        SORT_COL := col
        SORT_ASC := true
    }
    RefreshList()
}

UpdateColHeaders() {
    global LV, SORT_COL, SORT_ASC
    ind := SORT_ASC ? " ▲" : " ▼"
    LV.ModifyCol(1, , (SORT_COL = 1 ? "Project Name" ind : "Project Name"))
    LV.ModifyCol(2, , (SORT_COL = 2 ? "Path" ind : "Path"))
    LV.ModifyCol(3, , "Notes")
}

; ==============================================================================
; Helpers
; ==============================================================================
ReadProjects() {
    global INI_FILE
    result := Map()
    try {
        raw := IniRead(INI_FILE, "Projects")
        loop parse, raw, "`n", "`r" {
            if !A_LoopField
                continue
            eqPos := InStr(A_LoopField, "=")
            if !eqPos
                continue
            key := Trim(SubStr(A_LoopField, 1, eqPos - 1))
            val := Trim(SubStr(A_LoopField, eqPos + 1))
            result[key] := val
        }
    }
    return result
}

GetSelectedRow() {
    global LV
    row := LV.GetNext(0, "Focused")
    if !row
        row := LV.GetNext(0)
    if !row
        SetStatus("Select a project first.")
    return row
}

ValidatePath(name, path) {
    if DirExist(path)
        return true
    ans := MsgBox(
        "Path for '" name "' no longer exists:`n" path
        "`n`nRemove this stale entry?",
        "Path Not Found", "YesNo Icon!")
    if ans = "Yes"
        DeleteProject(name)
    return false
}

ReselectRow(name) {
    global LV
    loop LV.GetCount() {
        if LV.GetText(A_Index, 1) = name {
            LV.Modify(A_Index, "Select Focus Vis")
            break
        }
    }
}

; Stable insertion sort
SortProjectArray(arr, field, ascending) {
    n := arr.Length
    loop n - 1 {
        i := A_Index + 1
        cur := arr[i]
        j := i - 1
        while j >= 1 {
            shouldSwap := ascending ? (arr[j].%field% > cur.%field%) : (arr[j].%field% < cur.%field%)
            if !shouldSwap
                break
            arr[j + 1] := arr[j]
            j--
        }
        arr[j + 1] := cur
    }
    return arr
}

SetStatus(msg) {
    global STATUS_TXT
    STATUS_TXT.Value := msg
}

CCL_LV_DoubleClick(ctrl, row) {
    if row > 0
        LaunchSelected()
}

; ==============================================================================
; Resize handler
; ==============================================================================
OnResize(guiObj, minMax, width, height) {
    global LV, STATUS_TXT, SEARCH_BOX, BTN_CLEAR
    global BTN_LAUNCH, BTN_ADD, BTN_REMOVE, BTN_REFRESH
    if minMax = -1
        return

    SEARCH_BOX.Move(, , width - 62)
    BTN_CLEAR.Move(width - 42)
    LV.Move(, , width - 24, Max(height - 170, 60))

    btnY := height - 72
    statusY := height - 34
    STATUS_TXT.Move(, statusY, width - 24)
    BTN_LAUNCH.Move(12, btnY)
    BTN_ADD.Move(125, btnY)
    BTN_REMOVE.Move(238, btnY)
    BTN_REFRESH.Move(351, btnY)
}