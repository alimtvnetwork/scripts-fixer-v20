param([string]$Command = "all")
$ErrorActionPreference = "Stop"

# ── Cross-Platform OS Detection & Forwarding ──────────────────────────────────
$isUnix = ($null -ne $IsLinux -and $IsLinux) -or
          ($null -ne $IsMacOS -and $IsMacOS) -or
          ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Unix) -or
          ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::MacOSX)

if ($isUnix) {
    $scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $MyInvocation.MyCommand.Definition }
    $shCandidates = @(
        (Join-Path (Split-Path -Parent $scriptDir) "os/ubuntu/install-antigravity.sh"),
        (Join-Path $scriptDir "../../scripts/os/ubuntu/install-antigravity.sh"),
        (Join-Path (Get-Location) "scripts/os/ubuntu/install-antigravity.sh"),
        "scripts/os/ubuntu/install-antigravity.sh"
    )
    $shTarget = $null
    foreach ($cand in $shCandidates) {
        if ($cand -and (Test-Path $cand)) {
            $shTarget = (Resolve-Path $cand).Path
            break
        }
    }
    if (-not $shTarget) {
        Write-Error "Could not locate scripts/os/ubuntu/install-antigravity.sh for Unix forwarding."
        exit 1
    }
    Write-Host "Unix environment detected. Forwarding to $shTarget..." -ForegroundColor Cyan
    & bash $shTarget
    exit $LASTEXITCODE
}

# ── Environment Broadcast Helper ──────────────────────────────────────────────
function Broadcast-EnvironmentChange {
    try {
        if (-not ([System.Management.Automation.PSTypeName]'AntigravityNativeMethods').Type) {
            $typeDef = @"
using System;
using System.Runtime.InteropServices;
public static class AntigravityNativeMethods {
    public const int HWND_BROADCAST = 0xffff;
    public const int WM_SETTINGCHANGE = 0x1A;
    public const int SMTO_ABORTIFHUNG = 0x2;
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd, int Msg, IntPtr wParam, string lParam,
        int fuFlags, int uTimeout, out IntPtr lpdwResult);
}
"@
            Add-Type -TypeDefinition $typeDef -ErrorAction SilentlyContinue | Out-Null
        }
        $result = [IntPtr]::Zero
        [void][AntigravityNativeMethods]::SendMessageTimeout(
            [IntPtr]0xffff,
            0x1A,
            [IntPtr]::Zero,
            "Environment",
            0x2,
            3000,
            [ref]$result
        )
    } catch {
        # Non-critical if broadcast fails in headless CI or non-GUI environments
    }
}

# ── Shortcut Helper ───────────────────────────────────────────────────────────
function New-AntigravityShortcut {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetPath,
        [Parameter(Mandatory = $true)]
        [string]$ShortcutPath,
        [string]$Description = "Google Antigravity",
        [string]$IconLocation
    )
    try {
        $parent = Split-Path -Parent $ShortcutPath
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($ShortcutPath)
        $shortcut.TargetPath = $TargetPath
        $shortcut.WorkingDirectory = Split-Path -Parent $TargetPath
        $shortcut.Description = $Description
        if ($IconLocation) {
            $shortcut.IconLocation = $IconLocation
        }
        $shortcut.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
    } catch {
        Write-Host "  [ NOTE ] Failed to create shortcut at $ShortcutPath : $($_.Exception.Message)" -ForegroundColor DarkGray
    }
}

