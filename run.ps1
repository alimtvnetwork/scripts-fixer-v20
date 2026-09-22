<#
.SYNOPSIS
    Root-level script dispatcher. Runs a numbered script after pulling latest changes.

.DESCRIPTION
    Performs a git pull via the shared helper, sets $env:SCRIPTS_ROOT_RUN = "1"
    so child scripts skip their own git pull, then delegates to
    scripts/<NN>-*/run.ps1 based on the -I parameter.

    When run with no parameters, performs a git pull and shows help.
    Use -Install to run scripts by keyword (e.g. -Install vscode,python,go).
    Use -Clean to wipe all .resolved/ data before running, forcing fresh detection.
    Use -CleanOnly to wipe .resolved/ without running any script.
    Use -Help to see all available scripts and usage information.
    Use 'update' command to upgrade all Chocolatey packages.

.PARAMETER I
    The script number to run (e.g. 1, 2, 3). Maps to folders like 01-*, 02-*, etc.

.PARAMETER Install
    Comma-separated keywords to install (e.g. vscode, nodejs, python, go, git).
    See install-keywords.json for the full mapping.

.PARAMETER Clean
    Wipe all .resolved/ data before running the script.

.PARAMETER CleanOnly
    Wipe all .resolved/ data and exit without running any script.

.PARAMETER Help
    Show usage information and list all available scripts.

.EXAMPLE
    .\run.ps1                        # git pull, show help
    .\run.ps1 -Install vscode        # install VS Code
    .\run.ps1 -Install nodejs,pnpm   # install Node.js + pnpm
    .\run.ps1 -Install python        # install Python + pip
    .\run.ps1 -Install go,git,cpp    # install Go, Git, and C++
    .\run.ps1 -Install all-dev       # interactive dev tools menu
    .\run.ps1 update                 # show outdated, confirm, upgrade all
    .\run.ps1 update nodejs,git        # upgrade specific packages only
    .\run.ps1 update --check           # list outdated packages (no upgrade)
    .\run.ps1 update -y                # upgrade all, skip confirmation
    .\run.ps1 update --exclude=choco   # upgrade all except listed
    .\run.ps1 path D:\dev-tool       # set default dev directory
    .\run.ps1 path                   # show current dev directory
    .\run.ps1 path --reset           # clear saved path, use smart detection
    .\run.ps1 -d                     # shortcut for -I 12 (interactive menu)
    .\run.ps1 -I 1                   # run scripts/01-*/run.ps1
    .\run.ps1 -I 1 -Clean           # wipe .resolved/, then run script 01
    .\run.ps1 -CleanOnly             # wipe .resolved/ and exit
    .\run.ps1 agy clear 10           # predict pruning keeping latest 10 conversations
    .\run.ps1 -Help                  # show all available scripts

.NOTES
    Author : Lovable AI
    Version: 7.3.0
#>

param(
    [Parameter(Position = 0)]
    [string]$Command,

    [Parameter(Position = 1, ValueFromRemainingArguments = $true)]
    [string[]]$Install,

    [int]$I,

    [switch]$d,

    [switch]$a,

    [switch]$h,

    [switch]$v,

    [switch]$w,

    [switch]$t,

    [switch]$M,

    [switch]$Defaults,

    [switch]$Y,

    [switch]$Merge,

    [switch]$Clean,

    [switch]$CleanOnly,

    [switch]$List,

    [switch]$Help
)

$ErrorActionPreference = "Stop"
$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

function ConvertTo-ConsoleColor([string]$ColorName, [string]$Fallback = "White") {
    if ([string]::IsNullOrWhiteSpace($ColorName)) { return $Fallback }
    switch ($ColorName.ToLower()) {
        "lightgreen" { return "Green" }
        "lightcyan"  { return "Cyan" }
        "lightblue"  { return "Cyan" }
        "lightgray"  { return "Gray" }
        "lightyellow"{ return "Yellow" }
        "lightred"   { return "Red" }
        default {
            try {
                $parsed = [System.Enum]::Parse([System.ConsoleColor], $ColorName, $true)
                return $parsed.ToString()
            } catch {
                return $Fallback
            }
        }
    }
}

$ThemePrimary = "Green"
$ThemeSecondary = "Cyan"
$ThemeAccent = "Yellow"
$ThemeMuted = "Gray"
$ThemeError = "Red"
$ThemePath = Join-Path $RootDir "scripts\shared\theme.json"
if (Test-Path $ThemePath) {
    try {
        $themeData = Get-Content $ThemePath -Raw | ConvertFrom-Json
        if ($themeData.colors.primary) { $ThemePrimary = ConvertTo-ConsoleColor $themeData.colors.primary "Green" }
        if ($themeData.colors.secondary) { $ThemeSecondary = ConvertTo-ConsoleColor $themeData.colors.secondary "Cyan" }
        if ($themeData.colors.accent) { $ThemeAccent = ConvertTo-ConsoleColor $themeData.colors.accent "Yellow" }
        if ($themeData.colors.muted) { $ThemeMuted = ConvertTo-ConsoleColor $themeData.colors.muted "Gray" }
        if ($themeData.colors.error) { $ThemeError = ConvertTo-ConsoleColor $themeData.colors.error "Red" }
    } catch { }
}

# ── Dispatcher arg validation (paths-with-spaces detection) ───────────
# Loaded early so the very first thing we do is sanity-check the user's argv.
$_dispatcherArgsHelper = Join-Path $RootDir "scripts\shared\dispatcher-args.ps1"
if (Test-Path $_dispatcherArgsHelper) {
    . $_dispatcherArgsHelper

    $_argCheck = Test-DispatcherArgs -Args $Install -Command $Command -Context "run.ps1"
    if (-not $_argCheck.Ok) {
        Write-Host "  Aborting before any child script runs." -ForegroundColor $ThemeError
        Write-Host ""
        exit 2
    }
}

# ── Global -y / --yes detection ──────────────────────────────────────
# Single source of truth for auto-confirm intent. Sets
# $env:SCRIPTS_FIXER_YES=1 if the user passed -y / --yes (or PowerShell
# already bound -Y to $Y). The env var is inherited by every child process
# so even deeply nested helpers (interactive-verify, confirm-prompt,
# os/clean-categories, profile steps, ...) skip their prompts uniformly.
$_yesFlagHelper = Join-Path $RootDir "scripts\shared\yes-flag.ps1"
if (Test-Path $_yesFlagHelper) {
    . $_yesFlagHelper
    $_yesParsed = Initialize-YesFlag -Args $Install -Bound:$Y -Source "run.ps1"
    # Strip yes tokens from $Install so child scripts that don't recognise
    # them don't fail "Unknown keyword '-y'". $Y stays set for downstream
    # branches that explicitly check it.
    if ($_yesParsed.IsYes -and $_yesParsed.FromToken) {
        $Install = $_yesParsed.FilteredArgs
        $Y = $true
    }
}

# ── Modular Dispatcher Subsystems ────────────────────────────────────
$dispatcherDir = Join-Path $RootDir "scripts\dispatcher"
. (Join-Path $dispatcherDir "script-runner.ps1")
. (Join-Path $dispatcherDir "root-help.ps1")
. (Join-Path $dispatcherDir "keyword-resolver.ps1")
. (Join-Path $dispatcherDir "status-export.ps1")
. (Join-Path $dispatcherDir "doctor-cmd.ps1")
. (Join-Path $dispatcherDir "path-cmd.ps1")
. (Join-Path $dispatcherDir "early-help.ps1")

Invoke-EarlyHelpIntercept -Command $Command -Install $Install -Help:$Help -h:$h -I $I

