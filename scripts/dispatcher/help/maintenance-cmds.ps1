# Antigravity maintenance and developer cache cleanup help

function Show-HelpAgyMaintenanceExamples {
    Write-Host "    Antigravity & Gemini Brain Maintenance (script 69) -- detailed examples:" -ForegroundColor $ThemePrimary
    Write-Host "      Prediction, Pruning & Cache Scrubbing:" -ForegroundColor DarkYellow

    Write-HelpServiceLine ".\run.ps1 agy cache clear -k1" "# Preview mode keeping latest 1 conversation intact"
    Write-HelpServiceLine ".\run.ps1 agy clear --keep 10" "# Predict pruning keeping latest 10 conversations intact"
    Write-HelpServiceLine ".\run.ps1 agy cache clear" "# Alias for 'agy clear' (predict mode)"
    Write-HelpServiceLine ".\run.ps1 agy cache-clear" "# Shorthand alias for 'agy clear'"
    Write-HelpServiceLine ".\run.ps1 agy clear keep 10" "# Shorthand syntax without leading dashes"
    Write-HelpServiceLine ".\run.ps1 agy clean" "# Alias for 'agy clear' (runs safe prediction)"
    Write-HelpServiceLine ".\run.ps1 agy clear --keep 5 --threshold 100" "# Prune conversations >100KB keeping latest 5"
    Write-HelpServiceLine ".\run.ps1 clean-agy 10" "# Direct root shortcut with positional retention count"

    Write-Host "      Applying Cleanup & Pruning:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 agy clear --keep 10 -y" "# Apply conversation prune & scrub Electron/GPU caches"
    Write-HelpServiceLine ".\run.ps1 agy clear --keep 10 -y --kill" "# Terminate Antigravity processes prior to applying"

    Write-Host "      Rollback & Transaction History:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 agy list-backups" "# View all past pruning transactions & timestamps"
    Write-HelpServiceLine ".\run.ps1 agy undo latest" "# Restore pruned steps from the latest transaction"
    Write-HelpServiceLine ".\run.ps1 agy undo <transaction-id>" "# Rollback a specific historical transaction"

    Write-Host ""
}

