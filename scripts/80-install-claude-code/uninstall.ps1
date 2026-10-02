param([string]$Command = "uninstall")
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"

$loggingPath = Join-Path $sharedDir "logging.ps1"
$hasLogging = Test-Path $loggingPath

if ($hasLogging) {
    . $loggingPath
}

$pathUtilsScript = Join-Path $sharedDir "path-utils.ps1"
$hasPathUtils = Test-Path $pathUtilsScript

if ($hasPathUtils) {
    . $pathUtilsScript
}

function Invoke-SafeFileError {
    param([hashtable]$ErrorParams)

    $hasFileError = $null -ne (Get-Command Write-FileError -ErrorAction SilentlyContinue)

    if ($hasFileError) {
        Write-FileError -FilePath $ErrorParams.FilePath -Operation $ErrorParams.Operation -Reason $ErrorParams.Reason -Module "uninstall-claude-code"

        return
    }

    Write-Error "[$($ErrorParams.Operation)] $($ErrorParams.FilePath): $($ErrorParams.Reason)"

    return
}

function Remove-PathSafe {
    param([string]$TargetPath)

    $isTargetPresent = -not [string]::IsNullOrWhiteSpace($TargetPath) -and (Test-Path $TargetPath)

    if (-not $isTargetPresent) {
        return @{ IsSuccess = $true; TargetPath = $TargetPath }
    }

    try {
        Remove-Item -Path $TargetPath -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    } catch {
        $err = @{ FilePath = $TargetPath; Operation = "remove-path"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{
        IsSuccess = (-not (Test-Path $TargetPath))
        TargetPath = $TargetPath
    }
}

function Get-DesktopCandidateDirectories {
    $rawList = @(
        [Environment]::GetFolderPath("Desktop"),
        (Join-Path $env:USERPROFILE "Desktop"),
        (Join-Path $env:PUBLIC "Desktop"),
        "C:\Users\Administrator\Desktop"
    )
    $validCandidates = [System.Collections.Generic.List[string]]::new()

    foreach ($path in $rawList) {
        $hasPath = -not [string]::IsNullOrWhiteSpace($path) -and (Test-Path $path)

        if ($hasPath -and -not $validCandidates.Contains($path)) {
            $validCandidates.Add($path) | Out-Null
        }
    }

    return $validCandidates
}

function Get-StartMenuCandidateDirectories {
    $rawList = @(
        [Environment]::GetFolderPath("Programs"),
        (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"),
        "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    )
    $validCandidates = [System.Collections.Generic.List[string]]::new()

    foreach ($path in $rawList) {
        $hasPath = -not [string]::IsNullOrWhiteSpace($path) -and (Test-Path $path)

        if ($hasPath -and -not $validCandidates.Contains($path)) {
            $validCandidates.Add($path) | Out-Null
        }
    }

    return $validCandidates
}

function Remove-CandidateShortcuts {
    param(
        [System.Collections.Generic.List[string]]$Directories,
        [string[]]$ShortcutNames
    )

    foreach ($dir in $Directories) {
        foreach ($name in $ShortcutNames) {
            $linkPath = Join-Path $dir $name
            Remove-PathSafe -TargetPath $linkPath | Out-Null
        }
    }

    return @{ IsSuccess = $true }
}

function Remove-ClaudeShortcuts {
    $shortcutNames = @("Claude Code UI.lnk", "Claude Code.lnk", "Claude.lnk")
    $desktopDirs = Get-DesktopCandidateDirectories
    Remove-CandidateShortcuts -Directories $desktopDirs -ShortcutNames $shortcutNames | Out-Null

    $startMenuDirs = Get-StartMenuCandidateDirectories
    Remove-CandidateShortcuts -Directories $startMenuDirs -ShortcutNames $shortcutNames | Out-Null

    return @{ IsSuccess = $true }
}

function Remove-ClaudeDirectoriesAndShims {
    $userBinDir = Join-Path $env:USERPROFILE ".claude\bin"
    $programsClaudeDir = Join-Path $env:LOCALAPPDATA "Programs\Claude"

    Remove-PathSafe -TargetPath (Join-Path $userBinDir "claude-ui.cmd") | Out-Null
    Remove-PathSafe -TargetPath (Join-Path $userBinDir "claude.cmd") | Out-Null
    Remove-PathSafe -TargetPath $userBinDir | Out-Null
    Remove-PathSafe -TargetPath $programsClaudeDir | Out-Null

    return @{ IsSuccess = $true }
}

function Clean-ClaudeEnvironmentPath {
    $userBinDir = Join-Path $env:USERPROFILE ".claude\bin"
    $programsClaudeDir = Join-Path $env:LOCALAPPDATA "Programs\Claude"

    $hasRemovePath = $null -ne (Get-Command Remove-FromUserPath -ErrorAction SilentlyContinue)

    if ($hasRemovePath) {
        Remove-FromUserPath -Directory $userBinDir | Out-Null
        Remove-FromMachinePath -Directory $userBinDir | Out-Null
        Remove-FromUserPath -Directory $programsClaudeDir | Out-Null
        Remove-FromMachinePath -Directory $programsClaudeDir | Out-Null
    }

    return @{ IsSuccess = $true }
}

function Uninstall-ClaudeNpmPackage {
    $npmCmd = Get-Command "npm" -ErrorAction SilentlyContinue
    $hasNpm = $null -ne $npmCmd

    if (-not $hasNpm) {
        return @{ IsSuccess = $true }
    }

    try {
        npm uninstall -g @anthropic-ai/claude-code 2>$null | Out-Null
    } catch { }

    return @{ IsSuccess = $true }
}

function Uninstall-ClaudeCode {
    Write-Host "Uninstalling Claude Code UI & CLI..." -ForegroundColor Cyan

    Remove-ClaudeDirectoriesAndShims | Out-Null
    Remove-ClaudeShortcuts | Out-Null
    Clean-ClaudeEnvironmentPath | Out-Null
    Uninstall-ClaudeNpmPackage | Out-Null

    Write-Host "Claude Code uninstalled successfully." -ForegroundColor Green

    return @{ IsSuccess = $true }
}

Uninstall-ClaudeCode
