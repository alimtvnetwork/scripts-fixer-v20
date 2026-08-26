import os
import re

run_ps1 = "run.ps1"
with open(run_ps1, "r", encoding="utf-8") as f:
    content = f.read()

# Update run.ps1 Show-VersionFooter logic
replacement = """    $sha    = "unknown"
    $branch = "unknown"
    $remote = $null
    $time   = "unknown"
    try {
        Push-Location $RootDir
        $hasGit = Get-Command git -ErrorAction SilentlyContinue
        if ($hasGit) {
            $s = (& git rev-parse --short=12 HEAD 2>$null) | Select-Object -First 1
            if ($s) { $sha = "$s".Trim() }
            $b = (& git rev-parse --abbrev-ref HEAD 2>$null) | Select-Object -First 1
            if ($b) { $branch = "$b".Trim() }
            $r = (& git config --get remote.origin.url 2>$null) | Select-Object -First 1
            if ($r) { $remote = "$r".Trim() }
            $t = (& git log -1 --format=%cd --date=local 2>$null) | Select-Object -First 1
            if ($t) { $time = "$t".Trim() }
        }
    } catch {} finally { Pop-Location -ErrorAction SilentlyContinue }

    Write-Host ""
    Write-Host "  scripts-fixer v$ver" -ForegroundColor Magenta -NoNewline
    Write-Host " | " -ForegroundColor DarkGray -NoNewline
    Write-Host "git $sha ($branch)" -ForegroundColor Cyan -NoNewline
    Write-Host " | " -ForegroundColor DarkGray -NoNewline
    Write-Host "$time" -ForegroundColor Yellow
    if ($remote) {
        Write-Host "  repo: " -ForegroundColor DarkGray -NoNewline
        Write-Host "$remote" -ForegroundColor White
    }"""

content = re.sub(r'\$sha\s*=\s*"unknown".*?Write-Host "\$remote" -ForegroundColor White\n\s*\}', replacement, content, flags=re.DOTALL)

with open(run_ps1, "w", encoding="utf-8") as f:
    f.write(content)

print("run.ps1 updated.")
