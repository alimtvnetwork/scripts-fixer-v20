# Help filter and search guide

function Show-HelpFilterUsageAndExamples {
    Write-Host "  Filter / search the help text:" -ForegroundColor $ThemeAccent
    Write-Host "    .\run.ps1 help <keyword>            Show only help lines that match <keyword> (case-insensitive)" -ForegroundColor $ThemeMuted
    Write-Host "    .\run.ps1 -h <keyword>              Same as above (any of: help, --help, -h, /?, ?)" -ForegroundColor $ThemeMuted
    Write-Host "    .\run.ps1 help                      No keyword -> full help (this screen)" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Examples:" -ForegroundColor $ThemeSecondary
    Write-Host "      .\run.ps1 help chrome             Chrome browser + extension commands" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help ext-url            Ad-hoc Chrome extension URL / ID examples" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help conemu             ConEmu install + right-click context menu" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help vscode             VS Code install, settings sync, folder repair" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help profile            Profile recipes (small-dev, alldev, ...)" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help mysql              MySQL installer + related database keywords" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help uninstall          Every uninstall / remove command" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help export             Settings export commands across tools" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help chrome ext         Multiple terms -> AND match (lines with BOTH words)" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help vscode uninstall   AND match: VS Code uninstall commands only" -ForegroundColor $ThemeMuted
    Write-Host ""
}

function Show-HelpFilterExportsAndDiscovery {
    Write-Host "    Save filtered help to a file:" -ForegroundColor $ThemeSecondary
    Write-Host "      .\run.ps1 help chrome --out chrome-help.txt    Plain text (extension auto-detected)" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help chrome --out chrome-help.json   JSON (auto from .json extension)" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help vscode --json vscode.json       Force JSON regardless of extension" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help conemu --text conemu.log        Force plain text" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Discover available filter keywords:" -ForegroundColor $ThemeSecondary
    Write-Host "      .\run.ps1 help --list                          Show every recommended filter + match count" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help filters                         Same (aliases: list, filters, keywords)" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Verify the filter is case-insensitive:" -ForegroundColor $ThemeSecondary
    Write-Host "      .\run.ps1 help --self-test                     Run canned PASS/FAIL casing tests" -ForegroundColor $ThemeMuted
    Write-Host "      .\run.ps1 help --test                          Same (short alias)" -ForegroundColor $ThemeMuted
    Write-Host ""
}

function Show-HelpFilterGuide {
    Show-HelpFilterUsageAndExamples
    Show-HelpFilterExportsAndDiscovery
}
