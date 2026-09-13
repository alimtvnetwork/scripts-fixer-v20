param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function Uninstall-ClaudeCode {
    Write-Host "Uninstalling Claude Code..." -ForegroundColor Cyan
    $installDir = Join-Path $env:USERPROFILE ".claude\bin"
    if (Test-Path $installDir) {
        Remove-Item -Recurse -Force $installDir -ErrorAction SilentlyContinue
    }
    $desktopShortcut = Join-Path ([Environment]::GetFolderPath("Desktop")) "Claude Code.lnk"
    if (Test-Path $desktopShortcut) {
        Remove-Item -Force $desktopShortcut -ErrorAction SilentlyContinue
    }
    $hasNpm = $null -ne (Get-Command "npm" -ErrorAction SilentlyContinue)
    if ($hasNpm) {
        try {
            npm uninstall -g @anthropic-ai/claude-code 2>$null
        } catch { }
    }
    Write-Host "Claude Code uninstalled successfully." -ForegroundColor Green
}

Uninstall-ClaudeCode
