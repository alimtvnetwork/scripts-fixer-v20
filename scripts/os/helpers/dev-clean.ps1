<#
.SYNOPSIS
    os dev-cleanup / clean-dev -- Developer Tools Cache Remover.

.DESCRIPTION
    Reclaims disk space occupied by developer runtimes, compilers, package managers,
    and build caches:
      1. Go: 'go clean -cache -modcache -testcache -fuzzcache' + build/module cache sweep.
      2. pnpm: 'pnpm store prune' + <DEV_DIR>\pnpm\store + %LOCALAPPDATA%\pnpm\store.
      3. npm: 'npm cache clean --force' + %LOCALAPPDATA%\npm-cache.
      4. Chocolatey: 'choco cache clean' + %LOCALAPPDATA%\Chocolatey\Cache.
      5. Yarn: 'yarn cache clean' + %LOCALAPPDATA%\Yarn\Cache.
      6. Bun: 'bun pm cache rm' + %LOCALAPPDATA%\bun\install\cache.
      7. Python: 'pip cache purge' + %LOCALAPPDATA%\pip\cache.
      8. Cargo/Rust: %USERPROFILE%\.cargo\registry\cache + .cargo\git\db.
      9. .NET/NuGet: 'dotnet nuget locals all --clear' + %LOCALAPPDATA%\NuGet\v3-cache.
      10. Gradle/Maven: %USERPROFILE%\.gradle\caches + %USERPROFILE%\.m2\repository.

    Flags:
      --dry-run, -d  Report potential space reclaimed without deleting.
      --yes, -y      Bypass the confirmation prompt.

    CODE RED: every file/path failure logs the exact absolute path + reason.
#>
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Argv = @()
)

$ErrorActionPreference = "Continue"
Set-StrictMode -Version Latest

$helpersDir    = Split-Path -Parent $MyInvocation.MyCommand.Definition
$scriptDir     = Split-Path -Parent $helpersDir
$rootDir       = Split-Path -Parent $scriptDir
$sharedDir     = Join-Path $rootDir "shared"
$categoriesDir = Join-Path $helpersDir "clean-categories"

. (Join-Path $sharedDir "logging.ps1")
. (Join-Path $sharedDir "json-utils.ps1")
. (Join-Path $helpersDir "_common.ps1")
. (Join-Path $categoriesDir "_sweep.ps1")

Initialize-Logging -ScriptName "OS Dev-Cleanup"

$isDryRun = $false
$hasAutoYes = ($env:SCRIPTS_FIXER_YES -eq '1')
$isHelp = $false

foreach ($a in $Argv) {
    $low = "$a".Trim().ToLower()

    if ($low -in @("--dry-run", "-dry-run", "dry-run", "--dryrun", "-n", "-d")) {
        $isDryRun = $true
    }
    elseif ($low -in @("--yes", "-yes", "-y", "yes", "/y", "/yes", "--non-interactive", "--force", "-force")) {
        $hasAutoYes = $true
    }
    elseif ($low -in @("--help", "-help", "-h", "help", "/?", "?")) {
        $isHelp = $true
    }
}

Write-Host ""
Write-Host "  OS Dev-Cleanup (Developer Tools Cache Remover)" -ForegroundColor Cyan
Write-Host "  ==============================================" -ForegroundColor DarkGray
Write-Host "    1. Go             Build cache, test cache, and module downloads" -ForegroundColor DarkGray
Write-Host "    2. pnpm           CAS store prune and dev-tool pnpm store" -ForegroundColor DarkGray
Write-Host "    3. npm            npm cache clean --force and AppData cache" -ForegroundColor DarkGray
Write-Host "    4. Chocolatey     Package installer download cache and temp" -ForegroundColor DarkGray
Write-Host "    5. Yarn           Yarn global package cache" -ForegroundColor DarkGray
Write-Host "    6. Bun            Bun module and install cache" -ForegroundColor DarkGray
Write-Host "    7. Python / pip   pip HTTP download cache" -ForegroundColor DarkGray
Write-Host "    8. Cargo / Rust   Cargo registry cache and git checkouts" -ForegroundColor DarkGray
Write-Host "    9. Gradle         Build tool caches and daemon" -ForegroundColor DarkGray
Write-Host "    10. Maven         Local repository cache" -ForegroundColor DarkGray
Write-Host "    11. .NET / NuGet  Local HTTP and package caches" -ForegroundColor DarkGray
Write-Host "    12. Antigravity   AI caches, task dumps, and build artifacts" -ForegroundColor DarkGray
Write-Host ""

