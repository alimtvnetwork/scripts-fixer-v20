# 22-deep-uninstaller-suite — Visual & UX Guidelines

> **Spec Reference:** [01-overview.md](./01-overview.md)  
> **Status:** active

---

## 1. Console Terminal Aesthetics & Banners

Every uninstaller and clean command outputs standardized, console-safe ASCII glyphs conforming to repository standards (`[OK]`, `[==]`, `[XX]`, `[--]`, `[!!]`). No wide multi-byte emoji that break Windows PowerShell 5.1 console rendering.

### Deep Antigravity Uninstaller Output Banner
```text
  Antigravity Deep Uninstaller (agy-all)
  ======================================
  [  OK  ] Preserved project metadata & conversations:
           -> C:\Users\Administrator\.scripts-fixer\antigravity-projects-backup.json (1 conversation(s))
  [  OK  ] Terminated active Antigravity processes (PID: 1234, 5678)
  [  OK  ] Executed IDE silent uninstaller
  [  OK  ] Purged CLI binaries & PATH references
  [  OK  ] Purged AppData & LocalAppData configuration stores
  [  OK  ] Purged all Gemini brain directories (~/.gemini)
  [  OK  ] Removed Desktop & Start Menu shortcuts
  [  OK  ] Scrubbed Windows Registry uninstall entries
  [  OK  ] Protected workspace invariant verified: d:\work is untouched
  ======================================
  [  OK  ] Antigravity completely removed from machine.
```

### Windows Copilot Uninstaller Output Banner
```text
  Windows Copilot Deep Uninstaller
  ================================
  [  OK  ] Removed AppX Package: Microsoft.Windows.Ai.Copilot.Provider
  [  OK  ] Removed AppX Package: Microsoft.Copilot
  [  OK  ] Set Group Policy: TurnOffWindowsCopilot = 1 (HKCU & HKLM)
  [  OK  ] Disabled Taskbar Copilot button: ShowCopilotButton = 0
  [  OK  ] Disabled Edge sidebar Copilot integration
  ================================
  [  OK  ] Windows Copilot completely removed and disabled.
```

### Microsoft Edge Uninstaller Output Banner (Chris Titus Methodology)
```text
  Microsoft Edge Uninstaller (Chris Titus Methodology)
  ====================================================
  [  OK  ] Terminated Edge processes & update tasks
  [  OK  ] Executed Edge installer silent force-uninstall
  [  OK  ] Disabled EdgeUpdate & EdgeUpdateM services
  [  OK  ] Applied registry block: DoNotUpdateToEdgeWithChromium = 1
  [  OK  ] Removed Edge desktop and taskbar shortcuts
  ====================================================
  [  OK  ] Microsoft Edge browser successfully uninstalled.
```
