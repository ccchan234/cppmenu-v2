; AutoHotkey v2 Script
#Requires AutoHotkey v2.0
#SingleInstance Force

; Set the working directory to the script's directory
SetWorkingDir A_ScriptDir

; Add context menu on script startup
AddContextMenu()

; Remove context menu on script exit
OnExit RemoveContextMenu

; Function to add context menu entries
AddContextMenu() {
    try {
        ; Add for files
        RegWrite("CPPCFS Translate", "REG_SZ", "HKEY_CURRENT_USER\Software\Classes\*\shell\CPPCFSTranslate")
        RegWrite("Translate CPPCFS Path", "REG_SZ", "HKEY_CURRENT_USER\Software\Classes\*\shell\CPPCFSTranslate")
        RegWrite('"' A_ScriptFullPath '" "%1"', "REG_SZ", "HKEY_CURRENT_USER\Software\Classes\*\shell\CPPCFSTranslate\command")
        
        ; Add for directories
        RegWrite("CPPCFS Translate", "REG_SZ", "HKEY_CURRENT_USER\Software\Classes\Directory\shell\CPPCFSTranslate")
        RegWrite("Translate CPPCFS Path", "REG_SZ", "HKEY_CURRENT_USER\Software\Classes\Directory\shell\CPPCFSTranslate")
        RegWrite('"' A_ScriptFullPath '" "%1"', "REG_SZ", "HKEY_CURRENT_USER\Software\Classes\Directory\shell\CPPCFSTranslate\command")
    }
    catch as err {
        MsgBox "Failed to add context menu entries. Try running as administrator.`n`nError: " err.Message
        ExitApp
    }
}

; Function to remove context menu entries on exit
RemoveContextMenu(ExitReason, ExitCode) {
    try {
        RegDelete("HKEY_CURRENT_USER\Software\Classes\*\shell\CPPCFSTranslate")
        RegDelete("HKEY_CURRENT_USER\Software\Classes\Directory\shell\CPPCFSTranslate")
    }
}

; Handle command line parameter when launched from context menu
if A_Args.Length > 0 {
    selected := A_Args[1]
    ShowTranslatedPath(selected)
}

; Keep the original hotkey as fallback
^+!c::
{
    selected := GetSelectedItemPath()
    if (selected == "")
    {
        MsgBox "No item selected or not in File Explorer."
        return
    }
    ShowTranslatedPath(selected)
}

; New function to handle path translation and menu display
ShowTranslatedPath(selected) {
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