# ── Google Antigravity IDE Installer ──────────────────────────────────────────
function Install-AntigravityIDE {
    $ideCandidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\Antigravity.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity\Antigravity.exe"),
        (Join-Path $env:ProgramFiles "Antigravity\Antigravity.exe")
    )
    foreach ($cand in $ideCandidates) {
        if (Test-Path $cand) {
            Write-Host "Antigravity IDE is already installed at $cand." -ForegroundColor Green
            return $cand
        }
    }

    Write-Host "Fetching Antigravity IDE download URL..." -ForegroundColor Cyan
    $isArm = $env:PROCESSOR_ARCHITECTURE -eq "ARM64"
    $primaryUrl = if ($isArm) {
        "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/windows-arm/Antigravity-arm64.exe"
    } else {
        "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.13.0-6362815968182272/windows-x64/Antigravity-x64.exe"
    }

    $tempInstaller = Join-Path $env:TEMP "Antigravity-setup.exe"
    $downloadSuccess = $false

    try {
        Write-Host "Downloading Google Antigravity from storage.googleapis.com..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $primaryUrl -OutFile $tempInstaller -UseBasicParsing -TimeoutSec 120
        $downloadSuccess = (Test-Path $tempInstaller) -and ((Get-Item $tempInstaller).Length -gt 1000000)
    } catch {
        Write-Host "  [ NOTE ] Primary storage download failed: $($_.Exception.Message)" -ForegroundColor DarkGray
    }

    if (-not $downloadSuccess) {
        $ideDownloadUrl = $null
        try {
            $platformKey = if ($isArm) { "win32-arm64-user" } else { "win32-x64-user" }
            $updateApi = "https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/api/update/$platformKey/stable/latest"
            $updateInfo = Invoke-RestMethod -Uri $updateApi -Headers @{ "User-Agent" = "PowerShell" } -TimeoutSec 15
            if ($updateInfo -and $updateInfo.url) {
                $ideDownloadUrl = $updateInfo.url
            }
        } catch { }

        if (-not $ideDownloadUrl) {
            $ideDownloadUrl = "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.5.5-4923483625488384/windows-x64/Antigravity%20IDE.exe"
        }

        Write-Host "Downloading Antigravity from fallback URL ($ideDownloadUrl)..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $ideDownloadUrl -OutFile $tempInstaller -UseBasicParsing -TimeoutSec 120
    }

    Write-Host "Running silent Antigravity installation..." -ForegroundColor Cyan
    # Try NSIS silent install first (/S), then Inno Setup (/VERYSILENT)
    $proc = Start-Process -FilePath $tempInstaller -ArgumentList "/S" -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
    if (-not (Test-Path (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\Antigravity.exe")) -and `
        -not (Test-Path (Join-Path $env:LOCALAPPDATA "Programs\antigravity\Antigravity.exe"))) {
        Start-Process -FilePath $tempInstaller -ArgumentList "/VERYSILENT", "/MERGETASKS=!runcode", "/NORESTART" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    }
    Remove-Item -Path $tempInstaller -Force -ErrorAction SilentlyContinue

    foreach ($cand in $ideCandidates) {
        if (Test-Path $cand) {
            Write-Host "Antigravity installed successfully at $cand." -ForegroundColor Green
            return $cand
        }
    }
    Write-Host "  [ NOTE ] Antigravity installer completed." -ForegroundColor DarkGray
    return $null
}

# ── Antigravity CLI Installer ─────────────────────────────────────────────────
function Install-AntigravityCLI {
    Write-Host "Installing Antigravity CLI..." -ForegroundColor Cyan
    $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
    $assetName = "agy_cli_windows_${arch}.zip"
    $downloadUrl = $null

    try {
        $releaseUrl = "https://api.github.com/repos/google-antigravity/antigravity-cli/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $releaseUrl -Headers @{ "User-Agent" = "PowerShell" } -TimeoutSec 15
        $asset = $releaseInfo.assets | Where-Object { $_.name -eq $assetName }
        if ($asset -and $asset.browser_download_url) {
            $downloadUrl = $asset.browser_download_url
        }
    } catch {
        Write-Host "  [ NOTE ] GitHub API query failed: $($_.Exception.Message)" -ForegroundColor DarkGray
    }

    if (-not $downloadUrl) {
        $downloadUrl = "https://github.com/google-antigravity/antigravity-cli/releases/latest/download/$assetName"
    }

    $uniqueId = [System.Guid]::NewGuid().ToString("N")
    $tempZip = Join-Path $env:TEMP "agy_${uniqueId}_${assetName}"
    $tempDir = Join-Path $env:TEMP "agy_extracted_$uniqueId"

    Write-Host "Downloading Antigravity CLI ($assetName)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing

    if (Test-Path $tempDir) { Remove-Item -Force -Recurse $tempDir }
    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force

    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }

    # Stop running CLI processes before overwriting binaries
    Get-Process -Name "antigravity", "agy" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    $srcExe = if (Test-Path (Join-Path $tempDir "antigravity.exe")) {
        Join-Path $tempDir "antigravity.exe"
    } elseif (Test-Path (Join-Path $tempDir "agy.exe")) {
        Join-Path $tempDir "agy.exe"
    } else {
        (Get-ChildItem -Path $tempDir -Filter "*.exe" -Recurse | Select-Object -First 1).FullName
    }

    if (-not $srcExe -or -not (Test-Path $srcExe)) {
        throw "Could not find Antigravity executable in extracted files."
    }

    Copy-Item -Path $srcExe -Destination (Join-Path $installDir "antigravity.exe") -Force
    Copy-Item -Path $srcExe -Destination (Join-Path $installDir "agy.exe") -Force

    Remove-Item -Path $tempZip -Force -ErrorAction SilentlyContinue
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

    return $installDir
}

