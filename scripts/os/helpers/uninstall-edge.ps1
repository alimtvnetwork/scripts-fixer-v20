<#
.SYNOPSIS
    Microsoft Edge uninstaller and update service blocker (Chris Titus WinUtil methodology).
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

function Stop-EdgeProcesses {
    Write-Host "Stopping running Microsoft Edge processes..." -ForegroundColor Cyan
    Get-Process -Name "msedge", "msedgewebview2", "MicrosoftEdgeUpdate" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 300
}

function Find-EdgeSetupExecutable {
    $searchPatterns = @(
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\*\Installer\setup.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\*\Installer\setup.exe",
        "${env:ProgramFiles(x86)}\Microsoft\EdgeCore\*\Installer\setup.exe",
        "$env:ProgramFiles\Microsoft\EdgeCore\*\Installer\setup.exe"
    )

    foreach ($pattern in $searchPatterns) {
        $matches = Get-Item -Path $pattern -ErrorAction SilentlyContinue

        if ($matches) {
            $first = $matches | Select-Object -First 1
            return $first.FullName
        }
    }

    return $null
}

function Invoke-EdgeUninstallerExecutable {
    param([string]$SetupPath)

    $hasSetup = -not [string]::IsNullOrWhiteSpace($SetupPath) -and (Test-Path -LiteralPath $SetupPath)

    if (-not $hasSetup) {
        Write-Host "Microsoft Edge setup.exe not found on system." -ForegroundColor DarkGray
        return
    }

    Write-Host "Executing Edge uninstaller: $SetupPath..." -ForegroundColor Cyan

    try {
        Start-Process -FilePath $SetupPath -ArgumentList "--uninstall", "--system-level", "--verbose-logging", "--force-uninstall" -Wait -NoNewWindow
    } catch {
        Write-FileError -FilePath $SetupPath -Reason $_.Exception.Message
    }
}

function Disable-EdgeServices {
    Write-Host "Stopping and disabling Edge update services..." -ForegroundColor Cyan

    $services = @("edgeupdate", "edgeupdatem")
    foreach ($svcName in $services) {
        $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
        $hasSvc = $null -ne $svc

        if ($hasSvc) {
            try {
                Stop-Service -Name $svcName -Force -ErrorAction SilentlyContinue
                Set-Service -Name $svcName -StartupType Disabled -ErrorAction SilentlyContinue
            } catch {
                Write-FileError -FilePath "Service:$svcName" -Reason $_.Exception.Message
            }
        }
    }
}

function Disable-EdgeScheduledTasks {
    Write-Host "Disabling Edge update scheduled tasks..." -ForegroundColor Cyan

    $tasks = @("MicrosoftEdgeUpdateTaskMachineCore*", "MicrosoftEdgeUpdateTaskMachineUA*")
    foreach ($taskPat in $tasks) {
        try {
            Get-ScheduledTask -TaskName $taskPat -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue | Out-Null
        } catch {
            Write-FileError -FilePath "ScheduledTask:$taskPat" -Reason $_.Exception.Message
        }
    }
}

function Set-RegistryDwordSafely {
    param(
        [string]$KeyPath,
        [string]$ValueName,
        [int]$ValueData
    )

    $hasKey = Test-Path -LiteralPath $KeyPath

    if (-not $hasKey) {
        try {
            New-Item -Path $KeyPath -Force -ErrorAction SilentlyContinue | Out-Null
        } catch {
            Write-FileError -FilePath $KeyPath -Reason $_.Exception.Message
            return
        }
    }

    try {
        Set-ItemProperty -Path $KeyPath -Name $ValueName -Value $ValueData -Type DWord -Force -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -FilePath "$KeyPath\$ValueName" -Reason $_.Exception.Message
    }
}

function Set-EdgeUpdateBlockRegistry {
    Write-Host "Configuring Edge Chromium block policy..." -ForegroundColor Cyan
    Set-RegistryDwordSafely -KeyPath "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -ValueName "DoNotUpdateToEdgeWithChromium" -ValueData 1
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

function Remove-EdgeShortcuts {
    Write-Host "Removing Microsoft Edge shortcuts..." -ForegroundColor Cyan

    $userDesktop = [Environment]::GetFolderPath("Desktop")
    $hasUserDesktop = -not [string]::IsNullOrWhiteSpace($userDesktop)

    if ($hasUserDesktop) {
        Remove-ShortcutFile -ShortcutPath (Join-Path $userDesktop "Microsoft Edge.lnk")
    }

    $publicDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
    $hasPublicDesktop = -not [string]::IsNullOrWhiteSpace($publicDesktop)

    if ($hasPublicDesktop) {
        Remove-ShortcutFile -ShortcutPath (Join-Path $publicDesktop "Microsoft Edge.lnk")
    }

    $userPrograms = [Environment]::GetFolderPath("Programs")
    $hasUserPrograms = -not [string]::IsNullOrWhiteSpace($userPrograms)

    if ($hasUserPrograms) {
        Remove-ShortcutFile -ShortcutPath (Join-Path $userPrograms "Microsoft Edge.lnk")
    }

    $commonPrograms = [Environment]::GetFolderPath("CommonPrograms")
    $hasCommonPrograms = -not [string]::IsNullOrWhiteSpace($commonPrograms)

    if ($hasCommonPrograms) {
        Remove-ShortcutFile -ShortcutPath (Join-Path $commonPrograms "Microsoft Edge.lnk")
    }
}

function Uninstall-MicrosoftEdge {
    Write-Host "Starting Microsoft Edge uninstallation (WinUtil method)..." -ForegroundColor Cyan

    Stop-EdgeProcesses
    $setupPath = Find-EdgeSetupExecutable
    Invoke-EdgeUninstallerExecutable -SetupPath $setupPath
    Disable-EdgeServices
    Disable-EdgeScheduledTasks
    Set-EdgeUpdateBlockRegistry
    Remove-EdgeShortcuts

    Write-Host "[  OK  ] Microsoft Edge uninstalled and update blocks applied." -ForegroundColor Green
}

Uninstall-MicrosoftEdge
