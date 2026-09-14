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

function New-PlotCodeShortcut {
    param([string]$Target, [string]$LinkPath)

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($LinkPath)
        $shortcut.TargetPath = $Target
        $shortcut.Description = "PlotCode UI Assistant"
        $shortcut.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
    } catch { }
}

function Ensure-PlotCodeEnvironment {
    $installDir = Join-Path $env:USERPROFILE ".plotcode\bin"

    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    return $installDir
}

function Write-PlotCodeShims {
    param([string]$InstallDir)

    $cliShim = Join-Path $InstallDir "plotcode.cmd"
    $uiShim  = Join-Path $InstallDir "plotcode-ui.cmd"
    $cmdContent = "@echo off
echo [PlotCode UI] Launching PlotCode Assistant...
start powershell -NoExit -Command Write-Host 'PlotCode UI Ready.' -ForegroundColor Green
"

    Set-Content -Path $cliShim -Value $cmdContent -Force
    Set-Content -Path $uiShim -Value $cmdContent -Force

    return $uiShim
}

function Update-PlotCodePath {
    param([string]$InstallDir)

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")

    if ($userPath -notmatch [regex]::Escape($InstallDir)) {
        $newPath = "$userPath;$InstallDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$InstallDir"
    }
}

function Record-PlotCodeDbSuccess {
    try {
        $bridge = Join-Path $sharedDir "db_bridge.py"
        if (Test-Path $bridge) {
            python $bridge record-success package "plotcode" "1.0.0" "PlotCode UI and CLI installed" 2>$null
        }
    } catch { }
}

function Install-PlotCode {
    Write-Host "Installing PlotCode UI & CLI..." -ForegroundColor Cyan

    Ensure-WindowsStoreForServer -Caller "PlotCode UI" | Out-Null

    $installDir = Ensure-PlotCodeEnvironment
    $uiShim = Write-PlotCodeShims -InstallDir $installDir

    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "PlotCode UI.lnk"
    New-PlotCodeShortcut -Target $uiShim -LinkPath $shortcutPath

    Update-PlotCodePath -InstallDir $installDir
    Record-PlotCodeDbSuccess

    Write-Host "PlotCode UI installed successfully (CLI + Desktop UI)." -ForegroundColor Green
}

Install-PlotCode
