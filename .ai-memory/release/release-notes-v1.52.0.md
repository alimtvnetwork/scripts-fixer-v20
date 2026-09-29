## Quick Install v1.52.0

### Windows (PowerShell)

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/alimtvnetwork/scripts-fixer-v20/v1.52.0/install.ps1 -OutFile install.ps1; .\install.ps1 -TargetDir ".ai-memory/prompts" -Version "v1.52.0"
```

### Unix / Linux / macOS (Bash)

```bash
curl -sL https://raw.githubusercontent.com/alimtvnetwork/scripts-fixer-v20/v1.52.0/install.sh | bash -s -- ".ai-memory/prompts" "v1.52.0"
```

---

## What's Changed in v1.52.0

### Added
- add devtool clear, devtools clear, clear devtools, and devtools-cache clear aliases
