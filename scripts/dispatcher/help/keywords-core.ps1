# Core keyword installs cheatsheet

function Write-HelpKeywordLine {
    param([string]$Keyword, [string]$Description)

    $kc = 44
    Write-Host "    $($Keyword.PadRight($kc))" -NoNewline
    Write-Host $Description -ForegroundColor $ThemeMuted
}

function Show-HelpKeywordsCore {
    Write-Host "  Install by Keyword:" -ForegroundColor $ThemeAccent
    Write-Host ""

    Write-HelpKeywordLine "install vscode" "Install Visual Studio Code"
    Write-HelpKeywordLine "install nodejs" "Install Node.js + Yarn + Bun"
    Write-HelpKeywordLine "install pnpm" "Install Node.js + pnpm (auto-chains)"
    Write-HelpKeywordLine "install python" "Install Python + pip"
    Write-HelpKeywordLine "install pylibs" "Install Python + pip + all libraries (numpy, pandas, jupyter...)"
    Write-HelpKeywordLine "install go" "Install Go + configure GOPATH"
    Write-HelpKeywordLine "install git" "Install Git + LFS + GitHub CLI"
    Write-HelpKeywordLine "install cpp" "Install C++ MinGW-w64 compiler"
    Write-HelpKeywordLine "install php" "Install PHP via Chocolatey"
    Write-HelpKeywordLine "install powershell" "Install latest PowerShell"
    Write-HelpKeywordLine "install winget" "Install Winget package manager"
    Write-HelpKeywordLine "install flutter" "Install Flutter SDK + Dart"
    Write-HelpKeywordLine "install dotnet" "Install .NET SDK (latest)"
    Write-HelpKeywordLine "install java" "Install OpenJDK (latest LTS)"
    Write-HelpKeywordLine "install settingssync" "Sync VSCode settings + extensions (auto-installs VS Code)"
    Write-HelpKeywordLine "install contextmenu" "Fix VSCode right-click menu (auto-installs VS Code + settings)"
    Write-HelpKeywordLine "install chrome" "Install Google Chrome (choco googlechrome + official installer fallback) [58]"
    Write-HelpKeywordLine "install chrome with-ext" "Chrome + every configured Web Store extension in one shot [58]"
    Write-HelpKeywordLine "install chrome ext" "Show extension catalog; 'ext vpn,tabcopy' installs by name [58]"
    Write-HelpKeywordLine "install chrome ext-all" "Install ALL configured extensions (vpn, tabcopy, tabextend, adblocker, ...) [58]"
    Write-HelpKeywordLine "install chrome ext-url <urls|file>" "Install ad-hoc extensions from raw Web Store URLs / IDs / .csv / .txt [58]"
    Write-HelpKeywordLine "uninstall chrome" "Uninstall Chrome + clean shortcuts/registry/AppData (warns on HKLM if not elevated) [58]"
    Write-HelpKeywordLine "chrome fix-ai" "Disable built-in AI (Gemini Nano) + reclaim 2-4 GB; --dry-run / --verify / --restore [58]"
    Write-HelpKeywordLine "install protonvpn" "Install Proton VPN (aliases: proton, proton-vpn, vpn) [60]"
    Write-HelpKeywordLine "uninstall protonvpn" "Uninstall Proton VPN + clean .installed/protonvpn.json record [60]"
    Write-HelpKeywordLine "install jumpjump-vpn" "Install JumpJump VPN via direct download (aliases: jumpjump, jumpjumpvpn, jjvpn) [61]"
    Write-HelpKeywordLine "uninstall jumpjump-vpn" "Uninstall JumpJump VPN + clean .installed/jumpjump-vpn.json record [61]"
    Write-HelpKeywordLine "install antigravity-manager" "Install Antigravity Manager [68]"
    Write-HelpKeywordLine "uninstall antigravity-manager" "Uninstall Antigravity Manager [68]"
    Write-HelpKeywordLine "install antigravity" "Install Antigravity (agy) [69]"
    Write-HelpKeywordLine "install codex" "Install Codex UI [78]"
    Write-HelpKeywordLine "install plotcode" "Install PlotCode UI [79]"
    Write-HelpKeywordLine "install claude-code" "Install Claude Code (UI & CLI) [80]"
    Write-HelpKeywordLine "install qtorrent" "Install qBittorrent [76]"
    Write-HelpKeywordLine "install utorrent" "Install uTorrent [77]"

    Write-Host ""
}
