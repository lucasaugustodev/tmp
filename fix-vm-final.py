import winrm, time
s = winrm.Session("216.238.117.49", auth=("Administrator", "vD_9uF{FmAAq6Q6s"), transport="ntlm", read_timeout_sec=120, operation_timeout_sec=90)

r = s.run_cmd("hostname")
print(f"Host: {r.std_out.decode().strip()}")

# 1. Clone agent pack
print("\n1. Installing agent pack...")
r = s.run_cmd(r'dir C:\lucasaugustodev-agents\README.md')
if r.status_code != 0:
    r = s.run_cmd(r'git clone --depth 1 https://github.com/lucasaugustodev/claude-agents.git C:\lucasaugustodev-agents')
    print(f"   Clone RC: {r.status_code}")
    if r.std_err:
        print(f"   err: {r.std_err.decode().strip()[:200]}")
else:
    print("   Already present")

# 2. Pull latest launcher
print("\n2. Pulling launcher...")
r = s.run_cmd(r'cd C:\claude-launcher-web && git pull')
print(f"   {r.std_out.decode().strip()[:300]}")

# 3. Restart
print("\n3. Restarting...")
s.run_cmd("taskkill /f /im node.exe")
time.sleep(3)
r = s.run_cmd('schtasks /run /tn "ClaudeLauncherWeb"')
print(f"   Schtask RC: {r.status_code}")

# 4. Wait and check
time.sleep(8)
r = s.run_cmd('powershell -c "Test-NetConnection -ComputerName localhost -Port 3001 | Select-Object -ExpandProperty TcpTestSucceeded"')
port_ok = r.std_out.decode().strip()
print(f"\n4. Port 3001: {port_ok}")

# 5. Wait more and re-check (auto-install would have run by now on first browser hit)
time.sleep(5)
r = s.run_cmd('powershell -c "Test-NetConnection -ComputerName localhost -Port 3001 | Select-Object -ExpandProperty TcpTestSucceeded"')
print(f"5. Port 3001 (after wait): {r.std_out.decode().strip()}")

# 6. Check latest commit
r = s.run_cmd(r'cd C:\claude-launcher-web && git log --oneline -1')
print(f"6. Commit: {r.std_out.decode().strip()}")

print("\nDone!")
