# Subtask 02: Linux (Ubuntu) & Cross-Platform Parity Engine

> **Subtask ID:** `Task-04`  
> **Parent Task:** `task-20261016180011-install-whatsapp-on-windows-server`  
> **Slug:** `install-whatsapp-on-windows-server`  
> **Target Files:**  
> - `scripts-linux/49-install-whatsapp/run.sh`  
> - `scripts-linux/49-install-whatsapp/config.json`  
> - `scripts-linux/49-install-whatsapp/log-messages.json`  
> - `scripts-linux/49-install-whatsapp/manifest.json`  
> - `scripts-linux/49-install-whatsapp/readme.md`  
> - `scripts-linux/run.sh`  

---

## 1. Scope & Technical Deliverable

Create the Unix/Ubuntu install script at `scripts-linux/49-install-whatsapp/run.sh`:
1. Support Ubuntu 20.04, 22.04, 24.04 and Debian.
2. Probe package options:
   - Snap package `whatsapp-for-linux`.
   - Browser PWA launcher wrapper using `google-chrome`, `chromium-browser`, or `brave-browser` with desktop shortcut `~/.local/share/applications/whatsapp.desktop`.
3. Commands: `install` (default), `uninstall`.
4. Strict timeout enforcement on all shell commands.
5. Wire verb `whatsapp` / `49` into `scripts-linux/run.sh`.
6. Conformance to AGENTS.md:
   - Micro-functions (<= 8-15 lines).
   - Strict affirmative booleans (`is*`, `has*`).
   - Strict relative Git paths.
