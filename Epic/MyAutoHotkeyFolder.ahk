#Requires AutoHotkey v2.0

MyGui := Gui()
MyGui.Add("Text", , "Double-click a file to launch it.")
TV := MyGui.Add("TreeView", "w640 r20")
TV.OnEvent("DoubleClick", LaunchFile)

; Function to recursively add files and folders to the TreeView
AddFilesAndFolders(folder, parentNode := 0) {
    Loop Files, folder "\*.*", "DF"
    {
        if A_LoopFileAttrib ~= "D"  ; If it's a folder
        {
            newNode := TV.Add(A_LoopFileName, parentNode, "Icon2")  ; Use folder icon
            AddFilesAndFolders(A_LoopFilePath, newNode)  ; Recursive call
        }
        else
            TV.Add(A_LoopFileName, parentNode, "Icon1")  ; Use file icon
    }
}

; Call the function with your desired root folder
rootFolder := "C:\Users\psiegel\OneDrive - Epic\Documents\AutoHotkey"
rootNode := TV.Add(rootFolder, , "Icon2")
AddFilesAndFolders(rootFolder, rootNode)

MyGui.Add("Button", "Default", "Launch").OnEvent("Click", LaunchFile)
MyGui.Show()

LaunchFile(*) {
    if (selectedItem := TV.GetSelection()) {
        filePath := GetFullPath(selectedItem)
        if FileExist(filePath) {
            if MsgBox("Would you like to launch the file or document below?`n`n" filePath, , 4) = "No"
                return
            try Run(filePath)
            if A_LastError
                MsgBox("Could not launch the specified file. Perhaps it is not associated with anything.")
        }
    }
}

GetFullPath(itemId) {
    path := TV.GetText(itemId)
    parent := TV.GetParent(itemId)
    while parent {
        path := TV.GetText(parent) "\" path
        parent := TV.GetParent(parent)
    }
    return path
}