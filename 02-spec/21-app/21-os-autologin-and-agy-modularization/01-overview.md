# Specification 21: OS Auto-Login Integration & AGY Commands Modularization — Overview

> **Spec ID:** 21-app/01-overview  
> **Status:** `active`  
> **Target Subsystems:** `scripts/os`, `scripts-linux/68-user-mgmt`, `scripts/69-install-antigravity/helpers/agy_optimizer/`, `scripts-linux/69-install-antigravity/helpers/agy_optimizer/`  

---

## 1. User Request (Verbatim)

```text
Can you please follow the Git map? Also do a Git pull first. So Git map has an auto login functionality that will allow us to log in or set up auto login that would allow the user to log in automatically to the Windows. Then we will do other parts. Can you integrate something for the Windows Server, Windows 11, and Ubuntu machine for now in your brand code? And also, I do see that the AGY commands are in Python, and that's really big one file. Can you please break it down and put a small folder, and inside this you break it down to shared Python code where most of the engine code would go, and then rest of the code you break it down to smaller files, like 100 lines. And then you also test those Python codes to check if it is working or not. Can you please do that for me?
```

---

## 2. System Context & Architectural Goals

This specification defines two primary capabilities integrated into the repository:

1. **Cross-Platform OS Auto-Login Subsystem:**
   - Seamlessly integrates auto-login management into repository tools (`scripts/os/run.ps1`, `scripts/os/helpers/autologin.ps1`, `scripts-linux/68-user-mgmt/autologin.sh`, and root dispatchers).
   - Supports **Windows 11**: Configures `AutoAdminLogon`, `DefaultUserName`, `DefaultDomainName`, `DefaultPassword` in `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon`, and sets `DevicePasswordLessBuildVersion = 0` under `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device` to unlock passwordless accounts.
   - Supports **Windows Server**: Configures `AutoAdminLogon`, sets `ForceAutoLogon = 1`, and configures `DisableCAD = 1` under Winlogon and system policies to bypass Ctrl+Alt+Del lockscreens.
   - Supports **Ubuntu (Desktop & Server)**: Configures GDM3 (`/etc/gdm3/custom.conf`), LightDM (`/etc/lightdm/lightdm.conf.d/50-autologin.conf`), and systemd getty console auto-login (`/etc/systemd/system/getty@tty1.service.d/override.conf`) for headless servers.
   - Bridges with `gitmap os autologin` when available while remaining 100% functional standalone.

2. **AGY Optimizer Python Modularization:**
   - Decomposes monolithic `agy_optimizer.py` (882 lines) into a clean, modular Python package located in `scripts/69-install-antigravity/helpers/agy_optimizer/` and mirrored in `scripts-linux/69-install-antigravity/helpers/agy_optimizer/`.
   - Core engine logic is centralized in shared modules (`shared/` or `core/`).
   - Every file is bounded to **<= 100 lines** with micro-functions targeting **<= 8-15 lines**.
   - Preserves `agy_optimizer.py` root shim for backward compatibility with existing PowerShell/Bash callers.
   - Comprehensive unit verification tests testing all modular Python functions and CLI flows.
