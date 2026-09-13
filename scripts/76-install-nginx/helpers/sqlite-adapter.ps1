# --------------------------------------------------------------------------
#  Helper: SQLite Adapter for Windows Nginx Domain Manager
#  Provides multi-tier SQLite persistence (sqlite3 CLI -> python3 bridge fallback)
#  Schema manages domains, domain_history, and domain_settings.
# --------------------------------------------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-NginxDbPath {
    param([string]$CustomPath = "")
    if (-not [string]::IsNullOrWhiteSpace($CustomPath)) {
        return $CustomPath
    }
    if (-not [string]::IsNullOrWhiteSpace($env:NGINX_DB_PATH)) {
        return $env:NGINX_DB_PATH
    }

    # Check repo root .installed
    $repoRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
    $installedDir = Join-Path $repoRoot ".installed"
    if (Test-Path -LiteralPath $installedDir) {
        return (Join-Path $installedDir "nginx-domains.sqlite3")
    }

    $appDataDir = Join-Path $env:LOCALAPPDATA "scripts-fixer"
    if (-not (Test-Path -LiteralPath $appDataDir)) {
        New-Item -ItemType Directory -Path $appDataDir -Force | Out-Null
    }
    return (Join-Path $appDataDir "nginx-domains.sqlite3")
}

function Find-SqliteExecutable {
    $cmd = Get-Command "sqlite3.exe" -ErrorAction SilentlyContinue
    if ($null -ne $cmd) {
        return $cmd.Source
    }
    $candidates = @(
        "C:\tools\sqlite\sqlite3.exe",
        "C:\ProgramData\chocolatey\bin\sqlite3.exe",
        "C:\sqlite\sqlite3.exe"
    )
    foreach ($cand in $candidates) {
        if (Test-Path -LiteralPath $cand) {
            return $cand
        }
    }
    return $null
}

function Find-PythonExecutable {
    $cmd = Get-Command "python.exe" -ErrorAction SilentlyContinue
    if ($null -ne $cmd) {
        return $cmd.Source
    }
    $py = Get-Command "py.exe" -ErrorAction SilentlyContinue
    if ($null -ne $py) {
        return $py.Source
    }
    $candidates = @(
        "C:\Python313\python.exe",
        "C:\Python312\python.exe",
        "C:\Python311\python.exe",
        "C:\tools\python\python.exe",
        "E:\dev-tool\python\Python313\python.exe"
    )
    foreach ($cand in $candidates) {
        if (Test-Path -LiteralPath $cand) {
            return $cand
        }
    }
    return $null
}

function Invoke-NginxDbExec {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Sql,

        [string]$DbPath = ""
    )

    $db = Get-NginxDbPath -CustomPath $DbPath
    $dbDir = Split-Path -Parent $db
    if (-not [string]::IsNullOrWhiteSpace($dbDir) -and -not (Test-Path -LiteralPath $dbDir)) {
        New-Item -ItemType Directory -Path $dbDir -Force | Out-Null
    }

    $sqliteExe = Find-SqliteExecutable
    if ($null -ne $sqliteExe) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $sqliteExe
        $psi.Arguments = "-bail `"$db`""
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        $proc.StandardInput.Write($Sql)
        $proc.StandardInput.Close()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()

        if ($proc.ExitCode -ne 0) {
            throw "SQLite CLI Error: $stderr"
        }
        return
    }

    $pythonExe = Find-PythonExecutable
    $bridgePy = Join-Path $PSScriptRoot "sqlite-bridge.py"
    if ($null -ne $pythonExe -and (Test-Path -LiteralPath $bridgePy)) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $pythonExe
        $psi.Arguments = "`"$bridgePy`" exec `"$db`""
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        $proc.StandardInput.Write($Sql)
        $proc.StandardInput.Close()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()

        if ($proc.ExitCode -ne 0) {
            throw "Python SQLite Exec Error: $stderr"
        }
        return
    }

    throw "Neither sqlite3.exe nor python.exe with sqlite-bridge.py found to execute SQLite query."
}

