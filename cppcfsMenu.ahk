; AutoHotkey v2 Script, 241018T005501 final version, fm v002

; Set the working directory to the script's directory
SetWorkingDir A_ScriptDir

; Hotkey to trigger the script (Ctrl+Shift+Alt+C)
^+!c::
{
    ; Get the selected item's path in File Explorer
    selected := GetSelectedItemPath()
    if (selected == "")
    {
        MsgBox "No item selected or not in File Explorer."
        return
    }

    ; Properly quote the selected path for the command line
    quotedSelected := '"' selected '"'

    ; Run cppcryptfsctl.exe to get the translated path
    RunWait A_ComSpec ' /c cppcryptfsctl.exe -M ' quotedSelected ' > "' A_Temp '\cppcfs_output.txt" 2>&1', , "Hide"

    ; Read the output file
    try
    {
        translatedPath := FileRead(A_Temp "\cppcfs_output.txt")
    }
    catch
    {
        MsgBox "Failed to read the output file."
        return
    }

    ; Remove the temporary file
    FileDelete A_Temp "\cppcfs_output.txt"

    ; Store the translated path in a global variable
    global translatedPath := Trim(translatedPath)

    ; Check if translatedPath is empty or contains an error
    if (translatedPath == "" || InStr(translatedPath, "Error"))
    {
        MsgBox "Failed to translate the selected path."
        return
    }

    ; Create a new menu
    TranslatedPathMenu := Menu()
    TranslatedPathMenu.Add(translatedPath, DismissMenu)  ; New item to display the translated path
    TranslatedPathMenu.Add("Copy Translated Path", CopyTranslatedPath)
    TranslatedPathMenu.Add("Open in File Explorer", OpenInFileExplorer)
    TranslatedPathMenu.Show()
}
return

; Function to get the selected item's path in File Explorer
GetSelectedItemPath()
{
    shellApp := ComObject("Shell.Application")
    for window in shellApp.Windows
    {
        if (window.hwnd == WinActive("A"))
        {
            sel := window.Document.SelectedItems()
            if (sel.Count == 0)
                return ""
            for item in sel
                return item.Path
        }
    }
    return ""
}

; Function to copy the translated path to clipboard
CopyTranslatedPath(ItemName, ItemPos, MenuObj)
{
    global translatedPath
    A_Clipboard := translatedPath
    ;MsgBox "Translated path copied to clipboard:`n" translatedPath
}

; Function to open the translated path in File Explorer
OpenInFileExplorer(ItemName, ItemPos, MenuObj)
{
    global translatedPath

    ; Clean up the translatedPath
    translatedPath := Trim(translatedPath)
    translatedPath := StrReplace(translatedPath, '"', '')
    translatedPath := StrReplace(translatedPath, "`r`n", "")

    ;MsgBox "Translated Path: " translatedPath

    ; Check if the path exists and get its attributes
    attr := FileExist(translatedPath)
    if attr
    {
        ;MsgBox "File Attributes: " attr

        if InStr(attr, "D")  ; Check if it's a directory
        {
            ;MsgBox "Opening directory:`n" translatedPath
            Run 'explorer.exe "' . translatedPath . '"'
        }
        else
        {
            ;MsgBox "Opening file:`n" translatedPath
            Run 'explorer.exe /select,"' . translatedPath . '"'
        }
    }
    else
    {
        MsgBox "The translated path does not exist or is not accessible:`n" translatedPath
    }
}

; New function to dismiss the menu without action
DismissMenu(ItemName, ItemPos, MenuObj)
{
    return  ; Do nothing, which will dismiss the menu
}
