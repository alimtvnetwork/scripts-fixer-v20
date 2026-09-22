<#
.SYNOPSIS
    System diagnostics, health checks, and doctor self-check for root dispatcher.
#>

function Invoke-DoctorCommand {
    <#
    .SYNOPSIS
        Quick health-check that verifies the project setup itself.
        Lighter than full audit -- runs in < 2 seconds.
    #>

    Write-Host ""
    Write-Host "  Project Doctor" -ForegroundColor $ThemeSecondary
    Write-Host "  ==============" -ForegroundColor $ThemeMuted
    Write-Host ""

    $passCount = 0
    $failCount = 0
    $warnCount = 0

    # Helper to print check results
    function Write-Check {
        param([string]$Label, [string]$Status, [string]$Detail = "")
        switch ($Status) {
            "pass" {
                Write-Host "    [PASS] " -ForegroundColor Green -NoNewline
                Write-Host $Label -NoNewline
                if ($Detail) { Write-Host " -- $Detail" -ForegroundColor $ThemeMuted } else { Write-Host "" }
                $script:passCount++
            }
            "fail" {
                Write-Host "    [FAIL] " -ForegroundColor $ThemeError -NoNewline
                Write-Host $Label -NoNewline
                if ($Detail) { Write-Host " -- $Detail" -ForegroundColor $ThemeMuted } else { Write-Host "" }
                $script:failCount++
            }
            "warn" {
                Write-Host "    [WARN] " -ForegroundColor $ThemeAccent -NoNewline
                Write-Host $Label -NoNewline
                if ($Detail) { Write-Host " -- $Detail" -ForegroundColor $ThemeMuted } else { Write-Host "" }
                $script:warnCount++
            }
        }
    }

    # 1. Check scripts root directory
    $scriptsRoot = Join-Path $RootDir "scripts"
    $hasScriptsDir = Test-Path $scriptsRoot
    if ($hasScriptsDir) {
        Write-Check "Scripts directory exists" "pass" $scriptsRoot
    } else {
        Write-Check "Scripts directory exists" "fail" "Not found: $scriptsRoot"
    }

    # 2. Check version.json
    $versionFile = Join-Path $scriptsRoot "version.json"
    $hasVersionFile = Test-Path $versionFile
    if ($hasVersionFile) {
        try {
            $versionData = Get-Content $versionFile -Raw | ConvertFrom-Json
            $hasVersion = -not [string]::IsNullOrWhiteSpace($versionData.version)
            if ($hasVersion) {
                Write-Check "version.json is valid" "pass" "v$($versionData.version)"
            } else {
                Write-Check "version.json is valid" "fail" "Empty version field"
            }
        } catch {
            Write-Check "version.json is valid" "fail" "Parse error: $_"
        }
    } else {
        Write-Check "version.json is valid" "fail" "Not found"
    }

    # 3. Check registry.json
    $registryFile = Join-Path $scriptsRoot "registry.json"
    $hasRegistry = Test-Path $registryFile
    if ($hasRegistry) {
        try {
            $registryData = Get-Content $registryFile -Raw | ConvertFrom-Json
            $registryCount = ($registryData.scripts.PSObject.Properties | Measure-Object).Count
            Write-Check "registry.json is valid" "pass" "$registryCount scripts registered"
        } catch {
            Write-Check "registry.json is valid" "fail" "Parse error: $_"
        }
    } else {
        Write-Check "registry.json is valid" "fail" "Not found"
    }

    # 4. Check registry IDs match existing folders
    if ($hasRegistry) {
        $missingFolders = @()
        foreach ($prop in $registryData.scripts.PSObject.Properties) {
            $folderPath = Join-Path $scriptsRoot $prop.Value
            $isFolderMissing = -not (Test-Path $folderPath)
            if ($isFolderMissing) {
                $missingFolders += "$($prop.Name):$($prop.Value)"
            }
        }
        $hasMissing = $missingFolders.Count -gt 0
        if ($hasMissing) {
            Write-Check "Registry folders exist" "fail" "Missing: $($missingFolders -join ', ')"
        } else {
            Write-Check "Registry folders exist" "pass" "All $registryCount folders present"
        }
    }

    # 5. Check .logs directory
    $logsDir = Join-Path $RootDir ".logs"
    $hasLogsDir = Test-Path $logsDir
    if ($hasLogsDir) {
        $logFiles = @(Get-ChildItem -Path $logsDir -Filter "*.json" -File -ErrorAction SilentlyContinue)
        Write-Check ".logs/ directory exists" "pass" "$($logFiles.Count) log file(s)"
    } else {
        Write-Check ".logs/ directory exists" "warn" "Will be created on first script run"
    }

    # 6. Check .installed directory
    $installedDir = Join-Path $RootDir ".installed"
    $hasInstalledDir = Test-Path $installedDir
    if ($hasInstalledDir) {
        $trackFiles = @(Get-ChildItem -Path $installedDir -Filter "*.json" -File -ErrorAction SilentlyContinue)
        Write-Check ".installed/ directory exists" "pass" "$($trackFiles.Count) tool(s) tracked"
    } else {
        Write-Check ".installed/ directory exists" "warn" "No tools tracked yet"
    }

    # 7. Check Chocolatey
    $chocoCmd = Get-Command choco -ErrorAction SilentlyContinue
    $hasChoco = $null -ne $chocoCmd
    if ($hasChoco) {
        $chocoVer = try { & choco --version 2>$null } catch { $null }
        Write-Check "Chocolatey is reachable" "pass" "v$chocoVer"
    } else {
        Write-Check "Chocolatey is reachable" "fail" "Not found in PATH"
    }

    # 8. Check admin rights
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        Write-Check "Running as Administrator" "pass"
    } else {
        Write-Check "Running as Administrator" "warn" "Some scripts require admin rights"
    }

    # 9. Check shared helpers are present
    $requiredHelpers = @("logging.ps1", "installed.ps1", "resolved.ps1", "help.ps1", "choco-utils.ps1", "path-utils.ps1", "dev-dir.ps1", "json-utils.ps1", "tool-version.ps1")
    $sharedDir = Join-Path $scriptsRoot "shared"
    $missingHelpers = @()
    foreach ($helper in $requiredHelpers) {
        $helperPath = Join-Path $sharedDir $helper
        $isHelperMissing = -not (Test-Path $helperPath)
        if ($isHelperMissing) {
            $missingHelpers += $helper
        }
    }
    $hasMissingHelpers = $missingHelpers.Count -gt 0
    if ($hasMissingHelpers) {
        Write-Check "Shared helpers present" "fail" "Missing: $($missingHelpers -join ', ')"
    } else {
        Write-Check "Shared helpers present" "pass" "$($requiredHelpers.Count) helpers found"
    }

    # 10. Check install-keywords.json
    $keywordsFile = Join-Path $sharedDir "install-keywords.json"
    $hasKeywords = Test-Path $keywordsFile
    if ($hasKeywords) {
        try {
            $kwData = Get-Content $keywordsFile -Raw | ConvertFrom-Json
            $kwCount = ($kwData.keywords.PSObject.Properties | Measure-Object).Count
            Write-Check "install-keywords.json is valid" "pass" "$kwCount keywords mapped"
        } catch {
            Write-Check "install-keywords.json is valid" "fail" "Parse error: $_"
        }
    } else {
        Write-Check "install-keywords.json is valid" "fail" "Not found"
    }

    # Summary
    Write-Host ""
    Write-Host "  Summary: " -NoNewline -ForegroundColor $ThemeMuted
    Write-Host "$passCount passed" -ForegroundColor Green -NoNewline
    $hasWarns = $warnCount -gt 0
    if ($hasWarns) {
        Write-Host ", $warnCount warning(s)" -ForegroundColor $ThemeAccent -NoNewline
    }
    $hasFails = $failCount -gt 0
    if ($hasFails) {
        Write-Host ", $failCount failed" -ForegroundColor $ThemeError -NoNewline
    }
    Write-Host ""

    if ($hasFails) {
        Write-Host ""
        Write-Host "  Some checks failed. Fix the issues above for a healthy setup." -ForegroundColor $ThemeError
    } elseif ($hasWarns) {
        Write-Host ""
        Write-Host "  Project looks good with minor warnings." -ForegroundColor $ThemeAccent
    } else {
        Write-Host ""
        Write-Host "  All checks passed. Project is healthy!" -ForegroundColor Green
    }
    Write-Host ""
}

