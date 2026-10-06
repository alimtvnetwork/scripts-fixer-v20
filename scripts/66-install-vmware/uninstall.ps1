# --------------------------------------------------------------------------
#  Script 66 -- Uninstall VMware Workstation/Player
# --------------------------------------------------------------------------
param(
    [Parameter(Position = 0)]
    [string]$Command = "uninstall"
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

function Stop-VMwareServiceByName {
    param([string]$ServiceName)

    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    $hasService = $null -ne $service

    if (-not $hasService) {
        return
    }

    $isRunning = $service.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running

    if (-not $isRunning) {
        return
    }

    Write-Log "Stopping service $ServiceName..." -Level "info"
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
}

function Stop-VMwareServices {
    $serviceNames = @("VMAuthdService", "VMnetDHCP", "VMware NAT Service", "VMUSBArbService")

    foreach ($name in $serviceNames) {
        Stop-VMwareServiceByName -ServiceName $name
    }
}

function Get-RegistryUninstallPaths {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    return $paths
}

function Test-VMwareDisplayName {
    param([string]$DisplayName)

    $isMatch = $DisplayName -like "*VMware Workstation*" -or $DisplayName -like "*VMware Player*"

    return $isMatch
}

function Get-VMwareUninstallCommandFromKey {
    param([PSCustomObject]$Item)

    $hasQuiet = -not [string]::IsNullOrWhiteSpace($Item.QuietUninstallString)

    if ($hasQuiet) {
        return $Item.QuietUninstallString
    }

    $hasUninstall = -not [string]::IsNullOrWhiteSpace($Item.UninstallString)

    if ($hasUninstall) {
        return $Item.UninstallString
    }

    return ""
}

function Find-UninstallCommandInPath {
    param([string]$RegistryPath)

    $items = Get-ItemProperty $RegistryPath -ErrorAction SilentlyContinue

    foreach ($item in $items) {
        $hasName = $null -ne $item.DisplayName -and (Test-VMwareDisplayName -DisplayName $item.DisplayName)

        if ($hasName) {
            $cmd = Get-VMwareUninstallCommandFromKey -Item $item

            return $cmd
        }
    }

    return ""
}

function Find-VMwareUninstallCommand {
    $paths = Get-RegistryUninstallPaths

    foreach ($p in $paths) {
        $cmd = Find-UninstallCommandInPath -RegistryPath $p
        $hasCmd = -not [string]::IsNullOrWhiteSpace($cmd)

        if ($hasCmd) {
            return $cmd
        }
    }

    return ""
}

function Invoke-MsiSilentUninstall {
    param([string]$MsiGuid)

    Write-Log "Executing MSI silent uninstallation for $MsiGuid..." -Level "info"
    $msiArgs = "/x `"$MsiGuid`" /qn REBOOT=ReallySuppress /norestart"
    $proc = Start-Process -FilePath "msiexec.exe" -ArgumentList $msiArgs -Wait -PassThru
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}

function Invoke-RawUninstallCommand {
    param([string]$CommandString)

    Write-Log "Executing raw uninstall command: $CommandString" -Level "info"
    $cleanCmd = $CommandString.Trim()
    $hasMsi = $cleanCmd -match '(?i)msiexec(?:\.exe)?\s+/[ix]\{([0-9a-f\-]+)\}'

    if ($hasMsi) {
        $guid = "{$($Matches[1])}"
        $isMsiSuccess = Invoke-MsiSilentUninstall -MsiGuid $guid

        return $isMsiSuccess
    }

    $proc = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$cleanCmd /s /qn`"" -Wait -PassThru
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}

function Has-Winget {
    $wingetCmd = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    $hasWinget = $null -ne $wingetCmd

    return $hasWinget
}

function Uninstall-VMwareViaWinget {
    $hasWinget = Has-Winget

    if (-not $hasWinget) {
        return $false
    }

    Write-Log "Attempting uninstall via winget..." -Level "info"
    $wingetArgs = @("uninstall", "VMware.WorkstationPro", "--silent", "--accept-source-agreements")
    $proc = Start-Process -FilePath "winget.exe" -ArgumentList $wingetArgs -Wait -PassThru -NoNewWindow
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}

function Has-Chocolatey {
    $chocoCmd = Get-Command "choco.exe" -ErrorAction SilentlyContinue
    $hasChoco = $null -ne $chocoCmd

    return $hasChoco
}

function Uninstall-VMwareViaChocoPackage {
    param([string]$PackageName)

    Write-Log "Attempting uninstall via choco package $PackageName..." -Level "info"
    $proc = Start-Process -FilePath "choco.exe" -ArgumentList @("uninstall", $PackageName, "--yes", "--remove-dependencies") -Wait -PassThru -NoNewWindow
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}

function Uninstall-VMwareViaChoco {
    $hasChoco = Has-Chocolatey

    if (-not $hasChoco) {
        return $false
    }

    $isWsDone = Uninstall-VMwareViaChocoPackage -PackageName "vmwareworkstation"

    if ($isWsDone) {
        return $true
    }

    $isPlayerDone = Uninstall-VMwareViaChocoPackage -PackageName "vmware-workstation-player"

    return $isPlayerDone
}

function Remove-TempFileByPattern {
    param([string]$FilePath)

    $hasFile = Test-Path $FilePath

    if (-not $hasFile) {
        return
    }

    try {
        Remove-Item -Path $FilePath -Force -Recurse -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -FilePath $FilePath -Operation "remove" -Reason $_.Exception.Message -Module "VMwareUninstaller"
    }
}

function Clean-VMwareTempFiles {
    $tempList = @(
        (Join-Path $env:TEMP "vmware-installer.exe"),
        (Join-Path $env:TEMP "vmware*.exe"),
        (Join-Path $env:TEMP "vmware*.bundle")
    )

    foreach ($item in $tempList) {
        Remove-TempFileByPattern -FilePath $item
    }
}

function Try-UninstallFromRegistry {
    $uninstallCmd = Find-VMwareUninstallCommand
    $hasCmd = -not [string]::IsNullOrWhiteSpace($uninstallCmd)

    if (-not $hasCmd) {
        return $false
    }

    $isUninstalled = Invoke-RawUninstallCommand -CommandString $uninstallCmd

    return $isUninstalled
}

function Execute-VMwareUninstallLifecycle {
    Stop-VMwareServices
    $isRegistryDone = Try-UninstallFromRegistry

    if ($isRegistryDone) {
        Clean-VMwareTempFiles

        return $true
    }

    $isWingetDone = Uninstall-VMwareViaWinget

    if ($isWingetDone) {
        Clean-VMwareTempFiles

        return $true
    }

    $isChocoDone = Uninstall-VMwareViaChoco
    Clean-VMwareTempFiles

    return $isChocoDone
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

function Get-VMwareAllCandidatePaths {
    $dirs = [System.Collections.Generic.List[string]]::new()
    Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path ${env:ProgramFiles} "VMware\VMware Workstation")
    Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path ${env:ProgramFiles} "VMware\VMware Player")
    Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path ${env:ProgramFiles} "VMware\VMware VIX")

    $x86Root = ${env:ProgramFiles(x86)}
    $hasX86Root = -not [string]::IsNullOrWhiteSpace($x86Root)

    if ($hasX86Root) {
        Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path $x86Root "VMware\VMware Workstation")
        Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path $x86Root "VMware\VMware Player")
        Add-CandidateDirSafe -List $dirs -DirectoryPath (Join-Path $x86Root "VMware\VMware VIX")
    }

    return $dirs.ToArray()
}

