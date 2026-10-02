# --------------------------------------------------------------------------
#  Script 66 -- Install VMware Workstation/Player
# --------------------------------------------------------------------------
param(
    [Parameter(Position = 0)]
    [string]$Command = "install"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"

. (Join-Path $sharedDir "logging.ps1")
. (Join-Path $sharedDir "install-paths.ps1")

$dbBridge = Join-Path $sharedDir "db_bridge.py"

function Invoke-DbRecord {
    param(
        [string]$Action,
        [string[]]$ExtraArgs
    )

    $hasBridge = Test-Path $script:dbBridge
    if ($hasBridge) {
        python $script:dbBridge $Action @ExtraArgs 2>$null
    }
}

function Get-VMwareTargetDir {
    $x64Path = Join-Path ${env:ProgramFiles} "VMware\VMware Workstation"
    $hasX64 = Test-Path $x64Path
    if ($hasX64) {
        return $x64Path
    }

    $x86Path = Join-Path ${env:ProgramFiles(x86)} "VMware\VMware Workstation"
    $hasX86 = Test-Path $x86Path
    if ($hasX86) {
        return $x86Path
    }

    return $x64Path
}

function Test-VMwareBinaryOnDisk {
    $targetDir = Get-VMwareTargetDir
    $vmwareExe = Join-Path $targetDir "vmware.exe"
    $playerExe = Join-Path $targetDir "vmplayer.exe"
    $hasBinary = (Test-Path $vmwareExe) -or (Test-Path $playerExe)

    return $hasBinary
}

function Test-VMwareDisplayName {
    param([string]$DisplayName)

    $isMatch = $DisplayName -like '*VMware Workstation*' -or $DisplayName -like '*VMware Player*'

    return $isMatch
}

function Test-VMwareRegistryKey {
    param([string]$RegistryPath)

    $items = Get-ItemProperty $RegistryPath -ErrorAction SilentlyContinue
    $matchingItems = $items | Where-Object {
        $null -ne $_.DisplayName -and (Test-VMwareDisplayName -DisplayName $_.DisplayName)
    }
    $hasMatch = $null -ne $matchingItems -and @($matchingItems).Count -gt 0

    return $hasMatch
}

function Is-VMwareInstalled {
    $hasBinary = Test-VMwareBinaryOnDisk
    if ($hasBinary) {
        return $true
    }

    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    foreach ($p in $paths) {
        $hasKey = Test-VMwareRegistryKey -RegistryPath $p
        if ($hasKey) {
            return $true
        }
    }

    return $false
}

function Has-Chocolatey {
    $chocoCmd = Get-Command "choco.exe" -ErrorAction SilentlyContinue
    $hasChoco = $null -ne $chocoCmd

    return $hasChoco
}

function Install-VMwareViaChocoPackage {
    param([string]$PackageName)

    Write-Log "Attempting install via Chocolatey package '$PackageName'..." -Level "info"
    $proc = Start-Process -FilePath "choco.exe" -ArgumentList @("install", $PackageName, "--yes", "--no-progress") -Wait -PassThru -NoNewWindow
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}

function Install-VMwareViaChoco {
    $hasChoco = Has-Chocolatey
    if (-not $hasChoco) {
        return $false
    }

    $isWorkstationInstalled = Install-VMwareViaChocoPackage -PackageName "vmwareworkstation"
    if ($isWorkstationInstalled) {
        return $true
    }

    $isPlayerInstalled = Install-VMwareViaChocoPackage -PackageName "vmware-workstation-player"

    return $isPlayerInstalled
}

function Get-VMwareDownloadUrl {
    $url = $env:VMWARE_DOWNLOAD_URL
    $hasCustomUrl = -not [string]::IsNullOrWhiteSpace($url)
    if ($hasCustomUrl) {
        return $url
    }

    return "https://download3.vmware.com/software/WKST-1752-WIN/VMware-workstation-full-17.5.2-23775571.exe"
}

function Invoke-VMwareDownload {
    param(
        [string]$Url,
        [string]$DestinationPath
    )

    try {
        Write-Log "Downloading VMware installer from $Url..." -Level "info"
        Invoke-WebRequest -Uri $Url -OutFile $DestinationPath -UseBasicParsing
        $hasFile = Test-Path $DestinationPath

        return $hasFile
    } catch {
        Write-FileError -FilePath $DestinationPath -Operation "download" -Reason $_.Exception.Message -Module "VMwareInstaller"

        return $false
    }
}

function Invoke-VMwareBinaryInstaller {
    param([string]$InstallerPath)

    $hasInstaller = Test-Path $InstallerPath
    if (-not $hasInstaller) {
        Write-FileError -FilePath $InstallerPath -Operation "execute" -Reason "Installer executable not found on disk" -Module "VMwareInstaller"

        return $false
    }

    Write-Log "Executing installer silently..." -Level "info"
    $installerArgs = '/s /v"/qn EULAS_AGREED=1 REBOOT=ReallySuppress"'
    $proc = Start-Process -FilePath $InstallerPath -ArgumentList $installerArgs -Wait -PassThru
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}

function Remove-VMwareTempInstaller {
    param([string]$FilePath)

    $hasFile = Test-Path $FilePath
    if (-not $hasFile) {
        return
    }

    try {
        Write-Log "Cleaning up installer..." -Level "info"
        Remove-Item -Path $FilePath -Force -ErrorAction Stop
    } catch {
        Write-FileError -FilePath $FilePath -Operation "remove" -Reason $_.Exception.Message -Module "VMwareInstaller"
    }
}

function Install-VMwareViaDirectDownload {
    param(
        [string]$DownloadUrl,
        [string]$TempInstallerPath
    )

    $hasDownloaded = Invoke-VMwareDownload -Url $DownloadUrl -DestinationPath $TempInstallerPath
    if (-not $hasDownloaded) {
        return $false
    }

    $isInstalled = Invoke-VMwareBinaryInstaller -InstallerPath $TempInstallerPath
    Remove-VMwareTempInstaller -FilePath $TempInstallerPath

    return $isInstalled
}

function Install-VMwareResilient {
    param(
        [string]$DownloadUrl,
        [string]$TempInstallerPath
    )

    $isChocoInstalled = Install-VMwareViaChoco
    if ($isChocoInstalled) {
        return $true
    }

    Write-Log "Chocolatey installation skipped or failed; trying direct download..." -Level "info"
    $isDirectInstalled = Install-VMwareViaDirectDownload -DownloadUrl $DownloadUrl -TempInstallerPath $TempInstallerPath

    return $isDirectInstalled
}

Write-Banner -Title "Install VMware Workstation/Player"
Initialize-Logging -ScriptName "Install VMware"

$targetDir = Get-VMwareTargetDir
$url = Get-VMwareDownloadUrl
$tempPath = Join-Path $env:TEMP "vmware-installer.exe"

Write-InstallPaths `
    -Tool   "VMware Workstation/Player" `
    -Source $url `
    -Temp   $tempPath `
    -Target $targetDir

try {
    Write-Log "Checking for existing VMware installation..." -Level "info"
    $isInstalled = Is-VMwareInstalled

    if ($isInstalled) {
        Write-Log "VMware is already installed." -Level "success"
        Invoke-DbRecord -Action "record-skipped" -ExtraArgs @("package", "vmware", "already installed")

        return
    }

    Invoke-DbRecord -Action "record-start" -ExtraArgs @("package", "vmware", "install")
    $isSuccess = Install-VMwareResilient -DownloadUrl $url -TempInstallerPath $tempPath

    if ($isSuccess) {
        Write-Log "VMware installed successfully." -Level "success"
        Invoke-DbRecord -Action "record-success" -ExtraArgs @("package", "vmware", "17.5.2", "VMware Workstation installed")
    } else {
        Write-Log "VMware installation failed." -Level "error"
        Invoke-DbRecord -Action "record-failure" -ExtraArgs @("package", "vmware", "1", "installer failed")
    }
} catch {
    Write-Log "Error: $_" -Level "error"
    Invoke-DbRecord -Action "record-failure" -ExtraArgs @("package", "vmware", "1", "$_")
} finally {
    $hasErrors = $script:_LogErrors.Count -gt 0
    $finalStatus = if ($hasErrors) { "fail" } else { "ok" }
    Save-LogFile -Status $finalStatus
}
