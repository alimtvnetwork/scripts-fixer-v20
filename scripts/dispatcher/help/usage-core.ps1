# Core CLI usage commands and invocation syntax

function Write-HelpUsageEntry {
    param([string]$Syntax, [string]$Description)

    $col = 44
    Write-Host "    $($Syntax.PadRight($col))" -NoNewline
    Write-Host $Description -ForegroundColor $ThemeMuted
}

function Show-HelpUsageCore {
    Write-HelpUsageEntry ".\run.ps1 install <keywords>" "Install by keyword (bare command)"
    Write-HelpUsageEntry ".\run.ps1 -Install <keywords>" "Install by keyword (named parameter)"
    Write-HelpUsageEntry ".\run.ps1 update" "Show outdated, confirm, upgrade all"
    Write-HelpUsageEntry ".\run.ps1 update nodejs,git" "Upgrade specific packages only"
    Write-HelpUsageEntry ".\run.ps1 update --check" "List outdated packages (no upgrade)"
    Write-HelpUsageEntry ".\run.ps1 update -y" "Upgrade all, skip confirmation"
    Write-HelpUsageEntry ".\run.ps1 update --exclude=pkg1,pkg2" "Upgrade all except listed"
    Write-HelpUsageEntry ".\run.ps1 self-update" "Refresh local scripts-fixer copy (git pull)"
    Write-HelpUsageEntry ".\run.ps1 self-update --check" "Show if local copy is behind upstream (no pull)"
    Write-HelpUsageEntry ".\run.ps1 self-update --reinstall" "Pull, then re-run install.ps1 (refresh shims/PATH)"
    Write-HelpUsageEntry ".\run.ps1 export" "Export all app settings to repo"
    Write-HelpUsageEntry ".\run.ps1 export npp,obs" "Export specific app settings"
    Write-HelpUsageEntry ".\run.ps1 export-config <app>" "Export app config (qtorrent, utorrent, vscode)"
    Write-HelpUsageEntry ".\run.ps1 import-config <app>" "Import app config (qtorrent, utorrent, vscode)"
    Write-HelpUsageEntry ".\run.ps1 status" "Show dashboard of all installed tools"
    Write-HelpUsageEntry ".\run.ps1 status --no-choco" "Status without outdated package check"
    Write-HelpUsageEntry ".\run.ps1 report [--since=24h] [--open]" "Timestamped JSON+HTML report of install/uninstall actions"
    Write-HelpUsageEntry ".\run.ps1 doctor" "Quick health check of project setup"
    Write-HelpUsageEntry ".\run.ps1 doctor --self-check" "Deep audit: changelog files, version, clean catalog, keyword resolution, SHA256 pins"
    Write-HelpUsageEntry ".\run.ps1 doctor --self-check --skip-network" "Same as above but skips sections (d) + (e) for offline use"
    Write-HelpUsageEntry ".\run.ps1 models" "Pick AI model backend (llama.cpp / Ollama), browse + install"
    Write-HelpUsageEntry ".\run.ps1 models <ids>" "Direct install: CSV of model ids (auto-routes per backend)"
    Write-HelpUsageEntry ".\run.ps1 models list" "List all models from both catalogs"
    Write-HelpUsageEntry ".\run.ps1 models-download <n|id>" "Top-level shortcut for 'models download ...'"
    Write-HelpUsageEntry ".\run.ps1 install model <ids>" "Same shortcut: 'install model 93' or 'install model 93,94' (standalone GGUF)"
    Write-HelpUsageEntry ".\run.ps1 -M" "Shortcut for 'models'"
    Write-HelpUsageEntry ".\run.ps1 download <url> [<dir>]" "Fast download (aria2c, defaults -s 16 -p 1M); 'url' is alias"
    Write-HelpUsageEntry ".\run.ps1 download <url> -s 12 -p 2M" "Override splits (per-server connections) and piece size"
}
