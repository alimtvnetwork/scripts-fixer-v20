#!/bin/bash
set -e

echo -e "  \033[1;36m[  ..  ] Running System Cleanup & Package Maintenance...\033[0m"
sudo apt-get autoremove --purge -y
sudo apt-get clean
sudo apt-get autoclean
sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null || true
if command -v journalctl &>/dev/null; then
    sudo journalctl --vacuum-time=3d 2>/dev/null || true
fi
echo -e "  \033[1;32m[  OK  ] System cleanup completed successfully.\033[0m"
