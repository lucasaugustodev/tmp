#Requires AutoHotkey v2.0

; Primeiro mover/minimizar o Claude Code (janela com "Claude Code" no título)
; para liberar o SupremaPoker
hwndSupra := 18942940

; Minimiza todas as outras janelas exceto SupremaPoker
WinMinimizeAll()
Sleep(500)

; Restaura e maximiza o SupremaPoker
WinActivate("ahk_id " hwndSupra)
WinRestore("ahk_id " hwndSupra)
Sleep(300)
WinMaximize("ahk_id " hwndSupra)
WinWaitActive("ahk_id " hwndSupra,, 5)
Sleep(1500)

ExitApp()
