# Install Python 2
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"
. (Join-Path $sharedDir "logging.ps1")

Write-Host "Installing Python 2 via WSL Ubuntu..." -ForegroundColor Cyan
wsl -e bash scripts/os/ubuntu/install-python2.sh
