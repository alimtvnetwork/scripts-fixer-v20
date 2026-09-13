param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function Uninstall-PlotCode {
    Write-Host "Uninstalling PlotCode UI..." -ForegroundColor Cyan
    $installDir = Join-Path $env:USERPROFILE ".plotcode\bin"
    if (Test-Path $installDir) {
        Remove-Item -Recurse -Force $installDir
    }
    Write-Host "PlotCode UI uninstalled successfully." -ForegroundColor Green
}

Uninstall-PlotCode
