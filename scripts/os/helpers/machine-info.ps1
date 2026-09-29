<#
.SYNOPSIS
    Cross-platform Machine Identity, Hostname & Network Adapter Inspector.

.DESCRIPTION
    Provides machine identity management, OS version detection, IP inspection,
    and alias resolution with parity to GitMap's Go implementation.
#>

param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Argv = @()
)

$ErrorActionPreference = "Continue"
Set-StrictMode -Version Latest

$helpersDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$osDir      = Split-Path -Parent $helpersDir
$scriptsDir = Split-Path -Parent $osDir
$rootDir    = Split-Path -Parent $scriptsDir
$sharedDir  = Join-Path $scriptsDir "shared"

. (Join-Path $sharedDir "logging.ps1")

function Get-StorageFile {
    $dir = Join-Path $rootDir ".installed"
    $hasDir = Test-Path -LiteralPath $dir

    if (-not $hasDir) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    return (Join-Path $dir "machine-identity.json")
}

function Get-StoredMachineConfig {
    $path = Get-StorageFile
    $hasFile = Test-Path -LiteralPath $path

    if (-not $hasFile) {
        return $null
    }

    try {
        return (Get-Content -LiteralPath $path -Raw -Encoding UTF8 | ConvertFrom-Json)
    } catch {
        Write-FileError -FilePath $path -Operation "read" -Reason $_.Exception.Message -Module "machine-info"

        return $null
    }
}

function Save-StoredMachineConfig {
    param([PSCustomObject]$Config)

    $path = Get-StorageFile

    try {
        $json = ($Config | ConvertTo-Json -Depth 4)
        Set-Content -LiteralPath $path -Value $json -Encoding UTF8 -Force

        return $true
    } catch {
        Write-FileError -FilePath $path -Operation "write" -Reason $_.Exception.Message -Module "machine-info"

        return $false
    }
}

function Get-PrimaryIPv4Address {
    try {
        $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ErrorAction Stop
        foreach ($adapter in $adapters) {
            $ips = @($adapter.IPAddress)
            $v4 = $ips | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' -and $_ -ne '127.0.0.1' } | Select-Object -First 1

            if ($v4) {
                return "$v4"
            }
        }
    } catch {}

    return "127.0.0.1"
}

function Get-WindowsOSDetails {
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
    $hasReg = Test-Path $regPath

    if (-not $hasReg) {
        return [PSCustomObject]@{ Version = [System.Environment]::OSVersion.VersionString; Build = "" }
    }

    $props = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
    $pName = if ($props.ProductName) { $props.ProductName } else { "Windows" }
    $dispVer = if ($props.DisplayVersion) { $props.DisplayVersion } else { "" }
    $build = if ($props.CurrentBuild) { $props.CurrentBuild } else { "" }

    $label = "$pName $dispVer (Build $build)".Trim()

    return [PSCustomObject]@{ Version = $label; Build = "$build" }
}

function Get-SystemToolsPresence {
    $gitCmd = Get-Command "git" -ErrorAction SilentlyContinue
    $gitPath = if ($gitCmd) { $gitCmd.Source } else { "" }
    $hasGit = [bool]$gitCmd

    $bashCmd = Get-Command "bash" -ErrorAction SilentlyContinue
    $bashPath = if ($bashCmd) { $bashCmd.Source } else { "" }
    $hasBash = [bool]$bashCmd

    $psCmd = Get-Command "pwsh" -ErrorAction SilentlyContinue
    if (-not $psCmd) {
        $psCmd = Get-Command "powershell" -ErrorAction SilentlyContinue
    }
    $psPath = if ($psCmd) { $psCmd.Source } else { "" }
    $hasPs = [bool]$psCmd

    return [PSCustomObject]@{
        GitPath        = $gitPath
        BashPath       = $bashPath
        PowerShellPath = $psPath
        HasGit         = $hasGit
        HasBash        = $hasBash
        HasPowerShell  = $hasPs
    }
}

function Get-MachineIdentityData {
    $ip = Get-PrimaryIPv4Address
    $hostname = [System.Environment]::MachineName
    $user = [System.Environment]::UserName
    $cores = [System.Environment]::ProcessorCount
    $arch = [System.Environment]::GetEnvironmentVariable("PROCESSOR_ARCHITECTURE")
    $stored = Get-StoredMachineConfig
    $tools = Get-SystemToolsPresence

    $alias = if ($stored -and $stored.alias) { $stored.alias } else { $ip }
    $machName = if ($stored -and $stored.machineName) { $stored.machineName } else { $hostname }
    $prevName = if ($stored -and $stored.previousName) { $stored.previousName } else { "" }
    $prevAlias = if ($stored -and $stored.previousAlias) { $stored.previousAlias } else { "" }

    $winOS = Get-WindowsOSDetails

    return [PSCustomObject]@{
        sequence       = 1
        nodeId         = "local-01"
        ipAddress      = $ip
        alias          = $alias
        machineName    = $machName
        osHostname     = $hostname
        previousName   = $prevName
        previousAlias  = $prevAlias
        osPlatform     = "Windows (windows)"
        osVersion      = $winOS.Version
        buildVersion   = $winOS.Build
        architecture   = $arch
        platform       = "windows/$arch"
        cpuCores       = $cores
        currentUser    = $user
        scope          = "local"
        gitPath        = $tools.GitPath
        bashPath       = $tools.BashPath
        powerShellPath = $tools.PowerShellPath
        hasGit         = $tools.HasGit
        hasBash        = $tools.HasBash
        hasPowerShell  = $tools.HasPowerShell
    }
}

