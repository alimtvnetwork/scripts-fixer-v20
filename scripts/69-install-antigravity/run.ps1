param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function Install-AntigravityCLI {
    $isInstalled = ($null -ne (Get-Command "antigravity" -ErrorAction SilentlyContinue)) -or ($null -ne (Get-Command "agy" -ErrorAction SilentlyContinue))
    if ($isInstalled) {
        Write-Host "Antigravity is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Antigravity..." -ForegroundColor Cyan
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $assetName = "agy_cli_windows_${arch}.zip"
    $downloadUrl = $null

    try {
        $releaseUrl = "https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $releaseUrl -Headers @{ "User-Agent" = "PowerShell" }
        $asset = $releaseInfo.assets | Where-Object { $_.name -eq $assetName }
        if ($asset) { $downloadUrl = $asset.browser_download_url }
    } catch { }

    if (-not $downloadUrl) {
        $downloadUrl = "https://github.com/google-antigravity/antigravity-cli/releases/latest/download/$assetName"
    }

    $tempZip = Join-Path $env:TEMP $assetName
    $tempDir = Join-Path $env:TEMP "agy_extracted"
    
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip
    if (Test-Path $tempDir) { Remove-Item -Force -Recurse $tempDir }
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
    
    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }
    
    $srcExe = if (Test-Path (Join-Path $tempDir "antigravity.exe")) {
        Join-Path $tempDir "antigravity.exe"
    } elseif (Test-Path (Join-Path $tempDir "agy.exe")) {
        Join-Path $tempDir "agy.exe"
    } else {
        (Get-ChildItem -Path $tempDir -Filter "*.exe" -Recurse | Select-Object -First 1).FullName
    }

    if (-not $srcExe -or -not (Test-Path $srcExe)) {
        throw "Could not find Antigravity executable in extracted files."
    }

    Copy-Item -Path $srcExe -Destination (Join-Path $installDir "antigravity.exe") -Force
    Copy-Item -Path $srcExe -Destination (Join-Path $installDir "agy.exe") -Force
    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item -Force -Recurse $tempDir -ErrorAction SilentlyContinue

    # Add to PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notmatch [regex]::Escape($installDir)) {
        $newPath = "$userPath;$installDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$installDir"
    }

    Write-Host "Antigravity (antigravity / agy) installed successfully." -ForegroundColor Green
}

Install-AntigravityCLI

