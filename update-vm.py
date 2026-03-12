import winrm, time
s = winrm.Session("216.238.121.127", auth=("Administrator", "r5{Avv=CmAtD9CYv"), transport="ntlm", read_timeout_sec=120, operation_timeout_sec=90)

r = s.run_cmd("hostname")
print(f"Host: {r.std_out.decode().strip()}")

print("Pulling launcher...")
r = s.run_cmd(r"cd C:\claude-launcher-web && git pull")
print(f"  {r.std_out.decode().strip()[:300]}")
if r.std_err:
    print(f"  err: {r.std_err.decode().strip()[:200]}")

r = s.run_cmd(r"dir C:\lucasaugustodev-agents\README.md")
if r.status_code != 0:
    print("Cloning agent pack...")
    r = s.run_cmd(r"git clone --depth 1 https://github.com/lucasaugustodev/claude-agents.git C:\lucasaugustodev-agents")
    print(f"  Clone RC: {r.status_code}")
else:
    print("Agent pack already present")

print("Restarting launcher...")
s.run_cmd("taskkill /f /im node.exe")
time.sleep(3)
r = s.run_cmd('schtasks /run /tn "ClaudeLauncherWeb"')
print(f"  Restart RC: {r.status_code}")

time.sleep(5)
r = s.run_cmd('powershell -c "Test-NetConnection -ComputerName localhost -Port 3001 | Select-Object -ExpandProperty TcpTestSucceeded"')
print(f"  Port 3001: {r.std_out.decode().strip()}")
print("Done!")
