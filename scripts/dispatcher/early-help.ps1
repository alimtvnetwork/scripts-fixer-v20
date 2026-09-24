<#
.SYNOPSIS
    Early help intercept and interactive help search REPL for root dispatcher.
#>

function script:_Parse-HelpOutFlags {
    param([string]$Filter)

    $outFile = $null; $format = $null
    if (-not $Filter) { return [pscustomobject]@{ Filter=""; OutFile=$null; Format=$null } }
    $termsRaw = @($Filter -split '[\s]+' | Where-Object { $_ })
    $kept = New-Object System.Collections.Generic.List[string]
    for ($i = 0; $i -lt $termsRaw.Count; $i++) {
        $t = "$($termsRaw[$i])"; $tl = $t.ToLower()
        $consumeNext = $false; $inlineVal = $null; $fmtHere = $null

        if     ($tl -eq "--out"  -or $tl -eq "-out")  { $consumeNext = $true; $fmtHere = "auto" }
        elseif ($tl -eq "--text" -or $tl -eq "-text") { $consumeNext = $true; $fmtHere = "text" }
        elseif ($tl -eq "--json" -or $tl -eq "-json") { $consumeNext = $true; $fmtHere = "json" }
        elseif ($tl -match '^--?out=(.+)$')  { $inlineVal = $Matches[1]; $fmtHere = "auto" }
        elseif ($tl -match '^--?text=(.+)$') { $inlineVal = $Matches[1]; $fmtHere = "text" }
        elseif ($tl -match '^--?json=(.+)$') { $inlineVal = $Matches[1]; $fmtHere = "json" }
        else { $kept.Add($t); continue }

        $val = $inlineVal
        if ($consumeNext -and ($i + 1) -lt $termsRaw.Count) {
            $val = "$($termsRaw[$i + 1])"; $i++
        }
        if ($val) {
            $outFile = $val
            if ($fmtHere -eq "auto") {
                $ext = [System.IO.Path]::GetExtension($val).ToLower()
                $format = if ($ext -eq ".json") { "json" } else { "text" }
            } else { $format = $fmtHere }
        }
    }
    return [pscustomobject]@{
        Filter  = ($kept -join ' ').Trim()
        OutFile = $outFile
        Format  = $format
    }
}

function script:_Read-HelpKeywordLine {
    param(
        [string]$PromptText = "  Search keyword (Tab to complete, Ctrl+C to cancel): ",
        [string[]]$Completions = @()
    )

    Write-Host ""
    Write-Host $PromptText -ForegroundColor $ThemeSecondary -NoNewline

    $isConsoleAvailable = $false
    try {
        if ([System.Console]::KeyAvailable -ne $null) { $isConsoleAvailable = $true }
    } catch { $isConsoleAvailable = $false }

    if (-not $isConsoleAvailable) {
        $line = [System.Console]::ReadLine()
        if ($null -eq $line) { return $null }
        return $line.Trim()
    }

    $buffer = New-Object System.Text.StringBuilder
    $lastCompletionPrefix = $null
    $completionIndex = -1
    $completionMatches = @()

    while ($true) {
        $key = [System.Console]::ReadKey($true)

        if ($key.Key -eq [System.ConsoleKey]::Enter) {
            Write-Host ""
            return $buffer.ToString().Trim()
        }

        if ($key.Key -eq [System.ConsoleKey]::Escape) {
            Write-Host ""
            return ""
        }

        if ($key.Key -eq [System.ConsoleKey]::Backspace) {
            if ($buffer.Length -gt 0) {
                $buffer.Remove($buffer.Length - 1, 1) | Out-Null
                [System.Console]::Write("`b `b")
            }
            $completionMatches = @()
            $completionIndex = -1
            continue
        }

        if ($key.Key -eq [System.ConsoleKey]::Tab) {
            if ($Completions.Count -gt 0) {
                $currentText = $buffer.ToString()
                $lastTokenMatch = [regex]::Match($currentText, '([^\s,]+)$')
                $prefix = if ($lastTokenMatch.Success) { $lastTokenMatch.Value } else { "" }
                $baseText = if ($lastTokenMatch.Success) {
                    $currentText.Substring(0, $lastTokenMatch.Index)
                } else {
                    $currentText
                }

                if ($completionMatches.Count -eq 0 -or $lastCompletionPrefix -ne $prefix) {
                    $lastCompletionPrefix = $prefix
                    $completionMatches = @($Completions | Where-Object {
                        $_.ToLower().StartsWith($prefix.ToLower())
                    })
                    $completionIndex = 0
                } else {
                    $completionIndex = ($completionIndex + 1) % $completionMatches.Count
                }

                if ($completionMatches.Count -gt 0) {
                    $chosen = $completionMatches[$completionIndex]
                    $newTotal = $baseText + $chosen
                    while ($buffer.Length -gt 0) {
                        [System.Console]::Write("`b `b")
                        $buffer.Remove($buffer.Length - 1, 1) | Out-Null
                    }
                    [void]$buffer.Append($newTotal)
                    [System.Console]::Write($newTotal)
                }
            }
            continue
        }

        $c = $key.KeyChar
        if ($c -ge [char]32) {
            [void]$buffer.Append($c)
            [System.Console]::Write($c)
            $completionMatches = @()
            $completionIndex = -1
        }
    }
}

