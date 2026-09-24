# Specification 21: OS Auto-Login Integration & AGY Commands Modularization — Data Contracts

> **Spec ID:** 21-app/02-data-contracts  
> **Status:** `active`  

---

## 1. Auto-Login Data Contracts

### 1.1 Status Envelope (JSON & Terminal)

Both PowerShell and Bash auto-login implementations support `--json` and human-readable terminal output.

```json
{
  "is_enabled": true,
  "username": "administrator",
  "domain": ".",
  "has_password": true,
  "os_flavor": "windows_11",
  "display_manager": "Winlogon",
  "is_server_cad_disabled": true,
  "is_passwordless_unlocked": true
}
```

### 1.2 CLI Arguments Schema

| Flag / Param | Type | Default | Description |
|---|---|---|---|
| `command` | string (`status`, `enable`, `disable`) | `status` | Action verb |
| `-u`, `--user`, `--username` | string | Current user | Target username to log in automatically |
| `-p`, `--password`, `-Password` | string | `""` | Password for the auto-login account |
| `-d`, `--domain`, `-Domain` | string | `.` | Local computer or domain name |
| `--server` | switch | Auto-detect | Explicit Windows Server flag (ForceAutoLogon, DisableCAD) |
| `--win11` | switch | Auto-detect | Explicit Windows 11 flag (DevicePasswordLessBuildVersion = 0) |
| `--dry-run` | switch | `false` | Inspect planned registry or configuration mutations without writing |
| `--json` | switch | `false` | Emit JSON status envelope |

---

## 2. AGY Python Package Contracts

### 2.1 Package Architecture

```text
scripts/69-install-antigravity/helpers/agy_optimizer/
├── __init__.py           # Package exports & public API facade
├── models.py             # Data classes (ConversationInfo, BrainCleanupItem) & ANSI styling
├── shared/
│   ├── __init__.py
│   ├── paths.py          # Cross-platform cache, home, and backup paths
│   └── database.py       # SQLite backup schema, transactions & rollbacks
├── scanner.py            # Conversation and disk asset discovery engine
├── pruner.py             # Conversation step pruner & brain artifact archiver
├── predictor.py          # Reclamation analytics & tabular projection formatter
├── applier.py            # Execution coordinator & cleanup applier
└── cli.py                # Command-line argument parser & entrypoint dispatch
```

### 2.2 Sizing Contract (Strict <= 100 Lines per File)

Every file in `agy_optimizer/` must strictly contain **<= 100 lines** and micro-functions targeting **<= 8-15 lines**.
No file shall exceed 100 lines. All boolean variables must adhere to `is*` and `has*` positive prefixes.
