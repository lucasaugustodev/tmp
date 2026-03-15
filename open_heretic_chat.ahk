#Requires AutoHotkey v2.0

; Open CMD with custom title and run the commands
Run('cmd.exe /k "title Heretic 3x Chat && set PYTHONPATH=D:\heretic\python-libs && set HF_HOME=D:\heretic\hf-cache && python C:\Users\PC\heretic_chat.py"',, "Show")

; Wait for the window to appear
WinWait("Heretic 3x Chat",, 10)
Sleep(500)

; Resize to 1200x700
WinActivate("Heretic 3x Chat")
WinWaitActive("Heretic 3x Chat",, 5)
Sleep(300)
WinMove(100, 100, 1200, 700, "Heretic 3x Chat")

ExitApp()
