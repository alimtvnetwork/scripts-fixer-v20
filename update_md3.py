with open('ubuntu-installation-guide/02-ubuntu-manage-v2.md', 'r', encoding='utf-8') as f:
    content = f.read()

windows_anydesk = """
### AnyDesk (Windows Installation via PowerShell)
To automate the installation of AnyDesk on a Windows host, you can use PowerShell to download it into the `scripts-download` directory and install it silently.

```powershell
# Set up download directory in user profile
$downloadDir = "$HOME\\scripts-download"
New-Item -ItemType Directory -Force -Path $downloadDir | Out-Null
Set-Location $downloadDir

# Download latest AnyDesk for Windows
Invoke-WebRequest -Uri "https://download.anydesk.com/AnyDesk.exe" -OutFile "AnyDesk.exe"

# Install silently (runs in background)
Start-Process -FilePath ".\\AnyDesk.exe" -ArgumentList "--install", "$env:ProgramFiles\\AnyDesk", "--start-with-win", "--silent" -Wait -NoNewWindow
```
"""

content = content.replace("sudo apt-fast install -y anydesk\n```", "sudo apt-fast install -y anydesk\n```\n" + windows_anydesk)

with open('ubuntu-installation-guide/02-ubuntu-manage-v2.md', 'w', encoding='utf-8') as f:
    f.write(content)