# ── PATH & Environment Update ─────────────────────────────────────────────────
function Update-EnvironmentPath {
    param([Parameter(Mandatory = $true)][string]$InstallDir)

    # User PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($null -eq $userPath) { $userPath = "" }
    $pathParts = $userPath -split ';' | Where-Object { [string]::IsNullOrWhiteSpace($_) -eq $false }
    if ($pathParts -notcontains $InstallDir) {
        $newUserPath = ($pathParts + $InstallDir) -join ';'
        [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
        Write-Host "Added $InstallDir to User PATH." -ForegroundColor Cyan
    }

    # Process PATH
    $procParts = $env:PATH -split ';' | Where-Object { [string]::IsNullOrWhiteSpace($_) -eq $false }
    if ($procParts -notcontains $InstallDir) {
        $env:PATH = ($procParts + $InstallDir) -join ';'
    }

    Broadcast-EnvironmentChange
}

# ── Shortcuts Creation ────────────────────────────────────────────────────────
function Create-Shortcuts {
    param(
        [string]$IdePath,
        [Parameter(Mandatory = $true)]
        [string]$InstallDir
    )

    $targetExe = if ($IdePath -and (Test-Path $IdePath)) {
        $IdePath
    } else {
        Join-Path $InstallDir "antigravity.exe"
    }

    $desktopDir = [Environment]::GetFolderPath("Desktop")
    if ($desktopDir -and (Test-Path $desktopDir)) {
        $desktopShortcut = Join-Path $desktopDir "Antigravity.lnk"
        New-AntigravityShortcut -TargetPath $targetExe -ShortcutPath $desktopShortcut -Description "Google Antigravity" -IconLocation "$targetExe,0"
        Write-Host "Created Desktop shortcut: $desktopShortcut" -ForegroundColor Cyan
    }

    $programsDir = [Environment]::GetFolderPath("Programs")
    if ($programsDir -and (Test-Path $programsDir)) {
        $startMenuShortcut = Join-Path $programsDir "Antigravity.lnk"
        New-AntigravityShortcut -TargetPath $targetExe -ShortcutPath $startMenuShortcut -Description "Google Antigravity" -IconLocation "$targetExe,0"
        Write-Host "Created Start Menu shortcut: $startMenuShortcut" -ForegroundColor Cyan
    }
}

# ── Verification ──────────────────────────────────────────────────────────────
function Verify-AntigravityInstallation {
    param([Parameter(Mandatory = $true)][string]$InstallDir)

    Write-Host "Verifying Antigravity installation..." -ForegroundColor Cyan
    $cliExe = Join-Path $InstallDir "antigravity.exe"
    $agyExe = Join-Path $InstallDir "agy.exe"

    if (-not (Test-Path $cliExe)) {
        throw "Verification failed: $cliExe does not exist."
    }
    if (-not (Test-Path $agyExe)) {
        throw "Verification failed: $agyExe does not exist."
    }

    try {
        $cliVer = & "$cliExe" --version
        Write-Host "Verified 'antigravity.exe --version': $cliVer" -ForegroundColor Green
    } catch {
        throw "Verification failed: executing '$cliExe --version' threw an error: $($_.Exception.Message)"
    }

    try {
        $agyVer = & "$agyExe" --version
        Write-Host "Verified 'agy.exe --version': $agyVer" -ForegroundColor Green
    } catch {
        throw "Verification failed: executing '$agyExe --version' threw an error: $($_.Exception.Message)"
    }

    $ideCandidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\Antigravity.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity\Antigravity.exe"),
        (Join-Path $env:ProgramFiles "Antigravity\Antigravity.exe")
    )
    foreach ($cand in $ideCandidates) {
        if (Test-Path $cand) {
            Write-Host "Verified Antigravity IDE executable: $cand" -ForegroundColor Green
            break
        }
    }
}

