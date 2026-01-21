; ===========================
; SETTINGS GUI & MANAGEMENT FUNCTIONS
; ===========================
; This file contains all settings-related functions
; #Include this file in the main script

ShowSettings() {
    global hotkeyCategories, hotstringCategories, wikiCategories, customTabs, MyGui
    
    if (!IsSet(MyGui) || !MyGui.Hwnd) {
        MsgBox("Main GUI not available. Please open the main window first.", "Error", 48)
        return
    }
    
    settingsGui := Gui("+Resize +Owner" . MyGui.Hwnd, "⚙️ Settings - Configure Shortcuts")
    settingsGui.SetFont("s9", "Segoe UI")
    settingsGui.BackColor := "0xF0F0F0"
    
    settingsTab := settingsGui.Add("Tab3", "x10 y10 w680 h500", ["Hotkeys", "Hotstrings", "Wiki Shortcuts", "🎨 Customize Tabs", "🎯 Custom Tab Content", "⌨️ GUI Hotkeys"])
    
    ; === HOTKEYS TAB ===
    settingsTab.UseTab(1)
    settingsGui.Add("Text", "x20 y40 w200", "Categories:")
    categoryListHK := settingsGui.Add("ListBox", "x20 y60 w200 h350", [])
    
    settingsGui.Add("Text", "x240 y40 w440", "Items in Selected Category:")
    itemListHK := settingsGui.Add("ListView", "x240 y60 w440 h350 +Grid", ["Hotkey", "Description"])
    itemListHK.ModifyCol(1, 180)
    itemListHK.ModifyCol(2, 240)
    
    addCatBtnHK := settingsGui.Add("Button", "x20 y420 w95 h30", "➕ Add Category")
    addCatBtnHK.OnEvent("Click", (*) => AddCategory("Hotkeys", categoryListHK))
    
    renameCatBtnHK := settingsGui.Add("Button", "x120 y420 w95 h30", "✏️ Rename")
    renameCatBtnHK.OnEvent("Click", (*) => RenameCategory("Hotkeys", categoryListHK))
    
    delCatBtnHK := settingsGui.Add("Button", "x20 y455 w95 h30", "🗑️ Delete")
    delCatBtnHK.OnEvent("Click", (*) => DeleteCategory("Hotkeys", categoryListHK, itemListHK))
    
    addItemBtnHK := settingsGui.Add("Button", "x240 y420 w140 h30", "➕ Add Hotkey")
    addItemBtnHK.OnEvent("Click", (*) => AddItem("Hotkeys", categoryListHK, itemListHK))
    
    editItemBtnHK := settingsGui.Add("Button", "x390 y420 w140 h30", "✏️ Edit Hotkey")
    editItemBtnHK.OnEvent("Click", (*) => EditItem("Hotkeys", categoryListHK, itemListHK))
    
    delItemBtnHK := settingsGui.Add("Button", "x540 y420 w140 h30", "🗑️ Delete Hotkey")
    delItemBtnHK.OnEvent("Click", (*) => DeleteItem("Hotkeys", categoryListHK, itemListHK))
    
    ; === HOTSTRINGS TAB ===
    settingsTab.UseTab(2)
    settingsGui.Add("Text", "x20 y40 w200", "Categories:")
    categoryListHS := settingsGui.Add("ListBox", "x20 y60 w200 h350", [])
    
    settingsGui.Add("Text", "x240 y40 w440", "Items in Selected Category:")
    itemListHS := settingsGui.Add("ListView", "x240 y60 w440 h350 +Grid", ["Hotstring", "Description"])
    itemListHS.ModifyCol(1, 180)
    itemListHS.ModifyCol(2, 240)
    
    addCatBtnHS := settingsGui.Add("Button", "x20 y420 w95 h30", "➕ Add Category")
    addCatBtnHS.OnEvent("Click", (*) => AddCategory("Hotstrings", categoryListHS))
    
    renameCatBtnHS := settingsGui.Add("Button", "x120 y420 w95 h30", "✏️ Rename")
    renameCatBtnHS.OnEvent("Click", (*) => RenameCategory("Hotstrings", categoryListHS))
    
    delCatBtnHS := settingsGui.Add("Button", "x20 y455 w95 h30", "🗑️ Delete")
    delCatBtnHS.OnEvent("Click", (*) => DeleteCategory("Hotstrings", categoryListHS, itemListHS))
    
    addItemBtnHS := settingsGui.Add("Button", "x240 y420 w140 h30", "➕ Add Hotstring")
    addItemBtnHS.OnEvent("Click", (*) => AddItem("Hotstrings", categoryListHS, itemListHS))
    
    editItemBtnHS := settingsGui.Add("Button", "x390 y420 w140 h30", "✏️ Edit Hotstring")
    editItemBtnHS.OnEvent("Click", (*) => EditItem("Hotstrings", categoryListHS, itemListHS))
    
    delItemBtnHS := settingsGui.Add("Button", "x540 y420 w140 h30", "🗑️ Delete Hotstring")
    delItemBtnHS.OnEvent("Click", (*) => DeleteItem("Hotstrings", categoryListHS, itemListHS))
    
    ; === WIKI TAB ===
    settingsTab.UseTab(3)
    settingsGui.Add("Text", "x20 y40 w200", "Categories:")
    categoryListWS := settingsGui.Add("ListBox", "x20 y60 w200 h350", [])
    
    settingsGui.Add("Text", "x240 y40 w440", "Items in Selected Category:")
    itemListWS := settingsGui.Add("ListView", "x240 y60 w440 h350 +Grid", ["Shortcut", "Description"])
    itemListWS.ModifyCol(1, 180)
    itemListWS.ModifyCol(2, 240)
    
    addCatBtnWS := settingsGui.Add("Button", "x20 y420 w95 h30", "➕ Add Category")
    addCatBtnWS.OnEvent("Click", (*) => AddCategory("Wiki", categoryListWS))
    
    renameCatBtnWS := settingsGui.Add("Button", "x120 y420 w95 h30", "✏️ Rename")
    renameCatBtnWS.OnEvent("Click", (*) => RenameCategory("Wiki", categoryListWS))
    
    delCatBtnWS := settingsGui.Add("Button", "x20 y455 w95 h30", "🗑️ Delete")
    delCatBtnWS.OnEvent("Click", (*) => DeleteCategory("Wiki", categoryListWS, itemListWS))
    
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
    
    global tabMetadata
    tabListView.Add("", "Built-in", tabMetadata.hotkeys.name, tabMetadata.hotkeys.icon, tabMetadata.hotkeys.visible ? "✓" : "✗", tabMetadata.hotkeys.order)
    tabListView.Add("", "Built-in", tabMetadata.hotstrings.name, tabMetadata.hotstrings.icon, tabMetadata.hotstrings.visible ? "✓" : "✗", tabMetadata.hotstrings.order)
    tabListView.Add("", "Built-in", tabMetadata.wiki.name, tabMetadata.wiki.icon, tabMetadata.wiki.visible ? "✓" : "✗", tabMetadata.wiki.order)
    tabListView.Add("", "Built-in", tabMetadata.favorites.name, tabMetadata.favorites.icon, tabMetadata.favorites.visible ? "✓" : "✗", tabMetadata.favorites.order)
    
    for tab in customTabs {
        tabListView.Add("", "Custom", tab.name, tab.icon, "✓", tab.order ? tab.order : (50 + A_Index))
    }
    
    settingsGui.Add("Text", "x20 y465 w660 cGray", "Note: Built-in tabs can be renamed/hidden/reordered. Custom tabs can be fully deleted. Save to apply changes.")
    
    ; === CUSTOM TAB CONTENT ===
    settingsTab.UseTab(5)
    settingsGui.Add("Text", "x20 y40 w200", "Select Custom Tab:")
    customTabDropdown := settingsGui.Add("DropDownList", "x20 y60 w200", [])
    
    for tab in customTabs {
        customTabDropdown.Add([tab.name])
    }
    
    settingsGui.Add("Text", "x20 y100 w200", "Categories:")
    categoryListCustom := settingsGui.Add("ListBox", "x20 y120 w200 h260", [])
    
    settingsGui.Add("Text", "x240 y100 w440", "Items in Selected Category:")
    itemListCustom := settingsGui.Add("ListView", "x240 y120 w440 h260 +Grid", ["Item", "Description"])
    itemListCustom.ModifyCol(1, 180)
    itemListCustom.ModifyCol(2, 240)
    
    addCatBtnCustom := settingsGui.Add("Button", "x20 y390 w95 h30", "➕ Add Category")
    addCatBtnCustom.OnEvent("Click", (*) => AddCustomCategory(customTabDropdown, categoryListCustom))
    
    renameCatBtnCustom := settingsGui.Add("Button", "x120 y390 w95 h30", "✏️ Rename")
    renameCatBtnCustom.OnEvent("Click", (*) => RenameCustomCategory(customTabDropdown, categoryListCustom))
    
    delCatBtnCustom := settingsGui.Add("Button", "x20 y425 w95 h30", "🗑️ Delete")
    delCatBtnCustom.OnEvent("Click", (*) => DeleteCustomCategory(customTabDropdown, categoryListCustom, itemListCustom))
    
    addItemBtnCustom := settingsGui.Add("Button", "x240 y390 w140 h30", "➕ Add Item")
    addItemBtnCustom.OnEvent("Click", (*) => AddCustomItem(customTabDropdown, categoryListCustom, itemListCustom))
    
    editItemBtnCustom := settingsGui.Add("Button", "x390 y390 w140 h30", "✏️ Edit Item")
    editItemBtnCustom.OnEvent("Click", (*) => EditCustomItem(customTabDropdown, categoryListCustom, itemListCustom))
    
    delItemBtnCustom := settingsGui.Add("Button", "x540 y390 w140 h30", "🗑️ Delete Item")
    delItemBtnCustom.OnEvent("Click", (*) => DeleteCustomItem(customTabDropdown, categoryListCustom, itemListCustom))
    
    settingsGui.Add("Text", "x20 y465 w660 cGray", "Note: First create a custom tab in the 'Customize Tabs' section, then add content to it here.")
    
    ; === GUI HOTKEYS TAB ===
    settingsTab.UseTab(6)
    settingsGui.Add("Text", "x20 y40 w640", "Customize GUI Hotkeys:")
    settingsGui.Add("Text", "x20 y70 w640 cGray", "Use AutoHotkey hotkey notation (e.g., ^!Space = Ctrl+Alt+Space, ^f = Ctrl+F)")
    
    settingsGui.Add("Text", "x20 y100 w200", "Open GUI Hotkey:")
    openGuiEdit := settingsGui.Add("Edit", "x20 y120 w300 h25", guiHotkeys.openGui)
    settingsGui.Add("Text", "x330 y120 w300 h25 +0x200", "Default: ^!Space (Ctrl+Alt+Space)")
    
    settingsGui.Add("Text", "x20 y160 w200", "Close GUI Hotkey:")
    closeGuiEdit := settingsGui.Add("Edit", "x20 y180 w300 h25", guiHotkeys.closeGui)
    settingsGui.Add("Text", "x330 y180 w300 h25 +0x200", "Default: ^!Escape (Ctrl+Alt+Esc)")
    
    settingsGui.Add("Text", "x20 y220 w200", "Focus Search Hotkey:")
    focusSearchEdit := settingsGui.Add("Edit", "x20 y240 w300 h25", guiHotkeys.focusSearch)
    settingsGui.Add("Text", "x330 y240 w300 h25 +0x200", "Default: ^f (Ctrl+F)")
    
    settingsGui.Add("Text", "x20 y280 w640", "Hotkey Notation Reference:")
    settingsGui.Add("Text", "x20 y305 w640 cGray", "^  = Ctrl  |  !  = Alt  |  +  = Shift  |  #  = Win`nExample: ^+a = Ctrl+Shift+A  |  !#Space = Alt+Win+Space")
    
    testBtn := settingsGui.Add("Button", "x20 y345 w150 h30", "🧪 Test Hotkeys")
    testBtn.OnEvent("Click", (*) => TestGuiHotkeys(openGuiEdit, closeGuiEdit, focusSearchEdit))
    
    resetHotkeysBtn := settingsGui.Add("Button", "x180 y345 w150 h30", "🔄 Reset to Defaults")
    resetHotkeysBtn.OnEvent("Click", (*) => ResetGuiHotkeys(openGuiEdit, closeGuiEdit, focusSearchEdit))
    
    settingsGui.Add("Text", "x20 y390 w640", "Note: Changes take effect after saving and reloading the GUI.")
    settingsGui.Add("Text", "x20 y415 w640 cRed", "⚠️ Warning: Invalid hotkeys may prevent the GUI from opening. Test before saving!")
    
    ; Tab 4 buttons (after customTabDropdown exists)
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
    
    customTabDropdown.OnEvent("Change", (*) => LoadCustomTabContent(customTabDropdown, categoryListCustom))
    
    settingsTab.UseTab()
    
    ; Bottom buttons
    saveBtn := settingsGui.Add("Button", "x10 y520 w120 h35", "💾 Save & Close")
    saveBtn.OnEvent("Click", (*) => SaveSettings(settingsGui, openGuiEdit, closeGuiEdit, focusSearchEdit))
    
    cancelBtn := settingsGui.Add("Button", "x140 y520 w120 h35", "❌ Cancel")
    cancelBtn.OnEvent("Click", (*) => settingsGui.Destroy())
    
    restoreAllBtn := settingsGui.Add("Button", "x270 y520 w150 h35", "🔄 Restore ALL")
    restoreAllBtn.OnEvent("Click", (*) => RestoreAllDefaults())
    restoreAllBtn.ToolTip := "Restore ALL settings to original defaults"
    
    exportConfigBtn := settingsGui.Add("Button", "x430 y520 w130 h35", "📤 Export")
    exportConfigBtn.OnEvent("Click", (*) => ExportConfig())
    
    importConfigBtn := settingsGui.Add("Button", "x570 y520 w120 h35", "📥 Import")
    importConfigBtn.OnEvent("Click", (*) => ImportConfig())
    
    categoryListHK.OnEvent("Change", (*) => LoadCategoryItems("Hotkeys", categoryListHK, itemListHK))
    categoryListHS.OnEvent("Change", (*) => LoadCategoryItems("Hotstrings", categoryListHS, itemListHS))
    categoryListWS.OnEvent("Change", (*) => LoadCategoryItems("Wiki", categoryListWS, itemListWS))
    categoryListCustom.OnEvent("Change", (*) => LoadCustomCategoryItems(customTabDropdown, categoryListCustom, itemListCustom))
    
    LoadSettingsCategories(categoryListHK, categoryListHS, categoryListWS)
    
    if (customTabs.Length > 0) {
        customTabDropdown.Choose(1)
        LoadCustomTabContent(customTabDropdown, categoryListCustom)
    }
    
    settingsGui.Show("w700 h565")
}

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
    
    inputGui := Gui("+Owner" . MyGui.Hwnd, "Add Item")
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
    
    inputGui := Gui("+Owner" . MyGui.Hwnd, "Edit Item")
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
    
    catListHK.Delete()
    for cat in hotkeyCategories
        catListHK.Add([cat.name])
    
    catListHS.Delete()
    for cat in hotstringCategories
        catListHS.Add([cat.name])
    
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
    
    inputGui := Gui("+Owner" . MyGui.Hwnd, "Add " . keyLabel)
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
    
    inputGui := Gui("+Owner" . MyGui.Hwnd, "Edit " . keyLabel)
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

