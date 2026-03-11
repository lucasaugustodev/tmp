"""Update claude-launcher-web on a provisioned Windows VM via WinRM"""
import winrm
import sys
import os

ip = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("VM_IP", "")
pw = sys.argv[2] if len(sys.argv) > 2 else os.environ.get("VM_PASS", "")

if not ip or not pw:
    print("Usage: update-vm-launcher.py <ip> <password>")
    sys.exit(1)

print(f"Connecting to {ip}...")
s = winrm.Session(ip, auth=("Administrator", pw), transport="ntlm")

r = s.run_cmd("hostname")
print(f"Hostname: {r.std_out.decode().strip()}")

# Update claude-launcher-web
print("Pulling latest claude-launcher-web...")
r = s.run_cmd(r"cd C:\claude-launcher-web && git pull")
print(f"  stdout: {r.std_out.decode().strip()[:300]}")
print(f"  stderr: {r.std_err.decode().strip()[:300]}")

# Restart launcher
print("Restarting launcher...")
s.run_cmd("taskkill /f /im node.exe")
import time; time.sleep(2)
r = s.run_cmd('schtasks /run /tn "ClaudeLauncherWeb"')
print(f"  Restart: RC={r.status_code}")

time.sleep(3)
r = s.run_cmd('powershell -c "Test-NetConnection -ComputerName localhost -Port 3001 | Select-Object -ExpandProperty TcpTestSucceeded"')
print(f"  Port 3001: {r.std_out.decode().strip()}")
print("Done!")
