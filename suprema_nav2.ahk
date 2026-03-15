#Requires AutoHotkey v2.0

hwnd := 18942940

; Coordenadas da janela obtidas: Left=-8, Top=-8, Width=610, Height=1096
; A janela começa em x=-8, y=-8 no sistema de coordenadas da tela
; Então posição na tela = posição_na_janela + (-8, -8)
; Para clicar em x=300, y=200 dentro da janela:
; coordenada tela = (300 + (-8), 200 + (-8)) = (292, 192)

WinActivate("ahk_id " hwnd)
WinWaitActive("ahk_id " hwnd,, 5)
Sleep(1000)

; Clicar no item "Clube dos Vaqueiros" (aparece em y≈300 na janela de 1096px)
; Na screenshot de 768px a lista aparece em y≈310 -> proporcional: (310/768)*1096 ≈ 443
; Vamos tentar y=440 na janela = 440-8=432 na tela
; x = centro da janela ≈ 300 - 8 = 292
Click(292, 440)
Sleep(2000)

ExitApp()