SaveSettings(settingsGui, openGuiEdit, closeGuiEdit, focusSearchEdit) {
    ; Update global GUI hotkeys from edit controls
    global guiHotkeys
    guiHotkeys.openGui := openGuiEdit.Value
    guiHotkeys.closeGui := closeGuiEdit.Value
    guiHotkeys.focusSearch := focusSearchEdit.Value
    
    ; Show progress indicator
    progressGui := Gui("+AlwaysOnTop -Caption +ToolWindow +Owner" . settingsGui.Hwnd, "Saving")
    progressGui.BackColor := "0x2196F3"
    progressGui.SetFont("s10 Bold", "Segoe UI")
    progressGui.Add("Text", "cWhite x20 y15 w200 Center", "💾 Saving configuration...")
    progressGui.Show("w240 h50 NoActivate")
    
    SetTimer(() => DoSave(settingsGui, progressGui), -50)
}

DoSave(settingsGui, progressGui) {
    if SaveConfiguration() {
        progressGui.Destroy()
        
        result := MsgBox("Settings saved successfully!`n`nThe script will now reload to apply hotkey changes.", "Settings Saved", 64)
        
        settingsGui.Destroy()
        if IsSet(MyGui) && MyGui.Hwnd
            MyGui.Destroy()
        
        ; Reload the script to apply hotkey changes
        Reload()
    } else {
        progressGui.Destroy()
    }
}