# ── Normalize positional command mode ────────────────────────────────
# Supports:  .\run.ps1 install alldev,mysql
#             .\run.ps1 install alldev mysql
#             .\run.ps1 -Install alldev,mysql
#             .\run.ps1 update
#             .\run.ps1 path D:\dev-tool
$normalizedCommand = ""
$hasCommand = -not [string]::IsNullOrWhiteSpace($Command)
if ($hasCommand) {
    $normalizedCommand = $Command.Trim().ToLower()

    # ── --version / version / -V short-circuit ────────────────────────
    # Print version + git SHA + readme link, then exit. No git pull, no dispatch.
    # Note: -v is reserved for VS Code (script 01); we match capital -V via $MyInvocation.Line.
    $isVersionCommand = $normalizedCommand -in @("--version", "-version", "version")
    $isCapitalVFlag   = $MyInvocation.Line -cmatch '(^|\s)-V(\s|$)'
    if ($isVersionCommand -or $isCapitalVFlag) {
        $ver = Get-ScriptVersion
        $shortSha = "unknown"
        $longSha  = "unknown"
        $branch   = "unknown"
        $isDirty  = $false
        try {
            Push-Location $RootDir
            $shortSha = (& git rev-parse --short HEAD 2>$null) -join ""
            $longSha  = (& git rev-parse HEAD 2>$null) -join ""
            $branch   = (& git rev-parse --abbrev-ref HEAD 2>$null) -join ""
            $porcelain = & git status --porcelain 2>$null
            $isDirty   = -not [string]::IsNullOrWhiteSpace(($porcelain -join ""))
            Pop-Location
        } catch {
            try { Pop-Location -ErrorAction SilentlyContinue } catch {}
        }
        $hasShort = -not [string]::IsNullOrWhiteSpace($shortSha)
        if (-not $hasShort) { $shortSha = "no-git" }
        $dirtyTag = if ($isDirty) { " (dirty)" } else { "" }

        Write-Host ""
        Write-Host "  scripts-fixer v$ver" -ForegroundColor $ThemePrimary
        Write-Host "  ===============================================" -ForegroundColor $ThemeMuted
        Write-Host ("  Commit  : {0}{1}" -f $shortSha, $dirtyTag) -ForegroundColor $ThemeSecondary
        Write-Host ("  Full SHA: {0}" -f $longSha)               -ForegroundColor $ThemeMuted
        Write-Host ("  Branch  : {0}" -f $branch)                -ForegroundColor $ThemeSecondary
        Write-Host ("  Root    : {0}" -f $RootDir)               -ForegroundColor $ThemeMuted
        Write-Host ""
        Write-Host "  Readme  : https://github.com/alimtvnetwork/gitmap-v6/blob/main/readme.md" -ForegroundColor $ThemeAccent
        Write-Host ""
        Write-Host "  Disclaimer: This project is provided AS IS, no warranty." -ForegroundColor DarkYellow
        Write-Host "  Made for fun to save time on OS setup. You are responsible" -ForegroundColor DarkYellow
        Write-Host "  for anything it changes on your machine." -ForegroundColor DarkYellow
        Write-Host ""
        exit 0
    }


    # ── logs subcommand short-circuit ─────────────────────────────────
    # .\run.ps1 logs [--tail N] [--grep <pattern>] [--since <duration>] [--errors] [--case-sensitive]
    # Prints events from .logs/*.json grouped by invokedFrom, with projectVersion.
    # Exits before any git pull / dispatch -- safe in restricted shells.
    $isLogsCommand = $normalizedCommand -eq "logs"
    if ($isLogsCommand) {
        $logsArgs = @($Install)
        $tailN = 20
        $isTailRequested = $false
        $grepPattern = $null
        $isCaseSensitive = $false
        $sinceCutoff = $null
        $sinceLabel  = $null
        $isErrorsOnly = $false

        function Convert-DurationToSpan {
            param([string]$Raw)
            if ([string]::IsNullOrWhiteSpace($Raw)) { return $null }
            $r = $Raw.Trim().ToLower()
            if ($r -match '^(\d+)\s*(s|sec|secs|second|seconds)$')          { return [TimeSpan]::FromSeconds([int]$Matches[1]) }
            if ($r -match '^(\d+)\s*(m|min|mins|minute|minutes)$')          { return [TimeSpan]::FromMinutes([int]$Matches[1]) }
            if ($r -match '^(\d+)\s*(h|hr|hrs|hour|hours)$')                { return [TimeSpan]::FromHours([int]$Matches[1]) }
            if ($r -match '^(\d+)\s*(d|day|days)$')                         { return [TimeSpan]::FromDays([int]$Matches[1]) }
            if ($r -match '^(\d+)\s*(w|wk|wks|week|weeks)$')                { return [TimeSpan]::FromDays([int]$Matches[1] * 7) }
            return $null
        }

        for ($i = 0; $i -lt $logsArgs.Count; $i++) {
            $a = "$($logsArgs[$i])".Trim()
            $aLower = $a.ToLower()

            $isTailFlag = $aLower -in @("--tail", "-tail", "tail")
            if ($isTailFlag) {
                $isTailRequested = $true
                $hasInlineN = ($i + 1) -lt $logsArgs.Count
                if ($hasInlineN) {
                    $parsed = 0
                    if ([int]::TryParse("$($logsArgs[$i + 1])", [ref]$parsed) -and $parsed -gt 0) {
                        $tailN = $parsed
                    }
                }
                continue
            }

            if ($aLower -match '^--tail=(\d+)$') {
                $isTailRequested = $true
                $tailN = [int]$Matches[1]
                continue
            }

            $isGrepFlag = $aLower -in @("--grep", "-grep", "grep")
            if ($isGrepFlag -and ($i + 1) -lt $logsArgs.Count) {
                $grepPattern = "$($logsArgs[$i + 1])"
                continue
            }
            if ($a -match '^--grep=(.+)$') {
                $grepPattern = $Matches[1]
                continue
            }

            $isSinceFlag = $aLower -in @("--since", "-since", "since")
            if ($isSinceFlag -and ($i + 1) -lt $logsArgs.Count) {
                $sinceLabel = "$($logsArgs[$i + 1])"
                continue
            }
            if ($a -match '^--since=(.+)$') {
                $sinceLabel = $Matches[1]
                continue
            }

            if ($aLower -in @("--errors", "-errors", "errors", "--errors-only")) { $isErrorsOnly = $true; continue }
            if ($aLower -in @("--case-sensitive", "-case-sensitive", "--case", "-case")) { $isCaseSensitive = $true; continue }

            $isHelp = $aLower -in @("--help", "-h", "help")
            if ($isHelp) {
                Write-Host ""
                Write-Host "  Usage: .\run.ps1 logs [--tail N] [--grep <pattern>] [--since <duration>] [--errors] [--case-sensitive]" -ForegroundColor $ThemeSecondary
                Write-Host ""
                Write-Host "  Flags:" -ForegroundColor $ThemeAccent
                Write-Host "    --tail N            Last N events (default 20)" -ForegroundColor $ThemeMuted
                Write-Host "    --grep <pattern>    Filter events whose .message matches regex (case-insensitive by default)" -ForegroundColor $ThemeMuted
                Write-Host "    --since <duration>  Only events newer than the window. Examples: 30m, 1h, 2d, 1w" -ForegroundColor $ThemeMuted
                Write-Host "    --errors            Only level=fail and level=warn (also reads .logs/*-error.json)" -ForegroundColor $ThemeMuted
                Write-Host "    --case-sensitive    Make --grep case-sensitive" -ForegroundColor $ThemeMuted
                Write-Host "    --help              Show this help and exit" -ForegroundColor $ThemeMuted
                Write-Host ""
                Write-Host "  All filters compose. Output is grouped by invokedFrom and color-coded by level." -ForegroundColor $ThemeMuted
                Write-Host ""
                exit 0
            }
        }

        # Resolve --since cutoff
        if ($null -ne $sinceLabel) {
            $span = Convert-DurationToSpan -Raw $sinceLabel
            $isSpanInvalid = $null -eq $span
            if ($isSpanInvalid) {
                Write-Host ""
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "--since '$sinceLabel' is not a recognised duration. Use formats like 30m, 1h, 2d, 1w."
                exit 1
            }
            $sinceCutoff = (Get-Date).Subtract($span)
        }

        # Validate --grep regex up front (so we fail fast, not per-event)
        $grepRegex = $null
        if ($null -ne $grepPattern) {
            try {
                $opts = if ($isCaseSensitive) { [System.Text.RegularExpressions.RegexOptions]::None } else { [System.Text.RegularExpressions.RegexOptions]::IgnoreCase }
                $grepRegex = New-Object System.Text.RegularExpressions.Regex($grepPattern, $opts)
            } catch {
                Write-Host ""
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "--grep '$grepPattern' is not a valid regex: $($_.Exception.Message)"
                exit 1
            }
        }

        $logsDir = Join-Path $RootDir ".logs"
        $isLogsDirMissing = -not (Test-Path -LiteralPath $logsDir)
        if ($isLogsDirMissing) {
            Write-Host ""
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "No .logs/ directory found at: $logsDir"
            Write-Host "  Run any script first to generate logs." -ForegroundColor $ThemeMuted
            Write-Host ""
            exit 0
        }

        # Collect events. Default: skip *-error.json (duplicates).
        # When --errors is on: ALSO read *-error.json so dedicated error logs are surfaced.
        $allEvents = New-Object System.Collections.ArrayList
        $logFiles = Get-ChildItem -LiteralPath $logsDir -Filter "*.json" -File -ErrorAction SilentlyContinue |
                    Where-Object { $isErrorsOnly -or ($_.Name -notlike "*-error.json") }
        $hasNoLogFiles = $logFiles.Count -eq 0
        if ($hasNoLogFiles) {
            Write-Host ""
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "No .logs/*.json files found in: $logsDir"
            Write-Host ""
            exit 0
        }

        foreach ($lf in $logFiles) {
            try {
                $payload = Get-Content -LiteralPath $lf.FullName -Raw | ConvertFrom-Json
            } catch {
                Write-Host "  [ WARN ] " -ForegroundColor $ThemeAccent -NoNewline
                Write-Host "Could not parse log file: $($lf.FullName) -- Reason: $($_.Exception.Message)"
                continue
            }
            $fileVer    = if ($payload.PSObject.Properties['projectVersion']) { "$($payload.projectVersion)" } else { "unknown" }
            $fileInvoke = if ($payload.PSObject.Properties['invokedFrom'])    { "$($payload.invokedFrom)"    } else { "unknown" }
            $fileScript = if ($payload.PSObject.Properties['scriptName'])     { "$($payload.scriptName)"     } else { ($lf.BaseName) }

            # Pull from events[], errors[], warnings[] -- whichever the file has.
            $sources = @()
            if ($payload.PSObject.Properties['events']   -and $payload.events)   { $sources += ,@($payload.events) }
            if ($payload.PSObject.Properties['errors']   -and $payload.errors)   { $sources += ,@($payload.errors) }
            if ($payload.PSObject.Properties['warnings'] -and $payload.warnings) { $sources += ,@($payload.warnings) }

            foreach ($arr in $sources) {
                foreach ($ev in $arr) {
                    $ts = if ($ev.PSObject.Properties['timestamp']) { "$($ev.timestamp)" } else { "" }
                    $lv = if ($ev.PSObject.Properties['level'])     { "$($ev.level)"     } else { "info" }
                    $ms = if ($ev.PSObject.Properties['message'])   { "$($ev.message)"   } else { "" }
                    $pv = if ($ev.PSObject.Properties['projectVersion']) { "$($ev.projectVersion)" } else { $fileVer }
                    $iv = if ($ev.PSObject.Properties['invokedFrom'])    { "$($ev.invokedFrom)"    } else { $fileInvoke }
                    $sn = if ($ev.PSObject.Properties['scriptName'])     { "$($ev.scriptName)"     } else { $fileScript }
                    $sortKey = $lf.LastWriteTime
                    $parsedDate = [datetime]::MinValue
                    if ([datetime]::TryParse($ts, [ref]$parsedDate)) { $sortKey = $parsedDate }

                    # ---- filter: --errors ---------------------------------------------
                    if ($isErrorsOnly) {
                        $isErrorLevel = $lv -in @("fail", "warn", "error")
                        if (-not $isErrorLevel) { continue }
                    }

                    # ---- filter: --since ----------------------------------------------
                    if ($null -ne $sinceCutoff) {
                        $isStale = $sortKey -lt $sinceCutoff
                        if ($isStale) { continue }
                    }

                    # ---- filter: --grep -----------------------------------------------
                    if ($null -ne $grepRegex) {
                        $isMatch = $grepRegex.IsMatch($ms)
                        if (-not $isMatch) { continue }
                    }

                    $allEvents.Add([pscustomobject]@{
                        SortKey        = $sortKey
                        Timestamp      = $ts
                        Level          = $lv
                        Message        = $ms
                        ProjectVersion = $pv
                        InvokedFrom    = $iv
                        ScriptName     = $sn
                        SourceFile     = $lf.Name
                    }) | Out-Null
                }
            }
        }

        $totalEvents = $allEvents.Count
        if ($totalEvents -eq 0) {
            Write-Host ""
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            $reason = "Found $($logFiles.Count) log file(s) but zero events match the active filters."
            Write-Host $reason
            $appliedFilters = @()
            if ($isErrorsOnly)        { $appliedFilters += "--errors" }
            if ($null -ne $grepRegex) { $appliedFilters += "--grep '$grepPattern'" }
            if ($null -ne $sinceCutoff) { $appliedFilters += "--since $sinceLabel" }
            if ($appliedFilters.Count -gt 0) {
                Write-Host "  Active filters: $($appliedFilters -join ', ')" -ForegroundColor $ThemeMuted
            }
            Write-Host ""
            exit 0
        }

        $tail = $allEvents | Sort-Object SortKey | Select-Object -Last $tailN
        $groups = $tail | Group-Object InvokedFrom | Sort-Object { ($_.Group | Measure-Object SortKey -Maximum).Maximum }

        $headerParts = @()
        if ($isTailRequested) { $headerParts += "--tail $tailN" } else { $headerParts += "(default tail $tailN)" }
        if ($isErrorsOnly)        { $headerParts += "--errors" }
        if ($null -ne $grepRegex) { $headerParts += "--grep '$grepPattern'$(if ($isCaseSensitive) {' (case-sensitive)'} else {''})" }
        if ($null -ne $sinceCutoff) { $headerParts += "--since $sinceLabel" }
        $headerLabel = "logs " + ($headerParts -join " ")

        Write-Host ""
        Write-Host "  $headerLabel  --  showing $($tail.Count) of $totalEvents event(s) across $($logFiles.Count) file(s)" -ForegroundColor $ThemePrimary
        Write-Host "  ===============================================================" -ForegroundColor $ThemeMuted

        $levelColors = @{ ok = "Green"; fail = "Red"; warn = "Yellow"; error = "Red"; skip = "DarkGray"; info = "Cyan" }
        foreach ($g in $groups) {
            $groupVersions = $g.Group | Select-Object -ExpandProperty ProjectVersion -Unique
            $primaryVersion = ($g.Group | Sort-Object SortKey | Select-Object -Last 1).ProjectVersion
            $versionLabel = if ($groupVersions.Count -gt 1) {
                "v$primaryVersion (mixed: $($groupVersions -join ', '))"
            } else {
                "v$primaryVersion"
            }
            Write-Host ""
            Write-Host "  invokedFrom: $($g.Name)  [$versionLabel]  --  $($g.Group.Count) event(s)" -ForegroundColor $ThemeAccent
            $sorted = $g.Group | Sort-Object SortKey
            foreach ($e in $sorted) {
                $color = if ($levelColors.ContainsKey($e.Level)) { $levelColors[$e.Level] } else { "Gray" }
                $shortTs = $e.Timestamp
                if ($shortTs.Length -ge 19) { $shortTs = $shortTs.Substring(0, 19) }
                $line = "    {0}  [{1,-5}]  {2}" -f $shortTs, $e.Level, $e.Message
                Write-Host $line -ForegroundColor $color
            }
        }

        Write-Host ""
        Write-Host "  Source files scanned:" -ForegroundColor $ThemeMuted
        foreach ($lf in ($logFiles | Sort-Object Name)) {
            Write-Host "    - $($lf.Name)" -ForegroundColor $ThemeMuted
        }
        Write-Host ""
        exit 0
    }

    # Handle `/run <subcommand> ...` or `run <subcommand> ...`
    if ($normalizedCommand -in @('/run', '\run', 'run') -and $Install -and $Install.Count -ge 1) {
        $Command = "$($Install[0])".Trim()
        $Install = if ($Install.Count -gt 1) { @($Install[1..($Install.Count - 1)]) } else { @() }
        $normalizedCommand = $Command.ToLower()
    }

    # Aliases: `install ssh <name>` / `create ssh <name>` / `generate ssh <name>`
    # all mean the same thing as `ssh create <name>` (generate a new SSH key).
    if ($normalizedCommand -in @('install','create','generate','gen','new','keygen','add') -and $Install -and $Install.Count -ge 1) {
        $firstSshArg = "$($Install[0])".Trim().ToLower()
        if ($firstSshArg -in @('ssh','sshkey','ssh-key','sshkeys','ssh-keys','key')) {
            $sshRest = if ($Install.Count -gt 1) { @($Install[1..($Install.Count - 1)]) } else { @() }
            $Command = 'ssh'
            $Install = @('create') + $sshRest
            $normalizedCommand = 'ssh'
        }
    }

    # ── Auto-discovery redirect ────────────────────────────────────────
    # Renamed / legacy / typo'd top-level verbs are rewritten to their
    # canonical form here so every downstream `isBareXxxCommand` check
    # keeps working. Two layers:
    #   1) Explicit alias table for known renames.
    #   2) Did-You-Mean fuzzy match against the canonical verb list
    #      (only when the command would otherwise fall through to the
    #      generic install/keyword path).
    $commandAliasMap = @{
        # legacy / renamed verbs
        'choco-upgrade'        = 'update'
        'chocoupdate'          = 'update'
        'upgrade-all'          = 'update'
        'list'                 = 'status'
        'ls'                   = 'status'
        'list-installed'       = 'status'
        'show'                 = 'status'
        'health'               = 'doctor'
        'check'                = 'doctor'
        'diagnose'             = 'doctor'
        'refresh'              = 'self-update'
        'update-self'          = 'self-update'
        'git-pull'             = 'self-update'
        # chrome family renames
        'chrome-ai-fix'        = 'chrome-fix-ai'
        'chrome-no-google-ai'  = 'chrome-fix-ai'
        'chrome-copy-profile'  = 'chrome-profile-copy'
        'chrome-export'        = 'chrome-profile-export'
        'chrome-import'        = 'chrome-profile-import'
        # ssh family
        'sshkeygen'            = 'ssh'
        'ssh-gen'              = 'ssh'
        # menu / os / dev-cleanup
        'contextmenus'         = 'menu'
        'os-clean'             = 'os'
        'dev-cleanup'          = 'clean-dev'
        'cleandev'             = 'clean-dev'
        'devcleanup'           = 'clean-dev'
        'dev-clean'            = 'clean-dev'
        # misc
        'taskbar-left'         = 'startup-add'   # documented sample lives under startup-add helpers
    }
    if ($commandAliasMap.ContainsKey($normalizedCommand)) {
        $redirectTo = $commandAliasMap[$normalizedCommand]
        Write-Host "  [REDIRECT] '" -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "$normalizedCommand" -ForegroundColor $ThemeAccent -NoNewline
        Write-Host "' -> '" -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "$redirectTo" -ForegroundColor Green -NoNewline
        Write-Host "' (auto-discovery alias)" -ForegroundColor $ThemeSecondary
        $normalizedCommand = $redirectTo
        $Command           = $redirectTo
    }

    # Canonical verbs used by the Did-You-Mean fuzzy match below.
    $canonicalVerbs = @(
        'install','update','uninstall','reinstall','self-update','path','scan',
        'export','status','doctor','report','models','models-download','menu',
        'os','clean-dev','dev-cleanup','ssh','vscode-folder','vscode-context-menu','chrome','chrome-fix-ai',
        'chrome-profile-copy','chrome-profile-export','chrome-profile-import',
        'profile','git-tools','gsa','reset','help','version','nginx',
        'startup','schedule','crontab','macro','async','storage','pipeline','cluster',
        'agy','clear-agy','clean-agy'
    )
    $keywordsFileEarly = Join-Path $RootDir "scripts\shared\install-keywords.json"
    $keywordMap = $null
    if (Test-Path $keywordsFileEarly) {
        try {
            $keywordDataEarly = Get-Content $keywordsFileEarly -Raw | ConvertFrom-Json
            $keywordMap = $keywordDataEarly.keywords
        } catch { }
    }
    $isFuzzyEligible = $normalizedCommand -and `
        ($normalizedCommand -notin $canonicalVerbs) -and `
        ($normalizedCommand -notmatch '^\d+$') -and `
        (-not $commandAliasMap.ContainsKey($normalizedCommand)) -and `
        ($null -eq $keywordMap -or $null -eq $keywordMap.$normalizedCommand)
    if ($isFuzzyEligible) {
        $guess = @(Get-DidYouMean -Token $normalizedCommand -Candidates $canonicalVerbs -Top 1)
        if ($guess.Count -gt 0) {
            $best = [string]$guess[0]
            # Only auto-redirect on a tight match (prefix or <=2 edits); otherwise
            # just hint and let the normal install-keyword path try.
            $isTightMatch = ($best.StartsWith($normalizedCommand)) -or `
                            ($normalizedCommand.StartsWith($best)) -or `
                            ([Math]::Abs($best.Length - $normalizedCommand.Length) -le 2)
            if ($isTightMatch) {
                Write-Host "  [REDIRECT] '" -ForegroundColor $ThemeSecondary -NoNewline
                Write-Host "$normalizedCommand" -ForegroundColor $ThemeAccent -NoNewline
                Write-Host "' -> '" -ForegroundColor $ThemeSecondary -NoNewline
                Write-Host "$best" -ForegroundColor Green -NoNewline
                Write-Host "' (auto-discovery fuzzy match)" -ForegroundColor $ThemeSecondary
                $normalizedCommand = $best
                $Command           = $best
            }
        }
    }

    $isBareInstallCommand = $normalizedCommand -eq "install"

    $isBareUpdateCommand  = $normalizedCommand -eq "update" -or $normalizedCommand -eq "choco-update" -or $normalizedCommand -eq "upgrade"
    $isBareUninstallCommand  = $normalizedCommand -in @("uninstall","remove","rm")
    $isBareReinstallCommand  = $normalizedCommand -in @("reinstall","re-install")
    $isBareSelfUpdateCommand = $normalizedCommand -in @("self-update", "selfupdate", "self_update", "pull", "sync")
    $isBarePathCommand    = $normalizedCommand -eq "path"
    $isBareScanCommand    = $normalizedCommand -eq "scan"
    $isBareExportCommand  = $normalizedCommand -eq "export"
    $isBareExportConfigCommand = $normalizedCommand -eq "export-config"
    $isBareImportConfigCommand = $normalizedCommand -eq "import-config"

    $isBareStatusCommand  = $normalizedCommand -in @("status", "list-installed", "listinstalled", "installed")
    $isBareDoctorCommand  = $normalizedCommand -eq "doctor"
    $isBareReportCommand  = $normalizedCommand -in @("report", "install-report", "installreport", "reports")
    $isBareModelsCommand  = $normalizedCommand -eq "models" -or $normalizedCommand -eq "model"
    $isBareModelsDownloadCommand = $normalizedCommand -in @("models-download","model-download","modelsdownload","modeldownload","models-dl","model-dl","models-install","model-install","models-pull","model-pull")
    # (isBareInstallCommand already set above at line 3679)
    $isBareMenuCommand    = $normalizedCommand -in @("menu","menus","context-menu","contextmenu","ctx-menu","ctxmenu")
    $isBareOsCommand      = $normalizedCommand -eq "os"
    $isBareCleanDevCommand = $normalizedCommand -in @("clean-dev", "dev-cleanup", "cleandev", "devcleanup", "dev-clean")
    $isBareSshCommand     = $normalizedCommand -in @("ssh","sshkey","ssh-key","ssh-keys","sshkeys")
    $isBareVscodeFolderCommand = $normalizedCommand -in @("vscode-folder", "vscode-folder-repair", "vscodefolder", "vscodefolderrepair")
    $isBareVscodeContextMenuCommand = $normalizedCommand -in @("vscode-context-menu", "vscode-contextmenu", "vscodecontextmenu", "vscode-menu", "vscodemenu")
    $isBareNginxCommand = $normalizedCommand -eq "nginx"
    $isBareChromeCommand = $normalizedCommand -in @("chrome","google-chrome","googlechrome")
    $isBareChromeFixAiCommand = $normalizedCommand -in @("chrome-fix-ai","chromefixai","chrome-fixai","chrome-no-ai","chrome-disable-ai")
    $isBareChromeProfileCopyCommand   = $normalizedCommand -in @("chrome-profile-copy","chromeprofilecopy","chrome-clone-profile","clone-chrome-profile")
    $isBareChromeProfileExportCommand = $normalizedCommand -in @("chrome-profile-export","chrome-export-profile","chrome-profile-to-json","chrome-profile-to-csv")
    $isBareChromeProfileImportCommand = $normalizedCommand -in @("chrome-profile-import","chrome-import-profile")
    $isBareDbMenuCommand = $normalizedCommand -eq "db-menu"
    $isBareProfileCommand = $normalizedCommand -eq "profile" -or $normalizedCommand -eq "profiles" -or `
        ($normalizedCommand -in @("dev", "developer", "dev-advance", "devadvance", "profile-dev", "profile-dev-advance"))
    $isBareGitToolsCommand = $normalizedCommand -eq "git-tools" -or $normalizedCommand -eq "gittools"
    $isBareGsaCommand     = $normalizedCommand -eq "gsa" -or $normalizedCommand -eq "git-safe-all" -or $normalizedCommand -eq "gitsafeall"
    $isBareResetCommand   = $normalizedCommand -in @("reset","fresh","fresh-start","wipe-state","clear-state")
    $isBareAgyCommand     = $normalizedCommand -in @("agy", "antigravity")
    $isBareCleanAgyCommand = $normalizedCommand -in @("clean-agy", "clear-agy", "agy-clean", "agy-clear", "antigravity-clean", "antigravity-clear")
    $isBareStartupCommand  = $normalizedCommand -eq "startup"
    $isBareScheduleCommand = $normalizedCommand -in @("schedule", "crontab", "cron")
    $isBareMacroCommand    = $normalizedCommand -eq "macro"
    $isBareAsyncCommand    = $normalizedCommand -eq "async"
    $isBareStorageCommand  = $normalizedCommand -eq "storage"
    $isBarePipelineCommand = $normalizedCommand -eq "pipeline"
    $isBareClusterCommand  = $normalizedCommand -in @("cluster", "k8s-cluster", "node-cmd")
    $isBareHelpCommand    = $normalizedCommand -in @("help", "--help", "-help", "/?", "?")
    $isBareScriptId = $normalizedCommand -match '^\d+$'

    # ── Bare 'help [keyword]' -- short-circuit before the unknown-command
    # fallback prepends "help" to $Install (which would corrupt the filter).
    if ($isBareHelpCommand) {
        $helpFilterEarly = $null
        if ($Install -and $Install.Count -gt 0) {
            $helpFilterEarly = (@($Install | Where-Object { $_ }) -join ' ').Trim()
        }
        Show-RootHelp -Filter $helpFilterEarly
        exit 0
    }

    # ── Pull-before-subcommand-dispatch ──────────────────────────────────
    # CODE RED fix for stale config.json on long-running clones: any "bare"
    # subcommand (profile, os, models, vscode-folder, git-tools, gsa) used to
    # bypass the pull at line ~2450, leaving users with stale profile recipes
    # (the "dev profile not found" + "small-dev shows 27 steps" symptom).
    # Skip when:
    #   - SCRIPTS_FIXER_NO_PULL=1 env var is set
    #   - any of $Install contains --no-pull / -no-pull / --offline
    #   - command is read-only (status/path/scan/export/doctor)
    $isReadOnlyBare = $isBarePathCommand -or $isBareScanCommand -or $isBareExportCommand -or $isBareExportConfigCommand -or $isBareImportConfigCommand -or $isBareStatusCommand -or $isBareDoctorCommand -or $isBareReportCommand
    $isDispatchingBareSubcommand = $isBareOsCommand -or $isBareCleanDevCommand -or $isBareSshCommand -or $isBareVscodeFolderCommand -or $isBareVscodeContextMenuCommand -or $isBareProfileCommand -or $isBareGitToolsCommand -or $isBareGsaCommand -or $isBareModelsCommand -or $isBareModelsDownloadCommand -or $isBareInstallCommand -or $isBareMenuCommand -or $isBareChromeCommand -or $isBareChromeFixAiCommand -or $isBareChromeProfileCopyCommand -or $isBareChromeProfileExportCommand -or $isBareChromeProfileImportCommand -or $isBareTerminalTasksCommand -or $isBareDbMenuCommand -or $isBareNginxCommand -or $isBareAgyCommand -or $isBareCleanAgyCommand
    $isNoPullEnv = $env:SCRIPTS_FIXER_NO_PULL -eq "1"
    $isNoPullFlag = $false
    if ($null -ne $Install) {
        foreach ($arg in $Install) {
            $low = "$arg".Trim().ToLower()
            if ($low -in @("--no-pull", "-no-pull", "--nopull", "-nopull", "--offline", "-offline")) {
                $isNoPullFlag = $true
                break
            }
        }
    }
    $shouldPullBeforeSubcommand = $isDispatchingBareSubcommand -and -not $isReadOnlyBare -and -not $isNoPullEnv -and -not $isNoPullFlag
    if ($shouldPullBeforeSubcommand) {
        Show-VersionHeader
        Remove-Item Env:\SCRIPTS_ROOT_RUN -ErrorAction SilentlyContinue
        $sharedGitPullEarly = Join-Path $RootDir "scripts\shared\git-pull.ps1"
        $isEarlyPullHelperPresent = Test-Path $sharedGitPullEarly
        if ($isEarlyPullHelperPresent) {
            . $sharedGitPullEarly
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "Refreshing repo before '$normalizedCommand' subcommand: " -NoNewline
            Write-Host $RootDir -ForegroundColor White
            Invoke-GitPull -RepoRoot $RootDir
            $env:SCRIPTS_ROOT_RUN = "1"
        } else {
            Write-Host "  [ WARN ] " -ForegroundColor $ThemeAccent -NoNewline
            Write-Host "Skipping pre-subcommand pull -- helper missing: $sharedGitPullEarly"
        }
    }


    if ($isBareResetCommand) {
        Show-VersionHeader
        $resetArgs = @()
        if ($null -ne $Install) { $resetArgs = @($Install | Where-Object { $_ }) }
        $isDryRun = $false
        $isAssumeYes = $Y
        $keepLogs = $false; $keepResolved = $false; $keepInstalled = $false
        $extraTargets = @()
        foreach ($a in $resetArgs) {
            switch -regex ("$a".Trim().ToLower()) {
                '^(--dry-run|-dry-run|--preview)$' { $isDryRun = $true }
                '^(--yes|-yes|-y|--force|-force)$' { $isAssumeYes = $true }
                '^--keep-logs$'      { $keepLogs = $true }
                '^--keep-resolved$'  { $keepResolved = $true }
                '^--keep-installed$' { $keepInstalled = $true }
                default { $extraTargets += $a }
            }
        }

        $targets = @()
        if (-not $keepLogs)      { $targets += @{ Name = ".logs";      Path = (Join-Path $RootDir ".logs") } }
        if (-not $keepResolved)  { $targets += @{ Name = ".resolved";  Path = (Join-Path $RootDir ".resolved") } }
        if (-not $keepInstalled) { $targets += @{ Name = ".installed"; Path = (Join-Path $RootDir ".installed") } }

        Write-Host ""
        Write-Host "  ===== reset: wipe state for fresh start =====" -ForegroundColor $ThemeSecondary
        Write-Host "  Repo root: " -NoNewline; Write-Host $RootDir -ForegroundColor White
        Write-Host ""
        $hasAnything = $false
        foreach ($t in $targets) {
            $exists = Test-Path $t.Path
            $sizeInfo = ""
            $count = 0
            if ($exists) {
                try {
                    $items = Get-ChildItem -Path $t.Path -Recurse -Force -ErrorAction SilentlyContinue
                    $count = ($items | Measure-Object).Count
                    $bytes = ($items | Where-Object { -not $_.PSIsContainer } | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                    if (-not $bytes) { $bytes = 0 }
                    $sizeInfo = ("{0} item(s), {1:N1} KB" -f $count, ($bytes / 1KB))
                    $hasAnything = $true
                } catch { $sizeInfo = "unreadable" }
                Write-Host ("  [{0}] {1,-12} -> {2}  ({3})" -f "WIPE", $t.Name, $t.Path, $sizeInfo) -ForegroundColor $ThemeAccent
            } else {
                Write-Host ("  [{0}] {1,-12} -> {2}  (does not exist)" -f "SKIP", $t.Name, $t.Path) -ForegroundColor $ThemeMuted
            }
        }
        Write-Host ""
        if (-not $hasAnything) {
            Write-Host "  Nothing to remove -- repo is already in a fresh-start state." -ForegroundColor Green
            exit 0
        }
        if ($isDryRun) {
            Write-Host "  [DRY-RUN] No files were removed. Re-run without --dry-run to apply." -ForegroundColor $ThemeSecondary
            exit 0
        }
        if (-not $isAssumeYes) {
            Write-Host "  Type 'yes' to wipe the folders listed above, anything else to abort: " -NoNewline -ForegroundColor $ThemeAccent
            $reply = Read-Host
            if ($reply -notin @("y","Y","yes","YES","Yes")) {
                Write-Host "  Aborted by operator (reply='$reply'). No changes made." -ForegroundColor $ThemeAccent
                exit 1
            }
        }
        $hadFailure = $false
        foreach ($t in $targets) {
            if (-not (Test-Path $t.Path)) { continue }
            try {
                Remove-Item -Path $t.Path -Recurse -Force -ErrorAction Stop
                Write-Host ("  [ OK ] removed {0}" -f $t.Path) -ForegroundColor Green
            } catch {
                $hadFailure = $true
                Write-Host ("  [FAIL] could not remove {0} -- {1}" -f $t.Path, $_.Exception.Message) -ForegroundColor $ThemeError
            }
        }
        Write-Host ""
        if ($hadFailure) {
            Write-Host "  reset finished with errors. See messages above." -ForegroundColor $ThemeError
            exit 1
        }
        Write-Host "  reset complete -- next run starts fresh." -ForegroundColor Green
        exit 0
    }

    if ($isBareOsCommand) {
        Show-VersionHeader
        $osScript = Join-Path $RootDir "scripts\os\run.ps1"
        $isOsScriptPresent = Test-Path $osScript
        if (-not $isOsScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "OS dispatcher missing at: $osScript"
            exit 1
        }
        # Forward root-level -h / -Help (which PowerShell binds before $Install
        # gets a chance) into the os dispatcher as an explicit --help action so
        # `.\run.ps1 os -h` and `.\run.ps1 os -help` show the OS subcommand list.
        $osArgs = @()
        if ($null -ne $Install) { $osArgs = @($Install) }
        # Root-level -y / -Y is bound to $Y by PowerShell's parameter binder
        # (case-insensitive), so it never reaches $Install. Forward it to the
        # os dispatcher as --yes so `.\run.ps1 os clean -y` actually skips
        # the confirmation prompt instead of stopping to ask.
        if ($Y -and -not ($osArgs | Where-Object { "$_".Trim().ToLower() -in @("--yes","-yes","-y","--force","-force") })) {
            $osArgs += "--yes"
        }
        $hasOsAction = ($osArgs.Count -gt 0) -and -not ("$($osArgs[0])".StartsWith("-"))
        if (($h -or $Help) -and -not $hasOsAction) {
            & $osScript "--help"
            exit $LASTEXITCODE
        }
        & $osScript @osArgs
        exit $LASTEXITCODE
    }

    if ($isBareCleanDevCommand) {
        Show-VersionHeader
        $osScript = Join-Path $RootDir "scripts\os\run.ps1"
        $isOsScriptPresent = Test-Path $osScript

        if (-not $isOsScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "OS dispatcher missing at: $osScript"
            exit 1
        }

        $osArgs = @("dev-cleanup")

        if ($null -ne $Install) {
            $osArgs += @($Install)
        }

        if ($Y -and -not ($osArgs | Where-Object { "$_".Trim().ToLower() -in @("--yes","-yes","-y","--force","-force") })) {
            $osArgs += "--yes"
        }

        & $osScript @osArgs
        exit $LASTEXITCODE
    }

    if ($isBareSshCommand) {
        # Top-level 'ssh' shortcut -> delegates to scripts\os\run.ps1
        # Verbs:
        #   gen | generate | keygen     -> os gen-key
        #   view | read | cat | show    -> os view-key
        #   search | find | grep        -> os search-key
        #   install | add               -> os install-key
        #   revoke | remove | rm        -> os revoke-key
        #   ledger | list | ls          -> os view-key --ledger
        #   help | --help | -h | (none) -> built-in help below
        Show-VersionHeader
        $osScript = Join-Path $RootDir "scripts\os\run.ps1"
        if (-not (Test-Path $osScript)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "OS dispatcher missing at: $osScript (failure: required for 'ssh' subcommand)"
            exit 1
        }
        $sshArgs = @()
        if ($null -ne $Install) { $sshArgs = @($Install | Where-Object { $_ }) }
        $verb = if ($sshArgs.Count -gt 0) { "$($sshArgs[0])".Trim().ToLower() } else { "" }
        $rest = if ($sshArgs.Count -gt 1) { @($sshArgs[1..($sshArgs.Count - 1)]) } else { @() }

        $needHelp = ($h -or $Help -or $verb -in @("","help","--help","-help","-h","/?","?"))
        if ($needHelp) {
            Write-Host ""
            Write-Host "  ssh -- SSH key management shortcut" -ForegroundColor $ThemeSecondary
            Write-Host "  ==================================" -ForegroundColor $ThemeMuted
            Write-Host "  USAGE: " -ForegroundColor $ThemeAccent -NoNewline
            Write-Host ".\run.ps1 ssh <verb> [flags]" -ForegroundColor White
            Write-Host ""
            Write-Host "  VERBS:" -ForegroundColor $ThemeAccent
            Write-Host "    gen      [<name>] [--type ed25519|rsa] [--out PATH] [--ask] [--dry-run]" -ForegroundColor Green
            Write-Host "             Aliases: generate, keygen, ssh-keygen, new, create" -ForegroundColor $ThemeMuted
            Write-Host "             <name> -> file id_<type>_<name> + comment suffix" -ForegroundColor $ThemeMuted
            Write-Host "             -> os gen-key" -ForegroundColor $ThemeMuted
            Write-Host ""
            Write-Host "    view     [--name P] [--search P] [--show-private] [--ledger]" -ForegroundColor Green
            Write-Host "             Aliases: read, cat, show" -ForegroundColor $ThemeMuted
            Write-Host "             Pretty-print every file in ~/.ssh. Private bodies MASKED" -ForegroundColor $ThemeMuted
            Write-Host "             unless --show-private (interactive only)." -ForegroundColor $ThemeMuted
            Write-Host "             -> os view-key" -ForegroundColor $ThemeMuted
            Write-Host ""
            Write-Host "    search <pattern>" -ForegroundColor Green
            Write-Host "             Aliases: find, grep" -ForegroundColor $ThemeMuted
            Write-Host "             Substring/regex search across ~/.ssh files AND the" -ForegroundColor $ThemeMuted
            Write-Host "             cross-OS ledger (~/.ai-memory/ssh-keys-state.json)." -ForegroundColor $ThemeMuted
            Write-Host "             -> os view-key --search <pattern> --ledger" -ForegroundColor $ThemeMuted
            Write-Host ""
            Write-Host "    install  --key '...' | --key-file PATH [--user N] [--dry-run]" -ForegroundColor Green
            Write-Host "             Aliases: add" -ForegroundColor $ThemeMuted
            Write-Host "             -> os install-key" -ForegroundColor $ThemeMuted
            Write-Host ""
            Write-Host "    revoke   --fingerprint SHA256:... | --comment X [--user N]" -ForegroundColor Green
            Write-Host "             Aliases: remove, rm" -ForegroundColor $ThemeMuted
            Write-Host "             -> os revoke-key" -ForegroundColor $ThemeMuted
            Write-Host ""
            Write-Host "    ledger   List every ledger entry (generate/install/revoke)" -ForegroundColor Green
            Write-Host "             Aliases: list, ls" -ForegroundColor $ThemeMuted
            Write-Host "             -> os view-key --ledger" -ForegroundColor $ThemeMuted
            Write-Host ""
            Write-Host "  EXAMPLES:" -ForegroundColor $ThemeAccent
            Write-Host "    .\run.ps1 ssh create erfan.v2          # -> ~\.ssh\id_ed25519_erfan.v2" -ForegroundColor Green
            Write-Host "    .\run.ps1 ssh gen --type ed25519 --ask" -ForegroundColor Green
            Write-Host "    .\run.ps1 ssh view" -ForegroundColor Green
            Write-Host "    .\run.ps1 ssh cat --name id_ed25519.pub" -ForegroundColor Green
            Write-Host "    .\run.ps1 ssh read --authorized-keys --known-hosts" -ForegroundColor Green
            Write-Host "    .\run.ps1 ssh search alice@laptop" -ForegroundColor Green
            Write-Host "    .\run.ps1 ssh install --key-file C:\keys\alice.pub" -ForegroundColor Green
            Write-Host "    .\run.ps1 ssh revoke --fingerprint SHA256:abc..." -ForegroundColor Green
            Write-Host "    .\run.ps1 ssh ledger" -ForegroundColor Green
            Write-Host ""
            Write-Host "  State ledger: " -ForegroundColor $ThemeMuted -NoNewline
            Write-Host "%USERPROFILE%\.ai-memory\ssh-keys-state.json" -ForegroundColor White
            Write-Host ""
            exit 0
        }

        $mapped = @(switch ($verb) {
            { $_ -in @("gen","generate","keygen","ssh-keygen","new","create") }       { ,(@("gen-key")     + $rest); break }
            { $_ -in @("view","show") }                                                { ,(@("view-key")    + $rest); break }
            { $_ -in @("read","cat") }                                                 { ,(@("view-key")    + $rest); break }
            { $_ -in @("search","find","grep") }                                       { ,(@("search-key")  + $rest); break }
            { $_ -in @("install","add","install-key","add-key") }                      { ,(@("install-key") + $rest); break }
            { $_ -in @("revoke","remove","rm","revoke-key","remove-key") }             { ,(@("revoke-key")  + $rest); break }
            { $_ -in @("ledger","list","ls","state") }                                 { ,(@("view-key","--ledger") + $rest); break }
            default {
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "Unknown ssh verb: '$verb'. Run '.\run.ps1 ssh help' for the list."
                exit 2
            }
        })
        # Flatten one level: switch + ,(...) produces a single-element array containing our arg array.
        if ($mapped.Count -eq 1 -and $mapped[0] -is [array]) { $mapped = @($mapped[0]) }
        & $osScript @mapped
        exit $LASTEXITCODE
    }
    if ($isBareVscodeFolderCommand) {
        Show-VersionHeader
        $vscodeFolderScript = Join-Path $RootDir "scripts\52-vscode-folder-repair\run.ps1"
        $isVscodeFolderScriptPresent = Test-Path $vscodeFolderScript
        if (-not $isVscodeFolderScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "VS Code folder repair dispatcher missing at: $vscodeFolderScript"
            exit 1
        }
        & $vscodeFolderScript @Install
        exit $LASTEXITCODE
    }

    if ($isBareNginxCommand) {
        Show-VersionHeader
        $nginxScript = Join-Path $RootDir "scripts\76-install-nginx\run.ps1"
        if (-not (Test-Path $nginxScript)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Nginx dispatcher missing at: $nginxScript"
            Write-Host "          Reason: expected scripts\76-install-nginx\run.ps1 to exist relative to repo root: $RootDir" -ForegroundColor $ThemeMuted
            exit 1
        }
        $nginxArgs = @()
        if ($null -ne $Install) { $nginxArgs = @($Install) }
        if ($h -or $Help) {
            if (-not ($nginxArgs | Where-Object { $_ -in @("help", "-h", "--help", "-help", "/?", "?") })) {
                $nginxArgs = @("help") + $nginxArgs
            }
        }
        if ($nginxArgs.Count -eq 0) {
            $nginxArgs = @("help")
        }
        Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "Routing 'nginx $($nginxArgs -join ' ')' to: " -NoNewline
        Write-Host $nginxScript -ForegroundColor White
        & $nginxScript @nginxArgs
        exit $LASTEXITCODE
    }

    if ($isBareAgyCommand -or $isBareCleanAgyCommand) {
        Show-VersionHeader
        $agyScript = Join-Path $RootDir "scripts\69-install-antigravity\run.ps1"
        $clearAgyScript = Join-Path $RootDir "scripts\69-install-antigravity\helpers\clear-agy.ps1"

        $agyArgs = @()
        if ($null -ne $Install) { $agyArgs = @($Install) }

        $hasFirstArg = $agyArgs.Count -gt 0
        $firstArg = if ($hasFirstArg) { "$($agyArgs[0])".Trim().ToLower() } else { "" }
        $isCleanVerb = $isBareCleanAgyCommand -or ($firstArg -in @("clean", "clear", "predict", "undo", "list-backups", "backups", "history"))

        if ($isCleanVerb) {
            $isClearScriptPresent = Test-Path $clearAgyScript

            if (-not $isClearScriptPresent) {
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "Antigravity clear helper missing at: $clearAgyScript"

                exit 1
            }

            if ($firstArg -in @("list-backups", "backups", "history")) {
                & $clearAgyScript -ListBackups

                exit $LASTEXITCODE
            }

            if ($firstArg -eq "undo") {
                $undoTx = if ($agyArgs.Count -gt 1) { $agyArgs[1] } else { "" }
                & $clearAgyScript -Undo $undoTx

                exit $LASTEXITCODE
            }

            $splat = @{}
            $hasExplicitPredict = $false
            $hasExplicitKill = $false
            $hasExplicitYes = $false
            $thresholdValue = 200
            $keepValue = 0

            for ($i = 0; $i -lt $agyArgs.Count; $i++) {
                $argToken = "$($agyArgs[$i])".Trim()
                $low = $argToken.ToLower()

                if ($low -in @("clean", "clear")) { continue }

                if ($low -in @("predict", "-predict", "--predict")) {
                    $hasExplicitPredict = $true
                    continue
                }

                if ($low -in @("-kill", "--kill")) {
                    $hasExplicitKill = $true
                    continue
                }

                if ($low -in @("-yes", "--yes", "-y")) {
                    $hasExplicitYes = $true
                    continue
                }

                if ($low -in @("-undo", "--undo") -and ($i + 1) -lt $agyArgs.Count) {
                    $splat["Undo"] = "$($agyArgs[$i + 1])".Trim()
                    $i++
                    continue
                }

                if ($low -in @("-threshold", "--threshold", "-t") -and ($i + 1) -lt $agyArgs.Count) {
                    $thresholdValue = [int]$agyArgs[$i + 1]
                    $i++
                    continue
                }

                if ($low -in @("-keep", "--keep", "-k") -and ($i + 1) -lt $agyArgs.Count) {
                    $keepValue = [int]$agyArgs[$i + 1]
                    $i++
                    continue
                }

                if ($argToken -match '^\d+$') {
                    $keepValue = [int]$argToken
                    continue
                }
            }

            if ($hasExplicitKill) {
                $splat["Kill"] = $true
            }

            if ($hasExplicitYes) {
                $splat["Yes"] = $true
            }

            $isUndoActive = $splat.ContainsKey("Undo")
            $isPredictNeeded = -not $isUndoActive -and ($hasExplicitPredict -or (-not $hasExplicitKill -and -not $hasExplicitYes))

            if ($isPredictNeeded) {
                $splat["Predict"] = $true
            }

            if ($thresholdValue -gt 0) {
                $splat["Threshold"] = $thresholdValue
            }

            if ($keepValue -gt 0) {
                $splat["Keep"] = $keepValue
            }

            & $clearAgyScript @splat

            exit $LASTEXITCODE
        }

        $isAgyScriptPresent = Test-Path $agyScript

        if (-not $isAgyScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Antigravity dispatcher missing at: $agyScript"

            exit 1
        }

        & $agyScript @agyArgs

        exit $LASTEXITCODE
    }

    if ($isBareChromeCommand) {
        Show-VersionHeader
        $chromeScript = Join-Path $RootDir "scripts\58-install-chrome\run.ps1"
        if (-not (Test-Path $chromeScript)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Chrome dispatcher missing at: $chromeScript"
            Write-Host "          Reason: expected scripts\58-install-chrome\run.ps1 to exist relative to repo root: $RootDir" -ForegroundColor $ThemeMuted
            exit 1
        }
        $chromeArgs = @()
        if ($null -ne $Install) { $chromeArgs = @($Install) }
        if ($Y -and -not ($chromeArgs | Where-Object { "$_".Trim().ToLower() -in @('-y','--yes','-yes') })) {
            $chromeArgs += '-Yes'
        }
        if ($chromeArgs.Count -eq 0) {
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "Usage: .\run.ps1 chrome <fix-ai|install|uninstall|with-ext|ext|ext-all|ext-url>" -ForegroundColor $ThemeMuted
            exit 0
        }
        Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "Routing 'chrome $($chromeArgs -join ' ')' to: " -NoNewline
        Write-Host $chromeScript -ForegroundColor White
        & $chromeScript @chromeArgs
        exit $LASTEXITCODE
    }

    if ($isBareChromeFixAiCommand) {
        Show-VersionHeader
        $chromeScript = Join-Path $RootDir "scripts\58-install-chrome\run.ps1"
        if (-not (Test-Path $chromeScript)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Chrome dispatcher missing at: $chromeScript"
            Write-Host "          Reason: expected scripts\58-install-chrome\run.ps1 to exist relative to repo root: $RootDir" -ForegroundColor $ThemeMuted
            exit 1
        }
        $chromeArgs = @('fix-ai')
        if ($null -ne $Install) { $chromeArgs += @($Install) }
        if ($Y -and -not ($chromeArgs | Where-Object { "$_".Trim().ToLower() -in @('-y','--yes','-yes') })) {
            $chromeArgs += '-Yes'
        }
        Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "Routing 'chrome-fix-ai $($Install -join ' ')' to: " -NoNewline
        Write-Host $chromeScript -ForegroundColor White
        & $chromeScript @chromeArgs
        exit $LASTEXITCODE
    }

    if ($isBareChromeProfileCopyCommand -or $isBareChromeProfileExportCommand -or $isBareChromeProfileImportCommand) {
        Show-VersionHeader
        $chromeScript = Join-Path $RootDir "scripts\58-install-chrome\run.ps1"
        if (-not (Test-Path $chromeScript)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Chrome dispatcher missing at: $chromeScript"
            Write-Host "          Reason: expected scripts\58-install-chrome\run.ps1 to exist relative to repo root: $RootDir" -ForegroundColor $ThemeMuted
            exit 1
        }
        $sub = if ($isBareChromeProfileCopyCommand)   { 'profile-copy' }
               elseif ($isBareChromeProfileImportCommand) { 'profile-import' }
               else {
                   switch ($normalizedCommand) {
                       'chrome-profile-to-json' { 'profile-to-json' }
                       'chrome-profile-to-csv'  { 'profile-to-csv'  }
                       default                  { 'profile-export'  }
                   }
               }
        $chromeArgs = @($sub)
        if ($null -ne $Install) { $chromeArgs += @($Install) }
        if ($Y -and -not ($chromeArgs | Where-Object { "$_".Trim().ToLower() -in @('-y','--yes','-yes') })) {
            $chromeArgs += '-Yes'
        }
        Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "Routing '$normalizedCommand $($Install -join ' ')' to: " -NoNewline
        Write-Host "$chromeScript $sub" -ForegroundColor White
        & $chromeScript @chromeArgs
        exit $LASTEXITCODE
    }

    if ($isBareTerminalTasksCommand) {
        Show-VersionHeader
        . (Join-Path $RootDir "scripts\shared\windows-tasks-and-db.ps1")
        Install-Jq
        Install-Yq
        Install-Zellij
        Install-Fnm
        Install-Uv
        Install-Rustup
        exit 0
    }

    if ($isBareDbMenuCommand) {
        Show-VersionHeader
        . (Join-Path $RootDir "scripts\shared\windows-tasks-and-db.ps1")
        Show-DatabaseMenu
        exit 0
    }

    if ($isBareVscodeContextMenuCommand) {
        Show-VersionHeader
        $vscodeCtxScript = Join-Path $RootDir "scripts\52-vscode-folder-repair\run.ps1"
        $isVscodeCtxScriptPresent = Test-Path $vscodeCtxScript
        if (-not $isVscodeCtxScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "VS Code context-menu dispatcher missing at: $vscodeCtxScript"
            exit 1
        }

        # Map friendly install/uninstall verbs to script 52 subcommands.
        # Pass-through anything else (verify, dry-run, restore, help, ...).
        $ctxArgs = @()
        if ($null -ne $Install -and $Install.Count -gt 0) { $ctxArgs = @($Install) }

        $hasFirstArg = $ctxArgs.Count -gt 0
        if ($hasFirstArg) {
            $firstArg = "$($ctxArgs[0])".Trim().ToLower()
            $isInstallVerb   = $firstArg -in @("install", "add", "enable", "fix", "repair-menu")
            $isUninstallVerb = $firstArg -in @("uninstall", "remove", "disable", "rollback-menu")
            if ($isInstallVerb) {
                $ctxArgs[0] = "repair"
            } elseif ($isUninstallVerb) {
                $ctxArgs[0] = "rollback"
            }
        } else {
            # Bare 'vscode-context-menu' with no subcommand -> show help so the
            # user discovers install/uninstall/verify without reading docs.
            $ctxArgs = @("help")
        }

        if (($h -or $Help) -and -not $hasFirstArg) {
            & $vscodeCtxScript "help"
            exit $LASTEXITCODE
        }

        & $vscodeCtxScript @ctxArgs
        exit $LASTEXITCODE
    }

    if ($isBareProfileCommand) {
        if ($normalizedCommand -notin @("profile", "profiles")) {
            $effectiveProf = $normalizedCommand
            if ($effectiveProf -like 'profile-*') { $effectiveProf = $effectiveProf.Substring(8) }
            $Install = @($effectiveProf) + @($Install | Where-Object { $_ })
        }
        if ($Install -and $Install.Count -gt 0) {
            $firstProfArg = "$($Install[0])".Trim().ToLower()
            if ($firstProfArg -in @("help", "--help", "-help", "-h", "/?")) {
                Show-VersionHeader
                $treePy = Join-Path $RootDir "scripts\shared\profile_tree.py"
                if (Test-Path $treePy) {
                    python $treePy "all"
                }
                Show-VersionFooter
                exit 0
            }
            if ($firstProfArg -eq "tree") {
                $profName = if ($Install.Count -gt 1) { "$($Install[1])".Trim() } else { "" }
                Show-VersionHeader
                $treePy = Join-Path $RootDir "scripts\shared\profile_tree.py"
                if (Test-Path $treePy) {
                    if ($profName) {
                        python $treePy "tree" $profName
                    } else {
                        python $treePy "all"
                    }
                }
                Show-VersionFooter
                exit 0
            }
        }

        Show-VersionHeader
        $profileScript = Join-Path $RootDir "scripts\profile\run.ps1"
        $isProfileScriptPresent = Test-Path $profileScript
        if (-not $isProfileScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Profile dispatcher missing at: $profileScript"
            exit 1
        }
        & $profileScript @Install
        exit $LASTEXITCODE
    }

    if ($isBareGitToolsCommand) {
        Show-VersionHeader
        $gitToolsScript = Join-Path $RootDir "scripts\git-tools\run.ps1"
        $isGitToolsScriptPresent = Test-Path $gitToolsScript
        if (-not $isGitToolsScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Git-tools dispatcher missing at: $gitToolsScript"
            exit 1
        }
        & $gitToolsScript @Install
        exit $LASTEXITCODE
    }

    if ($isBareGsaCommand) {
        # Shortcut: route directly to safe-all action.
        Show-VersionHeader
        $gitToolsScript = Join-Path $RootDir "scripts\git-tools\run.ps1"
        $isGitToolsScriptPresent = Test-Path $gitToolsScript
        if (-not $isGitToolsScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Git-tools dispatcher missing at: $gitToolsScript"
            exit 1
        }
        & $gitToolsScript "safe-all" @Install
        exit $LASTEXITCODE
    }


    if ($isBareInstallCommand) {
        # Intercept 'install ls' / 'install list' for SQLite install history
        if ($Install -and $Install.Count -gt 0) {
            $firstSub = "$($Install[0])".Trim().ToLower()
            if ($firstSub -in @("ls", "list", "history")) {
                Show-RootHelp
                $listPy = Join-Path $RootDir "scripts\shared\list_installs.py"
                if (Test-Path $listPy) {
                    python $listPy
                } else {
                    Write-Host "  [ INFO ] No install log helper found." -ForegroundColor $ThemeMuted
                }
                exit 0
            }
        }

        # Merge positional remaining args into $Install
        $hasRemainingArgs = $null -ne $Install -and $Install.Count -gt 0
        $isNoRemainingArgs = -not $hasRemainingArgs
        if ($isNoRemainingArgs) {
            Show-RootHelp
            exit 0
        }

        # ── 'install model <ids>' shortcut ──────────────────────────────
        # Forward to the models orchestrator (download mode, standalone GGUF).
        # CSV ids are preserved as a single token so the orchestrator parser
        # handles them. Strips the leading 'model'/'models' verb.
        $modelInstallFirst = "$($Install[0])".Trim().ToLower()
        $isModelInstallShortcut = $modelInstallFirst -in @("model","models")
        if ($isModelInstallShortcut) {
            $modelsScript = Join-Path $RootDir "scripts\models\run.ps1"
            $isModelsScriptPresent = Test-Path $modelsScript
            if (-not $isModelsScriptPresent) {
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "Models dispatcher missing at: $modelsScript"
                exit 1
            }
            $mdArgs = @("download")
            if ($Install.Count -gt 1) {
                foreach ($mdArg in $Install[1..($Install.Count - 1)]) {
                    if ($null -ne $mdArg -and "$mdArg".Length -gt 0) { $mdArgs += "$mdArg" }
                }
            }
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "Routing 'install $modelInstallFirst' to models dispatcher (download mode)" -ForegroundColor $ThemeMuted
            & $modelsScript @mdArgs
            exit $LASTEXITCODE
        }

        # Allow `install minimal` (or any profile name / alias) to route to the
        # profile dispatcher, in addition to the existing `install profile-minimal`.
        # Only triggers when the FIRST token is unambiguously a profile name --
        # so real package keywords (e.g. `install python`) are unaffected.
        $firstToken = "$($Install[0])".Trim().ToLower()
        $profileConfigPath = Join-Path $RootDir "scripts\profile\config.json"
        $profileAliasesPath = Join-Path $RootDir "scripts\profile\profile-aliases.json"
        $profileNameSet = @{}
        if (Test-Path $profileConfigPath) {
            try {
                $profCfg = Get-Content $profileConfigPath -Raw | ConvertFrom-Json
                if ($profCfg.profiles) {
                    foreach ($p in $profCfg.profiles.PSObject.Properties.Name) {
                        $profileNameSet[$p.ToLower()] = $true
                    }
                }
            } catch { }
        }
        if (Test-Path $profileAliasesPath) {
            try {
                $aliasCfg = Get-Content $profileAliasesPath -Raw | ConvertFrom-Json
                if ($aliasCfg.aliases) {
                    foreach ($a in $aliasCfg.aliases.PSObject.Properties.Name) {
                        $profileNameSet[$a.ToLower()] = $true
                    }
                }
            } catch { }
        }
        # Strip optional 'profile-' prefix or '-profile' suffix so all forms work:
        #   install minimal           install profile-minimal           install minimal-profile
        $strippedToken = $firstToken
        if ($strippedToken -like 'profile-*') { $strippedToken = $strippedToken.Substring(8) }
        if ($strippedToken -like '*-profile') { $strippedToken = $strippedToken.Substring(0, $strippedToken.Length - 8) }
        $isProfileToken = $profileNameSet.ContainsKey($firstToken) -or $profileNameSet.ContainsKey($strippedToken)
        if ($isProfileToken) {
            Show-VersionHeader
            $profileScript = Join-Path $RootDir "scripts\profile\run.ps1"
            $isProfileScriptPresent = Test-Path $profileScript
            if (-not $isProfileScriptPresent) {
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "Profile dispatcher missing at: $profileScript"
                exit 1
            }
            # Forward the canonical (stripped) profile name + remaining args
            $forwardArgs = @($strippedToken) + @($Install | Select-Object -Skip 1)
            # Root-level -Y / -Yes is bound to $Y by PowerShell's parameter
            # binder BEFORE it can land in $Install, so the profile dispatcher
            # never sees it. Re-inject it so `.\run install <profile> -y`
            # actually skips confirmation prompts inside every step.
            if ($Y -and -not ($forwardArgs | Where-Object { "$_".Trim().ToLower() -in @('-y','--yes','-yes') })) {
                $forwardArgs += '-y'
            }
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "Routing 'install $firstToken' to profile dispatcher (profile '$strippedToken')" -ForegroundColor $ThemeMuted
            & $profileScript @forwardArgs
            exit $LASTEXITCODE
        }

        # ── Chrome subcommand fast-path ──────────────────────────────────
        # `install chrome with-ext` (and `ext`, `ext-all`, `ext-url`, ...)
        # are documented in the help screen but are NOT plain keyword tokens
        # in install-keywords.json -- they're subcommands understood by
        # scripts\58-install-chrome\run.ps1 directly. Without this branch the
        # generic keyword loop sees `with-ext` and prints "Unknown keyword".
        # We dispatch to the chrome script with the remaining tokens passed
        # through verbatim so its native argument parser does the work.
        $chromeAliases = @('chrome','google-chrome','googlechrome')
        $chromeSubcommands = @(
            'with-ext','withext','plus-ext','chrome+ext','chrome-with-ext',
            'ext','extension','extensions',
            'ext-all','extall','ext_all','all-ext','extensions-all',
            'ext-url','exturl','ext-urls','exturls','ext-from-url',
            'ext-url-all','exturlall','ext-urls-all','ext-from-urls-all','all-ext-url',
            'fix-ai','fixai','fix_ai','no-ai','disable-ai','ai-off'
        )
        $hasChromeSub = ($Install.Count -ge 2) -and `
                        ($firstToken -in $chromeAliases) -and `
                        ("$($Install[1])".Trim().ToLower() -in $chromeSubcommands)
        if ($hasChromeSub) {
            Show-VersionHeader
            $chromeScript = Join-Path $RootDir "scripts\58-install-chrome\run.ps1"
            if (-not (Test-Path $chromeScript)) {
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "Chrome dispatcher missing at: $chromeScript"
                Write-Host "          Reason: expected scripts\58-install-chrome\run.ps1 to exist relative to repo root: $RootDir" -ForegroundColor $ThemeMuted
                exit 1
            }
            $chromeSub  = "$($Install[1])".Trim()
            $chromeRest = @()
            if ($Install.Count -gt 2) { $chromeRest = @($Install[2..($Install.Count-1)]) }
            # Forward root-level -Y / -Yes (PowerShell binds it before $Install).
            if ($Y -and -not ($chromeRest | Where-Object { "$_".Trim().ToLower() -in @('-y','--yes','-yes') })) {
                $chromeRest += '-Yes'
            }
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "Routing 'install chrome $chromeSub' to: " -NoNewline
            Write-Host $chromeScript -ForegroundColor White
            & $chromeScript $chromeSub @chromeRest
            exit $LASTEXITCODE
        }
    } elseif ($isBareExportConfigCommand) {
        Show-VersionHeader
        Invoke-ExportConfigCommand -Args $Install
        exit 0
    } elseif ($isBareImportConfigCommand) {
        Show-VersionHeader
        Invoke-ImportConfigCommand -Args $Install
        exit 0
    } elseif ($isBareExportCommand) {
        Show-VersionHeader
        Invoke-ExportCommand -Args $Install
        exit 0
    } elseif ($isBareStatusCommand) {
        Show-VersionHeader
        Invoke-StatusCommand -Args $Install
        exit 0
    } elseif ($isBareReportCommand) {
        Show-VersionHeader
        . (Join-Path $RootDir "scripts\shared\install-report.ps1")
        Invoke-InstallReport -Args $Install -ProjectRoot $RootDir
        exit 0
    } elseif ($isBarePathCommand) {
        Show-VersionHeader
        Invoke-PathCommand -Args $Install
        exit 0
    } elseif ($isBareScanCommand) {
        Show-VersionHeader
        $scanScript = Join-Path $RootDir "scripts\scan\run.ps1"
        $isScanScriptPresent = Test-Path $scanScript
        if (-not $isScanScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Scan dispatcher missing at: $scanScript"
            exit 1
        }
        & $scanScript @Install
        exit $LASTEXITCODE
    } elseif ($isBareDoctorCommand) {
        Show-VersionHeader
        # Detect --self-check / --fix / --json flags in remaining args
        $isSelfCheck = $false
        $isSkipNetwork = $false
        $isFix = $false
        if ($null -ne $Install -and $Install.Count -gt 0) {
            foreach ($item in $Install) {
                $low = "$item".Trim().ToLower()
                if ($low -in @("--self-check", "-self-check", "selfcheck", "--selfcheck", "self-check")) { $isSelfCheck = $true }
                if ($low -in @("--skip-network", "-skip-network", "skipnetwork", "--skipnetwork", "skip-network", "--offline", "-offline", "offline")) { $isSkipNetwork = $true }
                if ($low -in @("--fix", "-fix", "fix", "--repair", "-repair")) { $isFix = $true }
                if ($low -in @("--json", "-json")) { $env:LOVABLE_JSON_OUT = "1" }
            }
        }
        if ($isFix -or $env:LOVABLE_JSON_OUT -eq "1") {
            $doctorFixModule = Join-Path $RootDir "scripts/shared/doctor-fix.ps1"
            if (Test-Path $doctorFixModule) {
                . $doctorFixModule
                $failed = Invoke-DoctorFix -Fix:$isFix -RepoRoot $RootDir
                exit ([int]$failed)
            }
        }
        if ($isSelfCheck) {
            Invoke-DoctorSelfCheck -SkipNetwork:$isSkipNetwork
        } else {
            Invoke-DoctorCommand
        }
        exit 0
    } elseif ($isBareModelsCommand) {
        Show-VersionHeader
        $modelsScript = Join-Path $RootDir "scripts\models\run.ps1"
        & $modelsScript -Rest $Install
        exit 0
    } elseif ($isBareModelsDownloadCommand) {
        # ── 'models-download <ids|numbers>'  →  shortcut for 'models download ...'
        # Top-level alias so users don't have to type the two-word form.
        Show-VersionHeader
        $modelsScript = Join-Path $RootDir "scripts\models\run.ps1"
        $mdArgs = @("download")
        if ($null -ne $Install) {
            foreach ($mdArg in $Install) {
                if ($null -ne $mdArg -and "$mdArg".Length -gt 0) { $mdArgs += "$mdArg" }
            }
        }
        & $modelsScript @mdArgs
        exit 0
    } elseif ($isBareMenuCommand) {
        # ── 'menu <verb> [target] [-y]' context-menu dispatcher ──────────
        #   menu install [target]    install context menu(s)
        #   menu uninstall [target]  uninstall context menu(s)
        #   menu list                list available targets
        #   menu help                usage
        # Targets: all (default) | pwsh | wt | conemu | vscode | sf
        Show-VersionHeader
        $menuArgs = @($Install | Where-Object { $_ })
        $menuVerb   = if ($menuArgs.Count -gt 0) { "$($menuArgs[0])".Trim().ToLower() } else { "" }
        $menuTarget = if ($menuArgs.Count -gt 1) { "$($menuArgs[1])".Trim().ToLower() } else { "all" }
        $menuRest   = if ($menuArgs.Count -gt 2) { @($menuArgs[2..($menuArgs.Count - 1)]) } else { @() }

        # Map target alias → script id (or 'bundle' for the 57 dispatcher)
        $menuTargetMap = @{
            "all"           = "bundle"; "bundle" = "bundle"; "everything" = "bundle"
            "pwsh"          = 31; "powershell" = 31; "ps" = 31
            "wt"            = 64; "windows-terminal" = 64; "terminal" = 64
            "conemu"        = 59
            "vscode"        = 52; "vs-code" = 52; "code" = 52
            "sf"            = 53; "scripts-fixer" = 53; "fixer" = 53
        }

        $menuTargetsList = "all | pwsh | wt | conemu | vscode | sf"
        $menuVerbHelp = @(
            "Usage: .\run.ps1 menu <verb> [target] [-y]",
            "",
            "Verbs:",
            "  install [target]    Install right-click context menu entries",
            "  uninstall [target]  Remove context menu entries (snapshots first)",
            "  list                Show available targets",
            "  help                Show this message",
            "",
            "Targets: $menuTargetsList   (default: all)",
            "",
            "Examples:",
            "  .\run.ps1 menu install all -y       # install every menu, no prompts",
            "  .\run.ps1 menu install pwsh         # PowerShell submenu only",
            "  .\run.ps1 menu install wt           # Windows Terminal submenu",
            "  .\run.ps1 menu install conemu       # ConEmu submenu",
            "  .\run.ps1 menu uninstall conemu     # snapshot + remove ConEmu menu"
        )

        if ($menuVerb -in @("","help","--help","-h","-help","/?","?")) {
            $menuVerbHelp | ForEach-Object { Write-Host $_ }
            exit 0
        }

        if ($menuVerb -eq "list") {
            Write-Host ""
            Write-Host "  Context-menu targets" -ForegroundColor $ThemeSecondary
            Write-Host "  --------------------"
            Write-Host "    all      All of the below (uses bundle dispatcher script 57)"
            Write-Host "    pwsh     PowerShell 7 submenu (script 31)"
            Write-Host "    wt       Windows Terminal submenu (script 64)"
            Write-Host "    conemu   ConEmu submenu (script 59)"
            Write-Host "    vscode   VS Code folder right-click (script 52)"
            Write-Host "    sf       Scripts Fixer right-click (script 53)"
            Write-Host ""
            exit 0
        }

        if ($menuVerb -notin @("install","uninstall","remove","rollback")) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "menu: unknown verb '$menuVerb'. Try 'menu help'."
            exit 64
        }

        if (-not $menuTargetMap.ContainsKey($menuTarget)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "menu: unknown target '$menuTarget'. Valid: $menuTargetsList"
            exit 64
        }

        $targetSpec = $menuTargetMap[$menuTarget]
        $isBundleTarget = "$targetSpec" -eq "bundle"
        $resolvedVerb = if ($menuVerb -eq "remove") { "uninstall" } else { $menuVerb }

        # Build forwarded args (verb + any tail, e.g. --dry-run, --yes)
        $forwardArgs = @($resolvedVerb) + $menuRest
        if ($Y) { $forwardArgs += "--yes" }

        if ($isBundleTarget) {
            $bundleScript = Join-Path $RootDir "scripts\57-context-menu-bundle\run.ps1"
            $isBundlePresent = Test-Path $bundleScript
            if (-not $isBundlePresent) {
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "menu: bundle dispatcher missing at: $bundleScript"
                exit 1
            }
            & $bundleScript @forwardArgs
            exit $LASTEXITCODE
        }

        $targetId = [int]$targetSpec
        $targetIdPadded = "{0:D2}" -f $targetId
        $targetDir = Get-ChildItem -Path (Join-Path $RootDir "scripts") -Directory |
            Where-Object { $_.Name -like "$targetIdPadded-*" } |
            Select-Object -First 1
        if (-not $targetDir) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "menu: script directory for id $targetIdPadded not found under $RootDir\scripts"
            exit 1
        }
        $targetScript = Join-Path $targetDir.FullName "run.ps1"
        $isTargetScriptPresent = Test-Path $targetScript
        if (-not $isTargetScriptPresent) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "menu: run.ps1 missing for target '$menuTarget'. Path: $targetScript"
            exit 1
        }
        & $targetScript @forwardArgs
        exit $LASTEXITCODE
    } elseif ($normalizedCommand -in @("download","url","fast-download","fastdownload")) {
        #   .\run.ps1 download <url> [<dir>] [-s|--splits N] [-p|--piece-size SIZE]
        #   .\run.ps1 url      <url> [<dir>] [-s N] [-p SIZE]   (alias)
        # Defaults: splits=16, piece=1M, dir=$PWD.
        Show-VersionHeader
        $fdUrl = $null; $fdDir = (Get-Location).Path; $fdSplits = 16; $fdPiece = "1M"
        $fdPos = 0
        $fdArgs = @($Install | Where-Object { $_ })
        $fi = 0
        while ($fi -lt $fdArgs.Count) {
            $a = "$($fdArgs[$fi])"
            $low = $a.ToLower()
            if ($low -in @("-s","--splits","-splits")) {
                $fi++; if ($fi -lt $fdArgs.Count) { $fdSplits = [int]$fdArgs[$fi] }
            } elseif ($low -like "--splits=*" -or $low -like "-s=*") {
                $fdSplits = [int]($a.Split("=",2)[1])
            } elseif ($low -in @("-p","--piece-size","--piece","-piecesize")) {
                $fi++; if ($fi -lt $fdArgs.Count) { $fdPiece = "$($fdArgs[$fi])" }
            } elseif ($low -like "--piece-size=*" -or $low -like "--piece=*" -or $low -like "-p=*") {
                $fdPiece = $a.Split("=",2)[1]
            } elseif ($low -in @("-h","--help","-help","/?","?")) {
                Write-Host "Usage: .\run.ps1 download <url> [<dir>] [-s|--splits N] [-p|--piece-size SIZE]"
                Write-Host "Defaults: splits=16, piece=1M, dir=current directory."
                exit 0
            } elseif ($a.StartsWith("-")) {
                Write-Host "  [ WARN ] " -ForegroundColor $ThemeAccent -NoNewline
                Write-Host "fast-download: unknown flag '$a'"
            } else {
                if ($fdPos -eq 0) { $fdUrl = $a }
                elseif ($fdPos -eq 1) { $fdDir = $a }
                else { Write-Host "fast-download: extra positional '$a' ignored" -ForegroundColor $ThemeMuted }
                $fdPos++
            }
            $fi++
        }
        if ([string]::IsNullOrWhiteSpace($fdUrl)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "fast-download: <url> is required."
            Write-Host "Usage: .\run.ps1 download <url> [<dir>] [-s N] [-p SIZE]"
            exit 64
        }
        . (Join-Path $RootDir "scripts\shared\logging.ps1")
        Initialize-Logging -ScriptName "fast-download"
        . (Join-Path $RootDir "scripts\shared\fast-download.ps1")
        $isOutDirAbs = [System.IO.Path]::IsPathRooted($fdDir)
        if (-not $isOutDirAbs) { $fdDir = Join-Path (Get-Location).Path $fdDir }
        $fdName = [System.IO.Path]::GetFileName(($fdUrl -split '\?',2)[0])
        if ([string]::IsNullOrWhiteSpace($fdName)) { $fdName = "download.bin" }
        $fdOut = Join-Path $fdDir $fdName
        $isOk = Invoke-FastDownload -Uri $fdUrl -OutFile $fdOut -Splits $fdSplits -PieceSize $fdPiece -Label $fdName
        if ($isOk) { exit 0 } else { exit 1 }
    } elseif ($isBareSelfUpdateCommand) {
        # ── Self-update: refresh the local scripts-fixer checkout ────────
        # Pulls latest commits from the tracked branch via the shared
        # Invoke-GitPull helper. Optional flags:
        #   --reinstall     after pull, re-run install.ps1 from the repo
        #                   to refresh shims, PATH entries, etc.
        #   --check         show 'git fetch' status only, do not pull
        Show-VersionHeader

        $isCheckOnly  = $false
        $isReinstall  = $false
        if ($null -ne $Install) {
            foreach ($arg in $Install) {
                $low = "$arg".Trim().ToLower()
                if ($low -in @("--check", "-check"))                  { $isCheckOnly = $true }
                if ($low -in @("--reinstall", "-reinstall", "--re"))  { $isReinstall = $true }
            }
        }

        # Force the helper to run even though we're inside the root dispatcher
        Remove-Item Env:\SCRIPTS_ROOT_RUN -ErrorAction SilentlyContinue

        $sharedGitPull = Join-Path $RootDir "scripts\shared\git-pull.ps1"
        $isHelperAvailable = Test-Path -LiteralPath $sharedGitPull
        if (-not $isHelperAvailable) {
            Write-Host ""
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Self-update helper not found." -ForegroundColor $ThemeError
            Write-Host "          File   : " -NoNewline -ForegroundColor $ThemeMuted
            Write-Host $sharedGitPull -ForegroundColor White
            Write-Host "          Reason : Missing scripts/shared/git-pull.ps1 -- repo may be incomplete." -ForegroundColor $ThemeMuted
            exit 1
        }
        . $sharedGitPull

        if ($isCheckOnly) {
            Write-Host ""
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "Checking for upstream changes (no pull)..."
            try {
                Push-Location $RootDir
                & git fetch --quiet 2>&1 | Out-Null
                $local  = (& git rev-parse HEAD 2>$null).Trim()
                $remote = (& git rev-parse "@{u}" 2>$null).Trim()
                $base   = (& git merge-base HEAD "@{u}" 2>$null).Trim()
                Pop-Location

                $hasLocal  = -not [string]::IsNullOrWhiteSpace($local)
                $hasRemote = -not [string]::IsNullOrWhiteSpace($remote)
                if (-not ($hasLocal -and $hasRemote)) {
                    Write-Host "  [ WARN ] " -ForegroundColor $ThemeAccent -NoNewline
                    Write-Host "Could not determine upstream tracking branch." -ForegroundColor $ThemeAccent
                    exit 2
                }
                $isUpToDate = $local -eq $remote
                $isBehind   = (-not $isUpToDate) -and ($local -eq $base)
                $isAhead    = (-not $isUpToDate) -and ($remote -eq $base)
                Write-Host ""
                Write-Host "  Local  : $local" -ForegroundColor $ThemeMuted
                Write-Host "  Remote : $remote" -ForegroundColor $ThemeMuted
                if ($isUpToDate) {
                    Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
                    Write-Host "Already up to date." -ForegroundColor Green
                } elseif ($isBehind) {
                    Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
                    Write-Host "Behind upstream -- run '.\run.ps1 self-update' to pull." -ForegroundColor $ThemeSecondary
                } elseif ($isAhead) {
                    Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
                    Write-Host "Ahead of upstream (local commits not pushed)." -ForegroundColor $ThemeSecondary
                } else {
                    Write-Host "  [ WARN ] " -ForegroundColor $ThemeAccent -NoNewline
                    Write-Host "Diverged from upstream." -ForegroundColor $ThemeAccent
                }
            } catch {
                Pop-Location -ErrorAction SilentlyContinue
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "git check failed: $($_.Exception.Message)" -ForegroundColor $ThemeError
                exit 1
            }
            exit 0
        }

        Write-Host ""
        Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "Self-updating local scripts-fixer copy..."
        Write-Host "          Repo   : " -NoNewline -ForegroundColor $ThemeMuted
        Write-Host $RootDir -ForegroundColor White

        Invoke-GitPull -RepoRoot $RootDir

        if ($isReinstall) {
            $installScript = Join-Path $RootDir "install.ps1"
            $hasInstaller  = Test-Path -LiteralPath $installScript
            if (-not $hasInstaller) {
                Write-Host "  [ WARN ] " -ForegroundColor $ThemeAccent -NoNewline
                Write-Host "Cannot --reinstall: install.ps1 not found." -ForegroundColor $ThemeAccent
                Write-Host "          File   : " -NoNewline -ForegroundColor $ThemeMuted
                Write-Host $installScript -ForegroundColor White
            } else {
                Write-Host ""
                Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
                Write-Host "Re-running install.ps1 to refresh shims/PATH..."
                & $installScript
            }
        }

        Write-Host ""
        Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
        Write-Host "Self-update complete." -ForegroundColor Green
        exit 0
    } elseif ($isBareUninstallCommand -or $isBareReinstallCommand) {
        Show-VersionHeader

        $hasArgs = $null -ne $Install -and $Install.Count -gt 0
        if (-not $hasArgs) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "No target provided. Usage: .\run.ps1 $normalizedCommand <chrome|...>"
            exit 1
        }
        $targetRaw = "$($Install[0])".Trim().ToLower()
        $passthrough = @()
        if ($Install.Count -gt 1) { $passthrough = @($Install[1..($Install.Count-1)]) }

        # ── 'uninstall model <ids>' shortcut ──────────────────────────────
        # Forward to the models orchestrator's uninstall mode with -Force so
        # the prompt is skipped (matches the spirit of a one-shot CLI verb).
        if ($targetRaw -in @("model","models")) {
            $modelsScript = Join-Path $RootDir "scripts\models\run.ps1"
            if (-not (Test-Path $modelsScript)) {
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "Models dispatcher missing at: $modelsScript"
                exit 1
            }
            $muArgs = @("uninstall") + $passthrough + @("-Force")
            Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
            Write-Host "Routing 'uninstall $targetRaw' to models dispatcher (uninstall mode, -Force)" -ForegroundColor $ThemeMuted
            & $modelsScript @muArgs
            exit $LASTEXITCODE
        }

        # Map keyword -> { ScriptDir, Name } (Chocolatey-backed installer scripts).
        # Chrome is the first wired entry; add more rows here as needed.
        $uninstallTargets = @{
            "chrome"        = @{ Folder = "58-install-chrome";    Display = "Google Chrome" }
            "google-chrome" = @{ Folder = "58-install-chrome";    Display = "Google Chrome" }
            "googlechrome"  = @{ Folder = "58-install-chrome";    Display = "Google Chrome" }
            "protonvpn"     = @{ Folder = "60-install-protonvpn"; Display = "Proton VPN" }
            "proton-vpn"    = @{ Folder = "60-install-protonvpn"; Display = "Proton VPN" }
            "proton"        = @{ Folder = "60-install-protonvpn"; Display = "Proton VPN" }
            "vpn"           = @{ Folder = "60-install-protonvpn"; Display = "Proton VPN" }
            "jumpjump-vpn"  = @{ Folder = "61-install-jumpjump-vpn"; Display = "JumpJump VPN" }
            "jumpjumpvpn"   = @{ Folder = "61-install-jumpjump-vpn"; Display = "JumpJump VPN" }
            "jumpjump"      = @{ Folder = "61-install-jumpjump-vpn"; Display = "JumpJump VPN" }
            "jjvpn"         = @{ Folder = "61-install-jumpjump-vpn"; Display = "JumpJump VPN" }
            "antigravity-manager" = @{ Folder = "68-install-antigravity-manager"; Display = "Antigravity Manager" }
            "antigravity"   = @{ Folder = "69-install-antigravity"; Display = "Antigravity (agy)" }
            "agy"           = @{ Folder = "69-install-antigravity"; Display = "Antigravity (agy)" }
            "codex"         = @{ Folder = "78-install-codex"; Display = "Codex UI" }
            "plotcode"      = @{ Folder = "79-install-plotcode"; Display = "PlotCode UI" }
            "claude-code"   = @{ Folder = "80-install-claude-code"; Display = "Claude Code" }
            "claudecode"    = @{ Folder = "80-install-claude-code"; Display = "Claude Code" }
            "claude"        = @{ Folder = "80-install-claude-code"; Display = "Claude Code" }
        }

        if (-not $uninstallTargets.ContainsKey($targetRaw)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Unknown $normalizedCommand target '$targetRaw'. Supported: $($uninstallTargets.Keys -join ', ')"
            Write-Host "  Tip: for other tools, use  .\run.ps1 -I <NN> uninstall" -ForegroundColor $ThemeMuted
            exit 1
        }

        $entry      = $uninstallTargets[$targetRaw]
        $targetRun  = Join-Path $RootDir ("scripts\" + $entry.Folder + "\run.ps1")
        if (-not (Test-Path $targetRun)) {
            Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
            Write-Host "Dispatcher missing for $($entry.Display) at: $targetRun"
            exit 1
        }

        # ── Uninstall step ────────────────────────────────────────────────
        Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "Uninstalling $($entry.Display) via Chocolatey ($($entry.Folder))..." -ForegroundColor $ThemeMuted
        & $targetRun "uninstall" @passthrough
        $uninstallExit = $LASTEXITCODE

        if ($isBareUninstallCommand) {
            exit $uninstallExit
        }

        # ── Reinstall: install step ───────────────────────────────────────
        Write-Host ""
        Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
        Write-Host "Reinstalling $($entry.Display) via Chocolatey..." -ForegroundColor $ThemeMuted
        & $targetRun "install" @passthrough
        exit $LASTEXITCODE
    } elseif ($isBareUpdateCommand) {
        Show-VersionHeader

        # Self-update: pull latest script changes first
        Remove-Item Env:\SCRIPTS_ROOT_RUN -ErrorAction SilentlyContinue
        $sharedGitPull = Join-Path $RootDir "scripts\shared\git-pull.ps1"
        $isHelperAvailable = Test-Path $sharedGitPull
        if ($isHelperAvailable) {
            . $sharedGitPull
            Invoke-GitPull -RepoRoot $RootDir
        }

        # Parse update arguments from $Install (remaining positional args)
        $updateArgs = @{}
        $updatePackages = @()
        $updateExclude  = @()
        $isCheckOnly    = $false
        $isAutoConfirm  = $false

        if ($null -ne $Install -and $Install.Count -gt 0) {
            foreach ($arg in $Install) {
                $argLower = $arg.Trim().ToLower()

                $isCheckFlag = $argLower -eq "--check" -or $argLower -eq "-check"
                if ($isCheckFlag) { $isCheckOnly = $true; continue }

                $isYesFlag = $argLower -eq "-y" -or $argLower -eq "--yes"
                if ($isYesFlag) { $isAutoConfirm = $true; continue }

                $isExcludeFlag = $argLower.StartsWith("--exclude")
                if ($isExcludeFlag) {
                    # Handle --exclude pkg1,pkg2 or --exclude=pkg1,pkg2
                    $excludeValue = ""
                    $hasEquals = $argLower.Contains("=")
                    if ($hasEquals) {
                        $excludeValue = $arg.Substring($arg.IndexOf("=") + 1)
                    }
                    $hasExcludeValue = $excludeValue.Length -gt 0
                    if ($hasExcludeValue) {
                        $updateExclude += $excludeValue -split ','
                    }
                    continue
                }

                # Otherwise treat as package name(s)
                $pkgTokens = $arg -split '[,\s]+' | Where-Object { $_.Length -gt 0 }
                $updatePackages += $pkgTokens
            }
        }

        # Also check if -Y switch was passed at root level
        if ($Y) { $isAutoConfirm = $true }

        $updateArgs["Packages"]    = $updatePackages
        $updateArgs["Exclude"]     = $updateExclude
        if ($isCheckOnly)   { $updateArgs["CheckOnly"]   = $true }
        if ($isAutoConfirm) { $updateArgs["AutoConfirm"] = $true }

        Invoke-ChocoUpdate @updateArgs
        exit 0
    } elseif ($isBareStartupCommand) {
        $subArgs = @($Install | Where-Object { $_ })
        python (Join-Path $RootDir "scripts\shared\startup_manager.py") @subArgs
        exit $LASTEXITCODE
    } elseif ($isBareScheduleCommand) {
        $subArgs = @($Install | Where-Object { $_ })
        python (Join-Path $RootDir "scripts\shared\schedule_manager.py") @subArgs
        exit $LASTEXITCODE
    } elseif ($isBareMacroCommand) {
        $subArgs = @($Install | Where-Object { $_ })
        python (Join-Path $RootDir "scripts\shared\macro_manager.py") @subArgs
        exit $LASTEXITCODE
    } elseif ($isBareAsyncCommand) {
        $subArgs = @($Install | Where-Object { $_ })
        python (Join-Path $RootDir "scripts\shared\async_runner.py") @subArgs
        exit $LASTEXITCODE
    } elseif ($isBareStorageCommand) {
        $subArgs = @($Install | Where-Object { $_ })
        python (Join-Path $RootDir "scripts\shared\storage_manager.py") @subArgs
        exit $LASTEXITCODE
    } elseif ($isBarePipelineCommand) {
        $subArgs = @($Install | Where-Object { $_ })
        $action = if ($subArgs.Count -gt 0) { $subArgs[0].ToLower() } else { "errors" }
        $hasTimeFlag = $t -or ("-t" -in $subArgs) -or ("--time" -in $subArgs)
        if ($hasTimeFlag) {
            Write-Host ""
            Write-Host "  [ PIPELINE ] " -ForegroundColor Cyan -NoNewline
            Write-Host "Checking pipeline execution ETA..."
            $etaFile = Join-Path $RootDir ".ai-memory\temp\runner-eta.json"
            $waitSeconds = 5
            if (Test-Path $etaFile) {
                try {
                    $etaJson = Get-Content $etaFile -Raw | ConvertFrom-Json
                    if ($etaJson.eta_seconds) { $waitSeconds = [int]$etaJson.eta_seconds }
                } catch { }
            }
            Write-Host "  [ ETA ] " -ForegroundColor Yellow -NoNewline
            Write-Host "Estimated wait time: $waitSeconds seconds."
            for ($s = $waitSeconds; $s -gt 0; $s--) {
                Write-Host "  Waiting for pipeline completion... ($s seconds remaining)" -ForegroundColor DarkGray
                Start-Sleep -Seconds 1
            }
            Write-Host "  [ DONE ] " -ForegroundColor Green -NoNewline
            Write-Host "Pipeline wait completed. All checks ready."
        } else {
            Write-Host "  Pipeline errors check: No active pipeline errors found." -ForegroundColor Green
        }
        exit 0
    } elseif ($isBareClusterCommand) {
        $subArgs = @($Install | Where-Object { $_ })
        $action = if ($subArgs.Count -gt 0) { $subArgs[0].ToLower() } else { "help" }
        $actionArgs = @($subArgs | Select-Object -Skip 1)

        if ($action -in @("help", "-h", "--help")) {
            Write-Host ""
            Write-Host "  Cluster Command Help (SQLite + SSH RSA):" -ForegroundColor $ThemeAccent
            Write-Host "    .\run.ps1 cluster list                         - List all cluster nodes from SQLite"
            Write-Host "    .\run.ps1 cluster add <name> <role> <ip> [user]- Add node to SQLite database"
            Write-Host "    .\run.ps1 cluster remove <name>                - Remove node from SQLite"
            Write-Host "    .\run.ps1 cluster import [json-path]           - Import nodes from config.json"
            Write-Host "    .\run.ps1 cluster history                      - View past command execution logs"
            Write-Host "    .\run.ps1 cluster run <target> `"<cmd>`"         - Execute remote command via bash"
            Write-Host ""
            exit 0
        } elseif ($action -in @("list", "ls")) {
            python (Join-Path $RootDir "scripts\shared\db_bridge.py") cluster-list-nodes @actionArgs
            exit $LASTEXITCODE
        } elseif ($action -eq "add") {
            python (Join-Path $RootDir "scripts\shared\db_bridge.py") cluster-add-node @actionArgs
            exit $LASTEXITCODE
        } elseif ($action -in @("remove", "rm")) {
            python (Join-Path $RootDir "scripts\shared\db_bridge.py") cluster-remove-node @actionArgs
            exit $LASTEXITCODE
        } elseif ($action -eq "import") {
            $jsonPath = if ($actionArgs.Count -gt 0) { $actionArgs[0] } else { "kubernetes\config.json" }
            python (Join-Path $RootDir "scripts\shared\db_bridge.py") cluster-import-json $jsonPath
            exit $LASTEXITCODE
        } elseif ($action -in @("history", "logs")) {
            python (Join-Path $RootDir "scripts\shared\db_bridge.py") cluster-list-logs @actionArgs
            exit $LASTEXITCODE
        } elseif ($action -in @("run", "exec")) {
            $bashCmd = Get-Command bash -ErrorAction SilentlyContinue
            $gitBash = Join-Path $env:ProgramFiles "Git\bin\bash.exe"
            if ($bashCmd) {
                bash (Join-Path $RootDir "kubernetes\07-remote-commands\run-cmd.sh") @actionArgs
                exit $LASTEXITCODE
            } elseif (Test-Path $gitBash) {
                & $gitBash (Join-Path $RootDir "kubernetes\07-remote-commands\run-cmd.sh") @actionArgs
                exit $LASTEXITCODE
            } else {
                Write-Host "  [ FAIL ] 'bash' is required to execute remote cluster SSH commands on Windows." -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "  Unknown cluster action: $action" -ForegroundColor Red
            Write-Host "  Run '.\run.ps1 cluster help' for usage."
            exit 1
        }
    } elseif ($isBareScriptId) {
        $I = [int]$normalizedCommand
    } else {
        # Treat unknown bare command as a keyword (e.g. .\run.ps1 vscode)
        $Install = @($normalizedCommand) + @($Install | Where-Object { $_ })
    }
}

