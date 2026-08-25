# Task 10: Translate UFW & Firewalld Configuration
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
Translate: `ufw allow ssh`, `ufw allow 22`, `ufw enable`, `ufw status`.
## How
- **Ubuntu**: List the `ufw` commands.
- **Fedora/CentOS**: Translate to `firewalld`: `sudo firewall-cmd --permanent --add-service=ssh`, `sudo firewall-cmd --permanent --add-port=22/tcp`, `sudo firewall-cmd --reload`.
