<#
.SYNOPSIS
    Cross-platform and Windows edition detection helpers.
    Detects Windows Server, Windows 11, Windows 10, and Windows Store presence.
#>

function Test-IsWindowsEnvironment {
    if ($null -ne $IsWindows) {
        return [bool]$IsWindows
    }

    return ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT)
}

function Get-CimOperatingSystem {
    try {
        return (Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop)
    } catch {
        return $null
    }
}

function Test-IsWindowsServer {
    if (-not (Test-IsWindowsEnvironment)) {
        return $false
    }

    $os = Get-CimOperatingSystem

    if ($os -and ($os.ProductType -eq 2 -or $os.ProductType -eq 3)) {
        return $true
    }

    if ($os -and $os.Caption -match 'Server') {
        return $true
    }

    try {
        $key = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
        $instType = (Get-ItemProperty -Path $key -Name InstallationType -ErrorAction Stop).InstallationType

        if ($instType -and ($instType -match 'Server')) {
            return $true
        }
    } catch { }

    return $false
}

function Test-IsWindows11 {
    if (-not (Test-IsWindowsEnvironment)) {
        return $false
    }

    $os = Get-CimOperatingSystem
    if (-not $os) {
        return $false
    }

    $isClient = ($os.ProductType -eq 1)
    $isWin11Build = ([int]$os.BuildNumber -ge 22000)

    return ($isClient -and $isWin11Build)
}

function Test-IsWindows10 {
    if (-not (Test-IsWindowsEnvironment)) {
        return $false
    }

    $os = Get-CimOperatingSystem
    if (-not $os) {
        return $false
    }

    $isClient = ($os.ProductType -eq 1)
    $isWin10Build = ([int]$os.BuildNumber -ge 10240 -and [int]$os.BuildNumber -lt 22000)

    return ($isClient -and $isWin10Build)
}

function Test-HasWindowsStore {
    if (-not (Test-IsWindowsEnvironment)) {
        return $false
    }

    $appxStore = $null
    try {
        $appxStore = & powershell.exe -NoProfile -NonInteractive -Command "Get-AppxPackage -Name '*WindowsStore*' -AllUsers" 2>$null
    } catch { }

    if ($appxStore -and $appxStore.Trim().Length -gt 0) {
        return $true
    }

    $storeDir = Join-Path $env:ProgramFiles "WindowsApps\Microsoft.WindowsStore*"
    if (Test-Path $storeDir -ErrorAction SilentlyContinue) {
        return $true
    }

    return $false
}

function Get-OSInfo {
    $isWin = Test-IsWindowsEnvironment
    $isServer = Test-IsWindowsServer
    $isW11 = Test-IsWindows11
    $isW10 = Test-IsWindows10
    $hasStore = Test-HasWindowsStore
    $os = Get-CimOperatingSystem

    $caption = if ($os -and $os.Caption) { [string]$os.Caption } else { [System.Environment]::OSVersion.VersionString }
    $build = if ($os -and $os.BuildNumber) { [int]$os.BuildNumber } else { 0 }
    $productType = if ($os -and $os.ProductType) { [int]$os.ProductType } else { 1 }

    return [PSCustomObject]@{
        IsWindows       = $isWin
        IsWindowsServer = $isServer
        IsWindows11     = $isW11
        IsWindows10     = $isW10
        HasWindowsStore = $hasStore
        Caption         = $caption
        BuildNumber     = $build
        ProductType     = $productType
    }
}
