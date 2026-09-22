<#
.SYNOPSIS
    Antigravity & Gemini Brain Optimizer (Alias for clear-agy.ps1).
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
$ClearAgy = Join-Path $ScriptDir "clear-agy.ps1"

& $ClearAgy @PSBoundParameters
