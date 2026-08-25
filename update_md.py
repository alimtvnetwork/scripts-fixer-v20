with open('ubuntu-installation-guide/02-ubuntu-manage-v2.md', 'r', encoding='utf-8') as f:
    content = f.read()

import re

new_vm_section = """## VMware Open VM Tools And Shared Folders

Enables clipboard sharing, proper scrolling and host folder mounting inside a VMware guest, then links the shares reliably to your desktop on startup.

```bash
sudo DEBIAN_FRONTEND=noninteractive apt-fast install -y open-vm-tools open-vm-tools-desktop
sudo systemctl enable --now open-vm-tools
/usr/bin/vmware-toolbox-cmd -v
```

### Automount VMware Shared Folders on Startup to Desktop

Using `/etc/fstab` can fail if VMware tools load too late during boot. This approach uses a systemd mount unit to guarantee that any files you share from the host will immediately appear on your Ubuntu Desktop under `SharedDirectories` every time the OS runs.

```bash
# 1. Create the mount directory and ensure the Desktop exists
sudo mkdir -p /mnt/hgfs
mkdir -p "$HOME/Desktop"

# 2. Create a persistent shortcut directly on your Desktop
ln -sfn /mnt/hgfs "$HOME/Desktop/SharedDirectories"

# 3. Create a reliable systemd mount unit
cat << 'EOF' | sudo tee /etc/systemd/system/mnt-hgfs.mount > /dev/null
[Unit]
Description=Mount VMware Shared Folders
ConditionVirtualization=vmware
After=open-vm-tools.service

[Mount]
What=.host:/
Where=/mnt/hgfs
Type=fuse.vmhgfs-fuse
Options=allow_other,auto_unmount,defaults

[Install]
WantedBy=multi-user.target
EOF

# 4. Enable and activate the mount service
sudo systemctl daemon-reload
sudo systemctl enable mnt-hgfs.mount
sudo systemctl restart mnt-hgfs.mount

# Verify
ls -la "$HOME/Desktop/SharedDirectories"
```
"""

# Replace the old VM section
content = re.sub(
    r'## VMware Open VM Tools And Shared Folders.*?(?=## |\Z)', 
    new_vm_section + '\n', 
    content, 
    flags=re.DOTALL
)

with open('ubuntu-installation-guide/02-ubuntu-manage-v2.md', 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated VM section successfully.")
