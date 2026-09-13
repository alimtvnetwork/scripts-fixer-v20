# --------------------------------------------------------------------------
#  Script 76 -- Install & Manage Nginx on Windows
#  Virtual Host & Domain Manager with SQLite DB & Declarative INI Sync
# --------------------------------------------------------------------------
param(
    [Parameter(Position = 0)]
    [string]$Command = "help",

    [Parameter(Position = 1)]
    [string]$TargetDomain = "",

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs,

    [switch]$Help,
    [switch]$Interactive,
    [string]$Type = "static",
    [int]$Port = 80,
    [string]$Root = "",
    [string]$Php = "8.3",
    [string]$Proxy = "",
    [switch]$Ssl,
    [switch]$Purge,
    [switch]$Force,
    [switch]$Sync,
    [switch]$Keep,
    [switch]$Json,
    [string]$Mode = "default"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"
$helpersDir = Join-Path $scriptDir "helpers"
$script:ScriptDir = $scriptDir

# -- Dot-source shared helpers ------------------------------------------------
. (Join-Path $sharedDir "logging.ps1")
. (Join-Path $sharedDir "resolved.ps1")
. (Join-Path $sharedDir "git-pull.ps1")
. (Join-Path $sharedDir "help.ps1")
. (Join-Path $sharedDir "choco-utils.ps1")
. (Join-Path $sharedDir "installed.ps1")
. (Join-Path $sharedDir "interactive.ps1")
. (Join-Path $sharedDir "install-paths.ps1")

# -- Dot-source local domain manager helpers ----------------------------------
. (Join-Path $helpersDir "sqlite-adapter.ps1")
. (Join-Path $helpersDir "ini-parser.ps1")
. (Join-Path $helpersDir "vhost-compiler.ps1")
. (Join-Path $helpersDir "hosts-helper.ps1")
. (Join-Path $helpersDir "showcase-manager.ps1")

$config = Import-JsonConfig (Join-Path $scriptDir "config.json")
$logMessages = Import-JsonConfig (Join-Path $scriptDir "log-messages.json")

# Process flexible CLI arguments (--type, --port, -y, etc.)
$rem = @($RemainingArgs)
if ($rem.Length -gt 0) {
    for ($i = 0; $i -lt $rem.Length; $i++) {
        $arg = $rem[$i]
        if ($arg -in @("--type", "-t", "-Type") -and ($i + 1) -lt $rem.Length) {
            $Type = $rem[++$i]
        } elseif ($arg -in @("--port", "-p", "-Port") -and ($i + 1) -lt $rem.Length) {
            $Port = [int]$rem[++$i]
        } elseif ($arg -in @("--root", "-r", "-Root") -and ($i + 1) -lt $rem.Length) {
            $Root = $rem[++$i]
        } elseif ($arg -in @("--php", "-Php") -and ($i + 1) -lt $rem.Length) {
            $Php = $rem[++$i]
        } elseif ($arg -in @("--proxy", "-Proxy") -and ($i + 1) -lt $rem.Length) {
            $Proxy = $rem[++$i]
        } elseif ($arg -in @("--ssl", "-s", "-Ssl")) {
            $Ssl = $true
        } elseif ($arg -in @("--purge", "-Purge")) {
            $Purge = $true
        } elseif ($arg -in @("-y", "--yes", "--force", "-f", "-Force")) {
            $Force = $true
        } elseif ($arg -in @("--sync", "-Sync")) {
            $Sync = $true
        } elseif ($arg -in @("--keep", "-Keep")) {
            $Keep = $true
        } elseif ($arg -in @("--json", "-Json")) {
            $Json = $true
        } elseif (-not [string]::IsNullOrWhiteSpace($arg) -and [string]::IsNullOrWhiteSpace($TargetDomain) -and -not $arg.StartsWith("-")) {
            $TargetDomain = $arg
        }
    }
}

function Find-NginxExe {
    $cmd = Get-Command "nginx.exe" -ErrorAction SilentlyContinue
    if ($null -ne $cmd) {
        return $cmd.Source
    }
    $candidates = @(
        "C:\tools\nginx\nginx.exe",
        "C:\nginx\nginx.exe",
        (Join-Path $env:ProgramFiles "nginx\nginx.exe")
    )
    foreach ($cand in $candidates) {
        if (Test-Path -LiteralPath $cand) {
            return $cand
        }
    }
    return $null
}

function Get-NginxVersion {
    $exe = Find-NginxExe
    if ($null -eq $exe) { return "unknown" }
    try {
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $exe
        $pinfo.Arguments = "-v"
        $pinfo.RedirectStandardError = $true
        $pinfo.UseShellExecute = $false
        $p = [System.Diagnostics.Process]::Start($pinfo)
        $stderr = $p.StandardError.ReadToEnd()
        $p.WaitForExit()
        if ($stderr -match 'nginx/([0-9.]+)') {
            return $Matches[1]
        }
    } catch {
        return "unknown"
    }
    return "unknown"
}

function Show-NginxHelp {
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "                NGINX & VIRTUAL HOST DOMAIN MANAGER (WINDOWS)                   " -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\run.ps1 nginx <command> [options]"
    Write-Host "  .\run.ps1 nginx install"
    Write-Host "  .\run.ps1 nginx help"
    Write-Host "  .\run.ps1 nginx add <domain> [--type <static|php|wordpress|laravel|proxy>] [--port <80>] [--root <path>]"
    Write-Host "  .\run.ps1 nginx rm <domain> [--purge] [-y]"
    Write-Host "  .\run.ps1 nginx list [--json]"
    Write-Host "  .\run.ps1 nginx ini [--sync]"
    Write-Host "  .\run.ps1 nginx showcase [--keep]"
    Write-Host "  .\run.ps1 nginx start | stop | reload | status | test"
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  install     Install Nginx Web Server via Chocolatey"
    Write-Host "  help        Display this help message"
    Write-Host "  add         Register domain / subdomain in SQLite, generate vhost conf, sync to INI"
    Write-Host "  rm          Remove / unlink virtual host, update SQLite, sync to INI"
    Write-Host "  list        List all registered virtual host domains from SQLite"
    Write-Host "  ini         Show declarative domains.ini file or run two-way sync"
    Write-Host "  showcase    Demonstrate before/after Tri-State sync across SQLite, INI, and vhosts"
    Write-Host "  reload      Hot-reload Nginx configuration with syntax validation gate (nginx -t)"
    Write-Host "  status      Check running status of Nginx process"
    Write-Host "  start       Start Nginx background process"
    Write-Host "  stop        Stop running Nginx process"
    Write-Host ""
    Write-Host "Storage:" -ForegroundColor Yellow
    Write-Host "  SQLite DB : .installed\nginx-domains.sqlite3 (or %LOCALAPPDATA%\scripts-fixer\nginx-domains.sqlite3)"
    Write-Host "  INI File  : scripts\76-install-nginx\domains.ini"
    Write-Host "  Vhosts    : C:\tools\nginx\conf\conf.d\*.conf"
    Write-Host ""
}

function Invoke-NginxInstall {
    Write-Banner -Title $logMessages.scriptName
    Write-Log -Level "INFO" -Message $logMessages.messages.checking

    $existingExe = Find-NginxExe
    if ($null -ne $existingExe) {
        $ver = Get-NginxVersion
        Write-Log -Level "OK" -Message ($logMessages.messages.found -replace '\{version\}', $ver)
        Set-InstalledTracker -ScriptId "76"
        Ensure-NginxDatabaseInit
        Ensure-NginxConfIncludes -NginxExe $existingExe
        return
    }

    Write-InstallPaths `
        -Tool "Nginx Web Server" `
        -Source "Chocolatey (package: nginx)" `
        -Temp "C:\Users\$env:USERNAME\AppData\Local\Temp\chocolatey" `
        -Target "C:\tools\nginx"

    Write-Log -Level "INFO" -Message $logMessages.messages.installing
    try {
        Install-ChocoPackage -PackageName $config.nginx.chocoPackage
        $installedExe = Find-NginxExe
        if ($null -ne $installedExe) {
            $ver = Get-NginxVersion
            Write-Log -Level "OK" -Message ($logMessages.messages.installSuccess -replace '\{version\}', $ver)
            Set-InstalledTracker -ScriptId "76"
            Ensure-NginxDatabaseInit
            Ensure-NginxConfIncludes -NginxExe $installedExe
        } else {
            Write-FileError -Path "C:\tools\nginx\nginx.exe" -Reason "Nginx executable not found after Chocolatey install"
        }
    } catch {
        Write-FileError -Path "C:\tools\nginx" -Reason $_.Exception.Message
        throw
    }
}

function Invoke-NginxAddDomain {
    if ([string]::IsNullOrWhiteSpace($TargetDomain)) {
        Write-FileError -Path "TargetDomain" -Reason "No domain specified. Usage: .\run.ps1 nginx add <domain> [options]"
        exit 1
    }

    $domain = $TargetDomain.ToLowerInvariant().Trim()
    $validTypes = @("static", "php", "wordpress", "laravel", "proxy")
    if ($Type.ToLowerInvariant() -notin $validTypes) {
        Write-FileError -Path "Type" -Reason "Invalid type '$Type'. Must be one of: $($validTypes -join ', ')"
        exit 1
    }

    # Determine subdomain status
    $subdomainOf = ""
    $parts = @($domain.Split('.'))
    if ($parts.Length -gt 2) {
        $subdomainOf = ($parts[-2..-1]) -join '.'
    }

    # Resolve default root directory if empty
    $resolvedRoot = $Root
    if ([string]::IsNullOrWhiteSpace($resolvedRoot)) {
        if ($Type.ToLowerInvariant() -eq "laravel") {
            $resolvedRoot = "C:/tools/nginx/html/$domain/public"
        } elseif ($Type.ToLowerInvariant() -ne "proxy") {
            $resolvedRoot = "C:/tools/nginx/html/$domain"
        }
    }

    # Create root directory if static/php/wordpress/laravel
    if ($Type.ToLowerInvariant() -ne "proxy" -and -not [string]::IsNullOrWhiteSpace($resolvedRoot)) {
        $localRoot = $resolvedRoot.Replace("/", "\")
        if (-not (Test-Path -LiteralPath $localRoot)) {
            New-Item -ItemType Directory -Path $localRoot -Force | Out-Null
            $indexHtml = Join-Path $localRoot "index.html"
            if (-not (Test-Path -LiteralPath $indexHtml)) {
                $welcome = "<h1>Welcome to $domain</h1><p>Configured by scripts-fixer Nginx Domain Manager (Windows)</p>"
                [System.IO.File]::WriteAllText($indexHtml, $welcome, (New-Object System.Text.UTF8Encoding($false)))
            }
        }
    }

    $nginxExe = Find-NginxExe
    Write-Host "  [ ADD ] Generating Nginx virtual host for: $domain (type=$Type, port=$Port)" -ForegroundColor Cyan

    $vhostContent = Build-NginxVhostConfig `
        -Domain $domain `
        -Type $Type `
        -Port $Port `
        -RootPath $resolvedRoot `
        -PhpSocket "127.0.0.1:9000" `
        -ProxyPass $Proxy `
        -SslEnabled $(if ($Ssl) { 1 } else { 0 })

    $savedConf = Save-NginxVhostConfig -Domain $domain -ConfigContent $vhostContent -NginxExe $nginxExe

    # Commit to SQLite database
    Add-NginxDomainRecord `
        -Domain $domain `
        -SubdomainOf $subdomainOf `
        -Type $Type `
        -Port $Port `
        -RootPath $resolvedRoot `
        -PhpSocket "127.0.0.1:9000" `
        -ProxyPass $Proxy `
        -SslEnabled $(if ($Ssl) { 1 } else { 0 }) `
        -VhostFile $savedConf `
        -IniFile (Get-DefaultIniPath)

    # Sync to INI file
    Sync-DomainsToIni | Out-Null

    # Optional local DNS loopback mapping
    Add-HostsEntry -Domain $domain | Out-Null

    Write-Host "  [ OK ] Virtual host compiled -> $savedConf" -ForegroundColor Green
    Write-Host "  [ OK ] Recorded in SQLite database." -ForegroundColor Green
    Write-Host "  [ OK ] Synchronized to INI ledger ($(Get-DefaultIniPath))." -ForegroundColor Green

    # Attempt hot-reload if running
    $proc = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
    if ($null -ne $proc -and $null -ne $nginxExe) {
        Invoke-NginxReload
    }
}

function Invoke-NginxRmDomain {
    if ([string]::IsNullOrWhiteSpace($TargetDomain)) {
        Write-FileError -Path "TargetDomain" -Reason "No domain specified. Usage: .\run.ps1 nginx rm <domain> [--purge] [-y]"
        exit 1
    }

    $domain = $TargetDomain.ToLowerInvariant().Trim()
    $nginxExe = Find-NginxExe

    Write-Host "  [ RM ] Removing virtual host: $domain" -ForegroundColor Yellow

    # Remove vhost config
    Remove-NginxVhostConfig -Domain $domain -NginxExe $nginxExe -Purge:$Purge | Out-Null

    # Update or purge record in SQLite database
    Remove-NginxDomainRecord -Domain $domain -Purge:$Purge

    # Synchronize to INI file
    Sync-DomainsToIni | Out-Null

    # Remove local DNS mapping if present
    Remove-HostsEntry -Domain $domain | Out-Null

    Write-Host "  [ OK ] Domain '$domain' removed." -ForegroundColor Green
    Write-Host "  [ OK ] Updated in SQLite database." -ForegroundColor Green
    Write-Host "  [ OK ] Synchronized to INI ledger." -ForegroundColor Green

    # Reload Nginx if running
    $proc = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
    if ($null -ne $proc -and $null -ne $nginxExe) {
        Invoke-NginxReload
    }
}

function Invoke-NginxListDomains {
    $records = @(Get-NginxDomainRecords -All:$false)

    if ($Json) {
        $records | ConvertTo-Json -Depth 4
        return
    }

    Write-Host ""
    Write-Host "Registered Nginx Virtual Hosts (SQLite Ledger):" -ForegroundColor Cyan
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    if ($records.Length -eq 0) {
        Write-Host "  No virtual host domains registered yet." -ForegroundColor Yellow
        Write-Host "  Add one with: .\run.ps1 nginx add <domain> [--type <static|php|wordpress|laravel|proxy>]" -ForegroundColor Gray
        Write-Host ""
        return
    }

    Write-Host ("{0,-28} {1,-10} {2,-6} {3,-8} {4}" -f "DOMAIN", "TYPE", "PORT", "STATUS", "ROOT / UPSTREAM") -ForegroundColor White
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    foreach ($rec in $records) {
        $target = if ($rec.Type -eq "proxy") { $rec.ProxyPass } else { $rec.RootPath }
        Write-Host ("{0,-28} {1,-10} {2,-6} {3,-8} {4}" -f $rec.Domain, $rec.Type, $rec.Port, $rec.Status, $target) -ForegroundColor Green
    }
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    Write-Host ("Total active domains: {0}" -f $records.Length) -ForegroundColor Gray
    Write-Host ""
}

function Invoke-NginxIniDisplay {
    $iniPath = Get-DefaultIniPath
    if ($Sync) {
        Write-Host "  [ SYNC ] Running two-way synchronization between INI and SQLite..." -ForegroundColor Cyan
        Sync-IniToDomains -IniPath $iniPath | Out-Null
        Sync-DomainsToIni -IniPath $iniPath | Out-Null
        Write-Host "  [ OK ] INI and SQLite database are in sync." -ForegroundColor Green
        return
    }

    Write-Host ""
    Write-Host "Declarative Domains INI File ($iniPath):" -ForegroundColor Cyan
    Write-Host ("-" * 70) -ForegroundColor DarkGray
    if (Test-Path -LiteralPath $iniPath) {
        Get-Content -LiteralPath $iniPath
    } else {
        Write-Host "  INI file does not exist yet. Run with --sync to generate it." -ForegroundColor Yellow
    }
    Write-Host ("-" * 70) -ForegroundColor DarkGray
    Write-Host ""
}

function Invoke-NginxStart {
    $exe = Find-NginxExe
    if ($null -eq $exe) {
        Write-FileError -Path "nginx.exe" -Reason "Cannot start Nginx; executable not found."
        return
    }
    $nginxDir = Split-Path -Parent $exe
    Start-Process -FilePath $exe -WorkingDirectory $nginxDir
    Write-Log -Level "OK" -Message $logMessages.messages.serviceStarted
}

function Invoke-NginxStop {
    $exe = Find-NginxExe
    if ($null -eq $exe) { return }
    $nginxDir = Split-Path -Parent $exe
    Start-Process -FilePath $exe -ArgumentList "-s stop" -WorkingDirectory $nginxDir -Wait
    Write-Log -Level "OK" -Message $logMessages.messages.serviceStopped
}

function Invoke-NginxReload {
    $exe = Find-NginxExe
    if ($null -eq $exe) { return }
    $nginxDir = Split-Path -Parent $exe

    $syntaxOk = Test-NginxSyntax -NginxExe $exe
    if (-not $syntaxOk) {
        Write-FileError -Path "nginx.conf" -Reason "Nginx configuration syntax test failed. Aborting reload."
        return
    }

    Start-Process -FilePath $exe -ArgumentList "-s reload" -WorkingDirectory $nginxDir -Wait
    Write-Log -Level "OK" -Message $logMessages.messages.serviceReloaded
}

# --------------------------------------------------------------------------
# Main Command Switch
# --------------------------------------------------------------------------
if ($Help -or $Command -in @("--help", "-h", "help")) {
    Show-NginxHelp
    return
}

switch ($Command.ToLowerInvariant()) {
    "all"        { Invoke-NginxInstall }
    "install"    { Invoke-NginxInstall }
    "help"       { Show-NginxHelp }
    "add"        { Invoke-NginxAddDomain }
    "rm"         { Invoke-NginxRmDomain }
    "remove"     { Invoke-NginxRmDomain }
    "delete"     { Invoke-NginxRmDomain }
    "list"       { Invoke-NginxListDomains }
    "ls"         { Invoke-NginxListDomains }
    "ini"        { Invoke-NginxIniDisplay }
    "showcase"   { Invoke-NginxShowcase -Keep:$Keep }
    "check"      {
        $exe = Find-NginxExe
        if ($null -ne $exe) {
            $ver = Get-NginxVersion
            Write-Host "  Nginx is installed: version $ver at $exe" -ForegroundColor Green
        } else {
            Write-Host "  Nginx is NOT installed." -ForegroundColor Red
        }
    }
    "test"       {
        $exe = Find-NginxExe
        if ($null -eq $exe) {
            Write-Host "  Nginx is NOT installed." -ForegroundColor Red
            return
        }
        $ok = Test-NginxSyntax -NginxExe $exe
        if ($ok) {
            Write-Host "  Nginx configuration test passed (nginx -t)." -ForegroundColor Green
        } else {
            Write-Host "  Nginx configuration test FAILED (nginx -t)." -ForegroundColor Red
        }
    }
    "repair"     {
        Remove-InstalledTracker -ScriptId "76"
        Invoke-NginxInstall
    }
    "start"      { Invoke-NginxStart }
    "stop"       { Invoke-NginxStop }
    "reload"     { Invoke-NginxReload }
    "status"     {
        $exe = Find-NginxExe
        $proc = Get-Process -Name "nginx" -ErrorAction SilentlyContinue
        $isRun = ($null -ne $proc)
        $displayPath = if ($null -ne $exe) { $exe } else { "Not found" }
        Write-Host ("  Nginx Path   : {0}" -f $displayPath) -ForegroundColor Cyan
        Write-Host ("  Process State: {0}" -f $(if ($isRun) { "RUNNING" } else { "STOPPED" })) -ForegroundColor $(if ($isRun) { "Green" } else { "Yellow" })
        Invoke-NginxListDomains
    }
    "uninstall"  {
        Invoke-NginxStop
        Uninstall-ChocoPackage -PackageName $config.nginx.chocoPackage
        Remove-InstalledTracker -ScriptId "76"
        Write-Log -Level "OK" -Message $logMessages.messages.uninstallSuccess
    }
    default {
        Show-NginxHelp
    }
}
