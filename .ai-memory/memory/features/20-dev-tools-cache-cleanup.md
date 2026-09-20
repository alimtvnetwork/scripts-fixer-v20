# Developer Tools Cache Cleanup: os dev-cleanup / clean-dev

> **Status:** Authoritative Feature Specification & Implementation Record  
> **Command:** `.\run.ps1 clean-dev` / `.\run.ps1 os dev-cleanup` / `./run.sh clean-dev`  
> **Module:** `scripts/os/helpers/dev-clean.ps1`, `scripts/os/helpers/clean-categories/`

---

## 1. Problem Statement & Motivation
Developers working on Windows and cross-platform polyglot stacks accumulate massive build caches and package archives:
- **Go**: `go build` caches and module downloads (`pkg/mod`) routinely exceed 10+ GB with >100,000 files. Crucially, Go flags all downloaded module files as Read-Only (`[System.IO.FileAttributes]::ReadOnly`), causing standard file removal to fail with `UnauthorizedAccessException`.
- **pnpm**: Global content-addressable store (`pnpm/store`) and custom `dev-tool\pnpm\store` directories grow indefinitely without pruning.
- **npm**: Cache archives in `%LOCALAPPDATA%\npm-cache` and `~/.npm`.
- **Chocolatey**: Package installer download archives in `%LOCALAPPDATA%\Chocolatey\Cache`, `%ProgramData%\chocolatey\cache`, and `%TEMP%\chocolatey`.
- **Other Package Managers**: Yarn, Bun, Python/pip, Cargo/Rust, Gradle, Maven, and .NET/NuGet.

Prior to this feature, cleaning these required manual discovery or running individual tools one by one.

---

## 2. Solution Architecture

### 2.1 Top-Level & OS Dispatcher
- Accessible via top-level command: `.\run.ps1 clean-dev` (aliases: `dev-cleanup`, `cleandev`, `devcleanup`, `dev-clean`).
- Accessible via OS dispatcher: `.\run.ps1 os dev-cleanup` or `.\run.ps1 os clean-dev`.
- Supports `--dry-run` to preview freed bytes without altering disk contents.
- Supports `--yes` / `-y` to run non-interactively.

### 2.2 Dedicated Orchestrator: `scripts/os/helpers/dev-clean.ps1`
Runs a 10-step developer cache sweep:
1. **Go**: `go clean -cache -modcache -testcache -fuzzcache` + disk sweeps across `GOCACHE`, `GOMODCACHE`, `%USERPROFILE%\go\pkg\mod`, and `$env:DEV_DIR\go\pkg\mod` (`C:\dev-tool\go\pkg\mod`). Strips read-only attributes before removal.
2. **pnpm**: `pnpm store prune` + disk sweeps across `%LOCALAPPDATA%\pnpm\store`, `~/.pnpm-store`, `$env:DEV_DIR\pnpm\store`, and `C:\dev-tool\pnpm`.
3. **npm**: `npm cache clean --force` + directory sweep.
4. **Chocolatey**: `choco cache clean -y` + directory sweep across `%LOCALAPPDATA%\Chocolatey\Cache`, `%ProgramData%\chocolatey\cache`, and `%TEMP%\chocolatey`.
5. **Yarn**: `yarn cache clean` + directory sweep.
6. **Bun**: `bun pm cache rm` + directory sweep.
7. **Python / pip**: `pip cache purge` + directory sweep.
8. **Cargo / Rust**: `~/.cargo/registry/cache` + `~/.cargo/git/checkouts`.
9. **Gradle**: `~/.gradle/caches`.
10. **Maven**: `~/.m2/repository`.
11. **.NET / NuGet**: `dotnet nuget locals all --clear` + `%LOCALAPPDATA%\NuGet\v3-cache`.

### 2.3 StrictMode & Quality Defenses
- **StrictMode Sum Safety**: When `Measure-Object -Property Length -Sum` measures an empty collection, PowerShell under `Set-StrictMode` does not populate `.Sum`. `scripts/os/helpers/clean-categories/_sweep.ps1` guards `.Sum` access behind `$files.Count -gt 0`.
- **Parameter Collision Defense**: Script-level switch parameter `$a` in `run.ps1` must never be used as a loop variable (`foreach ($item in $Install)`).
- **Subcommand Integrity**: `run.ps1` maintains an explicit `elseif ($isBareDoctorCommand)` branch so diagnostic commands run directly rather than falling through to unknown keywords.

### 2.4 Cross-Platform Parity
- `scripts-linux/run.sh`: Added `clean-dev` / `dev-cleanup` top-level shortcut targeting `pkg-npm,pkg-pnpm,pkg-bun,pkg-yarn,pkg-pip,pkg-go,pkg-cargo`.
- `scripts-linux/65-os-clean/config.json`: Added `pkg-go` and `pkg-cargo` categories.
