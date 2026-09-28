<#
.SYNOPSIS
    Antigravity uninstaller helper supporting standard and deep purge.
#>

function Write-FileError {
    param(
        [string]$FilePath,
        [string]$Reason,
        [string]$Path = $FilePath
    )

    $target = if ($FilePath) { $FilePath } else { $Path }
    Write-Host "  [ FAIL ] FILE-ERROR path='$target' reason='$Reason'" -ForegroundColor Red
}

$backupHelper = Join-Path $PSScriptRoot "backup-state.ps1"
$hasBackupHelper = Test-Path -LiteralPath $backupHelper

if ($hasBackupHelper) {
    . $backupHelper
}

$envHelper = Join-Path $PSScriptRoot "env-path.ps1"
$hasEnvHelper = Test-Path -LiteralPath $envHelper

if ($hasEnvHelper) {
    . $envHelper
}

function Test-IsSafePath {
    param([string]$Path)

    $hasPath = -not [string]::IsNullOrWhiteSpace($Path)
    if (-not $hasPath) {
        return $false
    }

    $normalized = $Path.Replace("/", "\").ToLowerInvariant()
    $isWorkDir = $normalized.StartsWith("d:\work") -or $normalized.Contains("\work\")

    if ($isWorkDir) {
        Write-FileError -FilePath $Path -Reason "Safety barrier tripped: cannot modify workspace path"
        return $false
    }

    return $true
}

function Remove-SafeDirectory {
    param([string]$DirPath)

    $hasDir = Test-Path -LiteralPath $DirPath
    if (-not $hasDir) {
        return
    }

    $isSafe = Test-IsSafePath -Path $DirPath
    if (-not $isSafe) {
        return
    }

    try {
        Remove-Item -LiteralPath $DirPath -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -FilePath $DirPath -Reason $_.Exception.Message
    }
}

function Remove-SafeRegistryKey {
    param([string]$RegPath)

    $hasKey = Test-Path -LiteralPath $RegPath
    if (-not $hasKey) {
        return
    }

    try {
        Remove-Item -LiteralPath $RegPath -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -FilePath $RegPath -Reason $_.Exception.Message
    }
}

function Stop-RunningAntigravityProcs {
    Write-Host "Stopping running Antigravity processes..." -ForegroundColor Cyan
    Get-Process -Name "antigravity*", "agy*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
}

function Invoke-IdeUninstallerExecutable {
    $uninstallerCandidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\Uninstall Antigravity.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity\Uninstall Antigravity.exe")
    )

    foreach ($uninstaller in $uninstallerCandidates) {
        $hasUninstaller = Test-Path -LiteralPath $uninstaller

        if ($hasUninstaller) {
            Write-Host "Running Antigravity IDE uninstaller: $uninstaller..." -ForegroundColor Cyan
            try {
                Start-Process -FilePath $uninstaller -ArgumentList "/currentuser", "/S" -Wait -NoNewWindow
            } catch {
                Write-Host "  [ NOTE ] IDE uninstaller message: $($_.Exception.Message)" -ForegroundColor DarkGray
            }
            break
        }
    }
}

function Remove-IdeResidualDirectories {
    $dirs = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity")
    )

    foreach ($dir in $dirs) {
        Remove-SafeDirectory -DirPath $dir
    }
}

function Remove-CliResidualDirectories {
    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    $hasCli = Test-Path -LiteralPath $installDir

    if ($hasCli) {
        Write-Host "Removing CLI directory: $installDir..." -ForegroundColor Cyan
        Remove-SafeDirectory -DirPath $installDir
    }

    $antigravityRoot = Join-Path $env:USERPROFILE ".antigravity"
    $hasRoot = Test-Path -LiteralPath $antigravityRoot

    if ($hasRoot) {
        $childCount = (Get-ChildItem -Path $antigravityRoot -Force | Measure-Object).Count
        $isEmpty = ($childCount -eq 0)

        if ($isEmpty) {
            Remove-SafeDirectory -DirPath $antigravityRoot
        }
    }
}

function Remove-ShortcutFile {
    param([string]$ShortcutPath)

    $hasShortcut = Test-Path -LiteralPath $ShortcutPath
    if (-not $hasShortcut) {
        return
    }

    try {
        Remove-Item -LiteralPath $ShortcutPath -Force -ErrorAction SilentlyContinue
        Write-Host "Removed shortcut: $ShortcutPath" -ForegroundColor Cyan
    } catch {
        Write-FileError -FilePath $ShortcutPath -Reason $_.Exception.Message
    }
}

