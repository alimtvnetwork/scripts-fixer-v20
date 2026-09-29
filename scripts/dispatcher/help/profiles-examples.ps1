# Profile runnable examples and common flags

function Show-HelpProfileCommandPairs {
    param([array]$ProfileNames)

    $hasProfiles = $ProfileNames.Count -gt 0
    if (-not $hasProfiles) {
        return
    }

    $ec = 40
    foreach ($pname in $ProfileNames) {
        Write-Host "    $((".\run.ps1 profile $pname").PadRight($ec))" -NoNewline -ForegroundColor Green
        Write-Host "# run '$pname' profile" -ForegroundColor $ThemeMuted
        Write-Host "    $((".\run.ps1 install $pname").PadRight($ec))" -NoNewline -ForegroundColor Green
        Write-Host "# same, via 'install' shortcut" -ForegroundColor $ThemeMuted
        Write-Host ""
    }
}

function Show-HelpProfileCommonFlags {
    param([array]$ProfileNames)

    Write-Host "  Common profile flags:" -ForegroundColor $ThemeAccent
    Write-Host ""
    Write-Host "    .\run.ps1 profile list                  " -NoNewline
    Write-Host "# list all profiles with full descriptions" -ForegroundColor $ThemeMuted

    $hasProfiles = $ProfileNames.Count -gt 0
    if ($hasProfiles) {
        $sample = $ProfileNames[0]
        Write-Host "    .\run.ps1 profile tree $sample".PadRight(44) -NoNewline
        Write-Host "# view full installation tree" -ForegroundColor $ThemeMuted
        Write-Host "    .\run.ps1 profile $sample --dry-run".PadRight(44) -NoNewline
        Write-Host "# preview steps, do not execute" -ForegroundColor $ThemeMuted
        Write-Host "    .\run.ps1 profile $sample -y".PadRight(44) -NoNewline
        Write-Host "# skip confirmation prompts" -ForegroundColor $ThemeMuted
        Write-Host "    .\run.ps1 install $sample -y".PadRight(44) -NoNewline
        Write-Host "# install shortcut + auto-confirm" -ForegroundColor $ThemeMuted
    }

    Write-Host ""
}

function Show-HelpProfileExamples {
    param([array]$ProfileNames)

    Write-Host "  Profile Examples (copy-paste):" -ForegroundColor $ThemeAccent
    Write-Host "  (both forms are equivalent -- pick whichever you prefer)" -ForegroundColor $ThemeMuted
    Write-Host ""

    Show-HelpProfileCommandPairs -ProfileNames $ProfileNames
    Show-HelpProfileCommonFlags -ProfileNames $ProfileNames
}
