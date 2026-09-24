<#
.SYNOPSIS
    OS Auto-Login configuration helper for Windows 11 and Windows Server.

.DESCRIPTION
    Manages automated logon credentials across Windows platforms:
    - Windows 11: Sets Winlogon credentials and unlocks DevicePasswordLessBuildVersion
    - Windows Server: Sets Winlogon credentials, ForceAutoLogon, and disables CAD prompt
#>
param(
    [Parameter(Position = 0)]
    [ValidateSet("status", "enable", "disable", "check")]
    [string]$Command = "status",

    [Alias("u", "Name")]
    [string]$User = "",

    [Alias("p")]
    [string]$Password = "",

    [Alias("d")]
    [string]$Domain = ".",

    [switch]$Server,
    [switch]$Win11,
    [switch]$DryRun,
    [switch]$Json,
    [switch]$Ask
)

$ErrorActionPreference = "Stop"

$helpersDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptDir  = Split-Path -Parent $helpersDir
$sharedDir  = Join-Path (Split-Path -Parent $scriptDir) "shared"

. (Join-Path $sharedDir "logging.ps1")
. (Join-Path $sharedDir "json-utils.ps1")
. (Join-Path $helpersDir "_common.ps1")
. (Join-Path $helpersDir "_autologin-registry.ps1")
. (Join-Path $helpersDir "_autologin-status.ps1")
. (Join-Path $helpersDir "_autologin-actions.ps1")

$currentStatus = Get-AutoLoginStatus

if ($Command -in @("status", "check")) {
    Show-AutoLoginStatus -Status $currentStatus -AsJson:$Json
    exit 0
}

$isAdminOk = Test-IsAdministrator
if (-not $isAdminOk -and -not $DryRun) {
    Write-Host "  [ FAIL ] Administrator privileges required to configure Auto-Logon." -ForegroundColor Red
    exit 1
}

$isServerMode = $Server -or $currentStatus.is_windows_server
$isWin11Mode  = $Win11 -or $currentStatus.is_windows_11

if ($Command -eq "disable") {
    Disable-AutoLogin -IsDryRun:$DryRun
    exit 0
}

if ($Command -eq "enable") {
    $creds = Resolve-AutoLoginCredentials -TargetUser $User -TargetPass $Password -WantsAsk:$Ask
    if ([string]::IsNullOrEmpty($creds.User)) {
        Write-Host "  [ FAIL ] Username is required to enable auto-login." -ForegroundColor Red
        exit 1
    }

    Enable-AutoLogin `
        -TargetUser $creds.User `
        -TargetPass $creds.Password `
        -TargetDomain $Domain `
        -IsServerTarget:$isServerMode `
        -IsWin11Target:$isWin11Mode `
        -IsDryRun:$DryRun

    exit 0
}
