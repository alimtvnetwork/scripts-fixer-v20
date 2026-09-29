# Match summary display and file export for filtered help

function Show-HelpFilterSummary {
    param([int]$Matched, [array]$Needles, [string]$DisplayFilter, [hashtable]$PerTermCounts)

    Write-Host ""
    if ($Matched -eq 0) {
        Write-Host "  No help lines match: $DisplayFilter" -ForegroundColor $ThemeAccent
        Write-Host "  Tip: try fewer terms or broader keywords (e.g. 'chrome', 'ext', 'menu', 'os')." -ForegroundColor $ThemeMuted
    } else {
        $termWord = if ($Needles.Count -eq 1) { "term" } else { "terms (AND)" }
        Write-Host "  $Matched line(s) matched $($Needles.Count) $termWord -- $DisplayFilter" -ForegroundColor Green
        Write-Host "  Run '.\run.ps1 help' (no keyword) to see the full help screen." -ForegroundColor $ThemeMuted
    }

    Write-Host ""
    Write-Host "  Per-term hit counts (independent, not AND):" -ForegroundColor $ThemeSecondary
    $kwCol = [Math]::Max(8, ($Needles | Measure-Object -Property Length -Maximum).Maximum + 2)
    $hitCol = 7
    Write-Host ("    {0}{1}{2}" -f "Keyword".PadRight($kwCol), "Lines".PadRight($hitCol), "Share") -ForegroundColor $ThemeMuted
    Write-Host ("    {0}{1}{2}" -f ("".PadRight($kwCol,'-')), ("".PadRight($hitCol,'-')), "-----") -ForegroundColor $ThemeMuted

    foreach ($n in $Needles) {
        $hits = [int]$PerTermCounts[$n]
        $color = if ($hits -eq 0) { "Red" }
                 elseif ($hits -eq $Matched -and $Matched -gt 0) { "Green" }
                 elseif ($hits -ge 5) { "Cyan" }
                 else { "DarkYellow" }
        $share = if ($hits -gt 0) {
            $pct = [Math]::Round(($Matched / [double]$hits) * 100, 0)
            "$Matched/$hits AND-kept (${pct}%)"
        } else {
            "0 lines contain this term -> blocks AND match"
        }
        Write-Host ("    {0}" -f $n.PadRight($kwCol)) -ForegroundColor White -NoNewline
        Write-Host ("{0}" -f "$hits".PadRight($hitCol)) -ForegroundColor $color -NoNewline
        Write-Host $share -ForegroundColor $ThemeMuted
    }

    if ($Needles.Count -gt 1) {
        Write-Host "    (AND intersection: $Matched line(s))" -ForegroundColor $ThemeMuted
    }
}

function Export-HelpFilterResults {
    param(
        [string]$OutFile,
        [string]$Format,
        [string]$DisplayFilter,
        [array]$Needles,
        [int]$Matched,
        [System.Collections.Generic.List[object]]$MatchedRich,
        [System.Collections.Generic.List[string]]$MatchedPlain
    )

    if ([string]::IsNullOrWhiteSpace($OutFile)) {
        return
    }

    try {
        $outFull = if ([System.IO.Path]::IsPathRooted($OutFile)) { $OutFile } else { Join-Path (Get-Location).Path $OutFile }
        $parent = Split-Path -Parent $outFull
        if ($parent -and -not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        if ($Format -eq "json") {
            $payload = [pscustomobject]@{
                generatedAt = (Get-Date).ToString("o")
                filter      = $DisplayFilter
                keywords    = $Needles
                matchCount  = $Matched
                lines       = $MatchedRich
            }
            $payload | ConvertTo-Json -Depth 6 | Set-Content -Path $outFull -Encoding UTF8
        } else {
            $header = @(
                "# Filtered help -- keyword(s): $DisplayFilter",
                "# Generated: $((Get-Date).ToString('o'))",
                "# Matches  : $Matched",
                ""
            )
            ($header + $MatchedPlain) | Set-Content -Path $outFull -Encoding UTF8
        }

        Write-Host ""
        Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
        Write-Host "Saved $Matched line(s) to: " -NoNewline
        Write-Host "$outFull" -ForegroundColor $ThemeSecondary
        Write-Host "          Format: $Format" -ForegroundColor $ThemeMuted
    } catch {
        Write-Host ""
        Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
        Write-Host "Could not write export file: $OutFile"
        Write-Host "          Reason: $($_.Exception.Message)" -ForegroundColor $ThemeMuted
    }
}
