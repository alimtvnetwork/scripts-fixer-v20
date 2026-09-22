<#
.SYNOPSIS
    Antigravity installation check & detection helper.
#>

function Find-ExistingIdeCandidate {
    $ideCandidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\Antigravity.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity\Antigravity.exe"),
        (Join-Path $env:ProgramFiles "Antigravity\Antigravity.exe")
    )

    foreach ($cand in $ideCandidates) {
        $isFound = Test-Path $cand

        if ($isFound) {
            return $cand
        }
    }

    return $null
}

function Test-HasCli {
    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"

    $hasAgy = Test-Path (Join-Path $installDir "agy.exe")
    if ($hasAgy) {
        return $true
    }

    $hasAntigravity = Test-Path (Join-Path $installDir "antigravity.exe")
    if ($hasAntigravity) {
        return $true
    }

    $hasAgyCmd = $null -ne (Get-Command "agy.exe" -ErrorAction SilentlyContinue)
    if ($hasAgyCmd) {
        return $true
    }

    $hasAntigravityCmd = $null -ne (Get-Command "antigravity" -ErrorAction SilentlyContinue)

    return $hasAntigravityCmd
}

function Check-Antigravity {
    Write-Host "Checking Antigravity installation..." -ForegroundColor Cyan

    $hasCli = Test-HasCli
    $idePath = Find-ExistingIdeCandidate
    $hasIde = $null -ne $idePath

    if ($hasCli -or $hasIde) {
        Write-Host "Antigravity is present on the system (CLI: $hasCli, IDE: $hasIde)." -ForegroundColor Green
    } else {
        Write-Host "Antigravity is not currently installed." -ForegroundColor Yellow
    }

    return
}
