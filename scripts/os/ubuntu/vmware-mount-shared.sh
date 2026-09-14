#!/bin/bash
# vmware-mount-shared.sh -- Mount VMware shared folder and ensure Desktop symlink
set -e

PRIMARY='\033[1;32m'
SECONDARY='\033[1;36m'
MUTED='\033[0;37m'
TEXT='\033[0m'

_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_ROOT_DIR="$(cd "$_SCRIPT_DIR/../../.." && pwd)"

if [ -f "$_ROOT_DIR/scripts/shared/db.sh" ]; then
    . "$_ROOT_DIR/scripts/shared/db.sh"
    ensure_db
fi

is_fuse_available() {
    command -v vmhgfs-fuse >/dev/null 2>&1 || [ -x "/usr/bin/vmhgfs-fuse" ]
}

is_already_mounted() {
    if mountpoint -q /mnt/hgfs 2>/dev/null; then
        return 0
    fi

    grep -q "/mnt/hgfs" /proc/mounts 2>/dev/null
}

has_desktop_link() {
    local target="$HOME/Desktop/SharedDirectories"

    if [ -L "$target" ] || [ -d "$target" ]; then
        return 0
    fi

    return 1
}

mount_shared_folders() {
    if is_already_mounted; then
        echo -e "  ${PRIMARY}[  OK  ] VMware shared folders already mounted at /mnt/hgfs.${TEXT}"

        return 0
    fi

    echo -e "  ${SECONDARY}[  ..  ] Mounting VMware shared folders (.host:/ -> /mnt/hgfs)...${TEXT}"
    sudo mkdir -p /mnt/hgfs

    if sudo vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other 2>/dev/null; then
        echo -e "  ${PRIMARY}[  OK  ] Mounted /mnt/hgfs via vmhgfs-fuse.${TEXT}"

        return 0
    fi

    if sudo mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other 2>/dev/null; then
        echo -e "  ${PRIMARY}[  OK  ] Mounted /mnt/hgfs via mount -t fuse.vmhgfs-fuse.${TEXT}"

        return 0
    fi

    echo -e "  ${MUTED}[ INFO ] No active host shares found or virtualization host share disabled.${TEXT}"

    return 0
}

ensure_desktop_symlink() {
    local desktop_dir="$HOME/Desktop"
    local link_path="$desktop_dir/SharedDirectories"

    if has_desktop_link; then
        echo -e "  ${PRIMARY}[  OK  ] Desktop symlink already exists at $link_path.${TEXT}"

        return 0
    fi

    mkdir -p "$desktop_dir"

    if [ -d "/mnt/hgfs" ]; then
        ln -s /mnt/hgfs "$link_path"
        echo -e "  ${PRIMARY}[  OK  ] Created one-time Desktop symlink: $link_path -> /mnt/hgfs${TEXT}"

        return 0
    fi

    return 0
}

main() {
    if ! is_fuse_available; then
        echo -e "  ${MUTED}[ WARN ] vmhgfs-fuse is not installed. Run install-vmware-tools.sh first.${TEXT}"

        return 1
    fi

    mount_shared_folders
    ensure_desktop_symlink
}

main "$@"
