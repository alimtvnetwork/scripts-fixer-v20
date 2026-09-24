<#
.SYNOPSIS
    Registry access and OS edition detection for Auto-Login.
#>

$script:WinlogonKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$script:PasswordlessKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device"
$script:PoliciesSystemKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"

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
