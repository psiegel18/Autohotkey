#Requires AutoHotkey v2.0
#Warn All
#SingleInstance Force

; Global variables
global MyGui := ""
global GuiVisible := false

; Modern color scheme
global Colors := {
    Primary: "0x2C3E50",      ; Dark blue-gray
    Secondary: "0x34495E",    ; Lighter blue-gray
    Accent: "0x3498DB",       ; Bright blue
    Success: "0x27AE60",      ; Green
    Warning: "0xF39C12",      ; Orange
    Danger: "0xE74C3C",       ; Red
    Light: "0xECF0F1",        ; Light gray
    White: "0xFFFFFF",        ; White
    Text: "0x2C3E50",         ; Dark text
    TextLight: "0x7F8C8D"     ; Light text
}

class CredentialManager {
    static instance := ""
    credentialsFile := ""
    credentials := Map()
    mainGui := ""
    currentFavoritePage := 0  ; Track current page of favorites
    favoritesPerPage := 10    ; Show 10 favorites per page

    __New() {
        this.credentialsFile := A_ScriptDir "\credentials.txt"
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
                    if (parts.Length >= 3) {
                        ; Check if favorite flag exists (for backward compatibility)
                        isFavorite := (parts.Length >= 4) ? (parts[4] = "1") : false
                        this.credentials[parts[1]] := { 
                            username: parts[2], 
                            password: parts[3],
                            favorite: isFavorite
                        }
                    }
                }
            }
        }
    }

    SaveCredentials() {
        try {
            fileContent := ""
            for role, data in this.credentials {
                if (role != "" && data.username != "" && data.password != "") {
                    favoriteFlag := data.favorite ? "1" : "0"
                    fileContent .= role . "|" . data.username . "|" . data.password . "|" . favoriteFlag . "`n"
                }
            }

            if !FileExist(this.credentialsFile)
                FileAppend "", this.credentialsFile

            f := FileOpen(this.credentialsFile, "w", "UTF-8")
            if f {
                f.Write(RTrim(fileContent, "`n"))
                f.Close()
            } else {
                throw Error("Could not open file for writing")
            }
        } catch as err {
            MsgBox("Error saving credentials: " . err.Message)
        }
    }

    GetFavoriteCredentials() {
        favorites := Map()
        for role, data in this.credentials {
            if (data.favorite)
                favorites[role] := data
        }
        return favorites
    }

    CreateMainGui() {
        ; Create main GUI with modern styling
        this.mainGui := Gui("+Resize -MaximizeBox", "🔐 Credential Manager")
        this.mainGui.OnEvent("Close", this.HideGui.Bind(this))
        this.mainGui.BackColor := Colors.Light
        this.mainGui.MarginX := 0
        this.mainGui.MarginY := 0

        ; Create header section
        headerHeight := 80
        this.CreateHeader(headerHeight)
        
        ; Create main content area with reduced spacing
        this.CreateMainContent(headerHeight)
        
        ; Show with initial size - RefreshFavoriteButtons will resize properly
        this.mainGui.Show("w520 h500")
    }

    CreateHeader(height) {
        ; Header background (simulated with a text control)
        headerBg := this.mainGui.Add("Text", "x0 y0 w520 h" height " Background" Colors.Primary)
        
        ; Title
        title := this.mainGui.Add("Text", "x20 y15 w480 h35 Center c" Colors.White " Background" Colors.Primary, "🔐 CREDENTIAL MANAGER")
        title.SetFont("s16 Bold", "Segoe UI")
        
        ; Subtitle with total count
        totalCount := this.credentials.Count
        favoriteCount := this.GetFavoriteCredentials().Count
        subtitle := this.mainGui.Add("Text", "x20 y45 w480 h20 Center c" Colors.Light " Background" Colors.Primary, "Secure • Simple • Fast  |  " totalCount " Total • " favoriteCount " Favorites")
        subtitle.SetFont("s9", "Segoe UI")
    }

    CreateMainContent(headerY) {
        contentY := headerY + 10  ; Reduced from 20
        
        ; Action buttons container
        this.CreateActionButtons(contentY)
        
        ; Favorites section with reduced spacing
        this.CreateFavoritesSection(contentY + 50)  ; Reduced from 70
    }

    CreateActionButtons(startY) {
        buttonWidth := 80
        buttonHeight := 35
        spacing := 8
        totalWidth := (buttonWidth * 5) + (spacing * 4)
        startX := (520 - totalWidth) / 2  ; Center the buttons in wider window

        ; Add Role button
        addBtn := this.mainGui.Add("Button", "x" startX " y" startY " w" buttonWidth " h" buttonHeight, "➕ Add")
        addBtn.OnEvent("Click", this.ShowAddRoleGui.Bind(this))
        addBtn.SetFont("s9 Bold", "Segoe UI")

        ; Browse All button
        browseBtn := this.mainGui.Add("Button", "x" (startX + buttonWidth + spacing) " y" startY " w" buttonWidth " h" buttonHeight, "📋 Browse")
        browseBtn.OnEvent("Click", this.ShowBrowseGui.Bind(this))
        browseBtn.SetFont("s9 Bold", "Segoe UI")

        ; Remove Role button
        removeBtn := this.mainGui.Add("Button", "x" (startX + (buttonWidth + spacing) * 2) " y" startY " w" buttonWidth " h" buttonHeight, "🗑️ Remove")
        removeBtn.OnEvent("Click", this.ShowRemoveRoleGui.Bind(this))
        removeBtn.SetFont("s9 Bold", "Segoe UI")

        ; Modify Role button
        modifyBtn := this.mainGui.Add("Button", "x" (startX + (buttonWidth + spacing) * 3) " y" startY " w" buttonWidth " h" buttonHeight, "✏️ Modify")
        modifyBtn.OnEvent("Click", this.ShowModifyRoleGui.Bind(this))
        modifyBtn.SetFont("s9 Bold", "Segoe UI")

        ; Reload button
        reloadBtn := this.mainGui.Add("Button", "x" (startX + (buttonWidth + spacing) * 4) " y" startY " w" buttonWidth " h" buttonHeight, "🔄 Reload")
        reloadBtn.OnEvent("Click", (*) => this.ReloadApp())
        reloadBtn.SetFont("s9 Bold", "Segoe UI")
    }

    CreateFavoritesSection(startY) {
        favorites := this.GetFavoriteCredentials()
        
        ; Section header with reduced spacing
        if (favorites.Count > 0) {
            sectionHeader := this.mainGui.Add("Text", "x20 y" startY " w480 h25 c" Colors.Text, "⭐ FAVORITE CREDENTIALS")
            sectionHeader.SetFont("s10 Bold", "Segoe UI")
            startY += 30  ; Reduced from 35
        }

        ; Create favorite buttons with modern styling
        this.RefreshFavoriteButtons(startY)
    }

    RefreshFavoriteButtons(startY := 130) {
        ; Save current position BEFORE destroying GUI
        try {
            if (this.mainGui.Hwnd) {
                this.mainGui.GetPos(&currentX, &currentY)
                IniWrite(currentX, "settings.ini", "Window", "X")
                IniWrite(currentY, "settings.ini", "Window", "Y")
            }
        } catch {
            ; If we can't get position, use saved position from INI
            try {
                currentX := IniRead("settings.ini", "Window", "X")
                currentY := IniRead("settings.ini", "Window", "Y")
            } catch {
                currentX := 100
                currentY := 100
            }
        }

        ; Destroy and recreate GUI for refresh
        try this.mainGui.Destroy()

        ; Create GUI without scrolling - using pagination instead
        this.mainGui := Gui("+Resize -MaximizeBox", "🔐 Credential Manager")
        this.mainGui.OnEvent("Close", this.HideGui.Bind(this))
        this.mainGui.BackColor := Colors.Light
        this.mainGui.MarginX := 0
        this.mainGui.MarginY := 0

        ; Recreate header and action buttons
        this.CreateHeader(80)
        this.CreateActionButtons(100)

        ; Get all favorites
        allFavorites := this.GetFavoriteCredentials()
        totalFavorites := allFavorites.Count
        
        ; Calculate pagination
        totalPages := Ceil(totalFavorites / this.favoritesPerPage)
        
        ; Ensure current page is valid
        if (this.currentFavoritePage >= totalPages) {
            this.currentFavoritePage := Max(0, totalPages - 1)
        }
        
        ; Calculate which favorites to show on current page
        startIndex := this.currentFavoritePage * this.favoritesPerPage
        endIndex := Min(startIndex + this.favoritesPerPage - 1, totalFavorites - 1)

        ; Convert favorites map to array for easier pagination
        favoriteArray := []
        for role, data in allFavorites {
            favoriteArray.Push({role: role, data: data})
        }

        ; Add favorites section header
        buttonY := startY
        if (totalFavorites > 0) {
            ; Show page info in header
            pageInfo := ""
            if (totalPages > 1) {
                pageInfo := " (Page " (this.currentFavoritePage + 1) " of " totalPages ")"
            }
            sectionHeader := this.mainGui.Add("Text", "x20 y" buttonY " w480 h25 c" Colors.Text, "⭐ FAVORITE CREDENTIALS" pageInfo)
            sectionHeader.SetFont("s10 Bold", "Segoe UI")
            buttonY += 30
        } else {
            ; Show empty state with instructions
            emptyText := this.mainGui.Add("Text", "x20 y" buttonY " w480 h80 Center c" Colors.TextLight, "No favorite credentials selected.`n`nClick '📋 Browse' to view all credentials and mark favorites,`nor click '➕ Add' to create new credentials.")
            emptyText.SetFont("s10", "Segoe UI")
            buttonY += 100
        }

        ; Add navigation buttons if needed
        if (totalPages > 1) {
            ; Previous button
            prevBtn := this.mainGui.Add("Button", "x50 y" buttonY " w100 h30", "⬅️ Previous")
            prevBtn.OnEvent("Click", (*) => this.PreviousFavoritePage())
            prevBtn.SetFont("s9 Bold", "Segoe UI")
            if (this.currentFavoritePage = 0) {
                prevBtn.Enabled := false  ; Disable if on first page
            }
            
            ; Next button
            nextBtn := this.mainGui.Add("Button", "x370 y" buttonY " w100 h30", "Next ➡️")
            nextBtn.OnEvent("Click", (*) => this.NextFavoritePage())
            nextBtn.SetFont("s9 Bold", "Segoe UI")
            if (this.currentFavoritePage >= totalPages - 1) {
                nextBtn.Enabled := false  ; Disable if on last page
            }
            
            buttonY += 40  ; Space after navigation buttons
        }

        ; Display current page of favorites (max 10)
        roleCount := 0
        buttonWidth := 230
        buttonHeight := 40
        columnSpacing := 250
        rowSpacing := 60
        
        leftColumnX := 25
        rightColumnX := leftColumnX + columnSpacing
        currentRow := 0
        
        ; Show favorites for current page
        if (totalFavorites > 0) {
            Loop endIndex - startIndex + 1 {
                i := startIndex + A_Index - 1
                if (i >= favoriteArray.Length) {
                    break
                }
                
                favorite := favoriteArray[i + 1]  ; AutoHotkey arrays are 1-based
                
                ; Determine column and position
                isLeftColumn := (Mod(roleCount, 2) = 0)
                currentButtonX := isLeftColumn ? leftColumnX : rightColumnX
                currentButtonY := buttonY + (currentRow * rowSpacing)
                
                ; Create role button
                roleButton := this.mainGui.Add("Button", "x" currentButtonX " y" currentButtonY " w" buttonWidth " h" buttonHeight, "⭐ " favorite.role)
                roleButton.OnEvent("Click", this.HandleRoleClick.Bind(this, favorite.role))
                roleButton.SetFont("s10 Bold", "Segoe UI")
                
                ; Add username info below button
                usernameInfo := this.mainGui.Add("Text", "x" (currentButtonX + 5) " y" (currentButtonY + buttonHeight + 3) " w" (buttonWidth - 10) " h16 c" Colors.TextLight, "👤 " favorite.data.username)
                usernameInfo.SetFont("s8", "Segoe UI")
                
                roleCount++
                
                ; Move to next row after every 2 buttons
                if (Mod(roleCount, 2) = 0) {
                    currentRow++
                }
            }
        }

        ; Calculate window height (predictable since max 10 favorites)
        maxRowsNeeded := Ceil(Min(this.favoritesPerPage, totalFavorites) / 2.0)
        baseHeight := 80 + 50 + 30  ; header + action buttons + section header
        
        if (totalFavorites > 0) {
            if (totalPages > 1) {
                baseHeight += 40  ; navigation buttons space
            }
            contentHeight := baseHeight + (maxRowsNeeded * rowSpacing) + 60
        } else {
            contentHeight := baseHeight + 100 + 60  ; empty state
        }
        
        ; Show window at exact saved position
        this.mainGui.Show("w520 h" contentHeight " x" currentX " y" currentY)
    }

    ShowBrowseGui(*) {
        browseGui := Gui("+Owner" this.mainGui.Hwnd " +Resize", "📋 Browse All Credentials (" this.credentials.Count " total)")
        browseGui.BackColor := Colors.White
        browseGui.MarginX := 15
        browseGui.MarginY := 15
        
        ; Search section
        browseGui.Add("Text", "x15 y15 c" Colors.Text, "🔍 Search:")
        searchBox := browseGui.Add("Edit", "x70 y12 w300 h25")
        searchBox.SetFont("s10", "Segoe UI")
        searchBtn := browseGui.Add("Button", "x380 y12 w80 h25", "Search")
        searchBtn.SetFont("s9", "Segoe UI")
        
        ; Instructions
        browseGui.Add("Text", "x15 y45 w450 h15 c" Colors.TextLight, "★ = Favorite (shows as button on main screen)  |  Click role name to toggle favorite status")
        
        ; List view for all credentials
        credentialsList := browseGui.Add("ListView", "x15 y70 w450 h300 Grid", ["Status", "Role/Service", "Username"])
        credentialsList.SetFont("s9", "Segoe UI")
        
        ; Populate list
        this.PopulateCredentialsList(credentialsList)
        
        ; Handle double-click to toggle favorite
        credentialsList.OnEvent("DoubleClick", (*) => this.ToggleFavoriteFromList(credentialsList))
        
        ; Handle search
        searchBox.OnEvent("Change", (*) => this.FilterCredentialsList(credentialsList, searchBox.Value))
        searchBtn.OnEvent("Click", (*) => this.FilterCredentialsList(credentialsList, searchBox.Value))
        
        ; Buttons
        favoriteBtn := browseGui.Add("Button", "x15 y380 w100 h30", "⭐ Add Favorite")
        favoriteBtn.OnEvent("Click", (*) => this.ToggleFavoriteFromList(credentialsList))
        favoriteBtn.SetFont("s9 Bold", "Segoe UI")
        
        unfavoriteBtn := browseGui.Add("Button", "x125 y380 w120 h30", "❌ Remove Favorite")
        unfavoriteBtn.OnEvent("Click", (*) => this.ToggleFavoriteFromList(credentialsList))
        unfavoriteBtn.SetFont("s9 Bold", "Segoe UI")
        
        closeBtn := browseGui.Add("Button", "x365 y380 w100 h30", "✅ Done")
        closeBtn.OnEvent("Click", (*) => this.CloseBrowseGui(browseGui))
        closeBtn.SetFont("s9 Bold", "Segoe UI")

        browseGui.Show("w480 h430")
    }

    PopulateCredentialsList(listView, filter := "") {
        listView.Delete()  ; Clear existing items
        
        for role, data in this.credentials {
            ; Apply filter if specified
            if (filter != "" && !InStr(role, filter) && !InStr(data.username, filter))
                continue
                
            status := data.favorite ? "★" : ""
            listView.Add(, status, role, data.username)
        }
        
        ; Auto-size columns
        listView.ModifyCol(1, 50)   ; Status column
        listView.ModifyCol(2, 200)  ; Role column  
        listView.ModifyCol(3, 150)  ; Username column
    }

    RemoveRoleBySelection(gui, roleList, *) {
        if (roleList.Value = 0) {
            MsgBox("Please select a credential to remove.", "⚠️ Selection Required", "Icon!")
            return
        }
        
        ; Get the selected text from the listbox
        selectedText := roleList.Text
        
        ; Extract role name from the formatted text: "⭐ RoleName (👤 username)" or "RoleName (👤 username)"
        ; Remove favorite marker if present
        cleanText := RegExReplace(selectedText, "^⭐ ", "")
        ; Extract role name (everything before " (👤")
        if (RegExMatch(cleanText, "^(.+?) \(👤", &match))
            selectedRole := match[1]
        else
            selectedRole := cleanText
        
        ; Confirm deletion
        result := MsgBox("Are you sure you want to remove '" selectedRole "'?", "🗑️ Confirm Deletion", "YesNo Icon?")
        if (result = "Yes") {
            this.credentials.Delete(selectedRole)
            this.SaveCredentials()
            this.RefreshFavoriteButtons()
            gui.Destroy()
        }
    }

    FilterRoleList(listBox, filter) {
        ; Clear existing items
        listBox.Delete()
        
        ; Build filtered items array
        filteredItems := []
        for role, data in this.credentials {
            ; Apply filter if specified
            if (filter != "" && !InStr(role, filter) && !InStr(data.username, filter))
                continue
                
            favoriteMarker := data.favorite ? "⭐ " : ""
            filteredItems.Push(favoriteMarker . role . " (👤 " data.username ")")
        }
        
        ; Add all filtered items at once
        if (filteredItems.Length > 0)
            listBox.Add(filteredItems)
    }

    FilterCredentialsList(listView, filter) {
        this.PopulateCredentialsList(listView, filter)
    }

    ToggleFavoriteFromList(listView) {
        selectedRow := listView.GetNext()
        if (selectedRow = 0) {
            MsgBox("Please select a credential to toggle favorite status.", "⚠️ Selection Required", "Icon!")
            return
        }
        
        ; Get the role name from the selected row
        roleName := listView.GetText(selectedRow, 2)
        
        if (this.credentials.Has(roleName)) {
            ; Toggle favorite status
            this.credentials[roleName].favorite := !this.credentials[roleName].favorite
            
            ; Save changes
            this.SaveCredentials()
            
            ; Refresh the list
            this.PopulateCredentialsList(listView)
        }
    }

    CloseBrowseGui(gui) {
        gui.Destroy()
        ; Refresh main GUI to show updated favorites (reset to first page)
        this.currentFavoritePage := 0
        this.RefreshFavoriteButtons()
    }

    PreviousFavoritePage() {
        if (this.currentFavoritePage > 0) {
            this.currentFavoritePage--
            this.RefreshFavoriteButtons()
        }
    }

    NextFavoritePage() {
        allFavorites := this.GetFavoriteCredentials()
        totalPages := Ceil(allFavorites.Count / this.favoritesPerPage)
        
        if (this.currentFavoritePage < totalPages - 1) {
            this.currentFavoritePage++
            this.RefreshFavoriteButtons()
        }
    }

    CreateModernDialog(title, width := 350, height := 250) {
        dialog := Gui("+Owner" this.mainGui.Hwnd " +ToolWindow -MaximizeBox", title)
        dialog.BackColor := Colors.White
        dialog.MarginX := 20
        dialog.MarginY := 20
        
        ; Add header
        headerText := dialog.Add("Text", "x0 y0 w" width " h40 Center c" Colors.White " Background" Colors.Primary, title)
        headerText.SetFont("s12 Bold", "Segoe UI")
        
        return dialog
    }

    ShowAddRoleGui(*) {
        addGui := this.CreateModernDialog("➕ Add New Credential", 400, 320)
        
        ; Form fields with labels
        y := 60
        addGui.Add("Text", "x20 y" y " c" Colors.Text, "Role/Service Name:")
        roleName := addGui.Add("Edit", "x20 y" (y+20) " w340 h25")
        roleName.SetFont("s10", "Segoe UI")
        
        y += 60
        addGui.Add("Text", "x20 y" y " c" Colors.Text, "Username:")
        username := addGui.Add("Edit", "x20 y" (y+20) " w340 h25")
        username.SetFont("s10", "Segoe UI")
        
        y += 60
        addGui.Add("Text", "x20 y" y " c" Colors.Text, "Password:")
        password := addGui.Add("Edit", "x20 y" (y+20) " w340 h25 Password")
        password.SetFont("s10", "Segoe UI")
        
        y += 50
        favoriteCheck := addGui.Add("CheckBox", "x20 y" y " w340 h20", "⭐ Add to favorites (show as button on main screen)")
        favoriteCheck.SetFont("s9", "Segoe UI")
        favoriteCheck.Value := 1  ; Default to favorite
        
        ; Buttons
        y += 40
        saveBtn := addGui.Add("Button", "x20 y" y " w100 h35 Default", "💾 Save")
        saveBtn.OnEvent("Click", (ctrl, *) => this.AddRole(addGui, roleName.Value, username.Value, password.Value, favoriteCheck.Value))
        saveBtn.SetFont("s10 Bold", "Segoe UI")
        
        cancelBtn := addGui.Add("Button", "x260 y" y " w100 h35", "❌ Cancel")
        cancelBtn.OnEvent("Click", (ctrl, *) => addGui.Destroy())
        cancelBtn.SetFont("s10 Bold", "Segoe UI")

        addGui.Show("w400 h" (y + 50))
    }

    AddRole(gui, role, username, password, isFavorite, *) {
        if (role = "" || username = "" || password = "") {
            MsgBox("Please fill in all fields.", "⚠️ Validation Error", "Icon!")
            return
        }

        this.credentials[role] := { 
            username: username, 
            password: password,
            favorite: isFavorite
        }
        this.SaveCredentials()
        
        ; Reset to first page if adding a favorite
        if (isFavorite) {
            this.currentFavoritePage := 0
        }
        
        this.RefreshFavoriteButtons()
        gui.Destroy()
    }

    ShowRemoveRoleGui(*) {
        if (this.credentials.Count = 0) {
            MsgBox("No credentials available to remove.", "ℹ️ Information", "Iconi")
            return
        }

        removeGui := this.CreateModernDialog("🗑️ Remove Credential", 450, 320)
        
        y := 60
        ; Add search functionality
        removeGui.Add("Text", "x20 y" y " c" Colors.Text, "🔍 Search:")
        searchBox := removeGui.Add("Edit", "x80 y" (y-3) " w250 h25")
        searchBox.SetFont("s10", "Segoe UI")
        searchBtn := removeGui.Add("Button", "x340 y" (y-3) " w70 h25", "Search")
        searchBtn.SetFont("s9", "Segoe UI")
        
        y += 35
        removeGui.Add("Text", "x20 y" y " c" Colors.Text, "Select credential to remove:")
        roleList := removeGui.Add("ListBox", "x20 y" (y+20) " w390 h120")
        roleList.SetFont("s10", "Segoe UI")

        ; Build initial list and populate
        roleItems := []
        for role, data in this.credentials {
            favoriteMarker := data.favorite ? "⭐ " : ""
            roleItems.Push(favoriteMarker . role . " (👤 " data.username ")")
        }
        roleList.Add(roleItems)

        ; Handle search
        searchBox.OnEvent("Change", (*) => this.FilterRoleList(roleList, searchBox.Value))
        searchBtn.OnEvent("Click", (*) => this.FilterRoleList(roleList, searchBox.Value))

        y += 160
        removeBtn := removeGui.Add("Button", "x20 y" y " w100 h35 Default", "🗑️ Remove")
        removeBtn.OnEvent("Click", (ctrl, *) => this.RemoveRoleBySelection(removeGui, roleList))
        removeBtn.SetFont("s10 Bold", "Segoe UI")
        
        cancelBtn := removeGui.Add("Button", "x310 y" y " w100 h35", "❌ Cancel")
        cancelBtn.OnEvent("Click", (ctrl, *) => removeGui.Destroy())
        cancelBtn.SetFont("s10 Bold", "Segoe UI")

        removeGui.Show("w450 h" (y + 50))
    }

    RemoveRoleByIndex(gui, index, *) {
        if (index = 0) {
            MsgBox("Please select a credential to remove.", "⚠️ Selection Required", "Icon!")
            return
        }

        ; Find the listbox control in the GUI
        roleList := ""
        for ctrl in gui {
            if (ctrl.Type = "ListBox") {
                roleList := ctrl
                break
            }
        }
        
        if (!roleList) {
            MsgBox("Error: Could not find role selection.", "⚠️ Error", "Icon!")
            return
        }
        
        ; Get the selected text from the listbox
        selectedText := roleList.Text
        
        ; Extract role name from the formatted text: "⭐ RoleName (👤 username)" or "RoleName (👤 username)"
        ; Remove favorite marker if present
        cleanText := RegExReplace(selectedText, "^⭐ ", "")
        ; Extract role name (everything before " (👤")
        if (RegExMatch(cleanText, "^(.+?) \(👤", &match))
            selectedRole := match[1]
        else
            selectedRole := cleanText
        
        ; Confirm deletion
        result := MsgBox("Are you sure you want to remove '" selectedRole "'?", "🗑️ Confirm Deletion", "YesNo Icon?")
        if (result = "Yes") {
            this.credentials.Delete(selectedRole)
            this.SaveCredentials()
            this.RefreshFavoriteButtons()
            gui.Destroy()
        }
    }

    ShowModifyRoleGui(*) {
        if (this.credentials.Count = 0) {
            MsgBox("No credentials available to modify.", "ℹ️ Information", "Iconi")
            return
        }

        modifyGui := this.CreateModernDialog("✏️ Modify Credential", 450, 470)
        
        y := 60
        ; Add search functionality
        modifyGui.Add("Text", "x20 y" y " c" Colors.Text, "🔍 Search:")
        searchBox := modifyGui.Add("Edit", "x80 y" (y-3) " w250 h25")
        searchBox.SetFont("s10", "Segoe UI")
        searchBtn := modifyGui.Add("Button", "x340 y" (y-3) " w70 h25", "Search")
        searchBtn.SetFont("s9", "Segoe UI")
        
        y += 35
        modifyGui.Add("Text", "x20 y" y " c" Colors.Text, "Select credential to modify:")
        roleList := modifyGui.Add("ListBox", "x20 y" (y+20) " w390 h100")
        roleList.SetFont("s10", "Segoe UI")

        ; Build initial list and populate
        roleItems := []
        for role, data in this.credentials {
            favoriteMarker := data.favorite ? "⭐ " : ""
            roleItems.Push(favoriteMarker . role . " (👤 " data.username ")")
        }
        roleList.Add(roleItems)

        ; Handle search
        searchBox.OnEvent("Change", (*) => this.FilterRoleList(roleList, searchBox.Value))
        searchBtn.OnEvent("Click", (*) => this.FilterRoleList(roleList, searchBox.Value))

        y += 130
        modifyGui.Add("Text", "x20 y" y " c" Colors.Text, "New Role/Service Name:")
        roleName := modifyGui.Add("Edit", "x20 y" (y+20) " w390 h25")
        roleName.SetFont("s10", "Segoe UI")
        
        y += 50
        modifyGui.Add("Text", "x20 y" y " c" Colors.Text, "New Username:")
        username := modifyGui.Add("Edit", "x20 y" (y+20) " w390 h25")
        username.SetFont("s10", "Segoe UI")
        
        y += 50
        modifyGui.Add("Text", "x20 y" y " c" Colors.Text, "New Password:")
        password := modifyGui.Add("Edit", "x20 y" (y+20) " w390 h25 Password")
        password.SetFont("s10", "Segoe UI")

        y += 50
        favoriteCheck := modifyGui.Add("CheckBox", "x20 y" y " w390 h20", "⭐ Favorite (show as button on main screen)")
        favoriteCheck.SetFont("s9", "Segoe UI")

        y += 30
        saveBtn := modifyGui.Add("Button", "x20 y" y " w100 h35 Default", "💾 Save")
        saveBtn.OnEvent("Click", (ctrl, *) => this.ModifyRoleBySelection(modifyGui, roleList, roleName.Value, username.Value, password.Value, favoriteCheck.Value))
        saveBtn.SetFont("s10 Bold", "Segoe UI")
        
        cancelBtn := modifyGui.Add("Button", "x310 y" y " w100 h35", "❌ Cancel")
        cancelBtn.OnEvent("Click", (ctrl, *) => modifyGui.Destroy())
        cancelBtn.SetFont("s10 Bold", "Segoe UI")

        ; Auto-fill current values when selection changes
        roleList.OnEvent("Change", (*) => this.AutoFillModifyForm(roleList, roleName, username, password, favoriteCheck))

        modifyGui.Show("w450 h" (y + 50))
    }

    AutoFillModifyForm(roleList, roleNameEdit, usernameEdit, passwordEdit, favoriteCheck) {
        if (roleList.Value = 0)
            return
        
        ; Get the selected text from the listbox
        selectedText := roleList.Text
        
        ; Extract role name from the formatted text: "⭐ RoleName (👤 username)" or "RoleName (👤 username)"
        ; Remove favorite marker if present
        cleanText := RegExReplace(selectedText, "^⭐ ", "")
        ; Extract role name (everything before " (👤")
        if (RegExMatch(cleanText, "^(.+?) \(👤", &match))
            selectedRole := match[1]
        else
            selectedRole := cleanText
            
        if (this.credentials.Has(selectedRole)) {
            data := this.credentials[selectedRole]
            roleNameEdit.Value := selectedRole
            usernameEdit.Value := data.username
            passwordEdit.Value := data.password
            favoriteCheck.Value := data.favorite
        }
    }

    ModifyRoleBySelection(gui, roleList, newRoleName, username, password, isFavorite, *) {
        if (roleList.Value = 0) {
            MsgBox("Please select a credential to modify.", "⚠️ Selection Required", "Icon!")
            return
        }

        if (newRoleName = "" || username = "" || password = "") {
            MsgBox("Please fill in all fields.", "⚠️ Validation Error", "Icon!")
            return
        }

        ; Get the selected text from the listbox
        selectedText := roleList.Text
        
        ; Extract original role name from the formatted text
        cleanText := RegExReplace(selectedText, "^⭐ ", "")
        if (RegExMatch(cleanText, "^(.+?) \(👤", &match))
            originalRole := match[1]
        else
            originalRole := cleanText
        
        ; If role name changed, we need to delete old and create new
        if (newRoleName != originalRole) {
            ; Check if new role name already exists
            if (this.credentials.Has(newRoleName)) {
                result := MsgBox("A credential with the name '" newRoleName "' already exists. Do you want to overwrite it?", "⚠️ Duplicate Name", "YesNo Icon!")
                if (result != "Yes")
                    return
            }
            
            ; Delete the original entry
            this.credentials.Delete(originalRole)
        }
        
        ; Create/update the credential with new role name
        this.credentials[newRoleName] := { 
            username: username, 
            password: password,
            favorite: isFavorite
        }
        
        this.SaveCredentials()
        this.RefreshFavoriteButtons()
        gui.Destroy()
    }

    HandleRoleClick(role, *) {
        if !this.credentials.Has(role)
            return
    
        ; Modern notification
        result := MsgBox("Ready to auto-fill credentials for '" role "'`n`nClick OK, then click in the username field of your login form.", "🚀 Auto-Fill Ready", "OKCancel Iconi")
        
        if (result = "Cancel")
            return
    
        ; Wait for user to click in the field
        KeyWait "LButton"
        KeyWait "LButton", "D"
        Sleep 200
    
        ; Store and clear clipboard
        oldClip := A_Clipboard
        A_Clipboard := ""
    
        ; Fill username
        cred := this.credentials[role]
        A_Clipboard := cred.username
        ClipWait(2)
        Send "^v"
        Sleep 150
    
        ; Tab to password field
        Send "{Tab}"
        Sleep 150
    
        ; Fill password
        A_Clipboard := ""
        Sleep 100
        A_Clipboard := cred.password
        ClipWait(2)
        Send "^v"
        Sleep 150
        
        ; Submit form
        Send "{Enter}"
        Sleep 150
    
        ; Restore clipboard
        A_Clipboard := ""
        Sleep 100
        A_Clipboard := oldClip
    }

    ReloadApp() {
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
            ; Validate coordinates are reasonable
            if (x != "" && y != "" && IsNumber(x) && IsNumber(y) && x >= -100 && y >= -100) {
                this.mainGui.Move(x, y)
            }
        } catch {
            ; If restore fails, use default position
            this.mainGui.Move(100, 100)
        }
    }

    HideGui(*) {
        global GuiVisible
        this.mainGui.Hide()
        GuiVisible := false
    }

    ShowGui() {
        global GuiVisible
        ; Reset to first page when showing GUI
        this.currentFavoritePage := 0
        this.RefreshFavoriteButtons()
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
TraySetIcon(A_ScriptDir "\LoginIcon.ico")

; Assign hotkey as Ctrl+Alt+/
Hotkey "^!/", ToggleLoginManager