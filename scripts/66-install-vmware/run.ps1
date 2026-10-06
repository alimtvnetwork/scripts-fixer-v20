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
. (Join-Path $sharedDir "path-utils.ps1")

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


function Get-VMwareRegistryDirFromKey {
    param([string]$KeyPath)

    $hasKey = Test-Path $KeyPath

    if (-not $hasKey) {
        return ""
    }

    $prop = Get-ItemProperty -Path $KeyPath -ErrorAction SilentlyContinue
    $rawPath = if ($null -ne $prop) { $prop.InstallPath } else { "" }
    $cleanPath = if (-not [string]::IsNullOrWhiteSpace($rawPath)) { $rawPath.TrimEnd('\', '/') } else { "" }
    $hasPath = (-not [string]::IsNullOrWhiteSpace($cleanPath)) -and (Test-Path $cleanPath)

    if ($hasPath) {
        return $cleanPath
    }

    return ""
}

function Get-VMwareRegistryDir {
    $keys = @(
        "HKLM:\SOFTWARE\VMware, Inc.\VMware Workstation",
        "HKLM:\SOFTWARE\WOW6432Node\VMware, Inc.\VMware Workstation",
        "HKLM:\SOFTWARE\VMware, Inc.\VMware Player",
        "HKLM:\SOFTWARE\WOW6432Node\VMware, Inc.\VMware Player"
    )

    foreach ($key in $keys) {
        $foundDir = Get-VMwareRegistryDirFromKey -KeyPath $key
        $hasFoundDir = -not [string]::IsNullOrWhiteSpace($foundDir)

        if ($hasFoundDir) {
            return $foundDir
        }
    }

    return ""
}

function Add-CandidateDirSafe {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$DirectoryPath
    )

    $hasValue = -not [string]::IsNullOrWhiteSpace($DirectoryPath)

    if (-not $hasValue) {
        return
    }

    $cleanDir = $DirectoryPath.TrimEnd('\', '/')
    $isNew = -not $List.Contains($cleanDir)

    if ($isNew) {
        $List.Add($cleanDir)
    }
}

function Get-VMwareCandidateDirs {
    $dirs = [System.Collections.Generic.List[string]]::new()
    $regDir = Get-VMwareRegistryDir
    Add-CandidateDirSafe -List $dirs -DirectoryPath $regDir

    Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path ${env:ProgramFiles} "VMware\VMware Workstation")
    Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path ${env:ProgramFiles} "VMware\VMware Player")

    $x86Root = ${env:ProgramFiles(x86)}
    $hasX86Root = -not [string]::IsNullOrWhiteSpace($x86Root)

    if ($hasX86Root) {
        Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path $x86Root "VMware\VMware Workstation")
        Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path $x86Root "VMware\VMware Player")
    }

    return $dirs.ToArray()
}

function Get-VMwareTargetDir {
    $candidateDirs = Get-VMwareCandidateDirs

    foreach ($dir in $candidateDirs) {
        $hasDir = Test-Path $dir

        if ($hasDir) {
            return $dir
        }
    }

    return (Join-Path ${env:ProgramFiles} "VMware\VMware Workstation")
}

function Check-VMwareCandidateDirs {
    $candidateDirs = Get-VMwareCandidateDirs

    foreach ($dir in $candidateDirs) {
        $hasDir = Test-Path $dir
        Write-Log "Checked candidate directory '$dir': exists=$hasDir" -Level "info"
    }
}

function Add-DirectoryToBothPaths {
    param([string]$DirectoryPath)

    $hasDir = -not [string]::IsNullOrWhiteSpace($DirectoryPath) -and (Test-Path $DirectoryPath)

    if (-not $hasDir) {
        return
    }

    $cleanDir = $DirectoryPath.TrimEnd('\', '/')
    Add-ToMachinePath -Directory $cleanDir
    Add-ToUserPath -Directory $cleanDir
    $env:Path = "$cleanDir;$($env:Path)"
    Write-Log "VMware directory exported to Machine and User PATH: $cleanDir" -Level "success"
}

function Test-VMwareCliDir {
    param([string]$DirectoryPath)

    $hasDir = Test-Path $DirectoryPath

    if (-not $hasDir) {
        return $false
    }

    $vmrunPath = Join-Path $DirectoryPath "vmrun.exe"
    $vdiskPath = Join-Path $DirectoryPath "vmware-vdiskmanager.exe"
    $hasCli = (Test-Path $vmrunPath) -or (Test-Path $vdiskPath)

    return $hasCli
}

function Get-VMwareCliCandidateDirs {
    param([string]$InstallDir)

    $dirs = [System.Collections.Generic.List[string]]::new()
    Add-CandidateDirSafe -List $dirs -DirectoryPath $InstallDir

    $vixRegDir = Get-VMwareRegistryDirFromKey -KeyPath "HKLM:\SOFTWARE\VMware, Inc.\VMware VIX"
    Add-CandidateDirSafe -List $dirs -DirectoryPath $vixRegDir

    $vixWowDir = Get-VMwareRegistryDirFromKey -KeyPath "HKLM:\SOFTWARE\WOW6432Node\VMware, Inc.\VMware VIX"
    Add-CandidateDirSafe -List $dirs -DirectoryPath $vixWowDir

    Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path $InstallDir "vix")
    Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path ${env:ProgramFiles} "VMware\VMware VIX")

    $x86Root = ${env:ProgramFiles(x86)}
    $hasX86Root = -not [string]::IsNullOrWhiteSpace($x86Root)

    if ($hasX86Root) {
        Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path $x86Root "VMware\VMware VIX")
    }

    return $dirs.ToArray()
}

