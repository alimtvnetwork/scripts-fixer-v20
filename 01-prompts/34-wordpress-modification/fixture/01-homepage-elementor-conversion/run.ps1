[CmdletBinding()]
param(
    [Parameter(Position = 0)][string]$Command = "help",
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$RemainingArgs
)
$ErrorActionPreference = "Stop"

$python = Get-Command python.exe -ErrorAction SilentlyContinue
if (-not $python) { $python = Get-Command py.exe -ErrorAction SilentlyContinue }
if (-not $python) { Write-Error "Python 3 is required but not found in PATH."; exit 1 }

$scriptDir = $PSScriptRoot
$scriptPath = Join-Path $scriptDir "scripts\cli_dispatcher.py"

if ($Command -eq "test") {
    Write-Host "[INFO] Running unit test suite..." -ForegroundColor Cyan
    & $python.Source -m unittest discover -s (Join-Path $scriptDir "scripts") -p "test_*.py" -v
    exit $LASTEXITCODE
}

& $python.Source $scriptPath $Command @RemainingArgs
exit $LASTEXITCODE
