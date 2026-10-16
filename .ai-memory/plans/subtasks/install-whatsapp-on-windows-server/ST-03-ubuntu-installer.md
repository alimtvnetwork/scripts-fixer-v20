# ST-03: Ubuntu installer (new script)

## Goal

Create `scripts-linux/49-install-whatsapp/` following `scripts-linux/` fixture conventions.

## Work

1. Study an existing `scripts-linux/` script for structure (e.g. `scripts-linux/01-install-vscode/`).
2. Create the new script directory with:
   - Ubuntu/Debian detection via `/etc/os-release`
   - Primary: flatpak install `io.github.eneshecan.WhatsAppForLinux` (install flatpak if missing)
   - Fallback: download latest `whatsapp-for-linux` .deb from GitHub releases + `dpkg -i`
   - Verification: `flatpak list` or `dpkg -s`
   - Timeouts on all downloads and installs
   - CODE RED: `log_file_error` on every file/path failure with absolute path
3. Follow AGENTS.md: `is*`/`has*` booleans, micro-functions, guard clauses.

## Acceptance

- `bash -n` passes
- Script follows scripts-linux conventions
- All steps have timeouts
