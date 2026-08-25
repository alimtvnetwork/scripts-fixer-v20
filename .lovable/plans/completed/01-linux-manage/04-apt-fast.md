# Task 04: Translate Apt-Fast configuration
## Where
- `01-ubuntu-installation.md`, `02-fedora-installation.md`, `03-centos-installation.md`
## What
The OneNote file heavily references `apt-fast`.
## How
- **Ubuntu**: Include instructions to add the PPA (`add-apt-repository ppa:apt-fast/stable`), and install `apt-fast`. Set `DOWNLOADMANAGER="aria2c"` and `MAXDOWNLOADS=16`.
- **Fedora**: Note that `apt-fast` is Debian/Ubuntu specific. For Fedora, recommend configuring DNF concurrent downloads in `/etc/dnf/dnf.conf` (`max_parallel_downloads=10`).
- **CentOS**: Similar to Fedora, edit `/etc/yum.conf` or use `dnf`.
