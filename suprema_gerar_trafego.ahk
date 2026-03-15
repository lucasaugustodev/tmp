#Requires AutoHotkey v2.0

hwnd := 18942940

; Ativa janela do SupremaPoker
WinActivate("ahk_id " hwnd)
WinWaitActive("ahk_id " hwnd,, 5)
Sleep(1000)

; A janela ocupa aprox x=0-155, y=0-768 na tela conforme screenshots
; (janela começa em -8,-8 com 610px largura, mas visível ~0-150px)
; Vamos usar coordenadas relativas à janela

; === AÇÃO 1: Clicar no avatar/perfil (canto superior esquerdo da janela) ===
; Coordenadas da janela: ~x=40, y=40 relativo à janela (x-8, y-8 no sistema)
; Coor absoluta tela: x=32, y=32
Click(32, 32)
Sleep(2000)

ExitApp()
