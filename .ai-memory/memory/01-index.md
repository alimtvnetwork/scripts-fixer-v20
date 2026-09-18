# Master Memory Index: 01-index.md

> **Updated:** 2026-09-09  
> **Scope:** Repository-wide institutional memory and architectural decisions

---

## Core Knowledge & Conventions

1. **Project Architecture**: PowerShell utility scripts (Windows, `scripts/`) alongside Linux/macOS bash scripts (`scripts-linux/`) and the React dashboard (`src/`).
2. **CODE RED (Error Management)**: Every file/path error MUST log exact file path + failure reason. Use `Write-FileError` (PowerShell) / `log_file_error` (Bash).
3. **CODE RED (Install Paths)**: Every install/extract/repair/sync logs Source + Temp + Target via `Write-InstallPaths` from `scripts/shared/install-paths.ps1`.
4. **Dev Directory Naming**: Default dev directory is ALWAYS `dev-tool` (hyphenated) everywhere — code, help text, JSON, specs, memory. Never `devtool`/`devtools`/`dev_tool`.
5. **Root readme.md Installation Section**: 4 labeled remote one-liner blocks ONLY (Windows plain, Windows skip-probe, Bash plain, Bash skip-probe). NO local `.\install.ps1` or `bash ./install.sh` commands.
6. **Strictly Prohibited (SP-1..SP-6)**: Never write or suggest date/time/timestamp content in ANY `readme.txt`; never suggest "git update time" or auto-timestamp automation anywhere.
7. **Nginx Domain Manager & Tri-State Sync**: Zero-dependency SQLite persistence (`sqlite3` CLI + `python3` / `sqlite-bridge.py` fallback), bidirectional INI sync (`domains.ini` on Windows, per-site `/etc/nginx/sites.d/<domain>.ini` and master `/etc/nginx/sites.ini` on Linux), and modular syntax-validated virtual hosts (`conf.d/*.conf`, `sites-available/`).

---

## Master Memory Catalog

### 1. Active Directives & Sessions
- [01-nginx-domain-manager-sqlite](01-nginx-domain-manager-sqlite.md) — Session capture: Nginx Domain Manager, SQLite ledger, INI sync showcase, and CLI grammar.

### 2. Workflow State & Release Architecture
- [01-current-status](workflow/01-current-status.md) — Real-time workflow state, completed milestones, and pending roadmaps.
- [release-architecture-map](release-architecture-map.md) — Release architecture, versioning rules, and line ending standards.

### 3. Learned Knowledge & Architecture
- [01-execute-batched-loop](learned/01-execute-batched-loop.md) — Multi-agent orchestration, locking matrix, and artifact sanitation.
- [02-execute-batched-loop-k8s](learned/02-execute-batched-loop-k8s.md) — Kubernetes orchestration and batched task tracking.
- [03-nginx-domain-manager-sqlite-ini](learned/03-nginx-domain-manager-sqlite-ini.md) — Permanent institutional knowledge: Nginx Domain Manager, SQLite persistence, BOM decoding, and INI synchronization.
- [04-windows-git-unlink-acl-resolution](learned/04-windows-git-unlink-acl-resolution.md) — Windows Git unlink permission ACL resolution pattern.
- [05-project-context-and-subsystems](learned/05-project-context-and-subsystems.md) — Subsystem contracts, split DB conventions, and recent commit history.

### 4. Constraints & Prohibitions
- [Strictly prohibited (SP-N HARD STOP)](constraints/strictly-prohibited.md) — Numbered hard-stop rules; load on first read, refuse triggering requests with rule number cited.
- [Terminal banners](constraints/terminal-banners.md) — Avoid em dashes and wide Unicode in box-drawing banners.
- [Code Quality Overhaul](constraints/code-quality-overhaul.md) — Requirements for Enums (Type suffix), explicit isFail booleans, query wrappers, and removing magic strings.

### 5. Preferences & Naming Conventions
- [Script structure](preferences/script-structure.md) — How the user wants scripts organized with configs, specs, and suggestions.
- [Naming conventions](preferences/naming-conventions.md) — is/has prefix for booleans; avoid bare -not checks.
- [Dev directory naming](preferences/dev-dir-naming.md) — Default dev dir is always `dev-tool` (hyphenated) in all code/docs/help text.
- [Subdispatcher help flags](preferences/subdispatcher-help-flags.md) — All subdispatchers (os/profile/models/...) accept help/--help/-help/-h/?/empty; root forwards -h/-Help when no subaction given.

