<#
.SYNOPSIS
    Antigravity uninstaller helper.
#>

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
        $hasUninstaller = Test-Path $uninstaller

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
        $hasDir = Test-Path $dir

        if ($hasDir) {
            Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Remove-CliResidualDirectories {
    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    $hasCli = Test-Path $installDir

    if ($hasCli) {
        Write-Host "Removing CLI directory: $installDir..." -ForegroundColor Cyan
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    $antigravityRoot = Join-Path $env:USERPROFILE ".antigravity"
    $hasRoot = Test-Path $antigravityRoot

    if ($hasRoot) {
        $childCount = (Get-ChildItem -Path $antigravityRoot -Force | Measure-Object).Count
        if ($childCount -eq 0) {
            Remove-Item -Path $antigravityRoot -Force -ErrorAction SilentlyContinue
        }
    }
}

function Remove-AntigravityShortcuts {
    $desktopDir = [Environment]::GetFolderPath("Desktop")
    $hasDesktop = $desktopDir -and (Test-Path $desktopDir)

    if ($hasDesktop) {
        $desktopShortcut = Join-Path $desktopDir "Antigravity.lnk"
        if (Test-Path $desktopShortcut) {
            Remove-Item -Path $desktopShortcut -Force -ErrorAction SilentlyContinue
            Write-Host "Removed Desktop shortcut: $desktopShortcut" -ForegroundColor Cyan
        }
    }

    $programsDir = [Environment]::GetFolderPath("Programs")
    $hasPrograms = $programsDir -and (Test-Path $programsDir)

    if ($hasPrograms) {
        $startMenuShortcut = Join-Path $programsDir "Antigravity.lnk"
        if (Test-Path $startMenuShortcut) {
            Remove-Item -Path $startMenuShortcut -Force -ErrorAction SilentlyContinue
            Write-Host "Removed Start Menu shortcut: $startMenuShortcut" -ForegroundColor Cyan
        }
    }
}

function Remove-FromPathVariables {
    param([string]$InstallDir)

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if (-not [string]::IsNullOrEmpty($userPath)) {
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

function Uninstall-Antigravity {
    Write-Host "Uninstalling Antigravity..." -ForegroundColor Cyan

    Stop-RunningAntigravityProcs
    Invoke-IdeUninstallerExecutable
    Remove-IdeResidualDirectories

    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    Remove-CliResidualDirectories
    Remove-AntigravityShortcuts
    Remove-FromPathVariables -InstallDir $installDir

    Broadcast-EnvironmentChange
    Write-Host "Antigravity uninstalled successfully." -ForegroundColor Green
}
