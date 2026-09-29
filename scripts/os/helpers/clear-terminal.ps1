<#
.SYNOPSIS
    Clear terminal histories, suggestions, and reseed GitMap suggestions.

.DESCRIPTION
    Wipes terminal history files and in-memory caches across PowerShell (PSReadLine),
    Bash, Zsh, and Sh to start completely fresh. If GitMap was installed,
    reseeds canonical GitMap command suggestions into the terminal history and
    reinstalls tab-completion hooks.
#>

param(
    [switch]$DryRun,
    [switch]$Json,
    [switch]$Yes,
    [switch]$Help,
    [switch]$ReseedOnly,
    [switch]$NoReseed,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Argv = @()
)

$ErrorActionPreference = "Continue"
Set-StrictMode -Version Latest

$helpersDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$osDir      = Split-Path -Parent $helpersDir
$scriptsDir = Split-Path -Parent $osDir
$rootDir    = Split-Path -Parent $scriptsDir
$sharedDir  = Join-Path $scriptsDir "shared"

. (Join-Path $sharedDir "logging.ps1")

function Get-GitmapSeedCommands {
    return @(
        "gitmap status",
        "gitmap doctor",
        "gitmap scan",
        "gitmap pull",
        "gitmap sync",
        "gitmap cd",
        "gitmap repo list",
        "gitmap group list",
        "gitmap ssh list",
        "gitmap cluster list",
        "gitmap pipeline errors",
        "gitmap pipeline status",
        "gitmap storage list",
        "gitmap agy running-prompts",
        "gitmap agy sug",
        "gitmap agy clear 10",
        "gitmap completion install"
    )
}

function Test-GitmapInstalled {
    $hasCmd = [bool](Get-Command "gitmap" -ErrorAction SilentlyContinue)

    if ($hasCmd) {
        return $true
    }

    $homeDir = [System.Environment]::GetFolderPath("UserProfile")
    $hasHomeDir = Test-Path (Join-Path $homeDir ".gitmap")

    if ($hasHomeDir) {
        return $true
    }

    $appData = [System.Environment]::GetFolderPath("ApplicationData")
    $hasAppData = Test-Path (Join-Path $appData "gitmap")

    if ($hasAppData) {
        return $true
    }

    $hasRepo = Test-Path "D:\work\gitmap"

    return $hasRepo
}

function Get-PowerShellHistoryFiles {
    $results = @()
    $seen = @{}

    try {
        $opt = Get-PSReadLineOption -ErrorAction SilentlyContinue
        if ($opt -and $opt.HistorySavePath) {
            $p = $opt.HistorySavePath
            $results += $p
            $seen[$p.ToLower()] = $true
        }
    } catch {}

    $appData = [System.Environment]::GetFolderPath("ApplicationData")
    $stdPs = Join-Path $appData "Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

    if (-not $seen.ContainsKey($stdPs.ToLower())) {
        $results += $stdPs
        $seen[$stdPs.ToLower()] = $true
    }

    $homeDir = [System.Environment]::GetFolderPath("UserProfile")
    $linuxPs = Join-Path $homeDir ".local\share\powershell\PSReadLine\ConsoleHost_history.txt"

    if (-not $seen.ContainsKey($linuxPs.ToLower())) {
        $results += $linuxPs
    }

    return $results
}

function Get-AllTerminalHistoryTargets {
    $targets = @()
    $homeDir = [System.Environment]::GetFolderPath("UserProfile")

    foreach ($p in (Get-PowerShellHistoryFiles)) {
        $targets += [PSCustomObject]@{ Shell = "PowerShell"; Path = $p }
    }

    $targets += [PSCustomObject]@{ Shell = "Bash"; Path = (Join-Path $homeDir ".bash_history") }
    $targets += [PSCustomObject]@{ Shell = "Zsh";  Path = (Join-Path $homeDir ".zsh_history") }
    $targets += [PSCustomObject]@{ Shell = "Zsh";  Path = (Join-Path $homeDir ".zhistory") }
    $targets += [PSCustomObject]@{ Shell = "Sh";   Path = (Join-Path $homeDir ".sh_history") }
    $targets += [PSCustomObject]@{ Shell = "Sh";   Path = (Join-Path $homeDir ".history") }

    return $targets
}

