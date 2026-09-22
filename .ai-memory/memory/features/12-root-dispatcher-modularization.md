# Root Dispatcher Modularization Architecture

> **Version:** 1.0.0  
> **Status:** Authoritative Architecture Reference  
> **Updated:** 2026-09-22

---

## 1. Problem & Rationale
The repository's root entry point, `run.ps1`, had expanded over time to 5,814 lines. It contained sprawling, mixed responsibilities:
- Command dispatching and normalization
- Script execution orchestration (`Invoke-ScriptById`)
- Subsystem help rendering (`Show-RootHelp`, `Show-KeywordTable`)
- Fuzzy keyword resolution (`Resolve-InstallKeywords`, `Get-LevenshteinDistance`)
- Doctor and diagnostic checks (`Invoke-DoctorCommand`, `Invoke-DoctorSelfCheck`)
- Installation status and package export/import (`Invoke-StatusCommand`, `Invoke-ExportCommand`)
- Path configuration (`Invoke-PathCommand`)
- Interactive help search REPL (`Invoke-EarlyHelpIntercept`)

This large file size made navigation, isolated testing, and code quality audits difficult.

---

## 2. Decomposition Architecture
All utility functions, subsystem handlers, and interactive loops were decomposed into dedicated single-responsibility scripts located in `scripts/dispatcher/`:

```
scripts/dispatcher/
├── script-runner.ps1     # Core execution, versioning, and package update orchestration
├── root-help.ps1         # Full and filtered help display, keyword tables, and formatters
├── keyword-resolver.ps1  # Keyword parsing, fuzzy matching, and Levenshtein distance
├── status-export.ps1     # Status dashboard, config export/import, and installation tracking
├── doctor-cmd.ps1        # Self-checks, dependency validation, and registry verification
├── path-cmd.ps1          # Dev directory configuration, smart detection, and reset logic
└── early-help.ps1        # Early intercept, output formatting, and interactive help REPL
```

### Module Responsibilities:

| Module | Line Size | Key Functions | Responsibility |
|---|---|---|---|
| `script-runner.ps1` | ~390 lines | `Get-ScriptVersion`, `Show-VersionHeader`, `Show-VersionFooter`, `Get-InstalledTag`, `Get-VersionMap`, `Invoke-ScriptById`, `Invoke-ChocoUpdateCommand` | Manages version display, script lookup by ID, child script delegation, and package update commands. |
| `root-help.ps1` | ~1,070 lines | `Show-RootHelpRaw`, `Show-RootHelp`, `Show-KeywordTable` | Formats and outputs root help, category listings, and keyword tables with syntax coloring and filtering. |
| `keyword-resolver.ps1` | ~380 lines | `Get-LevenshteinDistance`, `Get-DidYouMean`, `Resolve-InstallKeywords` | Resolves user keywords to script IDs, supports fuzzy matching for typos, and maps combos. |
| `status-export.ps1` | ~290 lines | `Invoke-ExportConfigCommand`, `Invoke-ImportConfigCommand`, `Copy-Config`, `Invoke-ExportCommand`, `Invoke-StatusCommand`, `Write-StatusGroup` | Checks installed tools across package managers (Choco, Winget, Pip, NPM) and imports/exports configs. |
| `doctor-cmd.ps1` | ~600 lines | `Invoke-DoctorCommand`, `Write-Check`, `Invoke-DoctorSelfCheck`, `Write-SCRow`, `Write-SCHeader` | Performs self-checks across registry, script files, keyword mappings, and SHA-256 hashes. |
| `path-cmd.ps1` | ~65 lines | `Invoke-PathCommand` | Manages and sets persistent dev directory target paths. |
| `early-help.ps1` | ~460 lines | `_Parse-HelpOutFlags`, `_Read-HelpKeywordLine`, `_Save-LastKeyword`, `Invoke-EarlyHelpIntercept` | Intercepts help invocations early before git pull/argument normalization and provides interactive search REPL. |

---

## 3. Integration into `run.ps1`
In `run.ps1`, lines 171–3518 were replaced with clean, deterministic dot-sourcing in caller scope:

```powershell
# ── Modular Dispatcher Subsystems ────────────────────────────────────
$dispatcherDir = Join-Path $RootDir "scripts\dispatcher"
. (Join-Path $dispatcherDir "script-runner.ps1")
. (Join-Path $dispatcherDir "root-help.ps1")
. (Join-Path $dispatcherDir "keyword-resolver.ps1")
. (Join-Path $dispatcherDir "status-export.ps1")
. (Join-Path $dispatcherDir "doctor-cmd.ps1")
. (Join-Path $dispatcherDir "path-cmd.ps1")
. (Join-Path $dispatcherDir "early-help.ps1")

Invoke-EarlyHelpIntercept -Command $Command -Install $Install -Help:$Help -h:$h -I $I
```

### Key Technical Considerations:
1. **Dot-Sourcing (`.`):** Functions run directly in the caller's script scope, retaining access to `$RootDir`, theme variables (`$ThemePrimary`, etc.), and script parameters without polluting global state.
2. **Reduced Line Count:** `run.ps1` was reduced from **5,814 lines to 2,477 lines** (57.4% reduction), retaining only argument binding, git pull gating, and command normalization branches.
3. **Preserved Intercept Semantics:** `Invoke-EarlyHelpIntercept` handles all early help patterns and exits cleanly with `exit 0` when help is requested, or returns immediately when normal command execution is expected.

---

## 4. Verification Protocol
Every modular component and the root dispatcher were validated:
1. **AST Parser Syntax Check:** PowerShell parser confirmed 0 parse errors across `run.ps1` and all 7 extracted files.
2. **Help Subsystem:** Verified `.\run.ps1 -Help` and `.\run.ps1 help chrome`.
3. **Path Subsystem:** Verified `.\run.ps1 path`.
4. **Status Dashboard:** Verified `.\run.ps1 status` across tracked tools.
5. **Doctor Self-Check:** Verified `.\run.ps1 doctor --self-check` over 600 registry and keyword assertions.
6. **Subdispatcher Routing:** Verified `.\run.ps1 agy check` for Antigravity integration.
