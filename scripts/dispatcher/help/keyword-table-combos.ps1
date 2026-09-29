# Keyword table: Remote installers, combo shortcuts, and usage footer

function Show-HelpKeywordsRemote {
    Write-Host "    Remote installers (irm | iex)" -ForegroundColor $ThemePrimary
    Write-HelpKeywordTableRow "clean-code, cg, cc" "Coding Guidelines v24" "remote"
    Write-HelpKeywordTableRow "code-guide" "Coding Guidelines v24 (alias)" "remote"
    Write-HelpKeywordTableRow "coding-guidelines" "Coding Guidelines v24 (alias)" "remote"
    Write-HelpKeywordTableRow "starship, ss" "Starship cross-shell prompt" "remote"
    Write-HelpKeywordTableRow "starship-prompt" "Starship (alias)" "remote"
    Write-HelpKeywordTableRow "oh-my-posh, omp, posh" "Oh My Posh prompt theme" "remote"
    Write-HelpKeywordTableRow "ohmyposh" "Oh My Posh (alias)" "remote"
    Write-HelpKeywordTableRow "scoop, sc" "Scoop CLI installer" "remote"
    Write-HelpKeywordTableRow "scoop-installer" "Scoop (alias)" "remote"
    Write-Host ""
}

function Show-HelpKeywordsCombos {
    Write-Host "  Combo Shortcuts:" -ForegroundColor $ThemeAccent
    Write-Host ""
    Write-HelpKeywordTableRow "vscode+settings, vscode+s" "VSCode + Settings Sync" "01, 11"
    Write-HelpKeywordTableRow "vscode+menu+settings, vms" "VSCode + Menu Fix + Sync" "01, 10, 11"
    Write-HelpKeywordTableRow "git+desktop, git+gh" "Git + GitHub Desktop" "07, 08"
    Write-HelpKeywordTableRow "node+pnpm" "Node.js + pnpm" "03, 04"
    Write-HelpKeywordTableRow "frontend" "VSCode + Node + pnpm + Sync" "01, 03, 04, 11"
    Write-HelpKeywordTableRow "backend" "Python + Go + PHP + PG + .NET + Java" "05, 06, 16, 20, 39, 40"
    Write-HelpKeywordTableRow "web-dev, webdev" "VSCode + Node + pnpm + Git + Sync" "01, 03, 04, 07, 11"
    Write-HelpKeywordTableRow "essentials" "VSCode + Choco + Node + Git + Sync" "01, 02, 03, 07, 11"
    Write-Host ""

    Write-Host "    Python & Libraries" -ForegroundColor $ThemePrimary
    Write-HelpKeywordTableRow "pylibs" "Python + all libraries" "05, 41"
    Write-HelpKeywordTableRow "python+libs, ml-dev" "Python + all libraries" "05, 41"
    Write-HelpKeywordTableRow "python+jupyter" "Python + all libraries" "05, 41"
    Write-HelpKeywordTableRow "pip+jupyter+libs" "Python + all libraries" "05, 41"
    Write-HelpKeywordTableRow "jupyter+libs" "Jupyter group only" "41"
    Write-HelpKeywordTableRow "data-science, datascience" "Python + data/viz libs" "05, 41"
    Write-HelpKeywordTableRow "ai-dev, aidev" "Python + ML libs" "05, 41"
    Write-HelpKeywordTableRow "deep-learning, ml-full" "Python + ML libs" "05, 41"
    Write-Host ""

    Write-Host "    General" -ForegroundColor $ThemePrimary
    Write-HelpKeywordTableRow "full-stack, fullstack" "Everything for full-stack dev" "01-09, 11, 16, 39, 40"
    Write-HelpKeywordTableRow "mobile-dev" "Flutter mobile dev" "38"
    Write-HelpKeywordTableRow "data-dev" "Postgres + Redis + DuckDB + DBeaver" "20, 24, 28, 32"
    Write-Host ""

    Write-Host "  Usage: " -NoNewline -ForegroundColor $ThemeAccent
    Write-Host ".\run.ps1 install <keyword>[,<keyword>,...]"
    Write-Host ""
}