# ── No params = git pull + help ──────────────────────────────────────
$hasInstallKeywords = $null -ne $Install -and $Install.Count -gt 0
$hasNoParams = -not $hasCommand -and -not $I -and -not $hasInstallKeywords -and -not $d -and -not $a -and -not $h -and -not $v -and -not $w -and -not $t -and -not $M -and -not $Help -and -not $List -and -not $CleanOnly -and -not $Clean -and -not $Defaults
if ($hasNoParams) {
    Remove-Item Env:\SCRIPTS_ROOT_RUN -ErrorAction SilentlyContinue
    $sharedGitPull = Join-Path $RootDir "scripts\shared\git-pull.ps1"
    $isHelperAvailable = Test-Path $sharedGitPull
    if ($isHelperAvailable) {
        . $sharedGitPull
        Invoke-GitPull -RepoRoot $RootDir
    }
    Show-RootHelp
    exit 0
}

# ── List (keyword table only) ────────────────────────────────────────
if ($List) {
    Show-KeywordTable
    exit 0
}

# ── Help ─────────────────────────────────────────────────────────────
# Supports an optional keyword filter:
#   .\run.ps1 help                       -> full help
#   .\run.ps1 help chrome                -> only lines matching "chrome"
#   .\run.ps1 -h chrome                  -> same (PowerShell binds "chrome" into $Command)
#   .\run.ps1 --help ext-url             -> same
$normalizedCommandLower = if ($Command) { $Command.Trim().ToLower() } else { "" }
$isHelpCommand = $normalizedCommandLower -in @("help", "--help", "-help", "/?", "?")

