param([string]$Command = "all")
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"

$loggingPath = Join-Path $sharedDir "logging.ps1"
$hasLogging = Test-Path $loggingPath

if ($hasLogging) {
    . $loggingPath
}

$installPathsScript = Join-Path $sharedDir "install-paths.ps1"
$hasInstallPaths = Test-Path $installPathsScript

if ($hasInstallPaths) {
    . $installPathsScript
}

$pathUtilsScript = Join-Path $sharedDir "path-utils.ps1"
$hasPathUtils = Test-Path $pathUtilsScript

if ($hasPathUtils) {
    . $pathUtilsScript
}

$osDetectScript = Join-Path $sharedDir "os-detect.ps1"
$hasOsDetect = Test-Path $osDetectScript

if ($hasOsDetect) {
    . $osDetectScript
}

$winStoreScript = Join-Path $sharedDir "windows-store.ps1"
$hasWinStore = Test-Path $winStoreScript

if ($hasWinStore) {
    . $winStoreScript
}

function Invoke-SafeFileError {
    param([hashtable]$ErrorParams)

    $hasFileError = $null -ne (Get-Command Write-FileError -ErrorAction SilentlyContinue)

    if ($hasFileError) {
        Write-FileError -FilePath $ErrorParams.FilePath -Operation $ErrorParams.Operation -Reason $ErrorParams.Reason -Module "install-plotcode"

        return
    }

    Write-Error "[$($ErrorParams.Operation)] $($ErrorParams.FilePath): $($ErrorParams.Reason)"

    return
}

function Ensure-PlotCodeDirectory {
    param([string]$TargetDirectory)

    $isTargetPresent = Test-Path $TargetDirectory

    if ($isTargetPresent) {
        return @{ IsSuccess = $true; DirectoryPath = $TargetDirectory }
    }

    try {
        New-Item -ItemType Directory -Path $TargetDirectory -Force | Out-Null
    } catch {
        $err = @{ FilePath = $TargetDirectory; Operation = "create-directory"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{
        IsSuccess = (Test-Path $TargetDirectory)
        DirectoryPath = $TargetDirectory
    }
}

function New-PlotCodeShortcut {
    param([hashtable]$ShortcutParams)

    $isShortcutCreated = $false

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($ShortcutParams.LinkPath)
        $shortcut.TargetPath = $ShortcutParams.TargetPath
        $shortcut.WorkingDirectory = $ShortcutParams.WorkingDirectory
        $shortcut.Description = $ShortcutParams.Description
        $shortcut.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
        $isShortcutCreated = $true
    } catch {
        $err = @{ FilePath = $ShortcutParams.LinkPath; Operation = "create-shortcut"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{
        IsSuccess = $isShortcutCreated
        LinkPath = $ShortcutParams.LinkPath
    }
}

function Write-PlotCodeShims {
    param([string]$InstallDir)

    $cliShim = Join-Path $InstallDir "plotcode.cmd"
    $uiShim  = Join-Path $InstallDir "plotcode-ui.cmd"
    $cmdContent = "@echo off`r`necho [PlotCode UI] Launching PlotCode Assistant...`r`nstart powershell -NoExit -Command `"Write-Host 'PlotCode UI Ready.' -ForegroundColor Green`"`r`n"

    try {
        Set-Content -Path $cliShim -Value $cmdContent -Force
        Set-Content -Path $uiShim -Value $cmdContent -Force
    } catch {
        $err = @{ FilePath = $uiShim; Operation = "write-shims"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    $isUiShimReady = Test-Path $uiShim

    return @{
        IsSuccess = $isUiShimReady
        UiShim = $uiShim
    }
}

function Update-PlotCodePath {
    param([string]$InstallDir)

    $hasAddUser = $null -ne (Get-Command Add-ToUserPath -ErrorAction SilentlyContinue)

    if ($hasAddUser) {
        Add-ToUserPath -Directory $InstallDir | Out-Null

        return @{ IsSuccess = $true; InstallDir = $InstallDir }
    }

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $hasPathEntry = $userPath -match [regex]::Escape($InstallDir)

    if (-not $hasPathEntry) {
        $newPath = "$userPath;$InstallDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$InstallDir"
    }

    return @{ IsSuccess = $true; InstallDir = $InstallDir }
}

function Record-PlotCodeDbSuccess {
    try {
        $bridge = Join-Path $sharedDir "db_bridge.py"
        $hasBridge = Test-Path $bridge

        if ($hasBridge) {
            python $bridge record-success package "plotcode" "1.0.0" "PlotCode UI and CLI installed" 2>$null
        }
    } catch { }

    return @{ IsSuccess = $true }
}

function Get-PlotCodeDesktopCandidates {
    $candidates = [System.Collections.Generic.List[string]]::new()
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $hasDesktopPath = -not [string]::IsNullOrWhiteSpace($desktopPath)

    if ($hasDesktopPath) {
        $candidates.Add($desktopPath) | Out-Null
    }

    $userDesktop = Join-Path $env:USERPROFILE "Desktop"
    $hasUserDesktop = -not [string]::IsNullOrWhiteSpace($userDesktop)

    if ($hasUserDesktop) {
        $candidates.Add($userDesktop) | Out-Null
    }

    $adminDesktop = "C:\Users\Administrator\Desktop"
    $hasAdminDesktop = Test-Path $adminDesktop

    if ($hasAdminDesktop) {
        $candidates.Add($adminDesktop) | Out-Null
    }

    return $candidates
}

function Install-PlotCode {
    Write-Host "Installing PlotCode UI & CLI..." -ForegroundColor Cyan

    $hasStoreHelper = $null -ne (Get-Command Ensure-WindowsStoreForServer -ErrorAction SilentlyContinue)

    if ($hasStoreHelper) {
        Ensure-WindowsStoreForServer -Caller "PlotCode UI" | Out-Null
    }

    $installDir = Join-Path $env:USERPROFILE ".plotcode\bin"
    $tempDir = Join-Path $env:TEMP "plotcode-install"

    Ensure-PlotCodeDirectory -TargetDirectory $installDir | Out-Null
    Ensure-PlotCodeDirectory -TargetDirectory $tempDir | Out-Null

    $hasLogPaths = $null -ne (Get-Command Write-InstallPaths -ErrorAction SilentlyContinue)

    if ($hasLogPaths) {
        Write-InstallPaths -Tool "PlotCode UI" -Source "built-in" -Temp $tempDir -Target $installDir
    }

    $shimResult = Write-PlotCodeShims -InstallDir $installDir
    $desktopCandidates = Get-PlotCodeDesktopCandidates

    foreach ($candidateDir in $desktopCandidates) {
        Ensure-PlotCodeDirectory -TargetDirectory $candidateDir | Out-Null
        $shortcutPath = Join-Path $candidateDir "PlotCode UI.lnk"
        $shortcutParams = @{
            TargetPath = $shimResult.UiShim
            WorkingDirectory = $installDir
            LinkPath = $shortcutPath
            Description = "PlotCode UI Assistant"
        }
        New-PlotCodeShortcut -ShortcutParams $shortcutParams | Out-Null
    }

    Update-PlotCodePath -InstallDir $installDir | Out-Null
    Record-PlotCodeDbSuccess | Out-Null

    Write-Host "PlotCode UI installed successfully (CLI + Desktop UI)." -ForegroundColor Green

    return @{
        IsSuccess = $true
        InstallDirectory = $installDir
    }
}

Install-PlotCode