if ($isHelp) {
    Write-Host "  Usage: .\run.ps1 os dev-cleanup [--dry-run] [--yes]" -ForegroundColor White
    Write-Host "         .\run.ps1 clean-dev [--dry-run] [-y]" -ForegroundColor White
    Write-Host ""
    Write-Host "  Flags:" -ForegroundColor Yellow
    Write-Host "    --dry-run, -d    Preview space reclaimed without deleting" -ForegroundColor DarkGray
    Write-Host "    --yes, -y        Bypass confirmation prompt" -ForegroundColor DarkGray
    Write-Host "    --help, -h       Show this help message" -ForegroundColor DarkGray
    Write-Host ""
    exit 0
}

if ($isDryRun) {
    Write-Host "  [DRY-RUN] Preview only. No cache files will be deleted." -ForegroundColor Yellow
    Write-Host ""
}

$isPromptNeeded = -not $isDryRun -and -not $hasAutoYes
if ($isPromptNeeded) {
    Write-Host "  Proceed with dev tools cache cleanup? Type 'yes' to continue: " -NoNewline -ForegroundColor Yellow
    $reply = Read-Host
    $isConfirmed = $reply.Trim().ToLower() -eq "yes"

    if (-not $isConfirmed) {
        Write-Host "  Aborted by operator." -ForegroundColor Red
        Save-LogFile -Status "fail"
        exit 1
    }
}

$script:TotalBytesFreed = 0
$script:TotalItemsRemoved = 0
$script:StepIssuesCount = 0
$runner = Join-Path $helpersDir "clean-runner.ps1"

function Format-ByteSize {
    param([long]$Bytes)

    if ($Bytes -ge 1GB) {
        return ("{0:N2} GB" -f ($Bytes / 1GB))
    }

    if ($Bytes -ge 1MB) {
        return ("{0:N1} MB" -f ($Bytes / 1MB))
    }

    if ($Bytes -ge 1KB) {
        return ("{0:N0} KB" -f ($Bytes / 1KB))
    }

    return "$Bytes B"
}

