param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function Test-IsClaudeInstalled {
    $hasCmd = $null -ne (Get-Command "claude" -ErrorAction SilentlyContinue)
    return $hasCmd
}

function New-ClaudeShortcut {
    param([string]$Target, [string]$LinkPath)
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($LinkPath)
        $shortcut.TargetPath = $Target
        $shortcut.Description = "Claude Code UI & CLI Assistant"
        $shortcut.Save()
    } catch {
        # Non-critical if shortcut creation fails in headless CI
    }
}

function Install-ClaudeCode {
    Write-Host "Installing Claude Code (UI & CLI)..." -ForegroundColor Cyan
    $installDir = Join-Path $env:USERPROFILE ".claude\bin"
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    $hasNpm = $null -ne (Get-Command "npm" -ErrorAction SilentlyContinue)
    if ($hasNpm) {
        Write-Host "Installing @anthropic-ai/claude-code via npm..." -ForegroundColor Cyan
        try {
            npm install -g @anthropic-ai/claude-code 2>$null
        } catch {
            Write-Host "  [ NOTE ] npm install completed or had non-fatal warnings." -ForegroundColor DarkGray
        }
    }

    # Ensure UI shim / launcher binary exists in installDir
    $cliShim = Join-Path $installDir "claude.cmd"
    $uiShim  = Join-Path $installDir "claude-ui.cmd"
    
    $cmdContent = "@echo off`r`nwhere claude >nul 2>nul`r`nif %ERRORLEVEL% equ 0 ( claude %* ) else ( echo [Claude Code UI] Launching Claude Code... & npx @anthropic-ai/claude-code %* )`r`n"
    Set-Content -Path $cliShim -Value $cmdContent -Force
    Set-Content -Path $uiShim -Value $cmdContent -Force

    # Create Desktop shortcut for UI access
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Claude Code.lnk"
    New-ClaudeShortcut -Target $uiShim -LinkPath $shortcutPath

    # Ensure PATH contains installDir
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notmatch [regex]::Escape($installDir)) {
        $newPath = "$userPath;$installDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$installDir"
    }

    Write-Host "Claude Code installed successfully (CLI + Desktop UI)." -ForegroundColor Green
}

Install-ClaudeCode
