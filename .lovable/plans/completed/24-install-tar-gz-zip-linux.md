# Plan 24: Intelligent Linux Archive Installer (.tar.gz, .tar.xz, .tar.bz2, .tar, .zip, .gz)

> **Task ID:** 24  
> **Status:** Completed (100% Green)  
> **Orchestration Workflow:** [V2] Prompt v2.2.0 (Continuous Self-Loop, Budget N=100)  
> **Execution Steps:** Completed across 8 atomic self-loop execution cycles  
> **Initial Prompt:** "add commands to install tar, gz, or zip files in ubuntu, <cli> install tar <zip, tar, gz> # file installation, intelleigent enough to figure out tar, gz files with steps to instal for linux only, please"  
> **Commit SHA:** `a35925e` (v1.41.0)  
> **Target OS:** Ubuntu / Linux Only (Fail-closed on other operating systems)  
> **Dispatcher Commands:**  
> - `./run install tar <path-or-url> [custom-app-name]`  
> - `./run install zip <path-or-url> [custom-app-name]`  
> - `./run install gz <path-or-url> [custom-app-name]`  
> - `./run install archive <path-or-url> [custom-app-name]`  
> - `./run.sh install-tar <path-or-url> [custom-app-name]`  
> - Direct archive detection: `./run install /path/to/archive.tar.gz`

---

## 1. Problem Statement & User Intent
The user requested an intelligent file installation capability for `.tar`, `.gz`, and `.zip` files in Ubuntu/Linux:
```bash
<cli> install tar <zip, tar, gz> # file installation, intelligent enough to figure out tar, gz files with steps to install for linux only, please
```

Key Requirements:
1. **Intelligent Format Detection:** Inspect archives (.tar.gz, .tgz, .tar.xz, .tar.bz2, .tar, .zip, and standalone .gz) using file magic bytes and extensions.
2. **Local & Remote Sources:** Support local file paths (`./file.tar.gz`, `~/file.zip`, `/abs/path`) and remote HTTP/HTTPS URLs.
3. **Smart Unpacking & Staging:** Handle both flat archives (binaries at root) and nested archives (single root subfolder) without directory nesting or pollution.
4. **Binary & GUI Discovery:** Automatically discover the primary executable, apply executable permissions (`chmod +x`), handle Electron `chrome-sandbox`, and create symlinks in `~/.local/bin` and `/usr/local/bin`.
5. **Desktop & Shell Integration:** If a GUI app is detected, install `.desktop` launcher and desktop icon. Automatically verify and add `~/.local/bin` to PATH in `~/.bashrc`, `~/.zshrc`, and `~/.profile`.
6. **Linux Only:** Block execution on non-Linux platforms with clear instructions.
7. **Strict Multi-Point Verification:** Test binary presence, executability, and version output before reporting success.

---

## 2. Target Files
1. `scripts/os/ubuntu/install-archive.sh` (New standalone backend script)
2. `scripts/os/ubuntu/install-tar.sh` (Symlink / alias to `install-archive.sh`)
3. `scripts/run.sh` (CLI dispatcher updates for `tar`, `zip`, `gz`, `archive`, `install-tar`, and help menus)
4. `scripts/shared/list_installs.py` (Add description for ID 81 and archive tools)
5. `scripts/shared/install-keywords.json` (Register archive keywords)
6. `readme.md` & `changelog.md` (Documentation and version bump)

---

## 3. Subtask Breakdown

### Subtask 01: Core Backend Script (`scripts/os/ubuntu/install-archive.sh`)
Implement a 10-step resilient workflow:
- Step 1: Pre-flight checks (Linux OS check, required tools: `tar`, `unzip`, `gzip`, `xz-utils`, `bzip2`, `file`, `curl`/`wget`).
- Step 2: Source resolution (download remote URLs to temporary directory with progress, validate local paths).
- Step 3: Format detection (`file -b --mime-type`, extension checks, `tar -ztf` vs `gzip -t`).
- Step 4: Application name derivation (stripping arch tags, extensions, version numbers; custom name override).
- Step 5: Isolated staging extraction (`/tmp/archive-stage-XXXXXX`).
- Step 6: Layout inspection & atomic transfer to `~/.local/share/<app-name>`.
- Step 7: Binary discovery & permission setting (main executable, SUID / sandbox permissions for Electron).
- Step 8: System & user symlinks (`~/.local/bin/<app-name>` and `/usr/local/bin/<app-name>`).
- Step 9: Desktop launcher & icon generation for GUI apps.
- Step 10: Multi-point verification smoke test.

### Subtask 02: CLI Dispatcher & Argument Parsing (`scripts/run.sh`)
- Add dedicated interceptor at the start of `install)` case for `tar`, `zip`, `gz`, `archive`, `tgz`.
- Ensure archive URLs containing "help" (e.g. `https://example.com/helper/archive.tar.gz`) are NOT caught by help checks.
- Add top-level alias commands: `install-tar`, `install-zip`, `install-archive`.
- Enforce Linux check at dispatcher level.
- Update `show_main_help`, `show_install_help`, and add `show_tar_install_help`.
- Register tool ID `81` for archive installations.

### Subtask 03: System Registration, Helpers & Documentation
- Register ID 81 in `scripts/shared/list_installs.py` and `scripts/shared/install-keywords.json`.
- Update `readme.md` and `changelog.md`.
- Validate syntax with `bash -n` and execute smoke tests.
