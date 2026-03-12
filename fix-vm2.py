import winrm
s = winrm.Session("216.238.117.49", auth=("Administrator", "vD_9uF{FmAAq6Q6s"), transport="ntlm", read_timeout_sec=60, operation_timeout_sec=45)

# Check agent pack
r = s.run_cmd(r'dir C:\lucasaugustodev-agents\README.md')
print(f"Agent pack: RC={r.status_code}")

# Check claude-mem
r = s.run_cmd(r'dir C:\claude-mem\package.json')
print(f"claude-mem: RC={r.status_code}")

# Check port
r = s.run_cmd('powershell -c "(Test-NetConnection -ComputerName localhost -Port 3001).TcpTestSucceeded"')
print(f"Port 3001: {r.std_out.decode().strip()}")

# Check node running
r = s.run_cmd('tasklist /fi "imagename eq node.exe"')
print(f"Node: {r.std_out.decode().strip()[:300]}")

# Try to curl localhost
r = s.run_cmd('powershell -c "try { (Invoke-WebRequest http://localhost:3001/api/health -TimeoutSec 5).StatusCode } catch { $_.Exception.Message }"')
print(f"Health: {r.std_out.decode().strip()[:300]}")

# Get stdout/stderr logs
r = s.run_cmd(r'type C:\claude-launcher-web\stdout.log')
print(f"\n=== STDOUT ===\n{r.std_out.decode().strip()[-1000:]}")
r = s.run_cmd(r'type C:\claude-launcher-web\stderr.log')
print(f"\n=== STDERR ===\n{r.std_out.decode().strip()[-1000:]}")
