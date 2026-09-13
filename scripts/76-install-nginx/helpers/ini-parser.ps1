# --------------------------------------------------------------------------
#  Helper: INI Parser & Two-Way Synchronizer for Windows Nginx Domain Manager
#  Provides pure PowerShell INI file reading, writing, and SQLite synchronization.
# --------------------------------------------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-DefaultIniPath {
    $scriptDir = Split-Path -Parent $PSScriptRoot
    $localIni = Join-Path $scriptDir "domains.ini"
    return $localIni
}

function Import-NginxIni {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $data = @{}
    if (-not (Test-Path -LiteralPath $FilePath)) {
        return $data
    }

    $currentSection = ""
    $lines = Get-Content -LiteralPath $FilePath

    foreach ($rawLine in $lines) {
        $line = $rawLine.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#") -or $line.StartsWith(";")) {
            continue
        }

        if ($line -match '^\[(.*)\]$') {
            $currentSection = $Matches[1].Trim()
            if (-not $data.ContainsKey($currentSection)) {
                $data[$currentSection] = @{}
            }
            continue
        }

        if ($line -match '^([^=]+)=(.*)$') {
            $key = $Matches[1].Trim()
            $val = $Matches[2].Trim()
            # Strip surrounding quotes if present
            if ($val.StartsWith('"') -and $val.EndsWith('"') -and $val.Length -ge 2) {
                $val = $val.Substring(1, $val.Length - 2)
            }
            if (-not [string]::IsNullOrWhiteSpace($currentSection)) {
                $data[$currentSection][$key] = $val
            }
        }
    }

    return $data
}

function Export-NginxIni {
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Data,

        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )

    $parentDir = Split-Path -Parent $FilePath
    if (-not [string]::IsNullOrWhiteSpace($parentDir) -and -not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    $now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $content = New-Object System.Text.StringBuilder
    [void]$content.AppendLine("# --------------------------------------------------------------------------")
    [void]$content.AppendLine("#  scripts-fixer Nginx Domains Registry")
    [void]$content.AppendLine("#  Last synchronized: $now")
    [void]$content.AppendLine("#  Two-way synchronized with SQLite database (nginx-domains.sqlite3)")
    [void]$content.AppendLine("# --------------------------------------------------------------------------")
    [void]$content.AppendLine("")

    $sortedSections = $Data.Keys | Sort-Object
    foreach ($section in $sortedSections) {
        [void]$content.AppendLine("[$section]")
        $subHash = $Data[$section]
        $sortedKeys = $subHash.Keys | Sort-Object
        foreach ($k in $sortedKeys) {
            $v = $subHash[$k]
            [void]$content.AppendLine("  $k = $v")
        }
        [void]$content.AppendLine("")
    }

    [System.IO.File]::WriteAllText($FilePath, $content.ToString(), (New-Object System.Text.UTF8Encoding($false)))
}

function Sync-DomainsToIni {
    param(
        [string]$IniPath = "",
        [string]$DbPath = ""
    )

    if ([string]::IsNullOrWhiteSpace($IniPath)) {
        $IniPath = Get-DefaultIniPath
    }

    $records = Get-NginxDomainRecords -All:$false -DbPath $DbPath
    $iniData = @{}

    foreach ($rec in $records) {
        $sec = $rec.Domain
        $iniData[$sec] = @{
            "type"         = $rec.Type
            "port"         = $rec.Port
            "root"         = $rec.RootPath
            "subdomain_of" = $rec.SubdomainOf
            "php_socket"   = $rec.PhpSocket
            "proxy_pass"   = $rec.ProxyPass
            "ssl"          = $rec.SslEnabled
            "status"       = $rec.Status
            "vhost_file"   = $rec.VhostFile
            "created_at"   = $rec.CreatedAt
            "updated_at"   = $rec.UpdatedAt
        }
    }

    Export-NginxIni -Data $iniData -FilePath $IniPath
    return $iniData
}

function Sync-IniToDomains {
    param(
        [string]$IniPath = "",
        [string]$DbPath = ""
    )

    if ([string]::IsNullOrWhiteSpace($IniPath)) {
        $IniPath = Get-DefaultIniPath
    }

    if (-not (Test-Path -LiteralPath $IniPath)) {
        return @()
    }

    $iniData = Import-NginxIni -FilePath $IniPath
    $synced = @()

    foreach ($domain in $iniData.Keys) {
        $item = $iniData[$domain]
        $type = if ($item.ContainsKey("type")) { $item["type"] } else { "static" }
        $port = if ($item.ContainsKey("port")) { [int]$item["port"] } else { 80 }
        $root = if ($item.ContainsKey("root")) { $item["root"] } else { "" }
        $subOf = if ($item.ContainsKey("subdomain_of")) { $item["subdomain_of"] } else { "" }
        $phpSock = if ($item.ContainsKey("php_socket")) { $item["php_socket"] } else { "127.0.0.1:9000" }
        $proxy = if ($item.ContainsKey("proxy_pass")) { $item["proxy_pass"] } else { "" }
        $ssl = if ($item.ContainsKey("ssl")) { [int]$item["ssl"] } else { 0 }
        $vhost = if ($item.ContainsKey("vhost_file")) { $item["vhost_file"] } else { "" }
        $status = if ($item.ContainsKey("status")) { $item["status"] } else { "active" }

        Add-NginxDomainRecord `
            -Domain $domain `
            -SubdomainOf $subOf `
            -Type $type `
            -Port $port `
            -RootPath $root `
            -PhpSocket $phpSock `
            -ProxyPass $proxy `
            -SslEnabled $ssl `
            -VhostFile $vhost `
            -IniFile $IniPath `
            -DbPath $DbPath

        $synced += $domain
    }

    return $synced
}
