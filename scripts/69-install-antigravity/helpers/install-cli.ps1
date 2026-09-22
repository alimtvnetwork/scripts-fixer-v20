<#
.SYNOPSIS
    Antigravity CLI installer helper.
#>

function Ensure-CliDirectory {
    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    $hasDir = Test-Path $installDir

    if (-not $hasDir) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    return $installDir
}

function Test-HasExistingCliBinaries {
    param([string]$InstallDir)

    $agyExe = Join-Path $InstallDir "agy.exe"
    $antigravityExe = Join-Path $InstallDir "antigravity.exe"

    return ((Test-Path $agyExe) -and (Test-Path $antigravityExe))
}

function Test-CopyLocalAgy {
    param([string]$InstallDir)

    $localAgy = Join-Path $env:LOCALAPPDATA "agy\bin\agy.exe"
    $hasLocal = Test-Path $localAgy

    if ($hasLocal) {
        $agyExe = Join-Path $InstallDir "agy.exe"
        $antigravityExe = Join-Path $InstallDir "antigravity.exe"
        Copy-Item -Path $localAgy -Destination $agyExe -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $localAgy -Destination $antigravityExe -Force -ErrorAction SilentlyContinue

        return $true
    }

    return $false
}

function Get-CliDownloadUrl {
    param([string]$AssetName)

    try {
        $releaseUrl = "https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $releaseUrl -Headers @{ "User-Agent" = "PowerShell" } -TimeoutSec 15
        $asset = $releaseInfo.assets | Where-Object { $_.name -eq $AssetName }
        $hasUrl = $asset -and $asset.browser_download_url

        if ($hasUrl) {
            return $asset.browser_download_url
        }
    } catch {
        Write-Host "  [ NOTE ] GitHub API query failed: $($_.Exception.Message)" -ForegroundColor DarkGray
    }

    return "https://github.com/google-antigravity/antigravity-cli/releases/latest/download/$AssetName"
}

function Find-ExtractedExe {
    param([string]$TempDir)

    $antiExe = Join-Path $TempDir "antigravity.exe"
    if (Test-Path $antiExe) {
        return $antiExe
    }

    $agyExe = Join-Path $TempDir "agy.exe"
    if (Test-Path $agyExe) {
        return $agyExe
    }

    $found = Get-ChildItem -Path $TempDir -Filter "*.exe" -Recurse | Select-Object -First 1
    if ($found) {
        return $found.FullName
    }

    return $null
}

function Deploy-ExtractedCli {
    param(
        [string]$TempDir,
        [string]$InstallDir
    )

    $srcExe = Find-ExtractedExe -TempDir $TempDir
    $isMissing = -not $srcExe -or -not (Test-Path $srcExe)

    if ($isMissing) {
        throw "Could not find Antigravity executable in extracted files."
    }

    $antigravityExe = Join-Path $InstallDir "antigravity.exe"
    $agyExe = Join-Path $InstallDir "agy.exe"
    Copy-Item -Path $srcExe -Destination $antigravityExe -Force -ErrorAction SilentlyContinue
    Copy-Item -Path $srcExe -Destination $agyExe -Force -ErrorAction SilentlyContinue
}

function Install-AntigravityCLI {
    Write-Host "Installing Antigravity CLI..." -ForegroundColor Cyan

    $installDir = Ensure-CliDirectory
    $hasExisting = Test-HasExistingCliBinaries -InstallDir $installDir

    if ($hasExisting) {
        Write-Host "Antigravity CLI is already present in $installDir." -ForegroundColor Green

        return $installDir
    }

    $hasCopiedLocal = Test-CopyLocalAgy -InstallDir $installDir
    if ($hasCopiedLocal) {
        return $installDir
    }

    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $assetName = "agy_cli_windows_${arch}.zip"
    $downloadUrl = Get-CliDownloadUrl -AssetName $assetName

    $uniqueId = [System.Guid]::NewGuid().ToString("N")
    $tempZip = Join-Path $env:TEMP "agy_${uniqueId}_${assetName}"
    $tempDir = Join-Path $env:TEMP "agy_extracted_$uniqueId"

    Write-Host "Downloading Antigravity CLI ($assetName)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing

    if (Test-Path $tempDir) { Remove-Item -Force -Recurse $tempDir }
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force

    Deploy-ExtractedCli -TempDir $tempDir -InstallDir $installDir

    Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    return $installDir
}
