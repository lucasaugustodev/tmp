#Requires AutoHotkey v2.0

; === Script de automação completo do SupremaPoker ===
; Aguarda 3 segundos para o terminal não interferir
Sleep(3000)

hwnd := 18942940

; Função para tirar screenshot via PowerShell
TakeScreenshot(filename) {
    RunWait('powershell.exe -WindowStyle Hidden -Command "Add-Type -AssemblyName System.Windows.Forms, System.Drawing; $bmp = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height); $g = [System.Drawing.Graphics]::FromImage($bmp); $g.CopyFromScreen(0,0,0,0,$bmp.Size); $bmp.Save(''' filename ''', ''Png''); $g.Dispose(); $bmp.Dispose()"',, "Hide")
}

; Minimiza todas as janelas
WinMinimizeAll()
Sleep(800)

; Ativa e maximiza o SupremaPoker
WinActivate("ahk_id " hwnd)
WinRestore("ahk_id " hwnd)
Sleep(300)
WinMaximize("ahk_id " hwnd)
WinWaitActive("ahk_id " hwnd,, 5)
Sleep(2000)

; Screenshot 1: Estado inicial maximizado
TakeScreenshot("C:\tmp\ss_supra_A.png")
Sleep(500)

; === AÇÃO 1: Clicar no avatar/nome do usuário (perfil) ===
; Posição aproximada do avatar no canto superior esquerdo
Click(60, 55)
Sleep(2500)
TakeScreenshot("C:\tmp\ss_supra_B.png")
Sleep(500)

; === AÇÃO 2: Clicar em um clube da lista (Clube dos Vaqueiros) ===
; Na janela maximizada (resolução 1920x1080 ou similar), clicar no primeiro clube
Click(960, 350)
Sleep(2500)
TakeScreenshot("C:\tmp\ss_supra_C.png")
Sleep(500)

; Voltar (ESC ou botão voltar)
Send("{Escape}")
Sleep(1500)

; === AÇÃO 3: Clicar no ícone de configurações ou em outro menu ===
Click(960, 450)
Sleep(2500)
TakeScreenshot("C:\tmp\ss_supra_D.png")
Sleep(500)

; Voltar
Send("{Escape}")
Sleep(1000)

; === AÇÃO 4: Clicar no botão/aba de torneios ou lobby ===
Click(960, 550)
Sleep(2500)
TakeScreenshot("C:\tmp\ss_supra_E.png")

ExitApp()
