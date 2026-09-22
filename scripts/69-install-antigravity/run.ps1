param([string]$Command = "all")
$ErrorActionPreference = "Stop"

# ── Cross-Platform OS Detection & Forwarding ──────────────────────────────────
$isUnix = ($null -ne $IsLinux -and $IsLinux) -or
          ($null -ne $IsMacOS -and $IsMacOS) -or
          ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Unix) -or
          ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::MacOSX)

if ($isUnix) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
    $shCandidates = @(
        (Join-Path (Split-Path -Parent $scriptDir) "os/ubuntu/install-antigravity.sh"),
        (Join-Path $scriptDir "../../scripts/os/ubuntu/install-antigravity.sh"),
        (Join-Path (Get-Location) "scripts/os/ubuntu/install-antigravity.sh"),
        "scripts/os/ubuntu/install-antigravity.sh"
    )
    $shTarget = $null
    foreach ($cand in $shCandidates) {
        if ($cand -and (Test-Path $cand)) {
            $shTarget = (Resolve-Path $cand).Path
            break
        }
    }
    if (-not $shTarget) {
        Write-Error "Could not locate scripts/os/ubuntu/install-antigravity.sh for Unix forwarding."
        exit 1
    }
    Write-Host "Unix environment detected. Forwarding to $shTarget..." -ForegroundColor Cyan
    & bash $shTarget
    exit $LASTEXITCODE
}

# ── Import Modular Helpers ───────────────────────────────────────────────────
$helpersDir = Join-Path $PSScriptRoot "helpers"
. (Join-Path $helpersDir "env-path.ps1")
. (Join-Path $helpersDir "shortcuts.ps1")
. (Join-Path $helpersDir "check.ps1")
. (Join-Path $helpersDir "verify.ps1")
. (Join-Path $helpersDir "telemetry.ps1")
. (Join-Path $helpersDir "install-ide.ps1")
. (Join-Path $helpersDir "install-cli.ps1")
. (Join-Path $helpersDir "uninstall.ps1")

function Clear-AntigravityCache {
    param([string[]]$ExtraArgs)

    $helper = Join-Path $PSScriptRoot "helpers\clear-agy.ps1"
    if (Test-Path -LiteralPath $helper) {
        & $helper @ExtraArgs
    } else {
        Write-Host "  [XX] Clear helper not found: $helper" -ForegroundColor Red
        exit 1
    }
}

function Install-AntigravityCLIOnly {
    Write-Host "Installing Antigravity CLI (agy)..." -ForegroundColor Cyan

    $installDir = Install-AntigravityCLI
    Update-EnvironmentPath -InstallDir $installDir
    Create-Shortcuts -IdePath $null -InstallDir $installDir
    Verify-AntigravityInstallation -InstallDir $installDir
    Record-AntigravityDbSuccess -Mode "cli"

    Write-Host "Antigravity CLI installation complete." -ForegroundColor Green
}

function Install-Antigravity {
    Write-Host "Installing Antigravity (IDE & CLI)..." -ForegroundColor Cyan

    $idePath = Install-AntigravityIDE
    if ($idePath -and (Test-Path $idePath)) {
        Update-EnvironmentPath -InstallDir (Split-Path -Parent $idePath)
    }

    $installDir = Install-AntigravityCLI
    Update-EnvironmentPath -InstallDir $installDir
    Create-Shortcuts -IdePath $idePath -InstallDir $installDir
    Verify-AntigravityInstallation -InstallDir $installDir
    Record-AntigravityDbSuccess -Mode "full"

    Write-Host "Antigravity installation complete." -ForegroundColor Green
}

$action = if ($env:ANTIGRAVITY_MODE) { $env:ANTIGRAVITY_MODE } else { $Command }

switch ($action.ToLowerInvariant()) {
    "cli"       { Install-AntigravityCLIOnly }
    "check"     { Check-Antigravity }
    "uninstall" { Uninstall-Antigravity }
    "clean"     { Clear-AntigravityCache -ExtraArgs $args }
    "clear"     { Clear-AntigravityCache -ExtraArgs $args }
    "predict"   { Clear-AntigravityCache -ExtraArgs @("-Predict") }
    default     { Install-Antigravity }
}
