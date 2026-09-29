# Profiles section orchestrator

. (Join-Path $PSScriptRoot "profiles-list.ps1")
. (Join-Path $PSScriptRoot "profiles-issues.ps1")
. (Join-Path $PSScriptRoot "profiles-examples.ps1")

function Show-HelpProfilesHeader {
    param([int]$EntryCount, [string]$ConfigPath, [int]$AliasCount, [string]$AliasesPath)

    Write-Host ("  Profiles ({0} available):" -f $EntryCount) -ForegroundColor $ThemeAccent
    Write-Host "  (multi-step install recipes -- run with 'profile <name>' or 'install <name>')" -ForegroundColor $ThemeMuted
    Write-Host ("  source: {0}" -f $ConfigPath) -ForegroundColor $ThemeMuted

    $hasAliases = $AliasCount -gt 0
    if ($hasAliases) {
        Write-Host ("  aliases: {0} (grouped under their resolved profile)" -f $AliasesPath) -ForegroundColor $ThemeMuted
    }

    Write-Host ""
}

function Show-HelpProfiles {
    $paths = Get-HelpProfilePaths
    $hasValidator = Test-Path $paths.ValidatorPath
    $hasValidatorCmd = $null -ne (Get-Command Test-ProfileConfig -ErrorAction SilentlyContinue)

    if ($hasValidator -and -not $hasValidatorCmd) {
        try { . $paths.ValidatorPath } catch { $hasValidator = $false }
    }

    $entries = Load-HelpProfileEntries -ConfigPath $paths.ConfigPath -HasValidator $hasValidator
    $profileNames = @($entries | ForEach-Object { $_.Name })
    $aliasesByTarget = @{}
    $hasAliasesCmd = $null -ne (Get-Command Get-ProfileAliasesByTarget -ErrorAction SilentlyContinue)

    if ($hasValidator -and $hasAliasesCmd) {
        $byTgt = Get-ProfileAliasesByTarget -FilePath $paths.AliasesPath -KnownProfileNames $profileNames
        if ($null -ne $byTgt) { $aliasesByTarget = $byTgt }
    }

    Show-HelpProfilesHeader -EntryCount $entries.Count -ConfigPath $paths.ConfigPath -AliasCount $aliasesByTarget.Count -AliasesPath $paths.AliasesPath

    $hasEntries = $entries.Count -gt 0
    if ($hasEntries) {
        Show-HelpProfileItems -Entries $entries -AliasesByTarget $aliasesByTarget
    } else {
        Write-Host "    (no profiles available -- see issues report below)" -ForegroundColor DarkYellow
        Write-Host "    Try: .\run.ps1 profile list" -ForegroundColor DarkYellow
    }

    Write-Host ""

    $cfgValidation = if ($hasValidator) { Test-ProfileConfig -FilePath $paths.ConfigPath } else { $null }
    $aliasValidation = if ($hasValidator) { Test-ProfileAliasesConfig -FilePath $paths.AliasesPath -KnownProfileNames $profileNames } else { $null }

    Show-HelpProfileIssues -HasValidator $hasValidator -CfgValidation $cfgValidation -AliasValidation $aliasValidation -AliasesByTarget $aliasesByTarget -AliasesPath $paths.AliasesPath
    Show-HelpProfileExamples -ProfileNames $profileNames
}
