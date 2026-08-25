import os

os_run = "scripts/os/run.ps1"
with open(os_run, "r", encoding="utf-8") as f:
    content = f.read()

if "update-all" not in content:
    content = content.replace('switch ($Action) {', '''switch ($Action) {
    "update-all" {
        Write-Host "Running Ubuntu update-all via WSL..." -ForegroundColor Cyan
        wsl -e bash scripts/os/ubuntu/update-all.sh
        break
    }
    "update" {
        Write-Host "Running Ubuntu update via WSL..." -ForegroundColor Cyan
        wsl -e bash scripts/os/ubuntu/update.sh
        break
    }''')
    with open(os_run, "w", encoding="utf-8") as f:
        f.write(content)
        
profile_run = "scripts/profile/run.ps1"
if os.path.exists(profile_run):
    with open(profile_run, "r", encoding="utf-8") as f:
        p_content = f.read()
    if "ubuntu" not in p_content:
        p_content = p_content.replace('param(', '''param(
    [switch]$ubuntu_basic,
    [switch]$ubuntu_vscode,
    [switch]$ubuntu_simple_dev,
    [switch]$ubuntu_dev,
''')
        # Inject the handler at the bottom or top
        append = '''
if ($Args -contains "ubuntu-basic" -or $ubuntu_basic) { wsl -e bash scripts/os/ubuntu/profile-ubuntu-basic.sh; exit 0 }
if ($Args -contains "ubuntu+vscode" -or $ubuntu_vscode) { wsl -e bash scripts/os/ubuntu/profile-ubuntu-vscode.sh; exit 0 }
if ($Args -contains "ubuntu+simple-dev" -or $ubuntu_simple_dev) { wsl -e bash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh; exit 0 }
if ($Args -contains "ubuntu+dev" -or $ubuntu_dev) { wsl -e bash scripts/os/ubuntu/profile-ubuntu-dev.sh; exit 0 }
'''
        with open(profile_run, "a", encoding="utf-8") as f:
            f.write(append)
            
print("OS and Profile dispatcher updated.")
