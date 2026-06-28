<#
.SYNOPSIS
    Points this clone's git hooks at .githooks/ (versioned).
#>
$ErrorActionPreference = "Stop"
$repoRoot = (git rev-parse --show-toplevel).Trim()
Set-Location $repoRoot
git config core.hooksPath .githooks
Write-Host "[OK] core.hooksPath -> .githooks" -ForegroundColor Green
Write-Host "     Hooks active: $((Get-ChildItem .githooks -File).Name -join ', ')" -ForegroundColor DarkGray
