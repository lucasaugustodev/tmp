#Requires AutoHotkey v2.0
hwnd := 18942940
if WinExist("ahk_id " hwnd) {
    WinShow("ahk_id " hwnd)
    WinRestore("ahk_id " hwnd)
    WinActivate("ahk_id " hwnd)
    WinWaitActive("ahk_id " hwnd,, 5)
    WinMaximize("ahk_id " hwnd)
}
Sleep(1500)
ExitApp()
