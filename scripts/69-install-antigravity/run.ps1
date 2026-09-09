param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function Install-AntigravityCLI {
    $isInstalled = $null -ne (Get-Command "agy" -ErrorAction SilentlyContinue)
    if ($isInstalled) {
        Write-Host "Antigravity CLI (agy) is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Antigravity CLI..." -ForegroundColor Cyan
    Invoke-Expression (Invoke-RestMethod "https://get.antigravity.dev")
    Write-Host "Antigravity CLI installed successfully." -ForegroundColor Green
}

Install-AntigravityCLI
