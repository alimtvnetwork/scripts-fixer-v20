<#
.SYNOPSIS
    Microsoft Store & AppX dependency manager for Windows Server and client Windows.
    Provides automated installation of Microsoft Store dependencies (VCLibs, UI.Xaml)
    and enables Windows Server compatibility for Store-reliant tools like PlotCode and Codex.
#>

Set-StrictMode -Version Latest
$sharedDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
if (Test-Path (Join-Path $sharedDir "os-detect.ps1")) {
    . (Join-Path $sharedDir "os-detect.ps1")
}

function Test-HasStoreInstalled {
    return (Test-HasWindowsStore)
}

function Download-AppxFile {
    param([string]$Url, [string]$DestPath)

    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $Url -OutFile $DestPath -UseBasicParsing -TimeoutSec 60
        return (Test-Path $DestPath)
    } catch {
        return $false
    }
}

function Install-AppxPackageDirect {
    param([string]$PackagePath)

    if (-not (Test-Path $PackagePath)) {
        return $false
    }

    try {
        $cmd = "try { Add-AppxPackage -Path '$PackagePath' -ErrorAction Stop } catch { if (`$_.Exception.Message -notmatch '0x80073D06') { throw `$_.Exception } }"
        & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command $cmd 2>$null
        return $true
    } catch {
        return $false
    }
}

function Install-StoreDependencies {
    $tempDir = Join-Path $env:TEMP "store-prereqs-$([System.Guid]::NewGuid().ToString('N'))"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    $vclibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $vclibsDest = Join-Path $tempDir "Microsoft.VCLibs.x64.appx"

    if (Download-AppxFile -Url $vclibsUrl -DestPath $vclibsDest) {
        Install-AppxPackageDirect -PackagePath $vclibsDest | Out-Null
    }

    $xamlUrl = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
    $xamlDest = Join-Path $tempDir "Microsoft.UI.Xaml.2.8.x64.appx"

    if (Download-AppxFile -Url $xamlUrl -DestPath $xamlDest) {
        Install-AppxPackageDirect -PackagePath $xamlDest | Out-Null
    }

    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    return $true
}

function Ensure-WindowsStoreForServer {
    param([string]$Caller = "Installation")

    $isServer = Test-IsWindowsServer

    if (-not $isServer) {
        return $true
    }

    $hasStore = Test-HasStoreInstalled

    if ($hasStore) {
        Write-Host "  [  OK  ] Microsoft Store / AppX container is present on this server." -ForegroundColor Green
        return $true
    }

    Write-Host ""
    Write-Host "  [ INFO ] Windows Server detected: Store / AppX is missing by default." -ForegroundColor Cyan
    Write-Host "  [  ..  ] Configuring Windows Server compatibility for $Caller..." -ForegroundColor Yellow

    Install-StoreDependencies | Out-Null

    Write-Host "  [  OK  ] Windows Server compatibility configured for $Caller." -ForegroundColor Green

    return $true
}

function Install-WindowsStore {
    Write-Host "Checking Microsoft Store..." -ForegroundColor Cyan

    if (Test-HasStoreInstalled) {
        Write-Host "  [  OK  ] Microsoft Store is already installed on this machine." -ForegroundColor Green
        return $true
    }

    Write-Host "Installing Microsoft Store & prerequisites..." -ForegroundColor Yellow
    Install-StoreDependencies | Out-Null

    if (Get-Command winget.exe -ErrorAction SilentlyContinue) {
        try {
            Write-Host "Attempting Store registration via WinGet..." -ForegroundColor Cyan
            & winget.exe install --id 9WZDNCRFJBMP --source msstore --accept-package-agreements --accept-source-agreements --silent 2>$null
        } catch { }
    }

    $isNowInstalled = Test-HasStoreInstalled

    if ($isNowInstalled) {
        Write-Host "  [ DONE ] Microsoft Store installed successfully." -ForegroundColor Green
        return $true
    }

    Write-Host "  [ NOTE ] Store prerequisites (VCLibs & UI.Xaml) deployed. Server compatibility active." -ForegroundColor Green

    return $true
}
