<#
.SYNOPSIS
    Cross-Platform Work Directory Artifacts & System Cache Cleaner Dispatcher (Windows, macOS, Linux/Unix).

.DESCRIPTION
    Dispatches `clean` / `clear` subcommands to `03-ai-scripts/44-work-and-system-cache-cleaner.py`:
      - clean artifacts / work / build  : Work directory (D:\work, ~/work) build elements & binaries
      - clean all / caches / system     : Full 8-layer sweep (Work, Go, npm/pnpm/Node, DevTools, Temp, WU, Recycle Bin, Git)
      - clean go / go-cache             : Go build, test, fuzz, and module caches (GOCACHE & GOMODCACHE)
      - clean npm / pnpm / node         : npm, pnpm store, Yarn, Bun & Node.js caches (keeps node_modules)
      - clean devtools                  : Chrome/Edge/Brave DevTools & GPU caches, VS Code Cache, Antigravity caches
      - clean temp                      : User & OS temporary directories (%TEMP%, Windows\Temp, /tmp)
      - clean wu-download               : Windows SoftwareDistribution\Download & DeliveryOptimization
      - clean recycle                   : Windows Recycle Bin ($Recycle.Bin), macOS ~/.Trash, Linux Trash
      - clean git-cache                 : Git caches (~/.gitcache), .gitmap temp/logs, stale tmp_pack_*
#>
param(
    [Parameter(Position = 0)]
    [string]$Subcommand = "all",

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest = @()
)

$ErrorActionPreference = "Continue"
$helpersDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$osDir      = Split-Path -Parent $helpersDir
$scriptsDir = Split-Path -Parent $osDir
$repoRoot   = Split-Path -Parent $scriptsDir

$pyCleaner = Join-Path $repoRoot "03-ai-scripts\44-work-and-system-cache-cleaner.py"
if (-not (Test-Path -LiteralPath $pyCleaner)) {
    $pyCleaner = Join-Path $scriptsDir "os-work-cache-cleaner.py"
}

function Show-CleanSubcommandsHelp {
    Write-Host ""
    Write-Host "  ========================================================================================" -ForegroundColor DarkGray
    Write-Host "  Multi-Layer Artifacts & System Cache Cleaner (Windows, macOS & Linux/Unix)" -ForegroundColor Cyan
    Write-Host "  ========================================================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  USAGE:" -ForegroundColor Yellow
    Write-Host "    Windows (PowerShell) : .\run.ps1 clean <subcommand> [--dry-run] [-y] [--work-dir <path>]" -ForegroundColor White
    Write-Host "                           .\run.ps1 clear <subcommand> [--dry-run] [-y]" -ForegroundColor White
    Write-Host "    macOS / Linux (Bash) : ./run.sh clean <subcommand> [--dry-run] [-y] [--work-dir <path>]" -ForegroundColor White
    Write-Host "                           ./run.sh clear <subcommand> [--dry-run] [-y]" -ForegroundColor White
    Write-Host "    Direct Python Script : python 03-ai-scripts/44-work-and-system-cache-cleaner.py [--dry-run] [-y]" -ForegroundColor White
    Write-Host ""
    Write-Host "  SUBCOMMANDS:" -ForegroundColor Yellow
    Write-Host "    all | caches | full        Run all 8 cleanup layers (Plan preview -> prompt or -y -> summary)" -ForegroundColor Green
    Write-Host "    artifacts | work | build   Clean work dir (D:\work, ~/work) dist/build/target/tmp/.cache & binaries" -ForegroundColor Green
    Write-Host "                               (Strictly keeps node_modules packages & git-tracked files intact)" -ForegroundColor DarkGray
    Write-Host "    go | go-cache              Clean Go build cache (GOCACHE), module cache (GOMODCACHE), test/fuzz cache" -ForegroundColor Green
    Write-Host "    npm | pnpm | node          Clean npm cache, pnpm CAS store (.pnpm-store), Yarn, Bun, node-gyp" -ForegroundColor Green
    Write-Host "    devtools | browser-cache   Clean Browser DevTools/GPU cache (Chrome/Edge), VS Code & Antigravity cache" -ForegroundColor Green
    Write-Host "    temp | tmp                 Clean OS & user temp dirs (%TEMP%, %LOCALAPPDATA%\Temp, Windows\Temp, /tmp)" -ForegroundColor Green
    Write-Host "    wu-download | wu           Clean Windows SoftwareDistribution\Download & DeliveryOptimization (or apt/brew)" -ForegroundColor Green
    Write-Host "    recycle | trash            Empty Windows Recycle Bin (Clear-RecycleBin), macOS ~/.Trash, Linux Trash" -ForegroundColor Green
    Write-Host "    git-cache | git            Clean Git cache folders (~/.gitcache), .gitmap temp/logs, stale tmp_pack_*" -ForegroundColor Green
    Write-Host "    dev | dev-cleanup          Run full developer toolchain cache sweep (Go, pnpm, npm, Choco, Cargo, pip)" -ForegroundColor Green
    Write-Host "    terminal                   Wipe terminal command history & reseed suggestions" -ForegroundColor Green
    Write-Host "    agy | antigravity          Prune Antigravity conversations & scrub GPU/Electron caches" -ForegroundColor Green
    Write-Host ""
    Write-Host "  FLAGS:" -ForegroundColor Yellow
    Write-Host "    --dry-run, --plan, -n, -d  Plan Mode: scan and display detailed table of items & sizes without deleting" -ForegroundColor DarkGray
    Write-Host "    -y, --yes, --force         Auto-approve deletion after displaying the Plan table (skip [y/N] prompt)" -ForegroundColor DarkGray
    Write-Host "    --work-dir, -w <path>      Override work directory to scan (default: auto-detect D:\work or ~/work)" -ForegroundColor DarkGray
    Write-Host "    --only <cat1,cat2>         Run only specific category IDs" -ForegroundColor DarkGray
    Write-Host "    --skip <cat1,cat2>         Skip specific category IDs" -ForegroundColor DarkGray
    Write-Host "    --json                     Emit machine-readable JSON plan or execution summary" -ForegroundColor DarkGray
    Write-Host "    --help, -h                 Show this detailed help menu" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  EXAMPLES (Windows / macOS / Linux):" -ForegroundColor Yellow
    Write-Host "    .\run.ps1 clean --help                        # Show this detailed cleaning guide" -ForegroundColor DarkGray
    Write-Host "    .\run.ps1 clean all --dry-run                 # Preview all 8 layers & reclaimable GBs (Plan Mode)" -ForegroundColor DarkGray
    Write-Host "    .\run.ps1 clean all -y                        # Clean all 8 layers automatically & show space saved" -ForegroundColor DarkGray
    Write-Host "    .\run.ps1 clean artifacts --dry-run           # Preview D:\work build folders & binaries to remove" -ForegroundColor DarkGray
    Write-Host "    .\run.ps1 clean artifacts -y                  # Remove D:\work build folders & binaries automatically" -ForegroundColor DarkGray
    Write-Host "    .\run.ps1 clean go -y                         # Purge Go GOCACHE & GOMODCACHE" -ForegroundColor DarkGray
    Write-Host "    .\run.ps1 clean npm -y                        # Purge npm, pnpm store, Yarn, Bun & Node caches" -ForegroundColor DarkGray
    Write-Host "    .\run.ps1 clean wu-download -y                # Purge Windows SoftwareDistribution\Download" -ForegroundColor DarkGray
    Write-Host "    .\run.ps1 clean recycle -y                    # Empty Recycle Bin / Trash" -ForegroundColor DarkGray
    Write-Host "    ./run.sh clean all --dry-run                  # macOS / Linux Plan Mode preview" -ForegroundColor DarkGray
    Write-Host "    ./run.sh clean all -y                         # macOS / Linux full cache & artifact cleanup" -ForegroundColor DarkGray
    Write-Host ""
}