function Invoke-NginxDbQueryTsv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Sql,

        [string]$DbPath = ""
    )

    $db = Get-NginxDbPath -CustomPath $DbPath
    if (-not (Test-Path -LiteralPath $db)) {
        return @()
    }
    $fileInfo = Get-Item -LiteralPath $db
    if ($fileInfo.Length -eq 0) {
        return @()
    }

    $sqliteExe = Find-SqliteExecutable
    if ($null -ne $sqliteExe) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $sqliteExe
        $psi.Arguments = "-separator `"|`" `"$db`""
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        $proc.StandardInput.Write($Sql)
        $proc.StandardInput.Close()
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()

        if ($proc.ExitCode -ne 0) {
            throw "SQLite Query Error: $stderr"
        }
        if ([string]::IsNullOrWhiteSpace($stdout)) {
            return @()
        }
        return @($stdout -split "\r?\n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }

    $pythonExe = Find-PythonExecutable
    $bridgePy = Join-Path $PSScriptRoot "sqlite-bridge.py"
    if ($null -ne $pythonExe -and (Test-Path -LiteralPath $bridgePy)) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $pythonExe
        $psi.Arguments = "`"$bridgePy`" query `"$db`""
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $proc = [System.Diagnostics.Process]::Start($psi)
        $proc.StandardInput.Write($Sql)
        $proc.StandardInput.Close()
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()

        if ($proc.ExitCode -ne 0) {
            throw "Python SQLite Query Error: $stderr"
        }
        if ([string]::IsNullOrWhiteSpace($stdout)) {
            return @()
        }
        return @($stdout -split "\r?\n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    }

    throw "Neither sqlite3.exe nor python.exe with sqlite-bridge.py found to query SQLite."
}

function Initialize-NginxDatabase {
    param([string]$DbPath = "")
    $db = Get-NginxDbPath -CustomPath $DbPath

    $schema = @"
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS domains (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    domain        TEXT NOT NULL UNIQUE,
    subdomain_of  TEXT DEFAULT '',
    type          TEXT NOT NULL CHECK (type IN ('static', 'php', 'wordpress', 'laravel', 'proxy')),
    port          INTEGER NOT NULL DEFAULT 80,
    ssl_port      INTEGER DEFAULT 443,
    root_path     TEXT NOT NULL DEFAULT '',
    php_version   TEXT DEFAULT '',
    php_socket    TEXT DEFAULT '127.0.0.1:9000',
    proxy_pass    TEXT DEFAULT '',
    ssl_enabled   INTEGER NOT NULL DEFAULT 0,
    ssl_cert      TEXT DEFAULT '',
    ssl_key       TEXT DEFAULT '',
    status        TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled', 'deleted')),
    vhost_file    TEXT NOT NULL DEFAULT '',
    ini_file      TEXT NOT NULL DEFAULT '',
    created_at    TEXT NOT NULL DEFAULT (datetime('now', 'localtime')),
    updated_at    TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE INDEX IF NOT EXISTS idx_domains_domain ON domains(domain);
CREATE INDEX IF NOT EXISTS idx_domains_type ON domains(type);
CREATE INDEX IF NOT EXISTS idx_domains_status ON domains(status);

CREATE TABLE IF NOT EXISTS domain_history (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    domain       TEXT NOT NULL,
    action       TEXT NOT NULL CHECK (action IN ('CREATE', 'UPDATE', 'ENABLE', 'DISABLE', 'DELETE', 'SYNC', 'ERROR')),
    diff_summary TEXT DEFAULT '',
    operator     TEXT NOT NULL DEFAULT 'admin',
    created_at   TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);

CREATE INDEX IF NOT EXISTS idx_history_domain ON domain_history(domain);

CREATE TABLE IF NOT EXISTS domain_settings (
    key          TEXT PRIMARY KEY,
    value        TEXT NOT NULL,
    updated_at   TEXT NOT NULL DEFAULT (datetime('now', 'localtime'))
);
"@
    Invoke-NginxDbExec -Sql $schema -DbPath $db
}

function Ensure-NginxDatabaseInit {
    param([string]$DbPath = "")
    $db = Get-NginxDbPath -CustomPath $DbPath
    $isMissing = -not (Test-Path -LiteralPath $db)
    if ($isMissing) {
        Initialize-NginxDatabase -DbPath $db
        return
    }
    $fileInfo = Get-Item -LiteralPath $db
    if ($fileInfo.Length -eq 0) {
        Initialize-NginxDatabase -DbPath $db
    }
}

function Add-NginxDomainRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        [string]$SubdomainOf = "",
        [string]$Type = "static",
        [int]$Port = 80,
        [string]$RootPath = "",
        [string]$PhpVersion = "",
        [string]$PhpSocket = "127.0.0.1:9000",
        [string]$ProxyPass = "",
        [int]$SslEnabled = 0,
        [string]$VhostFile = "",
        [string]$IniFile = "",
        [string]$DbPath = ""
    )

    Ensure-NginxDatabaseInit -DbPath $DbPath

    $safeDomain = $Domain.Replace("'", "''")
    $safeSub = $SubdomainOf.Replace("'", "''")
    $safeRoot = $RootPath.Replace("'", "''")
    $safeSock = $PhpSocket.Replace("'", "''")
    $safeProxy = $ProxyPass.Replace("'", "''")
    $safeVhost = $VhostFile.Replace("'", "''")
    $safeIni = $IniFile.Replace("'", "''")

    $sql = @"
INSERT INTO domains (
    domain, subdomain_of, type, port, root_path, php_version, php_socket,
    proxy_pass, ssl_enabled, status, vhost_file, ini_file, created_at, updated_at
) VALUES (
    '$safeDomain', '$safeSub', '$Type', $Port, '$safeRoot', '$PhpVersion', '$safeSock',
    '$safeProxy', $SslEnabled, 'active', '$safeVhost', '$safeIni',
    datetime('now', 'localtime'), datetime('now', 'localtime')
)
ON CONFLICT(domain) DO UPDATE SET
    subdomain_of = excluded.subdomain_of,
    type = excluded.type,
    port = excluded.port,
    root_path = excluded.root_path,
    php_version = excluded.php_version,
    php_socket = excluded.php_socket,
    proxy_pass = excluded.proxy_pass,
    ssl_enabled = excluded.ssl_enabled,
    status = 'active',
    vhost_file = excluded.vhost_file,
    ini_file = excluded.ini_file,
    updated_at = datetime('now', 'localtime');

INSERT INTO domain_history (domain, action, diff_summary, operator, created_at)
VALUES ('$safeDomain', 'CREATE', 'Added or updated domain $safeDomain (type=$Type, port=$Port)', '$env:USERNAME', datetime('now', 'localtime'));
"@
    Invoke-NginxDbExec -Sql $sql -DbPath $DbPath
}

