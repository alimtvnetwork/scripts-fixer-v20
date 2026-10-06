Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repoDir = Split-Path -Parent $scriptDir
$sharedDir = Join-Path $repoDir "scripts\shared"

$loggingPath = Join-Path $sharedDir "logging.ps1"
$hasLogging = Test-Path $loggingPath

if ($hasLogging) {
    . $loggingPath
}

function Invoke-SafeFileError {
    param([hashtable]$ErrorParams)

    $filePath = if ([string]::IsNullOrWhiteSpace($ErrorParams.FilePath)) { "UnknownFile" } else { $ErrorParams.FilePath }
    $hasFileError = $null -ne (Get-Command Write-FileError -ErrorAction SilentlyContinue)

    if ($hasFileError) {
        Write-FileError -FilePath $filePath -Operation $ErrorParams.Operation -Reason $ErrorParams.Reason -Module "e2e-ai-ui-install"

        return
    }

    Write-Error "[$($ErrorParams.Operation)] $($filePath): $($ErrorParams.Reason)"

    return
}

function Resolve-FirstExistingPath {
    param([string[]]$CandidatePaths)

    foreach ($path in $CandidatePaths) {
        $hasPath = -not [string]::IsNullOrWhiteSpace($path)
        $isExisting = $hasPath -and (Test-Path $path)

        if ($isExisting) {
            return $path
        }
    }

    return $null
}

function Get-DesktopDirectories {
    $dirs = [System.Collections.Generic.List[string]]::new()
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $hasDesktopPath = -not [string]::IsNullOrWhiteSpace($desktopPath)

    if ($hasDesktopPath) {
        $dirs.Add($desktopPath) | Out-Null
    }

    $userDesktop = Join-Path $env:USERPROFILE "Desktop"
    $hasUserDesktop = -not [string]::IsNullOrWhiteSpace($userDesktop)

    if ($hasUserDesktop) {
        $dirs.Add($userDesktop) | Out-Null
    }

    $adminDesktop = "C:\Users\Administrator\Desktop"
    $hasAdmin = Test-Path $adminDesktop

    if ($hasAdmin) {
        $dirs.Add($adminDesktop) | Out-Null
    }

    $hasPublic = -not [string]::IsNullOrWhiteSpace($env:PUBLIC)

    if ($hasPublic) {
        $dirs.Add((Join-Path $env:PUBLIC "Desktop")) | Out-Null
    }

    return $dirs.ToArray()
}

