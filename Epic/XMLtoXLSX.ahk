#Requires AutoHotkey v2.0
#SingleInstance Force

ShowProcessWindow(title := "Processing", message := "Please wait...") {
    global ProcessGui := Gui("+AlwaysOnTop -SysMenu", title)
    ProcessGui.Add("Text", "w300 Center", message)
    ProcessGui.Add("Progress", "w300 h20 vProgressBar")
    ProcessGui.Add("Text", "w300 vStatusText Center", "Initializing...")
    ProcessGui.Show()
    return ProcessGui
}

UpdateProcess(status, progressValue := 0) {
    global ProcessGui
    if ProcessGui.HasProp("StatusText") {
        ProcessGui["StatusText"].Value := status
        ProcessGui["ProgressBar"].Value := progressValue
    }
}

CloseProcessWindow() {
    global ProcessGui
    ProcessGui.Destroy()
}

; Hotkey: Ctrl+Alt+Shift+M
^!+m:: {
    ; Ask user if they want to convert a single file or multiple files
    result := MsgBox("Would you like to convert multiple files from a folder?`n`nYes = Select a folder`nNo = Select single file`nSelect 'Cancel' to exit", "XML to XLSX Converter", "YesNoCancel Icon?")
    
    if (result = "Cancel") {
        return
    } else if (result = "Yes") {  ; User chose Multiple
        ; Select folder containing XML files
        folderPath := DirSelect("", 0, "Select folder containing XML files")
        if (!folderPath)
            return
        
        ; Show process window and start scanning
        ShowProcessWindow("Scanning Files", "Scanning folder for XML files...")
        UpdateProcess("Counting XML files...", 20)
        
        ; Get all XML files in the folder
        xmlFiles := []
        fileCount := 0
        
        ; First count total files for progress
        Loop Files, folderPath "\*.xml"
            fileCount++
            
        UpdateProcess("Found " fileCount " XML files. Loading...", 40)
        
        ; Now collect the files
        currentFile := 0
        Loop Files, folderPath "\*.xml" {
            xmlFiles.Push(A_LoopFilePath)
            currentFile++
            progress := 40 + Round((currentFile / fileCount) * 40)  ; Progress from 40 to 80
            UpdateProcess("Loading file " currentFile " of " fileCount, progress)
        }
        
        UpdateProcess("Preparing file list...", 90)
        
        if (xmlFiles.Length = 0) {
            CloseProcessWindow()
            MsgBox("No XML files found in the selected folder.", "Error", "Icon!")
            return
        }
        
        UpdateProcess("Creating window...", 95)
        
        ; Create GUI for file selection
        MyGui := Gui("+Resize", "Select XML Files to Convert")
        
        ; Add ListView that fills the window and automatically resizes
        LV := MyGui.Add("ListView", "vMyListView w800 h400 Checked", ["File Path"])
        
        ; Set column width to fill available space
        LV.ModifyCol(1, "AutoHdr")
        
        ; Add files to ListView
        for filePath in xmlFiles
            LV.Add(, filePath)
        
        ; Add button panel at the bottom
        MyGui.Add("GroupBox", "x10 y+10 w780 h50 vButtonPanel", "Actions")
        
        ; Add Select All button
        MyGui.Add("Button", "xp+10 yp+20 w100 vSelectAllBtn", "Select All")
            .OnEvent("Click", (*) => ToggleAll(true))
        
        ; Add Unselect All button
        MyGui.Add("Button", "x+10 yp w100 vUnselectAllBtn", "Unselect All")
            .OnEvent("Click", (*) => ToggleAll(false))
        
        ; Add Cancel button (before Convert button)
        MyGui.Add("Button", "x+10 yp w100 vCancelBtn", "Cancel")
            .OnEvent("Click", (*) => MyGui.Destroy())
        
        ; Add Convert button (right-aligned)
        MyGui.Add("Button", "x640 yp w100 Default vConvertBtn", "Convert")
            .OnEvent("Click", ConvertSelected)
        
        ; Function to toggle all items
        ToggleAll(check) {
            Loop LV.GetCount()
                LV.Modify(A_Index, check ? "Check" : "-Check")
        }
        
        ; Handle window resize
        MyGui.OnEvent("Size", GuiResize)
        
        GuiResize(thisGui, MinMax, Width, Height) {
            if MinMax = -1  ; The window has been minimized
                return
            
            ; Resize ListView to fill the window minus space for buttons
            LV.Move(,, Width - 20, Height - 80)
            
            ; Move button panel
            buttonPanelY := Height - 60
            thisGui["ButtonPanel"].Move(10, buttonPanelY, Width - 20, 50)
            
            ; Adjust button positions
            thisGui["SelectAllBtn"].Move(20, buttonPanelY + 20)
            thisGui["UnselectAllBtn"].Move(130, buttonPanelY + 20)
            thisGui["CancelBtn"].Move(240, buttonPanelY + 20)
            thisGui["ConvertBtn"].Move(Width - 120, buttonPanelY + 20)
            
            ; Ensure column fills the available width
            LV.ModifyCol(1, Width - 40)
        }
        
        UpdateProcess("Complete!", 100)
        Sleep(500)  ; Short pause to show completion
        CloseProcessWindow()
        
        MyGui.Show()
        
        ConvertSelected(*) {
            selectedFiles := []
            row := 0
            while (row := LV.GetNext(row, "C"))
                selectedFiles.Push(LV.GetText(row, 1))
            
            if (selectedFiles.Length = 0) {
                MsgBox("No files selected!", "Error", "Icon!")
                return
            }
            
            ; Create progress GUI
            ProgressGui := Gui("+AlwaysOnTop", "Converting Files")
            ProgressGui.Add("Text",, "Converting files... Please wait")
            ProgressBar := ProgressGui.Add("Progress", "w300 h20 vMyProgress")
            StatusText := ProgressGui.Add("Text", "vStatus w300", "Initializing...")
            ProgressGui.Show()
            
            ; Convert selected files with progress updates
            total := selectedFiles.Length
            current := 0
            
            for filePath in selectedFiles {
                current++
                progress := Round((current / total) * 100)
                
                ; Update progress bar and status
                ProgressBar.Value := progress
                StatusText.Value := "Converting " current " of " total ": " filePath
                
                ConvertXMLToXLSX(filePath)
            }
            
            ProgressGui.Destroy()
            MsgBox("Conversion complete!", "Success", "Icon!")
            MyGui.Destroy()
        }
    } else {  ; User chose Single
        ; Select single XML file
        filePath := FileSelect(1, "", "Select XML file", "XML files (*.xml)")
        if (!filePath)
            return
            
        ; Create simple progress GUI for single file
        ProgressGui := Gui("+AlwaysOnTop", "Converting File")
        ProgressGui.Add("Text",, "Converting file... Please wait")
        StatusText := ProgressGui.Add("Text", "w300", filePath)
        ProgressGui.Show()
        
        ConvertXMLToXLSX(filePath)
        
        ProgressGui.Destroy()
        MsgBox("Conversion complete!", "Success", "Icon!")
    }
}

ConvertXMLToXLSX(filePath) {
    try {
        ; Create Excel application
        excel := ComObject("Excel.Application")
        excel.Visible := false
        
        ; Open XML file
        workbook := excel.Workbooks.OpenXML(filePath)
        
        ; Get new file path
        newPath := RegExReplace(filePath, "\.xml$", ".xlsx")
        
        ; Save as XLSX
        workbook.SaveAs(newPath, 51)  ; 51 = xlOpenXMLWorkbook (*.xlsx)
        
        ; Close workbook and Excel
        workbook.Close()
        excel.Quit()
    } catch Error as e {
        MsgBox("Error converting " filePath "`n`nError: " e.Message, "Error", "Icon!")
    }
}