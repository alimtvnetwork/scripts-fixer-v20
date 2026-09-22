<#
.SYNOPSIS
    Keyword resolution, Levenshtein distance, and fuzzy matching for root dispatcher.
#>

function Get-LevenshteinDistance {
    param([string]$A, [string]$B)
    if ([string]::IsNullOrEmpty($A)) { return [int]$B.Length }
    if ([string]::IsNullOrEmpty($B)) { return [int]$A.Length }
    $la = $A.Length; $lb = $B.Length
    $prev = New-Object 'int[]' ($lb + 1)
    $curr = New-Object 'int[]' ($lb + 1)
    for ($j = 0; $j -le $lb; $j++) { $prev[$j] = $j }
    for ($i = 1; $i -le $la; $i++) {
        $curr[0] = $i
        for ($j = 1; $j -le $lb; $j++) {
            $cost = if ($A[$i - 1] -eq $B[$j - 1]) { 0 } else { 1 }
            $del = $prev[$j] + 1
            $ins = $curr[$j - 1] + 1
            $sub = $prev[$j - 1] + $cost
            $min = $del; if ($ins -lt $min) { $min = $ins }; if ($sub -lt $min) { $min = $sub }
            $curr[$j] = $min
        }
        $tmp = $prev; $prev = $curr; $curr = $tmp
    }
    return [int]$prev[$lb]
}

# Rank candidates by Levenshtein distance, with prefix/substring bonuses, and
# return the top N closest matches. Filters by a length-aware cutoff so wildly
# different tokens do not surface noisy suggestions.
function Get-DidYouMean {
    param(
        [string]   $Token,
        [string[]] $Candidates,
        [int]      $Top = 3
    )
    if ([string]::IsNullOrWhiteSpace($Token)) { return @() }
    if ($null -eq $Candidates -or $Candidates.Count -eq 0) { return @() }
    $tokLower = $Token.ToLower()
    $tokLen   = $tokLower.Length
    $cutoff   = [Math]::Max(2, [int][Math]::Ceiling($tokLen / 2.0))

    $scored = foreach ($c in ($Candidates | Select-Object -Unique)) {
        if ([string]::IsNullOrWhiteSpace($c)) { continue }
        $cLower = $c.ToLower()
        $d = Get-LevenshteinDistance -A $tokLower -B $cLower
        $isPrefix   = $cLower.StartsWith($tokLower) -or $tokLower.StartsWith($cLower)
        $isContains = $cLower.Contains($tokLower) -or $tokLower.Contains($cLower)
        $score = $d
        if ($isPrefix)        { $score -= 2 }
        elseif ($isContains)  { $score -= 1 }
        if ($score -lt 0) { $score = 0 }
        [pscustomobject]@{ Candidate = $c; Distance = $d; Score = $score; Prefix = $isPrefix; Contains = $isContains }
    }

    $kept = $scored | Where-Object { $_.Distance -le $cutoff -or $_.Prefix -or $_.Contains }
    if (-not $kept -or $kept.Count -eq 0) { return @() }
    return @($kept | Sort-Object Score, Distance, Candidate | Select-Object -First $Top -ExpandProperty Candidate)
}


