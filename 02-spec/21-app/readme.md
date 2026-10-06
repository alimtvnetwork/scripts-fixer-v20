# 21-app Specification Index

| Spec ID | Name | Status | Description |
|---|---|---|---|
| 20 | [20-agy-cache-clear-and-dev-clean.md](./20-agy-cache-clear-and-dev-clean.md) | `active` | Antigravity cache clear short flag -k<N>, summary at bottom, colorful UI, cross-OS parity, and dev-clean integration |
| 21 | [21-os-autologin-and-agy-modularization](./21-os-autologin-and-agy-modularization/01-overview.md) | `active` | Cross-OS auto-login for Windows Server, Windows 11, and Ubuntu, plus AGY Python modularization with shared engine |
| 22 | [22-deep-uninstaller-suite](./22-deep-uninstaller-suite/01-overview.md) | `active` | Antigravity deep uninstaller with project/conversation state backup, AGM uninstaller, Windows Copilot purge, Chris Titus Edge removal, and enhanced dev-clean |
| 23 | [23-vmware-codex-claude-ui](./23-vmware-codex-claude-ui/01-vmware-installer-spec.md) | `active` | VMware installation improvements (Windows & Linux) and cross-platform Codex UI & Claude Code Desktop UI |
| 24 | [24-vmware-clear-help-codex-plot](./24-vmware-clear-help-codex-plot/01-clear-and-help-routing-spec.md) | `active` | VMware host verification, clear commands harmonization, GitMap subcommand help, and Codex/Plot UI release v1.56.0 |

## Commands

| Command | Description |
|---|---|
| `.\run.ps1 devtools clear` | Clean up developer tools cache across registered ecosystems |
| `.\run.ps1 clear devtools` | Alias to clean developer tools cache |
| `.\run.ps1 devtools-cache clear` | Alias to clear devtools cache |

## Flags

| Flag | Type | Description |
|---|---|---|
| `-DryRun` / `--dry-run` | switch | Preview items and sizes that would be removed without deleting |
| `-Force` / `-f` | switch | Skip confirmation prompts and remove caches directly |
| `-Help` / `-h` | switch | Display usage and help information |

## Exit Codes

| Code | Meaning |
|---|---|
| `0` | Success - operation completed without error |
| `1` | Failure - error encountered during execution |

## Verification

Run the test suite or dry-run checks:
```powershell
.\run.ps1 devtools clear --dry-run
node tools/spec-lint.cjs
```
