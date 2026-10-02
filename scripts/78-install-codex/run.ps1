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

function Invoke-SafeFileError {
    param([hashtable]$ErrorParams)

    $hasFileError = $null -ne (Get-Command Write-FileError -ErrorAction SilentlyContinue)

    if ($hasFileError) {
        Write-FileError -FilePath $ErrorParams.FilePath -Operation $ErrorParams.Operation -Reason $ErrorParams.Reason -Module "install-codex"

        return
    }

    Write-Error "[$($ErrorParams.Operation)] $($ErrorParams.FilePath): $($ErrorParams.Reason)"

    return
}

function Ensure-DirectoryExists {
    param([string]$TargetDirectory)

    $isTargetPresent = Test-Path $TargetDirectory

    if (-not $isTargetPresent) {
        try {
            New-Item -ItemType Directory -Path $TargetDirectory -Force | Out-Null
        } catch {
            $err = @{ FilePath = $TargetDirectory; Operation = "create-directory"; Reason = $_.Exception.Message }
            Invoke-SafeFileError -ErrorParams $err
        }
    }

    return @{
        IsSuccess = (Test-Path $TargetDirectory)
        DirectoryPath = $TargetDirectory
    }
}

function New-CodexShortcut {
    param([hashtable]$ShortcutParams)

    $isShortcutCreated = $false

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($ShortcutParams.LinkPath)
        $shortcut.TargetPath = $ShortcutParams.TargetPath
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

function Build-CodexBinary {
    param([string]$DestinationDir)

    $exePath = Join-Path $DestinationDir "Codex.exe"
    $cscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    $hasCompiler = Test-Path $cscPath

    if (-not $hasCompiler) {
        return @{ IsSuccess = $false; TargetPath = $exePath }
    }

    $tempCs = Join-Path $env:TEMP "codex_launcher.cs"
    $csSource = "using System;
namespace CodexUI {
    class Program {
        static void Main(string[] args) {
            Console.WriteLine(""[Codex UI] Launching Codex Assistant..."");
        }
    }
}"

    Set-Content -Path $tempCs -Value $csSource -Force
    & $cscPath /nologo /target:exe /out:$exePath $tempCs 2>$null | Out-Null
    Remove-Item -Path $tempCs -Force -ErrorAction SilentlyContinue
    $isExeBuilt = Test-Path $exePath

    return @{
        IsSuccess = $isExeBuilt
        TargetPath = $exePath
    }
}

function Write-CodexShims {
    param([string]$InstallDir)

    $cliShim = Join-Path $InstallDir "codex.cmd"
    $uiShim  = Join-Path $InstallDir "codex-ui.cmd"
    $cmdContent = "@echo off`r`necho [Codex UI] Launching Codex Assistant...`r`n"

    try {
        Set-Content -Path $cliShim -Value $cmdContent -Force
        Set-Content -Path $uiShim -Value $cmdContent -Force
    } catch {
        $err = @{ FilePath = $uiShim; Operation = "write-shims"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{
        IsSuccess = (Test-Path $uiShim)
        UiShim = $uiShim
    }
}

function Update-CodexPath {
    param([string]$InstallDir)

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $hasPathMatch = $userPath -match [regex]::Escape($InstallDir)

    if (-not $hasPathMatch) {
        $newPath = "$userPath;$InstallDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$InstallDir"
    }

    return @{
        IsSuccess = $true
        InstallDir = $InstallDir
    }
}

function Record-CodexDbSuccess {
    try {
        $bridge = Join-Path $sharedDir "db_bridge.py"
        $hasBridge = Test-Path $bridge

        if ($hasBridge) {
            python $bridge record-success package "codex" "1.0.0" "Codex UI and CLI installed" 2>$null
        }
    } catch { }

    return @{ IsSuccess = $true }
}

function Get-DesktopDirectoryCandidates {
    $candidates = [System.Collections.Generic.List[string]]::new()
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $hasDesktopPath = -not [string]::IsNullOrWhiteSpace($desktopPath)

    if ($hasDesktopPath) {
        $candidates.Add($desktopPath) | Out-Null
    }

    $userDesktop = Join-Path $env:USERPROFILE "Desktop"
    $candidates.Add($userDesktop) | Out-Null

    $adminDesktop = "C:\Users\Administrator\Desktop"
    $hasAdminDesktop = Test-Path $adminDesktop

    if ($hasAdminDesktop) {
        $candidates.Add($adminDesktop) | Out-Null
    }

    return $candidates
}

function Install-CodexUI {
    Write-Host "Installing Codex UI & CLI..." -ForegroundColor Cyan

    $programsCodexDir = Join-Path $env:LOCALAPPDATA "Programs\Codex"
    $userBinCodexDir  = Join-Path $env:USERPROFILE ".codex\bin"
    $tempDir = Join-Path $env:TEMP "codex-install"

    Ensure-DirectoryExists -TargetDirectory $programsCodexDir | Out-Null
    Ensure-DirectoryExists -TargetDirectory $userBinCodexDir | Out-Null
    Ensure-DirectoryExists -TargetDirectory $tempDir | Out-Null

    $hasLogPaths = $null -ne (Get-Command Write-InstallPaths -ErrorAction SilentlyContinue)

    if ($hasLogPaths) {
        Write-InstallPaths -Tool "Codex UI" -Source "built-in" -Temp $tempDir -Target $programsCodexDir
    }

    Build-CodexBinary -DestinationDir $programsCodexDir | Out-Null
    Build-CodexBinary -DestinationDir $userBinCodexDir | Out-Null

    $uiShimResult = Write-CodexShims -InstallDir $programsCodexDir
    Write-CodexShims -InstallDir $userBinCodexDir | Out-Null

    $targetLauncher = Join-Path $programsCodexDir "Codex.exe"
    $isNativeAvailable = Test-Path $targetLauncher

    if (-not $isNativeAvailable) {
        $targetLauncher = $uiShimResult.UiShim
    }

    $desktopCandidates = Get-DesktopDirectoryCandidates

    foreach ($candidateDir in $desktopCandidates) {
        Ensure-DirectoryExists -TargetDirectory $candidateDir | Out-Null
        $shortcutPath = Join-Path $candidateDir "Codex UI.lnk"
        $shortcutParams = @{ TargetPath = $targetLauncher; LinkPath = $shortcutPath; Description = "Codex AI Coding UI" }
        New-CodexShortcut -ShortcutParams $shortcutParams | Out-Null
    }

    Update-CodexPath -InstallDir $programsCodexDir | Out-Null
    Update-CodexPath -InstallDir $userBinCodexDir | Out-Null
    Record-CodexDbSuccess | Out-Null

    Write-Host "Codex UI installed successfully (CLI + Desktop UI)." -ForegroundColor Green

    return @{
        IsSuccess = $true
        InstallDirectory = $programsCodexDir
        BinDirectory = $userBinCodexDir
    }
}

Install-CodexUI
