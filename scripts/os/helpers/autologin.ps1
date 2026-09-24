<#
.SYNOPSIS
    OS Auto-Login configuration helper for Windows 11 and Windows Server.

.DESCRIPTION
    Manages automated logon credentials across Windows platforms:
    - Windows 11: Sets Winlogon credentials and unlocks DevicePasswordLessBuildVersion
    - Windows Server: Sets Winlogon credentials, ForceAutoLogon, and disables CAD prompt
    - Interoperable with 'gitmap os autologin' when gitmap is installed.

.EXAMPLES
    .\run.ps1 os autologin status
    .\run.ps1 os autologin enable -User developer -Password "Secret123"
    .\run.ps1 os autologin disable
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

$winlogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$passwordlessKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
$policiesSystemKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

function Test-IsWindowsServer {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($null -eq $os) {
        return $false
    }

    return ($os.ProductType -in @(2, 3))
}

function Test-IsWindows11 {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($null -eq $os) {
        return $false
    }

    $buildNum = 0
    [void][int]::TryParse($os.BuildNumber, [ref]$buildNum)

    return ($buildNum -ge 22000)
}

function Ensure-RegistryKey {
    param([string]$KeyPath)

    if (-not (Test-Path $KeyPath)) {
        New-Item -Path $KeyPath -Force | Out-Null
    }
}

function Set-RegistryValueSafe {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$PropertyType
    )

    Ensure-RegistryKey -KeyPath $Path
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $PropertyType -Force
}

function Get-RegistryValueSafe {
    param(
        [string]$Path,
        [string]$Name,
        [object]$DefaultValue = $null
    )

    if (-not (Test-Path $Path)) {
        return $DefaultValue
    }

    $val = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($null -eq $val) {
        return $DefaultValue
    }

    return $val
}

function Get-AutoLoginStatus {
    $autoLogon = Get-RegistryValueSafe -Path $winlogonKey -Name "AutoAdminLogon" -DefaultValue "0"
    $isEnabled = ("$autoLogon" -eq "1")
    $currentUser = Get-RegistryValueSafe -Path $winlogonKey -Name "DefaultUserName" -DefaultValue ""
    $currentDomain = Get-RegistryValueSafe -Path $winlogonKey -Name "DefaultDomainName" -DefaultValue "."
    $storedPass = Get-RegistryValueSafe -Path $winlogonKey -Name "DefaultPassword" -DefaultValue ""
    $hasPassword = (-not [string]::IsNullOrEmpty("$storedPass"))
    $isServerHost = Test-IsWindowsServer
    $isWin11Host = Test-IsWindows11

    $pwlessVal = Get-RegistryValueSafe -Path $passwordlessKey -Name "DevicePasswordLessBuildVersion" -DefaultValue 2
    $isPasswordlessUnlocked = ("$pwlessVal" -eq "0")

    $cadWinlogon = Get-RegistryValueSafe -Path $winlogonKey -Name "DisableCAD" -DefaultValue 0
    $isCadDisabled = ("$cadWinlogon" -eq "1")

    return [PSCustomObject]@{
        is_enabled               = $isEnabled
        username                 = "$currentUser"
        domain                   = "$currentDomain"
        has_password             = $hasPassword
        is_windows_server        = $isServerHost
        is_windows_11            = $isWin11Host
        is_passwordless_unlocked = $isPasswordlessUnlocked
        is_server_cad_disabled   = $isCadDisabled
        display_manager          = "Winlogon"
    }
}

