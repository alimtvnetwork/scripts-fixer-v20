# --------------------------------------------------------------------------
#  Helper: Install WhatsApp Desktop across Windows Server and Windows 10/11
# --------------------------------------------------------------------------

$_sharedDir = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "shared"
$_loggingPath = Join-Path $_sharedDir "logging.ps1"

if ((Test-Path $_loggingPath) -and -not (Get-Command Write-Log -ErrorAction SilentlyContinue)) {
    . $_loggingPath
}

$_chocoUtilsPath = Join-Path $_sharedDir "choco-utils.ps1"

if ((Test-Path $_chocoUtilsPath) -and -not (Get-Command Install-ChocoPackage -ErrorAction SilentlyContinue)) {
    . $_chocoUtilsPath
}

$_osDetectPath = Join-Path $_sharedDir "os-detect.ps1"

if ((Test-Path $_osDetectPath) -and -not (Get-Command Test-IsWindowsServer -ErrorAction SilentlyContinue)) {
    . $_osDetectPath
}

function Get-WhatsAppPathList {
    return @(
        "$env:LOCALAPPDATA\WhatsApp\WhatsApp.exe",
        "$env:LOCALAPPDATA\Programs\WhatsApp\WhatsApp.exe",
        "$env:LOCALAPPDATA\Microsoft\WindowsApps\WhatsApp.exe",
        "$env:ProgramFiles\WhatsApp\WhatsApp.exe",
        "${env:ProgramFiles(x86)}\WhatsApp\WhatsApp.exe"
    )
}

function Get-WhatsAppPath {
    $pathList = Get-WhatsAppPathList

    foreach ($p in $pathList) {

        if (Test-Path -LiteralPath $p) {
            return $p
        }
    }

    $cmd = Get-Command "WhatsApp.exe" -ErrorAction SilentlyContinue

    if ($null -ne $cmd) {
        return $cmd.Source
    }

    return $null
}

function Get-ChromiumBrowserPathList {
    return @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
        "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
    )
}

function Get-ChromiumBrowserPath {
    $pathList = Get-ChromiumBrowserPathList

    foreach ($p in $pathList) {

        if (Test-Path -LiteralPath $p) {
            return $p
        }
    }

    $cmd = Get-Command chrome.exe, msedge.exe -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($null -ne $cmd) {
        return $cmd.Source
    }

    return $null
}

function Get-WhatsAppLauncherSource {
    param(
        [Parameter(Mandatory)] [string]$BrowserPath,
        [Parameter(Mandatory)] [string]$ProfileDir
    )

    return @"
using System;
using System.Diagnostics;
namespace WhatsAppLauncher {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            string browser = @"$BrowserPath";
            string profile = @"$ProfileDir";
            string url = "https://web.whatsapp.com/";
            string launchArgs = string.Format("--app={0} --user-data-dir=\"{1}\" --class=WhatsApp --name=WhatsApp", url, profile);

            if (args != null && args.Length > 0 && !string.IsNullOrWhiteSpace(args[0])) {
                string a = args[0].Trim();

                if (a.StartsWith("whatsapp://", StringComparison.OrdinalIgnoreCase)) {
                    launchArgs += " \"" + a + "\"";
                }
            }

            ProcessStartInfo psi = new ProcessStartInfo();
            psi.FileName = browser;
            psi.Arguments = launchArgs;
            psi.UseShellExecute = false;
            Process.Start(psi);
        }
    }
}
"@
}

