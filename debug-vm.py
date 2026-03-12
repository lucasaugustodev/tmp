import winrm, time
s = winrm.Session("216.238.117.49", auth=("Administrator", "vD_9uF{FmAAq6Q6s"), transport="ntlm", read_timeout_sec=60, operation_timeout_sec=45)

# Kill existing node processes
print("Killing node processes...")
s.run_cmd("taskkill /f /im node.exe")
time.sleep(2)

# Start launcher manually and capture output
print("Starting launcher manually (capturing output)...")
r = s.run_ps(r'''
$env:PATH = "C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem;C:\Windows\System32\WindowsPowerShell\v1.0\;C:\Windows\System32\OpenSSH\;C:\Program Files\nodejs\;C:\Program Files\Git\cmd;C:\Program Files\GitHub CLI;C:\Users\Administrator\AppData\Roaming\npm;C:\Program Files\GitHub CLI\;C:\Users\Administrator\.bun\bin;" + $env:PATH
$env:PORT = "3001"
Set-Location "C:\claude-launcher-web"
$proc = Start-Process -FilePath "node" -ArgumentList "server.js" -RedirectStandardOutput "C:\claude-launcher-web\stdout.log" -RedirectStandardError "C:\claude-launcher-web\stderr.log" -PassThru -NoNewWindow
Start-Sleep -Seconds 8
Get-Content "C:\claude-launcher-web\stdout.log" -ErrorAction SilentlyContinue | Select-Object -Last 30
Write-Output "=== STDERR ==="
Get-Content "C:\claude-launcher-web\stderr.log" -ErrorAction SilentlyContinue | Select-Object -Last 30
Write-Output "=== PORT CHECK ==="
Test-NetConnection -ComputerName localhost -Port 3001 | Select-Object TcpTestSucceeded
''')
print(r.std_out.decode().strip()[:3000])
if r.std_err:
    print(f"\nPS Error: {r.std_err.decode().strip()[:500]}")
