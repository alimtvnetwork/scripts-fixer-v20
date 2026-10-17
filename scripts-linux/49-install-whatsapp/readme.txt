49-install-whatsapp
===================

Installs WhatsApp Desktop for Linux on Ubuntu/Debian.
Resolution:
  1. snap install whatsapp-for-linux (Tier 1 preferred)
  2. flatpak install from flathub (Tier 2, installs flatpak if missing)
  3. latest amd64 .deb from github.com/eneshecan/whatsapp-for-linux + dpkg -i (Tier 3 fallback)
  4. PWA desktop wrapper via Chrome/Chromium/Brave (Tier 4 fallback)

Every download and install step enforces a timeout
(downloadSeconds/installSeconds in config.json).

Verify: snap list whatsapp-for-linux | flatpak list | dpkg -s wasistlos | test -x ~/.local/bin/whatsapp
