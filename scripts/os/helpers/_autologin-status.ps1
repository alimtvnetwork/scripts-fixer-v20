<#
.SYNOPSIS
    Status inspection and rendering for Auto-Login.
#>

function Get-AutoLoginStatus {
    $autoLogon = Get-RegistryValueSafe -Path $script:WinlogonKey -Name "AutoAdminLogon" -DefaultValue "0"
    $isEnabled = ("$autoLogon" -eq "1")
    $currentUser = Get-RegistryValueSafe -Path $script:WinlogonKey -Name "DefaultUserName" -DefaultValue ""
    $currentDomain = Get-RegistryValueSafe -Path $script:WinlogonKey -Name "DefaultDomainName" -DefaultValue "."
    $storedPass = Get-RegistryValueSafe -Path $script:WinlogonKey -Name "DefaultPassword" -DefaultValue ""
    $hasPassword = (-not [string]::IsNullOrEmpty("$storedPass"))
    $isServerHost = Test-IsWindowsServer
    $isWin11Host = Test-IsWindows11

    $pwlessVal = Get-RegistryValueSafe -Path $script:PasswordlessKey -Name "DevicePasswordLessBuildVersion" -DefaultValue 2
    $isPasswordlessUnlocked = ("$pwlessVal" -eq "0")

    $cadWinlogon = Get-RegistryValueSafe -Path $script:WinlogonKey -Name "DisableCAD" -DefaultValue 0
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
