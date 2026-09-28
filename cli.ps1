<#
.SYNOPSIS
    Unified CLI wrapper for scripts-fixer and run.ps1 commands.
#>
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Args
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$runPs1 = Join-Path $scriptDir "run.ps1"

& $runPs1 @Args

exit $LASTEXITCODE
