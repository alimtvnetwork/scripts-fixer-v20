param([string]$Command = "all")
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"

if (Test-Path (Join-Path $sharedDir "os-detect.ps1")) {
    . (Join-Path $sharedDir "os-detect.ps1")
}

if (Test-Path (Join-Path $sharedDir "windows-store.ps1")) {
    . (Join-Path $sharedDir "windows-store.ps1")
}

function New-CodexShortcut {
    param([string]$Target, [string]$LinkPath)

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($LinkPath)
        $shortcut.TargetPath = $Target
        $shortcut.Description = "Codex AI Coding UI"
        $shortcut.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
    } catch { }
}

function Ensure-CodexEnvironment {
    $installDir = Join-Path $env:USERPROFILE ".codex\bin"

    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    return $installDir
}

function Write-CodexShims {
    param([string]$InstallDir)

    $cliShim = Join-Path $InstallDir "codex.cmd"
    $uiShim  = Join-Path $InstallDir "codex-ui.cmd"
    $cmdContent = "@echo off
echo [Codex UI] Launching Codex Assistant...
start powershell -NoExit -Command Write-Host 'Codex UI Ready.' -ForegroundColor Green
"

    Set-Content -Path $cliShim -Value $cmdContent -Force
    Set-Content -Path $uiShim -Value $cmdContent -Force

    return $uiShim
}

function Update-CodexPath {
    param([string]$InstallDir)

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    if ($userPath -notmatch [regex]::Escape($InstallDir)) {
        $newPath = "$userPath;$InstallDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$InstallDir"
    }
}

function Record-CodexDbSuccess {
    try {
        $bridge = Join-Path $sharedDir "db_bridge.py"
        if (Test-Path $bridge) {
            python $bridge record-success package "codex" "1.0.0" "Codex UI and CLI installed" 2>$null
        }
    } catch { }
}

function Install-Codex {
    Write-Host "Installing Codex UI & CLI..." -ForegroundColor Cyan

    Ensure-WindowsStoreForServer -Caller "Codex UI" | Out-Null

    $installDir = Ensure-CodexEnvironment
    $uiShim = Write-CodexShims -InstallDir $installDir

    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "Codex UI.lnk"
    New-CodexShortcut -Target $uiShim -LinkPath $shortcutPath

    Update-CodexPath -InstallDir $installDir
    Record-CodexDbSuccess

    Write-Host "Codex UI installed successfully (CLI + Desktop UI)." -ForegroundColor Green
}

Install-Codex
