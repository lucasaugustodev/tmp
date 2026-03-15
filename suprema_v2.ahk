#Requires AutoHotkey v2.0

; Função para tirar screenshot usando GDI+ via DllCall
TakeShot(filename) {
    ; Inicializa GDI+
    gdipToken := 0
    si := Buffer(16, 0)
    NumPut("UInt", 1, si, 0)  ; GdiplusVersion = 1
    DllCall("gdiplus\GdiplusStartup", "UPtr*", &gdipToken, "Ptr", si, "Ptr", 0)

    ; Obtém dimensões da tela
    width := SysGet(78)   ; SM_CXVIRTUALSCREEN
    height := SysGet(79)  ; SM_CYVIRTUALSCREEN

    ; Cria bitmap compatível
    hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
    hMemDC := DllCall("CreateCompatibleDC", "Ptr", hDC, "Ptr")
    hBitmap := DllCall("CreateCompatibleBitmap", "Ptr", hDC, "Int", width, "Int", height, "Ptr")
    DllCall("SelectObject", "Ptr", hMemDC, "Ptr", hBitmap)
    DllCall("BitBlt", "Ptr", hMemDC, "Int", 0, "Int", 0, "Int", width, "Int", height, "Ptr", hDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)

    ; Salva como PNG usando GDI+
    pBitmap := 0
    DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", 0, "UPtr*", &pBitmap)

    ; CLSID para PNG
    CLSID := Buffer(16, 0)
    DllCall("Ole32\CLSIDFromString", "Str", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", CLSID)

    ; Salva
    DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", filename, "Ptr", CLSID, "Ptr", 0)

    ; Limpeza
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("DeleteObject", "Ptr", hBitmap)
    DllCall("DeleteDC", "Ptr", hMemDC)
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    DllCall("gdiplus\GdiplusShutdown", "UPtr", gdipToken)
}

; Aguarda para não conflitar com o terminal
Sleep(3000)

hwnd := 18942940

; Minimiza todas as janelas
WinMinimizeAll()
Sleep(1000)

; Ativa e maximiza o SupremaPoker
WinActivate("ahk_id " hwnd)
WinRestore("ahk_id " hwnd)
Sleep(500)
WinMaximize("ahk_id " hwnd)
WinWaitActive("ahk_id " hwnd,, 10)
Sleep(2000)

; Screenshot A: estado inicial
TakeShot("C:\tmp\ss_A.png")
Sleep(800)

; === AÇÃO 1: Clicar no perfil/avatar ===
; Janela: Left=-8, Top=-8, Width=610, Height=1096
; Avatar/nome fica no topo: y≈55 da janela = y≈47 tela; x≈60 janela = x≈52 tela
Click(52, 47)
Sleep(2500)
TakeShot("C:\tmp\ss_B.png")
Sleep(500)

; Fecha popup se houver
Send("{Escape}")
Sleep(1000)

; === AÇÃO 2: Clicar no primeiro clube da lista ===
; Lista começa após o banner. Na janela de 1096px: ~y=430-450 = ~422 tela
Click(295, 432)
Sleep(3000)
TakeShot("C:\tmp\ss_C.png")
Sleep(500)

Send("{Escape}")
Sleep(1000)

; === AÇÃO 3: Clicar no segundo clube ===
Click(295, 560)
Sleep(3000)
TakeShot("C:\tmp\ss_D.png")
Sleep(500)

Send("{Escape}")
Sleep(1000)

; === AÇÃO 4: Botão/banner no rodapé (TORNEIO RING GAME) ===
Click(295, 950)
Sleep(2500)
TakeShot("C:\tmp\ss_E.png")

; Restaura janelas minimizadas
WinMinimizeAllUndo()
Sleep(500)

ExitApp()
