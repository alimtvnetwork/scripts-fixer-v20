## Quick Install v1.54.0

### Windows (PowerShell)

```powershell
Invoke-WebRequest -Uri https://raw.githubusercontent.com/alimtvnetwork/scripts-fixer-v20/v1.54.0/install.ps1 -OutFile install.ps1; .\install.ps1 -TargetDir ".ai-memory/prompts" -Version "v1.54.0"
```

### Unix / Linux / macOS (Bash)

```bash
curl -sL https://raw.githubusercontent.com/alimtvnetwork/scripts-fixer-v20/v1.54.0/install.sh | bash -s -- ".ai-memory/prompts" "v1.54.0"
```

---

## What's Changed in v1.54.0

### Added
- Cross-platform machine identity & IP inspection (`machine`, `alias`, `ip`) with GitMap Go parity.
- Cross-platform terminal history & suggestion cleaner (`clear terminal`, `clear-terminal`) across PowerShell (PSReadLine), Bash, Zsh, and Sh.
- GitMap suggestion reseeding engine (17 canonical commands) and automatic tab-completion hook setup.
- Global update to coding-guidelines-v24 across all documentation, remote installers, and SHA256 integrity verifications.
