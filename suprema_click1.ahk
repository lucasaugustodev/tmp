#Requires AutoHotkey v2.0

hwnd := 18942940
WinActivate("ahk_id " hwnd)
WinWaitActive("ahk_id " hwnd,, 5)
Sleep(800)

; Clicar em "Clube dos Vaqueir..." (item da lista, ~posição 295, 310)
Click(295, 310)
Sleep(1500)

ExitApp()