$normSub = "$Subcommand".Trim().ToLower()
$hasHelpFlag = ($normSub -in @("help", "--help", "-help", "-h", "/?", "?")) -or ($Rest | Where-Object { "$_".Trim().ToLower() -in @("help", "--help", "-help", "-h", "/?", "?") })

if ($hasHelpFlag) {
    Show-CleanSubcommandsHelp
    exit 0
}

if (-not (Test-Path -LiteralPath $pyCleaner)) {
    Write-Host "  [ FAIL ] Python cleaner script not found at: $pyCleaner" -ForegroundColor Red
    exit 1
}

$onlyFilter = ""
switch ($normSub) {
    { $_ -in @("artifacts", "artifact", "work", "work-artifacts", "build", "builds", "binaries", "binary") } {
        $onlyFilter = "work-artifacts"
    }
    { $_ -in @("go", "golang", "go-cache", "gocache", "gomodcache") } {
        $onlyFilter = "go-cache"
    }
    { $_ -in @("npm", "pnpm", "node", "nodejs", "npm-cache", "pnpm-cache", "pnpm-store", "yarn", "bun", "npm-pnpm-node-cache") } {
        $onlyFilter = "npm-pnpm-node-cache"
    }
    { $_ -in @("devtools", "devtools-cache", "browser-cache", "vscode-cache") } {
        $onlyFilter = "devtools-cache"
    }
    { $_ -in @("temp", "tmp", "temp-dirs", "tempdir", "tempdirs") } {
        $onlyFilter = "temp-dirs"
    }
    { $_ -in @("wu", "wu-download", "windows-update", "softwaredistribution", "software-distribution") } {
        $onlyFilter = "windows-update"
    }
    { $_ -in @("recycle", "recycle-bin", "recyclebin", "trash") } {
        $onlyFilter = "recycle-bin"
    }
    { $_ -in @("git", "git-cache", "gitcache", "gitmap-cache") } {
        $onlyFilter = "git-cache"
    }
    default {
        # "all", "caches", "full", "system", or empty runs all 8 layers
        $onlyFilter = ""
    }
}

[string[]]$pyArgs = @()
if ($onlyFilter) {
    $pyArgs += "--only"
    $pyArgs += $onlyFilter
}
if ($env:SCRIPTS_FIXER_YES -eq "1") {
    $pyArgs += "--yes"
}
if ($Rest -and $Rest.Count -gt 0) {
    foreach ($tok in $Rest) {
        if (-not [string]::IsNullOrWhiteSpace("$tok")) {
            $pyArgs += "$tok".Trim()
        }
    }
}

& python $pyCleaner @pyArgs
exit $LASTEXITCODE