function Show-MachineIdentityView {
    param([PSCustomObject]$Identity)

    Write-Host ""
    Write-Host "  ● Machine Identity & Hostname" -ForegroundColor Cyan
    Write-Host "  =============================" -ForegroundColor DarkGray
    Write-Host "    Machine IP:      " -NoNewline; Write-Host $Identity.ipAddress -ForegroundColor Green
    Write-Host "    Machine Alias:   " -NoNewline; Write-Host $Identity.alias -ForegroundColor Yellow -NoNewline
    Write-Host " (auto-defaults to IP if unset)" -ForegroundColor DarkGray
    Write-Host "    Machine Name:    " -NoNewline; Write-Host $Identity.machineName -ForegroundColor Cyan -NoNewline
    Write-Host " (OS Hostname: $($Identity.osHostname))" -ForegroundColor DarkGray
    Write-Host "    Current User:    $($Identity.currentUser)" -ForegroundColor DarkGray
    Write-Host "    Previous Value:  name=`"$($Identity.previousName)`" | alias=`"$($Identity.previousAlias)`"" -ForegroundColor DarkGray
    Write-Host "    OS Platform:     $($Identity.osPlatform)" -ForegroundColor DarkGray
    Write-Host "    OS Version:      " -NoNewline; Write-Host $Identity.osVersion -ForegroundColor Green
    Write-Host "    Hardware:        $($Identity.architecture), $($Identity.cpuCores) CPU core(s)" -ForegroundColor DarkGray
    Write-Host "    Git Path:        $(if ($Identity.hasGit) { $Identity.gitPath } else { 'not installed' })" -ForegroundColor DarkGray
    Write-Host "    Bash Path:       $(if ($Identity.hasBash) { $Identity.bashPath } else { 'not installed' })" -ForegroundColor DarkGray
    Write-Host "    PowerShell:      $(if ($Identity.hasPowerShell) { $Identity.powerShellPath } else { 'not installed' })" -ForegroundColor DarkGray
    Write-Host ""
}

function Get-MachineNetworkAdapters {
    $results = @()

    try {
        $adapters = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" -ErrorAction Stop
        foreach ($adapter in $adapters) {
            $ipList = @($adapter.IPAddress)
            $subList = @($adapter.IPSubnet)
            $gwList = @($adapter.DefaultIPGateway)

            $v4 = $ipList | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' } | Select-Object -First 1
            $mask = $subList | Where-Object { $_ -match '^\d+\.\d+\.\d+\.\d+$' } | Select-Object -First 1
            $gw = if ($gwList.Count -gt 0) { $gwList[0] } else { "-" }

            $results += [PSCustomObject]@{
                name       = $adapter.Description
                ip         = if ($v4) { $v4 } else { "-" }
                netmask    = if ($mask) { $mask } else { "-" }
                gateway    = $gw
                mac        = $adapter.MACAddress
                isDHCP     = [bool]$adapter.DHCPEnabled
                status     = "up"
                isLoopback = $false
            }
        }
    } catch {}

    return $results
}

function Show-MachineNetworkView {
    $adapters = Get-MachineNetworkAdapters

    Write-Host ""
    Write-Host "  ● Network Interfaces & IP Configuration" -ForegroundColor Cyan
    Write-Host "  =======================================" -ForegroundColor DarkGray

    $fmt = "  {0,-28} {1,-16} {2,-16} {3,-16} {4,-6} {5,-6}"
    Write-Host ([string]::Format($fmt, "INTERFACE", "IP ADDRESS", "NETMASK", "GATEWAY", "DHCP", "STATUS")) -ForegroundColor DarkYellow
    Write-Host "  $('-' * 88)" -ForegroundColor DarkGray

    foreach ($a in $adapters) {
        $dhcpStr = if ($a.isDHCP) { "yes" } else { "no" }
        Write-Host ([string]::Format($fmt, $a.name, $a.ip, $a.netmask, $a.gateway, $dhcpStr, $a.status)) -ForegroundColor Green
    }

    Write-Host ""
}

function Set-MachineIdentityValue {
    param(
        [string]$NewValue,
        [bool]$IsJson
    )

    $clean = $NewValue.Trim().Replace(" ", "-")
    $cur = Get-MachineIdentityData

    $cfg = [PSCustomObject]@{
        alias         = $clean
        machineName   = $clean
        previousAlias = $cur.alias
        previousName  = $cur.machineName
        updatedAt     = (Get-Date).ToString("o")
    }

    $isOk = Save-StoredMachineConfig -Config $cfg

    if (-not $isOk) {
        Write-Host "  [ FAIL ] Failed to save machine identity configuration." -ForegroundColor Red

        return 1
    }

    $updated = Get-MachineIdentityData

    if ($IsJson) {
        $updated | ConvertTo-Json -Depth 4

        return 0
    }

    Write-Host ""
    Write-Host "  [  OK  ] Updated machine alias and name to '$clean' (previous saved for 'revert')." -ForegroundColor Green
    Show-MachineIdentityView -Identity $updated

    return 0
}

