<#
.SYNOPSIS
    Root help displays and keyword tables for root dispatcher.
#>

function Show-RootHelpRaw {
    Show-VersionHeader
    Write-Host ""
    Write-Host "  Dev Tools Setup Scripts" -ForegroundColor $ThemeSecondary
    Write-Host "  =======================" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "  Usage:" -ForegroundColor $ThemeAccent
    Write-Host ""
    $col = 44
    Write-Host "    $(".\run.ps1 install <keywords>".PadRight($col))" -NoNewline; Write-Host "Install by keyword (bare command)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -Install <keywords>".PadRight($col))" -NoNewline; Write-Host "Install by keyword (named parameter)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 update".PadRight($col))" -NoNewline; Write-Host "Show outdated, confirm, upgrade all" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 update nodejs,git".PadRight($col))" -NoNewline; Write-Host "Upgrade specific packages only" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 update --check".PadRight($col))" -NoNewline; Write-Host "List outdated packages (no upgrade)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 update -y".PadRight($col))" -NoNewline; Write-Host "Upgrade all, skip confirmation" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 update --exclude=pkg1,pkg2".PadRight($col))" -NoNewline; Write-Host "Upgrade all except listed" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 self-update".PadRight($col))" -NoNewline; Write-Host "Refresh local scripts-fixer copy (git pull)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 self-update --check".PadRight($col))" -NoNewline; Write-Host "Show if local copy is behind upstream (no pull)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 self-update --reinstall".PadRight($col))" -NoNewline; Write-Host "Pull, then re-run install.ps1 (refresh shims/PATH)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 export".PadRight($col))" -NoNewline; Write-Host "Export all app settings to repo" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 export npp,obs".PadRight($col))" -NoNewline; Write-Host "Export specific app settings" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 export-config <app>".PadRight($col))" -NoNewline; Write-Host "Export app config (qtorrent, utorrent, vscode)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 import-config <app>".PadRight($col))" -NoNewline; Write-Host "Import app config (qtorrent, utorrent, vscode)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 status".PadRight($col))" -NoNewline; Write-Host "Show dashboard of all installed tools" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 status --no-choco".PadRight($col))" -NoNewline; Write-Host "Status without outdated package check" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 report [--since=24h] [--open]".PadRight($col))" -NoNewline; Write-Host "Timestamped JSON+HTML report of install/uninstall actions" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 doctor".PadRight($col))" -NoNewline; Write-Host "Quick health check of project setup" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 doctor --self-check".PadRight($col))" -NoNewline; Write-Host "Deep audit: changelog files, version, clean catalog, keyword resolution, SHA256 pins" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 doctor --self-check --skip-network".PadRight($col))" -NoNewline; Write-Host "Same as above but skips sections (d) + (e) for offline use" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 models".PadRight($col))" -NoNewline; Write-Host "Pick AI model backend (llama.cpp / Ollama), browse + install" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 models <ids>".PadRight($col))" -NoNewline; Write-Host "Direct install: CSV of model ids (auto-routes per backend)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 models list".PadRight($col))" -NoNewline; Write-Host "List all models from both catalogs" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 models-download <n|id>".PadRight($col))" -NoNewline; Write-Host "Top-level shortcut for 'models download ...'" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 install model <ids>".PadRight($col))" -NoNewline; Write-Host "Same shortcut: 'install model 93' or 'install model 93,94' (standalone GGUF)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -M".PadRight($col))" -NoNewline; Write-Host "Shortcut for 'models'" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 download <url> [<dir>]".PadRight($col))" -NoNewline; Write-Host "Fast download (aria2c, defaults -s 16 -p 1M); 'url' is alias" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 download <url> -s 12 -p 2M".PadRight($col))" -NoNewline; Write-Host "Override splits (per-server connections) and piece size" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 os <action>".PadRight($col))" -NoNewline; Write-Host "OS housekeeping: clean, temp-clean, hib-off, flp, add-user ('os -h' for full list)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 os power [flags]".PadRight($col))" -NoNewline; Write-Host "Set display/sleep/disk/hibernate timeouts (--display N --sleep N --disk N --hibernate N | --never | --ac-only | --dc-only | --dry-run)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 os hib-off | hib-on".PadRight($col))" -NoNewline; Write-Host "Disable / enable Windows hibernation" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 os browser <name>".PadRight($col))" -NoNewline; Write-Host "Set default web browser (chrome | firefox | edge | brave | opera | vivaldi | librewolf)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 os email <name>".PadRight($col))" -NoNewline; Write-Host "Set default mail client (outlook | thunderbird | mailbird | em-client | windows-mail)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 os clean | temp-clean".PadRight($col))" -NoNewline; Write-Host "Disk cleanup (categories, buckets, consent system) or just temp dirs" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 os dev-cleanup [-y]".PadRight($col))" -NoNewline; Write-Host "Clean dev tools caches (Go, pnpm, npm, choco, yarn, bun, pip, cargo, nuget)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 clean-dev [-y]".PadRight($col))" -NoNewline; Write-Host "Top-level shortcut for 'os dev-cleanup' (supports --dry-run, --yes)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 agy <action>".PadRight($col))" -NoNewline; Write-Host "Antigravity maintenance: clear | clean | predict | undo | list-backups ('agy help')" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 agy clear --keep 10".PadRight($col))" -NoNewline; Write-Host "Prune conversations keeping latest 10 intact (safe predict mode by default)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 agy clear --keep 10 -y".PadRight($col))" -NoNewline; Write-Host "Apply conversation prune & cache scrub (keeps latest 10 intact)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 agy undo latest".PadRight($col))" -NoNewline; Write-Host "Rollback the most recent conversation pruning transaction" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 clean-agy 10".PadRight($col))" -NoNewline; Write-Host "Top-level shortcut for 'agy clear --keep 10' (supports -y, --dry-run)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 os add-user | edit-user | remove-user".PadRight($col))" -NoNewline; Write-Host "Local Windows user management (add/edit/remove, JSON-bulk variants too)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 ssh <verb>".PadRight($col))" -NoNewline; Write-Host "SSH keys: gen | view | read | cat | search | install | revoke | ledger ('ssh help')" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 ssh view".PadRight($col))" -NoNewline; Write-Host "Pretty-print ~/.ssh (public keys + masked private + ledger summary)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 ssh search <p>".PadRight($col))" -NoNewline; Write-Host "Substring/regex search across ~/.ssh files AND the cross-OS ledger" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 menu <verb> [target]".PadRight($col))" -NoNewline; Write-Host "Context-menu manager: install|uninstall|list|help; targets all|pwsh|wt|conemu|vscode|sf" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 menu install all -y".PadRight($col))" -NoNewline; Write-Host "Install every right-click menu (PowerShell, Windows Terminal, ConEmu, VS Code, SF)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 menu install pwsh|wt|conemu".PadRight($col))" -NoNewline; Write-Host "Install one menu only (PowerShell / Windows Terminal / ConEmu submenu)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 menu uninstall conemu".PadRight($col))" -NoNewline; Write-Host "Snapshot to .reg + remove a target's right-click entries" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 vscode-folder <action>".PadRight($col))" -NoNewline; Write-Host "VS Code folder-only context-menu repair ('vscode-folder help')" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 vscode-context-menu install".PadRight($col))" -NoNewline; Write-Host "Legacy alias for 'menu install vscode' (kept for back-compat)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 profile <name>".PadRight($col))" -NoNewline; Write-Host "Run a profile recipe (see 'Profiles' section below for list)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 profile tree <name>".PadRight($col))" -NoNewline; Write-Host "View the full installation tree of a profile" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 install <profile>".PadRight($col))" -NoNewline; Write-Host "Same as above -- 'install minimal' == 'profile minimal'" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 profile list".PadRight($col))" -NoNewline; Write-Host "Show all available profiles with descriptions" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 gsa".PadRight($col))" -NoNewline; Write-Host "git safe.directory='*' (wildcard, idempotent)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 gsa --scan <path>".PadRight($col))" -NoNewline; Write-Host "Add each .git repo under <path> individually" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 git-tools <action>".PadRight($col))" -NoNewline; Write-Host "Git config helpers ('git-tools help' for actions)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 path <dir>".PadRight($col))" -NoNewline; Write-Host "Set default dev directory" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 path".PadRight($col))" -NoNewline; Write-Host "Show current dev directory" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 path --reset".PadRight($col))" -NoNewline; Write-Host "Clear saved path, use smart detection" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I <number>".PadRight($col))" -NoNewline; Write-Host "Run a specific script by ID" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -d".PadRight($col))" -NoNewline; Write-Host "Shortcut for -I 12 (interactive menu)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -a".PadRight($col))" -NoNewline; Write-Host "Shortcut for -I 13 (audit mode)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -h".PadRight($col))" -NoNewline; Write-Host "Shortcut for -I 13 -Report (health check)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -v".PadRight($col))" -NoNewline; Write-Host "Shortcut for -I 1  (install VS Code)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -w".PadRight($col))" -NoNewline; Write-Host "Shortcut for -I 14 (install Winget)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -t".PadRight($col))" -NoNewline; Write-Host "Shortcut for -I 15 (Windows tweaks)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -Defaults".PadRight($col))" -NoNewline; Write-Host "Use all defaults, prompt to confirm" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -Defaults -Y".PadRight($col))" -NoNewline; Write-Host "Use all defaults, skip confirmation" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I <number> -Merge".PadRight($col))" -NoNewline; Write-Host "Run with merge flag (script 02)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I <number> -Clean".PadRight($col))" -NoNewline; Write-Host "Wipe cache, then run" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -CleanOnly".PadRight($col))" -NoNewline; Write-Host "Wipe all cached data" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -Help".PadRight($col))" -NoNewline; Write-Host "Show this help" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -List".PadRight($col))" -NoNewline; Write-Host "Show keyword table only" -ForegroundColor $ThemeMuted
    Write-Host ""

    # ── Profiles section (dynamic, schema-validated against scripts/profile/*.json) ──
    $profileCfgPath     = Join-Path $RootDir "scripts\profile\config.json"
    $profileAliasesPath = Join-Path $RootDir "scripts\profile\profile-aliases.json"

    # Lazy-load the shared schema validator (graceful degradation if missing)
    $validatorPath = Join-Path $RootDir "scripts\shared\profile-config-validator.ps1"
    $hasValidator  = Test-Path $validatorPath
    if ($hasValidator -and -not (Get-Command Test-ProfileConfig -ErrorAction SilentlyContinue)) {
        try { . $validatorPath } catch { $hasValidator = $false }
    }

    $profileEntries          = @()
    $profileNamesForExamples = @()
    $cfgValidation           = $null
    $aliasValidation         = $null

    if ($hasValidator) {
        $cfgValidation = Test-ProfileConfig -FilePath $profileCfgPath
        foreach ($pname in $cfgValidation.ProfileNames) {
            $pdef   = $null
            try { $pdef = (Get-Content $profileCfgPath -Raw | ConvertFrom-Json).profiles.$pname } catch {}
            $plabel = if ($pdef -and $pdef.label) { [string]$pdef.label } else { "" }
            $pdesc  = if ($pdef -and $pdef.description) { [string]$pdef.description } elseif ($plabel) { $plabel } else { "" }
            $profileEntries += [pscustomobject]@{
                Name        = [string]$pname
                Label       = $plabel
                Description = $pdesc
            }
            $profileNamesForExamples += [string]$pname
        }
    } else {
        # Validator unavailable -- best-effort raw read so --help still works
        if (Test-Path $profileCfgPath) {
            try {
                $profCfgHelp = Get-Content $profileCfgPath -Raw | ConvertFrom-Json
                foreach ($pname in $profCfgHelp.profiles.PSObject.Properties.Name) {
                    $pdef   = $profCfgHelp.profiles.$pname
                    $plabel = if ($pdef.label) { [string]$pdef.label } else { "" }
                    $pdesc  = if ($pdef.description) { [string]$pdef.description } elseif ($plabel) { $plabel } else { "" }
                    $profileEntries += [pscustomobject]@{ Name = [string]$pname; Label = $plabel; Description = $pdesc }
                    $profileNamesForExamples += [string]$pname
                }
            } catch {}
        }
    }

    # Build "target -> aliases[]" map so each profile can list its own aliases.
    $aliasesByTarget = @{}
    if ($hasValidator -and (Get-Command Get-ProfileAliasesByTarget -ErrorAction SilentlyContinue)) {
        $byTgt = Get-ProfileAliasesByTarget -FilePath $profileAliasesPath -KnownProfileNames $profileNamesForExamples
        if ($byTgt) { $aliasesByTarget = $byTgt }
    }

    Write-Host ("  Profiles ({0} available):" -f $profileEntries.Count) -ForegroundColor $ThemeAccent
    Write-Host "  (multi-step install recipes -- run with 'profile <name>' or 'install <name>')" -ForegroundColor $ThemeMuted
    Write-Host ("  source: {0}" -f $profileCfgPath) -ForegroundColor $ThemeMuted
    if ($aliasesByTarget.Count -gt 0) {
        Write-Host ("  aliases: {0} (grouped under their resolved profile)" -f $profileAliasesPath) -ForegroundColor $ThemeMuted
    }
    Write-Host ""

    if ($profileEntries.Count -gt 0) {
        $pc = 16
        foreach ($entry in $profileEntries) {
            $line = $entry.Description
            if ([string]::IsNullOrWhiteSpace($line)) { $line = $entry.Label }
            Write-Host "    $($entry.Name.PadRight($pc))" -NoNewline -ForegroundColor Green
            Write-Host $line -ForegroundColor $ThemeMuted

            # Show this profile's aliases inline, grouped underneath
            if ($aliasesByTarget.ContainsKey($entry.Name)) {
                foreach ($a in $aliasesByTarget[$entry.Name]) {
                    $kindTag = if ($a.Kind -eq "fallback") { "[fallback]" } else { "[exact]   " }
                    Write-Host ("    {0}  {1} " -f (" " * $pc), $kindTag) -NoNewline -ForegroundColor DarkCyan
                    Write-Host ("{0,-14} -> {1}" -f $a.Name, $entry.Name) -NoNewline -ForegroundColor $ThemeSecondary
                    if ($entry.Description) {
                        Write-Host ("  ({0})" -f $entry.Description) -ForegroundColor $ThemeMuted
                    } else {
                        Write-Host ""
                    }
                    if ($a.Kind -eq "fallback" -and $a.Reason) {
                        Write-Host ("    {0}             reason: {1}" -f (" " * $pc), $a.Reason) -ForegroundColor $ThemeMuted
                    }
                }
            }
        }
    } else {
        Write-Host "    (no profiles available -- see issues report below)" -ForegroundColor DarkYellow
        Write-Host "    Try: .\run.ps1 profile list" -ForegroundColor DarkYellow
    }
    Write-Host ""

    # Issues report for the profiles config (errors + warnings, with file paths)
    if ($hasValidator -and $cfgValidation) {
        Format-ProfileConfigIssues -Result $cfgValidation -Title "Profile config issues"
    }

    # Validate aliases (used both for issues report and orphan detection)
    if ($hasValidator) {
        $aliasValidation = Test-ProfileAliasesConfig -FilePath $profileAliasesPath -KnownProfileNames $profileNamesForExamples
    }

    # ── Orphan aliases (target not in profile catalog) ──────────────────
    if ($aliasesByTarget.ContainsKey('__orphans__') -and $aliasesByTarget['__orphans__'].Count -gt 0) {
        $orphans = $aliasesByTarget['__orphans__']
        Write-Host ("  Orphan aliases ({0}) -- target not in profile catalog:" -f $orphans.Count) -ForegroundColor $ThemeAccent
        Write-Host ("  source: {0}" -f $profileAliasesPath) -ForegroundColor $ThemeMuted
        Write-Host ""
        foreach ($a in $orphans) {
            Write-Host ("    [{0}] {1,-14} -> {2}  (UNRESOLVED)" -f $a.Kind, $a.Name, $a.Target) -ForegroundColor DarkYellow
        }
        Write-Host ""
    }

    if ($hasValidator -and $aliasValidation) {
        Format-ProfileConfigIssues -Result $aliasValidation -Title "Profile aliases issues"
    }

    Write-Host "  Profile Examples (copy-paste):" -ForegroundColor $ThemeAccent
    Write-Host "  (both forms are equivalent -- pick whichever you prefer)" -ForegroundColor $ThemeMuted
    Write-Host ""
    if ($profileNamesForExamples.Count -gt 0) {
        $ec = 40
        foreach ($pname in $profileNamesForExamples) {
            Write-Host "    $((".\run.ps1 profile $pname").PadRight($ec))" -NoNewline -ForegroundColor Green
            Write-Host "# run '$pname' profile" -ForegroundColor $ThemeMuted
            Write-Host "    $((".\run.ps1 install $pname").PadRight($ec))" -NoNewline -ForegroundColor Green
            Write-Host "# same, via 'install' shortcut" -ForegroundColor $ThemeMuted
            Write-Host ""
        }
    }
    Write-Host "  Common profile flags:" -ForegroundColor $ThemeAccent
    Write-Host ""
    Write-Host "    .\run.ps1 profile list                  " -NoNewline; Write-Host "# list all profiles with full descriptions" -ForegroundColor $ThemeMuted
    if ($profileNamesForExamples.Count -gt 0) {
        $sample = $profileNamesForExamples[0]
        Write-Host "    .\run.ps1 profile tree $sample".PadRight(44)      -NoNewline; Write-Host "# view full installation tree" -ForegroundColor $ThemeMuted
        Write-Host "    .\run.ps1 profile $sample --dry-run".PadRight(44) -NoNewline; Write-Host "# preview steps, do not execute" -ForegroundColor $ThemeMuted
        Write-Host "    .\run.ps1 profile $sample -y".PadRight(44)        -NoNewline; Write-Host "# skip confirmation prompts" -ForegroundColor $ThemeMuted
        Write-Host "    .\run.ps1 install $sample -y".PadRight(44)        -NoNewline; Write-Host "# install shortcut + auto-confirm" -ForegroundColor $ThemeMuted
    }
    Write-Host ""

    Write-Host "  Install by Keyword:" -ForegroundColor $ThemeAccent
    Write-Host ""
    $kc = 44
    Write-Host "    $("install vscode".PadRight($kc))" -NoNewline; Write-Host "Install Visual Studio Code" -ForegroundColor $ThemeMuted
    Write-Host "    $("install nodejs".PadRight($kc))" -NoNewline; Write-Host "Install Node.js + Yarn + Bun" -ForegroundColor $ThemeMuted
    Write-Host "    $("install pnpm".PadRight($kc))" -NoNewline; Write-Host "Install Node.js + pnpm (auto-chains)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python".PadRight($kc))" -NoNewline; Write-Host "Install Python + pip" -ForegroundColor $ThemeMuted
    Write-Host "    $("install pylibs".PadRight($kc))" -NoNewline; Write-Host "Install Python + pip + all libraries (numpy, pandas, jupyter...)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install go".PadRight($kc))" -NoNewline; Write-Host "Install Go + configure GOPATH" -ForegroundColor $ThemeMuted
    Write-Host "    $("install git".PadRight($kc))" -NoNewline; Write-Host "Install Git + LFS + GitHub CLI" -ForegroundColor $ThemeMuted
    Write-Host "    $("install cpp".PadRight($kc))" -NoNewline; Write-Host "Install C++ MinGW-w64 compiler" -ForegroundColor $ThemeMuted
    Write-Host "    $("install php".PadRight($kc))" -NoNewline; Write-Host "Install PHP via Chocolatey" -ForegroundColor $ThemeMuted
    Write-Host "    $("install powershell".PadRight($kc))" -NoNewline; Write-Host "Install latest PowerShell" -ForegroundColor $ThemeMuted
    Write-Host "    $("install winget".PadRight($kc))" -NoNewline; Write-Host "Install Winget package manager" -ForegroundColor $ThemeMuted
    Write-Host "    $("install flutter".PadRight($kc))" -NoNewline; Write-Host "Install Flutter SDK + Dart" -ForegroundColor $ThemeMuted
    Write-Host "    $("install dotnet".PadRight($kc))" -NoNewline; Write-Host "Install .NET SDK (latest)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install java".PadRight($kc))" -NoNewline; Write-Host "Install OpenJDK (latest LTS)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install settingssync".PadRight($kc))" -NoNewline; Write-Host "Sync VSCode settings + extensions (auto-installs VS Code)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install contextmenu".PadRight($kc))" -NoNewline; Write-Host "Fix VSCode right-click menu (auto-installs VS Code + settings)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install chrome".PadRight($kc))" -NoNewline; Write-Host "Install Google Chrome (choco googlechrome + official installer fallback) [58]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install chrome with-ext".PadRight($kc))" -NoNewline; Write-Host "Chrome + every configured Web Store extension in one shot [58]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install chrome ext".PadRight($kc))" -NoNewline; Write-Host "Show extension catalog; 'ext vpn,tabcopy' installs by name [58]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install chrome ext-all".PadRight($kc))" -NoNewline; Write-Host "Install ALL configured extensions (vpn, tabcopy, tabextend, adblocker, ...) [58]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install chrome ext-url <urls|file>".PadRight($kc))" -NoNewline; Write-Host "Install ad-hoc extensions from raw Web Store URLs / IDs / .csv / .txt [58]" -ForegroundColor $ThemeMuted
    Write-Host "    $("uninstall chrome".PadRight($kc))" -NoNewline; Write-Host "Uninstall Chrome + clean shortcuts/registry/AppData (warns on HKLM if not elevated) [58]" -ForegroundColor $ThemeMuted
    Write-Host "    $("chrome fix-ai".PadRight($kc))" -NoNewline; Write-Host "Disable built-in AI (Gemini Nano) + reclaim 2-4 GB; --dry-run / --verify / --restore [58]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install protonvpn".PadRight($kc))" -NoNewline; Write-Host "Install Proton VPN (aliases: proton, proton-vpn, vpn) [60]" -ForegroundColor $ThemeMuted
    Write-Host "    $("uninstall protonvpn".PadRight($kc))" -NoNewline; Write-Host "Uninstall Proton VPN + clean .installed/protonvpn.json record [60]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install jumpjump-vpn".PadRight($kc))" -NoNewline; Write-Host "Install JumpJump VPN via direct download (aliases: jumpjump, jumpjumpvpn, jjvpn) [61]" -ForegroundColor $ThemeMuted
    Write-Host "    $("uninstall jumpjump-vpn".PadRight($kc))" -NoNewline; Write-Host "Uninstall JumpJump VPN + clean .installed/jumpjump-vpn.json record [61]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install antigravity-manager".PadRight($kc))" -NoNewline; Write-Host "Install Antigravity Manager [68]" -ForegroundColor $ThemeMuted
    Write-Host "    $("uninstall antigravity-manager".PadRight($kc))" -NoNewline; Write-Host "Uninstall Antigravity Manager [68]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install antigravity".PadRight($kc))" -NoNewline; Write-Host "Install Antigravity (agy) [69]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install codex".PadRight($kc))" -NoNewline; Write-Host "Install Codex UI [78]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install plotcode".PadRight($kc))" -NoNewline; Write-Host "Install PlotCode UI [79]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install claude-code".PadRight($kc))" -NoNewline; Write-Host "Install Claude Code (UI & CLI) [80]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install qtorrent".PadRight($kc))" -NoNewline; Write-Host "Install qBittorrent [76]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install utorrent".PadRight($kc))" -NoNewline; Write-Host "Install uTorrent [77]" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "    Nginx Web Server & Domain Manager:" -ForegroundColor $ThemePrimary
    Write-Host "      Management & Virtual Hosts:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 nginx install".PadRight(60) -NoNewline; Write-Host "# Install Nginx Web Server via Chocolatey" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 nginx help".PadRight(60) -NoNewline; Write-Host "# Show domain manager command help" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 nginx add example.com --type php".PadRight(60) -NoNewline; Write-Host "# Register vhost + compile conf + sync INI & SQLite" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 nginx rm example.com".PadRight(60) -NoNewline; Write-Host "# Remove vhost + unlink conf + sync INI & SQLite" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 nginx list".PadRight(60) -NoNewline; Write-Host "# List all registered domains in SQLite ledger" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 nginx ini --sync".PadRight(60) -NoNewline; Write-Host "# Bidirectional sync between SQLite and domains.ini" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 nginx showcase".PadRight(60) -NoNewline; Write-Host "# 5-phase showcase of SQLite and INI synchronization" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "    Startup, Task Scheduling & Macro Automation:" -ForegroundColor $ThemePrimary
    Write-Host "      Startup & Boot Automation:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 startup list".PadRight(60) -NoNewline; Write-Host "# List registered startup actions (Startup.db)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 startup add <path|macro> [--freq on-login]".PadRight(60) -NoNewline; Write-Host "# Register item to run on startup/login" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 startup remove <id>".PadRight(60) -NoNewline; Write-Host "# Unregister startup item" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 startup run <id>".PadRight(60) -NoNewline; Write-Host "# Trigger startup item interactively now" -ForegroundColor $ThemeMuted
    Write-Host "      Crontab & Scheduled Tasks:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 schedule list".PadRight(60) -NoNewline; Write-Host "# List all scheduled jobs (Schedule.db)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 schedule add <type> <target> <timing>".PadRight(60) -NoNewline; Write-Host "# Register job (types: ps, bash, sh, js, macro)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 schedule run <id>".PadRight(60) -NoNewline; Write-Host "# Execute job immediately & record to child DB" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 schedule debug <id>".PadRight(60) -NoNewline; Write-Host "# Inspect execution logs in ~/.scripts-fixer/schedules/<id>.db" -ForegroundColor $ThemeMuted
    Write-Host "      Interactive Macros & Workflows:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 macro list".PadRight(60) -NoNewline; Write-Host "# List registered macros (Macro.db)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 macro add <name> <cmd1> <cmd2>...".PadRight(60) -NoNewline; Write-Host "# Create interactive command sequence" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 macro run <name>".PadRight(60) -NoNewline; Write-Host "# Execute macro interactively with live output" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 macro startup add <name>".PadRight(60) -NoNewline; Write-Host "# Register macro to execute on system startup" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 macro schedule add <name> daily".PadRight(60) -NoNewline; Write-Host "# Schedule macro for periodic execution" -ForegroundColor $ThemeMuted
    Write-Host "      Async Monitoring & Storage Calculation:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 async <cmd> -t 5".PadRight(60) -NoNewline; Write-Host "# Run command/service periodically & monitor output" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 storage list".PadRight(60) -NoNewline; Write-Host "# Show split DB sizes & disk drive space calculation" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 storage partition".PadRight(60) -NoNewline; Write-Host "# Storage partitioning options & swap expansion guides" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 pipeline errors -t".PadRight(60) -NoNewline; Write-Host "# Wait for pipeline ETA and report error status" -ForegroundColor $ThemeMuted
    Write-Host "      Kubernetes Cluster Nodes & Remote Commands (SQLite + SSH RSA):" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 cluster list".PadRight(60) -NoNewline; Write-Host "# List cluster nodes from SQLite" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 cluster add <name> <role> <ip>".PadRight(60) -NoNewline; Write-Host "# Register node in SQLite" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 cluster history".PadRight(60) -NoNewline; Write-Host "# View cluster remote command execution logs" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "    Antigravity & Gemini Brain Maintenance (script 69) -- detailed examples:" -ForegroundColor $ThemePrimary
    Write-Host "      Prediction, Pruning & Cache Scrubbing:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 agy cache clear -k1".PadRight(60) -NoNewline; Write-Host "# Preview mode keeping latest 1 conversation intact" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy clear --keep 10".PadRight(60) -NoNewline; Write-Host "# Predict pruning keeping latest 10 conversations intact" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy cache clear".PadRight(60) -NoNewline; Write-Host "# Alias for 'agy clear' (predict mode)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy cache-clear".PadRight(60) -NoNewline; Write-Host "# Shorthand alias for 'agy clear'" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy clear keep 10".PadRight(60) -NoNewline; Write-Host "# Shorthand syntax without leading dashes" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy clean".PadRight(60) -NoNewline; Write-Host "# Alias for 'agy clear' (runs safe prediction)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy clear --keep 5 --threshold 100".PadRight(60) -NoNewline; Write-Host "# Prune conversations >100KB keeping latest 5" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 clean-agy 10".PadRight(60) -NoNewline; Write-Host "# Direct root shortcut with positional retention count" -ForegroundColor $ThemeMuted
    Write-Host "      Applying Cleanup & Pruning:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 agy clear --keep 10 -y".PadRight(60) -NoNewline; Write-Host "# Apply conversation prune & scrub Electron/GPU caches" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy clear --keep 10 -y --kill".PadRight(60) -NoNewline; Write-Host "# Terminate Antigravity processes prior to applying" -ForegroundColor $ThemeMuted
    Write-Host "      Rollback & Transaction History:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 agy list-backups".PadRight(60) -NoNewline; Write-Host "# View all past pruning transactions & timestamps" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy undo latest".PadRight(60) -NoNewline; Write-Host "# Restore pruned steps from the latest transaction" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 agy undo <transaction-id>".PadRight(60) -NoNewline; Write-Host "# Rollback a specific historical transaction" -ForegroundColor $ThemeMuted
    Write-Host ""
    # ----- Dedicated Chrome & extensions cheatsheet ---------------------------
    # Surfaces every extension install mode (single, comma-list, all, raw URL,
    # file-of-URLs) with copy-paste examples so users do not have to grep the
    # script's source to discover what's possible.
    Write-Host "    Chrome & Extensions (script 58) -- detailed examples:" -ForegroundColor $ThemePrimary
    Write-Host "      Browser:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 install chrome".PadRight(60) -NoNewline; Write-Host "# Chrome only (choco -> official installer fallback)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome with-ext".PadRight(60) -NoNewline; Write-Host "# Chrome + all configured Web Store extensions" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 uninstall chrome".PadRight(60) -NoNewline; Write-Host "# Remove Chrome + clean shortcuts / registry / AppData" -ForegroundColor $ThemeMuted
    Write-Host "      AI / Gemini Nano disable (reclaim 2-4 GB):" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 chrome fix-ai".PadRight(60) -NoNewline; Write-Host "# Disable Chrome's built-in AI + delete on-device model cache" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 chrome fix-ai --dry-run".PadRight(60) -NoNewline; Write-Host "# Preview policy + flag + cache changes without writing" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 chrome fix-ai --verify".PadRight(60) -NoNewline; Write-Host "# Report current policy/flag/cache state only" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 chrome fix-ai --restore".PadRight(60) -NoNewline; Write-Host "# Revert policies + restore Local State backup" -ForegroundColor $ThemeMuted
    Write-Host "      Extensions from the bundled catalog:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 install chrome ext".PadRight(60) -NoNewline; Write-Host "# List the catalog (name -> Web Store ID)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext vpn".PadRight(60) -NoNewline; Write-Host "# Install ONE extension by name" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext vpn,tabcopy,adblocker".PadRight(60) -NoNewline; Write-Host "# Install MANY by comma-separated names (no spaces)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext vpn tabcopy adblocker".PadRight(60) -NoNewline; Write-Host "# Same thing, space-separated also works" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-all".PadRight(60) -NoNewline; Write-Host "# Install every extension in config.json (alias: extall, all-ext)" -ForegroundColor $ThemeMuted
    Write-Host "      Ad-hoc extensions from raw Web Store URLs / IDs:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 install chrome ext-url https://chromewebstore.google.com/detail/<slug>/<id>" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url <id1> <id2> <id3>".PadRight(70) -NoNewline; Write-Host "# Multiple raw 32-char IDs / URLs" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url url1,url2,url3".PadRight(70)        -NoNewline; Write-Host "# Comma-separated list (quoted URLs with commas are handled)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url .\my-extensions.csv".PadRight(70)   -NoNewline; Write-Host "# .csv file -- one URL/ID per row, quoted fields OK" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url list.txt https://...".PadRight(70)  -NoNewline; Write-Host "# Mix file(s) and inline URLs in one call" -ForegroundColor $ThemeMuted
    Write-Host "      Copy-paste cookbook (real, runnable):" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 install chrome with-ext".PadRight(78) -NoNewline; Write-Host "# Fresh machine -> Chrome + every catalog extension" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext vpn,tabcopy,adblocker".PadRight(78) -NoNewline; Write-Host "# 3 extensions by name" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url ddkjiahejlhfcafbddmgiahcphecmpfh".PadRight(78) -NoNewline; Write-Host "# 1 extension by raw 32-char ID" -ForegroundColor $ThemeMuted
    Write-Host '        .\run.ps1 install chrome ext-url "https://chromewebstore.google.com/detail/<slug>/<id>"' -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url .\extensions.csv -Yes".PadRight(78) -NoNewline; Write-Host "# Bulk + skip warning prompt (CI)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 install chrome ext-url .\extensions.txt https://...".PadRight(78) -NoNewline; Write-Host "# Mix file + inline URL" -ForegroundColor $ThemeMuted
    Write-Host "      Discover / search inline:" -ForegroundColor DarkYellow
    Write-Host "        .\run.ps1 help chrome".PadRight(78)             -NoNewline; Write-Host "# All Chrome lines (browser + extensions)" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 help chrome ext".PadRight(78)         -NoNewline; Write-Host "# AND filter -> only extension lines" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 help ext-url".PadRight(78)            -NoNewline; Write-Host "# Only ad-hoc URL / ID / file examples" -ForegroundColor $ThemeMuted
    Write-Host "        .\run.ps1 help chrome --out chrome-help.txt".PadRight(78) -NoNewline; Write-Host "# Export matched lines to a file" -ForegroundColor $ThemeMuted
    Write-Host "      Tip: extensions land under the Chrome ExtensionInstallForcelist policy registry key" -ForegroundColor $ThemeMuted
    Write-Host "           (HKLM\\SOFTWARE\\Policies\\Google\\Chrome\\ExtensionInstallForcelist) and apply on next launch." -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Settings & Context Menus:" -ForegroundColor $ThemePrimary
    Write-Host "      Each keyword auto-installs its prerequisite app first, then applies settings," -ForegroundColor $ThemeMuted
    Write-Host "      and finally registers the right-click menu (where applicable)." -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      VS Code:" -ForegroundColor DarkYellow
    Write-Host "    $("install vscode+settings".PadRight($kc))" -NoNewline; Write-Host "VS Code + sync settings/keybindings/extensions [01,11]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode+s".PadRight($kc))" -NoNewline; Write-Host "Same as vscode+settings (short alias) [01,11]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode-settings".PadRight($kc))" -NoNewline; Write-Host "Same as vscode+settings (legacy alias of settings-sync) [01,11]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode+menu+settings (= vms)".PadRight($kc))" -NoNewline; Write-Host "VS Code + settings + right-click menu [01,11,10]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode+menu".PadRight($kc))" -NoNewline; Write-Host "VS Code right-click menu (auto-installs VS Code + settings) [01,11,10]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode+context, vscode-context-menu".PadRight($kc))" -NoNewline; Write-Host "Same as vscode+menu (aliases) [01,11,10]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode-fix-menu".PadRight($kc))" -NoNewline; Write-Host "Repair-only: fix VS Code folder right-click registry (no reinstall) [52]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install fix-vscode-menu".PadRight($kc))" -NoNewline; Write-Host "Same as vscode-fix-menu (alias) [52]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode+fix".PadRight($kc))" -NoNewline; Write-Host "VS Code + settings + folder right-click repair [01,11,52]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode+menu+fix".PadRight($kc))" -NoNewline; Write-Host "VS Code + settings + install menu + repair menu [01,11,10,52]" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      PowerShell:" -ForegroundColor DarkYellow
    Write-Host "    $("install pwsh-menu".PadRight($kc))" -NoNewline; Write-Host "PowerShell submenu with 'Open Here' + 'Open as Admin' (auto-installs PowerShell) [17,31]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install pwsh-context-menu".PadRight($kc))" -NoNewline; Write-Host "Same as pwsh-menu (alias) [17,31]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install ps-context-menu".PadRight($kc))" -NoNewline; Write-Host "Same as pwsh-menu (alias) [17,31]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install powershell-menu".PadRight($kc))" -NoNewline; Write-Host "Same as pwsh-menu (alias) [17,31]" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      ConEmu:" -ForegroundColor DarkYellow
    Write-Host "    $("install conemu".PadRight($kc))" -NoNewline; Write-Host "ConEmu + settings auto-applied (ConEmu.xml) [48 install+settings]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install conemu+settings".PadRight($kc))" -NoNewline; Write-Host "Same as conemu (explicit) [48 install+settings]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install conemu-settings".PadRight($kc))" -NoNewline; Write-Host "Apply ConEmu.xml only (skip install) [48 settings-only]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install install-conemu".PadRight($kc))" -NoNewline; Write-Host "Install ConEmu only (skip settings) [48 install-only]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install conemu-menu".PadRight($kc))" -NoNewline; Write-Host "ConEmu submenu with 'Open Here' + 'Open as Admin' for folder/background right-click [48,59]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install conemu+menu".PadRight($kc))" -NoNewline; Write-Host "Same as conemu-menu (alias) [48,59]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install conemu-context-menu".PadRight($kc))" -NoNewline; Write-Host "Same as conemu-menu (alias) [48,59]" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      Windows Terminal context menu:" -ForegroundColor DarkYellow
    Write-Host "    $("install wt-menu".PadRight($kc))" -NoNewline; Write-Host "Windows Terminal submenu with 'Open Here' + 'Open as Admin' for folder/background right-click [37,64]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install wt-context-menu".PadRight($kc))" -NoNewline; Write-Host "Same as wt-menu (alias) [37,64]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install terminal-menu".PadRight($kc))" -NoNewline; Write-Host "Same as wt-menu (alias) [37,64]" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      All right-click context menus (PowerShell + ConEmu + Windows Terminal):" -ForegroundColor DarkYellow
    Write-Host "    $("install context-menu".PadRight($kc))" -NoNewline; Write-Host "Run script 57 bundle: prompt per menu (or pass -y / --yes for all) [57]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install context".PadRight($kc))" -NoNewline; Write-Host "Search alias for the bundle [57]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install menu".PadRight($kc))" -NoNewline; Write-Host "Search alias for the bundle [57]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install right-click".PadRight($kc))" -NoNewline; Write-Host "Search alias for the bundle [57]" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      Scripts Fixer cascading right-click menu (script 53):" -ForegroundColor DarkYellow
    Write-Host "    $("install os-context-menu".PadRight($kc))" -NoNewline; Write-Host "Install full 'Scripts Fixer v{ver}' cascading right-click menu (file/folder/bg/desktop) [53]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install context-menu-all".PadRight($kc))" -NoNewline; Write-Host "Same as os-context-menu (alias) [53]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install all-context-menu".PadRight($kc))" -NoNewline; Write-Host "Same as os-context-menu (alias) [53]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install os-install-context-menu".PadRight($kc))" -NoNewline; Write-Host "Same as os-context-menu (alias) [53]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install scripts-fixer-menu".PadRight($kc))" -NoNewline; Write-Host "Same as os-context-menu (alias) [53]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install sf-menu".PadRight($kc))" -NoNewline; Write-Host "Same as os-context-menu (short alias) [53]" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      Other apps with bundled settings:" -ForegroundColor DarkYellow
    Write-Host "    $("install npp+settings".PadRight($kc))" -NoNewline; Write-Host "Notepad++ + settings [33 install+settings]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install obs+settings".PadRight($kc))" -NoNewline; Write-Host "OBS Studio + settings [36 install+settings]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install wt+settings".PadRight($kc))" -NoNewline; Write-Host "Windows Terminal + settings [37 install+settings]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install dbeaver+settings".PadRight($kc))" -NoNewline; Write-Host "DBeaver + settings [32 install+settings]" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      All settings at once:" -ForegroundColor DarkYellow
    Write-Host "    $("install all-settings".PadRight($kc))" -NoNewline; Write-Host "Install + apply ALL bundled settings: VS Code, NPP, OBS, WT, DBeaver, ConEmu (+ ConEmu right-click) [01,11,32,33,36,37,48,59]" -ForegroundColor $ThemeMuted
    Write-Host "    $("install settings".PadRight($kc))" -NoNewline; Write-Host "Same as all-settings (alias)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install all-settings --exclude obs,wt".PadRight($kc))" -NoNewline; Write-Host "Apply all settings EXCEPT the listed apps" -ForegroundColor $ThemeMuted
    Write-Host "    $("install all-settings --exclude=conemu".PadRight($kc))" -NoNewline; Write-Host "Inline form (=) also accepted; valid tokens: vscode,npp,obs,wt,dbeaver,conemu" -ForegroundColor $ThemeMuted
    Write-Host "    $("install all-settings --exclude obs,xyz --exclude-strict".PadRight($kc))" -NoNewline; Write-Host "Abort (exit 2) if any --exclude token is unknown instead of warning" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      --exclude token reference:" -ForegroundColor DarkYellow
    Write-Host "      Each token is looked up in the same keyword map as install <keyword>." -ForegroundColor $ThemeMuted
    Write-Host "      Whatever script IDs the token resolves to are subtracted from the bundle." -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      $("Token".PadRight(20))" -NoNewline -ForegroundColor White
    Write-Host "$("Removes IDs".PadRight(18))" -NoNewline -ForegroundColor White
    Write-Host "Aliases" -ForegroundColor White
    Write-Host "      $("vscode".PadRight(20))" -NoNewline; Write-Host "$("[01, 11]".PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary; Write-Host "vs-code, code, vscode+settings, vscode+s, vscode-settings (legacy: settings-sync)" -ForegroundColor $ThemeMuted
    Write-Host "      $("vscode-fix-menu".PadRight(20))" -NoNewline; Write-Host "$("[52]".PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary; Write-Host "fix-vscode-menu, vscode-menu-fix, vscode-menu-repair, fix-vscode-context-menu (folder right-click repair only)" -ForegroundColor $ThemeMuted
    Write-Host "      $("npp".PadRight(20))" -NoNewline; Write-Host "$("[33]".PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary; Write-Host "notepad++, notepadpp, notepad-plus, npp+settings, npp-settings" -ForegroundColor $ThemeMuted
    Write-Host "      $("obs".PadRight(20))" -NoNewline; Write-Host "$("[36]".PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary; Write-Host "obs-studio, obs+settings, obs-settings, install-obs" -ForegroundColor $ThemeMuted
    Write-Host "      $("wt".PadRight(20))" -NoNewline; Write-Host "$("[37]".PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary; Write-Host "windows-terminal, wt+settings, wt-settings, install-wt" -ForegroundColor $ThemeMuted
    Write-Host "      $("dbeaver".PadRight(20))" -NoNewline; Write-Host "$("[32]".PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary; Write-Host "db-viewer, dbviewer, dbeaver+settings, dbeaver-settings" -ForegroundColor $ThemeMuted
    Write-Host "      $("conemu".PadRight(20))" -NoNewline; Write-Host "$("[48, 59]".PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary; Write-Host "conemu+settings, conemu-settings, install-conemu, conemu-menu, conemu+menu, conemu-context-menu" -ForegroundColor $ThemeMuted
    Write-Host "      $("conemu-menu".PadRight(20))" -NoNewline; Write-Host "$("[59]".PadRight(18))" -NoNewline -ForegroundColor $ThemeSecondary; Write-Host "conemu+menu, conemu-context-menu (right-click only; keeps script 48 install)" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      Flag spellings (all equivalent):" -ForegroundColor $ThemeMuted
    Write-Host "        --exclude  -exclude  --ex  -ex  --without  -without  --skip  -skip" -ForegroundColor $ThemeMuted
    Write-Host "      Value formats: '--exclude obs,wt'  '--exclude obs wt'  '--exclude=obs,wt'" -ForegroundColor $ThemeMuted
    Write-Host "      Strict mode flags: --exclude-strict, --strict-exclude, --excludestrict" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Python & pip libraries:" -ForegroundColor $ThemePrimary
    Write-Host ""
    Write-Host "      Quick install:" -ForegroundColor DarkYellow
    Write-Host "    $("install pylibs".PadRight($kc))" -NoNewline; Write-Host "Install Python + all libraries in one go" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python-libs".PadRight($kc))" -NoNewline; Write-Host "Install all pip libraries only (numpy, pandas, etc.)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python+libs".PadRight($kc))" -NoNewline; Write-Host "Install Python + all libraries in one go" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      By purpose:" -ForegroundColor DarkYellow
    Write-Host "    $("install data-science".PadRight($kc))" -NoNewline; Write-Host "Python + data/viz libs (pandas, matplotlib, plotly)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install ai-dev".PadRight($kc))" -NoNewline; Write-Host "Python + ML libs (numpy, scipy, scikit-learn, torch)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install deep-learning".PadRight($kc))" -NoNewline; Write-Host "Python + ML libs (same as ai-dev)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install jupyter+libs".PadRight($kc))" -NoNewline; Write-Host "Jupyter only (jupyterlab, notebook, ipykernel)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install viz-libs".PadRight($kc))" -NoNewline; Write-Host "Visualization (matplotlib, seaborn, plotly)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install web-libs".PadRight($kc))" -NoNewline; Write-Host "Web frameworks (django, flask, fastapi, uvicorn)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install scraping-libs".PadRight($kc))" -NoNewline; Write-Host "Scraping (requests, beautifulsoup4)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install db-libs".PadRight($kc))" -NoNewline; Write-Host "Database (sqlalchemy)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install cv-libs".PadRight($kc))" -NoNewline; Write-Host "Computer Vision (opencv-python)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install data-libs".PadRight($kc))" -NoNewline; Write-Host "Data tools (pandas, polars)" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      With Python (auto-installs Python first):" -ForegroundColor DarkYellow
    Write-Host "    $("install python+viz".PadRight($kc))" -NoNewline; Write-Host "Python + visualization group" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python+web".PadRight($kc))" -NoNewline; Write-Host "Python + web frameworks group" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python+scraping".PadRight($kc))" -NoNewline; Write-Host "Python + scraping group" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python+db".PadRight($kc))" -NoNewline; Write-Host "Python + database group" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python+cv".PadRight($kc))" -NoNewline; Write-Host "Python + computer vision group" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python+data".PadRight($kc))" -NoNewline; Write-Host "Python + data tools group" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python+ml".PadRight($kc))" -NoNewline; Write-Host "Python + ML group" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python+jupyter".PadRight($kc))" -NoNewline; Write-Host "Python + all libraries (includes Jupyter)" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      By group (.\run.ps1 -I 41 --):" -ForegroundColor DarkYellow
    Write-Host "    $(".\run.ps1 -I 41 -- group ml".PadRight($kc))" -NoNewline; Write-Host "ML group (numpy, scipy, scikit-learn, torch...)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- group jupyter".PadRight($kc))" -NoNewline; Write-Host "Jupyter (jupyterlab, notebook, ipykernel, ipywidgets)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- group viz".PadRight($kc))" -NoNewline; Write-Host "Visualization (matplotlib, seaborn, plotly)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- group data".PadRight($kc))" -NoNewline; Write-Host "Data tools (pandas, polars)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- group web".PadRight($kc))" -NoNewline; Write-Host "Web frameworks (django, flask, fastapi, uvicorn)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- group scraping".PadRight($kc))" -NoNewline; Write-Host "Scraping (requests, beautifulsoup4)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- group cv".PadRight($kc))" -NoNewline; Write-Host "Computer Vision (opencv-python)" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- group db".PadRight($kc))" -NoNewline; Write-Host "Database (sqlalchemy)" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "      Utilities:" -ForegroundColor DarkYellow
    Write-Host "    $(".\run.ps1 -I 41 -- add <pkg1> <pkg2>".PadRight($kc))" -NoNewline; Write-Host "Install specific packages by name" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- list".PadRight($kc))" -NoNewline; Write-Host "Show all available library groups" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- installed".PadRight($kc))" -NoNewline; Write-Host "Show currently installed pip packages" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- uninstall".PadRight($kc))" -NoNewline; Write-Host "Uninstall all tracked libraries" -ForegroundColor $ThemeMuted
    Write-Host "    $(".\run.ps1 -I 41 -- uninstall <pkg>".PadRight($kc))" -NoNewline; Write-Host "Uninstall specific packages" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Database installs:" -ForegroundColor $ThemePrimary
    Write-Host "    $("install databases".PadRight($kc))" -NoNewline; Write-Host "Open the interactive database installer menu" -ForegroundColor $ThemeMuted
    Write-Host "    $("install mysql".PadRight($kc))" -NoNewline; Write-Host "Install MySQL database" -ForegroundColor $ThemeMuted
    Write-Host "    $("install postgresql".PadRight($kc))" -NoNewline; Write-Host "Install PostgreSQL database" -ForegroundColor $ThemeMuted
    Write-Host "    $("install sqlite".PadRight($kc))" -NoNewline; Write-Host "Install SQLite + DB Browser for SQLite" -ForegroundColor $ThemeMuted
    Write-Host "    $("install mongodb,redis".PadRight($kc))" -NoNewline; Write-Host "Install MongoDB + Redis" -ForegroundColor $ThemeMuted
    Write-Host "    $("install alldev".PadRight($kc))" -NoNewline; Write-Host "Interactive dev tools menu (pick what to install)" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Combine keywords:" -ForegroundColor $ThemePrimary
    Write-Host "    $("install nodejs,pnpm".PadRight($kc))" -NoNewline; Write-Host "Install Node.js + pnpm" -ForegroundColor $ThemeMuted
    Write-Host "    $("install go,git,cpp".PadRight($kc))" -NoNewline; Write-Host "Install Go, Git, and C++" -ForegroundColor $ThemeMuted
    Write-Host "    $("install python,php".PadRight($kc))" -NoNewline; Write-Host "Install Python + PHP" -ForegroundColor $ThemeMuted
    Write-Host "    $("install vscode,nodejs,git".PadRight($kc))" -NoNewline; Write-Host "Install VS Code, Node.js, and Git" -ForegroundColor $ThemeMuted
    Write-Host "    $("install alldev,mysql".PadRight($kc))" -NoNewline; Write-Host "Run the alldev menu, then install MySQL" -ForegroundColor $ThemeMuted
    Write-Host ""

    Write-Host "    Remote installers (irm <url> | iex):" -ForegroundColor $ThemePrimary
    Write-Host "      All aliases on each row are EQUIVALENT -- pick whichever you remember." -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "    $("install clean-code".PadRight($kc))" -NoNewline; Write-Host "Coding Guidelines v23 -- alimtvnetwork/coding-guidelines-v23" -ForegroundColor $ThemeMuted
    Write-Host "    $("install code-guide  (= cg, cc)".PadRight($kc))" -NoNewline; Write-Host "Same as 'install clean-code' (4 aliases total)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install coding-guidelines".PadRight($kc))" -NoNewline; Write-Host "Same as 'install clean-code' (long alias)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install starship    (= ss)".PadRight($kc))" -NoNewline; Write-Host "Starship cross-shell prompt -- local wrapper (winget/scoop/cargo)" -ForegroundColor $ThemeMuted
    Write-Host "    $("install oh-my-posh  (= omp, posh)".PadRight($kc))" -NoNewline; Write-Host "Oh My Posh prompt -- ohmyposh.dev/install.ps1" -ForegroundColor $ThemeMuted
    Write-Host "    $("install scoop       (= sc)".PadRight($kc))" -NoNewline; Write-Host "Scoop CLI installer -- get.scoop.sh" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "    Combine remote + local: install vscode,cg  (VS Code first, then clean-code)" -ForegroundColor $ThemeMuted
    Write-Host ""

    Show-KeywordTable -Inline
    Write-Host ""

    # ── Available Scripts (with installed versions) ──
    Write-Host "  Available Scripts:" -ForegroundColor $ThemeAccent
    Write-Host ""

    $vMap = Get-VersionMap
    $nc = 30

    $printRow = {
        param([string]$id, [string]$name, [string]$desc)
        $ver = $vMap[$id]
        $hasVer = -not [string]::IsNullOrWhiteSpace($ver)
        Write-Host "    $id  $($name.PadRight($nc)) " -NoNewline
        Write-Host $desc -ForegroundColor $ThemeMuted -NoNewline
        if ($hasVer) {
            Write-Host "  [" -NoNewline -ForegroundColor $ThemeMuted
            Write-Host "v$ver" -NoNewline -ForegroundColor Green
            Write-Host "]" -NoNewline -ForegroundColor $ThemeMuted
        }
        Write-Host ""
    }

    Write-Host "    ID  $("Name".PadRight($nc))  Description" -ForegroundColor $ThemeMuted
    Write-Host "    --  $(''.PadRight($nc, '-'))  $(''.PadRight(50, '-'))" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "    Core Tools" -ForegroundColor $ThemePrimary
    & $printRow "01" "vscode"          "Install Visual Studio Code (Stable/Insiders)"
    & $printRow "02" "choco"               "Install Chocolatey package manager"
    & $printRow "03" "nodejs"     "Install Node.js LTS, Yarn, Bun, verify npx"
    & $printRow "04" "pnpm"                     "Install pnpm, configure global store"
    & $printRow "05" "python"                   "Install Python, configure pip user site"
    & $printRow "41" "pylibs"         "Install pip packages: ML, viz, web, jupyter (by group)"
    & $printRow "06" "golang"                   "Install Go, configure GOPATH and go env"
    & $printRow "07" "git"           "Install Git, Git LFS, GitHub CLI, configure settings"
    & $printRow "08" "github-desktop"           "Install GitHub Desktop via Chocolatey"
    & $printRow "09" "cpp"          "Install MinGW-w64 C++ compiler, verify g++/gcc/make"
    & $printRow "16" "php"                      "Install PHP via Chocolatey"
    & $printRow "17" "pwsh"      "Install latest PowerShell via Winget/Chocolatey"
    & $printRow "38" "flutter"           "Install Flutter SDK, Dart, Android toolchain"
    & $printRow "39" "dotnet"                 "Install .NET SDK (6/8/9), configure dotnet CLI"
    & $printRow "40" "java"           "Install OpenJDK via Chocolatey (17/21)"
    Write-Host ""
    Write-Host "    Optional" -ForegroundColor $ThemePrimary
    & $printRow "10" "vscode-menu"  "Add/repair VSCode right-click context menu entries"
    & $printRow "11" "vscode-sync"     "Sync VSCode settings, keybindings, and extensions"
    & $printRow "31" "pwsh-menu"  "Add PowerShell submenu to right-click menu (Open Here + Open as Admin)"
    Write-Host ""
    Write-Host "    Orchestrator" -ForegroundColor $ThemePrimary
    & $printRow "12" "all"    "Interactive grouped menu: pick tools or install everything"
    & $printRow "30" "databases"        "Interactive database installer (SQL, NoSQL, file-based)"
    Write-Host ""
    Write-Host "    Utilities" -ForegroundColor $ThemePrimary
    & $printRow "13" "audit"               "Scan configs, specs, suggestions for stale IDs"
    & $printRow "14" "winget"           "Install/verify Winget package manager (standalone)"
    & $printRow "15" "win-tweaks"           "Chris Titus Windows Utility (tweaks and debloating)"
    Write-Host ""
    Write-Host "    Desktop Tools" -ForegroundColor $ThemePrimary
    & $printRow "32" "dbeaver"        "Universal database visualization and management tool"
    & $printRow "33" "npp"          "Install NPP, NPP Settings, or NPP + Settings"
    & $printRow "34" "sticky-notes"      "Install Simple Sticky Notes via Chocolatey"
    & $printRow "35" "gitmap"                   "Git repository navigator CLI tool"
    & $printRow "36" "obs"               "Install OBS, OBS Settings, or OBS + Settings"
    & $printRow "37" "wt"          "Install WT, WT Settings, or WT + Settings"
    Write-Host ""

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

    # Resolve actual default dev directory dynamically (saved path > smart detect)
    # Quiet inline detection -- avoids the noisy logging in Find-BestDevDrive.
    $resolvedDefault = $null
    $resolvedSource  = $null
    try {
        $devDirHelperPath = Join-Path $RootDir "scripts\shared\dev-dir.ps1"
        $isDevDirHelperPresent = Test-Path $devDirHelperPath
        if ($isDevDirHelperPresent) {
            . $devDirHelperPath
            $savedPath = Get-SavedDevPath
            $hasSavedPath = $null -ne $savedPath
            if ($hasSavedPath) {
                $resolvedDefault = $savedPath
                $resolvedSource  = "saved via .\run.ps1 path"
            }
        }
    } catch {}

    $isResolvedMissing = [string]::IsNullOrWhiteSpace($resolvedDefault)
    if ($isResolvedMissing) {
        # Quiet drive scan: E: > D: > best non-system fixed drive >= 10 GB free
        $minFreeGB = 10
        $sysLetter = if ([string]::IsNullOrWhiteSpace($env:SystemDrive)) { "C" } else { $env:SystemDrive.TrimEnd('\').Substring(0, 1) }
        $bestLetter = $null
        $bestSource = $null
        try {
            $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
            $diskMap = @{}
            foreach ($d in $disks) {
                $letter = $d.DeviceID.Substring(0, 1)
                $freeGB = [math]::Round($d.FreeSpace / 1GB, 1)
                $diskMap[$letter] = $freeGB
            }
            $hasGoodE = $diskMap.ContainsKey("E") -and $diskMap["E"] -ge $minFreeGB
            $hasGoodD = $diskMap.ContainsKey("D") -and $diskMap["D"] -ge $minFreeGB
            if ($hasGoodE) {
                $bestLetter = "E"; $bestSource = "auto-detected: E: drive ($($diskMap['E']) GB free)"
            } elseif ($hasGoodD) {
                $bestLetter = "D"; $bestSource = "auto-detected: D: drive ($($diskMap['D']) GB free)"
            } else {
                $best = $diskMap.GetEnumerator() |
                    Where-Object { $_.Key -ne $sysLetter -and $_.Key -ne "E" -and $_.Key -ne "D" -and $_.Value -ge $minFreeGB } |
                    Sort-Object Value -Descending | Select-Object -First 1
                $hasBest = $null -ne $best
                if ($hasBest) {
                    $bestLetter = $best.Key
                    $bestSource = "auto-detected: $($best.Key): drive ($($best.Value) GB free)"
                }
            }
        } catch {}

        $hasBestLetter = $null -ne $bestLetter
        if ($hasBestLetter) {
            $resolvedDefault = "${bestLetter}:\dev-tool"
            $resolvedSource  = $bestSource
        } else {
            $resolvedDefault = "${sysLetter}:\dev-tool"
            $resolvedSource  = "fallback to system drive (no qualified drive >= $minFreeGB GB free)"
        }
    }

    Write-Host "    Default dev directory: " -NoNewline -ForegroundColor $ThemeMuted
    Write-Host "$resolvedDefault " -NoNewline -ForegroundColor White
    Write-Host "($resolvedSource)" -ForegroundColor $ThemeMuted
    Write-Host "    Override with: " -NoNewline -ForegroundColor $ThemeMuted; Write-Host ".\run.ps1 -I 12 -- -Path F:\dev-tool" -ForegroundColor White
    Write-Host "    Default VS Code edition: " -NoNewline -ForegroundColor $ThemeMuted; Write-Host "Stable" -ForegroundColor White
    Write-Host "    Default sync mode: " -NoNewline -ForegroundColor $ThemeMuted; Write-Host "Overwrite" -ForegroundColor White
    Write-Host ""

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

    Show-VersionFooter
}

# ── Help wrapper with optional keyword filter + export ───────────────
# Usage:
#   Show-RootHelp                                       -> full help
#   Show-RootHelp -Filter "chrome"                      -> lines containing "chrome"
#   Show-RootHelp -Filter "chrome startup"              -> AND match
#   Show-RootHelp -Filter "chrome" -OutFile out.txt     -> also save plain text
#   Show-RootHelp -Filter "chrome" -OutFile out.json -Format json
function Show-RootHelp {
    param(
        [string]$Filter,
        [string]$OutFile,
        [ValidateSet("text", "json")]
        [string]$Format = "text"
    )

    $hasFilter = -not [string]::IsNullOrWhiteSpace($Filter)
    if (-not $hasFilter) {
        Show-RootHelpRaw
        return
    }

    # Split on whitespace and commas; lower-case; drop empties.
    # Each term must appear in a logical line for it to match (AND semantics).
    # Matching is case-INSENSITIVE: needles are lower-cased here, and each
    # captured help line is compared via .ToLower().Contains(...) below.
    $needles = @(
        $Filter.ToLower() -split '[\s,]+' |
            ForEach-Object { $_.Trim() } |
            Where-Object   { $_.Length -gt 0 }
    )
    $hasNeedles = $needles.Count -gt 0
    if (-not $hasNeedles) {
        Show-RootHelpRaw
        return
    }

    $displayFilter = $needles -join ' AND '

    # Auto-pick format from extension if -OutFile given without explicit -Format.
    $hasOutFile = -not [string]::IsNullOrWhiteSpace($OutFile)
    if ($hasOutFile -and -not $PSBoundParameters.ContainsKey('Format')) {
        $ext = [System.IO.Path]::GetExtension($OutFile).ToLower()
        if ($ext -eq ".json") { $Format = "json" } else { $Format = "text" }
    }

    # Capture Write-Host output (Information stream, ID 6) as records so we
    # can preserve the original colors when re-emitting matched lines.
    $records = & { Show-RootHelpRaw } 6>&1

    Write-Host ""
    Write-Host "  Filtered help -- keyword(s): $displayFilter" -ForegroundColor $ThemeSecondary
    Write-Host "  ===================================" -ForegroundColor $ThemeMuted
    Write-Host ""

    $pending = New-Object System.Collections.Generic.List[object]
    $matched = 0
    # Plain-text and structured copies of matched logical lines for export.
    $matchedPlain = New-Object System.Collections.Generic.List[string]
    $matchedRich  = New-Object System.Collections.Generic.List[object]
    # Per-term hit counts (independent OR-style tallies, NOT AND).
    # Each needle counts how many logical lines contain it individually,
    # so users can see which term is the most/least restrictive.
    $perTermCounts = [ordered]@{}
    foreach ($n in $needles) { $perTermCounts[$n] = 0 }

    foreach ($rec in $records) {
        $msg = ""; $fg = $null; $nl = $false
        if ($rec -is [System.Management.Automation.InformationRecord]) {
            $data = $rec.MessageData
            if ($data -is [System.Management.Automation.HostInformationMessage]) {
                $msg = [string]$data.Message
                $fg  = $data.ForegroundColor
                $nl  = [bool]$data.NoNewLine
            } else {
                $msg = [string]$data
            }
        } else {
            $msg = [string]$rec
        }

        $pending.Add([pscustomobject]@{ Message = $msg; ForegroundColor = $fg; NoNewLine = $nl })

        if (-not $nl) {
            # Logical line complete -- emit only if EVERY needle matches.
            $combined = -join ($pending | ForEach-Object { $_.Message })
            $combinedLower = $combined.ToLower()
            $isMatch = $true
            foreach ($n in $needles) {
                if ($combinedLower.Contains($n)) { $perTermCounts[$n]++ }
                else { $isMatch = $false }
            }
            if ($isMatch) {
                foreach ($p in $pending) {
                    $hp = @{ Object = $p.Message; NoNewline = $true }
                    if ($null -ne $p.ForegroundColor -and [int]$p.ForegroundColor -ge 0) {
                        $hp.ForegroundColor = $p.ForegroundColor
                    }
                    Write-Host @hp
                }
                Write-Host ""
                $matched++

                $matchedPlain.Add($combined.TrimEnd())
                $segments = @()
                foreach ($p in $pending) {
                    $colorName = if ($null -ne $p.ForegroundColor) { "$($p.ForegroundColor)" } else { $null }
                    $segments += [pscustomobject]@{ text = $p.Message; color = $colorName }
                }
                $matchedRich.Add([pscustomobject]@{
                    line     = $combined.TrimEnd()
                    segments = $segments
                })
            }
            $pending.Clear()
        }
    }

    Write-Host ""
    if ($matched -eq 0) {
        Write-Host "  No help lines match: $displayFilter" -ForegroundColor $ThemeAccent
        Write-Host "  Tip: try fewer terms or broader keywords (e.g. 'chrome', 'ext', 'menu', 'os')." -ForegroundColor $ThemeMuted
    } else {
        $termWord = if ($needles.Count -eq 1) { "term" } else { "terms (AND)" }
        Write-Host "  $matched line(s) matched $($needles.Count) $termWord -- $displayFilter" -ForegroundColor Green
        Write-Host "  Run '.\run.ps1 help' (no keyword) to see the full help screen." -ForegroundColor $ThemeMuted
    }

    # ── Per-term match summary ───────────────────────────────────────
    # Always show, even when AND result is 0 -- helps diagnose which
    # term killed the intersection (e.g. one term has 0 hits on its own).
    Write-Host ""
    Write-Host "  Per-term hit counts (independent, not AND):" -ForegroundColor $ThemeSecondary
    $kwCol = [Math]::Max(8, ($needles | Measure-Object -Property Length -Maximum).Maximum + 2)
    $hitCol = 7
    Write-Host ("    {0}{1}{2}" -f "Keyword".PadRight($kwCol), "Lines".PadRight($hitCol), "Share") -ForegroundColor $ThemeMuted
    Write-Host ("    {0}{1}{2}" -f ("".PadRight($kwCol,'-')), ("".PadRight($hitCol,'-')), "-----") -ForegroundColor $ThemeMuted
    foreach ($n in $needles) {
        $hits = [int]$perTermCounts[$n]
        $color = if ($hits -eq 0) { "Red" }
                 elseif ($hits -eq $matched -and $matched -gt 0) { "Green" }
                 elseif ($hits -ge 5) { "Cyan" }
                 else { "DarkYellow" }
        $share = if ($hits -gt 0) {
            $pct = [Math]::Round(($matched / [double]$hits) * 100, 0)
            "$matched/$hits AND-kept (${pct}%)"
        } else {
            "0 lines contain this term -> blocks AND match"
        }
        Write-Host ("    {0}" -f $n.PadRight($kwCol)) -ForegroundColor White -NoNewline
        Write-Host ("{0}" -f "$hits".PadRight($hitCol)) -ForegroundColor $color -NoNewline
        Write-Host $share -ForegroundColor $ThemeMuted
    }
    if ($needles.Count -gt 1) {
        Write-Host "    (AND intersection: $matched line(s))" -ForegroundColor $ThemeMuted
    }


    # ── Export ────────────────────────────────────────────────────────
    if ($hasOutFile) {
        try {
            $outFull = $OutFile
            if (-not [System.IO.Path]::IsPathRooted($outFull)) {
                $outFull = Join-Path (Get-Location).Path $OutFile
            }
            $parent = Split-Path -Parent $outFull
            if ($parent -and -not (Test-Path $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }

            if ($Format -eq "json") {
                $payload = [pscustomobject]@{
                    generatedAt = (Get-Date).ToString("o")
                    filter      = $displayFilter
                    keywords    = $needles
                    matchCount  = $matched
                    lines       = $matchedRich
                }
                $payload | ConvertTo-Json -Depth 6 | Set-Content -Path $outFull -Encoding UTF8
            } else {
                $header = @(
                    "# Filtered help -- keyword(s): $displayFilter",
                    "# Generated: $((Get-Date).ToString('o'))",
                    "# Matches  : $matched",
                    ""
                )
                ($header + $matchedPlain) | Set-Content -Path $outFull -Encoding UTF8
            }

            Write-Host ""
            Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
            Write-Host "Saved $matched line(s) to: " -NoNewline
            Write-Host "$outFull" -ForegroundColor $ThemeSecondary
            Write-Host "          Format: $Format" -ForegroundColor $ThemeMuted
        } catch {
            Write-Host ""
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Could not write export file: $OutFile"
            Write-Host "          Reason: $($_.Exception.Message)" -ForegroundColor $ThemeMuted
        }
    }
    Write-Host ""
}

# ── Keyword table (compact view) ────────────────────────────────────
function Show-KeywordTable {
    param([switch]$Inline)

    $isStandalone = -not $Inline
    if ($isStandalone) {
        Write-Host ""
        Write-Host "  Available Keywords" -ForegroundColor $ThemeSecondary
        Write-Host "  ==================" -ForegroundColor $ThemeMuted
    } else {
        Write-Host "  Available Keywords:" -ForegroundColor $ThemeAccent
    }
    Write-Host ""

    $kwCol = 28
    $descCol = 36

    Write-Host "    $("Keyword".PadRight($kwCol))$("Description".PadRight($descCol))Script ID" -ForegroundColor $ThemeMuted
    Write-Host "    $(''.PadRight($kwCol, '-'))$(''.PadRight($descCol, '-'))---------" -ForegroundColor $ThemeMuted

    Write-Host "    $("vscode, vs-code".PadRight($kwCol))$("VS Code".PadRight($descCol))01"
    Write-Host "    $("choco, chocolatey".PadRight($kwCol))$("choco".PadRight($descCol))02"
    Write-Host "    $("nodejs, node".PadRight($kwCol))$("nodejs".PadRight($descCol))03"
    Write-Host "    $("pnpm".PadRight($kwCol))$("Node.js + pnpm".PadRight($descCol))03, 04"
    Write-Host ""
    Write-Host "    Python & Libraries" -ForegroundColor $ThemePrimary
    Write-Host "    $("python, pip".PadRight($kwCol))$("Python + pip".PadRight($descCol))05"
    Write-Host "    $("pylibs".PadRight($kwCol))$("Python + all libraries".PadRight($descCol))05, 41"
    Write-Host "    $("python-libs, pip-libs".PadRight($kwCol))$("All pip libraries only".PadRight($descCol))41"
    Write-Host "    $("ml-libs, ml-full".PadRight($kwCol))$("ML libraries".PadRight($descCol))41"
    Write-Host "    $("jupyter+libs".PadRight($kwCol))$("Jupyter group only".PadRight($descCol))41"
    Write-Host "    $("viz-libs".PadRight($kwCol))$("Visualization group".PadRight($descCol))41"
    Write-Host "    $("web-libs".PadRight($kwCol))$("Web frameworks group".PadRight($descCol))41"
    Write-Host "    $("scraping-libs".PadRight($kwCol))$("Scraping group".PadRight($descCol))41"
    Write-Host "    $("db-libs".PadRight($kwCol))$("Database group".PadRight($descCol))41"
    Write-Host "    $("cv-libs".PadRight($kwCol))$("Computer Vision group".PadRight($descCol))41"
    Write-Host "    $("data-libs".PadRight($kwCol))$("Data tools group".PadRight($descCol))41"
    Write-Host "    $("python+viz".PadRight($kwCol))$("Python + viz group".PadRight($descCol))05, 41"
    Write-Host "    $("python+web".PadRight($kwCol))$("Python + web group".PadRight($descCol))05, 41"
    Write-Host "    $("python+scraping".PadRight($kwCol))$("Python + scraping group".PadRight($descCol))05, 41"
    Write-Host "    $("python+db".PadRight($kwCol))$("Python + database group".PadRight($descCol))05, 41"
    Write-Host "    $("python+cv".PadRight($kwCol))$("Python + CV group".PadRight($descCol))05, 41"
    Write-Host "    $("python+data".PadRight($kwCol))$("Python + data group".PadRight($descCol))05, 41"
    Write-Host "    $("python+ml".PadRight($kwCol))$("Python + ML group".PadRight($descCol))05, 41"
    Write-Host "    $("python+libs, ml-dev".PadRight($kwCol))$("Python + all libraries".PadRight($descCol))05, 41"
    Write-Host "    $("python+jupyter".PadRight($kwCol))$("Python + all libraries".PadRight($descCol))05, 41"
    Write-Host "    $("pip+jupyter+libs".PadRight($kwCol))$("Python + all libraries".PadRight($descCol))05, 41"
    Write-Host "    $("data-science".PadRight($kwCol))$("Python + data/viz libs".PadRight($descCol))05, 41"
    Write-Host "    $("ai-dev, deep-learning".PadRight($kwCol))$("Python + ML libs".PadRight($descCol))05, 41"
    Write-Host ""
    Write-Host "    Languages & Runtimes" -ForegroundColor $ThemePrimary
    Write-Host "    $("go, golang".PadRight($kwCol))$("Go".PadRight($descCol))06"
    Write-Host "    $("git, gh".PadRight($kwCol))$("Git + LFS + GitHub CLI".PadRight($descCol))07"
    Write-Host "    $("github-desktop".PadRight($kwCol))$("github-desktop".PadRight($descCol))08"
    Write-Host "    $("cpp, c++, gcc".PadRight($kwCol))$("cpp".PadRight($descCol))09"
    Write-Host "    $("php, php+phpmyadmin".PadRight($kwCol))$("PHP + phpMyAdmin (default)".PadRight($descCol))16"
    Write-Host "    $("php-only".PadRight($kwCol))$("PHP only".PadRight($descCol))16"
    Write-Host "    $("phpmyadmin".PadRight($kwCol))$("phpMyAdmin only".PadRight($descCol))16"
    Write-Host "    $("powershell, pwsh".PadRight($kwCol))$("pwsh".PadRight($descCol))17"
    Write-Host "    $("flutter, dart".PadRight($kwCol))$("Flutter SDK + Dart".PadRight($descCol))38"
    Write-Host "    $("dotnet, csharp, .net".PadRight($kwCol))$("dotnet".PadRight($descCol))39"
    Write-Host "    $("java, openjdk, jdk".PadRight($kwCol))$("OpenJDK".PadRight($descCol))40"
    Write-Host ""
    Write-Host "    Config & Settings" -ForegroundColor $ThemePrimary
    Write-Host "    $("vscode+menu, vscode+context".PadRight($kwCol))$("VS Code + Settings + Right-click Menu".PadRight($descCol))01, 10, 11"
    Write-Host "    $("vscode+settings, vscode+s".PadRight($kwCol))$("VS Code + Settings Sync".PadRight($descCol))01, 11"
    Write-Host "    $("pwsh+menu, pwsh-menu".PadRight($kwCol))$("PowerShell + Right-click Menu".PadRight($descCol))17, 31"
    Write-Host "    $("conemu+menu, conemu-menu".PadRight($kwCol))$("ConEmu + Right-click Menu".PadRight($descCol))48, 59"
    Write-Host "    $("wt+menu, wt-menu".PadRight($kwCol))$("Windows Terminal + Right-click Menu".PadRight($descCol))37, 64"
    Write-Host "    $("all-dev, all".PadRight($kwCol))$("Interactive dev tools menu".PadRight($descCol))12"
    Write-Host "    $("audit".PadRight($kwCol))$("Audit mode".PadRight($descCol))13"
    Write-Host "    $("health, healthcheck".PadRight($kwCol))$("Health check (audit + report)".PadRight($descCol))13"
    Write-Host "    $("winget".PadRight($kwCol))$("Winget package manager".PadRight($descCol))14"
    Write-Host "    $("tweaks".PadRight($kwCol))$("Windows tweaks".PadRight($descCol))15"
    Write-Host ""
    Write-Host "    Databases" -ForegroundColor $ThemePrimary
    Write-Host "    $("mysql".PadRight($kwCol))$("MySQL".PadRight($descCol))18"
    Write-Host "    $("mariadb".PadRight($kwCol))$("MariaDB".PadRight($descCol))19"
    Write-Host "    $("postgresql, postgres".PadRight($kwCol))$("PostgreSQL".PadRight($descCol))20"
    Write-Host "    $("sqlite".PadRight($kwCol))$("SQLite + DB Browser".PadRight($descCol))21"
    Write-Host "    $("mongodb, mongo".PadRight($kwCol))$("MongoDB".PadRight($descCol))22"
    Write-Host "    $("couchdb".PadRight($kwCol))$("CouchDB".PadRight($descCol))23"
    Write-Host "    $("redis".PadRight($kwCol))$("Redis".PadRight($descCol))24"
    Write-Host "    $("cassandra".PadRight($kwCol))$("Apache Cassandra".PadRight($descCol))25"
    Write-Host "    $("neo4j".PadRight($kwCol))$("Neo4j".PadRight($descCol))26"
    Write-Host "    $("elasticsearch".PadRight($kwCol))$("Elasticsearch".PadRight($descCol))27"
    Write-Host "    $("duckdb".PadRight($kwCol))$("DuckDB".PadRight($descCol))28"
    Write-Host "    $("litedb".PadRight($kwCol))$("LiteDB".PadRight($descCol))29"
    Write-Host "    $("databases, db".PadRight($kwCol))$("Database installer menu".PadRight($descCol))30"
    Write-Host ""
    Write-Host "    Desktop Tools" -ForegroundColor $ThemePrimary
    Write-Host "    $("notepad++, npp".PadRight($kwCol))$("NPP + Settings (install + sync)".PadRight($descCol))33"
    Write-Host "    $("npp+settings".PadRight($kwCol))$("NPP + Settings (explicit)".PadRight($descCol))33"
    Write-Host "    $("npp-settings".PadRight($kwCol))$("NPP Settings (settings only)".PadRight($descCol))33"
    Write-Host "    $("install-npp".PadRight($kwCol))$("Install NPP (install only)".PadRight($descCol))33"
    Write-Host "    $("sticky-notes, sticky".PadRight($kwCol))$("sticky-notes".PadRight($descCol))34"
    Write-Host "    $("gitmap, git-map".PadRight($kwCol))$("GitMap CLI".PadRight($descCol))35"
    Write-Host "    $("obs, obs+settings".PadRight($kwCol))$("OBS + Settings (install + sync)".PadRight($descCol))36"
    Write-Host "    $("obs-settings".PadRight($kwCol))$("OBS Settings (settings only)".PadRight($descCol))36"
    Write-Host "    $("install-obs".PadRight($kwCol))$("Install OBS (install only)".PadRight($descCol))36"
    Write-Host "    $("wt, windows-terminal".PadRight($kwCol))$("WT + Settings (install + sync)".PadRight($descCol))37"
    Write-Host "    $("wt+settings".PadRight($kwCol))$("WT + Settings (explicit)".PadRight($descCol))37"
    Write-Host "    $("wt-settings".PadRight($kwCol))$("WT Settings (settings only)".PadRight($descCol))37"
    Write-Host "    $("install-wt".PadRight($kwCol))$("Install WT (install only)".PadRight($descCol))37"
    Write-Host "    $("dbeaver, db-viewer".PadRight($kwCol))$("DBeaver + Settings (install + sync)".PadRight($descCol))32"
    Write-Host "    $("dbeaver-settings".PadRight($kwCol))$("DBeaver Settings (settings only)".PadRight($descCol))32"
    Write-Host "    $("install-dbeaver".PadRight($kwCol))$("Install DBeaver (install only)".PadRight($descCol))32"
    Write-Host ""
    Write-Host "    AI & Local LLM" -ForegroundColor $ThemePrimary
    Write-Host "    $("ollama, local-llm".PadRight($kwCol))$("Ollama (local LLM runner)".PadRight($descCol))42"
    Write-Host "    $("llama-cpp, llamacpp".PadRight($kwCol))$("llama.cpp + KoboldCPP".PadRight($descCol))43"
    Write-Host "    $("llama, gguf".PadRight($kwCol))$("llama.cpp (alias)".PadRight($descCol))43"
    Write-Host "    $("llm".PadRight($kwCol))$("LLM tools (Ollama)".PadRight($descCol))42"
    Write-Host "    $("kobold, koboldcpp".PadRight($kwCol))$("KoboldCPP (llama.cpp)".PadRight($descCol))43"
    Write-Host "    $("ollama-models".PadRight($kwCol))$("Ollama model pull only".PadRight($descCol))42"
    Write-Host "    $("llama-models".PadRight($kwCol))$("llama.cpp model picker only".PadRight($descCol))43"
    Write-Host "    $("ai-tools, local-ai".PadRight($kwCol))$("Ollama + llama.cpp".PadRight($descCol))42, 43"
    Write-Host "    $("ollama+llama".PadRight($kwCol))$("Ollama + llama.cpp".PadRight($descCol))42, 43"
    Write-Host "    $("ai-full, aifull".PadRight($kwCol))$("Python + libs + Ollama + llama.cpp".PadRight($descCol))05, 41, 42, 43"
    Write-Host ""
    Write-Host "    DevOps & Containers" -ForegroundColor $ThemePrimary
    Write-Host "    $("rust, cargo".PadRight($kwCol))$("Rust + Cargo".PadRight($descCol))44"
    Write-Host "    $("docker".PadRight($kwCol))$("Docker Desktop".PadRight($descCol))45"
    Write-Host "    $("kubernetes, k8s".PadRight($kwCol))$("Kubernetes tools".PadRight($descCol))46"
    Write-Host "    $("devops".PadRight($kwCol))$("Git + Docker + Kubernetes".PadRight($descCol))07, 45, 46"
    Write-Host "    $("container-dev".PadRight($kwCol))$("Docker + Kubernetes".PadRight($descCol))45, 46"
    Write-Host "    $("systems-dev".PadRight($kwCol))$("C++ + Rust".PadRight($descCol))09, 44"
    Write-Host ""
    Write-Host "    Remote installers (irm | iex)" -ForegroundColor $ThemePrimary
    Write-Host "    $("clean-code, cg, cc".PadRight($kwCol))$("Coding Guidelines v23".PadRight($descCol))remote"
    Write-Host "    $("code-guide".PadRight($kwCol))$("Coding Guidelines v23 (alias)".PadRight($descCol))remote"
    Write-Host "    $("coding-guidelines".PadRight($kwCol))$("Coding Guidelines v23 (alias)".PadRight($descCol))remote"
    Write-Host "    $("starship, ss".PadRight($kwCol))$("Starship cross-shell prompt".PadRight($descCol))remote"
    Write-Host "    $("starship-prompt".PadRight($kwCol))$("Starship (alias)".PadRight($descCol))remote"
    Write-Host "    $("oh-my-posh, omp, posh".PadRight($kwCol))$("Oh My Posh prompt theme".PadRight($descCol))remote"
    Write-Host "    $("ohmyposh".PadRight($kwCol))$("Oh My Posh (alias)".PadRight($descCol))remote"
    Write-Host "    $("scoop, sc".PadRight($kwCol))$("Scoop CLI installer".PadRight($descCol))remote"
    Write-Host "    $("scoop-installer".PadRight($kwCol))$("Scoop (alias)".PadRight($descCol))remote"
    Write-Host ""

    Write-Host "  Combo Shortcuts:" -ForegroundColor $ThemeAccent
    Write-Host ""
    Write-Host "    $("vscode+settings, vscode+s".PadRight($kwCol))$("VSCode + Settings Sync".PadRight($descCol))01, 11"
    Write-Host "    $("vscode+menu+settings, vms".PadRight($kwCol))$("VSCode + Menu Fix + Sync".PadRight($descCol))01, 10, 11"
    Write-Host "    $("git+desktop, git+gh".PadRight($kwCol))$("Git + GitHub Desktop".PadRight($descCol))07, 08"
    Write-Host "    $("node+pnpm".PadRight($kwCol))$("Node.js + pnpm".PadRight($descCol))03, 04"
    Write-Host "    $("frontend".PadRight($kwCol))$("VSCode + Node + pnpm + Sync".PadRight($descCol))01, 03, 04, 11"
    Write-Host "    $("backend".PadRight($kwCol))$("Python + Go + PHP + PG + .NET + Java".PadRight($descCol))05, 06, 16, 20, 39, 40"
    Write-Host "    $("web-dev, webdev".PadRight($kwCol))$("VSCode + Node + pnpm + Git + Sync".PadRight($descCol))01, 03, 04, 07, 11"
    Write-Host "    $("essentials".PadRight($kwCol))$("VSCode + Choco + Node + Git + Sync".PadRight($descCol))01, 02, 03, 07, 11"
    Write-Host ""
    Write-Host "    Python & Libraries" -ForegroundColor $ThemePrimary
    Write-Host "    $("pylibs".PadRight($kwCol))$("Python + all libraries".PadRight($descCol))05, 41"
    Write-Host "    $("python+libs, ml-dev".PadRight($kwCol))$("Python + all libraries".PadRight($descCol))05, 41"
    Write-Host "    $("python+jupyter".PadRight($kwCol))$("Python + all libraries".PadRight($descCol))05, 41"
    Write-Host "    $("pip+jupyter+libs".PadRight($kwCol))$("Python + all libraries".PadRight($descCol))05, 41"
    Write-Host "    $("jupyter+libs".PadRight($kwCol))$("Jupyter group only".PadRight($descCol))41"
    Write-Host "    $("data-science, datascience".PadRight($kwCol))$("Python + data/viz libs".PadRight($descCol))05, 41"
    Write-Host "    $("ai-dev, aidev".PadRight($kwCol))$("Python + ML libs".PadRight($descCol))05, 41"
    Write-Host "    $("deep-learning, ml-full".PadRight($kwCol))$("Python + ML libs".PadRight($descCol))05, 41"
    Write-Host ""
    Write-Host "    General" -ForegroundColor $ThemePrimary
    Write-Host "    $("full-stack, fullstack".PadRight($kwCol))$("Everything for full-stack dev".PadRight($descCol))01-09, 11, 16, 39, 40"
    Write-Host "    $("mobile-dev".PadRight($kwCol))$("Flutter mobile dev".PadRight($descCol))38"
    Write-Host "    $("data-dev".PadRight($kwCol))$("Postgres + Redis + DuckDB + DBeaver".PadRight($descCol))20, 24, 28, 32"
    Write-Host ""
    Write-Host "  Usage: " -NoNewline -ForegroundColor $ThemeAccent; Write-Host ".\run.ps1 install <keyword>[,<keyword>,...]"
    Write-Host ""
    }


# Levenshtein distance -- used to rank "did you mean" suggestions for unknown
# --exclude tokens. Pure PowerShell, no external deps. O(len(a) * len(b)).

function Show-AgyHelp {
    Write-Host ""
    Write-Host "  Antigravity (agy) -- Google Antigravity IDE & CLI Manager" -ForegroundColor $ThemeSecondary
    Write-Host "  ========================================================" -ForegroundColor $ThemeMuted
    Write-Host "  USAGE: " -ForegroundColor $ThemeAccent -NoNewline
    Write-Host ".\run.ps1 agy <action> [flags]" -ForegroundColor White
    Write-Host ""
    Write-Host "  ACTIONS:" -ForegroundColor $ThemeAccent
    Write-Host "    clear | clean       " -ForegroundColor Green -NoNewline
    Write-Host "Predict or apply conversation pruning & cache scrubbing" -ForegroundColor $ThemeMuted
    Write-Host "    cache clear         " -ForegroundColor Green -NoNewline
    Write-Host "Alias for 'agy clear' (prunes heavy conversations & clears app caches)" -ForegroundColor $ThemeMuted
    Write-Host "    cache-clear         " -ForegroundColor Green -NoNewline
    Write-Host "Alias for 'agy clear'" -ForegroundColor $ThemeMuted
    Write-Host "    predict             " -ForegroundColor Green -NoNewline
    Write-Host "Run in non-destructive prediction mode (default without -y)" -ForegroundColor $ThemeMuted
    Write-Host "    list-backups        " -ForegroundColor Green -NoNewline
    Write-Host "List all historical conversation pruning transactions" -ForegroundColor $ThemeMuted
    Write-Host "    undo [tx-id]        " -ForegroundColor Green -NoNewline
    Write-Host "Restore pruned conversations from 'latest' or a specific transaction ID" -ForegroundColor $ThemeMuted
    Write-Host "    install             " -ForegroundColor Green -NoNewline
    Write-Host "Install Antigravity IDE and CLI (agy)" -ForegroundColor $ThemeMuted
    Write-Host "    cli                 " -ForegroundColor Green -NoNewline
    Write-Host "Install Antigravity CLI only (agy)" -ForegroundColor $ThemeMuted
    Write-Host "    check               " -ForegroundColor Green -NoNewline
    Write-Host "Check Antigravity installation status" -ForegroundColor $ThemeMuted
    Write-Host "    uninstall           " -ForegroundColor Green -NoNewline
    Write-Host "Uninstall Antigravity IDE and CLI" -ForegroundColor $ThemeMuted
    Write-Host "    help                " -ForegroundColor Green -NoNewline
    Write-Host "Show this help screen" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "  FLAGS (for clear / clean / cache clear):" -ForegroundColor $ThemeAccent
    Write-Host "    --keep <N> | -k <N> | -k<N> | <N>  " -ForegroundColor Green -NoNewline
    Write-Host "Keep latest N conversations intact (default: all preserved, only heavy pruned)" -ForegroundColor $ThemeMuted
    Write-Host "    -y | --yes                         " -ForegroundColor Green -NoNewline
    Write-Host "Apply changes (without -y, runs safe prediction only)" -ForegroundColor $ThemeMuted
    Write-Host "    --kill                             " -ForegroundColor Green -NoNewline
    Write-Host "Terminate running Antigravity processes before clearing" -ForegroundColor $ThemeMuted
    Write-Host "    --threshold <KB> | -t <KB> | -t<KB> " -ForegroundColor Green -NoNewline
    Write-Host "Conversation size threshold in KB (default: 200 KB)" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "  EXAMPLES:" -ForegroundColor $ThemeAccent
    Write-Host "    .\run.ps1 agy clear                  # Preview cleanup savings without modifying files" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy cache clear -k1        # Preview mode keeping latest 1 conversation intact" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy cache clear            # Same as 'agy clear' (preview mode)" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy cache-clear            # Shorthand alias for cache clear" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy clear -k10 -y          # Apply: keep latest 10 conversations, scrub caches" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy cache clear -y --kill  # Kill running agy processes & scrub caches" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy undo latest            # Revert the last pruning transaction" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy list-backups           # View past backup transaction IDs" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy install                # Install Antigravity IDE & CLI" -ForegroundColor Green
    Write-Host "    .\run.ps1 clean-agy 10               # Root shortcut to prune keeping latest 10" -ForegroundColor Green
    Write-Host ""
    Write-Host "  STANDALONE CLEANERS:" -ForegroundColor $ThemeAccent
    Write-Host "    python scripts/os-ai-clean.py --check       # Preview brain & temp cache cleaner" -ForegroundColor Green
    Write-Host "    python scripts/os-ai-clean.py --clean-all   # Purge Antigravity brain & OS temp AI dumps" -ForegroundColor Green
    Write-Host "    .\run.ps1 os dev-clean                      # Clean developer tool caches (Go, npm, pip, cargo)" -ForegroundColor Green
    Write-Host ""
}


