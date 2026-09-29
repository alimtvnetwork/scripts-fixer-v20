# Exclude token reference and flag spelling help

function Write-HelpExcludeTokenRow {
    param([string]$Token, [string]$Ids, [string]$Aliases)

    Write-Host "      $($Token.PadRight(20))" -NoNewline
    Write-Host "$($Ids.PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary
    Write-Host $Aliases -ForegroundColor $ThemeMuted
}

function Show-HelpExcludeTokens {
    Write-Host "      --exclude token reference:" -ForegroundColor DarkYellow
    Write-Host "      Each token is looked up in the same keyword map as install <keyword>." -ForegroundColor $ThemeMuted
    Write-Host "      Whatever script IDs the token resolves to are subtracted from the bundle." -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      $("Token".PadRight(20))" -NoNewline -ForegroundColor White
    Write-Host "$("Removes IDs".PadRight(18))" -NoNewline -ForegroundColor White
    Write-Host "Aliases" -ForegroundColor White

    Write-HelpExcludeTokenRow "vscode" "[01, 11]" "vs-code, code, vscode+settings, vscode+s, vscode-settings (legacy: settings-sync)"
    Write-HelpExcludeTokenRow "vscode-fix-menu" "[52]" "fix-vscode-menu, vscode-menu-fix, vscode-menu-repair, fix-vscode-context-menu (folder right-click repair only)"
    Write-HelpExcludeTokenRow "npp" "[33]" "notepad++, notepadpp, notepad-plus, npp+settings, npp-settings"
    Write-HelpExcludeTokenRow "obs" "[36]" "obs-studio, obs+settings, obs-settings, install-obs"
    Write-HelpExcludeTokenRow "wt" "[37]" "windows-terminal, wt+settings, wt-settings, install-wt"
    Write-HelpExcludeTokenRow "dbeaver" "[32]" "db-viewer, dbviewer, dbeaver+settings, dbeaver-settings"
    Write-HelpExcludeTokenRow "conemu" "[48, 59]" "conemu+settings, conemu-settings, install-conemu, conemu-menu, conemu+menu, conemu-context-menu"
    Write-HelpExcludeTokenRow "conemu-menu" "[59]" "conemu+menu, conemu-context-menu (right-click only; keeps script 48 install)"

    Write-Host ""
    Write-Host "      Flag spellings (all equivalent):" -ForegroundColor $ThemeMuted
    Write-Host "        --exclude  -exclude  --ex  -ex  --without  -without  --skip  -skip" -ForegroundColor $ThemeMuted
    Write-Host "      Value formats: '--exclude obs,wt'  '--exclude obs wt'  '--exclude=obs,wt'" -ForegroundColor $ThemeMuted
    Write-Host "      Strict mode flags: --exclude-strict, --strict-exclude, --excludestrict" -ForegroundColor $ThemeMuted
    Write-Host ""
}