function Get-StartMenuDirectories {
    $dirs = [System.Collections.Generic.List[string]]::new()
    $programsPath = [Environment]::GetFolderPath("Programs")
    $hasProgramsPath = -not [string]::IsNullOrWhiteSpace($programsPath)

    if ($hasProgramsPath) {
        $dirs.Add($programsPath) | Out-Null
    }

    $hasAppData = -not [string]::IsNullOrWhiteSpace($env:APPDATA)

    if ($hasAppData) {
        $dirs.Add((Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs")) | Out-Null
    }

    $commonPrograms = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    $hasCommon = Test-Path $commonPrograms

    if ($hasCommon) {
        $dirs.Add($commonPrograms) | Out-Null
    }

    return $dirs.ToArray()
}

function Resolve-ExistingShortcut {
    param([hashtable]$SearchParams)

    $candidates = [System.Collections.Generic.List[string]]::new()

    foreach ($dir in $SearchParams.Directories) {
        $hasDir = -not [string]::IsNullOrWhiteSpace($dir)

        if (-not $hasDir) {
            continue
        }

        foreach ($name in $SearchParams.FileNames) {
            $hasName = -not [string]::IsNullOrWhiteSpace($name)

            if (-not $hasName) {
                continue
            }

            $candidates.Add((Join-Path $dir $name)) | Out-Null
        }
    }

    $resolved = Resolve-FirstExistingPath -CandidatePaths $candidates.ToArray()

    return $resolved
}

function Test-ShortcutProperties {
    param([string]$ShortcutPath)

    $hasFile = -not [string]::IsNullOrWhiteSpace($ShortcutPath) -and (Test-Path $ShortcutPath)

    if (-not $hasFile) {
        return @{ IsSuccess = $false; Reason = "Shortcut does not exist" }
    }

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($ShortcutPath)
        $targetPath = $shortcut.TargetPath
        $workDir = $shortcut.WorkingDirectory
        $iconLocation = $shortcut.IconLocation
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null

        $hasTarget = -not [string]::IsNullOrWhiteSpace($targetPath) -and (Test-Path $targetPath)
        $hasWorkDir = -not [string]::IsNullOrWhiteSpace($workDir)
        $isValid = $hasTarget -and $hasWorkDir

        return @{ IsSuccess = $isValid; TargetPath = $targetPath; WorkingDirectory = $workDir; IconLocation = $iconLocation }
    } catch {
        return @{ IsSuccess = $false; Reason = $_.Exception.Message }
    }
}

function Test-VMwareWorkstationDirectory {
    $x86ProgramFiles = ${env:ProgramFiles(x86)}
    $candidatePaths = @(
        (Join-Path $x86ProgramFiles "VMware\VMware Workstation\vmware.exe"),
        (Join-Path $env:ProgramFiles "VMware\VMware Workstation\vmware.exe"),
        (Join-Path $env:ProgramFiles "VMware\VMware Tools\VMwareToolboxCmd.exe"),
        "C:\Program Files\VMware\VMware Tools\VMwareToolboxCmd.exe"
    )
    $resolvedExe = Resolve-FirstExistingPath -CandidatePaths $candidatePaths
    $hasExe = -not [string]::IsNullOrWhiteSpace($resolvedExe)

    if (-not $hasExe) {
        $err = @{ FilePath = "vmware.exe"; Operation = "validate"; Reason = "Neither VMware Workstation nor VMware Tools found" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; Directory = $null; Path = $null; IsGuest = $false }
    }

    $installDir = Split-Path -Parent $resolvedExe
    $isGuest = $resolvedExe -match "VMwareToolboxCmd\.exe"

    return @{ IsSuccess = $true; Directory = $installDir; Path = $resolvedExe; IsGuest = $isGuest }
}

function Test-VMwareEssentialBinaries {
    param([string]$InstallDirectory)

    $hasDir = -not [string]::IsNullOrWhiteSpace($InstallDirectory) -and (Test-Path $InstallDirectory)

    if (-not $hasDir) {
        return @{ IsSuccess = $false; Reason = "VMware directory missing" }
    }

    $vmwareExe = Join-Path $InstallDirectory "vmware.exe"
    $vmrunExe  = Join-Path $InstallDirectory "vmrun.exe"
    $hasVmware = Test-Path $vmwareExe
    $hasVmrun  = Test-Path $vmrunExe
    $isWorkstation = $hasVmware -and $hasVmrun

    $toolsExe = Join-Path $InstallDirectory "VMwareToolboxCmd.exe"
    $hasTools = Test-Path $toolsExe

    $isAllPresent = $isWorkstation -or $hasTools

    return @{ IsSuccess = $isAllPresent; HasVmware = $hasVmware; HasVmrun = $hasVmrun; HasTools = $hasTools }
}

function Test-VMwareVersionIntegrity {
    param([string]$ExecutablePath)

    $hasExe = -not [string]::IsNullOrWhiteSpace($ExecutablePath) -and (Test-Path $ExecutablePath)

    if (-not $hasExe) {
        $err = @{ FilePath = "$ExecutablePath"; Operation = "validate"; Reason = "VMware executable path invalid" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; FileVersion = $null; ProductVersion = $null }
    }

    $versionInfo = (Get-Item $ExecutablePath).VersionInfo
    $hasFileVersion = -not [string]::IsNullOrWhiteSpace($versionInfo.FileVersion)
    $hasProductVersion = -not [string]::IsNullOrWhiteSpace($versionInfo.ProductVersion)
    $hasValidVersion = $hasFileVersion -and $hasProductVersion

    if (-not $hasValidVersion) {
        $err = @{ FilePath = $ExecutablePath; Operation = "validate"; Reason = "VMware executable version info missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; FileVersion = $versionInfo.FileVersion; ProductVersion = $versionInfo.ProductVersion }
    }

    return @{ IsSuccess = $true; FileVersion = $versionInfo.FileVersion; ProductVersion = $versionInfo.ProductVersion }
}

function Test-VMwareAuthServiceStatus {
    $authSvc = Get-Service -Name "VMAuthdService" -ErrorAction SilentlyContinue
    $hasAuthSvc = ($null -ne $authSvc) -and ($authSvc.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running)

    if ($hasAuthSvc) {
        return @{ IsSuccess = $true; Status = $authSvc.Status.ToString(); Service = "VMAuthdService" }
    }

    $toolsSvc = Get-Service -Name "VMTools" -ErrorAction SilentlyContinue
    $hasToolsSvc = ($null -ne $toolsSvc) -and ($toolsSvc.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running)

    if ($hasToolsSvc) {
        return @{ IsSuccess = $true; Status = $toolsSvc.Status.ToString(); Service = "VMTools" }
    }

    $vm3dSvc = Get-Service -Name "VM3DService" -ErrorAction SilentlyContinue
    $hasVm3dSvc = ($null -ne $vm3dSvc) -and ($vm3dSvc.Status -eq [System.ServiceProcess.ServiceControllerStatus]::Running)

    if ($hasVm3dSvc) {
        return @{ IsSuccess = $true; Status = $vm3dSvc.Status.ToString(); Service = "VM3DService" }
    }

    return @{ IsSuccess = $false; Status = "NotInstalledOrRunning" }
}

function Test-ClaudeDefaultDirectory {
    $claudePaths = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Claude\Claude.exe"),
        (Join-Path $env:LOCALAPPDATA "Programs\Claude\claude.exe"),
        (Join-Path $env:LOCALAPPDATA "AnthropicClaude\claude.exe"),
        (Join-Path $env:ProgramFiles "Anthropic\Claude\Claude.exe")
    )
    $resolvedApp = Resolve-FirstExistingPath -CandidatePaths $claudePaths
    $isAppFound = -not [string]::IsNullOrWhiteSpace($resolvedApp)

    if (-not $isAppFound) {
        $err = @{ FilePath = "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"; Operation = "validate"; Reason = "Claude GUI executable missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; Path = $null }
    }

    return @{ IsSuccess = $true; Path = $resolvedApp }
}

function Test-ClaudeDesktopShortcutCOM {
    $dirs = Get-DesktopDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("Claude Code UI.lnk", "Claude Code.lnk", "Claude.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasShortcut = -not [string]::IsNullOrWhiteSpace($shortcut)

    if (-not $hasShortcut) {
        return @{ IsSuccess = $false; ShortcutPath = $null }
    }

    $comResult = Test-ShortcutProperties -ShortcutPath $shortcut

    return @{ IsSuccess = $comResult.IsSuccess; ShortcutPath = $shortcut }
}

function Test-ClaudeStartMenuShortcutCOM {
    $dirs = Get-StartMenuDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("Claude Code UI.lnk", "Claude Code.lnk", "Claude.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasShortcut = -not [string]::IsNullOrWhiteSpace($shortcut)

    if (-not $hasShortcut) {
        return @{ IsSuccess = $false; ShortcutPath = $null }
    }

    $comResult = Test-ShortcutProperties -ShortcutPath $shortcut

    return @{ IsSuccess = $comResult.IsSuccess; ShortcutPath = $shortcut }
}

function Get-NamedProcessMetrics {
    param([string]$ProcessName)

    $procs = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    $count = if ($null -ne $procs) { @($procs).Count } else { 0 }
    $totalMb = 0.0

    if ($null -ne $procs) {
        foreach ($p in $procs) {
            $totalMb += ($p.WorkingSet64 / 1MB)
        }
    }

    return @{ Count = $count; TotalWorkingSetMB = [math]::Round($totalMb, 2) }
}

function Stop-NamedProcesses {
    param([string]$ProcessName)

    $procs = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue

    if ($null -ne $procs) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
    }
}

function Test-LaunchClaudeApplication {
    param([string]$ExecutablePath)

    $hasExe = -not [string]::IsNullOrWhiteSpace($ExecutablePath) -and (Test-Path $ExecutablePath)

    if (-not $hasExe) {
        return @{ IsSuccess = $false; Reason = "Executable not found" }
    }

    $isValid = $false

    try {
        $proc = Start-Process -FilePath $ExecutablePath -PassThru
        Start-Sleep -Seconds 2

        $metrics = Get-NamedProcessMetrics -ProcessName "Claude"
        $hasHealthyTree = ($metrics.Count -ge 1) -and ($metrics.TotalWorkingSetMB -ge 30)
        $isValid = $hasHealthyTree
    } catch {
        $isValid = $false
    } finally {
        Stop-NamedProcesses -ProcessName "Claude"
    }

    return @{ IsSuccess = $isValid }
}

function Test-CodexDefaultDirectory {
    $codexExe = Join-Path $env:LOCALAPPDATA "Programs\Codex\Codex.exe"
    $hasCodexExe = Test-Path $codexExe

    if (-not $hasCodexExe) {
        $err = @{ FilePath = $codexExe; Operation = "validate"; Reason = "Codex.exe missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; Path = $null }
    }

    return @{ IsSuccess = $true; Path = $codexExe }
}

function Test-CodexDesktopShortcutCOM {
    $dirs = Get-DesktopDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("Codex UI.lnk", "Codex.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasShortcut = -not [string]::IsNullOrWhiteSpace($shortcut)

    if (-not $hasShortcut) {
        return @{ IsSuccess = $false; ShortcutPath = $null }
    }

    $comResult = Test-ShortcutProperties -ShortcutPath $shortcut

    return @{ IsSuccess = $comResult.IsSuccess; ShortcutPath = $shortcut }
}

function Test-CodexStartMenuShortcutCOM {
    $dirs = Get-StartMenuDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("Codex UI.lnk", "Codex.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasShortcut = -not [string]::IsNullOrWhiteSpace($shortcut)

    if (-not $hasShortcut) {
        return @{ IsSuccess = $false; ShortcutPath = $null }
    }

    $comResult = Test-ShortcutProperties -ShortcutPath $shortcut

    return @{ IsSuccess = $comResult.IsSuccess; ShortcutPath = $shortcut }
}

function Test-LaunchCodexApplication {
    param([string]$ExecutablePath)

    $hasExe = -not [string]::IsNullOrWhiteSpace($ExecutablePath) -and (Test-Path $ExecutablePath)

    if (-not $hasExe) {
        return @{ IsSuccess = $false; Reason = "Executable not found" }
    }

    $isValid = $false

    try {
        $proc = Start-Process -FilePath $ExecutablePath -PassThru
        Start-Sleep -Milliseconds 1200
        $proc.Refresh()

        $isAlive = -not $proc.HasExited
        $isTitleMatch = $proc.MainWindowTitle -eq "Codex AI Coding UI"
        $isValid = $isAlive -and $isTitleMatch
    } catch {
        $isValid = $false
    } finally {
        Stop-NamedProcesses -ProcessName "Codex"
    }

    return @{ IsSuccess = $isValid }
}

function Test-ClaudeDisambiguation {
    $candidates = @(
        (Join-Path $env:USERPROFILE ".claude\bin"),
        (Join-Path $env:LOCALAPPDATA "Programs\Claude")
    )

    $hasUiLaunch = $false
    $hasCliIntact = $false

    foreach ($dir in $candidates) {
        $uiShim = Join-Path $dir "claude-ui.cmd"
        $cliShim = Join-Path $dir "claude.cmd"

        if ((Test-Path $uiShim) -and ((Get-Content -Path $uiShim -Raw) -match "claude\.exe")) {
            $hasUiLaunch = $true
        }

        if ((Test-Path $cliShim) -and ((Get-Content -Path $cliShim -Raw) -match "claude")) {
            $hasCliIntact = $true
        }
    }

    $isDisambiguated = $hasUiLaunch -and $hasCliIntact

    return @{ IsSuccess = $isDisambiguated; HasUi = $hasUiLaunch; HasCli = $hasCliIntact }
}

function Test-CodexDisambiguation {
    $candidates = @(
        (Join-Path $env:USERPROFILE ".codex\bin\codex-ui.cmd"),
        (Join-Path $env:LOCALAPPDATA "Programs\Codex\codex-ui.cmd")
    )

    foreach ($shimPath in $candidates) {
        $hasShim = Test-Path $shimPath

        if ($hasShim) {
            $content = Get-Content -Path $shimPath -Raw
            $isGuiLaunch = $content -match "start\s+" -and $content -match "Codex\.exe"

            if ($isGuiLaunch) {
                return @{ IsSuccess = $true; ShimPath = $shimPath }
            }
        }
    }

    return @{ IsSuccess = $false; ShimPath = $null }
}

function Test-PlotCodeInstallation {
    $binDir = Join-Path $env:USERPROFILE ".plotcode\bin"
    $uiShim = Join-Path $binDir "plotcode-ui.cmd"
    $cliShim = Join-Path $binDir "plotcode.cmd"
    $hasUiShim = Test-Path $uiShim
    $hasCliShim = Test-Path $cliShim

    $dirs = Get-DesktopDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("PlotCode UI.lnk", "PlotCode.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasShortcut = -not [string]::IsNullOrWhiteSpace($shortcut)

    $isInstalled = $hasUiShim -and $hasCliShim -and $hasShortcut

    return @{
        IsSuccess = $isInstalled
        HasUiShim = $hasUiShim
        HasCliShim = $hasCliShim
        HasShortcut = $hasShortcut
    }
}

function Test-ScriptSyntaxValid {
    param([string]$ScriptPath)

    $hasScript = -not [string]::IsNullOrWhiteSpace($ScriptPath) -and (Test-Path $ScriptPath)

    if (-not $hasScript) {
        return @{ IsSuccess = $false; Reason = "Script not found: $ScriptPath" }
    }

    $tokens = $null
    $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($ScriptPath, [ref]$tokens, [ref]$errors) | Out-Null
    $hasNoErrors = ($errors.Count -eq 0)

    return @{ IsSuccess = $hasNoErrors; ErrorCount = $errors.Count }
}

function Test-UninstallLifecycleAndSyntax {
    param([string]$RepoRoot)

    $scripts = @(
        (Join-Path $RepoRoot "scripts\66-install-vmware\uninstall.ps1"),
        (Join-Path $RepoRoot "scripts\78-install-codex\uninstall.ps1"),
        (Join-Path $RepoRoot "scripts\79-install-plotcode\uninstall.ps1"),
        (Join-Path $RepoRoot "scripts\80-install-claude-code\uninstall.ps1")
    )

    foreach ($s in $scripts) {
        $result = Test-ScriptSyntaxValid -ScriptPath $s

        if (-not $result.IsSuccess) {
            return @{ IsSuccess = $false; FailedScript = $s }
        }
    }

    return @{ IsSuccess = $true }
}

function Write-CheckResult {
    param(
        [int]$StepNumber,
        [string]$Description,
        [bool]$IsSuccess
    )

    $statusColor = if ($IsSuccess) { "Green" } else { "Red" }
    Write-Host "  [ CHECK $($StepNumber.ToString("00")) ] $Description`: $IsSuccess" -ForegroundColor $statusColor

    return
}

function Run-AiUiVerificationSuite {
    Write-Host "`n=== Live 16-Point Windows Server E2E Verification Suite ===" -ForegroundColor Cyan

    $vmDirResult = Test-VMwareWorkstationDirectory
    Write-CheckResult -StepNumber 1 -Description "VMware installation directory" -IsSuccess $vmDirResult.IsSuccess

    $vmBinResult = Test-VMwareEssentialBinaries -InstallDirectory $vmDirResult.Directory
    Write-CheckResult -StepNumber 2 -Description "VMware essential binaries   " -IsSuccess $vmBinResult.IsSuccess

    $vmVerResult = Test-VMwareVersionIntegrity -ExecutablePath $vmDirResult.Path
    Write-CheckResult -StepNumber 3 -Description "VMware version integrity    " -IsSuccess $vmVerResult.IsSuccess

    $vmAuthResult = Test-VMwareAuthServiceStatus
    Write-CheckResult -StepNumber 4 -Description "VMware service status       " -IsSuccess $vmAuthResult.IsSuccess

    $claudeDirResult = Test-ClaudeDefaultDirectory
    Write-CheckResult -StepNumber 5 -Description "Claude UI default directory " -IsSuccess $claudeDirResult.IsSuccess

    $claudeDeskResult = Test-ClaudeDesktopShortcutCOM
    Write-CheckResult -StepNumber 6 -Description "Claude Code UI desktop link " -IsSuccess $claudeDeskResult.IsSuccess

    $claudeMenuResult = Test-ClaudeStartMenuShortcutCOM
    Write-CheckResult -StepNumber 7 -Description "Claude Code UI start menu   " -IsSuccess $claudeMenuResult.IsSuccess

    $claudeLaunchResult = Test-LaunchClaudeApplication -ExecutablePath $claudeDirResult.Path
    Write-CheckResult -StepNumber 8 -Description "Claude UI GUI live launch   " -IsSuccess $claudeLaunchResult.IsSuccess

    $codexDirResult = Test-CodexDefaultDirectory
    Write-CheckResult -StepNumber 9 -Description "Codex UI default directory  " -IsSuccess $codexDirResult.IsSuccess

    $codexDeskResult = Test-CodexDesktopShortcutCOM
    Write-CheckResult -StepNumber 10 -Description "Codex UI desktop link       " -IsSuccess $codexDeskResult.IsSuccess

    $codexMenuResult = Test-CodexStartMenuShortcutCOM
    Write-CheckResult -StepNumber 11 -Description "Codex UI start menu         " -IsSuccess $codexMenuResult.IsSuccess

    $codexLaunchResult = Test-LaunchCodexApplication -ExecutablePath $codexDirResult.Path
    Write-CheckResult -StepNumber 12 -Description "Codex UI GUI live launch    " -IsSuccess $codexLaunchResult.IsSuccess

    $claudeDisResult = Test-ClaudeDisambiguation
    Write-CheckResult -StepNumber 13 -Description "Claude CLI/UI disambiguation" -IsSuccess $claudeDisResult.IsSuccess

    $codexDisResult = Test-CodexDisambiguation
    Write-CheckResult -StepNumber 14 -Description "Codex CLI/UI disambiguation " -IsSuccess $codexDisResult.IsSuccess

    $plotCodeResult = Test-PlotCodeInstallation
    Write-CheckResult -StepNumber 15 -Description "PlotCode UI installation    " -IsSuccess $plotCodeResult.IsSuccess

    $uninstallResult = Test-UninstallLifecycleAndSyntax -RepoRoot $repoDir
    Write-CheckResult -StepNumber 16 -Description "Uninstall lifecycle & syntax" -IsSuccess $uninstallResult.IsSuccess

    $isAllPass = $vmDirResult.IsSuccess -and $vmBinResult.IsSuccess -and $vmVerResult.IsSuccess -and `
        $vmAuthResult.IsSuccess -and $claudeDirResult.IsSuccess -and $claudeDeskResult.IsSuccess -and `
        $claudeMenuResult.IsSuccess -and $claudeLaunchResult.IsSuccess -and $codexDirResult.IsSuccess -and `
        $codexDeskResult.IsSuccess -and $codexMenuResult.IsSuccess -and $codexLaunchResult.IsSuccess -and `
        $claudeDisResult.IsSuccess -and $codexDisResult.IsSuccess -and $plotCodeResult.IsSuccess -and `
        $uninstallResult.IsSuccess

    if ($isAllPass) {
        Write-Host "`n[PASSED] All 16 E2E live checks passed successfully!`n" -ForegroundColor Green

        exit 0
    }

    Write-Host "`n[FAILED] One or more verification checks failed.`n" -ForegroundColor Red

    exit 1
}

Run-AiUiVerificationSuite
