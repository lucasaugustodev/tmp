import winrm, time, os

# Get credentials from environment variables
VM_HOST = os.environ.get("VM_HOST", "216.238.117.49")
VM_USER = os.environ.get("VM_USER", "Administrator")
VM_PASS = os.environ.get("VM_PASS", "")

if not VM_PASS:
    raise ValueError("VM_PASS environment variable is required")

s = winrm.Session(VM_HOST, auth=(VM_USER, VM_PASS), transport="ntlm", read_timeout_sec=120, operation_timeout_sec=90)

# Kill ALL node processes
print("Killing all node...")
s.run_cmd("taskkill /f /im node.exe")
time.sleep(3)

# Verify killed
r = s.run_cmd('tasklist /fi "imagename eq node.exe"')
print(f"After kill: {r.std_out.decode().strip()[:200]}")

# Check if agent pack exists, if not clone it
r = s.run_cmd(r'dir C:\lucasaugustodev-agents\README.md')
if r.status_code != 0:
    print("Cloning agent pack...")
    r = s.run_cmd('git clone --depth 1 https://github.com/lucasaugustodev/claude-agents.git C:\\lucasaugustodev-agents')
    print(f"  RC: {r.status_code}")
else:
    print("Agent pack OK")

# Check installed_plugins.json - if claude-mem not registered, register it
r = s.run_cmd(r'type C:\Users\Administrator\.claude\plugins\installed_plugins.json')
plugins_content = r.std_out.decode().strip()
print(f"Installed plugins: {plugins_content[:300]}")

if 'claude-mem' not in plugins_content:
    print("Registering claude-mem in installed_plugins.json...")
    r = s.run_ps(r'''
$pluginsDir = "C:\Users\Administrator\.claude\plugins"
$regPath = "$pluginsDir\installed_plugins.json"
$cacheDir = "$pluginsDir\cache\thedotmack\claude-mem\0.0.1"

# Create cache dir and copy from pre-installed
New-Item -ItemType Directory -Force -Path $cacheDir | Out-Null
if (Test-Path "C:\claude-mem\package.json") {
    Copy-Item "C:\claude-mem\*" $cacheDir -Recurse -Force -Exclude @('.git','node_modules')
}

# Register in installed_plugins.json
$registry = @{
    version = 2
    plugins = @{
        "claude-mem@thedotmack" = @(
            @{
                scope = "user"
                installPath = $cacheDir
                version = "0.0.1"
                installedAt = (Get-Date -Format o)
                lastUpdated = (Get-Date -Format o)
            }
        )
    }
}
$registry | ConvertTo-Json -Depth 5 | Set-Content $regPath -Encoding UTF8
Write-Output "Registered"
''')
    print(f"  RC: {r.status_code}, out: {r.std_out.decode().strip()[:200]}")

# Start launcher via scheduled task
print("\nStarting launcher...")
r = s.run_cmd('schtasks /run /tn "ClaudeLauncherWeb"')
print(f"  Task RC: {r.status_code}")

# Wait and check
time.sleep(8)
r = s.run_cmd('powershell -c "(Test-NetConnection -ComputerName localhost -Port 3001).TcpTestSucceeded"')
port_ok = r.std_out.decode().strip()
print(f"Port 3001: {port_ok}")

if 'False' in port_ok:
    print("Port still down, trying direct start...")
    # Try starting directly with output capture
    r = s.run_ps(r'''
$env:PATH = "C:\Windows\system32;C:\Windows;C:\Program Files\nodejs;C:\Program Files\Git\cmd;C:\Program Files\GitHub CLI;C:\Users\Administrator\AppData\Roaming\npm;C:\Users\Administrator\.bun\bin;" + $env:PATH
$env:PORT = "3001"
Set-Location "C:\claude-launcher-web"
Start-Process -FilePath "node" -ArgumentList "server.js" -RedirectStandardOutput "C:\launcher-stdout.log" -RedirectStandardError "C:\launcher-stderr.log" -NoNewWindow
Start-Sleep -Seconds 10
Write-Output "=== STDOUT ==="
Get-Content "C:\launcher-stdout.log" -Tail 20 -ErrorAction SilentlyContinue
Write-Output "=== STDERR ==="
Get-Content "C:\launcher-stderr.log" -Tail 20 -ErrorAction SilentlyContinue
Write-Output "=== PORT ==="
(Test-NetConnection -ComputerName localhost -Port 3001).TcpTestSucceeded
''')
    print(r.std_out.decode().strip()[:2000])
    if r.std_err:
        print(f"PS ERR: {r.std_err.decode().strip()[:500]}")

print("\nDone")
