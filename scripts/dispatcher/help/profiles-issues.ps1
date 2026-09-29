# Profiles issues and orphan aliases reporting

function Show-HelpProfileOrphans {
    param([hashtable]$AliasesByTarget, [string]$AliasesPath)

    $hasOrphansKey = $AliasesByTarget.ContainsKey('__orphans__')
    if (-not $hasOrphansKey) {
        return
    }

    $orphans = $AliasesByTarget['__orphans__']
    $hasOrphans = $null -ne $orphans -and $orphans.Count -gt 0
    if (-not $hasOrphans) {
        return
    }

    Write-Host ("  Orphan aliases ({0}) -- target not in profile catalog:" -f $orphans.Count) -ForegroundColor $ThemeAccent
    Write-Host ("  source: {0}" -f $AliasesPath) -ForegroundColor $ThemeMuted
    Write-Host ""

    foreach ($a in $orphans) {
        Write-Host ("    [{0}] {1,-14} -> {2}  (UNRESOLVED)" -f $a.Kind, $a.Name, $a.Target) -ForegroundColor DarkYellow
    }

    Write-Host ""
}

function Show-HelpProfileIssues {
    param(
        [bool]$HasValidator,
        [object]$CfgValidation,
        [object]$AliasValidation,
        [hashtable]$AliasesByTarget,
        [string]$AliasesPath
    )

    $hasFormatCmd = $null -ne (Get-Command Format-ProfileConfigIssues -ErrorAction SilentlyContinue)
    $hasCfgIssues = $HasValidator -and $null -ne $CfgValidation -and $hasFormatCmd
    if ($hasCfgIssues) {
        Format-ProfileConfigIssues -Result $CfgValidation -Title "Profile config issues"
    }

    Show-HelpProfileOrphans -AliasesByTarget $AliasesByTarget -AliasesPath $AliasesPath

    $hasAliasIssues = $HasValidator -and $null -ne $AliasValidation -and $hasFormatCmd
    if ($hasAliasIssues) {
        Format-ProfileConfigIssues -Result $AliasValidation -Title "Profile aliases issues"
    }
}