# ── Uninstall Antigravity ─────────────────────────────────────────────────────
function Uninstall-Antigravity {
    Write-Host "Uninstalling Antigravity..." -ForegroundColor Cyan

    # 1. Stop running processes
    Write-Host "Stopping running Antigravity processes..." -ForegroundColor Cyan
    Get-Process -Name "antigravity*", "agy*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500

    # 2. Run uninstaller if present
    $uninstallerCandidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\Uninstall Antigravity.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity\Uninstall Antigravity.exe")
    )
    foreach ($uninstaller in $uninstallerCandidates) {
        if (Test-Path $uninstaller) {
            Write-Host "Running Antigravity IDE uninstaller: $uninstaller..." -ForegroundColor Cyan
            try {
                Start-Process -FilePath $uninstaller -ArgumentList "/currentuser", "/S" -Wait -NoNewWindow
            } catch {
                Write-Host "  [ NOTE ] IDE uninstaller message: $($_.Exception.Message)" -ForegroundColor DarkGray
            }
            break
        }
    }

    # Clean up any leftover IDE directory
    foreach ($dir in @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity")
    )) {
        if (Test-Path $dir) {
            Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    # 3. Clean up CLI binaries and directories
    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    if (Test-Path $installDir) {
        Write-Host "Removing CLI directory: $installDir..." -ForegroundColor Cyan
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    $antigravityRoot = Join-Path $env:USERPROFILE ".antigravity"
    if (Test-Path $antigravityRoot) {
        if ((Get-ChildItem -Path $antigravityRoot -Force | Measure-Object).Count -eq 0) {
            Remove-Item -Path $antigravityRoot -Force -ErrorAction SilentlyContinue
        }
    }

    # 4. Clean up shortcuts
    $desktopDir = [Environment]::GetFolderPath("Desktop")
    if ($desktopDir) {
        $desktopShortcut = Join-Path $desktopDir "Antigravity.lnk"
        if (Test-Path $desktopShortcut) {
            Remove-Item -Path $desktopShortcut -Force -ErrorAction SilentlyContinue
            Write-Host "Removed Desktop shortcut: $desktopShortcut" -ForegroundColor Cyan
        }
    }

    $programsDir = [Environment]::GetFolderPath("Programs")
    if ($programsDir) {
        $startMenuShortcut = Join-Path $programsDir "Antigravity.lnk"
        if (Test-Path $startMenuShortcut) {
            Remove-Item -Path $startMenuShortcut -Force -ErrorAction SilentlyContinue
            Write-Host "Removed Start Menu shortcut: $startMenuShortcut" -ForegroundColor Cyan
        }
    }

    # 5. Remove from User PATH and process PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if (-not [string]::IsNullOrEmpty($userPath)) {
        $parts = $userPath -split ';' | Where-Object {
            [string]::IsNullOrWhiteSpace($_) -eq $false -and
            $_ -ne $installDir -and
            $_ -ne (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\bin") -and
            $_ -ne (Join-Path $env:LOCALAPPDATA "Programs\antigravity\bin")
        }
        $newUserPath = $parts -join ';'
        [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
        Write-Host "Removed $installDir from User PATH." -ForegroundColor Cyan
    }

    $procParts = $env:PATH -split ';' | Where-Object {
        [string]::IsNullOrWhiteSpace($_) -eq $false -and
        $_ -ne $installDir -and
        $_ -ne (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\bin") -and
        $_ -ne (Join-Path $env:LOCALAPPDATA "Programs\antigravity\bin")
    }
    $env:PATH = $procParts -join ';'

    # Broadcast environment changes
    Broadcast-EnvironmentChange
    Write-Host "Antigravity uninstalled successfully." -ForegroundColor Green
}

# ── Main Entry Point ──────────────────────────────────────────────────────────
function Install-Antigravity {
    Write-Host "Installing Antigravity (IDE & CLI)..." -ForegroundColor Cyan

    $idePath = Install-AntigravityIDE
    $installDir = Install-AntigravityCLI

    Update-EnvironmentPath -InstallDir $installDir
    Create-Shortcuts -IdePath $idePath -InstallDir $installDir
    Verify-AntigravityInstallation -InstallDir $installDir

    Write-Host "Antigravity installation complete." -ForegroundColor Green
}

function Check-Antigravity {
    Write-Host "Checking Antigravity installation..." -ForegroundColor Cyan
    $installDir = Join-Path $env:USERPROFILE ".antigravity\bin"
    $hasCli = (Test-Path (Join-Path $installDir "antigravity.exe")) -or (Test-Path (Join-Path $installDir "agy.exe"))
    $hasIde = $false

    $ideCandidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Antigravity\Antigravity.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\antigravity\Antigravity.exe"),
        (Join-Path $env:ProgramFiles "Antigravity\Antigravity.exe")
    )
    foreach ($cand in $ideCandidates) {
        if (Test-Path $cand) {
            $hasIde = $true
            break
        }
    }

    if ($hasCli -or $hasIde) {
        Write-Host "Antigravity is present on the system (CLI: $hasCli, IDE: $hasIde)." -ForegroundColor Green
    } else {
        Write-Host "Antigravity is not currently installed." -ForegroundColor Yellow
    }
    exit 0
}

switch ($Command.ToLowerInvariant()) {
    "check"     { Check-Antigravity }
    "uninstall" { Uninstall-Antigravity }
    default     { Install-Antigravity }
}