function Resolve-InstallKeywords {
    param(
        [string[]]$Keywords
    )

    $keywordsFile = Join-Path $RootDir "scripts\shared\install-keywords.json"
    $isKeywordsFileMissing = -not (Test-Path $keywordsFile)
    if ($isKeywordsFileMissing) {
        Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
        Write-Host "Keyword mapping not found: $keywordsFile"
        return $null
    }

    $keywordData = Get-Content $keywordsFile -Raw | ConvertFrom-Json
    $keywordMap = $keywordData.keywords
    $modesMap  = $keywordData.modes
    $remoteMap = $keywordData.remote

    $tokens = [System.Collections.Generic.List[string]]::new()
    $excludeTokens = [System.Collections.Generic.List[string]]::new()
    $pendingExclude = $false
    $isExcludeStrict = $false
    foreach ($keywordGroup in $Keywords) {
        $isKeywordGroupMissing = [string]::IsNullOrWhiteSpace($keywordGroup)
        if ($isKeywordGroupMissing) {
            continue
        }

        $rawTrim  = "$keywordGroup".Trim()
        $rawLower = $rawTrim.ToLower()

        # --exclude-strict: standalone toggle that turns unknown --exclude tokens
        # into a hard abort instead of a warning. Accepts a few common spellings.
        $isStrictFlag = $rawLower -in @("--exclude-strict","-exclude-strict","--strict-exclude","-strict-exclude","--excludestrict","-excludestrict")
        if ($isStrictFlag) { $isExcludeStrict = $true; continue }

        # --exclude / -exclude / --ex / --without (consumes the next arg as CSV/space list)
        $isExcludeFlag = $rawLower -in @("--exclude","-exclude","--ex","-ex","--without","-without","--skip","-skip")
        if ($isExcludeFlag) { $pendingExclude = $true; continue }

        # --exclude=val,val (inline form)
        $hasExcludePrefix = $rawLower.StartsWith("--exclude=") -or $rawLower.StartsWith("-exclude=") -or $rawLower.StartsWith("--ex=") -or $rawLower.StartsWith("-ex=") -or $rawLower.StartsWith("--without=") -or $rawLower.StartsWith("-without=") -or $rawLower.StartsWith("--skip=") -or $rawLower.StartsWith("-skip=")
        if ($hasExcludePrefix) {
            $excludeValue = $rawTrim.Substring($rawTrim.IndexOf("=") + 1)
            $exParts = $excludeValue -split '[,\s]+' | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_.Length -gt 0 }
            foreach ($ep in $exParts) { $excludeTokens.Add($ep) }
            continue
        }

        $parts = $keywordGroup -split '[,\s]+' | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_.Length -gt 0 }
        foreach ($part in $parts) {
            if ($pendingExclude) {
                $excludeTokens.Add($part)
            } else {
                $tokens.Add($part)
            }
        }
        if ($pendingExclude) { $pendingExclude = $false }
    }

    # Resolve excludeTokens -> set of script IDs to drop. Each exclude token
    # is looked up via the same keywordMap so users can write "obs", "vscode",
    # "conemu", "npp", "wt", "dbeaver" -- whatever maps to a script ID.
    $excludeIds      = [System.Collections.Generic.HashSet[int]]::new()
    $acceptedExcl    = [System.Collections.Generic.List[pscustomobject]]::new()
    $ignoredExcl     = [System.Collections.Generic.List[pscustomobject]]::new()

    # Pre-compute the set of valid exclude tokens (anything that maps to at least
    # one numeric script ID via the keyword map). Used for suggestions on typos.
    $validExcludeTokens = [System.Collections.Generic.List[string]]::new()
    foreach ($kvKey in $keywordMap.Keys) {
        $kvVal = $keywordMap.$kvKey
        $hasNumericId = $false
        foreach ($vv in @($kvVal)) {
            if ($vv -is [int] -or ($vv -is [string] -and $vv -match '^\d+$')) { $hasNumericId = $true; break }
        }
        if ($hasNumericId) { [void]$validExcludeTokens.Add([string]$kvKey) }
    }

    foreach ($exTok in $excludeTokens) {
        $matchedKey = $exTok
        $exIds      = $keywordMap.$exTok
        if ($null -eq $exIds) {
            $exStripped = $exTok -replace '-', ''
            $exIds      = $keywordMap.$exStripped
            if ($null -ne $exIds) { $matchedKey = $exStripped }
        }
        if ($null -eq $exIds) {
            # Rank closest valid tokens by Levenshtein distance (with prefix/substring bonus).
            $suggestions = Get-DidYouMean -Token $exTok -Candidates $validExcludeTokens -Top 3
            $hint = if ($suggestions.Count -gt 0) { " Did you mean: $($suggestions -join ', ')?" } else { "" }
            Write-Log "Unknown --exclude token '$exTok' -- ignored.$hint" -Level "warn"
            $ignoredExcl.Add([pscustomobject]@{ Token = $exTok; Reason = "no matching keyword"; Suggestions = $suggestions })
            continue
        }
        $resolvedIds = [System.Collections.Generic.List[int]]::new()
        foreach ($exId in $exIds) {
            if ($exId -is [int] -or ($exId -is [string] -and $exId -match '^\d+$')) {
                $idInt = [int]$exId
                if ($excludeIds.Add($idInt)) { $resolvedIds.Add($idInt) }
                else { $resolvedIds.Add($idInt) }  # still record for accepted summary
            }
        }
        if ($resolvedIds.Count -eq 0) {
            Write-Log "Exclude token '$exTok' matched keyword '$matchedKey' but resolved to no numeric script IDs -- ignored." -Level "warn"
            $ignoredExcl.Add([pscustomobject]@{ Token = $exTok; Reason = "matched keyword but no numeric IDs"; Suggestions = @() })
            continue
        }
        $acceptedExcl.Add([pscustomobject]@{
            Token       = $exTok
            MatchedKey  = $matchedKey
            ResolvedIds = $resolvedIds
        })
    }

    $hasExcludeTokens = $excludeTokens.Count -gt 0
    if ($hasExcludeTokens) {
        if ($acceptedExcl.Count -gt 0) {
            foreach ($ae in $acceptedExcl) {
                $idStr = ($ae.ResolvedIds | Sort-Object -Unique | ForEach-Object { "{0:D2}" -f $_ }) -join ", "
                Write-Log "Accepted --exclude token '$($ae.Token)' -> [$idStr]" -Level "info"
            }
        }
        if ($ignoredExcl.Count -gt 0) {
            $ignoredList = ($ignoredExcl | ForEach-Object { "'$($_.Token)'" }) -join ", "
            Write-Log "Ignored --exclude tokens: $ignoredList" -Level "warn"
        }
    }

    # --exclude-strict: abort the entire run if any --exclude tokens were unknown
    # or otherwise unresolvable. Prints a clear actionable error before exiting.
    if ($isExcludeStrict -and $ignoredExcl.Count -gt 0) {
        $badList = ($ignoredExcl | ForEach-Object { "'$($_.Token)'" }) -join ", "
        Write-Log "--exclude-strict is set and $($ignoredExcl.Count) --exclude token(s) were invalid: $badList" -Level "fail"
        foreach ($bad in $ignoredExcl) {
            $sugg = if ($bad.Suggestions -and $bad.Suggestions.Count -gt 0) { " (did you mean: $($bad.Suggestions -join ', ')?)" } else { "" }
            Write-Log "  - '$($bad.Token)': $($bad.Reason)$sugg" -Level "fail"
        }
        $validSample = ($validExcludeTokens | Sort-Object | Select-Object -First 12) -join ", "
        Write-Log "Valid --exclude tokens include: $validSample ..." -Level "info"
        Write-Log "Aborting. Re-run without --exclude-strict to continue with the valid tokens only." -Level "info"
        exit 2
    }

    $hasExcludes = $excludeIds.Count -gt 0
    if ($hasExcludes) {
        $excludeList = ($excludeIds | Sort-Object | ForEach-Object { "{0:D2}" -f $_ }) -join ", "
        Write-Log "Excluding script IDs: $excludeList" -Level "info"
    } elseif ($hasExcludeTokens) {
        # User passed --exclude but nothing actually matched -- be loud about it
        # so they don't think the bundle was filtered when it wasn't.
        $validSample = ($validExcludeTokens | Sort-Object | Select-Object -First 12) -join ", "
        Write-Log "No --exclude tokens were valid; full bundle will run. Valid examples: $validSample ..." -Level "warn"
    }

    # Mode priority: install+settings > install-only / settings-only > null
    # When multiple keywords target the same script WITH THE SAME mode, merge to the highest.
    # When modes DIFFER (e.g. "group ml" vs "group jupyter"), keep both as separate runs.
    $modePriority = @{
        "install+settings" = 3
        "install-only"     = 2
        "settings-only"    = 1
    }

    # Build a list of {Id, Mode} entries -- allow same script ID with different modes
    $entries = [System.Collections.Generic.List[hashtable]]::new()
    $hasError = $false

    foreach ($token in $tokens) {
        # Try exact match first, then try without hyphens
        $ids = $keywordMap.$token
        if ($null -eq $ids) {
            $stripped = $token -replace '-', ''
            $ids = $keywordMap.$stripped
        }
        $isUnknown = $null -eq $ids
        if ($isUnknown) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Unknown keyword: '$token'"
            $hasError = $true
            continue
        }

        # Determine mode override for this token (if any)
        $tokenModes = $modesMap.$token
        foreach ($id in $ids) {
            # ── String entry (subcommand or remote convention) ─────────
            # e.g. "os:clean", "profile:base"  -- routes to scripts/<dispatcher>/run.ps1 <action> <args>
            # e.g. "remote:clean-code"         -- streams a remote URL via 'irm | iex'
            $isStringEntry = ($id -is [string]) -and ($id -match '^([a-z0-9][a-z0-9_-]*):(.+)$')
            if ($isStringEntry) {
                $dispatcher = $Matches[1]
                $action     = $Matches[2]

                $isRemoteEntry = $dispatcher -eq "remote"
                if ($isRemoteEntry) {
                    $remoteEntry = $null
                    $hasRemoteMap = $null -ne $remoteMap
                    if ($hasRemoteMap) {
                        $remoteEntry = $remoteMap.$action
                    }
                    # A remote entry must supply either 'url' (HTTP) or 'path' (repo-relative wrapper, v0.47.1+).
                    $remoteUrl  = $null
                    $remotePath = $null
                    if ($null -ne $remoteEntry) {
                        if ($remoteEntry.PSObject.Properties['url'])  { $remoteUrl  = "$($remoteEntry.url)".Trim() }
                        if ($remoteEntry.PSObject.Properties['path']) { $remotePath = "$($remoteEntry.path)".Trim() }
                    }
                    $hasUrl  = -not [string]::IsNullOrWhiteSpace($remoteUrl)
                    $hasPath = -not [string]::IsNullOrWhiteSpace($remotePath)
                    $isRemoteMissing = $null -eq $remoteEntry -or (-not $hasUrl -and -not $hasPath)
                    if ($isRemoteMissing) {
                        Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                        Write-Host "Remote keyword '$token' resolves to 'remote:$action' but no source is mapped in $keywordsFile (need 'remote.$action.url' OR 'remote.$action.path')."
                        $hasError = $true
                        continue
                    }
                    $remoteSha = $null
                    if ($remoteEntry.PSObject.Properties['sha256']) {
                        $rawSha = "$($remoteEntry.sha256)".Trim()
                        if (-not [string]::IsNullOrWhiteSpace($rawSha)) { $remoteSha = $rawSha.ToLowerInvariant() }
                    }
                    # Resolve local path against repo root if present.
                    $resolvedLocalPath = $null
                    if ($hasPath) {
                        $resolvedLocalPath = Join-Path $RootDir $remotePath
                    }
                    $entries.Add(@{ Kind = "remote"; Key = $action; Url = $remoteUrl; LocalPath = $resolvedLocalPath; Label = $remoteEntry.label; Sha256 = $remoteSha; Token = $token })
                    continue
                }

                $entries.Add(@{ Kind = "subcommand"; Dispatcher = $dispatcher; Action = $action; Token = $token })
                continue
            }

            $mode = $null
            if ($null -ne $tokenModes) {
                $mode = $tokenModes."$id"
            }

            # Check if an entry with the same ID already exists
            $existingEntry = $null
            foreach ($e in $entries) {
                $isScriptEntry = ($e.Kind -eq $null) -or ($e.Kind -eq "script")
                if (-not $isScriptEntry) { continue }
                $isSameId = $e.Id -eq [int]$id
                if ($isSameId) {
                    # Same ID: check if mode is identical or mergeable
                    $isSameMode = $e.Mode -eq $mode
                    $isBothNull = ($null -eq $e.Mode) -and ($null -eq $mode)
                    $isBothMergePriority = ($null -ne $e.Mode -and $modePriority.ContainsKey($e.Mode)) -and ($null -ne $mode -and $modePriority.ContainsKey($mode))
                    if ($isSameMode -or $isBothNull -or $isBothMergePriority) {
                        $existingEntry = $e
                        break
                    }
                }
            }

            $isNewEntry = $null -eq $existingEntry
            if ($isNewEntry) {
                $entries.Add(@{ Kind = "script"; Id = [int]$id; Mode = $mode })
            } else {
                # Merge: keep the higher-priority mode (only for install+settings / install-only / settings-only)
                $existingPri = if ($null -ne $existingEntry.Mode -and $modePriority.ContainsKey($existingEntry.Mode)) { $modePriority[$existingEntry.Mode] } else { 0 }
                $newPri      = if ($null -ne $mode -and $modePriority.ContainsKey($mode)) { $modePriority[$mode] } else { 0 }
                $isNewHigher = $newPri -gt $existingPri
                if ($isNewHigher) {
                    $existingEntry.Mode = $mode
                }
            }
        }
    }

    if ($hasError) {
        Write-Host ""
        Write-Host "  Run .\run.ps1 -Help to see all available keywords" -ForegroundColor $ThemeSecondary
        return $null
    }

    # Sort: subcommands + remote streams keep their original order at the END (run after script installs).
    # Script entries are sorted by ID. We split, sort scripts, then concat.
    $scriptEntries     = @($entries | Where-Object { $_.Kind -eq "script" -or $null -eq $_.Kind })
    $subcommandEntries = @($entries | Where-Object { $_.Kind -eq "subcommand" })
    $remoteEntries     = @($entries | Where-Object { $_.Kind -eq "remote" })
    $sortedScripts     = $scriptEntries | Sort-Object { [int]$_.Id }
    $sorted            = @($sortedScripts) + @($subcommandEntries) + @($remoteEntries)

    $preFilterCount = @($sorted).Count
    if ($hasExcludes) {
        $sorted = @($sorted | Where-Object {
            $isScript = ($_.Kind -eq "script") -or ($null -eq $_.Kind)
            if (-not $isScript) { return $true }
            return -not $excludeIds.Contains([int]$_.Id)
        })
    }
    $postFilterCount = @($sorted).Count
    $removedCount    = $preFilterCount - $postFilterCount

    # ── Final --exclude summary ────────────────────────────────────────
    # Always emit when the user passed any --exclude tokens, so the logs
    # have a single, scannable summary of what the filter actually did.
    if ($hasExcludeTokens) {
        Write-Log "------ --exclude summary ------" -Level "info"
        if ($acceptedExcl.Count -gt 0) {
            $acceptedSummary = ($acceptedExcl | ForEach-Object {
                $idStr = ($_.ResolvedIds | Sort-Object -Unique | ForEach-Object { "{0:D2}" -f $_ }) -join ","
                "$($_.Token)->[$idStr]"
            }) -join "  "
            Write-Log "Accepted ($($acceptedExcl.Count)): $acceptedSummary" -Level "ok"
        } else {
            Write-Log "Accepted (0): none" -Level "warn"
        }
        if ($ignoredExcl.Count -gt 0) {
            $ignoredSummary = ($ignoredExcl | ForEach-Object {
                $sg = if ($_.Suggestions -and $_.Suggestions.Count -gt 0) { " (did you mean: $($_.Suggestions -join ','))" } else { "" }
                "'$($_.Token)' [$($_.Reason)]$sg"
            }) -join "; "
            Write-Log "Ignored ($($ignoredExcl.Count)): $ignoredSummary" -Level "warn"
        } else {
            Write-Log "Ignored (0): none" -Level "ok"
        }
        Write-Log "Bundle: $postFilterCount item(s) included, $removedCount removed by --exclude (was $preFilterCount before filtering)" -Level "info"
        Write-Log "-------------------------------" -Level "info"
    }

    return $sorted
}

# ── Run a single script by ID ───────────────────────────────────────

