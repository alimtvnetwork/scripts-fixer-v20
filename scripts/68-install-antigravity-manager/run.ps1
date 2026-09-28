param(
    [Parameter(Position = 0)][string]$Command = "install",
    [Parameter(ValueFromRemainingArguments = $true)][string[]]$Rest
)

$ErrorActionPreference = "Stop"

function Write-FileError {
    param(
        [string]$FilePath,
        [string]$Reason,
        [string]$Path = $FilePath
    )

    $target = if ($FilePath) { $FilePath } else { $Path }
    Write-Host "  [ FAIL ] FILE-ERROR path='$target' reason='$Reason'" -ForegroundColor Red
}

function Test-IsSafePath {
    param(
        [Alias("TargetDir", "FilePath")]
        [string]$Path
    )

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

function Remove-ShortcutFile {
    param([string]$ShortcutPath)

    $hasShortcut = Test-Path -LiteralPath $ShortcutPath
    if (-not $hasShortcut) {
        return
    }

    try {
        Remove-Item -LiteralPath $ShortcutPath -Force -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -FilePath $ShortcutPath -Reason $_.Exception.Message
    }
}

function Get-LatestManagerUrl {
    $apiUrl = "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/latest"
    $response = Invoke-RestMethod -Uri $apiUrl

    foreach ($asset in $response.assets) {
        $hasExe = $asset.name.EndsWith("-setup.exe")

        if ($hasExe) {
            return $asset.browser_download_url
        }
    }

    throw "No -setup.exe found"
}

function Test-IsManagerInstalled {
    $regUser = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $isInstalledInReg = $null -ne (Get-ItemProperty $regUser -ErrorAction SilentlyContinue | Where-Object DisplayName -match "Antigravity Manager")
    $isInstalledInAppData = Test-Path -LiteralPath "$env:LOCALAPPDATA\Programs\antigravity-manager"
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

function Stop-AntigravityManagerProcs {
    Write-Host "Stopping running Anti-Gravity Manager processes..." -ForegroundColor Cyan
    Get-Process -Name "antigravity-manager*", "Antigravity Manager*", "agm*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
}

function Invoke-ManagerUninstallerExecutable {
    $uninstallerCandidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity-manager\Uninstall Antigravity Manager.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity Manager\Uninstall Antigravity Manager.exe")
    )

    foreach ($uninstaller in $uninstallerCandidates) {
        $hasUninstaller = Test-Path -LiteralPath $uninstaller

        if ($hasUninstaller) {
            Write-Host "Running Anti-Gravity Manager uninstaller: $uninstaller..." -ForegroundColor Cyan
            try {
                Start-Process -FilePath $uninstaller -ArgumentList "/S" -Wait -NoNewWindow
            } catch {
                Write-Host "  [ NOTE ] AGM uninstaller message: $($_.Exception.Message)" -ForegroundColor DarkGray
            }
            break
        }
    }
}

function Remove-ManagerShortcuts {
    $desktopDir = [Environment]::GetFolderPath("Desktop")
    $hasDesktop = -not [string]::IsNullOrWhiteSpace($desktopDir)

    if ($hasDesktop) {
        Remove-ShortcutFile -ShortcutPath (Join-Path $desktopDir "Antigravity Manager.lnk")
    }

    $programsDir = [Environment]::GetFolderPath("Programs")
    $hasPrograms = -not [string]::IsNullOrWhiteSpace($programsDir)

    if ($hasPrograms) {
        Remove-ShortcutFile -ShortcutPath (Join-Path $programsDir "Antigravity Manager.lnk")
    }
}

function Purge-ManagerConfigurations {
    $dirs = @(
        (Join-Path $env:APPDATA "antigravity-manager"),
        (Join-Path $env:LOCALAPPDATA "antigravity-manager")
    )

    foreach ($dir in $dirs) {
        Remove-SafeDirectory -DirPath $dir
    }
}

function Remove-ManagerRegistryEntries {
    $uninstallRoot = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
    $hasUninstall = Test-Path -LiteralPath $uninstallRoot

    if (-not $hasUninstall) {
        return
    }

    Get-ChildItem -Path $uninstallRoot -ErrorAction SilentlyContinue | Where-Object {
        $_.PSChildName -like "*Antigravity Manager*" -or $_.GetValue("DisplayName") -like "*Antigravity Manager*"
    } | ForEach-Object {
        Remove-SafeRegistryKey -RegPath $_.PSPath
    }
}

function Uninstall-AntigravityManager {
    [CmdletBinding(DefaultParameterSetName = "Standard")]
    param(
        [Parameter(ParameterSetName = "Deep")]
        [Alias("Deep")]
        [switch]$All
    )

    $isDeep = $All.IsPresent

    if ($isDeep) {
        Write-Host "Executing deep uninstallation of Anti-Gravity Manager..." -ForegroundColor Yellow
    } else {
        Write-Host "Uninstalling Anti-Gravity Manager..." -ForegroundColor Cyan
    }

    Stop-AntigravityManagerProcs
    Invoke-ManagerUninstallerExecutable

    $installDir = Join-Path $env:LOCALAPPDATA "Programs\antigravity-manager"
    Remove-SafeDirectory -DirPath $installDir
    Remove-ManagerShortcuts

    if ($isDeep) {
        Purge-ManagerConfigurations
        Remove-ManagerRegistryEntries
    }

    if ($isDeep) {
        Write-Host "[  OK  ] Anti-Gravity Manager completely removed." -ForegroundColor Green
    } else {
        Write-Host "[  OK  ] Anti-Gravity Manager uninstalled." -ForegroundColor Green
    }
}

$action = $Command.ToLowerInvariant()
$isUninstallAll = $action -in @("uninstall-all", "remove-all", "agm-all")

if ($isUninstallAll) {
    Uninstall-AntigravityManager -All
    exit 0
}

$isUninstall = $action -in @("uninstall", "remove")

if ($isUninstall) {
    $isAllFlag = $false

    foreach ($arg in $Rest) {
        $low = "$arg".Trim().ToLowerInvariant()
        $hasAll = $low -in @("all", "--all", "-all", "agm-all")

        if ($hasAll) {
            $isAllFlag = $true
            break
        }
    }

    if ($isAllFlag) {
        Uninstall-AntigravityManager -All
        exit 0
    }

    Uninstall-AntigravityManager
    exit 0
}

Install-AntigravityManager