# ── Doctor --self-check (deep audit, v0.46.1+) ──────────────────────
function Invoke-DoctorSelfCheck {
    <#
    .SYNOPSIS
        Deep self-audit of the project. Verifies internal consistency:
          (a) every claimed feature in changelog.md exists on disk
          (b) version.json matches the latest changelog header
          (c) every category in scripts/os/helpers/clean.ps1 catalog has a matching helper file
          (d) every keyword in install-keywords.json points to a real script ID / valid os:/profile: action
              / a remote.* entry whose URL responds 200 (or whose 'path' resolves to a real file)
          (e) every pinned remote.<key>.sha256 still matches the live upstream body
              -- full GET, hashed identically to run.ps1 (UTF-8 bytes of decoded string),
                 expected vs actual printed on mismatch. Empty pins skipped.
                 Path-based remotes are hashed from disk (not the network).
        Sections (d) and (e) require network access. Pass -SkipNetwork to skip both
        (e.g. on an air-gapped CI runner or when offline). Sections (a)-(c) always run.
        Prints a green/red table per row + per-section summaries + final tally.
    #>
    param([switch]$SkipNetwork)

    Write-Host ""
    Write-Host "  Doctor -- Self-Check (deep audit)" -ForegroundColor $ThemeSecondary
    Write-Host "  =================================" -ForegroundColor $ThemeMuted
    if ($SkipNetwork) {
        Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "--skip-network: sections (d) and (e) will be skipped (offline mode)"
    }
    Write-Host ""

    $script:scPass = 0
    $script:scFail = 0

    function Write-SCRow {
        param([string]$Section, [string]$Item, [bool]$Ok, [string]$Detail = "")
        if ($Ok) {
            Write-Host "    [ OK ] " -ForegroundColor Green -NoNewline
            $script:scPass++
        } else {
            Write-Host "    [FAIL] " -ForegroundColor $ThemeError -NoNewline
            $script:scFail++
        }
        $line = "{0,-10} {1,-40}" -f $Section, $Item
        Write-Host $line -NoNewline
        if ($Detail) { Write-Host " $Detail" -ForegroundColor $ThemeMuted } else { Write-Host "" }
    }

    function Write-SCHeader {
        param([string]$Title)
        Write-Host ""
        Write-Host "  -- $Title" -ForegroundColor $ThemeAccent
    }

    $scriptsRoot = Join-Path $RootDir "scripts"
    $sharedDir   = Join-Path $scriptsRoot "shared"

    # ============================================================
    # (a) Claimed features in changelog.md exist on disk
    # ============================================================
    Write-SCHeader "(a) Claimed files in changelog.md exist on disk"
    $changelogPath = Join-Path $RootDir "changelog.md"
    $hasChangelog = Test-Path $changelogPath
    if (-not $hasChangelog) {
        Write-SCRow "changelog" "changelog.md" $false "Missing at: $changelogPath"
    } else {
        $clText = Get-Content $changelogPath -Raw
        # Extract backticked paths that look like real files (contain / or \ and an extension OR end in .ps1/.json/.md)
        $regex = [regex]'`([A-Za-z0-9_./\\-]+\.(ps1|json|md|psm1|psd1))`'
        $matches = $regex.Matches($clText)
        $uniquePaths = @{}
        foreach ($m in $matches) {
            $p = $m.Groups[1].Value
            # Skip obvious externals (URL fragments, backslash-only Windows paths starting with %)
            if ($p.StartsWith("%") -or $p.StartsWith("~") -or $p.StartsWith("http")) { continue }
            $uniquePaths[$p] = $true
        }
        $checked = 0
        foreach ($rel in ($uniquePaths.Keys | Sort-Object)) {
            $checked++
            $abs = Join-Path $RootDir ($rel -replace '/', '\')
            $exists = Test-Path -LiteralPath $abs
            $detail = if ($exists) { "" } else { "Expected: $abs" }
            Write-SCRow "changelog" $rel $exists $detail
        }
        if ($checked -eq 0) {
            Write-SCRow "changelog" "(no `path.ext` references found)" $true ""
        }
    }

    # ============================================================
    # (b) version.json matches latest changelog header
    # ============================================================
    Write-SCHeader "(b) version.json matches latest changelog header"
    $versionFile = Join-Path $scriptsRoot "version.json"
    $hasVF = Test-Path $versionFile
    $hasCL = Test-Path $changelogPath
    if (-not $hasVF) {
        Write-SCRow "version" "scripts/version.json" $false "Missing at: $versionFile"
    } elseif (-not $hasCL) {
        Write-SCRow "version" "changelog.md" $false "Missing at: $changelogPath"
    } else {
        try {
            $vData = Get-Content $versionFile -Raw | ConvertFrom-Json
            $vJson = $vData.version
        } catch {
            $vJson = $null
            Write-SCRow "version" "version.json parse" $false "Parse error: $_  (path: $versionFile)"
        }
        if ($vJson) {
            $clRaw = Get-Content $changelogPath -Raw
            $headerMatch = [regex]::Match($clRaw, '(?m)^##\s*\[?v?(\d+\.\d+\.\d+)\]?')
            if (-not $headerMatch.Success) {
                Write-SCRow "version" "latest changelog header" $false "No '## [vX.Y.Z]' header found in $changelogPath"
            } else {
                $vCL = $headerMatch.Groups[1].Value
                $matches = ($vJson -eq $vCL)
                $detail = "version.json=v$vJson  changelog=v$vCL"
                Write-SCRow "version" "monotonic match" $matches $detail
            }
        }
    }

    # ============================================================
    # (c) Every os clean catalog category has a matching helper file
    # ============================================================
    Write-SCHeader "(c) os clean-categories: catalog vs helper files"
    $cleanDispatcher = Join-Path $scriptsRoot "os\helpers\clean.ps1"
    $catDir          = Join-Path $scriptsRoot "os\helpers\clean-categories"
    $hasCD = Test-Path $cleanDispatcher
    $hasCatDir = Test-Path $catDir
    if (-not $hasCD) {
        Write-SCRow "clean" "clean.ps1 dispatcher" $false "Missing at: $cleanDispatcher"
    } elseif (-not $hasCatDir) {
        Write-SCRow "clean" "clean-categories/ dir" $false "Missing at: $catDir"
    } else {
        # Parse @{ Cat = "name"; Bucket = "X"; Helper = "name.ps1" } lines
        $cdText = Get-Content $cleanDispatcher -Raw
        $catRegex = [regex]'@\{\s*Cat\s*=\s*"([^"]+)"\s*;\s*Bucket\s*=\s*"([^"]+)"\s*;\s*Helper\s*=\s*"([^"]+)"\s*\}'
        $catMatches = $catRegex.Matches($cdText)
        if ($catMatches.Count -eq 0) {
            Write-SCRow "clean" "catalog parse" $false "No catalog entries matched in: $cleanDispatcher"
        } else {
            foreach ($m in $catMatches) {
                $cat    = $m.Groups[1].Value
                $bucket = $m.Groups[2].Value
                $helper = $m.Groups[3].Value
                $helperPath = Join-Path $catDir $helper
                $exists = Test-Path -LiteralPath $helperPath
                $detail = if ($exists) { "[$bucket] $helper" } else { "[$bucket] MISSING: $helperPath" }
                Write-SCRow "clean" $cat $exists $detail
            }
        }
    }

    # ============================================================
    # (d) install-keywords.json: every keyword resolves
    # ============================================================
    Write-SCHeader "(d) install-keywords.json: keyword resolution"
    if ($SkipNetwork) {
        Write-SCRow "keywords" "(skipped -- --skip-network)" $true "Section (d) requires HEAD probes to remote URLs; skipped per flag."
    } else {
    $kwFile = Join-Path $sharedDir "install-keywords.json"
    $regFile = Join-Path $scriptsRoot "registry.json"
    if (-not (Test-Path $kwFile)) {
        Write-SCRow "keywords" "install-keywords.json" $false "Missing at: $kwFile"
    } elseif (-not (Test-Path $regFile)) {
        Write-SCRow "keywords" "registry.json" $false "Missing at: $regFile"
    } else {
        try {
            $kwData  = Get-Content $kwFile  -Raw | ConvertFrom-Json
            $regData = Get-Content $regFile -Raw | ConvertFrom-Json
        } catch {
            Write-SCRow "keywords" "json parse" $false "Parse error: $_"
            $kwData = $null
        }
        if ($null -ne $kwData) {
            # Build registry ID set
            $validIds = @{}
            foreach ($prop in $regData.scripts.PSObject.Properties) {
                $validIds[$prop.Name] = $true
            }

            # Probe remote URLs ONCE and cache. Path-based remotes (v0.47.1+)
            # skip HTTP probing and instead validate the local file exists.
            $remoteCache = @{}
            if ($null -ne $kwData.remote) {
                foreach ($rprop in $kwData.remote.PSObject.Properties) {
                    $rkey = $rprop.Name
                    $rval = $rprop.Value
                    $hasRPath = $rval.PSObject.Properties['path'] -and -not [string]::IsNullOrWhiteSpace("$($rval.path)")
                    $hasRUrl  = $rval.PSObject.Properties['url']  -and -not [string]::IsNullOrWhiteSpace("$($rval.url)")
                    if ($hasRPath) {
                        $relPath = "$($rval.path)".Trim()
                        $absPath = Join-Path $RootDir $relPath
                        $existsLocal = Test-Path -LiteralPath $absPath
                        $remoteCache[$rkey] = @{
                            Url   = "file:///$($absPath -replace '\\','/')"
                            Code  = if ($existsLocal) { 200 } else { 404 }
                            Ok    = $existsLocal
                            Kind  = "path"
                            Path  = $absPath
                        }
                    } elseif ($hasRUrl) {
                        $rurl = "$($rval.url)".Trim()
                        $code = -1
                        try {
                            $resp = Invoke-WebRequest -Uri $rurl -Method Head -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
                            $code = [int]$resp.StatusCode
                        } catch {
                            if ($null -ne $_.Exception.Response -and $null -ne $_.Exception.Response.StatusCode) {
                                $code = [int]$_.Exception.Response.StatusCode
                            }
                        }
                        $remoteCache[$rkey] = @{ Url = $rurl; Code = $code; Ok = ($code -eq 200); Kind = "url" }
                    } else {
                        $remoteCache[$rkey] = @{ Url = "(none)"; Code = 0; Ok = $false; Kind = "missing" }
                    }
                }
            }

            # Walk every keyword
            foreach ($kprop in $kwData.keywords.PSObject.Properties) {
                $kw = $kprop.Name
                $targets = $kprop.Value
                $allOk = $true
                $details = New-Object System.Collections.ArrayList

                foreach ($t in $targets) {
                    $tStr = "$t"
                    # Three resolution kinds: remote:<key>, os:<action>, profile:<name>, or numeric script ID
                    if ($tStr -match '^remote:(.+)$') {
                        $rk = $Matches[1]
                        if (-not $remoteCache.ContainsKey($rk)) {
                            $allOk = $false
                            [void]$details.Add("remote:$rk -> NOT in remote.* (path: $kwFile)")
                        } else {
                            $rc = $remoteCache[$rk]
                            if (-not $rc.Ok) {
                                $allOk = $false
                                if ($rc.Kind -eq "path") {
                                    [void]$details.Add("remote:$rk -> local file MISSING: $($rc.Path)")
                                } elseif ($rc.Kind -eq "missing") {
                                    [void]$details.Add("remote:$rk -> entry has neither 'url' nor 'path'")
                                } else {
                                    [void]$details.Add("remote:$rk -> HTTP $($rc.Code) for $($rc.Url)")
                                }
                            } else {
                                if ($rc.Kind -eq "path") {
                                    [void]$details.Add("remote:$rk local-OK")
                                } else {
                                    [void]$details.Add("remote:$rk 200")
                                }
                            }
                        }
                    } elseif ($tStr -match '^os:(.+)$') {
                        # Accept any os:<action> as valid (os dispatcher resolves at runtime)
                        [void]$details.Add("os:$($Matches[1])")
                    } elseif ($tStr -match '^profile:(.+)$') {
                        [void]$details.Add("profile:$($Matches[1])")
                    } elseif ($tStr -match '^\d+$') {
                        if (-not $validIds.ContainsKey($tStr)) {
                            $allOk = $false
                            [void]$details.Add("id $tStr -> NOT in registry.json")
                        } else {
                            [void]$details.Add("id $tStr")
                        }
                    } else {
                        $allOk = $false
                        [void]$details.Add("unknown target form: '$tStr'")
                    }
                }

                Write-SCRow "keyword" $kw $allOk ($details -join ", ")
            }
        }
    }
    } # end if (-not $SkipNetwork) for section (d)

    # ============================================================
    # (e) install-keywords.json: pinned remote.<key>.sha256 still matches live body
    # ============================================================
    Write-SCHeader "(e) remote SHA256 pins still match upstream body"
    if ($SkipNetwork) {
        Write-SCRow "sha256" "(skipped -- --skip-network)" $true "Section (e) requires full GET of every remote URL; skipped per flag."
    } else {
        $kwFileE = Join-Path $sharedDir "install-keywords.json"
        if (-not (Test-Path $kwFileE)) {
            Write-SCRow "sha256" "install-keywords.json" $false "Missing at: $kwFileE"
        } else {
            try {
                $kwDataE = Get-Content $kwFileE -Raw | ConvertFrom-Json
            } catch {
                Write-SCRow "sha256" "json parse" $false "Parse error at ${kwFileE}: $($_.Exception.Message)"
                $kwDataE = $null
            }
            if ($null -ne $kwDataE -and $null -ne $kwDataE.remote) {
                $remoteCount = 0
                foreach ($rprop in $kwDataE.remote.PSObject.Properties) {
                    $rkey = $rprop.Name
                    $rval = $rprop.Value
                    $remoteCount++

                    # Pull pinned sha256 (skip if absent or empty)
                    $pinned = $null
                    if ($rval.PSObject.Properties['sha256']) {
                        $rawPin = "$($rval.sha256)".Trim()
                        if (-not [string]::IsNullOrWhiteSpace($rawPin)) { $pinned = $rawPin.ToLowerInvariant() }
                    }
                    if ($null -eq $pinned) {
                        Write-SCRow "sha256" "remote:$rkey" $true "(unpinned -- skipped, no sha256 to verify)"
                        continue
                    }

                    # Resolve source: 'path' (repo-local) or 'url' (HTTP)
                    $hasRPath = $rval.PSObject.Properties['path'] -and -not [string]::IsNullOrWhiteSpace("$($rval.path)")
                    $hasRUrl  = $rval.PSObject.Properties['url']  -and -not [string]::IsNullOrWhiteSpace("$($rval.url)")
                    $body = $null
                    $sourceLabel = $null
                    $fetchError = $null

                    if ($hasRPath) {
                        $relPath = "$($rval.path)".Trim()
                        $absPath = Join-Path $RootDir $relPath
                        $sourceLabel = "local: $absPath"
                        if (-not (Test-Path -LiteralPath $absPath)) {
                            $fetchError = "Local wrapper not found: $absPath  (referenced by remote.$rkey.path in $kwFileE)"
                        } else {
                            try {
                                $body = Get-Content -LiteralPath $absPath -Raw -ErrorAction Stop
                            } catch {
                                $fetchError = "Read failed for $absPath -- $($_.Exception.Message)"
                            }
                        }
                    } elseif ($hasRUrl) {
                        $rurl = "$($rval.url)".Trim()
                        $sourceLabel = $rurl
                        try {
                            # Mirror run.ps1 dispatcher: Invoke-RestMethod returns the decoded string body.
                            $body = Invoke-RestMethod -Uri $rurl -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
                        } catch {
                            $code = ""
                            if ($null -ne $_.Exception.Response -and $null -ne $_.Exception.Response.StatusCode) {
                                $code = " (HTTP $([int]$_.Exception.Response.StatusCode))"
                            }
                            $fetchError = "GET failed for ${rurl}${code} -- $($_.Exception.Message)"
                        }
                    } else {
                        Write-SCRow "sha256" "remote:$rkey" $false "Entry has neither 'url' nor 'path' (path: $kwFileE)"
                        continue
                    }

                    if ($null -ne $fetchError) {
                        Write-SCRow "sha256" "remote:$rkey" $false $fetchError
                        continue
                    }
                    if ([string]::IsNullOrWhiteSpace($body)) {
                        Write-SCRow "sha256" "remote:$rkey" $false "Empty body from $sourceLabel  (pin source: remote.$rkey.sha256 in $kwFileE)"
                        continue
                    }

                    # Compute SHA256 IDENTICALLY to run.ps1 dispatcher: UTF-8 bytes of the decoded string.
                    try {
                        $bytes = [System.Text.Encoding]::UTF8.GetBytes("$body")
                        $sha = [System.Security.Cryptography.SHA256]::Create()
                        $hashBytes = $sha.ComputeHash($bytes)
                        $sha.Dispose()
                        $actual = ([System.BitConverter]::ToString($hashBytes) -replace '-', '').ToLowerInvariant()
                    } catch {
                        Write-SCRow "sha256" "remote:$rkey" $false "SHA256 computation failed for $sourceLabel -- $($_.Exception.Message)"
                        continue
                    }

                    $isMatch = $actual -eq $pinned
                    if ($isMatch) {
                        Write-SCRow "sha256" "remote:$rkey" $true "pinned=$pinned  source=$sourceLabel  ($([Math]::Round(([System.Text.Encoding]::UTF8.GetBytes($body)).Length / 1KB, 2)) KB)"
                    } else {
                        $detail = "MISMATCH  expected=$pinned  actual=$actual  source=$sourceLabel  pin=remote.$rkey.sha256 in $kwFileE"
                        Write-SCRow "sha256" "remote:$rkey" $false $detail
                    }
                }
                if ($remoteCount -eq 0) {
                    Write-SCRow "sha256" "remote.* entries" $true "(no entries to check -- remote.* is empty)"
                }
            } elseif ($null -ne $kwDataE) {
                Write-SCRow "sha256" "remote.* section" $true "(no remote.* section in $kwFileE -- nothing to verify)"
            }
        }
    }

    # ============================================================
    # Summary
    # ============================================================
    $total = $script:scPass + $script:scFail
    Write-Host ""
    Write-Host "  Self-Check Summary: " -NoNewline -ForegroundColor $ThemeMuted
    Write-Host "$($script:scPass)/$total OK" -ForegroundColor Green -NoNewline
    if ($script:scFail -gt 0) {
        Write-Host ", $($script:scFail) FAIL" -ForegroundColor $ThemeError
        Write-Host ""
        Write-Host "  Self-check found inconsistencies. Fix the rows marked [FAIL] above." -ForegroundColor $ThemeError
    } else {
        Write-Host ""
        Write-Host ""
        Write-Host "  All self-check rows green. Project is internally consistent." -ForegroundColor Green
    }
    Write-Host ""
}


