# Available keywords table orchestrator

. (Join-Path $PSScriptRoot "keyword-table-dev.ps1")
. (Join-Path $PSScriptRoot "keyword-table-tools.ps1")
. (Join-Path $PSScriptRoot "keyword-table-combos.ps1")

function Show-HelpKeywordTableHeader {
    param([bool]$IsInline)

    if ($IsInline) {
        Write-Host "  Available Keywords:" -ForegroundColor $ThemeAccent
    } else {
        Write-Host ""
        Write-Host "  Available Keywords" -ForegroundColor $ThemeSecondary
        Write-Host "  ==================" -ForegroundColor $ThemeMuted
    }

    Write-Host ""
    $kwCol = 28
    $descCol = 36
    Write-Host "    $("Keyword".PadRight($kwCol))$("Description".PadRight($descCol))Script ID" -ForegroundColor $ThemeMuted
    Write-Host "    $(''.PadRight($kwCol, '-'))$(''.PadRight($descCol, '-'))---------" -ForegroundColor $ThemeMuted
}

function Show-KeywordTable {
    param([switch]$Inline)

    $isInline = [bool]$Inline
    Show-HelpKeywordTableHeader -IsInline $isInline

    Show-HelpKeywordsDev
    Show-HelpKeywordsTools
    Show-HelpKeywordsRemote
    Show-HelpKeywordsCombos
}
