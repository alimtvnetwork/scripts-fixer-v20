## Quick Install v1.55.0

### Windows (PowerShell)

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/alimtvnetwork/scripts-fixer-v20/v1.55.0/install.ps1 -OutFile install.ps1; .\install.ps1 -TargetDir ".ai-memory/prompts" -Version "v1.55.0"
```

### Unix / Linux / macOS (Bash)

```bash
curl -sL https://raw.githubusercontent.com/alimtvnetwork/scripts-fixer-v20/v1.55.0/install.sh | bash -s -- ".ai-memory/prompts" "v1.55.0"
```

---

## What's Changed in v1.55.0

### Added
- Complete POSIX Shell command parity (`scripts/run.sh` and `scripts-linux/run.sh`) matching PowerShell dispatchers for `machine`, `ip`, `clear-terminal`, `clear terminal`, and `clean-dev` / `dev-clean`.
- Modularized PowerShell root help system: decomposed monolithic `root-help.ps1` into 30 modular sub-files in `scripts/dispatcher/help/` (strictly <= 100 lines each).
- Dynamic keyword search filtering for Shell runner (`./run.sh help <keyword>`).
- Dedicated Shell help categories for Machine Identity, Terminal History Cleaner, and Developer Tools Cleanup.
- Pester test suite expansion covering cross-platform shell script dispatching and dry-run execution.
