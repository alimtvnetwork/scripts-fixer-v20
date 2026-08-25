with open('ubuntu-installation-guide/02-ubuntu-manage-v2.md', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# 1. Add AnyDesk
anydesk_section = """
### AnyDesk (Cross-Platform Remote Desktop)
Install the latest version of AnyDesk directly from their official APT repository.

```bash
# Set up download directory
mkdir -p ~/scripts-download && cd ~/scripts-download

# Add repository key and list
wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/anydesk.gpg
echo "deb http://deb.anydesk.com/ all main" | sudo tee /etc/apt/sources.list.d/anydesk-stable.list

# Install
sudo apt-fast update -y
sudo apt-fast install -y anydesk
```
"""

# Insert it before the VMware section
content = content.replace("## VMware Open VM Tools And Shared Folders", anydesk_section + "\n## VMware Open VM Tools And Shared Folders")

# 2. Modify downloads to use ~/scripts-download
content = content.replace("cd ~/Downloads", "mkdir -p ~/scripts-download && cd ~/scripts-download")
content = content.replace("cd ~/installer", "mkdir -p ~/scripts-download && cd ~/scripts-download")

# For XAMPP, make sure it uses the new folder
content = re.sub(
    r'(?m)^aria2c -c -s 20.*?xampp-linux-x64.*?installer\.run$',
    r'mkdir -p ~/scripts-download && cd ~/scripts-download\n\g<0>',
    content
)

# For Beyond compare
content = re.sub(
    r'(?m)^wget https://www.scootersoftware.com/files/bcompare.*?deb$',
    r'mkdir -p ~/scripts-download && cd ~/scripts-download\n\g<0>',
    content
)

# For DBeaver
content = re.sub(
    r'(?m)^wget https://dbeaver.io/files/dbeaver-ce.*?deb$',
    r'mkdir -p ~/scripts-download && cd ~/scripts-download\n\g<0>',
    content
)

# 3. Add note about setup.sh vm-shared-folder-fix
helper_note = """
> **Note**: If you are using our provided `setup.sh` helper, you can instantly apply this fix across Ubuntu/CentOS/Fedora by simply running:
> ```bash
> ./setup.sh vm-shared-folder-fix
> ```
"""

content = content.replace("### Automount VMware Shared Folders on Startup to Desktop\n\nUsing `/etc/fstab` can fail", "### Automount VMware Shared Folders on Startup to Desktop\n" + helper_note + "\nUsing `/etc/fstab` can fail")

with open('ubuntu-installation-guide/02-ubuntu-manage-v2.md', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated markdown with AnyDesk, scripts-download directory, and helper note.")
