# Chrome and extensions detailed cookbook help

function Show-HelpChromeBrowserAndAi {
    Write-Host "    Chrome & Extensions (script 58) -- detailed examples:" -ForegroundColor $ThemePrimary
    Write-Host "      Browser:" -ForegroundColor DarkYellow

    Write-HelpServiceLine ".\run.ps1 install chrome" "# Chrome only (choco -> official installer fallback)"
    Write-HelpServiceLine ".\run.ps1 install chrome with-ext" "# Chrome + all configured Web Store extensions"
    Write-HelpServiceLine ".\run.ps1 uninstall chrome" "# Remove Chrome + clean shortcuts / registry / AppData"

    Write-Host "      AI / Gemini Nano disable (reclaim 2-4 GB):" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 chrome fix-ai" "# Disable Chrome's built-in AI + delete on-device model cache"
    Write-HelpServiceLine ".\run.ps1 chrome fix-ai --dry-run" "# Preview policy + flag + cache changes without writing"
    Write-HelpServiceLine ".\run.ps1 chrome fix-ai --verify" "# Report current policy/flag/cache state only"
    Write-HelpServiceLine ".\run.ps1 chrome fix-ai --restore" "# Revert policies + restore Local State backup"
}

function Show-HelpChromeCatalogAndAdHoc {
    Write-Host "      Extensions from the bundled catalog:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 install chrome ext" "# List the catalog (name -> Web Store ID)"
    Write-HelpServiceLine ".\run.ps1 install chrome ext vpn" "# Install ONE extension by name"
    Write-HelpServiceLine ".\run.ps1 install chrome ext vpn,tabcopy,adblocker" "# Install MANY by comma-separated names (no spaces)"
    Write-HelpServiceLine ".\run.ps1 install chrome ext vpn tabcopy adblocker" "# Same thing, space-separated also works"
    Write-HelpServiceLine ".\run.ps1 install chrome ext-all" "# Install every extension in config.json (alias: extall, all-ext)"

    Write-Host "      Ad-hoc extensions from raw Web Store URLs / IDs:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 install chrome ext-url https://chromewebstore.google.com/detail/<slug>/<id>" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url <id1> <id2> <id3>".PadRight(70) -NoNewline; Write-Host "# Multiple raw 32-char IDs / URLs" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url url1,url2,url3".PadRight(70) -NoNewline; Write-Host "# Comma-separated list (quoted URLs with commas are handled)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url .\my-extensions.csv".PadRight(70) -NoNewline; Write-Host "# .csv file -- one URL/ID per row, quoted fields OK" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url list.txt https://...".PadRight(70) -NoNewline; Write-Host "# Mix file(s) and inline URLs in one call" -ForegroundColor $ThemeMuted
}

function Show-HelpChromeCookbook {
    Write-Host "      Copy-paste cookbook (real, runnable):" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 install chrome with-ext".PadRight(78) -NoNewline; Write-Host "# Fresh machine -> Chrome + every catalog extension" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext vpn,tabcopy,adblocker".PadRight(78) -NoNewline; Write-Host "# 3 extensions by name" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url ddkjiahejlhfcafbddmgiahcphecmpfh".PadRight(78) -NoNewline; Write-Host "# 1 extension by raw 32-char ID" -ForegroundColor $ThemeMuted
    Write-Host '        .\run.ps1 install chrome ext-url "https://chromewebstore.google.com/detail/<slug>/<id>"' -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url .\extensions.csv -Yes".PadRight(78) -NoNewline; Write-Host "# Bulk + skip warning prompt (CI)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url .\extensions.txt https://...".PadRight(78) -NoNewline; Write-Host "# Mix file + inline URL" -ForegroundColor $ThemeMuted

    Write-Host "      Discover / search inline:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 help chrome".PadRight(78) -NoNewline; Write-Host "# All Chrome lines (browser + extensions)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 help chrome ext".PadRight(78) -NoNewline; Write-Host "# AND filter -> only extension lines" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 help ext-url".PadRight(78) -NoNewline; Write-Host "# Only ad-hoc URL / ID / file examples" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 help chrome --out chrome-help.txt".PadRight(78) -NoNewline; Write-Host "# Export matched lines to a file" -ForegroundColor $ThemeMuted
    Write-Host "      Tip: extensions land under the Chrome ExtensionInstallForcelist policy registry key" -ForegroundColor $ThemeMuted
    Write-Host "           (HKLM\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist) and apply on next launch." -ForegroundColor $ThemeMuted

    Write-Host ""
}

function Show-HelpChrome {
    Show-HelpChromeBrowserAndAi
    Show-HelpChromeCatalogAndAdHoc
    Show-HelpChromeCookbook
}
