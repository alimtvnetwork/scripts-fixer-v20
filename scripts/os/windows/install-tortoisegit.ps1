<#
.SYNOPSIS
    Installs or uninstalls TortoiseGit 2.4.0.2 silently on Windows.
.PARAMETER Version
    TortoiseGit version (default 2.4.0.2).
.PARAMETER Uninstall
    If specified, uninstalls TortoiseGit.
#>
param (
    [string]$Version = "2.4.0.2",
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

function Get-TortoiseGitUninstallPath {
    $paths = @(
        "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe",
        "C:\Program Files (x86)\TortoiseGit\bin\TortoiseGitProc.exe"
    )

    foreach ($p in $paths) {

        if (Test-Path $p) {
            return $p
        }
    }

    return $null
}

$isUninstall = [bool]$Uninstall

if ($isUninstall) {
    Write-Host "  [ .. ] Uninstalling TortoiseGit $Version..." -ForegroundColor Yellow

    $chocoCmd = Get-Command choco.exe -ErrorAction SilentlyContinue

    if ($null -ne $chocoCmd) {
        choco uninstall tortoisegit -y
        Write-Host "  [ OK ] TortoiseGit $Version uninstalled via Chocolatey." -ForegroundColor Green
        exit 0
    }

    Write-Host "  [WARN] TortoiseGit uninstaller not automated without Chocolatey; remove via Settings -> Apps." -ForegroundColor Yellow
    exit 0
}

Write-Host "  [ .. ] Installing TortoiseGit $Version on Windows..." -ForegroundColor Cyan

$chocoCmd = Get-Command choco.exe -ErrorAction SilentlyContinue

if ($null -ne $chocoCmd) {
    Write-Host "  [ .. ] Running choco install tortoisegit --version $Version -y..." -ForegroundColor Gray
    choco install tortoisegit --version $Version -y
    $isSuccess = $LASTEXITCODE -eq 0 -or $LASTEXITCODE -eq 3010

    if ($isSuccess) {
        Write-Host "  [ OK ] TortoiseGit $Version installed successfully via Chocolatey." -ForegroundColor Green
        exit 0
    }
}

Write-Host "  [ .. ] Chocolatey not available or failed; downloading standalone package..." -ForegroundColor Gray
$nupkgUrl = "https://packages.chocolatey.org/TortoiseGit.2.4.0.2.nupkg"
$tempDir = Join-Path $env:TEMP "TortoiseGitSetup"
$nupkgFile = Join-Path $tempDir "TortoiseGit.2.4.0.2.zip"

if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $nupkgUrl -OutFile $nupkgFile -UseBasicParsing

Expand-Archive -LiteralPath $nupkgFile -DestinationPath $tempDir -Force

$is64Bit = [Environment]::Is64BitOperatingSystem
$msiName = if ($is64Bit) { "TortoiseGit-2.4.0.2-64bit_x64.msi" } else { "TortoiseGit-2.4.0.2-32bit_x32.msi" }
$msiPath = Join-Path (Join-Path $tempDir "tools") $msiName

$proc = Start-Process -FilePath "msiexec.exe" -ArgumentList @("/i", "`"$msiPath`"", "/quiet", "/qn", "/norestart", "REBOOT=ReallySuppress") -Wait -PassThru -NoNewWindow

Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue

$isMsiOk = $proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010

if (-not $isMsiOk) {
    Write-Host "  [ERR ] Installer exited with code $($proc.ExitCode)" -ForegroundColor Red
    exit $proc.ExitCode
}

Write-Host "  [ OK ] TortoiseGit $Version installed successfully via MSI." -ForegroundColor Green