### 6. Features & Tooling
- [Error management file path rule](features/error-management-file-path-rule.md) — CODE RED: every file/path error must include exact path and failure reason.
- [Install-paths trio](features/install-paths-trio.md) — CODE RED: Source + Temp + Target logged via Write-InstallPaths on every install.
- [Database scripts](features/database-scripts.md) — Database installer script patterns.
- [Installed tracking](features/installed-tracking.md) — `.installed/` tracking system.
- [Interactive menu](features/interactive-menu.md) — Interactive menu system for script 12.
- [Logging](features/logging.md) — Structured JSON logging system.
- [Notepad++ settings](features/notepadpp-settings.md) — 3-variant NPP install modes with settings zip.
- [Questionnaire](features/questionnaire.md) — Questionnaire system for script 12.
- [Resolved folder](features/resolved-folder.md) — `.resolved/` runtime state persistence.
- [Shared helpers](features/shared-helpers.md) — Shared PowerShell helper modules.
- [Script 68 SSH key rollback](features/17-script-68-ssh-key-rollback.md) — Manifest-based per-run SSH key rollback.
- [Script 68 macOS perms](features/18-script-68-macos-perms.md) — createhomedir + numeric-gid chown for macOS user creation.
- [Change-port + DNS toolkit](features/19-change-port-and-dns.md) — Root-level change-port.sh / install-dns.sh dispatchers (v0.175.0).
- [Release v1.2.4](features/release-v1.2.4.md) — Pinned 2026-06-19: chrome-profile-copy suite (Win+Linux), taskbar-align-left, smoke tests.
- [Script 68 shared schema validator](features/script-68-shared-schema.md) — helpers/_schema.sh deduplicates strict JSON validation across all four *-from-json.sh leaves.
- [Windows user-mgmt shared helpers](features/windows-user-mgmt-shared-helpers.md) — Invoke-UserModify/Delete/PurgeHome in scripts/os/helpers/_common.ps1.
- [Windows schema validator](features/windows-schema-validator.md) — _schema.ps1 mirrors bash _schema.sh rule DSL + TSV contract for cross-OS JSON loaders.
- [Choco runner hardening](features/choco-runner-hardening.md) — v0.238–v0.242 layered fix for false [ FAIL ]: log filter, structured parser, no-op detection.
- [Install self-relocation](features/install-self-relocation.md) — install.ps1/.sh detection cases (cwd-is-target / sibling / safe / fallback).
- [Install bootstrap](features/install-bootstrap.md) — Auto-discovery, version reporting, and root-cause rule: derive current vN from repo slug only.
- [Default apps cross-OS](features/default-apps-cross-os.md) — `os browser` / `os email` set default web browser + mail client on Windows, Linux, and macOS.
- [Right-click verification helper](features/rightclick-verification.md) — scripts/shared/interactive-verify.ps1 prompts user to test right-click menus.
- [Write-Log bulletproof contract](features/write-log-bulletproof.md) — scripts/shared/logging.ps1 Write-Log wrapped in outer try/catch.
- [Universal context menu](features/universal-context-menu.md) — Cross-OS right-click spec (spec/55).
- [Fast download helper](features/fast-download.md) — Shared aria2c wrapper (Win+Linux).
- [Models dispatcher $Args→$Rest rename](features/models-args-rename.md) — CODE RED: `$Args` is a PowerShell automatic.
- [Reset command](features/reset-command.md) — `reset` verb on Windows + Linux wipes .logs/, .resolved/, .installed/ for fresh start.
- [Download URL logging](features/download-url-logging.md) — CODE RED extension: every model-download failure path logs upstream URL + target.
- [Ollama standalone registry pull](features/ollama-registry-direct-pull.md) — Direct registry.ollama.ai blob+manifest pull.
- [llama.cpp prebuilt (Linux)](features/llama-cpp-prebuilt.md) — Script 43 downloads pinned prebuilt tarball.
- [Download progress bar](features/download-progress-bar.md) — Winget-style colour-graduated in-place bar.
- [Per-tool min free GB](features/per-tool-min-free-gb.md) — Smart picker auto-falls-back to largest-free drive.

---

## CI/CD Ledger
See `.ai-memory/cicd-index.md` for the CI/CD issue ledger (workflows + open items).
