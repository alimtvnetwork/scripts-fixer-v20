[CmdletBinding()]
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$RemainingArgs)
$ErrorActionPreference = "Stop"

$python = (Get-Command python.exe -ErrorAction SilentlyContinue).Source
if (-not $python) { $python = (Get-Command py.exe -ErrorAction SilentlyContinue).Source }
if (-not $python) { Write-Error "Python 3 is required but not found in PATH."; exit 1 }

$scriptPath = Join-Path $PSScriptRoot "scripts\cli_dispatcher.py"
& $python $scriptPath @RemainingArgs
exit $LASTEXITCODE
