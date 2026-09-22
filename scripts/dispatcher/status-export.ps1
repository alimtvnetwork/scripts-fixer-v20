<#
.SYNOPSIS
    Settings export, config backup, and status dashboard for root dispatcher.
#>

function Invoke-ExportConfigCommand {
    param([string[]]$Args)
    $hasApp = $null -ne $Args -and $Args.Count -gt 0
    if (-not $hasApp) { Write-Host "Usage: export-config <app>"; return }
    $app = $Args[0]
    $backupDir = Join-Path $RootDir "configs"
    $hasBackup = Test-Path $backupDir
    if (-not $hasBackup) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
    if ($app -eq "qtorrent") { Copy-Config (Join-Path $env:APPDATA "qBittorrent") (Join-Path $backupDir "qtorrent") }
    if ($app -eq "utorrent") { Copy-Config (Join-Path $env:APPDATA "uTorrent") (Join-Path $backupDir "utorrent") }
    if ($app -eq "vscode") { Copy-Config (Join-Path $env:APPDATA "Code\User") (Join-Path $backupDir "vscode") }
}

function Invoke-ImportConfigCommand {
    param([string[]]$Args)
    $hasApp = $null -ne $Args -and $Args.Count -gt 0
    if (-not $hasApp) { Write-Host "Usage: import-config <app>"; return }
    $app = $Args[0]
    $backupDir = Join-Path $RootDir "configs"
    if ($app -eq "qtorrent") { Copy-Config (Join-Path $backupDir "qtorrent") (Join-Path $env:APPDATA "qBittorrent") }
    if ($app -eq "utorrent") { Copy-Config (Join-Path $backupDir "utorrent") (Join-Path $env:APPDATA "uTorrent") }
    if ($app -eq "vscode") { Copy-Config (Join-Path $backupDir "vscode") (Join-Path $env:APPDATA "Code\User") }
}

function Copy-Config {
    param([string]$Src, [string]$Dest)
    $hasSrc = Test-Path $Src
    if (-not $hasSrc) { Write-Host "Source not found: $Src"; return }
    $hasDest = Test-Path $Dest
    if (-not $hasDest) { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }
    Copy-Item -Path "$Src\*" -Destination $Dest -Recurse -Force
    Write-Host "Copied config to $Dest"
}

function Invoke-ExportCommand {
    param([string[]]$Args)

    Write-Host ""
    Write-Host "  Export Settings" -ForegroundColor $ThemeSecondary
    Write-Host "  ===============" -ForegroundColor $ThemeMuted
    Write-Host ""

    # Settings-capable scripts: scriptId -> keyword for display
    $exportScripts = @{
        "32" = "DBeaver"
        "33" = "Notepad++"
        "36" = "obs"
        "37" = "wt"
    }

    # Parse filter keywords from args
    $filterKeywords = @()
    $hasArgs = $null -ne $Args -and $Args.Count -gt 0
    if ($hasArgs) {
        foreach ($arg in $Args) {
            $tokens = $arg -split '[,\s]+' | Where-Object { $_.Length -gt 0 }
            $filterKeywords += $tokens
        }
    }

    # Keyword-to-scriptId mapping for filtering
    $exportKeywordMap = @{
        "dbeaver"  = "32"; "db-viewer" = "32"; "dbviewer" = "32"
        "npp"      = "33"; "notepad++" = "33"; "notepadpp" = "33"
        "obs"      = "36"; "obs-studio" = "36"
        "wt"       = "37"; "windows-terminal" = "37"
    }

    # Resolve which scripts to export
    $scriptIds = @()
    $hasFilters = $filterKeywords.Count -gt 0
    if ($hasFilters) {
        foreach ($kw in $filterKeywords) {
            $kwLower = $kw.ToLower()
            $hasMapping = $exportKeywordMap.ContainsKey($kwLower)
            if ($hasMapping) {
                $scriptIds += $exportKeywordMap[$kwLower]
            } else {
                Write-Host "  [ WARN ] Unknown export keyword: $kw" -ForegroundColor $ThemeAccent
                Write-Host "           Available: dbeaver, npp, obs, wt" -ForegroundColor $ThemeMuted
            }
        }
        $scriptIds = @($scriptIds | Select-Object -Unique)
    } else {
        $scriptIds = @($exportScripts.Keys | Sort-Object)
    }

    $hasNoScripts = $scriptIds.Count -eq 0
    if ($hasNoScripts) {
        Write-Host "  [ FAIL ] No valid export targets specified" -ForegroundColor $ThemeError
        Write-Host ""
        Write-Host "  Usage:" -ForegroundColor $ThemeAccent
        Write-Host "    .\run.ps1 export              # export all settings"
        Write-Host "    .\run.ps1 export npp,obs      # export specific apps"
        Write-Host "    .\run.ps1 export dbeaver      # export DBeaver settings"
        Write-Host ""
        return
    }

    Write-Host "  Exporting $($scriptIds.Count) app(s): $($scriptIds | ForEach-Object { $exportScripts[$_] }) " -ForegroundColor $ThemePrimary
    Write-Host ""

    $successCount = 0
    $failCount = 0

    foreach ($id in $scriptIds) {
        $label = $exportScripts[$id]
        Write-Host "  [ RUN  ] Exporting: $label (script $id)..." -ForegroundColor $ThemeSecondary

        try {
            $isExported = Invoke-ScriptById -ScriptId $id -ExtraArgs @("export")
            if ($isExported) {
                $successCount++
            } else {
                $failCount++
            }
        } catch {
            Write-Host "  [ FAIL ] Export failed for $label : $_" -ForegroundColor $ThemeError
            $failCount++
        }
    }

    Write-Host ""
    Write-Host "  ======================================" -ForegroundColor $ThemeMuted
    $hasFails = $failCount -gt 0
    if ($hasFails) {
        Write-Host "  [ DONE ] $successCount of $($scriptIds.Count) exported successfully ($failCount failed)" -ForegroundColor $ThemeAccent
    } else {
        Write-Host "  [ DONE ] $successCount of $($scriptIds.Count) exported successfully" -ForegroundColor Green
    }
    Write-Host ""
}

