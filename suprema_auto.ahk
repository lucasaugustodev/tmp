#Requires AutoHotkey v2.0

; Script de automação completo do SupremaPoker
; Aguarda para não conflitar com o terminal
Sleep(4000)

hwnd := 18942940

; === Função screenshot via GDI+ ===
TakeShot(filename) {
    ; Usa PowerShell via arquivo temporário
    psScript := "C:\tmp\take_shot.ps1"
    RunWait('powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "' psScript '" "' filename '"',, "Hide")
}

; Minimiza todas as janelas para liberar o SupremaPoker
WinMinimizeAll()
Sleep(1000)

; Ativa e maximiza o SupremaPoker
WinActivate("ahk_id " hwnd)
WinRestore("ahk_id " hwnd)
Sleep(500)
WinMaximize("ahk_id " hwnd)
WinWaitActive("ahk_id " hwnd,, 10)
Sleep(2000)

; Screenshot A: estado inicial maximizado
TakeShot("C:\tmp\ss_A.png")
Sleep(800)

; === AÇÃO 1: Clicar no avatar/perfil do usuário ===
; Na janela maximizada 610x1096, o avatar fica no topo esquerdo
; Coordenada tela: janela começa em -8,-8
; Avatar em aprox x=60, y=55 da janela = x=52, y=47 na tela
Click(52, 47)
Sleep(2500)
TakeShot("C:\tmp\ss_B.png")
Sleep(500)

; Fechar o que abriu com ESC
Send("{Escape}")
Sleep(1000)

; === AÇÃO 2: Clicar em "Clube dos Vaqueiros" (primeiro clube da lista) ===
; Na janela 1096px altura, o primeiro clube fica ~y=440 da janela = ~432 tela
Click(292, 432)
Sleep(3000)
TakeShot("C:\tmp\ss_C.png")
Sleep(500)

; Volta
Send("{Escape}")
Sleep(1500)

; === AÇÃO 3: Clicar no segundo clube (FichasNet) ===
; Aprox y=560 da janela = ~552 tela
Click(292, 552)
Sleep(3000)
TakeShot("C:\tmp\ss_D.png")
Sleep(500)

; Volta
Send("{Escape}")
Sleep(1500)

; === AÇÃO 4: Clicar no torneio/banner no rodapé ===
; Na parte inferior da janela
Click(292, 900)
Sleep(2500)
TakeShot("C:\tmp\ss_E.png")

; Restaura janelas minimizadas
WinMinimizeAllUndo()

ExitApp()
