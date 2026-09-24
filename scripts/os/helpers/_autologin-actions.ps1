<#
.SYNOPSIS
    Enable, disable, and credential resolution actions for Auto-Login.
#>

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

    Set-RegistryValueSafe -Path $script:WinlogonKey -Name "AutoAdminLogon" -Value "1" -PropertyType "String"
    Set-RegistryValueSafe -Path $script:WinlogonKey -Name "DefaultUserName" -Value $TargetUser -PropertyType "String"
    Set-RegistryValueSafe -Path $script:WinlogonKey -Name "DefaultDomainName" -Value $TargetDomain -PropertyType "String"

    if (-not [string]::IsNullOrEmpty($TargetPass)) {
        Set-RegistryValueSafe -Path $script:WinlogonKey -Name "DefaultPassword" -Value $TargetPass -PropertyType "String"
    }

    if ($IsWin11Target) {
        Set-RegistryValueSafe -Path $script:PasswordlessKey -Name "DevicePasswordLessBuildVersion" -Value 0 -PropertyType "DWord"
    }

    if ($IsServerTarget) {
        Set-RegistryValueSafe -Path $script:WinlogonKey -Name "ForceAutoLogon" -Value "1" -PropertyType "String"
        Set-RegistryValueSafe -Path $script:WinlogonKey -Name "DisableCAD" -Value 1 -PropertyType "DWord"
        Set-RegistryValueSafe -Path $script:PoliciesSystemKey -Name "DisableCAD" -Value 1 -PropertyType "DWord"
    }

    Write-Host "✔ OS Auto-Login configured successfully for '$TargetUser'." -ForegroundColor Green
}

function Disable-AutoLogin {
    param([switch]$IsDryRun)

    if ($IsDryRun) {
        Write-Host "  [DRY RUN] Would disable AutoAdminLogon and remove DefaultPassword" -ForegroundColor Cyan
        return
    }

    Set-RegistryValueSafe -Path $script:WinlogonKey -Name "AutoAdminLogon" -Value "0" -PropertyType "String"

    if (Test-Path $script:WinlogonKey) {
        Remove-ItemProperty -Path $script:WinlogonKey -Name "DefaultPassword" -ErrorAction SilentlyContinue
    }

    Write-Host "✔ OS Auto-Login disabled successfully." -ForegroundColor Green
}