function Show-AutoLoginStatus {
    param([PSCustomObject]$Status, [switch]$AsJson)

    if ($AsJson) {
        $Status | ConvertTo-Json -Depth 4
        return
    }

    $osFlavor = "Windows 10/Client"
    if ($Status.is_windows_server) {
        $osFlavor = "Windows Server"
    } elseif ($Status.is_windows_11) {
        $osFlavor = "Windows 11"
    }

    Write-Host ""
    Write-Host "▶ OS Auto-Login Status" -ForegroundColor Cyan
    Write-Host "  • Target OS:                   $osFlavor" -ForegroundColor White
    Write-Host "  • Enabled:                     $($Status.is_enabled)" -ForegroundColor $(if ($Status.is_enabled) { "Green" } else { "DarkGray" })
    Write-Host "  • Username:                    $($Status.username)" -ForegroundColor White
    Write-Host "  • Domain:                      $($Status.domain)" -ForegroundColor White
    Write-Host "  • Password Stored:             $($Status.has_password)" -ForegroundColor $(if ($Status.has_password) { "Green" } else { "DarkGray" })
    Write-Host "  • Display Manager:             $($Status.display_manager)" -ForegroundColor DarkGray

    if ($Status.is_windows_11) {
        Write-Host "  • Win11 Passwordless Unlocked: $($Status.is_passwordless_unlocked)" -ForegroundColor $(if ($Status.is_passwordless_unlocked) { "Green" } else { "DarkYellow" })
    }

    if ($Status.is_windows_server) {
        Write-Host "  • Server CAD Bypass:           $($Status.is_server_cad_disabled)" -ForegroundColor $(if ($Status.is_server_cad_disabled) { "Green" } else { "DarkYellow" })
    }

    Write-Host ""
}

function Resolve-AutoLoginCredentials {
    param([string]$TargetUser, [string]$TargetPass, [switch]$WantsAsk)

    $resolvedUser = $TargetUser
    if ([string]::IsNullOrWhiteSpace($resolvedUser)) {
        $resolvedUser = $env:USERNAME
    }

    $resolvedPass = $TargetPass
    if ([string]::IsNullOrWhiteSpace($resolvedPass) -and $WantsAsk) {
        Write-Host "Enter password for auto-login user [$resolvedUser]: " -NoNewline -ForegroundColor Yellow
        $sec = Read-Host -AsSecureString
        $resolvedPass = [System.Net.NetworkCredential]::new("", $sec).Password
    }

    return [PSCustomObject]@{
        User     = $resolvedUser
        Password = $resolvedPass
    }
}

function Enable-AutoLogin {
    param(
        [string]$TargetUser,
        [string]$TargetPass,
        [string]$TargetDomain,
        [switch]$IsServerTarget,
        [switch]$IsWin11Target,
        [switch]$IsDryRun
    )

    if ($IsDryRun) {
        Write-Host "  [DRY RUN] Would set AutoAdminLogon=1 for user '$TargetUser' (domain '$TargetDomain')" -ForegroundColor Cyan
        return
    }

    Set-RegistryValueSafe -Path $winlogonKey -Name "AutoAdminLogon" -Value "1" -PropertyType "String"
    Set-RegistryValueSafe -Path $winlogonKey -Name "DefaultUserName" -Value $TargetUser -PropertyType "String"
    Set-RegistryValueSafe -Path $winlogonKey -Name "DefaultDomainName" -Value $TargetDomain -PropertyType "String"

    if (-not [string]::IsNullOrEmpty($TargetPass)) {
        Set-RegistryValueSafe -Path $winlogonKey -Name "DefaultPassword" -Value $TargetPass -PropertyType "String"
    }

    if ($IsWin11Target) {
        Set-RegistryValueSafe -Path $passwordlessKey -Name "DevicePasswordLessBuildVersion" -Value 0 -PropertyType "DWord"
    }

    if ($IsServerTarget) {
        Set-RegistryValueSafe -Path $winlogonKey -Name "ForceAutoLogon" -Value "1" -PropertyType "String"
        Set-RegistryValueSafe -Path $winlogonKey -Name "DisableCAD" -Value 1 -PropertyType "DWord"
        Set-RegistryValueSafe -Path $policiesSystemKey -Name "DisableCAD" -Value 1 -PropertyType "DWord"
    }

    Write-Host "✔ OS Auto-Login configured successfully for '$TargetUser'." -ForegroundColor Green
}

function Disable-AutoLogin {
    param([switch]$IsDryRun)

    if ($IsDryRun) {
        Write-Host "  [DRY RUN] Would disable AutoAdminLogon and remove DefaultPassword" -ForegroundColor Cyan
        return
    }

    Set-RegistryValueSafe -Path $winlogonKey -Name "AutoAdminLogon" -Value "0" -PropertyType "String"

    if (Test-Path $winlogonKey) {
        Remove-ItemProperty -Path $winlogonKey -Name "DefaultPassword" -ErrorAction SilentlyContinue
    }

    Write-Host "✔ OS Auto-Login disabled successfully." -ForegroundColor Green
}

# Execution Entrypoint
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