function Show-HelpDevCacheExamples {
    Write-Host "    Developer Tools Cache Cleanup (dev-clean / clean-dev / os dev-cleanup) -- detailed examples:" -ForegroundColor $ThemePrimary
    Write-Host "      Developer Cache Sweeper (Go, pnpm, npm, Choco, Yarn, Bun, pip, Cargo, Gradle, Maven, NuGet, Antigravity):" -ForegroundColor DarkYellow

    Write-HelpServiceLine ".\run.ps1 clean-dev" "# Interactive cleanup across all 12 developer caches"
    Write-HelpServiceLine ".\run.ps1 clean-dev --dry-run" "# Preview space that would be reclaimed without deleting"
    Write-HelpServiceLine ".\run.ps1 clean-dev -y" "# Skip confirmation prompt (auto-approve cleanup)"
    Write-HelpServiceLine ".\run.ps1 dev-clean" "# Shorthand alias for 'clean-dev'"
    Write-HelpServiceLine ".\run.ps1 dev-cleanup" "# Shorthand alias for 'clean-dev'"
    Write-HelpServiceLine ".\run.ps1 os dev-cleanup" "# Run dev tools cache sweep via OS dispatcher"
    Write-HelpServiceLine ".\run.ps1 os dev-cleanup --dry-run" "# Preview reclaimable dev cache via OS dispatcher"
    Write-HelpServiceLine ".\run.ps1 os dev-cleanup -y" "# Auto-confirm dev cache sweep via OS dispatcher"

    Write-Host "      Runtime & Package Manager Caches Covered:" -ForegroundColor DarkYellow
    Write-Host "        Go".PadRight(24) -NoNewline; Write-Host "Build cache, test cache, fuzz cache, GOMODCACHE module downloads" -ForegroundColor $ThemeMuted
    Write-Host "        pnpm / npm / Yarn".PadRight(24) -NoNewline; Write-Host "CAS store prune, dev-tool\pnpm\store, npm-cache, Yarn cache" -ForegroundColor $ThemeMuted
    Write-Host "        Bun / Python pip".PadRight(24) -NoNewline; Write-Host "Bun pm cache rm, pip HTTP download cache & wheel cache" -ForegroundColor $ThemeMuted
    Write-Host "        Cargo / Rust".PadRight(24) -NoNewline; Write-Host "~/.cargo/registry/cache and git checkout clones" -ForegroundColor $ThemeMuted
    Write-Host "        Gradle / Maven".PadRight(24) -NoNewline; Write-Host "~/.gradle/caches daemon/dependencies, ~/.m2/repository" -ForegroundColor $ThemeMuted
    Write-Host "        .NET / NuGet".PadRight(24) -NoNewline; Write-Host "dotnet nuget locals all --clear + %LOCALAPPDATA%\NuGet\v3-cache" -ForegroundColor $ThemeMuted
    Write-Host "        Chocolatey".PadRight(24) -NoNewline; Write-Host "choco cache clean + package download archives in %TEMP%" -ForegroundColor $ThemeMuted
    Write-Host "        Antigravity / AI".PadRight(24) -NoNewline; Write-Host "Brain conversation history, Electron/GPU caches, task dumps" -ForegroundColor $ThemeMuted

    Write-Host "      Multi-Layer Work Artifacts & System Cache Cleaner (Windows, macOS & Linux/Unix):" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 clean --help" "# Detailed help for all clean/clear subcommands"
    Write-HelpServiceLine ".\run.ps1 clean all --dry-run" "# Plan Mode: preview all 8 layers & reclaimable space"
    Write-HelpServiceLine ".\run.ps1 clean all -y" "# Auto-clean Work, Go, npm/pnpm, DevTools, Temp, WU, Recycle, Git"
    Write-HelpServiceLine ".\run.ps1 clean artifacts --dry-run" "# Preview work directory (D:\work) build folders & binaries"
    Write-HelpServiceLine ".\run.ps1 clean artifacts -y" "# Remove D:\work build folders/binaries (keeps node_modules)"
    Write-HelpServiceLine ".\run.ps1 clean go -y" "# Clean Go GOCACHE, GOMODCACHE, testcache & fuzzcache"
    Write-HelpServiceLine ".\run.ps1 clean npm -y" "# Clean npm, pnpm store, Yarn, Bun & Node caches"
    Write-HelpServiceLine ".\run.ps1 clean devtools -y" "# Clean Chrome/Edge/VS Code DevTools & GPU caches"
    Write-HelpServiceLine ".\run.ps1 clean temp -y" "# Clean %TEMP%, %LOCALAPPDATA%\Temp, C:\Windows\Temp, /tmp"
    Write-HelpServiceLine ".\run.ps1 clean wu-download -y" "# Clean Windows SoftwareDistribution\Download"
    Write-HelpServiceLine ".\run.ps1 clean recycle -y" "# Empty Recycle Bin ($Recycle.Bin / ~/.Trash)"
    Write-HelpServiceLine ".\run.ps1 clean git-cache -y" "# Clean Git cache folders (~/.gitcache, .gitmap, tmp_pack_*)"
    Write-HelpServiceLine "./run.sh clean all --dry-run" "# macOS / Linux / Unix Plan Mode preview"
    Write-HelpServiceLine "./run.sh clean all -y" "# macOS / Linux / Unix auto-clean across all layers"

    Write-Host "      Targeted Cleaners:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 clean-agy 10" "# Prune Antigravity brain keeping latest 10 conversations"
    Write-HelpServiceLine ".\run.ps1 agy clear --keep 10 -y" "# Apply Antigravity conversation prune & cache scrub"
    Write-HelpServiceLine ".\run.ps1 os clean" "# General disk cleanup (temp, updates, logs)"
    Write-HelpServiceLine ".\run.ps1 os temp-clean" "# Purge user and system Temp folders"
    Write-HelpServiceLine ".\run.ps1 os choco-clean" "# Clean Chocolatey download archives & broken packages"
    Write-HelpServiceLine "python 03-ai-scripts/44-work-and-system-cache-cleaner.py --dry-run" "# Direct Python multi-layer Plan preview"
    Write-HelpServiceLine "python 03-ai-scripts/44-work-and-system-cache-cleaner.py -y" "# Direct Python multi-layer execution"

    Write-Host ""
}

function Show-HelpMaintenance {
    Show-HelpAgyMaintenanceExamples
    Show-HelpDevCacheExamples
}
