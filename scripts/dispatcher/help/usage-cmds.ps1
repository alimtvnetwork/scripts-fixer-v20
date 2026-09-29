# Usage commands section orchestrator

. (Join-Path $PSScriptRoot "usage-core.ps1")
. (Join-Path $PSScriptRoot "usage-system.ps1")

function Show-HelpUsageCommands {
    Write-Host ""
    Write-Host "  Dev Tools Setup Scripts" -ForegroundColor $ThemeSecondary
    Write-Host "  =======================" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "  Usage:" -ForegroundColor $ThemeAccent
    Write-Host ""

    Show-HelpUsageCore
    Show-HelpUsageSystem

    Write-Host ""
}
