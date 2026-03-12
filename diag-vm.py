import winrm, time, os

# Get credentials from environment variables
VM_HOST = os.environ.get("VM_HOST", "216.238.117.49")
VM_USER = os.environ.get("VM_USER", "Administrator")
VM_PASS = os.environ.get("VM_PASS", "")

if not VM_PASS:
    raise ValueError("VM_PASS environment variable is required")

s = winrm.Session(VM_HOST, auth=(VM_USER, VM_PASS), transport="ntlm", read_timeout_sec=60, operation_timeout_sec=45)

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