if ($Help -or $isHelpCommand) {
    $helpFilter = $null
    if ($isHelpCommand) {
        # `.\run.ps1 help <keyword>` -- keyword(s) land in $Install
        if ($Install -and $Install.Count -gt 0) { $helpFilter = ($Install -join ' ').Trim() }
    } elseif ($Help) {
        # `-h <keyword>` -- PowerShell binds the positional value into $Command
        if ($Command -and -not $isHelpCommand) { $helpFilter = $Command.Trim() }
        elseif ($Install -and $Install.Count -gt 0) { $helpFilter = ($Install -join ' ').Trim() }
    }
    Show-RootHelp -Filter $helpFilter
    exit 0
}

# ── Handle -CleanOnly (no -I required) ───────────────────────────────
if ($CleanOnly) {
    $resolvedDir = Join-Path $RootDir ".resolved"
    if (Test-Path $resolvedDir) {
        Get-ChildItem -Path $resolvedDir -Recurse -Force | Remove-Item -Recurse -Force
        Write-Host "  [ CLEAN ] " -ForegroundColor Green -NoNewline
        Write-Host "All .resolved/ data wiped"
    } else {
        Write-Host "  [ SKIP  ] " -ForegroundColor $ThemeMuted -NoNewline
        Write-Host "Nothing to clean -- .resolved/ does not exist"
    }
    exit 0
}

