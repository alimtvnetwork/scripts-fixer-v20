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

function Get-WhatsAppPath {
    $candidates = @(
        "$env:LOCALAPPDATA\WhatsApp\WhatsApp.exe",
        "$env:LOCALAPPDATA\Programs\WhatsApp\WhatsApp.exe",
        "$env:ProgramFiles\WhatsApp\WhatsApp.exe",
        "${env:ProgramFiles(x86)}\WhatsApp\WhatsApp.exe"
    )
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) {
            return $p
        }
    }

    return $null
}

function Get-ChromiumBrowserPath {
    $candidates = @(
        "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
        "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
        "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe",
        "$env:LOCALAPPDATA\Microsoft\Edge\Application\msedge.exe"
    )
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) {
            return $p
        }
    }

    $cmd = Get-Command chrome.exe, msedge.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) {
        return $cmd.Source
    }

    return $null
}

function New-WhatsAppLauncherBinary {
    param(
        [Parameter(Mandatory)] [string]$TargetPath,
        [Parameter(Mandatory)] [string]$BrowserPath,
        [Parameter(Mandatory)] [string]$ProfileDir
    )

    $escapedBrowser = $BrowserPath.Replace("\", "\\")
    $escapedProfile = $ProfileDir.Replace("\", "\\")

    $csharpCode = @"
using System;
using System.Diagnostics;
namespace WhatsAppLauncher {
    static class Program {
        [STAThread]
        static void Main(string[] args) {
            string browser = @"$escapedBrowser";
            string profile = @"$escapedProfile";
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
    try {
        Add-Type -TypeDefinition $csharpCode -OutputAssembly $TargetPath -OutputType WindowsApplication -ErrorAction Stop
        return (Test-Path -LiteralPath $TargetPath)
    } catch {
        Write-FileError -FilePath $TargetPath -Operation "compile" -Reason "Add-Type failed: $($_.Exception.Message)" -Module "Install-WhatsApp"
        return $false
    }
}

function Register-WhatsAppProtocol {
    param([Parameter(Mandatory)] [string]$LauncherPath)

    try {
        $regBase = "HKCU:\Software\Classes\whatsapp"
        if (-not (Test-Path $regBase)) {
            New-Item -Path $regBase -Force | Out-Null
        }
        Set-ItemProperty -Path $regBase -Name "(Default)" -Value "URL:WhatsApp Protocol" -Force
        Set-ItemProperty -Path $regBase -Name "URL Protocol" -Value "" -Force

        $cmdKey = "$regBase\shell\open\command"
        if (-not (Test-Path $cmdKey)) {
            New-Item -Path $cmdKey -Force | Out-Null
        }
        Set-ItemProperty -Path $cmdKey -Name "(Default)" -Value "`"$LauncherPath`" `"%1`"" -Force
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
        if (-not (Test-Path $dir)) {
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

function Install-WhatsAppServerEngine {
    param(
        [Parameter(Mandatory)] $WaConfig,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages
    Write-Log $msgs.serverEngineDetected -Level "info"

    $browserPath = Get-ChromiumBrowserPath
    if (-not $browserPath) {
        Write-Log $msgs.browserNotFound -Level "error"
        return $false
    }

    Write-Log ($msgs.browserFound -replace '\{path\}', $browserPath) -Level "info"

    $waDir = Join-Path $env:LOCALAPPDATA "WhatsApp"
    if (-not (Test-Path $waDir)) {
        New-Item -ItemType Directory -Path $waDir -Force | Out-Null
    }

    $profileDir = Join-Path $waDir "User Data"
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    $launcherExe = Join-Path $waDir "WhatsApp.exe"
    $hasBinary = New-WhatsAppLauncherBinary -TargetPath $launcherExe -BrowserPath $browserPath -ProfileDir $profileDir
    if (-not $hasBinary) {
        return $false
    }

    Write-Log ($msgs.launcherCreated -replace '\{path\}', $launcherExe) -Level "success"

    $startMenuLnk = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs\WhatsApp.lnk"
    New-WhatsAppShortcut -ShortcutPath $startMenuLnk -TargetPath $launcherExe -IconPath $browserPath | Out-Null

    $desktopDir = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
    $desktopLnk = Join-Path $desktopDir "WhatsApp.lnk"
    New-WhatsAppShortcut -ShortcutPath $desktopLnk -TargetPath $launcherExe -IconPath $browserPath | Out-Null

    Register-WhatsAppProtocol -LauncherPath $launcherExe | Out-Null
    Write-Log $msgs.shortcutsCreated -Level "success"

    Save-InstalledRecord -Name "whatsapp" -Version "1.0.0-server" -Method "server-desktop-launcher"
    return $true
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
        return @{ ok = $false; path = $null; reason = "fallback disabled" }
    }

    $url = [string]$Fallback.url
    $dest = Join-Path ($env:TEMP) "WhatsAppSetup.exe"

    Write-Log ($msgs.fallbackTriggered -replace '\{reason\}', $TriggerReason) -Level "warn"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing -TimeoutSec 30 -ErrorAction Stop
    } catch {
        Write-Log (($msgs.fallbackDownloadFailed -replace '\{url\}', $url) -replace '\{error\}', $_.Exception.Message) -Level "error"
        return @{ ok = $false; path = $null; reason = "download failed" }
    }

    $fileBytes = (Get-Item -LiteralPath $dest -ErrorAction SilentlyContinue).Length
    if ($fileBytes -lt 1MB) {
        return @{ ok = $false; path = $null; reason = "installer too small ($fileBytes bytes)" }
    }

    try {
        $proc = Start-Process -FilePath $dest -ArgumentList "/S" -PassThru -WindowStyle Hidden -ErrorAction Stop
        $hasExited = $proc.WaitForExit(30000)
        if (-not $hasExited) {
            $proc.Kill()
            return @{ ok = $false; path = $null; reason = "installer timeout" }
        }
    } catch {
        return @{ ok = $false; path = $null; reason = "start-process failed" }
    }

    $installedPath = Get-WhatsAppPath
    if (-not $installedPath) {
        return @{ ok = $false; path = $null; reason = "post-install verify failed" }
    }

    return @{ ok = $true; path = $installedPath; reason = "ok" }
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

    $isInstalled = Install-ChocoPackage -PackageName $WaConfig.chocoPackage
    if ($isInstalled) {
        $installedPath = Get-WhatsAppPath
        if ($installedPath) {
            Write-Log ($msgs.installSuccess -replace '\{path\}', $installedPath) -Level "success"
            Save-InstalledRecord -Name "whatsapp" -Version "choco" -Method "chocolatey"
            return $true
        }
    }

    $hasFallback = $null -ne $WaConfig.fallback
    if ($hasFallback) {
        $result = Invoke-WhatsAppOfficialInstaller -Fallback $WaConfig.fallback -LogMessages $LogMessages -TriggerReason "standard install unverified"
        if ($result.ok) {
            Save-InstalledRecord -Name "whatsapp" -Version "official" -Method "official-installer"
            return $true
        }
    }

    Write-Log "Standard methods exhausted -- falling back to native desktop launcher engine" -Level "info"
    return (Install-WhatsAppServerEngine -WaConfig $WaConfig -LogMessages $LogMessages)
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

function Remove-WaRegistryKeys {
    param(
        [Parameter(Mandatory)] [string[]]$Keys,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages
    $counter = @{ removed = 0; missing = 0; failed = 0 }

    foreach ($key in $Keys) {
        if ([string]::IsNullOrWhiteSpace($key)) { continue }
        $hasKey = Test-Path -LiteralPath $key -ErrorAction SilentlyContinue
        if (-not $hasKey) {
            $counter.missing++
            continue
        }
        try {
            Remove-Item -LiteralPath $key -Recurse -Force -ErrorAction Stop
            Write-Log ($msgs.cleanupRegKeyRemoved -replace '\{path\}', $key) -Level "success"
            $counter.removed++
        } catch {
            Write-FileError -FilePath $key -Operation "registry delete" -Reason "Remove-Item failed: $($_.Exception.Message)" -Module "Uninstall-WhatsApp"
            $counter.failed++
        }
    }

    return $counter
}

function Remove-WaShortcuts {
    param(
        [Parameter(Mandatory)] [string[]]$Paths,
        [Parameter(Mandatory)] $LogMessages
    )

    $msgs = $LogMessages.messages
    $counter = @{ removed = 0; missing = 0; failed = 0 }

    foreach ($raw in $Paths) {
        $p = Expand-WaPath -Raw $raw
        if ([string]::IsNullOrWhiteSpace($p)) { continue }
        $hasPath = Test-Path -LiteralPath $p -ErrorAction SilentlyContinue
        if (-not $hasPath) {
            $counter.missing++
            continue
        }
        try {
            Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction Stop
            Write-Log ($msgs.cleanupShortcutRemoved -replace '\{path\}', $p) -Level "success"
            $counter.removed++
        } catch {
            Write-FileError -FilePath $p -Operation "shortcut delete" -Reason "Remove-Item failed: $($_.Exception.Message)" -Module "Uninstall-WhatsApp"
            $counter.failed++
        }
    }

    return $counter
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

    $hasAppDataList = $null -ne $cleanup.PSObject.Properties['appDataPaths'] -and $cleanup.appDataPaths
    if ($hasAppDataList -and $cleanup.purgeAppData) {
        foreach ($raw in $cleanup.appDataPaths) {
            $p = Expand-WaPath -Raw $raw
            if (Test-Path -LiteralPath $p) {
                Remove-Item -LiteralPath $p -Recurse -Force -ErrorAction SilentlyContinue
                Write-Log ($msgs.cleanupAppDataPurged -replace '\{path\}', $p) -Level "success"
            }
        }
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

    # Remove native launcher executable if present
    $launcher = Join-Path $env:LOCALAPPDATA "WhatsApp\WhatsApp.exe"
    if (Test-Path -LiteralPath $launcher) {
        Remove-Item -LiteralPath $launcher -Force -ErrorAction SilentlyContinue
    }

    Invoke-WaPostUninstallCleanup -WaConfig $WaConfig -LogMessages $LogMessages

    Remove-InstalledRecord -Name "whatsapp"
    Remove-ResolvedData -ScriptFolder "49-install-whatsapp"

    Write-Log $LogMessages.messages.uninstallComplete -Level "success"
}