function Remove-NginxDomainRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        [switch]$Purge,
        [string]$DbPath = ""
    )

    Ensure-NginxDatabaseInit -DbPath $DbPath
    $safeDomain = $Domain.Replace("'", "''")

    if ($Purge) {
        $sql = @"
DELETE FROM domains WHERE domain = '$safeDomain';
INSERT INTO domain_history (domain, action, diff_summary, operator, created_at)
VALUES ('$safeDomain', 'DELETE', 'Purged record for $safeDomain from database', '$env:USERNAME', datetime('now', 'localtime'));
"@
    } else {
        $sql = @"
UPDATE domains SET status = 'deleted', updated_at = datetime('now', 'localtime') WHERE domain = '$safeDomain';
INSERT INTO domain_history (domain, action, diff_summary, operator, created_at)
VALUES ('$safeDomain', 'DELETE', 'Marked $safeDomain as deleted', '$env:USERNAME', datetime('now', 'localtime'));
"@
    }
    Invoke-NginxDbExec -Sql $sql -DbPath $DbPath
}

function Get-NginxDomainRecords {
    param(
        [switch]$All,
        [string]$DbPath = ""
    )

    Ensure-NginxDatabaseInit -DbPath $DbPath

    $whereClause = if ($All) { "1=1" } else { "status = 'active'" }
    $sql = "SELECT id, domain, subdomain_of, type, port, root_path, php_socket, proxy_pass, ssl_enabled, status, vhost_file, ini_file, created_at, updated_at FROM domains WHERE $whereClause ORDER BY domain ASC;"

    $lines = @(Invoke-NginxDbQueryTsv -Sql $sql -DbPath $DbPath)
    $records = @()

    foreach ($line in $lines) {
        $parts = @($line.Split('|'))
        if ($parts.Length -ge 14) {
            $record = [PSCustomObject]@{
                Id          = $parts[0]
                Domain      = $parts[1]
                SubdomainOf = $parts[2]
                Type        = $parts[3]
                Port        = [int]$parts[4]
                RootPath    = $parts[5]
                PhpSocket   = $parts[6]
                ProxyPass   = $parts[7]
                SslEnabled  = [int]$parts[8]
                Status      = $parts[9]
                VhostFile   = $parts[10]
                IniFile     = $parts[11]
                CreatedAt   = $parts[12]
                UpdatedAt   = $parts[13]
            }
            $records += $record
        }
    }
    return $records
}