function New-WhatsAppLauncherBinary {
    param(
        [Parameter(Mandatory)] [string]$TargetPath,
        [Parameter(Mandatory)] [string]$BrowserPath,
        [Parameter(Mandatory)] [string]$ProfileDir
    )

    $escapedBrowser = $BrowserPath.Replace("\", "\\")
    $escapedProfile = $ProfileDir.Replace("\", "\\")
    $code = Get-WhatsAppLauncherSource -BrowserPath $escapedBrowser -ProfileDir $escapedProfile

    try {
        Add-Type -TypeDefinition $code -OutputAssembly $TargetPath -OutputType WindowsApplication -ErrorAction Stop

        return (Test-Path -LiteralPath $TargetPath)
    } catch {
        Write-FileError -FilePath $TargetPath -Operation "compile" -Reason "Add-Type failed: $($_.Exception.Message)" -Module "Install-WhatsApp"

        return $false
    }
}

function Set-WaRegistryKeyDefault {
    param(
        [Parameter(Mandatory)] [string]$KeyPath,
        [Parameter(Mandatory)] [string]$Value
    )

    $hasKey = Test-Path -LiteralPath $KeyPath

    if (-not $hasKey) {
        New-Item -Path $KeyPath -Force | Out-Null
    }

    Set-ItemProperty -Path $KeyPath -Name "(Default)" -Value $Value -Force
}

function Register-WhatsAppProtocol {
    param([Parameter(Mandatory)] [string]$LauncherPath)

    try {
        $regBase = "HKCU:\Software\Classes\whatsapp"
        Set-WaRegistryKeyDefault -KeyPath $regBase -Value "URL:WhatsApp Protocol"
        Set-ItemProperty -Path $regBase -Name "URL Protocol" -Value "" -Force

        $cmdKey = "$regBase\shell\open\command"
        Set-WaRegistryKeyDefault -KeyPath $cmdKey -Value "`"$LauncherPath`" `"%1`""

        return $true
    } catch {
        return $false
    }
}

function New-WhatsAppShortcut {
    param(
        [Parameter(Mandatory)] [string]$ShortcutPath,
        [Parameter(Mandatory)] [string]$TargetPath,
        [Parameter(Mandatory)] [string]$IconPath
    )

    try {
        $dir = Split-Path -Parent $ShortcutPath
        $hasDir = Test-Path -LiteralPath $dir

        if (-not $hasDir) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        $wsh = New-Object -ComObject WScript.Shell
        $sc = $wsh.CreateShortcut($ShortcutPath)
        $sc.TargetPath = $TargetPath
        $sc.IconLocation = "$IconPath,0"
        $sc.Description = "WhatsApp Desktop Client"
        $sc.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null

        return (Test-Path -LiteralPath $ShortcutPath)
    } catch {
        return $false
    }
}

function New-WhatsAppStartMenuShortcut {
    param(
        [Parameter(Mandatory)] [string]$LauncherExe,
        [Parameter(Mandatory)] [string]$BrowserPath
    )

    $startMenuLnk = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\WhatsApp.lnk"

    return (New-WhatsAppShortcut -ShortcutPath $startMenuLnk -TargetPath $LauncherExe -IconPath $BrowserPath)
}

function New-WhatsAppDesktopShortcut {
    param(
        [Parameter(Mandatory)] [string]$LauncherExe,
        [Parameter(Mandatory)] [string]$BrowserPath
    )

    $desktopDir = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
    $hasDesktop = -not [string]::IsNullOrWhiteSpace($desktopDir)

    if (-not $hasDesktop) {
        return $false
    }

    $hasDir = Test-Path -LiteralPath $desktopDir

    if (-not $hasDir) {
        New-Item -ItemType Directory -Path $desktopDir -Force | Out-Null
    }

    $desktopLnk = Join-Path $desktopDir "WhatsApp.lnk"

    return (New-WhatsAppShortcut -ShortcutPath $desktopLnk -TargetPath $LauncherExe -IconPath $BrowserPath)
}

function New-ProcessStartInfo {
    param(
        [Parameter(Mandatory)] [string]$FilePath,
        [Parameter(Mandatory)] [string[]]$ArgumentList
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.Arguments = $ArgumentList -join " "
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true

    return $psi
}

function Invoke-ProcessWithTimeout {
    param(
        [Parameter(Mandatory)] [string]$FilePath,
        [Parameter(Mandatory)] [string[]]$ArgumentList,
        [Parameter(Mandatory)] [int]$TimeoutSeconds
    )

    try {
        $proc = New-Object System.Diagnostics.Process
        $proc.StartInfo = New-ProcessStartInfo -FilePath $FilePath -ArgumentList $ArgumentList
        [void]$proc.Start()
        $hasExited = $proc.WaitForExit($TimeoutSeconds * 1000)

        if (-not $hasExited) {
            $proc.Kill()

            return @{ isSuccess = $false; isTimeout = $true; exitCode = -1 }
        }

        $isZero = $proc.ExitCode -eq 0

        return @{ isSuccess = $isZero; isTimeout = $false; exitCode = $proc.ExitCode }
    } catch {
        return @{ isSuccess = $false; isTimeout = $false; exitCode = -1 }
    }
}

function Initialize-WhatsAppDirectories {
    param([Parameter(Mandatory)] [string]$WaDir)

    $hasWaDir = Test-Path -LiteralPath $WaDir

    if (-not $hasWaDir) {
        New-Item -ItemType Directory -Path $WaDir -Force | Out-Null
    }

    $profileDir = Join-Path $WaDir "User Data"
    $hasProfileDir = Test-Path -LiteralPath $profileDir

    if (-not $hasProfileDir) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    return $profileDir
}

function Register-WhatsAppShellIntegration {
    param(
        [Parameter(Mandatory)] [string]$LauncherExe,
        [Parameter(Mandatory)] [string]$BrowserPath
    )

    New-WhatsAppStartMenuShortcut -LauncherExe $LauncherExe -BrowserPath $BrowserPath | Out-Null
    New-WhatsAppDesktopShortcut -LauncherExe $LauncherExe -BrowserPath $BrowserPath | Out-Null
    Register-WhatsAppProtocol -LauncherPath $LauncherExe | Out-Null
}

function Install-WhatsAppServerEngine {
    param(
        [Parameter(Mandatory)] $WaConfig,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages
    Write-Log $msgs.serverEngineDetected -Level "info"

    $browserPath = Get-ChromiumBrowserPath
    $hasBrowser = -not [string]::IsNullOrWhiteSpace($browserPath)

    if (-not $hasBrowser) {
        Write-Log $msgs.browserNotFound -Level "error"

        return $false
    }

    Write-Log ($msgs.browserFound -replace '\{path\}', $browserPath) -Level "info"

    $waDir = Join-Path $env:LOCALAPPDATA "WhatsApp"
    $profileDir = Initialize-WhatsAppDirectories -WaDir $waDir

    $launcherExe = Join-Path $waDir "WhatsApp.exe"
    $hasBinary = New-WhatsAppLauncherBinary -TargetPath $launcherExe -BrowserPath $browserPath -ProfileDir $profileDir

    if (-not $hasBinary) {
        return $false
    }

    Write-Log ($msgs.launcherCreated -replace '\{path\}', $launcherExe) -Level "success"
    Register-WhatsAppShellIntegration -LauncherExe $launcherExe -BrowserPath $browserPath

    Write-Log $msgs.shortcutsCreated -Level "success"
    Save-InstalledRecord -Name "whatsapp" -Version "1.0.0-server" -Method "server-desktop-launcher"

    return $true
}

function Download-WhatsAppOfficialInstaller {
    param(
        [Parameter(Mandatory)] [string]$Url,
        [Parameter(Mandatory)] [string]$DestPath
    )

    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $Url -OutFile $DestPath -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop

        return @{ isSuccess = $true; error = "" }
    } catch {
        return @{ isSuccess = $false; error = $_.Exception.Message }
    }
}

function Test-WhatsAppInstallerSize {
    param([Parameter(Mandatory)] [string]$DestPath)

    $item = Get-Item -LiteralPath $DestPath -ErrorAction SilentlyContinue
    $hasItem = $null -ne $item

    if (-not $hasItem) {
        return $false
    }

    $hasValidSize = $item.Length -ge 1MB

    return $hasValidSize
}

function Invoke-WhatsAppOfficialInstaller {
    param(
        [Parameter(Mandatory)] $Fallback,
        [Parameter(Mandatory)] $LogMessages,
        [Parameter(Mandatory)] [string]$TriggerReason
    )

    $msgs = $LogMessages.messages
    $isFallbackDisabled = -not $Fallback.enabled

    if ($isFallbackDisabled) {
        Write-Log $msgs.fallbackDisabled -Level "error"

        return @{ isSuccess = $false; ok = $false; path = $null; reason = "fallback disabled" }
    }

    $dest = Join-Path ($env:TEMP) "WhatsAppSetup.exe"
    Write-Log ($msgs.fallbackTriggered -replace '\{reason\}', $TriggerReason) -Level "warn"

    $dlRes = Download-WhatsAppOfficialInstaller -Url ([string]$Fallback.url) -DestPath $dest

    if (-not $dlRes.isSuccess) {
        Write-Log (($msgs.fallbackDownloadFailed -replace '\{url\}', $Fallback.url) -replace '\{error\}', $dlRes.error) -Level "error"

        return @{ isSuccess = $false; ok = $false; path = $null; reason = "download failed" }
    }

    $hasValidSize = Test-WhatsAppInstallerSize -DestPath $dest

    if (-not $hasValidSize) {
        return @{ isSuccess = $false; ok = $false; path = $null; reason = "installer too small" }
    }

    $timeout = if ($Fallback.timeoutSeconds) { [int]$Fallback.timeoutSeconds } else { 30 }
    $execRes = Invoke-ProcessWithTimeout -FilePath $dest -ArgumentList @("/S") -TimeoutSeconds $timeout

    if (-not $execRes.isSuccess) {
        return @{ isSuccess = $false; ok = $false; path = $null; reason = "installer failed or timed out" }
    }

    $installedPath = Get-WhatsAppPath

    if (-not $installedPath) {
        return @{ isSuccess = $false; ok = $false; path = $null; reason = "post-install verify failed" }
    }

    return @{ isSuccess = $true; ok = $true; path = $installedPath; reason = "ok" }
}

function Test-HasWinget {
    $wingetCmd = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    $hasWinget = $null -ne $wingetCmd

    return $hasWinget
}

function Invoke-WhatsAppWingetCommand {
    param([int]$TimeoutSeconds = 60)

    $args = @(
        "install",
        "--id", "9NKSQGP7F2NH",
        "--source", "msstore",
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements",
        "--disable-interactivity"
    )

    return (Invoke-ProcessWithTimeout -FilePath "winget.exe" -ArgumentList $args -TimeoutSeconds $TimeoutSeconds)
}

function Install-WhatsAppWinget {
    param(
        [Parameter(Mandatory)] $WaConfig,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages
    $hasWinget = Test-HasWinget

    if (-not $hasWinget) {
        Write-Log $msgs.wingetNotFound -Level "info"

        return $false
    }

    Write-Log $msgs.wingetInstalling -Level "info"
    $timeoutSec = if ($WaConfig.wingetTimeoutSeconds) { [int]$WaConfig.wingetTimeoutSeconds } else { 60 }
    $res = Invoke-WhatsAppWingetCommand -TimeoutSeconds $timeoutSec

    if ($res.isTimeout) {
        Write-Log ($msgs.wingetTimeout -replace '\{seconds\}', "$timeoutSec") -Level "warn"

        return $false
    }

    $installedPath = Get-WhatsAppPath

    if (-not $installedPath) {
        Write-Log $msgs.wingetVerifyFailed -Level "warn"

        return $false
    }

    Write-Log ($msgs.installSuccess -replace '\{path\}', $installedPath) -Level "success"
    Save-InstalledRecord -Name "whatsapp" -Version "msstore" -Method "winget"

    return $true
}

function Install-WhatsAppChoco {
    param(
        [Parameter(Mandatory)] $WaConfig,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages
    Write-Log $msgs.installing -Level "info"
    $isInstalled = Install-ChocoPackage -PackageName $WaConfig.chocoPackage

    if (-not $isInstalled) {
        return $false
    }

    $installedPath = Get-WhatsAppPath

    if (-not $installedPath) {
        return $false
    }

    Write-Log ($msgs.installSuccess -replace '\{path\}', $installedPath) -Level "success"
    Save-InstalledRecord -Name "whatsapp" -Version "choco" -Method "chocolatey"

    return $true
}

function Install-WhatsAppOfficial {
    param(
        [Parameter(Mandatory)] $WaConfig,
        [Parameter(Mandatory)] $LogMessages
    )

    $hasFallback = $null -ne $WaConfig.fallback

    if (-not $hasFallback) {
        return $false
    }

    $res = Invoke-WhatsAppOfficialInstaller -Fallback $WaConfig.fallback -LogMessages $LogMessages -TriggerReason "standard install unverified"

    if (-not $res.isSuccess) {
        return $false
    }

    Save-InstalledRecord -Name "whatsapp" -Version "official" -Method "official-installer"

    return $true
}

function Install-WhatsAppStandard {
    param(
        [Parameter(Mandatory)] $WaConfig,
        [Parameter(Mandatory)] $LogMessages
    )

    $isWingetSuccess = Install-WhatsAppWinget -WaConfig $WaConfig -LogMessages $LogMessages

    if ($isWingetSuccess) {
        return $true
    }

    $isChocoSuccess = Install-WhatsAppChoco -WaConfig $WaConfig -LogMessages $LogMessages

    if ($isChocoSuccess) {
        return $true
    }

    $isOfficialSuccess = Install-WhatsAppOfficial -WaConfig $WaConfig -LogMessages $LogMessages

    if ($isOfficialSuccess) {
        return $true
    }

    Write-Log "Standard methods exhausted -- falling back to native desktop launcher engine" -Level "info"

    return (Install-WhatsAppServerEngine -WaConfig $WaConfig -LogMessages $LogMessages)
}

function Install-WhatsApp {
    param(
        [Parameter(Mandatory)] $WaConfig,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages
    $isDisabled = -not $WaConfig.enabled

    if ($isDisabled) {
        Write-Log "WhatsApp install disabled in config -- skipping" -Level "info"

        return $true
    }

    Write-Log $msgs.checking -Level "info"
    $existing = Get-WhatsAppPath

    if ($existing) {
        Write-Log ($msgs.alreadyInstalled -replace '\{path\}', $existing) -Level "success"
        Save-InstalledRecord -Name "whatsapp" -Version "existing" -Method "detected"

        return $true
    }

    Write-Log $msgs.notFound -Level "info"
    $isServer = Test-IsWindowsServer

    if ($isServer) {
        return (Install-WhatsAppServerEngine -WaConfig $WaConfig -LogMessages $LogMessages)
    }

    return (Install-WhatsAppStandard -WaConfig $WaConfig -LogMessages $LogMessages)
}

function Expand-WaPath {
    param([string]$Raw)

    if ([string]::IsNullOrWhiteSpace($Raw)) {
        return $null
    }

    try {
        return [Environment]::ExpandEnvironmentVariables($Raw)
    } catch {
        return $Raw
    }
}

function Remove-WaSingleRegistryKey {
    param(
        [Parameter(Mandatory)] [string]$Key,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages

    try {
        Remove-Item -LiteralPath $Key -Recurse -Force -ErrorAction Stop
        Write-Log ($msgs.cleanupRegKeyRemoved -replace '\{path\}', $Key) -Level "success"

        return @{ isSuccess = $true; error = "" }
    } catch {
        Write-FileError -FilePath $Key -Operation "registry delete" -Reason "Remove-Item failed: $($_.Exception.Message)" -Module "Uninstall-WhatsApp"

        return @{ isSuccess = $false; error = $_.Exception.Message }
    }
}

function Remove-WaRegistryKeys {
    param(
        [Parameter(Mandatory)] [string[]]$Keys,
        [Parameter(Mandatory)] $LogMessages
    )

    $counter = @{ removed = 0; missing = 0; failed = 0 }

    foreach ($key in $Keys) {

        if ([string]::IsNullOrWhiteSpace($key)) {
            continue
        }

        $hasKey = Test-Path -LiteralPath $key -ErrorAction SilentlyContinue

        if (-not $hasKey) {
            $counter.missing++

            continue
        }

        $res = Remove-WaSingleRegistryKey -Key $key -LogMessages $LogMessages

        if ($res.isSuccess) {
            $counter.removed++
        } else {
            $counter.failed++
        }
    }

    return $counter
}

function Remove-WaSingleShortcut {
    param(
        [Parameter(Mandatory)] [string]$Path,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages

    try {
        Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop
        Write-Log ($msgs.cleanupShortcutRemoved -replace '\{path\}', $Path) -Level "success"

        return @{ isSuccess = $true; error = "" }
    } catch {
        Write-FileError -FilePath $Path -Operation "shortcut delete" -Reason "Remove-Item failed: $($_.Exception.Message)" -Module "Uninstall-WhatsApp"

        return @{ isSuccess = $false; error = $_.Exception.Message }
    }
}

function Remove-WaShortcuts {
    param(
        [Parameter(Mandatory)] [string[]]$Paths,
        [Parameter(Mandatory)] $LogMessages
    )

    $counter = @{ removed = 0; missing = 0; failed = 0 }

    foreach ($raw in $Paths) {
        $p = Expand-WaPath -Raw $raw

        if ([string]::IsNullOrWhiteSpace($p)) {
            continue
        }

        $hasPath = Test-Path -LiteralPath $p -ErrorAction SilentlyContinue

        if (-not $hasPath) {
            $counter.missing++

            continue
        }

        $res = Remove-WaSingleShortcut -Path $p -LogMessages $LogMessages

        if ($res.isSuccess) {
            $counter.removed++
        } else {
            $counter.failed++
        }
    }

    return $counter
}

function Purge-WaAppData {
    param(
        [Parameter(Mandatory)] [string[]]$Paths,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages

    foreach ($raw in $Paths) {
        $p = Expand-WaPath -Raw $raw
        $hasPath = Test-Path -LiteralPath $p

        if ($hasPath) {
            Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue
            Write-Log ($msgs.cleanupAppDataPurged -replace '\{path\}', $p) -Level "success"
        }
    }
}

function Invoke-WaPostUninstallCleanup {
    param(
        [Parameter(Mandatory)] $WaConfig,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages
    $hasCleanupConfig = $null -ne $WaConfig.PSObject.Properties['uninstallCleanup']

    if (-not $hasCleanupConfig) {
        return
    }

    $cleanup = $WaConfig.uninstallCleanup
    $isCleanupDisabled = -not $cleanup.enabled

    if ($isCleanupDisabled) {
        return
    }

    Write-Log $msgs.cleanupStart -Level "info"

    $regCounter = @{ removed = 0; missing = 0; failed = 0 }

    if ($cleanup.removeRegistryKeys) {
        $regCounter = Remove-WaRegistryKeys -Keys $cleanup.registryKeys -LogMessages $LogMessages
    }

    $scCounter = @{ removed = 0; missing = 0; failed = 0 }

    if ($cleanup.removeShortcuts) {
        $scCounter = Remove-WaShortcuts -Paths $cleanup.shortcutPaths -LogMessages $LogMessages
    }

    $hasAppData = ($cleanup.purgeAppData -eq $true) -and ($null -ne $cleanup.appDataPaths)

    if ($hasAppData) {
        Purge-WaAppData -Paths $cleanup.appDataPaths -LogMessages $LogMessages
    }

    $summary = $msgs.cleanupSummary
    $summary = $summary -replace '\{regRemoved\}', $regCounter.removed
    $summary = $summary -replace '\{regMissing\}', $regCounter.missing
    $summary = $summary -replace '\{regFailed\}', $regCounter.failed
    $summary = $summary -replace '\{scRemoved\}', $scCounter.removed
    $summary = $summary -replace '\{scMissing\}', $scCounter.missing
    $summary = $summary -replace '\{scFailed\}', $scCounter.failed
    $hasAnyFailure = ($regCounter.failed + $scCounter.failed) -gt 0
    Write-Log $summary -Level $(if ($hasAnyFailure) { "warn" } else { "success" })
}

function Uninstall-WhatsApp {
    param($WaConfig, $LogMessages)

    Write-Log ($LogMessages.messages.uninstalling -replace '\{name\}', "WhatsApp") -Level "info"
    $isUninstalled = Uninstall-ChocoPackage -PackageName $WaConfig.chocoPackage

    $launcher = Join-Path $env:LOCALAPPDATA "WhatsApp\WhatsApp.exe"
    $hasLauncher = Test-Path -LiteralPath $launcher

    if ($hasLauncher) {
        Remove-Item -LiteralPath $launcher -Force -ErrorAction SilentlyContinue
    }

    Invoke-WaPostUninstallCleanup -WaConfig $WaConfig -LogMessages $LogMessages

    Remove-InstalledRecord -Name "whatsapp"
    Remove-ResolvedData -ScriptFolder "49-install-whatsapp"

    Write-Log $LogMessages.messages.uninstallComplete -Level "success"
}
