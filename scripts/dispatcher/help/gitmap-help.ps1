# GitMap dedicated help screen

function Show-GitmapHelpHeader {
    Write-Host ""
    Write-Host "  GitMap CLI -- Developer Companion & Fast Scanner" -ForegroundColor $ThemeSecondary
    Write-Host "  ========================================================" -ForegroundColor $ThemeMuted
    Write-Host "  Author: MD ALIM UL KARIM  |  Sponsor: RISEUP ASIA LLC" -ForegroundColor $ThemeMuted
    Write-Host "  USAGE: " -ForegroundColor $ThemeAccent -NoNewline
    Write-Host ".\run.ps1 gitmap <command> [args]" -ForegroundColor White
    Write-Host ""
}

function Show-GitmapHelpPrimaryActions {
    Write-Host "  PRIMARY & REPOSITORY COMMANDS:" -ForegroundColor $ThemeAccent
    Write-Host "    status | doctor     " -ForegroundColor Green -NoNewline; Write-Host "Health check, git hygiene, and split-db integrity" -ForegroundColor $ThemeMuted
    Write-Host "    scan                " -ForegroundColor Green -NoNewline; Write-Host "Discover and index local Git repositories" -ForegroundColor $ThemeMuted
    Write-Host "    pull | sync         " -ForegroundColor Green -NoNewline; Write-Host "Parallel fetch and sync repositories across disks" -ForegroundColor $ThemeMuted
    Write-Host "    cd <alias|path>     " -ForegroundColor Green -NoNewline; Write-Host "Jump directly to repository root directory" -ForegroundColor $ThemeMuted
    Write-Host "    repo list           " -ForegroundColor Green -NoNewline; Write-Host "List registered repositories and active branches" -ForegroundColor $ThemeMuted
    Write-Host "    group list          " -ForegroundColor Green -NoNewline; Write-Host "List logical repository grouping namespaces" -ForegroundColor $ThemeMuted
    Write-Host ""
}

function Show-GitmapHelpAutomationActions {
    Write-Host "  AUTOMATION (AUM) & SEARCH:" -ForegroundColor $ThemeAccent
    Write-Host "    aum search | grep   " -ForegroundColor Green -NoNewline; Write-Host "Fast parallel symbol and regex search across repos" -ForegroundColor $ThemeMuted
    Write-Host "    aum guard           " -ForegroundColor Green -NoNewline; Write-Host "Pre-commit verification and secret leak auditing" -ForegroundColor $ThemeMuted
    Write-Host "    aum sequence        " -ForegroundColor Green -NoNewline; Write-Host "Re-sequence numeric prefixes and normalize filenames" -ForegroundColor $ThemeMuted
    Write-Host "    search <symbol>     " -ForegroundColor Green -NoNewline; Write-Host "Instant SQLite indexed symbol search" -ForegroundColor $ThemeMuted
    Write-Host "    ff <pattern>        " -ForegroundColor Green -NoNewline; Write-Host "Fast file locator (ff, ffa, ffs, ffe)" -ForegroundColor $ThemeMuted
    Write-Host ""
}

function Show-GitmapHelpPipelineAndLlmActions {
    Write-Host "  PIPELINE, AGY & LLM:" -ForegroundColor $ThemeAccent
    Write-Host "    pipeline status     " -ForegroundColor Green -NoNewline; Write-Host "Query CI/CD status and runner pipeline health" -ForegroundColor $ThemeMuted
    Write-Host "    pipeline errors     " -ForegroundColor Green -NoNewline; Write-Host "Extract and summarize bounded CI failure logs" -ForegroundColor $ThemeMuted
    Write-Host "    agy running-prompts " -ForegroundColor Green -NoNewline; Write-Host "Inspect active Antigravity background tasks" -ForegroundColor $ThemeMuted
    Write-Host "    agy sug | clear 10  " -ForegroundColor Green -NoNewline; Write-Host "Smart prompt suggestions or prune conversations" -ForegroundColor $ThemeMuted
    Write-Host ""
}

function Show-GitmapHelpClusterAndStorageActions {
    Write-Host "  FLEET, CLUSTER & UTILITIES:" -ForegroundColor $ThemeAccent
    Write-Host "    ssh list            " -ForegroundColor Green -NoNewline; Write-Host "List discovered SSH hosts and credential profiles" -ForegroundColor $ThemeMuted
    Write-Host "    cluster list        " -ForegroundColor Green -NoNewline; Write-Host "Show status of connected multi-node workers" -ForegroundColor $ThemeMuted
    Write-Host "    storage list        " -ForegroundColor Green -NoNewline; Write-Host "Report disk consumption and cleanable caches" -ForegroundColor $ThemeMuted
    Write-Host "    completion install  " -ForegroundColor Green -NoNewline; Write-Host "Install PowerShell/Bash shell auto-completion" -ForegroundColor $ThemeMuted
    Write-Host ""
}

function Show-GitmapHelp {
    Show-GitmapHelpHeader
    Show-GitmapHelpPrimaryActions
    Show-GitmapHelpAutomationActions
    Show-GitmapHelpPipelineAndLlmActions
    Show-GitmapHelpClusterAndStorageActions
}