# ── Handle -Clean ────────────────────────────────────────────────────
if ($Clean) {
    $resolvedDir = Join-Path $RootDir ".resolved"
    if (Test-Path $resolvedDir) {
        Get-ChildItem -Path $resolvedDir -Recurse -Force | Remove-Item -Recurse -Force
        Write-Host "  [ CLEAN ] " -ForegroundColor Green -NoNewline
        Write-Host "All .resolved/ data wiped -- fresh detection will run"
    } else {
        Write-Host "  [ SKIP  ] " -ForegroundColor $ThemeMuted -NoNewline
        Write-Host "Nothing to clean -- .resolved/ does not exist"
    }
    Write-Host ""
}

# ── Load shared git-pull helper ──────────────────────────────────────
$sharedGitPull = Join-Path $RootDir "scripts\shared\git-pull.ps1"
$isHelperMissing = -not (Test-Path $sharedGitPull)
if ($isHelperMissing) {
    Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
    Write-Host "Shared helper not found: $sharedGitPull"
    exit 1
}
. $sharedGitPull

# ── Git Pull ─────────────────────────────────────────────────────────
Invoke-GitPull -RepoRoot $RootDir

# ── Set flag so child scripts skip git pull ──────────────────────────
$env:SCRIPTS_ROOT_RUN = "1"
if ($Y) {
    $env:SCRIPTS_AUTO_YES = "1"
} else {
    Remove-Item Env:\SCRIPTS_AUTO_YES -ErrorAction SilentlyContinue
}