function Get-NginxDomainRecord {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        [string]$DbPath = ""
    )

    Ensure-NginxDatabaseInit -DbPath $DbPath
    $safeDomain = $Domain.Replace("'", "''")
    $sql = "SELECT id, domain, subdomain_of, type, port, root_path, php_socket, proxy_pass, ssl_enabled, status, vhost_file, ini_file, created_at, updated_at FROM domains WHERE domain = '$safeDomain' LIMIT 1;"

    $lines = @(Invoke-NginxDbQueryTsv -Sql $sql -DbPath $DbPath)
    if ($lines.Length -eq 0) {
        return $null
    }
    $parts = @($lines[0].Split('|'))
    if ($parts.Length -ge 14) {
        return [PSCustomObject]@{
            Id          = $parts[0]
            Domain      = $parts[1]
            SubdomainOf = $parts[2]
            Type        = $parts[3]
            Port        = [int]$parts[4]
            RootPath    = $parts[5]
            PhpSocket   = $parts[6]
            ProxyPass   = $parts[7]
            SslEnabled  = [int]$parts[8]
            Status      = $parts[9]
            VhostFile   = $parts[10]
            IniFile     = $parts[11]
            CreatedAt   = $parts[12]
            UpdatedAt   = $parts[13]
        }
    }
    return $null
}

function Get-NginxDomainHistory {
    param(
        [string]$Domain = "",
        [int]$Limit = 20,
        [string]$DbPath = ""
    )

    Ensure-NginxDatabaseInit -DbPath $DbPath
    $whereClause = if (-not [string]::IsNullOrWhiteSpace($Domain)) { "WHERE domain = '$($Domain.Replace("'", "''"))'" } else { "" }
    $sql = "SELECT id, domain, action, diff_summary, operator, created_at FROM domain_history $whereClause ORDER BY id DESC LIMIT $Limit;"

    $lines = @(Invoke-NginxDbQueryTsv -Sql $sql -DbPath $DbPath)
    $history = @()
    foreach ($line in $lines) {
        $parts = @($line.Split('|'))
        if ($parts.Length -ge 6) {
            $history += [PSCustomObject]@{
                Id          = $parts[0]
                Domain      = $parts[1]
                Action      = $parts[2]
                DiffSummary = $parts[3]
                Operator    = $parts[4]
                CreatedAt   = $parts[5]
            }
        }
    }
    return $history
}