function Revert-MachineIdentityValue {
    param([bool]$IsJson)

    $cur = Get-MachineIdentityData
    $prev = if ($cur.previousName) { $cur.previousName } else { $cur.previousAlias }

    if ([string]::IsNullOrWhiteSpace($prev)) {
        $prev = $cur.osHostname
    }

    $cfg = [PSCustomObject]@{
        alias         = $prev
        machineName   = $prev
        previousAlias = $cur.alias
        previousName  = $cur.machineName
        updatedAt     = (Get-Date).ToString("o")
    }

    $null = Save-StoredMachineConfig -Config $cfg
    $updated = Get-MachineIdentityData

    if ($IsJson) {
        $updated | ConvertTo-Json -Depth 4

        return 0
    }

    Write-Host ""
    Write-Host "  [  OK  ] Reverted machine alias and name back to '$prev'." -ForegroundColor Green
    Show-MachineIdentityView -Identity $updated

    return 0
}

function Show-MachineHelp {
    Write-Host ""
    Write-Host "  Machine Identity & Network Configuration" -ForegroundColor Cyan
    Write-Host "  ========================================" -ForegroundColor DarkGray
    Write-Host "  Usage: .\run.ps1 machine [command] [args] [flags]" -ForegroundColor Yellow
    Write-Host "         .\run.ps1 os machine [command] [args] [flags]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Commands:" -ForegroundColor Yellow
    Write-Host "    ls, show, status             Display machine IP, alias, OS hostname, and specs" -ForegroundColor DarkGray
    Write-Host "    set <name>, change <name>    Set machine alias and name (sample: dev-win-01)" -ForegroundColor DarkGray
    Write-Host "    revert, undo                 Restore previous machine alias and name" -ForegroundColor DarkGray
    Write-Host "    ip, interfaces               Display active network adapters and IP addresses" -ForegroundColor DarkGray
    Write-Host "    help                         Show this help message" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Flags:" -ForegroundColor Yellow
    Write-Host "    --json, -j                   Output machine identity as structured JSON" -ForegroundColor DarkGray
    Write-Host "    -y, --yes                    Skip confirmation prompt" -ForegroundColor DarkGray
    Write-Host "    -h, --help                   Show this help message" -ForegroundColor DarkGray
    Write-Host ""
}

# ── Main Entrypoint Dispatcher ────────────────────────────────────────────────

$isJson = $false
$hasHelp = $false
$cleanArgs = @()

foreach ($a in $Argv) {
    $low = "$a".Trim().ToLower()

    if ($low -in @("--json", "-j", "json")) {
        $isJson = $true
    }
    elseif ($low -in @("--help", "-h", "-help", "help", "/?", "?")) {
        $hasHelp = $true
    }
    elseif (-not [string]::IsNullOrWhiteSpace($a) -and -not $low.StartsWith("-")) {
        $cleanArgs += "$a".Trim()
    }
}

if ($hasHelp) {
    Show-MachineHelp
    exit 0
}

$subCmd = if ($cleanArgs.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($cleanArgs[0])) { $cleanArgs[0].ToLower() } else { "ls" }

switch ($subCmd) {
    { $_ -in @("ls", "list", "show", "status", "st") } {
        $id = Get-MachineIdentityData
        if ($isJson) {
            $id | ConvertTo-Json -Depth 4
        } else {
            Show-MachineIdentityView -Identity $id
        }
        exit 0
    }

    { $_ -in @("ip", "ips", "net", "network", "interfaces") } {
        if ($isJson) {
            Get-MachineNetworkAdapters | ConvertTo-Json -Depth 4
        } else {
            Show-MachineNetworkView
        }
        exit 0
    }

    { $_ -in @("set", "change", "rename", "update") } {
        if ($cleanArgs.Count -lt 2) {
            Write-Host "  [ FAIL ] Missing new name/alias. Usage: .\run.ps1 machine set <name>" -ForegroundColor Red
            exit 1
        }
        $code = Set-MachineIdentityValue -NewValue $cleanArgs[1] -IsJson $isJson
        exit $code
    }

    { $_ -in @("revert", "rollback", "undo") } {
        $code = Revert-MachineIdentityValue -IsJson $isJson
        exit $code
    }

    default {
        # Positional value passed directly: .\run.ps1 machine my-node-01
        if ($cleanArgs.Count -gt 0 -and -not [string]::IsNullOrWhiteSpace($cleanArgs[0])) {
            $code = Set-MachineIdentityValue -NewValue $cleanArgs[0] -IsJson $isJson
            exit $code
        }

        $id = Get-MachineIdentityData
        if ($isJson) {
            $id | ConvertTo-Json -Depth 4
        } else {
            Show-MachineIdentityView -Identity $id
        }
        exit 0
    }
}
