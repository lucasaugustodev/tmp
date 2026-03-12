import winrm, time
s = winrm.Session("216.238.117.49", auth=("Administrator", "vD_9uF{FmAAq6Q6s"), transport="ntlm", read_timeout_sec=60, operation_timeout_sec=45)

# Is node running?
r = s.run_cmd('tasklist /fi "imagename eq node.exe"')
print(f"=== NODE PROCS ===\n{r.std_out.decode().strip()}")

# Port check
r = s.run_cmd('powershell -c "(Test-NetConnection -ComputerName localhost -Port 3001).TcpTestSucceeded"')
print(f"\nPort 3001: {r.std_out.decode().strip()}")

# Stdout log
r = s.run_cmd(r'powershell -c "if(Test-Path C:\claude-launcher-web\stdout.log){Get-Content C:\claude-launcher-web\stdout.log -Tail 50}else{echo NO_FILE}"')
print(f"\n=== STDOUT LOG ===\n{r.std_out.decode().strip()[:2000]}")

# Stderr log
r = s.run_cmd(r'powershell -c "if(Test-Path C:\claude-launcher-web\stderr.log){Get-Content C:\claude-launcher-web\stderr.log -Tail 50}else{echo NO_FILE}"')
print(f"\n=== STDERR LOG ===\n{r.std_out.decode().strip()[:2000]}")

# Windows event log for node crashes
r = s.run_cmd('powershell -c "Get-EventLog -LogName Application -Newest 10 -EntryType Error 2>$null | Select-Object TimeGenerated,Message | Format-List"')
print(f"\n=== EVENT LOG ===\n{r.std_out.decode().strip()[:2000]}")
