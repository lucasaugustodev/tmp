import winrm, sys
s = winrm.Session("216.238.117.49", auth=("Administrator", "vD_9uF{FmAAq6Q6s"), transport="ntlm", read_timeout_sec=60, operation_timeout_sec=45)

r = s.run_cmd("hostname")
print(f"Host: {r.std_out.decode().strip()}")

# Check if launcher is running
print("\n--- Node processes ---")
r = s.run_cmd('tasklist /fi "imagename eq node.exe"')
print(r.std_out.decode().strip()[:500])

# Check port 3001
print("\n--- Port 3001 ---")
r = s.run_cmd('powershell -c "Test-NetConnection -ComputerName localhost -Port 3001 | Select-Object TcpTestSucceeded"')
print(r.std_out.decode().strip())

# Check launcher log
print("\n--- Launcher stderr (last 30 lines) ---")
r = s.run_cmd(r'powershell -c "if (Test-Path C:\claude-launcher-web\launcher.log) { Get-Content C:\claude-launcher-web\launcher.log -Tail 30 } else { echo NO_LOG }"')
print(r.std_out.decode().strip()[:1500])

# Check start.bat exists
print("\n--- start.bat ---")
r = s.run_cmd(r'type C:\claude-launcher-web\start.bat')
print(r.std_out.decode().strip()[:500])

# Check if git pulled the latest
print("\n--- Latest commit ---")
r = s.run_cmd(r'cd C:\claude-launcher-web && git log --oneline -3')
print(r.std_out.decode().strip())

# Check scheduled task
print("\n--- Scheduled task ---")
r = s.run_cmd('schtasks /query /tn "ClaudeLauncherWeb" /fo LIST')
print(r.std_out.decode().strip()[:500])
