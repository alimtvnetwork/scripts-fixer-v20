# Consolidated Plan: Fix Cross-Platform Antigravity Installation (IDE + CLI + Desktop UI)

- **Slug:** `23-fix-antigravity-installer-cross-platform`
- **Status:** `completed`
- **Initial Task Prompt:** "Even not installation not done, but it says installation is done. It is quite funny. I will not find the installation. Uh, please fix it ASAP. Like, it, it looks very terrible. One thing you are trying several times, and it's nowhere near to the installation. So you should figure out for the Windows installation, you should figure out for Ubuntu installation. So currently I was running on Ubuntu, so it should detect the OS, and based on that, it should install the Antigravity. Does this make sense?"
- **Official Google Storage Links Provided:**
  - Linux x64: `https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/linux-x64/Antigravity.tar.gz`
  - Linux ARM: `https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/linux-arm/Antigravity.tar.gz`
  - Windows x64: `https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/windows-x64/Antigravity-x64.exe`
  - Windows ARM: `https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/windows-arm/Antigravity-arm64.exe`
- **Execution Budget:** N = 100 steps
- **Actual Completed Steps:** 18 steps (Planning, dual-agent research, implementation, and verification)

---

## 1. Problem Statement & Root Cause Analysis
Previously, running `./run install antigravity` only placed a headless CLI binary in `~/.antigravity/bin` and printed success without installing the actual Antigravity IDE application, without generating `.desktop` application launchers or Desktop shortcuts, without registering symlinks in `/usr/local/bin`, and without strict post-install verification. Users running the script on Ubuntu or Windows were unable to find Antigravity in their application menus or active shells.

---

## 2. Implemented Changes

### 2.1 Ubuntu / Linux Installation Pipeline (`scripts/os/ubuntu/install-antigravity.sh`)
- **Official Storage Integration:** Downloads official `Antigravity.tar.gz` directly from Google Cloud Storage for `linux-x64` and `linux-arm`, with resilient fallback to the auto-updater API.
- **Full App Extraction:** Extracts full Electron IDE into `$HOME/.local/share/antigravity` (with legacy symlink at `$HOME/.local/share/antigravity-ide`).
- **CLI Binary Symlinks:** Creates system-wide symlinks in `/usr/local/bin/antigravity` and `/usr/local/bin/agy` (via sudo or user-writable fallback) as well as `$HOME/.local/bin` and `$HOME/.antigravity/bin`, guaranteeing instant shell availability without restarting.
- **Desktop Application Launcher:** Generates standard `.desktop` files in `$HOME/.local/share/applications/antigravity.desktop`, `/usr/share/applications/`, and `$HOME/Desktop/antigravity.desktop` (marked trusted via `gio` where available), and triggers `update-desktop-database`.
- **Strict Verification:** Performs binary existence, executability, and smoke test checks. Fails closed with `exit 1` if verification fails.

### 2.2 Suite Profile & Dispatch Harmonization (`profile-ubuntu-antigravity-suite.sh` & `scripts/run.sh`)
- **Suite Profile:** Sequentially installs both Antigravity Manager GUI (`install-antigravity-manager.sh`) and Antigravity IDE+CLI (`install-antigravity.sh`).
- **Run Dispatcher:** Harmonizes help tables to list ID `69` for Antigravity and `68` for Antigravity Manager. Supports `antigravity`, `agy`, `ag`, `43`, and `69` aliases.
- **Post-Dispatch Verification Gate:** In `scripts/run.sh`, validates binary existence in standard paths before adding to `INSTALLED` and logging to SQLite.

### 2.3 Windows Installation Pipeline (`scripts/69-install-antigravity/run.ps1`)
- **Cross-Platform Detection:** Automatically detects Linux/macOS environments and forwards to `install-antigravity.sh`.
- **Official Storage Package:** Downloads `Antigravity-x64.exe` / `Antigravity-arm64.exe` from official Google Storage and runs silent NSIS setup (`/S`) with Inno fallback (`/VERYSILENT /MERGETASKS=!runcode /NORESTART`).
- **CLI Companion:** Unpacks `antigravity.exe` and `agy.exe` into `$env:USERPROFILE\.antigravity\bin`.
- **Shortcuts & Environment:** Generates Desktop and Start Menu `.lnk` shortcuts, updates User and process PATH, and broadcasts `WM_SETTINGCHANGE`.
- **Uninstallation Routine:** Fully supports `uninstall` argument, terminating processes, invoking the uninstaller, wiping shortcuts, and cleaning PATH.

---

## 3. Verification & Validation
- Syntax check on `scripts/os/ubuntu/install-antigravity.sh`: **PASS** (`bash -n` exit 0).
- Syntax check on `scripts/os/ubuntu/profile-ubuntu-antigravity-suite.sh`: **PASS** (`bash -n` exit 0).
- Syntax check on `scripts/run.sh`: **PASS** (`bash -n` exit 0).
- Syntax check on `scripts/69-install-antigravity/run.ps1`: **PASS** (AST Parser exit 0).
- Version bumped to `v1.40.0` across `scripts/version.json`, `readme.md`, and `changelog.md`.
