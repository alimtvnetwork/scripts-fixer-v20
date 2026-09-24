# Specification 21: OS Auto-Login Integration & AGY Commands Modularization — Visual & UX

> **Spec ID:** 21-app/03-visual-and-ux  
> **Status:** `active`  

---

## 1. Auto-Login Terminal UX

### 1.1 Status Display (`.\run.ps1 os autologin status`)

```text
▶ OS Auto-Login Status
  • Target OS:        Windows 11 (build 26100)
  • Enabled:          true
  • Username:         Administrator
  • Domain:           .
  • Password Stored:  true
  • Display Manager:  Winlogon
  • Win11 Passwordless Unlocked: true (DevicePasswordLessBuildVersion = 0)
```

### 1.2 Enable Confirmation (`.\run.ps1 os autologin enable -u dev -p pass123`)

```text
✔ OS Auto-Login configured successfully:
  • User:   dev
  • Domain: .
  • Status: Enabled on next system reboot
```

---

## 2. AGY Modular Engine Terminal Output

When executing `agy_optimizer.py` (or `python -m agy_optimizer`), the output maintains exact visual parity with the canonical format:
- Clear header box with Cyan formatting
- Grouped sections for Heavy Conversations, Electron/GPU Caches, and Gemini Brain targets
- Space reclamation summary box positioned cleanly at the end
- Rollback tips and interactive examples
