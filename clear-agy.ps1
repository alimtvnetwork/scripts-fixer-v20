<#
.SYNOPSIS
    Antigravity & Gemini Brain Optimizer (Root Entry Point).

.DESCRIPTION
    Delegates to scripts/69-install-antigravity/helpers/clear-agy.ps1.
    By default runs in prediction mode without terminating running Antigravity instances.

.PARAMETER Keep
    Number of latest conversations to retain intact (e.g. 5, 10). Older conversations beyond
    this count will be pruned to retain only their last 1-2 turns.

.PARAMETER Predict
    Run in prediction mode without modifying databases or killing processes.

.PARAMETER Yes
    Bypass interactive prompts.

.PARAMETER Undo
    Undo a specific prune transaction ID.

.PARAMETER Threshold
    Conversation size threshold in KB (default 200).

.PARAMETER Kill
    Explicitly terminate Antigravity processes prior to destructive operations.

.EXAMPLE
    .\clear-agy.ps1 -Keep 10
    Predict pruning keeping the latest 10 conversations intact.

.EXAMPLE
    .\clear-agy.ps1 10
    Positional shorthand for keeping the latest 10 conversations intact.
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
$RootDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$HelperScript = Join-Path $RootDir "scripts\69-install-antigravity\helpers\clear-agy.ps1"

if (-not (Test-Path -LiteralPath $HelperScript)) {
    Write-Host "  [XX] Helper script missing: $HelperScript" -ForegroundColor Red
    exit 1
}

$splat = @{
    Keep        = $Keep
    Predict     = $Predict
    Yes         = $Yes
    Undo        = $Undo
    Threshold   = $Threshold
    Kill        = $Kill
    ListBackups = $ListBackups
}

& $HelperScript @splat
