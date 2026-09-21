<#
.SYNOPSIS
    Installs or uninstalls Beyond Compare 4 or 5 silently on Windows.
.PARAMETER Version
    Beyond Compare major version: 4 or 5 (default 5).
.PARAMETER Uninstall
    If specified, uninstalls Beyond Compare.
#>
param (
    [int]$Version = 5,
    [switch]$Uninstall = $false
)

$ErrorActionPreference = 'Stop'

function Get-UninstallPath([int]$ver) {
    $paths = @(
        "C:\Program Files\Beyond Compare $ver\unins000.exe",
        "C:\Program Files (x86)\Beyond Compare $ver\unins000.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

if ($Uninstall) {
    Write-Host "  [ .. ] Uninstalling Beyond Compare $Version..." -ForegroundColor Yellow
    $uninstaller = Get-UninstallPath -ver $Version
    if ($uninstaller) {
        Start-Process -FilePath $uninstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait -NoNewWindow
        Write-Host "  [ OK ] Beyond Compare $Version uninstalled successfully." -ForegroundColor Green
    } else {
        Write-Host "  [WARN] Beyond Compare $Version uninstaller not found." -ForegroundColor Yellow
    }
    exit 0
}

Write-Host "  [ .. ] Installing Beyond Compare $Version on Windows..." -ForegroundColor Cyan

$downloadUrl = if ($Version -eq 4) {
    "https://www.scootersoftware.com/files/BCompare-4.4.7.28397.exe"
} else {
    "https://www.scootersoftware.com/files/BCompare-5.0.3.30064.exe"
}

$tempInstaller = Join-Path $env:TEMP "BCompare-$Version-setup.exe"

Write-Host "  [ .. ] Downloading $downloadUrl..." -ForegroundColor Gray
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $downloadUrl -OutFile $tempInstaller -UseBasicParsing

Write-Host "  [ .. ] Running silent installation..." -ForegroundColor Gray
$proc = Start-Process -FilePath $tempInstaller -ArgumentList "/VERYSILENT /NORESTART" -Wait -PassThru -NoNewWindow
if (Test-Path $tempInstaller) {
    Remove-Item $tempInstaller -Force -ErrorAction SilentlyContinue
}

if ($proc.ExitCode -ne 0) {
    Write-Host "  [ERR ] Installer exited with code $($proc.ExitCode)" -ForegroundColor Red
    exit $proc.ExitCode
}

Write-Host "  [ OK ] Beyond Compare $Version installed successfully." -ForegroundColor Green

# Configure Git Diff & Merge Tool if git is available
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $bcExe = "C:\Program Files\Beyond Compare $Version\BComp.exe"
    if (Test-Path $bcExe) {
        git config --global diff.tool bc
        git config --global difftool.bc.path "$bcExe"
        git config --global difftool.prompt false
        git config --global merge.tool bc
        git config --global mergetool.bc.path "$bcExe"
        git config --global mergetool.bc.cmd "`"$bcExe`" `"`$LOCAL`" `"`$REMOTE`" `"`$BASE`" `"`$MERGED`""
        git config --global mergetool.prompt false
        Write-Host "  [ OK ] Git configured to use Beyond Compare $Version for diff and merge." -ForegroundColor Green
    }
}
