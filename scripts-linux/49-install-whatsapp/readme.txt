49-install-whatsapp
===================

Installs WhatsApp for Linux (unofficial) on Ubuntu/Debian.
Resolution:
  1. flatpak install from flathub (installs flatpak first if missing)
  2. latest wasistlos_*.deb from github.com/eneshecan/whatsapp-for-linux + dpkg -i (fallback)

Every download and install step enforces a timeout
(downloadSeconds/installSeconds in config.json).

Verify: flatpak list | grep -i whatsapp  OR  dpkg -s wasistlos
