#Requires AutoHotkey v2.0
#Warn All
#SingleInstance Force

; Global variables
global MyGui := ""
global GuiVisible := false

class CredentialManager {
    static instance := ""
    credentialsFile := ""
    credentials := Map()
    mainGui := ""

    __New() {
        this.credentialsFile := "credentials.txt"
        this.LoadCredentials()
        this.CreateMainGui()
    }

    static GetInstance() {
        if !CredentialManager.instance
            CredentialManager.instance := CredentialManager()
        return CredentialManager.instance
    }

    LoadCredentials() {
        try {
            if FileExist(this.credentialsFile) {
                fileContent := FileRead(this.credentialsFile)
                loop parse, fileContent, "`n", "`r" {
                    if (A_LoopField = "")
                        continue
                    parts := StrSplit(A_LoopField, "|")
                    if (parts.Length >= 3)
                        this.credentials[parts[1]] := { username: parts[2], password: parts[3] }
                }
            }
        }
    }

    SaveCredentials() {
        try {
            ; Build file content
            fileContent := ""
            for role, data in this.credentials {
                if (role != "" && data.username != "" && data.password != "")
                    fileContent .= role . "|" . data.username . "|" . data.password . "`n"
            }

            ; Ensure file exists
            if !FileExist(this.credentialsFile)
                FileAppend "", this.credentialsFile

            ; Write file with proper line endings
            f := FileOpen(this.credentialsFile, "w", "UTF-8")
            if f {
                f.Write(RTrim(fileContent, "`n"))  ; Remove trailing newline
                f.Close()
            } else {
                throw Error("Could not open file for writing")
            }
        } catch as err {
            MsgBox("Error saving credentials: " . err.Message)
        }
    }

    CreateMainGui() {
        this.mainGui := Gui("+Resize", "Login Credential Manager")
        this.mainGui.OnEvent("Close", this.HideGui.Bind(this))

        ; Add controls
        this.mainGui.Add("Button", "x10 y10 w100", "Add Role").OnEvent("Click", this.ShowAddRoleGui.Bind(this))
        this.mainGui.Add("Button", "x120 y10 w100", "Remove Role").OnEvent("Click", this.ShowRemoveRoleGui.Bind(this))
        this.mainGui.Add("Button", "x230 y10 w100", "Modify Role").OnEvent("Click", this.ShowModifyRoleGui.Bind(this))
        this.mainGui.Add("Button", "x340 y10 w100", "Reload App").OnEvent("Click", (*) => this.ReloadApp())

        ; Create role buttons
        this.RefreshRoleButtons()
    }

    ReloadApp() {
        ; Store current window position
        try {
            IniWrite(this.mainGui.X, "settings.ini", "Window", "X")
            IniWrite(this.mainGui.Y, "settings.ini", "Window", "Y")
        }
        Reload()
    }

    RestoreWindowPosition() {
        try {
            x := IniRead("settings.ini", "Window", "X")
            y := IniRead("settings.ini", "Window", "Y")
            this.mainGui.Move(x, y)
        }
    }

    HideGui(*) {
        global GuiVisible
        this.mainGui.Hide()
        GuiVisible := false
    }

    RefreshRoleButtons() {
        buttonY := 50  ; Reset buttonY each time

        ; Remove all existing controls
        try this.mainGui.Destroy()

        ; Create a new GUI window
        this.mainGui := Gui("+Resize", "Login Credential Manager")
        this.mainGui.OnEvent("Close", this.HideGui.Bind(this))

        ; Recreate control buttons
        this.mainGui.Add("Button", "x10 y10 w100", "Add Role").OnEvent("Click", this.ShowAddRoleGui.Bind(this))
        this.mainGui.Add("Button", "x120 y10 w100", "Remove Role").OnEvent("Click", this.ShowRemoveRoleGui.Bind(this))
        this.mainGui.Add("Button", "x230 y10 w100", "Modify Role").OnEvent("Click", this.ShowModifyRoleGui.Bind(this))
        this.mainGui.Add("Button", "x340 y10 w100", "Reload App").OnEvent("Click", (*) => this.ReloadApp())

        ; Add role buttons
        for role, data in this.credentials {
            roleButton := this.mainGui.Add("Button", "x10 y" buttonY " w320", role)
            roleButton.OnEvent("Click", this.HandleRoleClick.Bind(this, role))
            buttonY += 40
        }

        ; Show GUI and restore position
        try {
            this.mainGui.Show("AutoSize")
            this.RestoreWindowPosition()
        }
    }

