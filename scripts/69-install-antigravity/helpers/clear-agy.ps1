<#
.SYNOPSIS
    Antigravity & Gemini Brain Optimizer with SQLite Conversation Pruning.

.DESCRIPTION
    Analyzes Antigravity conversation databases, reports heavy conversations (> 100-200 KB),
    prunes historical turns into a reversible backup database, cleans ephemeral brain artifacts,
    and supports full undo/redo capabilities.
#>
param(
    [Parameter(Position = 0)]
    [Alias("k")]
    [int]$Keep = 0,
    [switch]$Predict,
    [switch]$Yes,
    [string]$Undo,
    [Alias("t")]
    [int]$Threshold = 200,
    [switch]$Kill,
    [switch]$ListBackups,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$RemainingArgs
)

if ($RemainingArgs) {
    foreach ($arg in $RemainingArgs) {
        $low = "$arg".Trim().ToLower()

        if ($low -match '^(-k|--keep=?)(\d+)$') {
            $Keep = [int]$matches[2]
        }

        if ($low -match '^(-t|--threshold=?)(\d+)$') {
            $Threshold = [int]$matches[2]
        }
    }
}

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$OptimizerPy = Join-Path $ScriptDir "agy_optimizer.py"

. (Join-Path $ScriptDir "_clear-agy-ops.ps1")

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
        Invoke-UndoTransaction -OptimizerPath $OptimizerPy -TxId $Undo

        return
    }

    $isPredictOnly = $Predict -or (-not $Yes -and -not $Kill)
    if ($isPredictOnly) {
        Show-PredictionSummary -OptimizerPath $OptimizerPy -ThresholdKb $Threshold -KeepCount $Keep

        return
    }

    Stop-AntigravityProcessesIfRequested -IsKillAllowed $Kill
    Invoke-ApplyOptimization -OptimizerPath $OptimizerPy -ThresholdKb $Threshold -KeepCount $Keep
}

Main
