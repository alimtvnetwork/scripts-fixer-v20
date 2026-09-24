<#
.SYNOPSIS
    Execution routines for Antigravity optimization and conversation pruning.
#>

function Test-IsPythonAvailable {
    $pyCmd = Get-Command "python" -ErrorAction SilentlyContinue
    $isAvailable = ($null -ne $pyCmd)

    return $isAvailable
}

function Show-PredictionSummary {
    param(
        [string]$OptimizerPath,
        [int]$ThresholdKb,
        [int]$KeepCount = 0
    )

    Write-Host "  [==] Running Antigravity Optimizer in PREDICTION mode..." -ForegroundColor Cyan
    Write-Host "  [--] Antigravity processes will NOT be terminated." -ForegroundColor Gray
    Write-Host ""

    $pyArgs = @($OptimizerPath, "--predict", "--threshold", $ThresholdKb)
    if ($KeepCount -gt 0) {
        $pyArgs += @("--keep", $KeepCount)
    }

    & python @pyArgs
}

function Invoke-ApplyOptimization {
    param(
        [string]$OptimizerPath,
        [int]$ThresholdKb,
        [int]$KeepCount = 0
    )

    Write-Host "  [==] Applying Antigravity database & brain optimization..." -ForegroundColor Cyan
    Write-Host ""

    $pyArgs = @($OptimizerPath, "--threshold", $ThresholdKb, "--yes")
    if ($KeepCount -gt 0) {
        $pyArgs += @("--keep", $KeepCount)
    }

    & python @pyArgs
}

function Invoke-UndoTransaction {
    param(
        [string]$OptimizerPath,
        [string]$TxId
    )

    Write-Host "  [==] Reverting Antigravity prune transaction: $TxId..." -ForegroundColor Cyan
    & python $OptimizerPath --undo $TxId
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
