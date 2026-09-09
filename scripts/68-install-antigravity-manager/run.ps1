param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function Get-LatestManagerUrl {
    $apiUrl = "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/latest"
    $response = Invoke-RestMethod -Uri $apiUrl
    foreach ($asset in $response.assets) {
        $hasExe = $asset.name.EndsWith("-setup.exe")
        if ($hasExe) { return $asset.browser_download_url }
    }
    throw "No -setup.exe found"
}

function Test-IsManagerInstalled {
    $regUser = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $isInstalledInReg = $null -ne (Get-ItemProperty $regUser -ErrorAction SilentlyContinue | Where-Object DisplayName -match "Antigravity Manager")
    $isInstalledInAppData = Test-Path "$env:LOCALAPPDATA\Programs\antigravity-manager"
    $hasManager = $isInstalledInReg -or $isInstalledInAppData
    return $hasManager
}

function Install-AntigravityManager {
    $isInstalled = Test-IsManagerInstalled
    if ($isInstalled) {
        Write-Host "Antigravity Manager is already installed." -ForegroundColor Green
        return
    }
    $downloadUrl = Get-LatestManagerUrl
    $tempInstaller = "$env:TEMP\AntigravityManager-setup.exe"
    Write-Host "Downloading Antigravity Manager..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempInstaller
    Write-Host "Installing silently..." -ForegroundColor Cyan
    Start-Process -FilePath $tempInstaller -ArgumentList "/S" -Wait -NoNewWindow
    Write-Host "Antigravity Manager installed." -ForegroundColor Green
}

Install-AntigravityManager