# ── Status command function ────────────────────────────────────────────
function Invoke-StatusCommand {
    param([string[]]$Args)

    Write-Host ""
    Write-Host "  Tool Status Dashboard" -ForegroundColor $ThemeSecondary
    Write-Host "  =====================" -ForegroundColor $ThemeMuted
    Write-Host ""

    $installedDir = Join-Path $RootDir ".installed"
    $isInstalledDirMissing = -not (Test-Path $installedDir)
    if ($isInstalledDirMissing) {
        Write-Host "  No tools tracked yet. Run some install scripts first." -ForegroundColor $ThemeAccent
        Write-Host ""
        return
    }

    $records = Get-ChildItem -Path $installedDir -Filter "*.json" -File | Sort-Object Name
    $hasNoRecords = $records.Count -eq 0
    if ($hasNoRecords) {
        Write-Host "  No tools tracked yet. Run some install scripts first." -ForegroundColor $ThemeAccent
        Write-Host ""
        return
    }

    # Parse flags
    $isNoChoco     = $false
    $isModelsOnly  = $false
    $isToolsOnly   = $false
    if ($null -ne $Args) {
        foreach ($arg in $Args) {
            $argLower = "$arg".Trim().ToLower()
            if ($argLower -eq "--no-choco" -or $argLower -eq "--fast") { $isNoChoco = $true }
            if ($argLower -in @("--models", "--models-only", "models")) { $isModelsOnly = $true }
            if ($argLower -in @("--tools", "--tools-only", "tools"))    { $isToolsOnly = $true }
        }
    }

    # Split records into tools vs models (model-<slug>.json entries)
    $toolRecords  = @()
    $modelRecords = @()
    foreach ($file in $records) {
        $isModelFile = $file.BaseName -like "model-*"
        if ($isModelFile) { $modelRecords += $file } else { $toolRecords += $file }
    }

    $okCount = 0
    $errorCount = 0
    $unknownCount = 0

    function Write-StatusGroup {
        param([string]$Title, $Files, [int]$NameCol, [int]$VerCol, [int]$StatusCol, [int]$MethodCol)

        $hasFiles = @($Files).Count -gt 0
        if (-not $hasFiles) {
            Write-Host "  $Title -- (none tracked)" -ForegroundColor $ThemeMuted
            Write-Host ""
            return @{ ok = 0; err = 0; unk = 0 }
        }

        Write-Host "  $Title" -ForegroundColor White
        $header = "    {0}  {1}  {2}  {3}" -f "Name".PadRight($NameCol), "Version".PadRight($VerCol), "Status".PadRight($StatusCol), "Source".PadRight($MethodCol)
        Write-Host $header -ForegroundColor $ThemeMuted
        $separator = "    {0}  {1}  {2}  {3}" -f ("-" * $NameCol), ("-" * $VerCol), ("-" * $StatusCol), ("-" * $MethodCol)
        Write-Host $separator -ForegroundColor $ThemeMuted

        $local = @{ ok = 0; err = 0; unk = 0 }
        foreach ($file in $Files) {
            try { $record = Get-Content $file.FullName -Raw | ConvertFrom-Json } catch { continue }

            $toolName = if ($record.name) { $record.name } else { $file.BaseName }
            $version  = if ($record.version) { $record.version } else { "unknown" }
            $method   = if ($record.method) { $record.method } else { "--" }

            $hasError = $record.lastError -and ($record.lastError -ne "")
            $isVersionUnknown = $version -eq "unknown" -or $version -eq "installed" -or $version -eq "(version pending)"

            $status = "ok"; $statusColor = "Green"
            if ($hasError)             { $status = "error";      $statusColor = "Red";    $local.err++ }
            elseif ($isVersionUnknown) { $status = "unverified"; $statusColor = "Yellow"; $local.unk++ }
            else                       { $local.ok++ }

            $displayName = if ($toolName.Length -gt $NameCol) { $toolName.Substring(0, $NameCol - 2) + ".." } else { $toolName }
            $displayVer  = if ($version.Length  -gt $VerCol)  { $version.Substring(0, $VerCol - 2)  + ".." } else { $version }

            Write-Host "    $($displayName.PadRight($NameCol))  $($displayVer.PadRight($VerCol))  " -NoNewline
            Write-Host $status.PadRight($StatusCol) -ForegroundColor $statusColor -NoNewline
            Write-Host "  $method"
        }
        Write-Host ""
        return $local
    }

    $showTools  = -not $isModelsOnly
    $showModels = -not $isToolsOnly

    if ($showTools) {
        $r = Write-StatusGroup -Title "Tools" -Files $toolRecords -NameCol 24 -VerCol 24 -StatusCol 12 -MethodCol 16
        $okCount += $r.ok; $errorCount += $r.err; $unknownCount += $r.unk
    }
    if ($showModels) {
        $r = Write-StatusGroup -Title "Models" -Files $modelRecords -NameCol 32 -VerCol 20 -StatusCol 12 -MethodCol 16
        $okCount += $r.ok; $errorCount += $r.err; $unknownCount += $r.unk
    }

    $totalShown = 0
    if ($showTools)  { $totalShown += @($toolRecords).Count }
    if ($showModels) { $totalShown += @($modelRecords).Count }

    Write-Host "  Summary: " -NoNewline -ForegroundColor $ThemeMuted
    Write-Host "$okCount ok" -ForegroundColor Green -NoNewline
    if ($errorCount -gt 0)   { Write-Host ", $errorCount error(s)" -ForegroundColor $ThemeError -NoNewline }
    if ($unknownCount -gt 0) { Write-Host ", $unknownCount unverified" -ForegroundColor $ThemeAccent -NoNewline }
    Write-Host " -- $totalShown tracked (tools: $(@($toolRecords).Count), models: $(@($modelRecords).Count))"

    # Optionally check choco outdated
    $isChocoCheckEnabled = -not $isNoChoco
    if ($isChocoCheckEnabled) {
        $chocoCmd = Get-Command choco -ErrorAction SilentlyContinue
        $isChocoAvailable = $null -ne $chocoCmd
        if ($isChocoAvailable) {
            Write-Host ""
            Write-Host "  Checking for outdated packages..." -ForegroundColor $ThemeMuted
            try {
                $outdated = & choco outdated -r 2>$null | Where-Object { $_ -match '\|' }
                $hasOutdated = $null -ne $outdated -and @($outdated).Count -gt 0
                if ($hasOutdated) {
                    Write-Host ""
                    Write-Host "  Outdated Packages:" -ForegroundColor $ThemeAccent
                    foreach ($line in $outdated) {
                        $parts = $line -split '\|'
                        $hasParts = $parts.Count -ge 3
                        if ($hasParts) {
                            $pkgName = $parts[0]
                            $currentVer = $parts[1]
                            $availableVer = $parts[2]
                            Write-Host "    $($pkgName.PadRight(24))  $currentVer -> $availableVer" -ForegroundColor $ThemeMuted
                        }
                    }
                } else {
                    Write-Host "  All Chocolatey packages are up to date." -ForegroundColor Green
                }
            } catch {
                Write-Host "  Could not check Chocolatey outdated: $_" -ForegroundColor $ThemeAccent
            }
        }
    }

    Write-Host ""
    Write-Host "  Tip: '.\run.ps1 status --tools' / '--models' to filter; '--no-choco' to skip outdated check." -ForegroundColor $ThemeMuted
    Write-Host "  Aliases: status, list-installed, installed" -ForegroundColor $ThemeMuted
    Write-Host ""
}

# ── Doctor command function ────────────────────────────────────────────

