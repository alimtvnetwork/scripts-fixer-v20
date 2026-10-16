# Subtask 01: Windows Server WhatsApp Installation Engine

> **Subtask ID:** `Task-03`  
> **Parent Task:** `task-20261016180011-install-whatsapp-on-windows-server`  
> **Slug:** `install-whatsapp-on-windows-server`  
> **Target Files:**  
> - `scripts/49-install-whatsapp/run.ps1`  
> - `scripts/49-install-whatsapp/helpers/whatsapp.ps1`  
> - `scripts/49-install-whatsapp/config.json`  
> - `scripts/49-install-whatsapp/log-messages.json`  
> - `scripts/49-install-whatsapp/readme.md`  

---

## 1. Scope & Technical Deliverable

Enhance `scripts/49-install-whatsapp/` to detect Windows Server and provide a resilient native desktop launcher:
1. Detect Windows Server (`isWindowsServer`) using `(Get-CimInstance Win32_OperatingSystem).ProductType -ne 1`.
2. When on Windows Server (or when standard methods fail):
   - Locate available Chromium browser (`chrome.exe` / `msedge.exe`).
   - Create native `%LOCALAPPDATA%\WhatsApp\WhatsApp.exe` launcher wrapper with isolated user data directory `%LOCALAPPDATA%\WhatsApp\User Data`.
   - Create Start Menu shortcut and Desktop shortcut.
   - Register `whatsapp://` URL protocol handler.
   - Enforce strict timeouts on all external process executions (30-60s max watchdog).
3. Ensure uninstallation cleans up all created shortcuts, registry keys, and launcher binaries.
4. Conformance to AGENTS.md:
   - Affirmative booleans only (`is*`, `has*`). Fix existing `$isSuccess = $ok -eq $true` violation.
   - Micro-functions (<= 8-15 lines).
   - Strict relative Git paths.
