# Database installs, keyword combinations, and remote installers help

function Show-HelpDatabasesAndCombos {
    Write-Host "    Database installs:" -ForegroundColor $ThemePrimary
    Write-HelpKeywordLine "install databases" "Open the interactive database installer menu"
    Write-HelpKeywordLine "install mysql" "Install MySQL database"
    Write-HelpKeywordLine "install postgresql" "Install PostgreSQL database"
    Write-HelpKeywordLine "install sqlite" "Install SQLite + DB Browser for SQLite"
    Write-HelpKeywordLine "install mongodb,redis" "Install MongoDB + Redis"
    Write-HelpKeywordLine "install alldev" "Interactive dev tools menu (pick what to install)"
    Write-Host ""

    Write-Host "    Combine keywords:" -ForegroundColor $ThemePrimary
    Write-HelpKeywordLine "install nodejs,pnpm" "Install Node.js + pnpm"
    Write-HelpKeywordLine "install go,git,cpp" "Install Go, Git, and C++"
    Write-HelpKeywordLine "install python,php" "Install Python + PHP"
    Write-HelpKeywordLine "install vscode,nodejs,git" "Install VS Code, Node.js, and Git"
    Write-HelpKeywordLine "install alldev,mysql" "Run the alldev menu, then install MySQL"
    Write-Host ""
}

function Show-HelpRemoteInstallers {
    Write-Host "    Remote installers (irm <url> | iex):" -ForegroundColor $ThemePrimary
    Write-Host "      All aliases on each row are EQUIVALENT -- pick whichever you remember." -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-HelpKeywordLine "install clean-code" "Coding Guidelines v24 -- alimtvnetwork/coding-guidelines-v24"
    Write-HelpKeywordLine "install code-guide  (= cg, cc)" "Same as 'install clean-code' (4 aliases total)"
    Write-HelpKeywordLine "install coding-guidelines" "Same as 'install clean-code' (long alias)"
    Write-HelpKeywordLine "install starship    (= ss)" "Starship cross-shell prompt -- local wrapper (winget/scoop/cargo)"
    Write-HelpKeywordLine "install oh-my-posh  (= omp, posh)" "Oh My Posh prompt -- ohmyposh.dev/install.ps1"
    Write-HelpKeywordLine "install scoop       (= sc)" "Scoop CLI installer -- get.scoop.sh"

    Write-Host ""
    Write-Host "    Combine remote + local: install vscode,cg  (VS Code first, then clean-code)" -ForegroundColor $ThemeMuted
    Write-Host ""
}

function Show-HelpDatabasesAndRemotes {
    Show-HelpDatabasesAndCombos
    Show-HelpRemoteInstallers
}
