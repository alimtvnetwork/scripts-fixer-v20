<#
.SYNOPSIS
    Antigravity IDE installer helper.
#>

function Invoke-ReferenceInstaller {
    $refScript = "D:\work\antigravity-installer\01-installer\agy-install.ps1"
    $hasRef = Test-Path $refScript

    if ($hasRef) {
        Write-Host "Found reference installer at $refScript; executing..." -ForegroundColor Cyan
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $refScript

        return $true
    }

    return $false
}

function Get-IdeDownloadUrl {
    $isArm = $env:PROCESSOR_ARCHITECTURE -eq "ARM64"
    $primaryUrl = if ($isArm) {
        "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/windows-arm/Antigravity-arm64.exe"
    } else {
        "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/windows-x64/Antigravity-x64.exe"
    }

    return $primaryUrl
}

function Get-IdeFallbackUrl {
    $isArm = $env:PROCESSOR_ARCHITECTURE -eq "ARM64"
    $platformKey = if ($isArm) { "win32-arm64-user" } else { "win32-x64-user" }
    $updateApi = "https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/api/update/$platformKey/stable/latest"

    try {
        $updateInfo = Invoke-RestMethod -Uri $updateApi -Headers @{ "User-Agent" = "PowerShell" } -TimeoutSec 15
        $hasUrl = $updateInfo -and $updateInfo.url

        if ($hasUrl) {
            return $updateInfo.url
        }
    } catch { }

    return "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.5.5-4923483625488384/windows-x64/Antigravity%20IDE.exe"
}

function Download-IdeInstaller {
    param([string]$TargetFile)

    $primaryUrl = Get-IdeDownloadUrl
    $hasDownloaded = $false

    try {
        Write-Host "Downloading Google Antigravity from storage.googleapis.com..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $primaryUrl -OutFile $TargetFile -UseBasicParsing -TimeoutSec 120
        $hasDownloaded = (Test-Path $TargetFile) -and ((Get-Item $TargetFile).Length -gt 1000000)
    } catch {
        Write-Host "  [ NOTE ] Primary storage download failed: $($_.Exception.Message)" -ForegroundColor DarkGray
    }

    if (-not $hasDownloaded) {
        $fallbackUrl = Get-IdeFallbackUrl
        Write-Host "Downloading Antigravity from fallback URL ($fallbackUrl)..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $fallbackUrl -OutFile $TargetFile -UseBasicParsing -TimeoutSec 120
    }
}

function Execute-SilentIdeInstall {
    param([string]$InstallerFile)

    Write-Host "Running silent Antigravity installation..." -ForegroundColor Cyan
    Start-Process -FilePath $InstallerFile -ArgumentList "/S" -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue | Out-Null

    $installed = Find-ExistingIdeCandidate
    $isMissing = $null -eq $installed

    if ($isMissing) {
        Start-Process -FilePath $InstallerFile -ArgumentList "/VERYSILENT", "/MERGETASKS=!runcode", "/NORESTART" -Wait -NoNewWindow -ErrorAction SilentlyContinue | Out-Null
    }

    Remove-Item -Path $InstallerFile -Force -ErrorAction SilentlyContinue
}

function Install-AntigravityIDE {
    $existing = Find-ExistingIdeCandidate
    $hasExisting = $null -ne $existing

    if ($hasExisting) {
        Write-Host "Antigravity IDE is already installed at $existing." -ForegroundColor Green

        return $existing
    }

    $isRefDone = Invoke-ReferenceInstaller
    if ($isRefDone) {
        $refCand = Find-ExistingIdeCandidate

        return $refCand
    }

    $tempInstaller = Join-Path $env:TEMP "Antigravity-setup.exe"
    Download-IdeInstaller -TargetFile $tempInstaller
    Execute-SilentIdeInstall -InstallerFile $tempInstaller

    $finalCand = Find-ExistingIdeCandidate
    $hasFinal = $null -ne $finalCand

    if ($hasFinal) {
        Write-Host "Antigravity installed successfully at $finalCand." -ForegroundColor Green

        return $finalCand
    }

    Write-Host "  [ NOTE ] Antigravity installer completed." -ForegroundColor DarkGray

    return $null
}
