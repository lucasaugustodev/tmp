import winrm
s = winrm.Session("216.238.117.49", auth=("Administrator", "vD_9uF{FmAAq6Q6s"), transport="ntlm", read_timeout_sec=60, operation_timeout_sec=45)

# Check if agent pack exists
r = s.run_cmd(r'dir C:\lucasaugustodev-agents\README.md')
print(f"Agent pack exists: {r.status_code == 0}")
print(r.std_out.decode().strip()[:200])

# Check if claude-mem exists
r = s.run_cmd(r'dir C:\claude-mem\package.json')
print(f"claude-mem exists: {r.status_code == 0}")

# Check installed plugins
r = s.run_cmd(r'type C:\Users\Administrator\.claude\plugins\installed_plugins.json')
print(f"Installed plugins: {r.std_out.decode().strip()[:500]}")

# Check installed agents dir
r = s.run_cmd(r'dir C:\Users\Administrator\.claude\commands')
print(f"Agents dir: {r.std_out.decode().strip()[:500]}")
