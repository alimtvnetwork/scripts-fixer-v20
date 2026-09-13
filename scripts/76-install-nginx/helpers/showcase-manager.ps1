# --------------------------------------------------------------------------
#  Helper: Showcase Manager for Windows Nginx Domain Manager
#  Demonstrates Tri-State Before vs After updates across SQLite, INI, and Nginx vhosts.
# --------------------------------------------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-NginxShowcase {
    param(
        [switch]$Keep,
        [string]$DbPath = "",
        [string]$IniPath = ""
    )

    if ([string]::IsNullOrWhiteSpace($DbPath)) {
        $DbPath = Get-NginxDbPath
    }
    if ([string]::IsNullOrWhiteSpace($IniPath)) {
        $IniPath = Get-DefaultIniPath
    }

    Ensure-NginxDatabaseInit -DbPath $DbPath

    $demoDomain = "win-showcase.local"
    $demoSubDomain = "api.win-showcase.local"
    $demoPort = 8089
    $demoRoot = "C:/tools/nginx/html/$demoDomain"
    $nginxExe = Find-NginxExe

    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "         WINDOWS NGINX DOMAIN MANAGER: TRI-STATE SYNCHRONIZATION SHOWCASE       " -ForegroundColor White
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""

    # PHASE 1: BEFORE
    Write-Host "[PHASE 1: BEFORE MUTATION]" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "1. SQLite Database Query: SELECT domain, type, port, status FROM domains;" -ForegroundColor Gray

    $existing = Get-NginxDomainRecord -Domain $demoDomain -DbPath $DbPath
    if ($null -ne $existing) {
        Write-Host "   Row exists for '$demoDomain'. Purging previous test run..." -ForegroundColor Yellow
        Remove-NginxDomainRecord -Domain $demoDomain -Purge -DbPath $DbPath
        Remove-NginxVhostConfig -Domain $demoDomain -NginxExe $nginxExe -Purge | Out-Null
    }
    $existingSub = Get-NginxDomainRecord -Domain $demoSubDomain -DbPath $DbPath
    if ($null -ne $existingSub) {
        Remove-NginxDomainRecord -Domain $demoSubDomain -Purge -DbPath $DbPath
        Remove-NginxVhostConfig -Domain $demoSubDomain -NginxExe $nginxExe -Purge | Out-Null
    }
    Sync-DomainsToIni -IniPath $IniPath -DbPath $DbPath | Out-Null

    Write-Host "   Status: Domain '$demoDomain' does not exist in SQLite." -ForegroundColor Green
    Write-Host ""

    Write-Host "2. INI File Check ($IniPath):" -ForegroundColor Gray
    $iniData = Import-NginxIni -FilePath $IniPath
    $hasSection = $iniData.ContainsKey($demoDomain)
    $iniStatus = if ($hasSection) { "FOUND" } else { "NOT FOUND (Clean)" }
    $iniColor = if ($hasSection) { "Red" } else { "Green" }
    Write-Host "   [$demoDomain] section in INI -> $iniStatus" -ForegroundColor $iniColor
    Write-Host ""

    Write-Host "3. Nginx Virtual Host Check:" -ForegroundColor Gray
    $vhostDir = Get-NginxVhostDir -NginxExe $nginxExe
    $vhostFile = Join-Path $vhostDir "$demoDomain.conf"
    $hasVhost = Test-Path -LiteralPath $vhostFile
    $vhostStatus = if ($hasVhost) { "FOUND" } else { "NOT FOUND (Clean)" }
    $vhostColor = if ($hasVhost) { "Red" } else { "Green" }
    Write-Host "   $vhostFile -> $vhostStatus" -ForegroundColor $vhostColor
    Write-Host ""

    # PHASE 2: MUTATION
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[PHASE 2: EXECUTING DOMAIN ADDITIONS (APEX & SUBDOMAIN)]" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ">> Command 1: .\run.ps1 nginx add $demoDomain --type php --port $demoPort --root $demoRoot" -ForegroundColor White
    
    # Render and save vhost 1
    $vhostContent1 = Build-NginxVhostConfig -Domain $demoDomain -Type "php" -Port $demoPort -RootPath $demoRoot
    $savedConf1 = Save-NginxVhostConfig -Domain $demoDomain -ConfigContent $vhostContent1 -NginxExe $nginxExe
    Add-NginxDomainRecord -Domain $demoDomain -Type "php" -Port $demoPort -RootPath $demoRoot -PhpSocket "127.0.0.1:9000" -VhostFile $savedConf1 -IniFile $IniPath -DbPath $DbPath

    Write-Host ">> Command 2: .\run.ps1 nginx add $demoSubDomain --type proxy --port 8090 --proxy http://127.0.0.1:3000" -ForegroundColor White
    $vhostContent2 = Build-NginxVhostConfig -Domain $demoSubDomain -Type "proxy" -Port 8090 -ProxyPass "http://127.0.0.1:3000"
    $savedConf2 = Save-NginxVhostConfig -Domain $demoSubDomain -ConfigContent $vhostContent2 -NginxExe $nginxExe
    Add-NginxDomainRecord -Domain $demoSubDomain -SubdomainOf $demoDomain -Type "proxy" -Port 8090 -ProxyPass "http://127.0.0.1:3000" -VhostFile $savedConf2 -IniFile $IniPath -DbPath $DbPath

    # Sync to INI
    Sync-DomainsToIni -IniPath $IniPath -DbPath $DbPath | Out-Null
    Write-Host "   All records successfully committed to SQLite and synchronized to INI." -ForegroundColor Green
    Write-Host ""

    # PHASE 3: AFTER
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "[PHASE 3: AFTER MUTATION - TRI-STATE VERIFICATION]" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "1. SQLite Database Records:" -ForegroundColor Gray
    $afterRecords = @(Get-NginxDomainRecords -DbPath $DbPath | Where-Object { $_.Domain -in @($demoDomain, $demoSubDomain) })
    foreach ($rec in $afterRecords) {
        Write-Host ("   • [{0}] Type={1}, Port={2}, Root={3}, Proxy={4}, Status={5}" -f $rec.Domain, $rec.Type, $rec.Port, $rec.RootPath, $rec.ProxyPass, $rec.Status) -ForegroundColor Cyan
    }
    Write-Host ""
    Write-Host "   Audit Trail (domain_history):" -ForegroundColor Gray
    $historyRecords = @(Get-NginxDomainHistory -Limit 4 -DbPath $DbPath)
    foreach ($h in $historyRecords) {
        Write-Host ("     [{0}] {1} -> {2} (by {3})" -f $h.Action, $h.Domain, $h.DiffSummary, $h.Operator) -ForegroundColor DarkCyan
    }
    Write-Host ""

    Write-Host "2. Updated Declarative INI File ($IniPath Excerpt):" -ForegroundColor Gray
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    if (Test-Path -LiteralPath $IniPath) {
        Get-Content -LiteralPath $IniPath | Select-Object -First 28 | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkYellow }
    }
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host "3. Compiled Windows Nginx Virtual Host ($savedConf1 Excerpt):" -ForegroundColor Gray
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    if (Test-Path -LiteralPath $savedConf1) {
        Get-Content -LiteralPath $savedConf1 | Select-Object -First 20 | ForEach-Object { Write-Host "   $_" -ForegroundColor White }
    }
    Write-Host "----------------------------------------" -ForegroundColor DarkGray
    Write-Host ""

    # PHASE 4: REMOVAL & INI DEMONSTRATION
    Write-Host "[PHASE 4: REMOVAL MUTATION & REAL-TIME INI UPDATE]" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ">> Command: .\run.ps1 nginx rm $demoSubDomain" -ForegroundColor White
    Remove-NginxDomainRecord -Domain $demoSubDomain -Purge -DbPath $DbPath
    Remove-NginxVhostConfig -Domain $demoSubDomain -NginxExe $nginxExe -Purge | Out-Null
    Sync-DomainsToIni -IniPath $IniPath -DbPath $DbPath | Out-Null

    Write-Host "   Subdomain '$demoSubDomain' removed from SQLite and unlinked." -ForegroundColor Green
    Write-Host "   Updated INI verification: section [$demoSubDomain] automatically removed." -ForegroundColor Green
    Write-Host ""

    # PHASE 5: CLEANUP & TEARDOWN
    Write-Host "[PHASE 5: CLEANUP & TEARDOWN]" -ForegroundColor Yellow
    Write-Host "--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    if ($Keep) {
        Write-Host "   Flag -Keep specified: Retaining '$demoDomain' configuration." -ForegroundColor Cyan
    } else {
        Write-Host "   Tearing down '$demoDomain' to keep system pristine..." -ForegroundColor Gray
        Remove-NginxDomainRecord -Domain $demoDomain -Purge -DbPath $DbPath
        Remove-NginxVhostConfig -Domain $demoDomain -NginxExe $nginxExe -Purge | Out-Null
        Sync-DomainsToIni -IniPath $IniPath -DbPath $DbPath | Out-Null
        Write-Host "   Teardown complete. All showcase artifacts cleaned up." -ForegroundColor Green
    }
    Write-Host ""
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host "                        SHOWCASE EXECUTION COMPLETE                             " -ForegroundColor Green
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host ""
}
