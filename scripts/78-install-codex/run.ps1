param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function New-CodexShortcut {
    param([string]$Target, [string]$LinkPath)
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($LinkPath)
        $shortcut.TargetPath = $Target
        $shortcut.Description = "Codex AI Coding UI"
        $shortcut.Save()
    } catch { }
}

function Install-Codex {
    Write-Host "Installing Codex UI..." -ForegroundColor Cyan
    $installDir = Join-Path $env:USERPROFILE ".codex\bin"
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }
    
    $cliShim = Join-Path $installDir "codex.cmd"
    $uiShim  = Join-Path $installDir "codex-ui.cmd"
    $cmdContent = "@echo off`r`necho [Codex UI] Launching Codex Assistant...`r`nstart powershell -NoExit -Command Write-Host 'Codex UI Ready.' -ForegroundColor Green`r`n"
    Set-Content -Path $cliShim -Value $cmdContent -Force
    Set-Content -Path $uiShim -Value $cmdContent -Force
    
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Codex UI.lnk"
    New-CodexShortcut -Target $uiShim -LinkPath $shortcutPath

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notmatch [regex]::Escape($installDir)) {
        $newPath = "$userPath;$installDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$installDir"
    }

    Write-Host "Codex UI installed successfully (CLI + Desktop UI)." -ForegroundColor Green
}

Install-Codex