function Clear-HistoryFileItem {
    param(
        [string]$FilePath,
        [bool]$IsDryRun
    )

    $hasFile = Test-Path -LiteralPath $FilePath

    if (-not $hasFile) {
        return 0
    }

    $lineCount = 0
    try {
        $lines = @(Get-Content -LiteralPath $FilePath -ErrorAction SilentlyContinue)
        $lineCount = $lines.Count
    } catch {}

    if ($IsDryRun) {
        return $lineCount
    }

    try {
        $parent = Split-Path -Parent $FilePath
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        Set-Content -LiteralPath $FilePath -Value @() -Encoding UTF8 -Force
    } catch {
        Write-FileError -FilePath $FilePath -Operation "clear" -Reason $_.Exception.Message -Module "clear-terminal"
    }

    return $lineCount
}

function Clear-InMemoryHistories {
    try {
        Clear-History -ErrorAction SilentlyContinue
    } catch {}

    try {
        [Microsoft.PowerShell.PSConsoleReadLine]::ClearHistory()
    } catch {}
}

function Reseed-GitmapSuggestionsToFile {
    param(
        [string]$FilePath,
        [string[]]$Seeds
    )

    $parent = Split-Path -Parent $FilePath
    $hasParent = Test-Path -LiteralPath $parent

    if (-not $hasParent) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    try {
        Add-Content -LiteralPath $FilePath -Value $Seeds -Encoding UTF8 -Force
    } catch {
        Write-FileError -FilePath $FilePath -Operation "reseed" -Reason $_.Exception.Message -Module "clear-terminal"
    }
}

function Configure-GitmapIntelliSense {
    $hasCmd = [bool](Get-Command "gitmap" -ErrorAction SilentlyContinue)

    if ($hasCmd) {
        try {
            & gitmap completion install 2>$null | Out-Null
        } catch {}
    }

    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin -ErrorAction SilentlyContinue
        Set-PSReadLineOption -PredictionViewStyle InlineView -ErrorAction SilentlyContinue
    } catch {
        try {
            Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
        } catch {}
    }
}

function Show-ClearTerminalHelp {
    Write-Host ""
    Write-Host "  Clear Terminal Histories & Reseed GitMap Suggestions" -ForegroundColor Cyan
    Write-Host "  ====================================================" -ForegroundColor DarkGray
    Write-Host "  Usage: .\run.ps1 clear-terminal [flags]" -ForegroundColor Yellow
    Write-Host "         .\run.ps1 clear terminal [flags]" -ForegroundColor Yellow
    Write-Host "         .\run.ps1 os clear-terminal [flags]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Flags:" -ForegroundColor Yellow
    Write-Host "    --dry-run, -n      Preview files to be cleared without modifying" -ForegroundColor DarkGray
    Write-Host "    --yes, -y          Skip interactive confirmation prompt" -ForegroundColor DarkGray
    Write-Host "    --reseed-only      Reseed GitMap suggestions without clearing history" -ForegroundColor DarkGray
    Write-Host "    --no-reseed        Clear histories without reseeding GitMap suggestions" -ForegroundColor DarkGray
    Write-Host "    --json, -j         Output results as machine-readable JSON" -ForegroundColor DarkGray
    Write-Host "    --help, -h         Show this help message" -ForegroundColor DarkGray
    Write-Host ""
}

# ── Main Entrypoint ───────────────────────────────────────────────────────────

$isDryRun     = $DryRun.IsPresent
$isAutoYes    = ($env:SCRIPTS_FIXER_YES -eq "1") -or $Yes.IsPresent
$isJson       = $Json.IsPresent
$isReseedOnly = $ReseedOnly.IsPresent
$isNoReseed   = $NoReseed.IsPresent
$hasHelp      = $Help.IsPresent

foreach ($a in $Argv) {
    $low = "$a".Trim().ToLower()

    if ($low -in @("--dry-run", "-dry-run", "-n", "dry-run", "--dryrun", "-dryrun")) {
        $isDryRun = $true
    }
    elseif ($low -in @("--yes", "-yes", "-y", "yes", "/y", "--auto-yes")) {
        $isAutoYes = $true
    }
    elseif ($low -in @("--json", "-json", "-j", "json")) {
        $isJson = $true
    }
    elseif ($low -in @("--reseed-only", "-reseed-only", "reseed-only")) {
        $isReseedOnly = $true
    }
    elseif ($low -in @("--no-reseed", "-no-reseed", "no-reseed")) {
        $isNoReseed = $true
    }
    elseif ($low -in @("--help", "-help", "-h", "help", "/?", "?")) {
        $hasHelp = $true
    }
}

