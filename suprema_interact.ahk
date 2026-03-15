#Requires AutoHotkey v2.0

hwnd := 18942940

; Ativar e maximizar
WinActivate("ahk_id " hwnd)
WinWaitActive("ahk_id " hwnd,, 5)
Sleep(500)
WinMaximize("ahk_id " hwnd)
Sleep(1000)

ExitApp()
