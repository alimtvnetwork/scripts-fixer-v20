param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function Uninstall-Codex {
    Write-Host "Uninstalling Codex UI..." -ForegroundColor Cyan
    $installDir = Join-Path $env:USERPROFILE ".codex\bin"
    if (Test-Path $installDir) {
        Remove-Item -Recurse -Force $installDir
    }
    Write-Host "Codex UI uninstalled successfully." -ForegroundColor Green
}

Uninstall-Codex