function script:_Save-LastKeyword {
    param([string]$Filter)
    if ([string]::IsNullOrWhiteSpace($Filter)) { return }
    try {
        $f = Join-Path $RootDir ".resolved\help-last-keyword.json"
        $d = Split-Path -Parent $f
        if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
        ([pscustomobject]@{ keyword = $Filter.Trim(); savedAt = (Get-Date).ToString("o") } |
            ConvertTo-Json -Compress) | Set-Content -Path $f -Encoding UTF8 -Force
    } catch {
        Write-Host "  Note: could not write last keyword cache: $_" -ForegroundColor DarkGray
    }
}

function Invoke-EarlyHelpIntercept {
    param(
        [string]$Command,
        [string[]]$Install,
        [switch]$Help,
        [switch]$h,
        [int]$I
    )

    $_helpAliases = @("help", "--help", "-help", "/?", "?", "-?")
    $_earlyHelpFilter = $null
    $_isEarlyHelp = $false

    $_cmdLow = if ($Command) { $Command.Trim().ToLower() } else { "" }
    $_installList = @()
    if ($null -ne $Install) {
        $_installList = @($Install | Where-Object { $null -ne $_ -and "$_".Length -gt 0 })
    }

    if ($_cmdLow -in @('/run', '\run', 'run') -and $_installList.Count -ge 1) {
        $Command = "$($_installList[0])".Trim()
        $Install = if ($_installList.Count -gt 1) { @($_installList[1..($_installList.Count - 1)]) } else { @() }
        $_cmdLow = $Command.ToLower()
        $_installList = @($Install)
    }

    if ($_cmdLow -in $_helpAliases) {
        $_isEarlyHelp = $true
        if ($_installList.Count -gt 0) { $_earlyHelpFilter = ($_installList -join ' ').Trim() }
    } elseif ([string]::IsNullOrWhiteSpace($_cmdLow) -and $_installList.Count -gt 0 -and "$($_installList[0])".Trim().ToLower() -in $_helpAliases) {
        $_isEarlyHelp = $true
        $_rest = @($_installList | Select-Object -Skip 1)
        if ($_rest.Count -gt 0) { $_earlyHelpFilter = ($_rest -join ' ').Trim() }
    } elseif (($Help -or $h) -and -not $I -and ($_cmdLow -notin @("nginx", "os", "ssh", "menu", "vscode-folder", "git-tools", "agy", "antigravity", "clean-agy", "clear-agy"))) {
        $_isEarlyHelp = $true
        if ($_cmdLow -and ($_cmdLow -notin $_helpAliases)) {
            $_earlyHelpFilter = $Command.Trim()
            if ($_installList.Count -gt 0) {
                $_earlyHelpFilter = (@($_earlyHelpFilter) + $_installList -join ' ').Trim()
            }
        } elseif ($_installList.Count -gt 0) {
            $_earlyHelpFilter = ($_installList -join ' ').Trim()
        }
    }

    if (-not $_isEarlyHelp) {
        return
    }

    # ── List recommended help-filter keywords ────────────────────────
    $_isFilterList = $false
    if ($_earlyHelpFilter) {
        $_ftlist = $_earlyHelpFilter.Trim().ToLower()
        if ($_ftlist -in @("--list","-list","list","--filters","-filters","filters","--keywords","-keywords","keywords","--filter-list","filter-list")) {
            $_isFilterList = $true
        }
    }
    if ($_isFilterList) {
        $_records = & { Show-RootHelpRaw } 6>&1
        $_lines = New-Object System.Collections.Generic.List[string]
        $_buf = New-Object System.Text.StringBuilder
        foreach ($rec in $_records) {
            $msg = ""; $nl = $false
            if ($rec -is [System.Management.Automation.InformationRecord]) {
                $data = $rec.MessageData
                if ($data -is [System.Management.Automation.HostInformationMessage]) {
                    $msg = [string]$data.Message; $nl = [bool]$data.NoNewLine
                } else { $msg = [string]$data }
            } else { $msg = [string]$rec }
            [void]$_buf.Append($msg)
            if (-not $nl) { [void]$_lines.Add($_buf.ToString()); $_buf.Clear() }
        }
        $_filters = @(
            @{ K = "agy";           D = "Antigravity IDE & CLI cache, prune, and maintenance" },
            @{ K = "chrome";        D = "Google Chrome browser + extensions" },
            @{ K = "ext";           D = "Every Chrome extension installer/updater" },
            @{ K = "ext-url";       D = "Ad-hoc Chrome extension URL / ID examples" },
            @{ K = "ext-all";       D = "Install every extension in the registry" },
            @{ K = "vscode";        D = "VS Code install, settings sync, folder repair" },
            @{ K = "conemu";        D = "ConEmu install + right-click context menu" },
            @{ K = "menu";          D = "All right-click / Explorer context menus" },
            @{ K = "profile";       D = "Profile recipes (small-dev, alldev, etc.)" },
            @{ K = "install";       D = "Installation commands and shortcuts" },
            @{ K = "uninstall";     D = "Every uninstall / remove / rollback command" },
            @{ K = "self-update";   D = "Self-update the repo or git-tools" },
            @{ K = "settings";      D = "Settings export/sync across tools" },
            @{ K = "export";        D = "Export settings (npp, obs, wt, dbeaver)" },
            @{ K = "os";            D = "OS-level tweaks and debloating" },
            @{ K = "clean-dev";     D = "Clean dev tool caches (Go, npm, pip, etc.)" },
            @{ K = "path";          D = "Default dev directory commands" },
            @{ K = "models";        D = "Local LLM model management" },
            @{ K = "models-download"; D = "Download GGUF models directly" },
            @{ K = "download";      D = "Fast multi-part aria2c downloader" },
            @{ K = "url";           D = "Fast downloader by raw URL" },
            @{ K = "mariadb";       D = "MariaDB database engine commands" },
            @{ K = "mongodb";       D = "MongoDB database engine commands" },
            @{ K = "redis";         D = "Redis cache engine commands" },
            @{ K = "sqlite";        D = "SQLite database tools" },
            @{ K = "node";          D = "Node.js, npm, yarn, pnpm, bun runtimes" },
            @{ K = "python";        D = "Python runtime and pip libraries" },
            @{ K = "kubernetes";    D = "Kubernetes clusters, nodes, and kubectl" },
            @{ K = "java";          D = "OpenJDK Java runtime" },
            @{ K = "dotnet";        D = ".NET SDK and CLI runtimes" },
            @{ K = "rust";          D = "Rust toolchain (rustup, cargo)" },
            @{ K = "go";            D = "Go programming language" },
            @{ K = "php";           D = "PHP runtime" },
            @{ K = "obs";           D = "OBS Studio screen recorder" },
            @{ K = "dbeaver";       D = "DBeaver universal database tool" },
            @{ K = "ollama";        D = "Ollama local LLM server" },
            @{ K = "user";          D = "User-specific configuration and PATH" },
            @{ K = "ssh";           D = "SSH keys, profiles, and ledger commands" }
        )

        Write-Host ""
        Write-Host "  Recommended Help Filters" -ForegroundColor $ThemeSecondary
        Write-Host "  ========================" -ForegroundColor $ThemeMuted
        Write-Host "  Use these with '.\run.ps1 help <filter>' to view only matching commands." -ForegroundColor $ThemeMuted
        Write-Host ""

        $shownCount = 0
        foreach ($f in $_filters) {
            $mCount = 0
            foreach ($line in $_lines) {
                if ($line.ToLower().Contains($f.K.ToLower())) { $mCount++ }
            }
            if ($mCount -gt 0) {
                $shownCount++
                $kStr = "  " + $f.K.PadRight(18)
                Write-Host $kStr -ForegroundColor $ThemeAccent -NoNewline
                Write-Host " (" -ForegroundColor $ThemeMuted -NoNewline
                Write-Host "$mCount".PadLeft(3) -ForegroundColor White -NoNewline
                Write-Host " matches)  " -ForegroundColor $ThemeMuted -NoNewline
                Write-Host $f.D -ForegroundColor White
            }
        }

        Write-Host ""
        Write-Host "  Showing $shownCount active filter(s)." -ForegroundColor $ThemePrimary
        Write-Host ""
        exit 0
    }

    # ── Self-test mode ────────────────────────────────────────────────
    $_isSelfTest = $false
    if ($_earlyHelpFilter) {
        $_ftlower = $_earlyHelpFilter.Trim().ToLower()
        if ($_ftlower -in @("--self-test","-self-test","self-test","selftest","--test","-test","test")) {
            $_isSelfTest = $true
        }
    }
    if ($_isSelfTest) {
        Write-Host ""
        Write-Host "  Help filter -- case-insensitivity self-test" -ForegroundColor $ThemeSecondary
        Write-Host "  ==========================================" -ForegroundColor $ThemeMuted
        Write-Host ""

        $_records = & { Show-RootHelpRaw } 6>&1

        function _Get-HelpLines {
            param($Records)
            $buf = New-Object System.Collections.Generic.List[string]
            $cur = New-Object System.Text.StringBuilder
            foreach ($rec in $Records) {
                $msg = ""; $nl = $false
                if ($rec -is [System.Management.Automation.InformationRecord]) {
                    $data = $rec.MessageData
                    if ($data -is [System.Management.Automation.HostInformationMessage]) {
                        $msg = [string]$data.Message; $nl = [bool]$data.NoNewLine
                    } else { $msg = [string]$data }
                } else { $msg = [string]$rec }
                [void]$cur.Append($msg)
                if (-not $nl) { [void]$buf.Add($cur.ToString()); $cur.Clear() }
            }
            return $buf
        }

        function _Count-Matches {
            param($Lines, [string[]]$Needles)
            $n = 0
            foreach ($line in $Lines) {
                $low = $line.ToLower()
                $all = $true
                foreach ($needle in $Needles) {
                    if (-not $low.Contains($needle)) { $all = $false; break }
                }
                if ($all) { $n++ }
            }
            return $n
        }

        $_lines = _Get-HelpLines -Records $_records

        $_cases = @(
            @{ Label = "single keyword"; Variants = @("chrome","CHROME","Chrome","ChRoMe");        Min = 1 },
            @{ Label = "multi-word AND"; Variants = @("vscode uninstall","VSCODE UNINSTALL","VsCode UnInstall"); Min = 1 },
            @{ Label = "comma-split";    Variants = @("chrome,ext","CHROME,EXT","Chrome, Ext");     Min = 1 },
            @{ Label = "another keyword";Variants = @("conemu","CONEMU","ConEmu");                  Min = 1 }
        )

        $_pass = 0; $_fail = 0
        foreach ($c in $_cases) {
            $counts = @()
            foreach ($v in $c.Variants) {
                $needles = @($v.ToLower() -split '[\s,]+' | Where-Object { $_ })
                $counts += (_Count-Matches -Lines $_lines -Needles $needles)
            }
            $allEqual = (($counts | Select-Object -Unique).Count -eq 1)
            $minOk    = ($counts[0] -ge $c.Min)
            $ok       = $allEqual -and $minOk

            if ($ok) {
                $_pass++
                Write-Host ("  [ PASS ] {0,-18} -> {1} match(es) across {2} casing(s): {3}" -f `
                    $c.Label, $counts[0], $c.Variants.Count, ($c.Variants -join ' | ')) -ForegroundColor Green
            } else {
                $_fail++
                Write-Host ("  [ FAIL ] {0,-18} -> counts: [{1}] (variants: {2})" -f `
                    $c.Label, ($counts -join ', '), ($c.Variants -join ' | ')) -ForegroundColor $ThemeError
            }
        }

        Write-Host ""
        if ($_fail -eq 0) {
            Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
            Write-Host "All $_pass case(s) passed -- filter IS case-insensitive."
        } else {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "$_fail of $($_pass + $_fail) case(s) failed."
            exit 1
        }
        Write-Host ""
        exit 0
    }

    # ── Parse file-redirect flags from initial invocation ─────────────
    $_initialParsed   = _Parse-HelpOutFlags -Filter $_earlyHelpFilter
    $_earlyHelpFilter = $_initialParsed.Filter
    $_helpOutFile     = $_initialParsed.OutFile
    $_helpFormat      = $_initialParsed.Format

    _Save-LastKeyword -Filter $_earlyHelpFilter

    $_showArgs = @{ Filter = $_earlyHelpFilter }
    if ($_helpOutFile) {
        $_showArgs.OutFile = $_helpOutFile
        if ($_helpFormat) { $_showArgs.Format = $_helpFormat }
    }
    Show-RootHelp @_showArgs

    if ($_helpOutFile) {
        exit 0
    }

    # ── Multi-search interactive loop ─────────────────────────────────
    $isInteractiveSession = $false
    try {
        if ([System.Environment]::UserInteractive -and [System.Console]::KeyAvailable -ne $null) {
            $isInteractiveSession = $true
        }
    } catch {
        $isInteractiveSession = $false
    }

    if ($isInteractiveSession) {
        $_completionPool = @(
            'agy','clear-agy','clean-agy',
            'chrome','chrome-fix-ai','fix-ai','chrome-profile-copy',
            'menu','context-menu','profile','install','uninstall',
            'self-update','settings','export','os','clean-dev',
            'path','models','models-download','download','url',
            'mariadb','mongodb','redis','sqlite','node','python',
            'kubernetes','java','dotnet','rust','go','php','obs',
            'dbeaver','ollama','user','ssh',
            'exit','quit',
            '--out','--json','--text','--list','--self-test'
        ) | Sort-Object -Unique

        while ($true) {
            $typed = _Read-HelpKeywordLine -Completions $_completionPool
            if ($null -eq $typed) { break }
            if ([string]::IsNullOrWhiteSpace($typed)) {
                Write-Host "  Exiting help search." -ForegroundColor $ThemeMuted
                Write-Host ""
                break
            }

            $lowTyped = $typed.Trim().ToLower()
            if ($lowTyped -in @("exit", "quit", "q", ":q")) {
                Write-Host "  Exiting help search." -ForegroundColor $ThemeMuted
                Write-Host ""
                break
            }

            $reparsed = _Parse-HelpOutFlags -Filter $typed
            $_earlyHelpFilter = $reparsed.Filter
            $_helpOutFile     = $reparsed.OutFile
            $_helpFormat      = $reparsed.Format

            _Save-LastKeyword -Filter $_earlyHelpFilter

            $_showArgs = @{ Filter = $_earlyHelpFilter }
            if ($_helpOutFile) {
                $_showArgs.OutFile = $_helpOutFile
                if ($_helpFormat) { $_showArgs.Format = $_helpFormat }
            }
            Show-RootHelp @_showArgs
        }
    }

    exit 0
}
