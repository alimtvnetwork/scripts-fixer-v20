<#
.SYNOPSIS
    Verification of Antigravity CLI and IDE binaries.
#>

function Verify-CliCommand {
    param(
        [string]$ExePath,
        [string]$Label
    )

    $isMissing = -not (Test-Path $ExePath)
    if ($isMissing) {
        throw "Verification failed: $ExePath does not exist."
    }

    try {
        $ver = & "$ExePath" --version
        Write-Host "Verified '$Label --version': $ver" -ForegroundColor Green
    } catch {
        throw "Verification failed: executing '$ExePath --version' threw an error: $($_.Exception.Message)"
    }
}

function Verify-IdePresence {
    $cand = Find-ExistingIdeCandidate
    $hasIde = $null -ne $cand

    if ($hasIde) {
        Write-Host "Verified Antigravity IDE executable: $cand" -ForegroundColor Green
    }
}

function Verify-AntigravityInstallation {
    param([Parameter(Mandatory = $true)][string]$InstallDir)

    Write-Host "Verifying Antigravity installation..." -ForegroundColor Cyan

    $cliExe = Join-Path $InstallDir "antigravity.exe"
    $agyExe = Join-Path $InstallDir "agy.exe"

    Verify-CliCommand -ExePath $cliExe -Label "antigravity.exe"
    Verify-CliCommand -ExePath $agyExe -Label "agy.exe"
    Verify-IdePresence
}