function Remove-AntigravityShortcuts {
    $desktopDir = [Environment]::GetFolderPath("Desktop")
    $hasDesktop = -not [string]::IsNullOrWhiteSpace($desktopDir)

    if ($hasDesktop) {
        Remove-ShortcutFile -ShortcutPath (Join-Path $desktopDir "Antigravity.lnk")
    }

    $programsDir = [Environment]::GetFolderPath("Programs")
    $hasPrograms = -not [string]::IsNullOrWhiteSpace($programsDir)

    if ($hasPrograms) {
        Remove-ShortcutFile -ShortcutPath (Join-Path $programsDir "Antigravity.lnk")
    }
}

function Remove-FromPathVariables {
    param([string]$InstallDir)

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $hasUserPath = -not [string]::IsNullOrEmpty($userPath)

    if ($hasUserPath) {
        $parts = $userPath -split ';' | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_) -and
            $_ -ne $InstallDir -and
            $_ -ne (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\bin") -and
            $_ -ne (Join-Path $env:LOCALAPPDATA "Programs\antigravity\bin")
        }
        $newUserPath = $parts -join ';'
        [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
        Write-Host "Removed $InstallDir from User PATH." -ForegroundColor Cyan
    }

    $procParts = $env:PATH -split ';' | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_) -and
        $_ -ne $InstallDir -and
        $_ -ne (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\bin") -and
        $_ -ne (Join-Path $env:LOCALAPPDATA "Programs\antigravity\bin")
    }
    $env:PATH = $procParts -join ';'
}

function Purge-AntigravityConfigurations {
    $dirs = @(
        (Join-Path $env:APPDATA "Antigravity"),
        (Join-Path $env:LOCALAPPDATA "Antigravity"),
        (Join-Path $env:LOCALAPPDATA "antigravity-updater"),
        (Join-Path $env:USERPROFILE ".gemini"),
        (Join-Path $env:USERPROFILE ".cache\antigravity")
    )

    foreach ($dir in $dirs) {
        Remove-SafeDirectory -DirPath $dir
    }
}

function Purge-AntigravityTemp {
    $patterns = @("antigravity*", "gemini*")
    foreach ($pat in $patterns) {
        Get-ChildItem -Path $env:TEMP -Filter $pat -Force -ErrorAction SilentlyContinue | ForEach-Object {
            Remove-SafeDirectory -DirPath $_.FullName
        }
    }
}

function Remove-AntigravityRegistryEntries {
    Remove-SafeRegistryKey -RegPath "HKCU:\Software\Google\Antigravity"

    $uninstallRoot = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    $hasUninstall = Test-Path -LiteralPath $uninstallRoot

    if (-not $hasUninstall) {
        return
    }

    Get-ChildItem -Path $uninstallRoot -ErrorAction SilentlyContinue | Where-Object {
        $_.PSChildName -like "*Antigravity*"
    } | ForEach-Object {
        Remove-SafeRegistryKey -RegPath $_.PSPath
    }
}

function Uninstall-Antigravity {
    [CmdletBinding(DefaultParameterSetName = "Standard")]
    param(
        [Parameter(ParameterSetName = "Deep")]
        [Alias("Deep")]
        [switch]$All
    )

    $isDeep = $All.IsPresent

    if ($isDeep) {
        Write-Host "Executing deep uninstallation of Antigravity..." -ForegroundColor Yellow
        Export-AntigravityState
    } else {
        Write-Host "Uninstalling Antigravity..." -ForegroundColor Cyan
    }

    Stop-RunningAntigravityProcs
    Invoke-IdeUninstallerExecutable
    Remove-IdeResidualDirectories

    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    Remove-CliResidualDirectories
    Remove-AntigravityShortcuts
    Remove-FromPathVariables -InstallDir $installDir

    if ($isDeep) {
        Purge-AntigravityConfigurations
        Purge-AntigravityTemp
        Remove-AntigravityRegistryEntries
    }

    if (Get-Command Broadcast-EnvironmentChange -ErrorAction SilentlyContinue) {
        Broadcast-EnvironmentChange
    }

    if ($isDeep) {
        Write-Host "[  OK  ] Antigravity completely removed from machine." -ForegroundColor Green
    } else {
        Write-Host "Antigravity uninstalled successfully." -ForegroundColor Green
    }
}
