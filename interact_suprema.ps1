Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32Helper {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern bool BringWindowToTop(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
    [DllImport("user32.dll")]
    public static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
    [DllImport("user32.dll")]
    public static extern int SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
}
[StructLayout(LayoutKind.Sequential)]
public struct RECT { public int Left; public int Top; public int Right; public int Bottom; }
"@

function Take-Screenshot($path) {
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen
    $bmp = New-Object System.Drawing.Bitmap($screen.Bounds.Width, $screen.Bounds.Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.CopyFromScreen(0, 0, 0, 0, $bmp.Size)
    $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    Write-Host "Screenshot salvo: $path"
}

function Click-At($x, $y) {
    [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point($x, $y)
    Start-Sleep -Milliseconds 100
    $sim = New-Object System.Windows.Forms.SendKeys
    # Usa mouse_event
    Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public class MouseOps {
    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, int dx, int dy, uint dwData, int dwExtraInfo);
}
"@
    [MouseOps]::mouse_event(0x0002, 0, 0, 0, 0)  # MOUSEEVENTF_LEFTDOWN
    Start-Sleep -Milliseconds 50
    [MouseOps]::mouse_event(0x0004, 0, 0, 0, 0)  # MOUSEEVENTF_LEFTUP
    Write-Host "Clicou em ($x, $y)"
}

$hwnd = [IntPtr]::new(18942940)

# Passo 1: Focar e maximizar SupremaPoker
Write-Host "=== Ativando SupremaPoker ==="
[Win32Helper]::ShowWindow($hwnd, 9)   # SW_RESTORE
Start-Sleep -Milliseconds 500
[Win32Helper]::ShowWindow($hwnd, 3)   # SW_MAXIMIZE
Start-Sleep -Milliseconds 500
[Win32Helper]::BringWindowToTop($hwnd)
[Win32Helper]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds 2000

# Screenshot A: estado inicial
Take-Screenshot "C:\tmp\ss_A.png"
Start-Sleep -Milliseconds 800

# Passo 2: Obter posição da janela
$rect = New-Object RECT
[Win32Helper]::GetWindowRect($hwnd, [ref]$rect)
Write-Host "Janela: Left=$($rect.Left) Top=$($rect.Top) Right=$($rect.Right) Bottom=$($rect.Bottom)"
$winX = $rect.Left
$winY = $rect.Top
$winW = $rect.Right - $rect.Left
$winH = $rect.Bottom - $rect.Top

# AÇÃO 1: Clicar no perfil/avatar (topo esquerdo)
Write-Host "=== AÇÃO 1: Clicando no perfil ==="
[Win32Helper]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds 500
$clickX = $winX + 60   # ~60px da esquerda
$clickY = $winY + 55   # ~55px do topo
Click-At $clickX $clickY
Start-Sleep -Milliseconds 2500
Take-Screenshot "C:\tmp\ss_B.png"
Start-Sleep -Milliseconds 500

# ESC para fechar
[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
Start-Sleep -Milliseconds 1000

# AÇÃO 2: Clicar no primeiro clube da lista
Write-Host "=== AÇÃO 2: Clicando no Clube dos Vaqueiros ==="
[Win32Helper]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds 500
$clickX = $winX + [int]($winW * 0.5)   # centro horizontal
$clickY = $winY + [int]($winH * 0.40)  # ~40% vertical (lista de clubes)
Click-At $clickX $clickY
Start-Sleep -Milliseconds 3000
Take-Screenshot "C:\tmp\ss_C.png"
Start-Sleep -Milliseconds 500

[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
Start-Sleep -Milliseconds 1000

# AÇÃO 3: Clicar no segundo clube (FichasNet)
Write-Host "=== AÇÃO 3: Clicando no segundo clube ==="
[Win32Helper]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds 500
$clickX = $winX + [int]($winW * 0.5)
$clickY = $winY + [int]($winH * 0.52)  # ~52% vertical
Click-At $clickX $clickY
Start-Sleep -Milliseconds 3000
Take-Screenshot "C:\tmp\ss_D.png"
Start-Sleep -Milliseconds 500

[System.Windows.Forms.SendKeys]::SendWait("{ESC}")
Start-Sleep -Milliseconds 1000

# AÇÃO 4: Clicar no banner TORNEIO (rodapé)
Write-Host "=== AÇÃO 4: Clicando no banner Torneio ==="
[Win32Helper]::SetForegroundWindow($hwnd)
Start-Sleep -Milliseconds 500
$clickX = $winX + [int]($winW * 0.5)
$clickY = $winY + [int]($winH * 0.87)  # ~87% vertical (rodapé)
Click-At $clickX $clickY
Start-Sleep -Milliseconds 2500
Take-Screenshot "C:\tmp\ss_E.png"

Write-Host "=== AUTOMAÇÃO CONCLUÍDA ==="
Write-Host "Screenshots salvos em C:\tmp\ss_A.png até ss_E.png"
