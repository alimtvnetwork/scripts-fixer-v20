# Available scripts registry table with version badges

function Write-HelpScriptRow {
    param([hashtable]$VersionMap, [string]$Id, [string]$Name, [string]$Description)

    $nc = 30
    $ver = if ($VersionMap.ContainsKey($Id)) { $VersionMap[$Id] } else { $null }
    $hasVer = -not [string]::IsNullOrWhiteSpace($ver)

    Write-Host "    $Id  $($Name.PadRight($nc)) " -NoNewline
    Write-Host $Description -ForegroundColor $ThemeMuted -NoNewline

    if ($hasVer) {
        Write-Host "  [" -NoNewline -ForegroundColor $ThemeMuted
        Write-Host "v$ver" -NoNewline -ForegroundColor Green
        Write-Host "]" -NoNewline -ForegroundColor $ThemeMuted
    }

    Write-Host ""
}

function Show-HelpScriptsTable {
    Write-Host "  Available Scripts:" -ForegroundColor $ThemeAccent
    Write-Host ""

    $vMap = if (Get-Command Get-VersionMap -ErrorAction SilentlyContinue) { Get-VersionMap } else { @{} }
    $nc = 30

    Write-Host "    ID  $("Name".PadRight($nc))  Description" -ForegroundColor $ThemeMuted
    Write-Host "    --  $(''.PadRight($nc, '-'))  $(''.PadRight(50, '-'))" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Core Tools" -ForegroundColor $ThemePrimary
    Write-HelpScriptRow $vMap "01" "vscode"          "Install Visual Studio Code (Stable/Insiders)"
    Write-HelpScriptRow $vMap "02" "choco"           "Install Chocolatey package manager"
    Write-HelpScriptRow $vMap "03" "nodejs"          "Install Node.js LTS, Yarn, Bun, verify npx"
    Write-HelpScriptRow $vMap "04" "pnpm"            "Install pnpm, configure global store"
    Write-HelpScriptRow $vMap "05" "python"          "Install Python, configure pip user site"
    Write-HelpScriptRow $vMap "41" "pylibs"          "Install pip packages: ML, viz, web, jupyter (by group)"
    Write-HelpScriptRow $vMap "06" "golang"          "Install Go, configure GOPATH and go env"
    Write-HelpScriptRow $vMap "07" "git"             "Install Git, Git LFS, GitHub CLI, configure settings"
    Write-HelpScriptRow $vMap "08" "github-desktop"  "Install GitHub Desktop via Chocolatey"
    Write-HelpScriptRow $vMap "09" "cpp"             "Install MinGW-w64 C++ compiler, verify g++/gcc/make"
    Write-HelpScriptRow $vMap "16" "php"             "Install PHP via Chocolatey"
    Write-HelpScriptRow $vMap "17" "pwsh"            "Install latest PowerShell via Winget/Chocolatey"
    Write-HelpScriptRow $vMap "38" "flutter"         "Install Flutter SDK, Dart, Android toolchain"
    Write-HelpScriptRow $vMap "39" "dotnet"          "Install .NET SDK (6/8/9), configure dotnet CLI"
    Write-HelpScriptRow $vMap "40" "java"            "Install OpenJDK via Chocolatey (17/21)"
    Write-Host ""

    Write-Host "    Optional" -ForegroundColor $ThemePrimary
    Write-HelpScriptRow $vMap "10" "vscode-menu"     "Add/repair VSCode right-click context menu entries"
    Write-HelpScriptRow $vMap "11" "vscode-sync"     "Sync VSCode settings, keybindings, and extensions"
    Write-HelpScriptRow $vMap "31" "pwsh-menu"       "Add PowerShell submenu to right-click menu (Open Here + Open as Admin)"
    Write-Host ""

    Write-Host "    Orchestrator" -ForegroundColor $ThemePrimary
    Write-HelpScriptRow $vMap "12" "all"             "Interactive grouped menu: pick tools or install everything"
    Write-HelpScriptRow $vMap "30" "databases"       "Interactive database installer (SQL, NoSQL, file-based)"
    Write-Host ""

    Write-Host "    Utilities" -ForegroundColor $ThemePrimary
    Write-HelpScriptRow $vMap "13" "audit"           "Scan configs, specs, suggestions for stale IDs"
    Write-HelpScriptRow $vMap "14" "winget"          "Install/verify Winget package manager (standalone)"
    Write-HelpScriptRow $vMap "15" "win-tweaks"      "Chris Titus Windows Utility (tweaks and debloating)"
    Write-Host ""

    Write-Host "    Desktop Tools" -ForegroundColor $ThemePrimary
    Write-HelpScriptRow $vMap "32" "dbeaver"         "Universal database visualization and management tool"
    Write-HelpScriptRow $vMap "33" "npp"             "Install NPP, NPP Settings, or NPP + Settings"
    Write-HelpScriptRow $vMap "34" "sticky-notes"    "Install Simple Sticky Notes via Chocolatey"
    Write-HelpScriptRow $vMap "35" "gitmap"          "Git repository navigator CLI tool"
    Write-HelpScriptRow $vMap "36" "obs"             "Install OBS, OBS Settings, or OBS + Settings"
    Write-HelpScriptRow $vMap "37" "wt"              "Install WT, WT Settings, or WT + Settings"
    Write-Host ""
}
