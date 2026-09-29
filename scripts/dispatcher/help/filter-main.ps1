# Root help entry point with filtering and export

. (Join-Path $PSScriptRoot "filter-engine.ps1")
. (Join-Path $PSScriptRoot "filter-summary-export.ps1")

function Resolve-HelpExportFormat {
    param([string]$OutFile, [string]$RequestedFormat, [hashtable]$BoundParams)

    $hasFormat = $BoundParams.ContainsKey('Format')
    if ($hasFormat) {
        return $RequestedFormat
    }

    $hasOutFile = -not [string]::IsNullOrWhiteSpace($OutFile)
    if ($hasOutFile) {
        $ext = [System.IO.Path]::GetExtension($OutFile).ToLower()
        if ($ext -eq ".json") {
            return "json"
        }
    }

    return "text"
}

function Show-RootHelp {
    param(
        [string]$Filter,
        [string]$OutFile,
        [ValidateSet("text", "json")]
        [string]$Format = "text"
    )

    $needles = Get-HelpFilterNeedles -Filter $Filter
    $hasNeedles = $needles.Count -gt 0
    if (-not $hasNeedles) {
        Show-RootHelpRaw
        return
    }

    $displayFilter = $needles -join ' AND '
    $resolvedFormat = Resolve-HelpExportFormat -OutFile $OutFile -RequestedFormat $Format -BoundParams $PSBoundParameters

    $records = & { Show-RootHelpRaw } 6>&1

    Write-Host ""
    Write-Host "  Filtered help -- keyword(s): $displayFilter" -ForegroundColor $ThemeSecondary
    Write-Host "  ===================================" -ForegroundColor $ThemeMuted
    Write-Host ""

    $result = Execute-HelpFilterSearch -Records $records -Needles $needles

    Show-HelpFilterSummary -Matched $result.MatchCount -Needles $needles -DisplayFilter $displayFilter -PerTermCounts $result.PerTermCounts
    Export-HelpFilterResults -OutFile $OutFile -Format $resolvedFormat -DisplayFilter $displayFilter -Needles $needles -Matched $result.MatchCount -MatchedRich $result.MatchedRich -MatchedPlain $result.MatchedPlain

    Write-Host ""
}
