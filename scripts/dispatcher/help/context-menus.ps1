# Settings and right-click context menus help

function Show-HelpEditorAndShellMenus {
    Write-Host "    Settings & Context Menus:" -ForegroundColor $ThemePrimary
    Write-Host "      Each keyword auto-installs its prerequisite app first, then applies settings," -ForegroundColor $ThemeMuted
    Write-Host "      and finally registers the right-click menu (where applicable)." -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      VS Code:" -ForegroundColor DarkYellow

    Write-HelpKeywordLine "install vscode+settings" "VS Code + sync settings/keybindings/extensions [01,11]"
    Write-HelpKeywordLine "install vscode+s" "Same as vscode+settings (short alias) [01,11]"
    Write-HelpKeywordLine "install vscode-settings" "Same as vscode+settings (legacy alias of settings-sync) [01,11]"
    Write-HelpKeywordLine "install vscode+menu+settings (= vms)" "VS Code + settings + right-click menu [01,11,10]"
    Write-HelpKeywordLine "install vscode+menu" "VS Code right-click menu (auto-installs VS Code + settings) [01,11,10]"
    Write-HelpKeywordLine "install vscode+context, vscode-context-menu" "Same as vscode+menu (aliases) [01,11,10]"
    Write-HelpKeywordLine "install vscode-fix-menu" "Repair-only: fix VS Code folder right-click registry (no reinstall) [52]"
    Write-HelpKeywordLine "install fix-vscode-menu" "Same as vscode-fix-menu (alias) [52]"
    Write-HelpKeywordLine "install vscode+fix" "VS Code + settings + folder right-click repair [01,11,52]"
    Write-HelpKeywordLine "install vscode+menu+fix" "VS Code + settings + install menu + repair menu [01,11,10,52]"

    Write-Host ""
    Write-Host "      PowerShell:" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install pwsh-menu" "PowerShell submenu with 'Open Here' + 'Open as Admin' (auto-installs PowerShell) [17,31]"
    Write-HelpKeywordLine "install pwsh-context-menu" "Same as pwsh-menu (alias) [17,31]"
    Write-HelpKeywordLine "install ps-context-menu" "Same as pwsh-menu (alias) [17,31]"
    Write-HelpKeywordLine "install powershell-menu" "Same as pwsh-menu (alias) [17,31]"

    Write-Host ""
    Write-Host "      ConEmu:" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install conemu" "ConEmu + settings auto-applied (ConEmu.xml) [48 install+settings]"
    Write-HelpKeywordLine "install conemu+settings" "Same as conemu (explicit) [48 install+settings]"
    Write-HelpKeywordLine "install conemu-settings" "Apply ConEmu.xml only (skip install) [48 settings-only]"
    Write-HelpKeywordLine "install install-conemu" "Install ConEmu only (skip settings) [48 install-only]"
    Write-HelpKeywordLine "install conemu-menu" "ConEmu submenu with 'Open Here' + 'Open as Admin' for folder/background right-click [48,59]"
    Write-HelpKeywordLine "install conemu+menu" "Same as conemu-menu (alias) [48,59]"
    Write-HelpKeywordLine "install conemu-context-menu" "Same as conemu-menu (alias) [48,59]"
    Write-Host ""
}

function Show-HelpTerminalAndBundleMenus {
    Write-Host "      Windows Terminal context menu:" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install wt-menu" "Windows Terminal submenu with 'Open Here' + 'Open as Admin' for folder/background right-click [37,64]"
    Write-HelpKeywordLine "install wt-context-menu" "Same as wt-menu (alias) [37,64]"
    Write-HelpKeywordLine "install terminal-menu" "Same as wt-menu (alias) [37,64]"

    Write-Host ""
    Write-Host "      All right-click context menus (PowerShell + ConEmu + Windows Terminal):" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install context-menu" "Run script 57 bundle: prompt per menu (or pass -y / --yes for all) [57]"
    Write-HelpKeywordLine "install context" "Search alias for the bundle [57]"
    Write-HelpKeywordLine "install menu" "Search alias for the bundle [57]"
    Write-HelpKeywordLine "install right-click" "Search alias for the bundle [57]"

    Write-Host ""
    Write-Host "      Scripts Fixer cascading right-click menu (script 53):" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install os-context-menu" "Install full 'Scripts Fixer v{ver}' cascading right-click menu (file/folder/bg/desktop) [53]"
    Write-HelpKeywordLine "install context-menu-all" "Same as os-context-menu (alias) [53]"
    Write-HelpKeywordLine "install all-context-menu" "Same as os-context-menu (alias) [53]"
    Write-HelpKeywordLine "install os-install-context-menu" "Same as os-context-menu (alias) [53]"
    Write-HelpKeywordLine "install scripts-fixer-menu" "Same as os-context-menu (alias) [53]"
    Write-HelpKeywordLine "install sf-menu" "Same as os-context-menu (short alias) [53]"

    Write-Host ""
    Write-Host "      Other apps with bundled settings:" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install npp+settings" "Notepad++ + settings [33 install+settings]"
    Write-HelpKeywordLine "install obs+settings" "OBS Studio + settings [36 install+settings]"
    Write-HelpKeywordLine "install wt+settings" "Windows Terminal + settings [37 install+settings]"
    Write-HelpKeywordLine "install dbeaver+settings" "DBeaver + settings [32 install+settings]"

    Write-Host ""
    Write-Host "      All settings at once:" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install all-settings" "Install + apply ALL bundled settings: VS Code, NPP, OBS, WT, DBeaver, ConEmu (+ ConEmu right-click) [01,11,32,33,36,37,48,59]"
    Write-HelpKeywordLine "install settings" "Same as all-settings (alias)"
    Write-HelpKeywordLine "install all-settings --exclude obs,wt" "Apply all settings EXCEPT the listed apps"
    Write-HelpKeywordLine "install all-settings --exclude=conemu" "Inline form (=) also accepted; valid tokens: vscode,npp,obs,wt,dbeaver,conemu"
    Write-HelpKeywordLine "install all-settings --exclude obs,xyz --exclude-strict" "Abort (exit 2) if any --exclude token is unknown instead of warning"
    Write-Host ""
}

function Show-HelpContextMenus {
    Show-HelpEditorAndShellMenus
    Show-HelpTerminalAndBundleMenus
}
