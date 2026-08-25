# Install GitHub CLI
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"
. (Join-Path $sharedDir "logging.ps1")

Write-Host "Installing GitHub CLI via WSL Ubuntu..." -ForegroundColor Cyan
wsl -e bash scripts/os/ubuntu/install-gh.sh
