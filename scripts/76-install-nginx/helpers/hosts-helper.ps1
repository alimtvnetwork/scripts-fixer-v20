# --------------------------------------------------------------------------
#  Helper: Windows Hosts File Manager
#  Provides safe modification of C:\Windows\System32\drivers\etc\hosts
#  with automatic backups and graceful non-admin fallbacks.
# --------------------------------------------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-WindowsHostsPath {
    return "$env:SystemRoot\System32\drivers\etc\hosts"
}

function Add-HostsEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        [string]$Ip = "127.0.0.1"
    )

    $hostsPath = Get-WindowsHostsPath
    if (-not (Test-Path -LiteralPath $hostsPath)) {
        return $false
    }

    try {
        $content = Get-Content -LiteralPath $hostsPath -ErrorAction Stop
        foreach ($line in $content) {
            $trimmed = $line.Trim()
            if ($trimmed -match "^\s*([0-9a-fA-F\.:]+)\s+.*\b$([regex]::Escape($Domain))\b") {
                return $true # Already present
            }
        }

        # Backup hosts file
        $bakPath = "$hostsPath.bak"
        Copy-Item -LiteralPath $hostsPath -Destination $bakPath -Force -ErrorAction Stop

        $entry = "$Ip $Domain  # scripts-fixer"
        Add-Content -LiteralPath $hostsPath -Value $entry -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Remove-HostsEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain
    )

    $hostsPath = Get-WindowsHostsPath
    if (-not (Test-Path -LiteralPath $hostsPath)) {
        return $false
    }

    try {
        $content = Get-Content -LiteralPath $hostsPath -ErrorAction Stop
        $newLines = @()
        $modified = $false

        foreach ($line in $content) {
            $trimmed = $line.Trim()
            if ($trimmed -match "^\s*([0-9a-fA-F\.:]+)\s+.*\b$([regex]::Escape($Domain))\b.*# scripts-fixer") {
                $modified = $true
                continue
            }
            $newLines += $line
        }

        if ($modified) {
            [System.IO.File]::WriteAllLines($hostsPath, $newLines)
            return $true
        }
        return $false
    } catch {
        return $false
    }
}