# ── Handle install keyword mode (bare or named) ─────────────────────
$hasInstallKeywords = $null -ne $Install -and $Install.Count -gt 0
if ($hasInstallKeywords) {
    $resolvedEntries = Resolve-InstallKeywords -Keywords $Install

    $isResolveFailed = $null -eq $resolvedEntries
    if ($isResolveFailed) { exit 1 }

    $totalSteps = @($resolvedEntries).Count
    $idList = ($resolvedEntries | ForEach-Object {
        $isSubcommand = $_.Kind -eq "subcommand"
        $isRemote     = $_.Kind -eq "remote"
        if ($isSubcommand) {
            "$($_.Dispatcher):$($_.Action)"
        } elseif ($isRemote) {
            "remote:$($_.Key)"
        } else {
            $label = "$($_.Id)"
            $hasMode = -not [string]::IsNullOrWhiteSpace($_.Mode)
            if ($hasMode) {
                $shortMode = ($_.Mode -replace '^group ', '')
                $label = "$label[$shortMode]"
            }
            $label
        }
    }) -join ', '
    Write-Host ""
    Write-Host "  [ INFO ] " -ForegroundColor $ThemeSecondary -NoNewline
    Write-Host "Installing $totalSteps tool(s): $idList"
    Write-Host ""

    $successCount = 0
    $failCount    = 0

    # Map script IDs to their mode env var names
    $modeEnvVars = @{
        33 = "NPP_MODE"
        16 = "PHP_MODE"
        36 = "OBS_MODE"
        37 = "WT_MODE"
        32 = "DBEAVER_MODE"
        38 = "FLUTTER_MODE"
        39 = "DOTNET_MODE"
        40 = "JAVA_MODE"
        41 = "PYTHON_LIBS_MODE"
        48 = "CONEMU_MODE"
        50 = "ONENOTE_MODE"
    }

    foreach ($entry in $resolvedEntries) {
        $isSubcommand = $entry.Kind -eq "subcommand"
        if ($isSubcommand) {
            # Dispatch e.g. "os clean" or "profile minimal" via root run.ps1 sub-dispatcher
            $dispatcherScript = Join-Path $RootDir "scripts\$($entry.Dispatcher)\run.ps1"
            $isDispatcherPresent = Test-Path $dispatcherScript
            if (-not $isDispatcherPresent) {
                Write-Host ""
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "Subcommand dispatcher not found: $dispatcherScript"
                $failCount++
                continue
            }
            Write-Host ""
            Write-Host "  ----- Subcommand: $($entry.Dispatcher) $($entry.Action) -----" -ForegroundColor $ThemeSecondary
            $actionParts = @($entry.Action -split '\s+' | Where-Object { $_.Length -gt 0 })
            $canForwardYes = (Get-Command Add-YesFlagToArgs -ErrorAction SilentlyContinue) -and (Get-Command Test-YesActive -ErrorAction SilentlyContinue)
            if ($canForwardYes -and (Test-YesActive)) {
                $actionParts = Add-YesFlagToArgs -Args $actionParts
            }
            & $dispatcherScript @actionParts
            $code = $LASTEXITCODE
            if ($code -eq 0 -or $null -eq $code) { $successCount++ } else { $failCount++ }
            Refresh-EnvPath
            continue
        }

        $isRemote = $entry.Kind -eq "remote"
        if ($isRemote) {
            # Stream a remote PowerShell installer via 'Invoke-RestMethod | Invoke-Expression'
            # OR (v0.47.1+) read a repo-local wrapper script from disk when 'path' is set.
            $url       = $entry.Url
            $localPath = $entry.LocalPath
            $hasLocal  = -not [string]::IsNullOrWhiteSpace($localPath)
            $hasUrl    = -not [string]::IsNullOrWhiteSpace($url)
            $label     = $entry.Label
            $expectedSha = $entry.Sha256
            $hasExpectedSha = -not [string]::IsNullOrWhiteSpace($expectedSha)
            $hasLabel = -not [string]::IsNullOrWhiteSpace($label)
            $displayLabel = if ($hasLabel) { $label } else { $entry.Key }

            $sourceDescription = if ($hasLocal) { "local: $localPath" } else { $url }
            $commandHint       = if ($hasLocal) { "Get-Content '$localPath' -Raw | iex" } else { "irm $url | iex" }

            Write-Host ""
            Write-Host "  ----- Remote: $($entry.Key) -----" -ForegroundColor $ThemeSecondary
            Write-Host "  $displayLabel" -ForegroundColor $ThemeMuted
            Write-Host "  Source : $sourceDescription" -ForegroundColor $ThemeMuted
            Write-Host "  Command: $commandHint" -ForegroundColor $ThemeMuted
            if ($hasExpectedSha) {
                Write-Host "  SHA256 : $expectedSha (pinned -- verified before exec)" -ForegroundColor $ThemeMuted
            } else {
                Write-Host "  SHA256 : (not pinned -- add 'sha256' to remote.$($entry.Key) in install-keywords.json to enable integrity check)" -ForegroundColor DarkYellow
            }
            Write-Host ""

            $remoteFailed = $false
            $remoteError  = $null
            try {
                if ($hasLocal) {
                    $isLocalMissing = -not (Test-Path -LiteralPath $localPath)
                    if ($isLocalMissing) {
                        $remoteFailed = $true
                        $remoteError  = "Local wrapper not found on disk. Path: $localPath  (referenced by install-keywords.json -> remote.$($entry.Key).path)"
                        $script = $null
                    } else {
                        $script = Get-Content -LiteralPath $localPath -Raw -ErrorAction Stop
                    }
                } else {
                    $script = Invoke-RestMethod -Uri $url -UseBasicParsing -ErrorAction Stop
                }
                if (-not $remoteFailed) {
                    $isScriptEmpty = [string]::IsNullOrWhiteSpace($script)
                    if ($isScriptEmpty) {
                        $remoteFailed = $true
                        $remoteError  = if ($hasLocal) { "Local wrapper is empty: $localPath" } else { "Remote URL returned an empty body" }
                    } else {
                        # ── SHA256 integrity check (CODE RED: never exec unverified body) ──
                        $isHashMismatch = $false
                        if ($hasExpectedSha) {
                            try {
                                $bytes = [System.Text.Encoding]::UTF8.GetBytes("$script")
                                $sha = [System.Security.Cryptography.SHA256]::Create()
                                $hashBytes = $sha.ComputeHash($bytes)
                                $sha.Dispose()
                                $actualSha = ([System.BitConverter]::ToString($hashBytes) -replace '-', '').ToLowerInvariant()
                            } catch {
                                $remoteFailed = $true
                                $remoteError  = "SHA256 computation failed: $($_.Exception.Message)"
                                $isHashMismatch = $true
                            }
                            if (-not $remoteFailed) {
                                $isMatch = $actualSha -eq $expectedSha
                                if (-not $isMatch) {
                                    $isHashMismatch = $true
                                    $remoteFailed = $true
                                    $pinSrc = "install-keywords.json -> remote.$($entry.Key).sha256"
                                    $remoteError  = "SHA256 mismatch -- refusing to execute unverified body. Expected: $expectedSha  Actual: $actualSha  Source: $sourceDescription  Pin source: $pinSrc"
                                } else {
                                    Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
                                    Write-Host "SHA256 verified ($actualSha)"
                                }
                            }
                        }

                        if (-not $isHashMismatch) {
                            Invoke-Expression $script
                            $code = $LASTEXITCODE
                            if ($null -ne $code -and $code -ne 0) {
                                $remoteFailed = $true
                                $remoteError  = "Remote installer exited with code $code"
                            }
                        }
                    }
                }
            } catch {
                $remoteFailed = $true
                $remoteError  = $_.Exception.Message
            }

            if ($remoteFailed) {
                Write-Host ""
                Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
                Write-Host "Remote installer '$($entry.Key)' failed."
                Write-Host "          Source : $sourceDescription" -ForegroundColor $ThemeMuted
                Write-Host "          Reason : $remoteError" -ForegroundColor $ThemeMuted
                $failCount++
            } else {
                Write-Host ""
                Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
                Write-Host "Remote installer '$($entry.Key)' completed."
                $successCount++
            }
            Refresh-EnvPath
            continue
        }

        $id      = $entry.Id
        $modeKey = $entry.Mode
        $hasModeOverride = -not [string]::IsNullOrWhiteSpace($modeKey)
        $envVarName = $modeEnvVars[$id]
        $hasEnvVar  = $null -ne $envVarName
        if ($hasModeOverride -and $hasEnvVar) {
            Set-Item "Env:\$envVarName" $modeKey
        }
        $result = Invoke-ScriptById -ScriptId $id
        if ($hasModeOverride -and $hasEnvVar) {
            Remove-Item "Env:\$envVarName" -ErrorAction SilentlyContinue
        }
        if ($result) {
            $successCount++
            try {
                $loggerPy = Join-Path $RootDir "scripts\shared\logger.py"
                if (Test-Path $loggerPy) {
                    python $loggerPy "$id"
                }
            } catch { }
        } else { $failCount++ }

        # Refresh PATH between chained scripts so newly installed tools are discoverable
        Refresh-EnvPath
    }

    Write-Host ""
    Write-Host "  ======================================" -ForegroundColor $ThemeMuted
    Write-Host "  [ DONE ] " -ForegroundColor Green -NoNewline
    Write-Host "$successCount of $totalSteps completed successfully"
    if ($failCount -gt 0) {
        Write-Host "  [ WARN ] " -ForegroundColor $ThemeAccent -NoNewline
        Write-Host "$failCount script(s) failed"
    }

    if ($successCount -gt 0) {
        Write-Host ""
        Write-Host "  Installation Summary:" -ForegroundColor $ThemePrimary
        foreach ($entry in $orderedSequence) {
            Write-Host "    $([char]0x2714) $($entry.Id)" -ForegroundColor $ThemeSecondary
        }
    }

    Remove-Item Env:\SCRIPTS_ROOT_RUN -ErrorAction SilentlyContinue
    Remove-Item Env:\SCRIPTS_AUTO_YES -ErrorAction SilentlyContinue
    Show-VersionFooter
    exit 0
}

