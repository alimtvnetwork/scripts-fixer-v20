param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function Install-AntigravityCLI {
    $isInstalled = $null -ne (Get-Command "agy" -ErrorAction SilentlyContinue)
    if ($isInstalled) {
        Write-Host "Antigravity CLI (agy) is already installed." -ForegroundColor Green
        return
    }

    Write-Host "Installing Antigravity CLI..." -ForegroundColor Cyan
    $releaseUrl = "https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest"
    $releaseInfo = Invoke-RestMethod -Uri $releaseUrl
    $asset = $releaseInfo.assets | Where-Object { $_.name -eq "agy_cli_windows_x64.zip" }
    
    if (-not $asset) {
        Write-Error "Failed to find the Windows asset."
    }

    $tempZip = Join-Path $env:TEMP "agy_cli_windows_x64.zip"
    $tempDir = Join-Path $env:TEMP "agy_extracted"
    
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip
    if (Test-Path $tempDir) { Remove-Item -Force -Recurse $tempDir }
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
    
    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir | Out-Null
    }
    
    Move-Item -Path (Join-Path $tempDir "agy.exe") -Destination (Join-Path $installDir "agy.exe") -Force
    Remove-Item $tempZip
    Remove-Item -Force -Recurse $tempDir

    # Add to PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notmatch [regex]::Escape($installDir)) {
        $newPath = "$userPath;$installDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$installDir"
    }

    Write-Host "Antigravity CLI installed successfully." -ForegroundColor Green
}

Install-AntigravityCLI
