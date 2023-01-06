; Set Scroll Lock key permanently
SetScrollLockState, AlwaysOff
return
; --------------------------------------------------------------END-----------------------------------------------------------------

; View or Hide Hidden Files
^F2::GoSub,CheckActiveWindow
CheckActiveWindow:
ID := WinExist("A")
WinGetClass,Class, ahk_id %ID%
WClasses := "CabinetWClass ExploreWClass"
IfInString, WClasses, %Class%
GoSub, Toggle_HiddenFiles_Display
Return
Toggle_HiddenFiles_Display:
RootKey = HKEY_CURRENT_USER
SubKey = Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
RegRead, HiddenFiles_Status, % RootKey, % SubKey, Hidden
if HiddenFiles_Status = 2
RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 1 
else 
RegWrite, REG_DWORD, % RootKey, % SubKey, Hidden, 2
PostMessage, 0x111, 41504,,, ahk_id %ID%
Return
; --------------------------------------------------------------END-----------------------------------------------------------------

;-------------------------------------------- WINDOWS KEY + Y TOGGLES FILE EXTENSIONS
#y::
RegRead, HiddenFiles_Status, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt
If HiddenFiles_Status = 1 
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 0
Else 
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, HideFileExt, 1
WinGetClass, eh_Class,A
If (eh_Class = "#32770" OR A_OSVersion = "WIN_VISTA")
send, {F5}
Else PostMessage, 0x111, 28931,,, A
Return
; --------------------------------------------------------------END-----------------------------------------------------------------

;---------------------------------------------------- Open Everything Program ------------------------------------------------------
#f::
run, "C:\Program Files\Everything\Everything.exe"
; --------------------------------------------------------------END-----------------------------------------------------------------

; ;----------------------------------------------------- Google from clipboard -------------------------------------------------------
; #g::
; {
;     Send, ^c
;     Sleep 50
;     Run, https://www.google.com/search?q=%clipboard%
;     Return
; }
; --------------------------------------------------------------END-----------------------------------------------------------------

;---------------------------------------------------- Close Window with Escape -----------------------------------------------------
$Escape::                                               ; Long press (> 0.5 sec) on Esc closes window - but if you change your mind you can keep it pressed for 3 more seconds
    KeyWait, Escape, T1                               ; Wait no more than 0.5 sec for key release (also suppress auto-repeat)
    If ErrorLevel                                       ; timeout, so key is still down...
        {
            SoundPlay *64                               ; Play an asterisk (Doesn't work for me though!)
            WinGet, X, ProcessName, A
            SplashTextOn,,150,,`nRelease button to close %x%`n`nKeep pressing it to NOT close window...
            KeyWait, Escape, T3                         ; Wait no more than 3 more sec for key to be released
            SplashTextOff
            If !ErrorLevel                              ; No timeout, so key was released
                {
                    PostMessage, 0x112, 0xF060,,, A     ; ...so close window      
                    Return
                }
                                                        ; Otherwise,                
            SoundPlay *64
            KeyWait, Escape                             ; Wait for button to be released
                                                        ; Then do nothing...            
            Return
        }
        
        Send {Esc}
Return
; --------------------------------------------------------------END-----------------------------------------------------------------


; -------------------------------------------------------- Always on Top -----------------------------------------------------------
#ScrollLock:: Winset, Alwaysontop, , A ; ctrl + space
Return
; --------------------------------------------------------------END-----------------------------------------------------------------


; ---------------------------------------------------------- Suspend AHK ------------------------------------------------------------
#Pause::Suspend ; Win + scrollLock
return
; --------------------------------------------------------------END-----------------------------------------------------------------

; ctrl+shift+p: open powershell at current folder location in file explorer


; run script as admin (reload if not as admin) 
if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force


#IfWinActive ahk_class CabinetWClass
^+p::
    pwshHere()
    return
#IfWinActive


pwshHere(){
If WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
      If WinActive("ahk_class CabinetWClass") || WinActive("ahk_class ExploreWClass") {
        WinHWND := WinActive()
        For win in ComObjCreate("Shell.Application").Windows
            If (win.HWND = WinHWND) {
                dir := SubStr(win.LocationURL, 9) ; remove "file:///"
                dir := RegExReplace(dir, "%20", " ")
                Break
            }
    }
    Run, pwsh, % dir ? dir : A_Desktop
    }

}

; Launch_Mail::Run

; ---------------------------------------------------- Launch VSCode in this folder ------------------------------------------------------------
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

GetActiveExplorerPath()
{
    explorerHwnd := WinActive("ahk_class CabinetWClass")
    if (explorerHwnd)
    {
        for window in ComObjCreate("Shell.Application").Windows
        {
            if (window.hwnd==explorerHwnd)
            {
                return window.Document.Folder.Self.Path
            }
        }
    }
}



#IfWinActive ahk_exe Explorer.exe
.::
path := GetActiveExplorerPath()
run, "C:\Program Files\Microsoft VS Code\bin\code.cmd" "%path%"
return

; ---------------------------------------------------------- Deactivate AHK ------------------------------------------------------------