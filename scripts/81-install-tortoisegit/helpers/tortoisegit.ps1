# --------------------------------------------------------------------------
#  Helper: Install TortoiseGit 2.4.0.2 via Chocolatey or Direct MSI
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

function Get-TortoiseGitExecutableList {
    return @(
        "$env:ProgramFiles\TortoiseGit\bin\TortoiseGitProc.exe",
        "${env:ProgramFiles(x86)}\TortoiseGit\bin\TortoiseGitProc.exe"
    )
}

function Get-TortoiseGitPath {
    $pathList = Get-TortoiseGitExecutableList

    foreach ($p in $pathList) {

        if (Test-Path -LiteralPath $p) {
            return $p
        }
    }

    $cmd = Get-Command "TortoiseGitProc.exe" -ErrorAction SilentlyContinue

    if ($null -ne $cmd) {
        return $cmd.Source
    }

    return $null
}

function Test-IsTortoiseGitInstalled {
    $tgitExe = Get-TortoiseGitPath
    $isFound = -not [string]::IsNullOrWhiteSpace($tgitExe)

    return $isFound
}

function Invoke-TortoiseGitMsi {
    param(
        [Parameter(Mandatory)]
        [string]$MsiPath
    )

    $msiArgs = @("/i", "`"$MsiPath`"", "/quiet", "/qn", "/norestart", "REBOOT=ReallySuppress")
    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru -NoNewWindow
    $isSuccessCode = $proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010

    return $isSuccessCode
}

function Extract-TortoiseGitMsiFromNupkg {
    param(
        [Parameter(Mandatory)]
        [string]$NupkgPath,

        [Parameter(Mandatory)]
        [string]$ExtractDir
    )

    $is64Bit = [Environment]::Is64BitOperatingSystem
    $targetMsiName = if ($is64Bit) { "TortoiseGit-2.4.0.2-64bit_x64.msi" } else { "TortoiseGit-2.4.0.2-32bit_x32.msi" }

    if (-not (Test-Path -LiteralPath $ExtractDir)) {
        New-Item -ItemType Directory -Path $ExtractDir -Force | Out-Null
    }

    Expand-Archive -LiteralPath $NupkgPath -DestinationPath $ExtractDir -Force

    $resolvedMsi = Join-Path (Join-Path $ExtractDir "tools") $targetMsiName

    if (-not (Test-Path -LiteralPath $resolvedMsi)) {
        Write-FileError -FilePath $resolvedMsi -Operation "Extract" -Reason "Target MSI missing from nupkg tools directory"
        return $null
    }

    return $resolvedMsi
}

function Install-TortoiseGitDirect {
    param(
        [Parameter(Mandatory)]
        [object]$WaConfig,

        [Parameter(Mandatory)]
        [object]$LogMessages
    )

    $tempDir = Join-Path $env:TEMP "TortoiseGitInstall"
    $nupkgPath = Join-Path $tempDir "TortoiseGit.2.4.0.2.nupkg.zip"

    try {
        if (-not (Test-Path -LiteralPath $tempDir)) {
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        }

        Write-Log $LogMessages.messages.downloading -Level "info"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $WaConfig.nupkgUrl -OutFile $nupkgPath -UseBasicParsing

        Write-Log $LogMessages.messages.extracting -Level "info"
        $msiFile = Extract-TortoiseGitMsiFromNupkg -NupkgPath $nupkgPath -ExtractDir $tempDir

        if ($null -eq $msiFile) {
            return $false
        }

        Write-Log $LogMessages.messages.msiInstalling -Level "info"
        $isInstalled = Invoke-TortoiseGitMsi -MsiPath $msiFile

        return $isInstalled
    } catch {
        Write-FileError -FilePath $nupkgPath -Operation "DownloadAndExtract" -Reason "$_"
        return $false
    } finally {

        if (Test-Path -LiteralPath $tempDir) {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

function Install-TortoiseGit {
    param(
        [Parameter(Mandatory)]
        [object]$WaConfig,

        [Parameter(Mandatory)]
        [object]$LogMessages
    )

    $isAlreadyInstalled = Test-IsTortoiseGitInstalled

    if ($isAlreadyInstalled) {
        Write-Log $LogMessages.messages.found -Level "info"
        return $true
    }

    Write-Log $LogMessages.messages.notFound -Level "info"

    $isChocoAvailable = Get-Command "choco.exe" -ErrorAction SilentlyContinue
    $isInstalled = $false

    if ($null -ne $isChocoAvailable) {
        Write-Log $LogMessages.messages.installing -Level "info"
        $isInstalled = Install-ChocoPackage -PackageName $WaConfig.chocoPackage -Version $WaConfig.version
    }

    if (-not $isInstalled) {
        $isInstalled = Install-TortoiseGitDirect -WaConfig $WaConfig -LogMessages $LogMessages
    }

    if ($isInstalled) {
        Save-InstalledRecord -Name "tortoisegit" -Version $WaConfig.version
        return $true
    }

    return $false
}

function Uninstall-TortoiseGit {
    param(
        [Parameter(Mandatory)]
        [object]$WaConfig,

        [Parameter(Mandatory)]
        [object]$LogMessages
    )

    Write-Log $LogMessages.messages.uninstalling -Level "info"

    $isChocoAvailable = Get-Command "choco.exe" -ErrorAction SilentlyContinue

    if ($null -ne $isChocoAvailable) {
        $isRemoved = Uninstall-ChocoPackage -PackageName $WaConfig.chocoPackage

        if ($isRemoved) {
            Purge-InstalledRecord -Name "tortoisegit"
            Write-Log $LogMessages.messages.uninstallSuccess -Level "success"
            return $true
        }
    }

    Purge-InstalledRecord -Name "tortoisegit"
    Write-Log $LogMessages.messages.uninstallComplete -Level "info"

    return $true
}
