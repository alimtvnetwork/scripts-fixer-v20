#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Windows PowerShell entrypoint for universal Python task automation.
.DESCRIPTION
    Loads config/env.ini, exports $WORK global/process variable for 'cd $WORK', discovers Python 3, and forwards arguments.
#>
[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ScriptArgs
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $ScriptDir

# 1. Cross-Platform Environment & $WORK Navigation Setup
$workDir = (Resolve-Path (Join-Path $ScriptDir "..")).Path
$envIni = Join-Path $ScriptDir "config\env.ini"
if (-not (Test-Path $envIni)) {
    $envIni = Join-Path $workDir "ini-env\env.ini"
}

if (Test-Path $envIni) {
    Get-Content $envIni | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not $line.StartsWith("#") -and -not $line.StartsWith(";") -and $line -match '^([^=]+)=(.*)$') {
            $k = $Matches[1].Trim()
            $v = $Matches[2].Trim()
            [Environment]::SetEnvironmentVariable($k, $v, "Process")
            Set-Item "Env:$k" $v
            Set-Variable -Scope Global -Name $k -Value $v
        }
    }
}

# Guarantee $WORK and $env:WORK are exported so operator/agent can do: cd $WORK
if (-not [Environment]::GetEnvironmentVariable("WORK", "Process")) {
    [Environment]::SetEnvironmentVariable("WORK", $workDir, "Process")
    Set-Item "Env:WORK" $workDir
    Set-Variable -Scope Global -Name WORK -Value $workDir
}

# 2. Python 3 Runtime Discovery
$PythonCmd = $null
foreach ($Candidate in @("python", "py", "python3")) {
    $Command = Get-Command $Candidate -ErrorAction SilentlyContinue
    if ($null -ne $Command) {
        $PythonCmd = $Candidate
        break
    }
}

if ($null -eq $PythonCmd) {
    Write-Error "[ FAIL ] Python 3 runtime not found on PATH. Please install Python 3."
    exit 1
}

# 3. Unit Test Discovery & Runner
if ($ScriptArgs.Count -gt 0 -and $ScriptArgs[0] -eq "test") {
    $TestArgs = @()
    if ($ScriptArgs.Count -gt 1) {
        $TestArgs = $ScriptArgs[1..($ScriptArgs.Count - 1)]
    }
    & $PythonCmd -m unittest discover (Join-Path $ScriptDir "tests") -v @TestArgs
    exit $LASTEXITCODE
}

# 4. Dispatch to CLI Dispatcher
$TargetScript = Join-Path $ScriptDir "scripts\cli_dispatcher.py"
& $PythonCmd $TargetScript @ScriptArgs
exit $LASTEXITCODE