    ShowAddRoleGui(*) {
        addGui := Gui("+Owner" this.mainGui.Hwnd " +ToolWindow", "Add New Role")
        addGui.Add("Text", , "Role Name:")
        roleName := addGui.Add("Edit", "w200")
        addGui.Add("Text", , "Username:")
        username := addGui.Add("Edit", "w200")
        addGui.Add("Text", , "Password:")
        password := addGui.Add("Edit", "w200")

        addGui.Add("Button", "Default w100", "Save").OnEvent("Click", (ctrl, *) => this.AddRole(addGui, roleName.Value, username.Value, password.Value))
        addGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (ctrl, *) => addGui.Destroy())

        addGui.Show()
    }

    AddRole(gui, role, username, password, *) {
        if (role = "" || username = "" || password = "") {
            MsgBox("Please fill in all fields.")
            return
        }

        this.credentials[role] := { username: username, password: password }
        this.SaveCredentials()
        this.RefreshRoleButtons()
        gui.Destroy()
    }

    ShowRemoveRoleGui(*) {
        if (this.credentials.Count = 0) {
            MsgBox("No roles to remove.")
            return
        }

        ; Create array of roles for ListBox
        roleArray := []
        for role, data in this.credentials {
            roleArray.Push(role)
        }

        removeGui := Gui("+Owner" this.mainGui.Hwnd " +ToolWindow", "Remove Role")
        removeGui.Add("Text", , "Select Role to Remove:")
        roleList := removeGui.Add("ListBox", "w200", roleArray)

        removeGui.Add("Button", "Default w100", "Remove").OnEvent("Click", (ctrl, *) => this.RemoveRole(removeGui, roleList.Text))
        removeGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (ctrl, *) => removeGui.Destroy())

        removeGui.Show()
    }

    RemoveRole(gui, role, *) {
        if (role = "") {
            MsgBox("Please select a role to remove.")
            return
        }

        this.credentials.Delete(role)
        this.SaveCredentials()
        this.RefreshRoleButtons()
        gui.Destroy()
    }

    ShowModifyRoleGui(*) {
        if (this.credentials.Count = 0) {
            MsgBox("No roles to modify.")
            return
        }

        ; Create array of roles for ListBox
        roleArray := []
        for role, data in this.credentials {
            roleArray.Push(role)
        }

        modifyGui := Gui("+Owner" this.mainGui.Hwnd " +ToolWindow", "Modify Role")
        modifyGui.Add("Text", , "Select Role:")
        roleList := modifyGui.Add("ListBox", "w200", roleArray)

        modifyGui.Add("Text", , "New Username:")
        username := modifyGui.Add("Edit", "w200")
        modifyGui.Add("Text", , "New Password:")
        password := modifyGui.Add("Edit", "w200")

        modifyGui.Add("Button", "Default w100", "Save").OnEvent("Click", (ctrl, *) => this.ModifyRole(modifyGui, roleList.Text, username.Value, password.Value))
        modifyGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (ctrl, *) => modifyGui.Destroy())

        modifyGui.Show()
    }

    ModifyRole(gui, role, username, password, *) {
        if (role = "") {
            MsgBox("Please select a role to modify.")
            return
        }

        if (username = "" || password = "") {
            MsgBox("Please fill in all fields.")
            return
        }

        this.credentials[role] := { username: username, password: password }
        this.SaveCredentials()
        this.RefreshRoleButtons()
        gui.Destroy()
    }

    HandleRoleClick(role, *) {
        if !this.credentials.Has(role)
            return

        MsgBox("Click OK and then click in the username field.", "Ready to Input", "T3")

        ; Wait for left click
        KeyWait "LButton"
        KeyWait "LButton", "D"
        Sleep 100

        ; Send credentials
        cred := this.credentials[role]

        ; Send username
        A_Clipboard := cred.username
        Send "^v"
        Sleep 100

        ; Send tab and wait
        Send "{Tab}"
        Sleep 100

        ; Clear clipboard and set password
        A_Clipboard := ""
        Sleep 50
        A_Clipboard := cred.password

        ; Send password
        Send "^v"
        Sleep 100

        ; Clear clipboard for security
        A_Clipboard := ""
    }

    ShowGui() {
        global GuiVisible
        this.mainGui.Show()
        this.RestoreWindowPosition()
        GuiVisible := true
    }
}

; Handle hotkey
ToggleLoginManager(*) {
    static manager := CredentialManager.GetInstance()
    if GuiVisible {
        manager.HideGui()
    } else {
        manager.ShowGui()
    }
}

; Set icon and hotkey
TraySetIcon("LoginIcon.ico")
Hotkey "^!/", ToggleLoginManager  ; Ctrl+Alt+/