function Get-VMwareCliDir {
    param([string]$InstallDir)

    $candidates = Get-VMwareCliCandidateDirs -InstallDir $InstallDir

    foreach ($dir in $candidates) {
        $hasCli = Test-VMwareCliDir -DirectoryPath $dir

        if ($hasCli) {
            return $dir
        }
    }

    foreach ($dir in $candidates) {
        $hasDir = (Test-Path $dir) -and ($dir -ne $InstallDir)

        if ($hasDir) {
            return $dir
        }
    }

    return ""
}

function Add-VMwareToPath {
    param([string]$InstallDir)

    $hasInstallDir = -not [string]::IsNullOrWhiteSpace($InstallDir) -and (Test-Path $InstallDir)

    if (-not $hasInstallDir) {
        return
    }

    Add-DirectoryToBothPaths -DirectoryPath $InstallDir
    $cliDir = Get-VMwareCliDir -InstallDir $InstallDir
    $hasCliDir = (-not [string]::IsNullOrWhiteSpace($cliDir)) -and ($cliDir -ne $InstallDir)

    if ($hasCliDir) {
        Add-DirectoryToBothPaths -DirectoryPath $cliDir
    }
}

function Test-VMwareBinaryInDir {
    param([string]$DirectoryPath)

    $hasDir = Test-Path $DirectoryPath

    if (-not $hasDir) {
        return $false
    }

    $vmwareExe = Join-Path $DirectoryPath "vmware.exe"
    $playerExe = Join-Path $DirectoryPath "vmplayer.exe"
    $hasBinary = (Test-Path $vmwareExe) -or (Test-Path $playerExe)

    return $hasBinary
}