AddCustomTab(tabListView, customTabDropdown := "") {
    global customTabs, MyGui
    
    inputGui := Gui("+Owner" . MyGui.Hwnd, "Add Custom Tab")
    inputGui.SetFont("s9", "Segoe UI")
    
    inputGui.Add("Text", "x10 y10 w300", "Tab Name:")
    nameEdit := inputGui.Add("Edit", "x10 y30 w300 h25")
    
    inputGui.Add("Text", "x10 y65 w300", "Icon (single character or [XX] format):")
    iconEdit := inputGui.Add("Edit", "x10 y85 w300 h25", "[+]")
    
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
            tabIcon := "[+]"
        
        if (tabOrder = "" || !IsNumber(tabOrder))
            tabOrder := 50
        
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
        
        if (customTabDropdown != "" && IsObject(customTabDropdown)) {
            customTabDropdown.Delete()
            for tab in customTabs {
                customTabDropdown.Add([tab.name])
            }
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
    
    isBuiltin := (tabType = "Built-in")
    builtinKey := ""
    customIndex := 0
    
    if (isBuiltin) {
        if (tabMetadata.hotkeys.name = tabName)
            builtinKey := "hotkeys"
        else if (tabMetadata.hotstrings.name = tabName)
            builtinKey := "hotstrings"
        else if (tabMetadata.wiki.name = tabName)
            builtinKey := "wiki"
        else if (tabMetadata.favorites.name = tabName)
            builtinKey := "favorites"
    } else {
        for index, tab in customTabs {
            if (tab.name = tabName) {
                customIndex := index
                break
            }
        }
    }
    
    inputGui := Gui("+Owner" . MyGui.Hwnd, "Edit Tab")
    inputGui.SetFont("s9", "Segoe UI")
    
    inputGui.Add("Text", "x10 y10 w300", "Tab Name:")
    nameEdit := inputGui.Add("Edit", "x10 y30 w300 h25", tabName)
    
    inputGui.Add("Text", "x10 y65 w300", "Icon (single character or [XX] format):")
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
            newIcon := "[+]"
        
        if (newOrder = "" || !IsNumber(newOrder))
            newOrder := tabOrder
        
        if (newName != tabName) {
            if (isBuiltin) {
                for key, meta in tabMetadata.OwnProps() {
                    if (key != builtinKey && meta.name = newName) {
                        MsgBox("A tab with this name already exists!", "Duplicate Name", 48)
                        return
                    }
                }
            }
            for index, tab in customTabs {
                if ((!isBuiltin && index != customIndex) || isBuiltin) {
                    if (tab.name = newName) {
                        MsgBox("A tab with this name already exists!", "Duplicate Name", 48)
                        return
                    }
                }
            }
        }
        
        if (isBuiltin) {
            tabMetadata.%builtinKey%.name := newName
            tabMetadata.%builtinKey%.icon := newIcon
            tabMetadata.%builtinKey%.order := Integer(newOrder)
        } else if (customIndex > 0) {
            customTabs[customIndex].name := newName
            customTabs[customIndex].icon := newIcon
            customTabs[customIndex].order := Integer(newOrder)
            
            if (customTabDropdown != "" && IsObject(customTabDropdown)) {
                currentSelection := customTabDropdown.Value
                customTabDropdown.Delete()
                for tab in customTabs {
                    customTabDropdown.Add([tab.name])
                }
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
    
    if (customTabDropdown != "" && IsObject(customTabDropdown)) {
        customTabDropdown.Delete()
        for tab in customTabs {
            customTabDropdown.Add([tab.name])
        }
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
    
    tabMetadata.hotkeys := {name: "Hotkeys", icon: "[HK]", visible: true, order: 1}
    tabMetadata.hotstrings := {name: "Hotstrings", icon: "[HS]", visible: true, order: 2}
    tabMetadata.wiki := {name: "Wiki Shortcuts", icon: "[W]", visible: true, order: 3}
    tabMetadata.favorites := {name: "Favorites", icon: "[*]", visible: true, order: 999}
    
    tabListView.Delete()
    
    tabListView.Add("", "Built-in", tabMetadata.hotkeys.name, tabMetadata.hotkeys.icon, "✓", tabMetadata.hotkeys.order)
    tabListView.Add("", "Built-in", tabMetadata.hotstrings.name, tabMetadata.hotstrings.icon, "✓", tabMetadata.hotstrings.order)
    tabListView.Add("", "Built-in", tabMetadata.wiki.name, tabMetadata.wiki.icon, "✓", tabMetadata.wiki.order)
    tabListView.Add("", "Built-in", tabMetadata.favorites.name, tabMetadata.favorites.icon, "✓", tabMetadata.favorites.order)
    
    global customTabs
    for tab in customTabs {
        tabListView.Add("", "Custom", tab.name, tab.icon, "✓", tab.order ? tab.order : (50 + A_Index))
    }
    
    MsgBox("Default tab settings restored! Save and reload to see changes.", "Success", 64)
}

TestGuiHotkeys(openGuiEdit, closeGuiEdit, focusSearchEdit) {
    ; Validate the hotkeys
    openGuiKey := openGuiEdit.Value
    closeGuiKey := closeGuiEdit.Value
    focusSearchKey := focusSearchEdit.Value
    
    errors := []
    
    ; Test Open GUI hotkey
    if (openGuiKey = "") {
        errors.Push("Open GUI hotkey cannot be empty")
    } else {
        try {
            Hotkey(openGuiKey, (*) => "", "On")
            Hotkey(openGuiKey, (*) => "", "Off")
        } catch as err {
            errors.Push("Invalid Open GUI hotkey: " . openGuiKey)
        }
    }
    
    ; Test Close GUI hotkey
    if (closeGuiKey != "") {
        try {
            Hotkey(closeGuiKey, (*) => "", "On")
            Hotkey(closeGuiKey, (*) => "", "Off")
        } catch as err {
            errors.Push("Invalid Close GUI hotkey: " . closeGuiKey)
        }
    }
    
    ; Test Focus Search hotkey
    if (focusSearchKey != "") {
        try {
            Hotkey(focusSearchKey, (*) => "", "On")
            Hotkey(focusSearchKey, (*) => "", "Off")
        } catch as err {
            errors.Push("Invalid Focus Search hotkey: " . focusSearchKey)
        }
    }
    
    if (errors.Length > 0) {
        errorMsg := "Hotkey Validation Errors:`n`n"
        for error in errors {
            errorMsg .= "• " . error . "`n"
        }
        errorMsg .= "`nPlease correct these before saving."
        MsgBox(errorMsg, "Invalid Hotkeys", 48)
    } else {
        MsgBox("✓ All hotkeys are valid!`n`nYou can safely save these settings.", "Validation Successful", 64)
    }
}

ResetGuiHotkeys(openGuiEdit, closeGuiEdit, focusSearchEdit) {
    result := MsgBox("Reset all GUI hotkeys to defaults?", "Confirm Reset", 4 + 32)
    if (result = "Yes") {
        openGuiEdit.Value := "^!Space"
        closeGuiEdit.Value := "^!Escape"
        focusSearchEdit.Value := "^f"
        MsgBox("GUI hotkeys reset to defaults!`n`nRemember to save to apply changes.", "Reset Complete", 64)
    }
}