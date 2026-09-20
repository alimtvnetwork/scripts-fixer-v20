<#
.SYNOPSIS
    Bucket F: choco-cache -- Chocolatey package installer download and cache cleaner.

.DESCRIPTION
    Cleans Chocolatey download archives, extraction temps, and cache artifacts:
      - %LOCALAPPDATA%\Chocolatey\Cache
      - %ProgramData%\chocolatey\cache
      - %TEMP%\chocolatey
      - %LOCALAPPDATA%\Temp\chocolatey
    Runs 'choco cache clean' or 'choco cache remove' when CLI is available.
    Preserves Chocolatey installation and package state in %ProgramData%\chocolatey\lib.
#>
param(
    [switch]$DryRun,
    [switch]$Yes,
    [int]$Days = 30,
    [hashtable]$SharedResult
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $here "_sweep.ps1")

$result = New-CleanResult -Category "choco-cache" -Label "Chocolatey package cache + installer downloads" -Bucket "F"

$chocoCmd = Get-Command "choco" -ErrorAction SilentlyContinue
$hasChoco = $null -ne $chocoCmd

if ($hasChoco -and -not $DryRun) {
    try {
        & choco cache clean -y 2>$null | Out-Null
        $result.Notes += "Invoked 'choco cache clean -y'"
    } catch {
        Write-Log "choco cache clean invocation failed: $($_.Exception.Message)" -Level "warn"
    }
}

$candidates = @()

$localApp = Get-LocalAppDataPath
$hasLocalApp = -not [string]::IsNullOrWhiteSpace($localApp)

if ($hasLocalApp) {
    $candidates += (Join-Path $localApp "Chocolatey\Cache")
    $candidates += (Join-Path $localApp "Temp\chocolatey")
}

$progData = $env:ProgramData
$hasProgData = -not [string]::IsNullOrWhiteSpace($progData)

if ($hasProgData) {
    $candidates += (Join-Path $progData "chocolatey\cache")
}

$tempDir = $env:TEMP
$hasTempDir = -not [string]::IsNullOrWhiteSpace($tempDir)

if ($hasTempDir) {
    $candidates += (Join-Path $tempDir "chocolatey")
}

$hasFoundAny = $false

foreach ($path in $candidates) {
    $isPathPresent = Test-Path -LiteralPath $path

    if (-not $isPathPresent) {
        continue
    }

    $hasFoundAny = $true
    Invoke-PathSweep -Path $path -Result $result -DryRun:$DryRun -LogPrefix "choco-cache"
}

if (-not $hasFoundAny) {
    $result.Notes += "Chocolatey cache directories not present"
}

Set-CleanResultStatus -Result $result -DryRun:$DryRun

return $result