function Invoke-DevStep {
    param(
        [string]$CategoryName,
        [string]$StepLabel
    )

    Write-Host ""
    Write-Host "  ---- $StepLabel ----" -ForegroundColor Cyan

    $forwardArgs = @()
    if ($isDryRun) {
        $forwardArgs += "--dry-run"
    }

    if ($hasAutoYes) {
        $forwardArgs += "--yes"
    }

    $helperFile = Join-Path $categoriesDir "$CategoryName.ps1"
    $isHelperFound = Test-Path -LiteralPath $helperFile
    if (-not $isHelperFound) {
        Write-Host "  [ SKIP ] Category helper missing: $CategoryName" -ForegroundColor DarkGray
        return
    }

    try {
        $catResult = & $helperFile -DryRun:$isDryRun -Yes:$hasAutoYes

        if ($null -eq $catResult) {
            Write-Host "  [ SKIP ] No result returned for $CategoryName" -ForegroundColor DarkGray
            return
        }

        $freedBytes = if ($isDryRun) { $catResult.WouldBytes } else { $catResult.Bytes }
        $freedCount = if ($isDryRun) { $catResult.WouldCount } else { $catResult.Count }

        $script:TotalBytesFreed += [long]$freedBytes
        $script:TotalItemsRemoved += [int]$freedCount

        $sizeLabel = Format-ByteSize -Bytes $freedBytes
        $statusTag = if ($isDryRun) { "[DRY-RUN]" } else { "[  OK  ]" }

        Write-Host "  $statusTag Cleaned $CategoryName : $sizeLabel freed ($freedCount item(s))" -ForegroundColor Green

        $hasLockedFiles = $catResult.Locked -gt 0
        if ($hasLockedFiles) {
            Write-Host "  [ WARN ] $($catResult.Locked) item(s) locked or in use" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  [ FAIL ] $StepLabel failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-FileError -FilePath $helperFile -Operation "execute" -Reason "$($_.Exception.Message)" -Module "dev-clean"
        $script:StepIssuesCount++
    }
}

function Test-IsSafeDevPath {
    param(
        [Alias("Path", "TargetDir")]
        [string]$FilePath
    )

    $isMissing = [string]::IsNullOrWhiteSpace($FilePath)

    if ($isMissing) {
        return $false
    }

    $norm = $FilePath.Trim().Replace('/', '\')
    $isWorkMatch = $norm.ToLower().StartsWith("d:\work\")

    if ($isWorkMatch) {
        return $false
    }

    $isRepoMatch = $norm.ToLower().StartsWith($rootDir.ToLower())

    if ($isRepoMatch) {
        return $false
    }

    return $true
}

function Remove-SafeDevFile {
    param(
        [string]$FilePath,
        [bool]$IsDryMode
    )

    $isSafe = Test-IsSafeDevPath -FilePath $FilePath

    if (-not $isSafe) {
        return 0
    }

    $hasFile = Test-Path -LiteralPath $FilePath -PathType Leaf

    if (-not $hasFile) {
        return 0
    }

    try {
        $item = Get-Item -LiteralPath $FilePath -Force -ErrorAction Stop
        $sz = [long]$item.Length

        if (-not $IsDryMode) {
            Remove-Item -LiteralPath $FilePath -Force -ErrorAction Stop
        }

        return $sz
    } catch {
        Write-FileError -FilePath $FilePath -Operation "remove" -Reason $_.Exception.Message -Module "dev-clean"
        $script:StepIssuesCount++

        return 0
    }
}

function Sweep-SafeDevFileList {
    param(
        [string[]]$Paths,
        [bool]$IsDryMode
    )

    $totBytes = 0
    $totCount = 0

    foreach ($p in $Paths) {
        $sz = Remove-SafeDevFile -FilePath "$p" -IsDryMode $IsDryMode
        $hasRemoved = $sz -gt 0

        if ($hasRemoved) {
            $totBytes += $sz
            $totCount++
        }
    }

    return @{ Bytes = $totBytes; Count = $totCount }
}

function Get-StaleDevCacheFiles {
    $targetDirs = @(
        (Join-Path $env:APPDATA "Code\Cache"),
        (Join-Path $env:APPDATA "Code\CachedData"),
        (Join-Path $env:APPDATA "Code\CachedExtensionVSIXs"),
        (Join-Path $env:LOCALAPPDATA "Temp\vscode-cache"),
        (Join-Path $env:TEMP "gitmap"),
        (Join-Path $env:USERPROFILE ".gitmap\temp"),
        (Join-Path $env:USERPROFILE ".gitmap\purge"),
        (Join-Path $env:LOCALAPPDATA "pip\cache\wheels")
    )

    $discovered = @()

    foreach ($d in $targetDirs) {
        $isSafe = Test-IsSafeDevPath -FilePath $d
        $hasDir = $isSafe -and (Test-Path -LiteralPath $d -PathType Container)

        if ($hasDir) {
            $files = Get-ChildItem -LiteralPath $d -Recurse -File -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

            if ($files) {
                $discovered += @($files)
            }
        }
    }

    return $discovered
}

function Invoke-AiCleanScriptScan {
    $aiCleanScript = Join-Path $scriptDir "os-ai-clean.py"
    $isMissing = -not (Test-Path -LiteralPath $aiCleanScript)

    if ($isMissing) {
        return $null
    }

    try {
        $jsonOut = & python $aiCleanScript --dry-run --json 2>$null | Out-String
        $isJsonEmpty = [string]::IsNullOrWhiteSpace($jsonOut)

        if ($isJsonEmpty) {
            return $null
        }

        return ($jsonOut | ConvertFrom-Json)
    } catch {
        return $null
    }
}

function Invoke-AgyClearHelper {
    param(
        [bool]$IsDryMode,
        [bool]$IsYesMode
    )

    $agyHelper = Join-Path (Split-Path -Parent (Split-Path -Parent $helpersDir)) "69-install-antigravity\helpers\clear-agy.ps1"
    $isAgyMissing = -not (Test-Path -LiteralPath $agyHelper)

    if ($isAgyMissing) {
        Write-Host "  [ SKIP ] Antigravity clear helper not found" -ForegroundColor DarkGray
        return
    }

    if ($IsDryMode) {
        Write-Host "  [DRY-RUN] Running Antigravity conversation and cache prediction..." -ForegroundColor Yellow
        & $agyHelper -Predict -Keep 10
        return
    }

    try {
        Write-Host "  [  OK  ] Optimizing Antigravity conversation DB & scrubbing caches..." -ForegroundColor Green
        & $agyHelper -Yes -Keep 10
    } catch {
        Write-Host "  [ WARN ] Antigravity cache cleanup failed: $($_.Exception.Message)" -ForegroundColor Yellow
        $script:StepIssuesCount++
    }
}

function Invoke-AiCacheDeepSweep {
    param([bool]$IsDryMode)

    $scanData = Invoke-AiCleanScriptScan
    $hasData = $null -ne $scanData -and $null -ne $scanData.categories

    if (-not $hasData) {
        return
    }

    foreach ($cat in $scanData.categories) {
        $catPaths = @($cat.paths)
        $res = Sweep-SafeDevFileList -Paths $catPaths -IsDryMode $IsDryMode

        $script:TotalBytesFreed += [long]$res.Bytes
        $script:TotalItemsRemoved += [int]$res.Count

        $sizeLabel = Format-ByteSize -Bytes $res.Bytes
        $tag = if ($IsDryMode) { "[DRY-RUN]" } else { "[  OK  ]" }
        Write-Host "  $tag $($cat.name): $sizeLabel ($($res.Count) files)" -ForegroundColor Green
    }
}

function Invoke-StaleBuildArtifactsSweep {
    param([bool]$IsDryMode)

    $staleFiles = Get-StaleDevCacheFiles
    $hasFiles = $staleFiles.Count -gt 0

    if (-not $hasFiles) {
        return
    }

    $res = Sweep-SafeDevFileList -Paths $staleFiles -IsDryMode $IsDryMode
    $script:TotalBytesFreed += [long]$res.Bytes
    $script:TotalItemsRemoved += [int]$res.Count

    $sizeLabel = Format-ByteSize -Bytes $res.Bytes
    $tag = if ($IsDryMode) { "[DRY-RUN]" } else { "[  OK  ]" }
    Write-Host "  $tag Stale Build & Editor Caches: $sizeLabel ($($res.Count) files)" -ForegroundColor Green
}

function Invoke-AntigravityDevStep {
    param(
        [bool]$IsDryMode,
        [bool]$IsYesMode
    )

    Write-Host ""
    Write-Host "  ---- 12. Antigravity & AI Developer Cache ----" -ForegroundColor Cyan

    Invoke-AgyClearHelper -IsDryMode $IsDryMode -IsYesMode $IsYesMode
    Invoke-AiCacheDeepSweep -IsDryMode $IsDryMode
    Invoke-StaleBuildArtifactsSweep -IsDryMode $IsDryMode
}

# Run all developer categories
Invoke-DevStep -CategoryName "go-buildcache"   -StepLabel "1. Go (build cache & module downloads)"
Invoke-DevStep -CategoryName "pnpm-store"      -StepLabel "2. pnpm (CAS store & cache)"
Invoke-DevStep -CategoryName "npm-cache"       -StepLabel "3. npm (cache clean --force)"
Invoke-DevStep -CategoryName "choco-cache"     -StepLabel "4. Chocolatey (package installer cache)"
Invoke-DevStep -CategoryName "yarn-cache"      -StepLabel "5. Yarn (package cache)"
Invoke-DevStep -CategoryName "bun-cache"       -StepLabel "6. Bun (module & install cache)"
Invoke-DevStep -CategoryName "pip-cache"       -StepLabel "7. Python / pip (cache purge)"
Invoke-DevStep -CategoryName "cargo-registry"  -StepLabel "8. Cargo / Rust (registry & git cache)"
Invoke-DevStep -CategoryName "gradle-cache"    -StepLabel "9. Gradle (daemon & dependency cache)"
Invoke-DevStep -CategoryName "maven-repo"      -StepLabel "10. Maven (local repository cache)"

# Direct .NET / NuGet local cache purge
Write-Host ""
Write-Host "  ---- 11. .NET / NuGet local caches ----" -ForegroundColor Cyan
$dotnetCmd = Get-Command "dotnet" -ErrorAction SilentlyContinue
$hasDotnet = $null -ne $dotnetCmd

if ($hasDotnet) {
    if ($isDryRun) {
        Write-Host "  [DRY-RUN] Would invoke 'dotnet nuget locals all --clear'" -ForegroundColor Yellow
    } else {
        try {
            & dotnet nuget locals all --clear 2>$null | Out-Null
            Write-Host "  [  OK  ] Invoked 'dotnet nuget locals all --clear'" -ForegroundColor Green
        } catch {
            Write-Host "  [ WARN ] dotnet nuget locals clear failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  [ SKIP ] dotnet CLI not present on PATH" -ForegroundColor DarkGray
}

Invoke-AntigravityDevStep -IsDryMode $isDryRun -IsYesMode $hasAutoYes

Write-Host ""
Write-Host "  ==============================================" -ForegroundColor DarkGray

$totalFormatted = Format-ByteSize -Bytes $script:TotalBytesFreed
$actionWord = if ($isDryRun) { "Would reclaim" } else { "Reclaimed" }
Write-Host "  $actionWord $totalFormatted across developer tool caches ($script:TotalItemsRemoved item(s))." -ForegroundColor Cyan

$hasZeroIssues = $script:StepIssuesCount -eq 0
if ($hasZeroIssues) {
    Write-Host "  [  OK  ] Dev tools cache cleanup finished cleanly." -ForegroundColor Green
    Save-LogFile -Status "ok"
    exit 0
}

Write-Host "  [ WARN ] Dev tools cache cleanup finished with $($script:StepIssuesCount) warning(s)." -ForegroundColor Yellow
Save-LogFile -Status "partial"
exit 0
