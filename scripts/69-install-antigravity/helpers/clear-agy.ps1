<#
.SYNOPSIS
    Antigravity & Gemini Brain Optimizer with SQLite Conversation Pruning.

.DESCRIPTION
    Analyzes Antigravity conversation databases, reports heavy conversations (> 100-200 KB),
    prunes historical turns into a reversible backup database, cleans ephemeral brain artifacts,
    and supports full undo/redo capabilities.

.PARAMETER Keep
    Number of latest conversations to retain intact (e.g. 5, 10). Older conversations beyond
    this count will be pruned to retain only their last 1-2 turns.

.PARAMETER Predict
    Run in non-destructive prediction mode without closing processes or altering files.

.PARAMETER Yes
    Auto-confirm execution when applying changes.

.PARAMETER Undo
    Undo a specific pruning transaction ID.

.PARAMETER Threshold
    Conversation size threshold in KB (default 200).

.PARAMETER Kill
    Explicitly terminate Antigravity processes prior to applying destructive cache deletes.

.EXAMPLE
    .\clear-agy.ps1 -Predict
    Predict cleanup opportunities without modifying any files.

.EXAMPLE
    .\clear-agy.ps1 -Keep 10
    Predict pruning keeping the latest 10 conversations intact.

.EXAMPLE
    .\clear-agy.ps1 5
    Predict pruning keeping the latest 5 conversations intact.

.EXAMPLE
    .\clear-agy.ps1 -Undo tx-20260922-120000
    Rollback a specific pruning transaction.
#>
param(
    [Parameter(Position = 0)]
    [int]$Keep = 0,
    [switch]$Predict,
    [switch]$Yes,
    [string]$Undo,
    [int]$Threshold = 200,
    [switch]$Kill,
    [switch]$ListBackups
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$OptimizerPy = Join-Path $ScriptDir "agy_optimizer.py"

function Test-IsPythonAvailable {
    $pyCmd = Get-Command "python" -ErrorAction SilentlyContinue
    $isAvailable = ($null -ne $pyCmd)

    return $isAvailable
}

function Show-PredictionSummary {
    param(
        [int]$ThresholdKb,
        [int]$KeepCount = 0
    )

    Write-Host "  [==] Running Antigravity Optimizer in PREDICTION mode..." -ForegroundColor Cyan
    Write-Host "  [--] Antigravity processes will NOT be terminated." -ForegroundColor Gray
    Write-Host ""

    $pyArgs = @($OptimizerPy, "--predict", "--threshold", $ThresholdKb)
    if ($KeepCount -gt 0) {
        $pyArgs += @("--keep", $KeepCount)
    }

    & python @pyArgs
}

function Invoke-ApplyOptimization {
    param(
        [int]$ThresholdKb,
        [int]$KeepCount = 0
    )

    Write-Host "  [==] Applying Antigravity database & brain optimization..." -ForegroundColor Cyan
    Write-Host ""

    $pyArgs = @($OptimizerPy, "--threshold", $ThresholdKb, "--yes")
    if ($KeepCount -gt 0) {
        $pyArgs += @("--keep", $KeepCount)
    }

    & python @pyArgs
}

function Invoke-UndoTransaction {
    param([string]$TxId)

    Write-Host "  [==] Reverting Antigravity prune transaction: $TxId..." -ForegroundColor Cyan
    & python $OptimizerPy --undo $TxId
}

function Stop-AntigravityProcessesIfRequested {
    param([bool]$IsKillAllowed)

    if (-not $IsKillAllowed) {
        return
    }

    $procNames = @("Antigravity*", "antigravity*", "agy*", "language_server_windows*")
    $procs = Get-Process -Name $procNames -ErrorAction SilentlyContinue
    $hasProcs = ($null -ne $procs) -and ($procs.Count -gt 0)

    if ($hasProcs) {
        Write-Host "  [!!] Terminating Antigravity processes as requested..." -ForegroundColor Yellow
        Stop-Process -Name $procNames -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
}

function Main {
    $hasPython = Test-IsPythonAvailable
    if (-not $hasPython) {
        Write-Host "  [XX] Python is required to run Antigravity optimization." -ForegroundColor Red

        exit 1
    }

    if ($ListBackups) {
        & python $OptimizerPy --list-backups

        return
    }

    $isUndo = -not [string]::IsNullOrWhiteSpace($Undo)
    if ($isUndo) {
        Invoke-UndoTransaction -TxId $Undo

        return
    }

    $isPredictOnly = $Predict -or (-not $Yes -and -not $Kill)
    if ($isPredictOnly) {
        Show-PredictionSummary -ThresholdKb $Threshold -KeepCount $Keep

        return
    }

    Stop-AntigravityProcessesIfRequested -IsKillAllowed $Kill
    Invoke-ApplyOptimization -ThresholdKb $Threshold -KeepCount $Keep
}

Main
