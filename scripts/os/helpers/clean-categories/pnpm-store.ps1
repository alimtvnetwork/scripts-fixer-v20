<#
.SYNOPSIS
    Bucket F: pnpm-store -- pnpm content-addressable store (CAS) and package cache.

.DESCRIPTION
    Cleans:
      - %USERPROFILE%\.pnpm-store              (legacy / cross-platform default)
      - %LOCALAPPDATA%\pnpm\store              (Windows default since pnpm v6+)
      - %LOCALAPPDATA%\pnpm-cache              (transient HTTP cache)
      - <DEV_DIR>\pnpm\store                   (configured dev-tool pnpm store)
      - 'pnpm store prune' invoked first when CLI is on PATH.
    SAFE: %LOCALAPPDATA%\pnpm\* outside of \store\ (the pnpm runtime itself,
          shims under \pnpm-global, and project package.json files).
#>
param(
    [switch]$DryRun,
    [switch]$Yes,
    [int]$Days = 30,
    [hashtable]$SharedResult
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $here "_sweep.ps1")

$result = New-CleanResult -Category "pnpm-store" -Label "pnpm CAS store (.pnpm-store + LOCALAPPDATA\pnpm\store; runtime SAFE)" -Bucket "F"

if (-not $DryRun) {
    $pnpmCmd = Get-Command "pnpm" -ErrorAction SilentlyContinue
    $hasPnpm = $null -ne $pnpmCmd

    if ($hasPnpm) {
        try {
            & pnpm store prune 2>$null | Out-Null
            $result.Notes += "Invoked 'pnpm store prune' before path sweep (unreferenced content only)"
        } catch {
            Write-Log "pnpm store prune failed: $($_.Exception.Message)" -Level "warn"
        }
    }
}

$candidates = @(
    (Join-Path (Get-UserProfilePath) ".pnpm-store"),
    (Join-Path (Get-LocalAppDataPath) "pnpm\store"),
    (Join-Path (Get-LocalAppDataPath) "pnpm-cache")
)

$hasDevDir = -not [string]::IsNullOrWhiteSpace($env:DEV_DIR)
if ($hasDevDir) {
    $candidates += (Join-Path $env:DEV_DIR "pnpm\store")
}

foreach ($drive in @("C:", "D:", "E:")) {
    $candidates += (Join-Path $drive "dev-tool\pnpm\store")
}

$candidates = @($candidates | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
$hasFoundAny = $false

foreach ($c in $candidates) {
    $isPathPresent = Test-Path -LiteralPath $c
    if (-not $isPathPresent) {
        continue
    }

    $hasFoundAny = $true
    $leaf = Split-Path -Leaf $c
    $parent = Split-Path -Parent $c
    $parentLeaf = Split-Path -Leaf $parent

    Invoke-PathSweep -Path $c -Result $result -DryRun:$DryRun -LogPrefix "pnpm-store/$parentLeaf/$leaf"
}

if (-not $hasFoundAny) {
    $result.Notes += "pnpm store not present (no .pnpm-store, LOCALAPPDATA\pnpm\store, LOCALAPPDATA\pnpm-cache)"
}

Set-CleanResultStatus -Result $result -DryRun:$DryRun

return $result