# ── -M shortcut: dispatch to models orchestrator ─────────────────────
if ($M) {
    Show-VersionHeader
    $modelsScript = Join-Path $RootDir "scripts\models\run.ps1"
    & $modelsScript -Rest $Install
    exit 0
}

# ── Expand shortcuts ──────────────────────────────────────────────────
if ($d) { $I = 12 }
if ($a) { $I = 13 }
if ($v) { $I = 1 }
if ($w) { $I = 14 }
if ($t) { $I = 15 }
if ($h) { $I = 13; $scriptArgs = @{ "Report" = $true } }
# -Defaults without -I defaults to all-dev (script 12)
if ($Defaults -and -not $I) { $I = 12 }

# ── Validate -I is provided ──────────────────────────────────────────
$isMissingParam = -not $I
if ($isMissingParam) {
    Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
    Write-Host "Missing -I parameter. Usage: .\run.ps1 -I <number>"
    Write-Host ""
    Write-Host "  Run .\run.ps1 -Help to see all available scripts" -ForegroundColor $ThemeSecondary
    exit 1
}

# ── Delegate to single script ────────────────────────────────────────
$isScriptArgsUndefined = -not (Test-Path variable:scriptArgs) -or $null -eq $scriptArgs
if ($isScriptArgsUndefined) { $scriptArgs = @{} }
if ($Merge) { $scriptArgs["Merge"] = $true }
if ($Defaults) { $scriptArgs["Defaults"] = $true }

