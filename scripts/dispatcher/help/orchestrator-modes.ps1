# Script 12 orchestrator, defaults mode, and per-script help

function Show-HelpScript12Modes {
    $kc = 44
    Write-Host "  Script 12 (Install All Dev Tools):" -ForegroundColor $ThemeAccent
    Write-Host "    $(".\run.ps1 -I 12".PadRight($kc))" -NoNewline; Write-Host "Interactive menu -- pick what to install" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 12 -- -All".PadRight($kc))" -NoNewline; Write-Host "Install everything without prompting" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 12 -- -Skip 04,06".PadRight($kc))" -NoNewline; Write-Host "Skip pnpm and Go" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 12 -- -Only 02,03".PadRight($kc))" -NoNewline; Write-Host "Run only Package Managers + Node.js" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "  Defaults Mode:" -ForegroundColor $ThemeAccent
    Write-Host "    $(".\run.ps1 -d -Defaults".PadRight($kc))" -NoNewline; Write-Host "All-dev with defaults, prompt to confirm" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -d -Defaults -Y".PadRight($kc))" -NoNewline; Write-Host "All-dev with defaults, auto-confirm" -ForegroundColor $ThemeMuted
    Write-Host ""
}

function Show-HelpPerScriptAndPathChanges {
    $kc = 44
    Write-Host "  Per-script help:" -ForegroundColor $ThemeAccent
    Write-Host "    $(".\run.ps1 -I <number> -- -Help".PadRight($kc))" -NoNewline; Write-Host "Show help for a specific script" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "  Change default dev directory:" -ForegroundColor $ThemeAccent
    Write-Host "    .\run.ps1 path                      Show current default dev directory" -ForegroundColor $ThemeMuted
    Write-Host "    .\run.ps1 path D:\dev-tool          Set default dev directory (persisted)" -ForegroundColor $ThemeMuted
    Write-Host "    .\run.ps1 path --reset              Clear saved path, use smart detection" -ForegroundColor $ThemeMuted
    Write-Host "    `$env:DEV_DIR = 'D:\dev-tool'        Per-session override (highest priority)" -ForegroundColor $ThemeMuted
    Write-Host "    .\run.ps1 -I <id> -Path D:\dev-tool  One-shot override for this run" -ForegroundColor $ThemeMuted
    Write-Host ""
}
