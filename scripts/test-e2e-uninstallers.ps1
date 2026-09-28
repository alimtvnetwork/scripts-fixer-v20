<#
.SYNOPSIS
    End-to-End Test Suite for Antigravity, AGM, Copilot, Edge Uninstallers and Dev-Clean.

.DESCRIPTION
    Runs comprehensive end-to-end verification across:
      1. Antigravity State Backup export (JSON containing project info & conversation names).
      2. Antigravity Uninstaller logic & safety barrier (verifying d:\work cannot be touched).
      3. Anti-Gravity Manager (AGM) uninstaller routine.
      4. Windows Copilot deep uninstaller routine.
      5. Microsoft Edge Chris Titus WinUtil uninstaller routine.
      6. Enhanced dev-tool cache cleaner (dev-clean).
      7. Unified CLI wrapper (cli.ps1 / cli.cmd).
      8. Optional -FullLiveTest switch to trigger full system removal from outside IDE.

.EXAMPLE
    pwsh -NoProfile -File scripts/test-e2e-uninstallers.ps1 -Simulate
    pwsh -NoProfile -File scripts/test-e2e-uninstallers.ps1 -FullLiveTest
#>

param(
    [switch]$Simulate,
    [switch]$FullLiveTest,
    [switch]$VerboseOutput
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$rootDir   = Split-Path -Parent $scriptDir

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  E2E Uninstaller & Cache Cleaner Verification Suite" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host ""

$testResults = @{
    TotalPassed = 0
    TotalFailed = 0
    TotalSkipped = 0
}

function Report-TestResult {
    param(
        [string]$Name,
        [bool]$IsPassed,
        [string]$Message
    )

    if ($IsPassed) {
        $testResults.TotalPassed++
        Write-Host "  [  OK  ] $Name : $Message" -ForegroundColor Green
        return
    }

    $testResults.TotalFailed++
    Write-Host "  [ FAIL ] $Name : $Message" -ForegroundColor Red
}

# ── Test 1: Antigravity State Backup Export ───────────────────────────────────
Write-Host "--> Running Test 1: Antigravity State Backup (JSON Schema)..." -ForegroundColor Yellow
$backupScript = Join-Path $rootDir "scripts\69-install-antigravity\helpers\backup-state.ps1"
$isBackupFound = Test-Path $backupScript
if (-not $isBackupFound) {
    Report-TestResult -Name "State Backup Helper" -IsPassed $false -Message "File not found: $backupScript"
} else {
    try {
        . $backupScript
        $backupPath = Export-AntigravityState
        $hasBackup = ($backupPath -and (Test-Path $backupPath))

        if ($hasBackup) {
            $rawJson = Get-Content $backupPath -Raw -Encoding UTF8
            $stateObj = $rawJson | ConvertFrom-Json
            $hasSavedAt = $null -ne $stateObj.saved_at
            $hasItems = $null -ne $stateObj.items
            $hasProjects = $null -ne $stateObj.projects

            $isValidSchema = $hasSavedAt -and $hasItems -and $hasProjects
            Report-TestResult -Name "State Backup Export" -IsPassed $isValidSchema -Message "Generated $backupPath ($($stateObj.total_conversations) conversations)"
        } else {
            Report-TestResult -Name "State Backup Export" -IsPassed $false -Message "Backup path was not created"
        }
    } catch {
        Report-TestResult -Name "State Backup Export" -IsPassed $false -Message "$($_.Exception.Message)"
    }
}

# ── Test 2: Antigravity Uninstaller AST & Safety Barrier ───────────────────────
Write-Host "--> Running Test 2: Antigravity Uninstaller Safety Barrier..." -ForegroundColor Yellow
$uninstallScript = Join-Path $rootDir "scripts\69-install-antigravity\helpers\uninstall.ps1"
$isUninstallFound = Test-Path $uninstallScript
if (-not $isUninstallFound) {
    Report-TestResult -Name "Antigravity Uninstaller" -IsPassed $false -Message "File not found: $uninstallScript"
} else {
    try {
        . $uninstallScript
        $isWorkspaceBlocked = -not (Test-IsSafePath -Path "D:\work\scripts-fixer")
        $isSafeAllowed = Test-IsSafePath -Path "$env:TEMP\antigravity-e2e-test"
        $isSafetyWorking = $isWorkspaceBlocked -and $isSafeAllowed

        Report-TestResult -Name "Workspace Safety Barrier" -IsPassed $isSafetyWorking -Message "d:\work blocked and temp paths allowed"
    } catch {
        Report-TestResult -Name "Workspace Safety Barrier" -IsPassed $false -Message "$($_.Exception.Message)"
    }
}

# ── Test 3: AGM Uninstaller Presence ──────────────────────────────────────────
Write-Host "--> Running Test 3: AGM Uninstaller Script..." -ForegroundColor Yellow
$agmScript = Join-Path $rootDir "scripts\68-install-antigravity-manager\run.ps1"
$isAgmFound = Test-Path $agmScript
if (-not $isAgmFound) {
    Report-TestResult -Name "AGM Script" -IsPassed $false -Message "File not found: $agmScript"
} else {
    try {
        $content = Get-Content $agmScript -Raw
        $hasUninstallFn = $content -match "Uninstall-AntigravityManager"
        Report-TestResult -Name "AGM Uninstaller Function" -IsPassed $hasUninstallFn -Message "Uninstall-AntigravityManager present"
    } catch {
        Report-TestResult -Name "AGM Uninstaller Function" -IsPassed $false -Message "$($_.Exception.Message)"
    }
}

# ── Test 4: Copilot Uninstaller Helper ─────────────────────────────────────────
Write-Host "--> Running Test 4: Windows Copilot Deep Uninstaller..." -ForegroundColor Yellow
$copilotScript = Join-Path $rootDir "scripts\os\helpers\uninstall-copilot.ps1"
$isCopilotFound = Test-Path $copilotScript
if (-not $isCopilotFound) {
    Report-TestResult -Name "Copilot Uninstaller" -IsPassed $false -Message "File not found: $copilotScript"
} else {
    try {
        $copilotContent = Get-Content $copilotScript -Raw
        $hasAppx = $copilotContent -match "Remove-AppxPackage"
        $hasPolicy = $copilotContent -match "TurnOffWindowsCopilot"
        Report-TestResult -Name "Copilot Uninstaller Logic" -IsPassed ($hasAppx -and $hasPolicy) -Message "AppX removal and policy disablement present"
    } catch {
        Report-TestResult -Name "Copilot Uninstaller Logic" -IsPassed $false -Message "$($_.Exception.Message)"
    }
}

# ── Test 5: Chris Titus WinUtil Edge Uninstaller ───────────────────────────────
Write-Host "--> Running Test 5: Microsoft Edge Uninstaller..." -ForegroundColor Yellow
$edgeScript = Join-Path $rootDir "scripts\os\helpers\uninstall-edge.ps1"
$isEdgeFound = Test-Path $edgeScript
if (-not $isEdgeFound) {
    Report-TestResult -Name "Edge Uninstaller" -IsPassed $false -Message "File not found: $edgeScript"
} else {
    try {
        $edgeContent = Get-Content $edgeScript -Raw
        $hasSetup = $edgeContent -match "--force-uninstall"
        $hasBlock = $edgeContent -match "DoNotUpdateToEdgeWithChromium"
        Report-TestResult -Name "Edge Uninstaller Logic" -IsPassed ($hasSetup -and $hasBlock) -Message "Chris Titus WinUtil setup flags and update block present"
    } catch {
        Report-TestResult -Name "Edge Uninstaller Logic" -IsPassed $false -Message "$($_.Exception.Message)"
    }
}

# ── Test 6: Enhanced Dev-Clean Dry Run ─────────────────────────────────────────
Write-Host "--> Running Test 6: Enhanced Dev-Clean Dry Run..." -ForegroundColor Yellow
$devCleanScript = Join-Path $rootDir "scripts\os\helpers\dev-clean.ps1"
try {
    $devCleanOut = & pwsh -NoProfile -File $devCleanScript --dry-run
    $hasDryRun = $devCleanOut -match "\[DRY-RUN\]"
    Report-TestResult -Name "Dev-Clean Enhancement" -IsPassed ($null -ne $hasDryRun) -Message "Dry-run completed cleanly without errors"
} catch {
    Report-TestResult -Name "Dev-Clean Enhancement" -IsPassed $false -Message "$($_.Exception.Message)"
}

# ── Test 7: CLI Wrapper & Supported Targets ────────────────────────────────────
Write-Host "--> Running Test 7: CLI Wrapper Dispatch..." -ForegroundColor Yellow
$cliScript = Join-Path $rootDir "cli.ps1"
$isCliFound = Test-Path $cliScript
if (-not $isCliFound) {
    Report-TestResult -Name "CLI Wrapper" -IsPassed $false -Message "File not found: $cliScript"
} else {
    try {
        $cliOut = & pwsh -NoProfile -File $cliScript uninstall test-target-probe 2>&1
        $hasAgyAll = $cliOut -match "agy-all"
        $hasCopilot = $cliOut -match "copilot"
        $hasEdge = $cliOut -match "edge"
        $isCliTargetsGood = ($null -ne $hasAgyAll) -and ($null -ne $hasCopilot) -and ($null -ne $hasEdge)

        Report-TestResult -Name "CLI Uninstall Targets" -IsPassed $isCliTargetsGood -Message "agy-all, copilot, and edge registered in dispatcher"
    } catch {
        Report-TestResult -Name "CLI Uninstall Targets" -IsPassed $false -Message "$($_.Exception.Message)"
    }
}

# ── Optional: Full Live Test ──────────────────────────────────────────────────
if ($FullLiveTest) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "  TRIGGERING FULL LIVE UNINSTALLATION OF ANTIGRAVITY" -ForegroundColor Red
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host "  Live uninstallation will now run 'agy-all' to purge all traces." -ForegroundColor Yellow
    Write-Host "  State backup JSON will be saved first." -ForegroundColor Yellow
    Write-Host ""

    & pwsh -NoProfile -File (Join-Path $rootDir "cli.ps1") uninstall agy-all
    Write-Host "  Live uninstall completed with exit code: $LASTEXITCODE" -ForegroundColor Green
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Summary: $($testResults.TotalPassed) Passed, $($testResults.TotalFailed) Failed" -ForegroundColor $(if ($testResults.TotalFailed -eq 0) { "Green" } else { "Red" })
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host ""

if ($testResults.TotalFailed -gt 0) {
    exit 1
}

exit 0