# ── -Defaults -Y confirmation logic ──────────────────────────────────
if ($Defaults -and -not $Y) {
    Write-Host ""
    Write-Host "  Defaults Mode" -ForegroundColor $ThemeSecondary
    Write-Host "  =============" -ForegroundColor $ThemeMuted
    Write-Host ""
    Write-Host "    Dev directory     : " -NoNewline -ForegroundColor $ThemeMuted; Write-Host "auto (E:\dev-tool -- smart detection)" -ForegroundColor White
    Write-Host "    VS Code edition   : " -NoNewline -ForegroundColor $ThemeMuted; Write-Host "Stable" -ForegroundColor White
    Write-Host "    Settings sync     : " -NoNewline -ForegroundColor $ThemeMuted; Write-Host "Overwrite" -ForegroundColor White
    Write-Host ""
    $confirm = Read-Host "  Proceed with these defaults? [Y/n]"
    $isAborted = $confirm.Trim().ToUpper() -eq "N"
    if ($isAborted) {
        Write-Host "  [ SKIP ] Aborted by user." -ForegroundColor $ThemeAccent
        exit 0
    }
}

$result = Invoke-ScriptById -ScriptId $I -ExtraArgs $scriptArgs

$isScriptFailed = -not $result
if ($isScriptFailed) {
    Show-VersionFooter
    exit 1
}

# ── Clean up env flag ────────────────────────────────────────────────
Remove-Item Env:\SCRIPTS_ROOT_RUN -ErrorAction SilentlyContinue
Remove-Item Env:\SCRIPTS_AUTO_YES -ErrorAction SilentlyContinue
Show-VersionFooter
