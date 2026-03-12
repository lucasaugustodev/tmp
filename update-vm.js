// Update claude-launcher-web on VM via SSH through the main server
const { execSync } = require('child_process');

const mainServer = '216.238.116.106';
const vmIp = '216.238.121.127';
const vmPass = 'r5{Avv=CmAtD9CYv';

// Use WinRM via Python on the main server
const script = `
import winrm
s = winrm.Session("${vmIp}", auth=("Administrator", "${vmPass}"), transport="ntlm", read_timeout_sec=120, operation_timeout_sec=90)

r = s.run_cmd("hostname")
print(f"Host: {r.std_out.decode().strip()}")

# Pull latest launcher
print("Pulling launcher...")
r = s.run_cmd(r"cd C:\\claude-launcher-web && git pull")
print(f"  {r.std_out.decode().strip()[:200]}")
print(f"  err: {r.std_err.decode().strip()[:200]}")

# Also clone agent pack if not present
r = s.run_cmd(r'dir C:\\lucasaugustodev-agents\\README.md')
if r.status_code != 0:
    print("Cloning agent pack...")
    r = s.run_cmd('git clone --depth 1 https://github.com/lucasaugustodev/claude-agents.git C:\\\\lucasaugustodev-agents')
    print(f"  Clone RC: {r.status_code}")
else:
    print("Agent pack already present")

# Restart launcher
print("Restarting launcher...")
s.run_cmd("taskkill /f /im node.exe")
import time; time.sleep(2)
r = s.run_cmd('schtasks /run /tn "ClaudeLauncherWeb"')
print(f"  Restart RC: {r.status_code}")

time.sleep(5)
r = s.run_cmd('powershell -c "Test-NetConnection -ComputerName localhost -Port 3001 | Select-Object -ExpandProperty TcpTestSucceeded"')
print(f"  Port 3001: {r.std_out.decode().strip()}")
print("Done!")
`.trim();

// Write script to main server and execute
console.log('Uploading update script to main server...');
execSync(`ssh -o StrictHostKeyChecking=no root@${mainServer} 'cat > /tmp/update-vm.py << '"'"'PYEOF'"'"'\n${script}\nPYEOF'`, { stdio: 'inherit' });

console.log('Running update on VM...');
execSync(`ssh -o StrictHostKeyChecking=no root@${mainServer} 'python3 /tmp/update-vm.py'`, { stdio: 'inherit', timeout: 120000 });
