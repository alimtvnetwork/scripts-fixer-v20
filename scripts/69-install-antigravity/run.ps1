param(
    [Parameter(Position = 0)][string]$Command = "all",
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$Rest,
    [switch]$Help,
    [switch]$h
)

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
. (Join-Path $helpersDir "help.ps1")
. (Join-Path $helpersDir "env-path.ps1")
. (Join-Path $helpersDir "shortcuts.ps1")
. (Join-Path $helpersDir "check.ps1")
. (Join-Path $helpersDir "verify.ps1")
. (Join-Path $helpersDir "telemetry.ps1")
. (Join-Path $helpersDir "install-ide.ps1")
. (Join-Path $helpersDir "install-cli.ps1")
. (Join-Path $helpersDir "uninstall.ps1")

$isHelpRequested = $Help -or $h -or ($Command.ToLowerInvariant() -in @("help", "--help", "-help", "-h", "/?", "?"))
if ($isHelpRequested) {
    Show-AgyHelp
    exit 0
}

function Clear-AntigravityCache {
    param([string[]]$ExtraArgs)

    $helper = Join-Path $PSScriptRoot "helpers\clear-agy.ps1"
    $isHelperMissing = -not (Test-Path -LiteralPath $helper)
    if ($isHelperMissing) {
        Write-Host "  [XX] Clear helper not found: $helper" -ForegroundColor Red
        exit 1
    }

    $normalized = @()
    foreach ($arg in $ExtraArgs) {
        $tok = "$arg".Trim()
        $low = $tok.ToLower()
        $isVerb = $low -in @("clean", "clear", "cache", "cache-clear", "clear-cache", "clean-cache", "cache-clean", "prune")
        if ($isVerb) { continue }

        if ($low -match '^(-k|--keep=?)(\d+)$') {
            $normalized += @("-Keep", [int]$matches[2])
            continue
        }

        if ($low -match '^(-t|--threshold=?)(\d+)$') {
            $normalized += @("-Threshold", [int]$matches[2])
            continue
        }

        $normalized += $tok
    }

    & $helper @normalized
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
    "cli"          { Install-AntigravityCLIOnly }
    "check"        { Check-Antigravity }
    "verify"       { Check-Antigravity }
    "uninstall"    { Uninstall-Antigravity }
    "remove"       { Uninstall-Antigravity }
    "clean"        { Clear-AntigravityCache -ExtraArgs $Rest }
    "clear"        { Clear-AntigravityCache -ExtraArgs $Rest }
    "cache"        { Clear-AntigravityCache -ExtraArgs $Rest }
    "cache-clear"  { Clear-AntigravityCache -ExtraArgs $Rest }
    "clear-cache"  { Clear-AntigravityCache -ExtraArgs $Rest }
    "clean-cache"  { Clear-AntigravityCache -ExtraArgs $Rest }
    "cache-clean"  { Clear-AntigravityCache -ExtraArgs $Rest }
    "prune"        { Clear-AntigravityCache -ExtraArgs $Rest }
    "predict"      { Clear-AntigravityCache -ExtraArgs (@("-Predict") + $Rest) }
    "list-backups" { Clear-AntigravityCache -ExtraArgs @("-ListBackups") }
    "backups"      { Clear-AntigravityCache -ExtraArgs @("-ListBackups") }
    "history"      { Clear-AntigravityCache -ExtraArgs @("-ListBackups") }
    "undo"         { Clear-AntigravityCache -ExtraArgs (@("-Undo") + $Rest) }
    "all"          { Install-Antigravity }
    "install"      { Install-Antigravity }
    "setup"        { Install-Antigravity }
    "reinstall"    { Install-Antigravity }
    "full"         { Install-Antigravity }
    default        {
        Write-Host "  [ FAIL ] Unknown Antigravity command: '$action'" -ForegroundColor Red
        Show-AgyHelp
        exit 1
    }
}