function Remove-PathFromAllScopes {
    param([string]$DirectoryPath)

    $hasValue = -not [string]::IsNullOrWhiteSpace($DirectoryPath)

    if (-not $hasValue) {
        return
    }

    $cleanDir = $DirectoryPath.TrimEnd('\', '/')
    Remove-FromMachinePath -Directory $cleanDir
    Remove-FromUserPath -Directory $cleanDir
}

function Remove-VMwareFromPath {
    $candidateDirs = Get-VMwareAllCandidatePaths

    foreach ($dir in $candidateDirs) {
        Remove-PathFromAllScopes -DirectoryPath $dir
    }

    Write-Log "VMware directories removed from Machine and User PATH." -Level "info"
}

function Remove-VMwareFromDb {
    $hasBridge = Test-Path $script:dbBridge

    if (-not $hasBridge) {
        return
    }

    try {
        $pyCmd = "import sys; sys.path.insert(0, r'$($script:sharedDir)'); import db_bridge; conn = db_bridge.get_connection(); conn.execute('DELETE FROM packages WHERE name=?', ('vmware',)); conn.execute('UPDATE install_logs SET status=\'success\', exit_code=0, ended_at=datetime(\'now\') WHERE target_name=\'vmware\' AND status=\'running\''); conn.commit(); conn.close()"
        python -c $pyCmd 2>$null
        Write-Log "VMware package record removed from database." -Level "info"
    } catch {
        Write-FileError -FilePath $script:dbBridge -Operation "delete" -Reason $_.Exception.Message -Module "VMwareUninstaller"
    }
}

function Get-VMwareTargetDirs {
    $dirs = Get-VMwareAllCandidatePaths

    return $dirs
}

function Invoke-VMwareUninstallMain {
    Write-Banner -Title "Uninstall VMware Workstation/Player"
    Initialize-Logging -ScriptName "Uninstall VMware"

    $targetDirs = Get-VMwareTargetDirs
    $targetPathStr = $targetDirs -join ", "
    $tempPath = Join-Path $env:TEMP "vmware-installer.exe"

    Write-InstallPaths `
        -Tool   "VMware Workstation/Player" `
        -Action "Uninstall" `
        -Source "Registry / Package Manager" `
        -Temp   $tempPath `
        -Target $targetPathStr

    try {
        Invoke-DbRecord -Action "record-start" -ExtraArgs @("package", "vmware", "uninstall")
        $isSuccess = Execute-VMwareUninstallLifecycle

        if ($isSuccess) {
            Remove-VMwareFromPath
            Remove-VMwareFromDb
            Write-Log "VMware uninstalled successfully." -Level "success"

            return
        }

        Write-FileError -FilePath $targetPathStr -Operation "uninstall" -Reason "No active VMware uninstaller succeeded" -Module "VMwareUninstaller"
        Write-Log "VMware uninstall did not detect active installation or uninstaller failed." -Level "warn"
        Invoke-DbRecord -Action "record-failure" -ExtraArgs @("package", "vmware", "1", "uninstall failed or not found")
    } catch {
        Write-Log "Error during VMware uninstallation: $_" -Level "error"
        Write-FileError -FilePath $targetPathStr -Operation "uninstall" -Reason $_.Exception.Message -Module "VMwareUninstaller"
        Invoke-DbRecord -Action "record-failure" -ExtraArgs @("package", "vmware", "1", "$_")
    } finally {
        $hasErrors = $script:_LogErrors.Count -gt 0
        $finalStatus = if ($hasErrors) { "fail" } else { "ok" }
        Save-LogFile -Status $finalStatus
    }
}

Invoke-VMwareUninstallMain