function Test-VMwareBinaryOnDisk {
    $candidateDirs = Get-VMwareCandidateDirs

    foreach ($dir in $candidateDirs) {
        $hasBinary = Test-VMwareBinaryInDir -DirectoryPath $dir

        if ($hasBinary) {
            return $true
        }
    }

    $cmd = (Get-Command "vmware.exe" -ErrorAction SilentlyContinue) -or (Get-Command "vmplayer.exe" -ErrorAction SilentlyContinue)
    $hasCommand = $null -ne $cmd

    return $hasCommand
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

function Test-VMwareAuthService {
    $service = Get-Service -Name "VMAuthdService" -ErrorAction SilentlyContinue
    $hasService = $null -ne $service

    return $hasService
}

function Log-VMwareAuthServiceStatus {
    $hasAuthService = Test-VMwareAuthService

    if (-not $hasAuthService) {
        return
    }

    Write-Log "VMware Authorization Service (VMAuthdService) verified." -Level "info"
}

function Get-VMwareKeySerial {
    param([string]$KeyPath)

    $hasKey = Test-Path $KeyPath

    if (-not $hasKey) {
        return ""
    }

    $props = Get-ItemProperty $KeyPath -ErrorAction SilentlyContinue
    $hasSerial = $null -ne $props -and (-not [string]::IsNullOrWhiteSpace($props.Serial))

    if ($hasSerial) {
        return $props.Serial
    }

    return ""
}

function Get-VMwareLicenseSerial {
    $keys = @(
        "HKLM:\SOFTWARE\VMware, Inc.\VMware Workstation",
        "HKLM:\SOFTWARE\WOW6432Node\VMware, Inc.\VMware Workstation"
    )

    foreach ($key in $keys) {
        $serial = Get-VMwareKeySerial -KeyPath $key
        $hasSerial = -not [string]::IsNullOrWhiteSpace($serial)

        if ($hasSerial) {
            return $serial
        }
    }

    return ""
}

function Test-BroadcomPersonalUse {
    $hasPersonalEnv = $env:VMWARE_PERSONAL_USE -eq "1"

    if ($hasPersonalEnv) {
        return $true
    }

    $hasEnvKey = -not [string]::IsNullOrWhiteSpace($env:VMWARE_LICENSE_KEY)

    if ($hasEnvKey) {
        return $false
    }

    $hasEnvSerial = -not [string]::IsNullOrWhiteSpace($env:VMWARE_SERIAL)

    if ($hasEnvSerial) {
        return $false
    }

    $serial = Get-VMwareLicenseSerial
    $hasSerial = -not [string]::IsNullOrWhiteSpace($serial)

    if ($hasSerial) {
        return $false
    }

    return $true
}

function Log-BroadcomLicenseStatus {
    $isPersonal = Test-BroadcomPersonalUse

    if ($isPersonal) {
        Write-Log "Broadcom personal use mode active (commercial license not required)." -Level "info"

        return
    }

    Write-Log "Commercial VMware license detected in registry." -Level "info"
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

    $hasService = Test-VMwareAuthService

    if ($hasService) {
        return $true
    }

    return $false
}

function Has-Winget {
    $wingetCmd = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    $hasWinget = $null -ne $wingetCmd

    return $hasWinget
}

function Test-WingetPackageFound {
    param([string]$PackageId)

    try {
        $searchArgs = @("search", "--id", $PackageId, "--exact", "--accept-source-agreements")
        $proc = Start-Process -FilePath "winget.exe" -ArgumentList $searchArgs -Wait -PassThru -NoNewWindow
        $isFound = ($proc.ExitCode -eq 0)

        return $isFound
    } catch {
        return $false
    }
}

function Invoke-WingetInstallProc {
    param([string]$PackageId)

    $wingetArgs = @(
        "install",
        $PackageId,
        "--accept-source-agreements",
        "--accept-package-agreements",
        "--disable-interactivity"
    )
    $proc = Start-Process -FilePath "winget.exe" -ArgumentList $wingetArgs -Wait -PassThru -NoNewWindow
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}

function Install-VMwareViaWinget {
    $hasWinget = Has-Winget

    if (-not $hasWinget) {
        return $false
    }

    $packageId = "VMware.WorkstationPro"
    $hasPackage = Test-WingetPackageFound -PackageId $packageId

    if (-not $hasPackage) {
        Write-Log "Winget returned exit code 1 or found 0 packages for '$packageId'; falling through immediately to Chocolatey..." -Level "info"

        return $false
    }

    Write-Log "Attempting install via winget package '$packageId'..." -Level "info"
    $isSuccess = Invoke-WingetInstallProc -PackageId $packageId

    if (-not $isSuccess) {
        Write-Log "Winget installation failed (exit code non-zero); falling through immediately to Chocolatey..." -Level "info"

        return $false
    }

    return $true
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

function Add-DownloadUrlSafe {
    param(
        [System.Collections.Generic.List[string]]$List,
        [string]$UrlOrPath
    )

    $hasValue = (-not [string]::IsNullOrWhiteSpace($UrlOrPath)) -and (-not $List.Contains($UrlOrPath))

    if ($hasValue) {
        $List.Add($UrlOrPath)
    }
}

function Get-VMwareInstallerEnvPath {
    $installerPath = $env:VMWARE_INSTALLER_PATH
    $hasInstallerPath = -not [string]::IsNullOrWhiteSpace($installerPath)

    if (-not $hasInstallerPath) {
        return ""
    }

    $hasLocalPath = Test-Path $installerPath -ErrorAction SilentlyContinue
    $isUrl = $installerPath -like "http*://"

    if ($hasLocalPath -or $isUrl) {
        return $installerPath
    }

    return ""
}

function Get-VMwareTempInstallerPath {
    $tempPath = Join-Path $env:TEMP "vmware-installer.exe"
    $hasTemp = Test-Path $tempPath -ErrorAction SilentlyContinue

    if (-not $hasTemp) {
        return ""
    }

    $item = Get-Item $tempPath -ErrorAction SilentlyContinue
    $hasValidSize = ($null -ne $item) -and ($item.Length -gt 1048576)

    if ($hasValidSize) {
        return $tempPath
    }

    return ""
}

function Get-VMwareDownloadUrls {
    $urls = [System.Collections.Generic.List[string]]::new()

    $installerEnv = Get-VMwareInstallerEnvPath
    $hasInstallerEnv = -not [string]::IsNullOrWhiteSpace($installerEnv)

    if ($hasInstallerEnv) {
        Add-DownloadUrlSafe -List $urls -UrlOrPath $installerEnv
    }

    $tempInstaller = Get-VMwareTempInstallerPath
    $hasTempInstaller = -not [string]::IsNullOrWhiteSpace($tempInstaller)

    if ($hasTempInstaller) {
        Add-DownloadUrlSafe -List $urls -UrlOrPath $tempInstaller
    }

    $customUrl = $env:VMWARE_DOWNLOAD_URL
    $hasCustomUrl = -not [string]::IsNullOrWhiteSpace($customUrl)

    if ($hasCustomUrl) {
        Add-DownloadUrlSafe -List $urls -UrlOrPath $customUrl
    }

    Add-DownloadUrlSafe -List $urls -UrlOrPath "https://download3.vmware.com/software/WKST-1760-WIN/VMware-workstation-full-17.6.0-24238078.exe"
    Add-DownloadUrlSafe -List $urls -UrlOrPath "https://archive.org/download/vmware-workstation-full-17.6.0-24238078/VMware-workstation-full-17.6.0-24238078.exe"
    Add-DownloadUrlSafe -List $urls -UrlOrPath "https://download3.vmware.com/software/WKST-1752-WIN/VMware-workstation-full-17.5.2-23775571.exe"
    Add-DownloadUrlSafe -List $urls -UrlOrPath "https://download3.vmware.com/software/wkst/VMware-workstation-full-17.5.2-23775571.exe"
    Add-DownloadUrlSafe -List $urls -UrlOrPath "https://download3.vmware.com/software/WKST-1750-WIN/VMware-workstation-full-17.5.0-22583795.exe"

    return $urls.ToArray()
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

function Copy-VMwareLocalInstaller {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    $hasSamePath = ($SourcePath -eq $DestinationPath)

    if ($hasSamePath) {
        $item = Get-Item $DestinationPath -ErrorAction SilentlyContinue
        $hasValidSize = ($null -ne $item) -and ($item.Length -gt 1048576)

        return $hasValidSize
    }

    try {
        Copy-Item -Path $SourcePath -Destination $DestinationPath -Force
        $item = Get-Item $DestinationPath -ErrorAction SilentlyContinue
        $hasCopied = ($null -ne $item) -and ($item.Length -gt 1048576)

        return $hasCopied
    } catch {
        Write-FileError -FilePath $DestinationPath -Operation "copy" -Reason $_.Exception.Message -Module "VMwareInstaller"

        return $false
    }
}

function Invoke-VMwareDownloadAttempt {
    param(
        [string]$Url,
        [string]$DestinationPath
    )

    $hasLocalFile = (Test-Path $Url -ErrorAction SilentlyContinue) -and (-not (Test-Path $Url -PathType Container -ErrorAction SilentlyContinue))

    if ($hasLocalFile) {
        Write-Log "Using local VMware installer from $Url..." -Level "info"

        return (Copy-VMwareLocalInstaller -SourcePath $Url -DestinationPath $DestinationPath)
    }

    try {
        Write-Log "Downloading VMware installer from $Url..." -Level "info"
        Invoke-WebRequest -Uri $Url -OutFile $DestinationPath -UseBasicParsing -TimeoutSec 300
        $item = Get-Item $DestinationPath -ErrorAction SilentlyContinue
        $hasFile = ($null -ne $item) -and ($item.Length -gt 1048576)

        return $hasFile
    } catch {
        Remove-VMwareTempInstaller -FilePath $DestinationPath
        Write-FileError -FilePath $DestinationPath -Operation "download" -Reason $_.Exception.Message -Module "VMwareInstaller"

        return $false
    }
}

function Invoke-VMwareDownloadWithFallbacks {
    param([string]$DestinationPath)

    $urls = Get-VMwareDownloadUrls

    foreach ($url in $urls) {
        $hasDownloaded = Invoke-VMwareDownloadAttempt -Url $url -DestinationPath $DestinationPath

        if ($hasDownloaded) {
            return $true
        }
    }

    return $false
}

function Invoke-VMwareBinaryInstaller {
    param([string]$InstallerPath)

    $hasInstaller = Test-Path $InstallerPath

    if (-not $hasInstaller) {
        Write-FileError -FilePath $InstallerPath -Operation "execute" -Reason "Installer executable not found on disk" -Module "VMwareInstaller"

        return $false
    }

    Write-Log "Executing installer silently with Broadcom EULA acceptance..." -Level "info"
    $installerArgs = '/s /v"/qn EULAS_AGREED=1 AUTOSOFTWAREUPDATE=0 REBOOT=ReallySuppress"'
    $proc = Start-Process -FilePath $InstallerPath -ArgumentList $installerArgs -Wait -PassThru
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}

function Install-VMwareViaDirectDownload {
    param([string]$TempInstallerPath)

    $hasDownloaded = Invoke-VMwareDownloadWithFallbacks -DestinationPath $TempInstallerPath

    if (-not $hasDownloaded) {
        return $false
    }

    $isInstalled = Invoke-VMwareBinaryInstaller -InstallerPath $TempInstallerPath
    Remove-VMwareTempInstaller -FilePath $TempInstallerPath

    return $isInstalled
}

function Install-VMwareResilient {
    param([string]$TempInstallerPath)

    $isWingetInstalled = Install-VMwareViaWinget

    if ($isWingetInstalled) {
        return $true
    }

    Write-Log "Winget installation skipped or failed; trying Chocolatey..." -Level "info"
    $isChocoInstalled = Install-VMwareViaChoco

    if ($isChocoInstalled) {
        return $true
    }

    Write-Log "Chocolatey installation skipped or failed; trying direct download..." -Level "info"
    $isDirectInstalled = Install-VMwareViaDirectDownload -TempInstallerPath $TempInstallerPath

    return $isDirectInstalled
}

function Execute-VMwareInstall {
    param(
        [string]$TempPath,
        [string]$TargetDir
    )

    $isSuccess = Install-VMwareResilient -TempInstallerPath $TempPath
    $isDetected = Is-VMwareInstalled
    $hasAuthService = Test-VMwareAuthService
    $isFinalSuccess = $isSuccess -or $isDetected -or $hasAuthService

    if ($isFinalSuccess) {
        Log-VMwareAuthServiceStatus
        Log-BroadcomLicenseStatus
        Write-Log "VMware installed successfully." -Level "success"
        Invoke-DbRecord -Action "record-success" -ExtraArgs @("package", "vmware", "17.6.0", "VMware Workstation installed")

        return $true
    }

    Write-FileError -FilePath $TargetDir -Operation "install" -Reason "VMware installation failed across all tiers" -Module "VMwareInstaller"
    Write-Log "VMware installation failed." -Level "error"
    Invoke-DbRecord -Action "record-failure" -ExtraArgs @("package", "vmware", "1", "installer failed")

    return $false
}

function Invoke-VMwareInstallMain {
    Write-Banner -Title "Install VMware Workstation/Player"
    Initialize-Logging -ScriptName "Install VMware"

    $candidateDirs = Get-VMwareCandidateDirs
    Check-VMwareCandidateDirs
    $targetDir = Get-VMwareTargetDir
    $targetPaths = $candidateDirs -join ", "
    $downloadUrls = Get-VMwareDownloadUrls
    $primarySource = $downloadUrls[0]
    $tempPath = Join-Path $env:TEMP "vmware-installer.exe"

    Write-InstallPaths `
        -Tool   "VMware Workstation/Player" `
        -Source $primarySource `
        -Temp   $tempPath `
        -Target $targetPaths

    try {
        Write-Log "Checking for existing VMware installation..." -Level "info"
        $isInstalled = Is-VMwareInstalled

        if ($isInstalled) {
            Add-VMwareToPath -InstallDir $targetDir
            Log-VMwareAuthServiceStatus
            Log-BroadcomLicenseStatus
            Write-Log "VMware is already installed." -Level "success"
            Invoke-DbRecord -Action "record-skipped" -ExtraArgs @("package", "vmware", "already installed")

            return
        }

        Invoke-DbRecord -Action "record-start" -ExtraArgs @("package", "vmware", "install")
        $isInstallOk = Execute-VMwareInstall -TempPath $tempPath -TargetDir $targetDir

        if ($isInstallOk) {
            $installedDir = Get-VMwareTargetDir
            Add-VMwareToPath -InstallDir $installedDir
        }
    } catch {
        Write-Log "Error: $_" -Level "error"
        Invoke-DbRecord -Action "record-failure" -ExtraArgs @("package", "vmware", "1", "$_")
    } finally {
        $hasErrors = $script:_LogErrors.Count -gt 0
        $finalStatus = if ($hasErrors) { "fail" } else { "ok" }
        Save-LogFile -Status $finalStatus
    }
}

Invoke-VMwareInstallMain