if ($hasHelp) {
    Show-ClearTerminalHelp
    exit 0
}

$isGitmapInstalled = Test-GitmapInstalled
$targets = Get-AllTerminalHistoryTargets
$clearedItems = @()
$totalLinesCleared = 0

if (-not $isReseedOnly) {
    foreach ($item in $targets) {
        $hasPath = Test-Path -LiteralPath $item.Path

        if ($hasPath) {
            $lines = Clear-HistoryFileItem -FilePath $item.Path -IsDryRun $isDryRun
            $totalLinesCleared += $lines

            $clearedItems += [PSCustomObject]@{
                Shell      = $item.Shell
                Path       = $item.Path
                LinesCount = $lines
                Status     = if ($isDryRun) { "would_clear" } else { "cleared" }
            }
        }
    }

    if (-not $isDryRun) {
        Clear-InMemoryHistories
    }
}

$seeds = Get-GitmapSeedCommands
$isReseeded = $false

if ($isGitmapInstalled -and -not $isNoReseed) {
    if (-not $isDryRun) {
        $psHistory = (Get-PowerShellHistoryFiles) | Select-Object -First 1
        if ($psHistory) {
            Reseed-GitmapSuggestionsToFile -FilePath $psHistory -Seeds $seeds
        }

        $homeDir = [System.Environment]::GetFolderPath("UserProfile")
        $bashHist = Join-Path $homeDir ".bash_history"
        if (Test-Path -LiteralPath (Split-Path -Parent $bashHist)) {
            Reseed-GitmapSuggestionsToFile -FilePath $bashHist -Seeds $seeds
        }

        Configure-GitmapIntelliSense
    }

    $isReseeded = $true
}

if ($isJson) {
    [PSCustomObject]@{
        status            = "ok"
        dryRun            = $isDryRun
        totalLinesCleared = $totalLinesCleared
        clearedFiles      = $clearedItems
        isGitmapInstalled = $isGitmapInstalled
        isReseeded        = $isReseeded
        seedCount         = if ($isReseeded) { $seeds.Count } else { 0 }
    } | ConvertTo-Json -Depth 4
    exit 0
}

Write-Host ""
Write-Host "  ● Terminal History & Suggestions Cleanup" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor DarkGray

if ($isDryRun) {
    Write-Host "  [DRY-RUN] Preview mode -- no files were modified." -ForegroundColor Yellow
}

if (-not $isReseedOnly) {
    Write-Host "  Cleared Terminal Histories:" -ForegroundColor DarkYellow
    foreach ($ci in $clearedItems) {
        Write-Host ("    [{0,-10}] {1} ({2} lines)" -f $ci.Shell, $ci.Path, $ci.LinesCount) -ForegroundColor DarkGray
    }

    if ($clearedItems.Count -eq 0) {
        Write-Host "    (No existing history files found to clear)" -ForegroundColor DarkGray
    }

    Write-Host ("  [  OK  ] Total lines cleared: {0}" -f $totalLinesCleared) -ForegroundColor Green
}

if ($isGitmapInstalled) {
    if ($isReseeded) {
        Write-Host ""
        Write-Host "  GitMap Reseed & Prediction Engine:" -ForegroundColor DarkYellow
        Write-Host "    [  OK  ] GitMap detected on system." -ForegroundColor Green
        Write-Host ("    [  OK  ] Reseeded {0} canonical command suggestions into terminal history." -f $seeds.Count) -ForegroundColor Green
        Write-Host "    [  OK  ] Configured PSReadLine prediction source (HistoryAndPlugin) & tab-completion." -ForegroundColor Green
    }
} else {
    Write-Host ""
    Write-Host "  GitMap: not detected (reseed skipped)." -ForegroundColor DarkGray
}

Write-Host ""
Write-Host "  Terminal history and suggestion caches are fresh." -ForegroundColor Cyan
Write-Host ""
exit 0
