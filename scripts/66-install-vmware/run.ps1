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

function Get-VMwareCandidateDirs {
    $dirs = [System.Collections.Generic.List[string]]::new()
    $dirs.Add((Join-Path ${env:ProgramFiles} "VMware\VMware Workstation"))

    $x86Root = ${env:ProgramFiles(x86)}
    $hasX86Root = -not [string]::IsNullOrWhiteSpace($x86Root)
    if ($hasX86Root) {
        $dirs.Add((Join-Path $x86Root "VMware\VMware Workstation"))
    }

    return $dirs.ToArray()
}

function Get-VMwareTargetDir {
    $x64Path = Join-Path ${env:ProgramFiles} "VMware\VMware Workstation"
    $hasX64 = Test-Path $x64Path
    if ($hasX64) {
        return $x64Path
    }

    $x86Root = ${env:ProgramFiles(x86)}
    $hasX86Root = -not [string]::IsNullOrWhiteSpace($x86Root)
    $x86Path = if ($hasX86Root) { Join-Path $x86Root "VMware\VMware Workstation" } else { "" }
    $hasX86 = (-not [string]::IsNullOrWhiteSpace($x86Path)) -and (Test-Path $x86Path)
    if ($hasX86) {
        return $x86Path
    }

    return $x64Path
}

function Check-VMwareCandidateDirs {
    $candidateDirs = Get-VMwareCandidateDirs
    foreach ($dir in $candidateDirs) {
        $hasDir = Test-Path $dir
        Write-Log "Checked candidate directory '$dir': exists=$hasDir" -Level "info"
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

function Install-VMwareViaWinget {
    $hasWinget = Has-Winget
    if (-not $hasWinget) {
        return $false
    }

    Write-Log "Attempting install via winget package 'VMware.WorkstationPro'..." -Level "info"
    $wingetArgs = @(
        "install",
        "VMware.WorkstationPro",
        "--accept-source-agreements",
        "--accept-package-agreements"
    )
    $proc = Start-Process -FilePath "winget.exe" -ArgumentList $wingetArgs -Wait -PassThru -NoNewWindow
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
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

function Get-VMwareDownloadUrls {
    $urls = [System.Collections.Generic.List[string]]::new()
    $customUrl = $env:VMWARE_DOWNLOAD_URL
    $hasCustomUrl = -not [string]::IsNullOrWhiteSpace($customUrl)
    if ($hasCustomUrl) {
        $urls.Add($customUrl)
    }

    $urls.Add("https://download3.vmware.com/software/WKST-1752-WIN/VMware-workstation-full-17.5.2-23775571.exe")
    $urls.Add("https://download3.vmware.com/software/wkst/VMware-workstation-full-17.5.2-23775571.exe")
    $urls.Add("https://download3.vmware.com/software/WKST-1750-WIN/VMware-workstation-full-17.5.0-22583795.exe")

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

function Invoke-VMwareDownloadAttempt {
    param(
        [string]$Url,
        [string]$DestinationPath
    )

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

    Write-Log "Executing installer silently..." -Level "info"
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
        Log-VMwareAuthServiceStatus
        Write-Log "VMware is already installed." -Level "success"
        Invoke-DbRecord -Action "record-skipped" -ExtraArgs @("package", "vmware", "already installed")

        return
    }

    Invoke-DbRecord -Action "record-start" -ExtraArgs @("package", "vmware", "install")
    $isSuccess = Install-VMwareResilient -TempInstallerPath $tempPath
    $isDetected = Is-VMwareInstalled
    $hasAuthService = Test-VMwareAuthService
    $isFinalSuccess = $isSuccess -or $isDetected -or $hasAuthService

    if ($isFinalSuccess) {
        Log-VMwareAuthServiceStatus
        Write-Log "VMware installed successfully." -Level "success"
        Invoke-DbRecord -Action "record-success" -ExtraArgs @("package", "vmware", "17.5.2", "VMware Workstation installed")
    } else {
        Write-FileError -FilePath $targetDir -Operation "install" -Reason "VMware installation failed across all tiers" -Module "VMwareInstaller"
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
