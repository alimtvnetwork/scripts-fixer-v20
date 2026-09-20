<#
.SYNOPSIS
    Bucket F: go-buildcache -- Go compiler build cache + module download cache.

.DESCRIPTION
    Cleans:
      - %LOCALAPPDATA%\go-build                    (Go build cache -- 'go env GOCACHE')
      - %USERPROFILE%\go\pkg\mod                   (Go module cache -- 'go env GOMODCACHE')
      - <DEV_DIR>\go\pkg\mod, <DEV_DIR>\go\pkg     (dev-tool Go workspace module cache)
      - Invokes 'go clean -cache -modcache -testcache -fuzzcache' when CLI is available.
    SAFE: %USERPROFILE%\go\bin (installed binaries via 'go install'),
          project source code, go.mod / go.sum files.
#>
param(
    [switch]$DryRun,
    [switch]$Yes,
    [int]$Days = 30,
    [hashtable]$SharedResult
)

$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
. (Join-Path $here "_sweep.ps1")

$result = New-CleanResult -Category "go-buildcache" -Label "Go build cache + module downloads (~/go/bin SAFE)" -Bucket "F"

$goCacheDir = $null
$goModCache = $null
$goCmd = Get-Command "go" -ErrorAction SilentlyContinue
$hasGo = $null -ne $goCmd

if ($hasGo) {
    try {
        $goCacheDir = (& go env GOCACHE 2>$null).Trim()
        $goModCache = (& go env GOMODCACHE 2>$null).Trim()
    } catch {
        Write-Log "go env probe failed: $($_.Exception.Message)" -Level "warn"
    }

    if (-not $DryRun) {
        try {
            & go clean -cache -testcache -fuzzcache 2>$null | Out-Null
            & go clean -modcache 2>$null | Out-Null
            $result.Notes += "Invoked 'go clean -cache -modcache -testcache -fuzzcache'"
        } catch {
            Write-Log "go clean failed: $($_.Exception.Message)" -Level "warn"
        }
    }
}

$candidates = @()

$hasResolvedCacheDir = -not [string]::IsNullOrWhiteSpace($goCacheDir)
if ($hasResolvedCacheDir) {
    $candidates += $goCacheDir
} else {
    $candidates += (Join-Path (Get-LocalAppDataPath) "go-build")
}

$hasResolvedModCache = -not [string]::IsNullOrWhiteSpace($goModCache)
if ($hasResolvedModCache) {
    $candidates += $goModCache
}

$userMod = Join-Path (Get-UserProfilePath) "go\pkg\mod"
$candidates += $userMod

$hasGopath = -not [string]::IsNullOrWhiteSpace($env:GOPATH)
if ($hasGopath) {
    $candidates += (Join-Path $env:GOPATH "pkg\mod")
}

$hasDevDir = -not [string]::IsNullOrWhiteSpace($env:DEV_DIR)
if ($hasDevDir) {
    $candidates += (Join-Path $env:DEV_DIR "go\pkg\mod")
}

foreach ($drive in @("C:", "D:", "E:")) {
    $candidates += (Join-Path $drive "dev-tool\go\pkg\mod")
}

$candidates = @($candidates | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -Unique)
$hasFoundAny = $false

function Reset-ReadOnlyAttributes {
    param([string]$TargetDir)

    $isTargetValid = Test-Path -LiteralPath $TargetDir
    if (-not $isTargetValid) {
        return
    }

    try {
        Get-ChildItem -LiteralPath $TargetDir -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
            $isReadOnly = $_.Attributes -band [System.IO.FileAttributes]::ReadOnly
            if ($isReadOnly) {
                $_.Attributes = $_.Attributes -bxor [System.IO.FileAttributes]::ReadOnly
            }
        }
    } catch {
        Write-Log "Attribute reset warning on $($TargetDir): $($_.Exception.Message)" -Level "warn"
    }
}

foreach ($c in $candidates) {
    $isPathPresent = Test-Path -LiteralPath $c
    if (-not $isPathPresent) {
        continue
    }

    $hasFoundAny = $true

    if (-not $DryRun -and ($c -like "*\pkg\mod*")) {
        Reset-ReadOnlyAttributes -TargetDir $c
    }

    Invoke-PathSweep -Path $c -Result $result -DryRun:$DryRun -LogPrefix "go/cache"
}

if (-not $hasFoundAny) {
    $result.Notes += "Go cache directories not present"
}

Set-CleanResultStatus -Result $result -DryRun:$DryRun

return $result
