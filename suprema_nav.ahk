#Requires AutoHotkey v2.0

hwnd := 18942940

; Ativar janela do SupremaPoker
WinActivate("ahk_id " hwnd)
WinWaitActive("ahk_id " hwnd,, 5)
Sleep(1000)

; A janela tem Left=-8, Top=-8, Width=610, Height=1096
; Vamos clicar no item "Clube dos Vaqueiros" que aparece na lista
; Na screenshot suprema_06, o clube aparece em ~(75, 300) relativo à tela
; Coordenadas absolutas: janela começa em -8,-8, então:
; item clube ≈ x=75, y=310 na tela

; Primeiro clica no banner "CONTA VERIFICADA" para fechar/interagir
Click(80, 130)
Sleep(1500)

ExitApp()
