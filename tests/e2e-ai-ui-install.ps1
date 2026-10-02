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
    $dirs = @(
        [Environment]::GetFolderPath("Desktop"),
        (Join-Path $env:USERPROFILE "Desktop"),
        (Join-Path $env:PUBLIC "Desktop")
    )

    return $dirs
}

function Get-StartMenuDirectories {
    $dirs = @(
        [Environment]::GetFolderPath("Programs"),
        (Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"),
        (Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs")
    )

    return $dirs
}

function Resolve-ExistingShortcut {
    param([hashtable]$SearchParams)

    $candidates = [System.Collections.Generic.List[string]]::new()
    foreach ($dir in $SearchParams.Directories) {
        foreach ($name in $SearchParams.FileNames) {
            $candidates.Add((Join-Path $dir $name)) | Out-Null
        }
    }

    $resolved = Resolve-FirstExistingPath -CandidatePaths $candidates.ToArray()

    return $resolved
}

function Test-VMwareWorkstationDirectory {
    $x86ProgramFiles = ${env:ProgramFiles(x86)}
    $candidatePaths = @(
        (Join-Path $x86ProgramFiles "VMware\VMware Workstation\vmware.exe"),
        (Join-Path $env:ProgramFiles "VMware\VMware Workstation\vmware.exe")
    )
    $resolvedPath = Resolve-FirstExistingPath -CandidatePaths $candidatePaths
    $hasResolved = -not [string]::IsNullOrWhiteSpace($resolvedPath)

    if (-not $hasResolved) {
        $errPath = Join-Path $x86ProgramFiles "VMware\VMware Workstation\vmware.exe"
        $err = @{ FilePath = $errPath; Operation = "verify-vmware-dir"; Reason = "vmware.exe missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; Path = $null }
    }

    return @{ IsSuccess = $true; Path = $resolvedPath }
}

function Test-VMwareVersionIntegrity {
    param([string]$ExecutablePath)

    $hasExe = -not [string]::IsNullOrWhiteSpace($ExecutablePath) -and (Test-Path $ExecutablePath)

    if (-not $hasExe) {
        $err = @{ FilePath = "$ExecutablePath"; Operation = "verify-vmware-version"; Reason = "vmware.exe path invalid" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; FileVersion = $null; ProductVersion = $null }
    }

    $versionInfo = (Get-Item $ExecutablePath).VersionInfo
    $hasFileVersion = -not [string]::IsNullOrWhiteSpace($versionInfo.FileVersion)
    $hasProductVersion = -not [string]::IsNullOrWhiteSpace($versionInfo.ProductVersion)
    $hasValidVersion = $hasFileVersion -and $hasProductVersion

    if (-not $hasValidVersion) {
        $err = @{ FilePath = $ExecutablePath; Operation = "verify-vmware-version"; Reason = "vmware.exe version info missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; FileVersion = $versionInfo.FileVersion; ProductVersion = $versionInfo.ProductVersion }
    }

    return @{ IsSuccess = $true; FileVersion = $versionInfo.FileVersion; ProductVersion = $versionInfo.ProductVersion }
}

function Test-ClaudeDefaultDirectory {
    $claudePaths = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Claude\Claude.exe"),
        (Join-Path $env:LOCALAPPDATA "AnthropicClaude\claude.exe"),
        (Join-Path $env:ProgramFiles "Anthropic\Claude\Claude.exe")
    )
    $resolvedApp = Resolve-FirstExistingPath -CandidatePaths $claudePaths
    $isAppFound = -not [string]::IsNullOrWhiteSpace($resolvedApp)

    if (-not $isAppFound) {
        $err = @{ FilePath = "$env:LOCALAPPDATA\Programs\Claude\Claude.exe"; Operation = "verify-claude-dir"; Reason = "Claude GUI executable missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; Path = $null }
    }

    $shimPath = Join-Path $env:USERPROFILE ".claude\bin\claude-ui.cmd"
    $hasShim = Test-Path $shimPath

    if (-not $hasShim) {
        $err = @{ FilePath = $shimPath; Operation = "verify-claude-shim"; Reason = "claude-ui.cmd missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; Path = $resolvedApp }
    }

    return @{ IsSuccess = $true; Path = $resolvedApp }
}

function Test-ClaudeDesktopShortcut {
    $dirs = Get-DesktopDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("Claude Code UI.lnk", "Claude Code.lnk", "Claude.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasFound = -not [string]::IsNullOrWhiteSpace($shortcut)

    if (-not $hasFound) {
        $err = @{ FilePath = "Desktop\Claude Code UI.lnk"; Operation = "verify-shortcut"; Reason = "Desktop shortcut missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; ShortcutPath = $null }
    }

    return @{ IsSuccess = $true; ShortcutPath = $shortcut }
}

function Test-ClaudeStartMenuShortcut {
    $dirs = Get-StartMenuDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("Claude Code UI.lnk", "Claude Code.lnk", "Claude.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasFound = -not [string]::IsNullOrWhiteSpace($shortcut)

    if (-not $hasFound) {
        $err = @{ FilePath = "StartMenu\Claude Code UI.lnk"; Operation = "verify-shortcut"; Reason = "Start Menu shortcut missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; ShortcutPath = $null }
    }

    return @{ IsSuccess = $true; ShortcutPath = $shortcut }
}

function Test-LaunchClaudeApplication {
    param([string]$ExecutablePath)

    $hasExe = -not [string]::IsNullOrWhiteSpace($ExecutablePath) -and (Test-Path $ExecutablePath)

    if (-not $hasExe) {
        $err = @{ FilePath = "$ExecutablePath"; Operation = "launch-test"; Reason = "Claude executable not found" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; ExecutablePath = $ExecutablePath }
    }

    $isLaunchSuccess = $false
    try {
        $proc = Start-Process -FilePath $ExecutablePath -ArgumentList "--version" -Wait -PassThru -NoNewWindow
        $isLaunchSuccess = ($proc.ExitCode -eq 0)
    } catch {
        $err = @{ FilePath = $ExecutablePath; Operation = "launch-test"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{ IsSuccess = $isLaunchSuccess; ExecutablePath = $ExecutablePath }
}

function Test-CodexDefaultDirectory {
    $codexExe = Join-Path $env:LOCALAPPDATA "Programs\Codex\Codex.exe"
    $hasCodexExe = Test-Path $codexExe

    if (-not $hasCodexExe) {
        $err = @{ FilePath = $codexExe; Operation = "verify-codex-dir"; Reason = "Codex.exe missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; Path = $null }
    }

    $shimPath = Join-Path $env:USERPROFILE ".codex\bin\codex-ui.cmd"
    $hasShim = Test-Path $shimPath

    if (-not $hasShim) {
        $err = @{ FilePath = $shimPath; Operation = "verify-codex-shim"; Reason = "codex-ui.cmd missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; Path = $codexExe }
    }

    return @{ IsSuccess = $true; Path = $codexExe }
}

function Test-CodexDesktopShortcut {
    $dirs = Get-DesktopDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("Codex UI.lnk", "Codex.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasFound = -not [string]::IsNullOrWhiteSpace($shortcut)

    if (-not $hasFound) {
        $err = @{ FilePath = "Desktop\Codex UI.lnk"; Operation = "verify-shortcut"; Reason = "Codex desktop shortcut missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; ShortcutPath = $null }
    }

    return @{ IsSuccess = $true; ShortcutPath = $shortcut }
}

function Test-CodexStartMenuShortcut {
    $dirs = Get-StartMenuDirectories
    $searchParams = @{ Directories = $dirs; FileNames = @("Codex UI.lnk", "Codex.lnk") }
    $shortcut = Resolve-ExistingShortcut -SearchParams $searchParams
    $hasFound = -not [string]::IsNullOrWhiteSpace($shortcut)

    if (-not $hasFound) {
        $err = @{ FilePath = "StartMenu\Codex UI.lnk"; Operation = "verify-shortcut"; Reason = "Codex Start Menu shortcut missing" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; ShortcutPath = $null }
    }

    return @{ IsSuccess = $true; ShortcutPath = $shortcut }
}

function Test-LaunchCodexApplication {
    param([string]$ExecutablePath)

    $hasExe = -not [string]::IsNullOrWhiteSpace($ExecutablePath) -and (Test-Path $ExecutablePath)

    if (-not $hasExe) {
        $err = @{ FilePath = "$ExecutablePath"; Operation = "launch-test"; Reason = "Codex executable not found" }
        Invoke-SafeFileError -ErrorParams $err

        return @{ IsSuccess = $false; ExecutablePath = $ExecutablePath }
    }

    $isLaunchSuccess = $false
    try {
        $proc = Start-Process -FilePath $ExecutablePath -PassThru -NoNewWindow
        Start-Sleep -Milliseconds 800
        $isProcessRunning = -not $proc.HasExited

        if ($isProcessRunning) {
            $isLaunchSuccess = $true
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }

        if (-not $isProcessRunning) {
            $isLaunchSuccess = ($proc.ExitCode -eq 0)
        }
    } catch {
        $err = @{ FilePath = $ExecutablePath; Operation = "launch-test"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{ IsSuccess = $isLaunchSuccess; ExecutablePath = $ExecutablePath }
}

function Write-CheckResult {
    param(
        [int]$StepNumber,
        [string]$Description,
        [bool]$IsSuccess
    )

    $statusColor = if ($IsSuccess) { "Green" } else { "Red" }
    Write-Host "  [ CHECK $StepNumber ] $Description`: $IsSuccess" -ForegroundColor $statusColor

    return
}

function Invoke-VMwareChecks {
    $dirResult = Test-VMwareWorkstationDirectory
    Write-CheckResult -StepNumber 1 -Description "VMware Workstation directory" -IsSuccess $dirResult.IsSuccess

    $verResult = Test-VMwareVersionIntegrity -ExecutablePath $dirResult.Path
    Write-CheckResult -StepNumber 2 -Description "VMware version integrity   " -IsSuccess $verResult.IsSuccess

    $isVmwarePass = $dirResult.IsSuccess -and $verResult.IsSuccess

    return @{ IsSuccess = $isVmwarePass }
}

function Invoke-ClaudeChecks {
    $dirResult = Test-ClaudeDefaultDirectory
    Write-CheckResult -StepNumber 3 -Description "Claude UI default directory " -IsSuccess $dirResult.IsSuccess

    $desktopResult = Test-ClaudeDesktopShortcut
    Write-CheckResult -StepNumber 4 -Description "Claude Code UI desktop link " -IsSuccess $desktopResult.IsSuccess

    $menuResult = Test-ClaudeStartMenuShortcut
    Write-CheckResult -StepNumber 5 -Description "Claude Code UI start menu   " -IsSuccess $menuResult.IsSuccess

    $launchResult = Test-LaunchClaudeApplication -ExecutablePath $dirResult.Path
    Write-CheckResult -StepNumber 6 -Description "Claude UI executable launch " -IsSuccess $launchResult.IsSuccess

    $isClaudePass = $dirResult.IsSuccess -and $desktopResult.IsSuccess -and $menuResult.IsSuccess -and $launchResult.IsSuccess

    return @{ IsSuccess = $isClaudePass }
}

function Invoke-CodexChecks {
    $dirResult = Test-CodexDefaultDirectory
    Write-CheckResult -StepNumber 7 -Description "Codex UI default directory  " -IsSuccess $dirResult.IsSuccess

    $desktopResult = Test-CodexDesktopShortcut
    Write-CheckResult -StepNumber 8 -Description "Codex UI desktop link       " -IsSuccess $desktopResult.IsSuccess

    $menuResult = Test-CodexStartMenuShortcut
    Write-CheckResult -StepNumber 9 -Description "Codex UI start menu         " -IsSuccess $menuResult.IsSuccess

    $launchResult = Test-LaunchCodexApplication -ExecutablePath $dirResult.Path
    Write-CheckResult -StepNumber 10 -Description "Codex UI executable launch  " -IsSuccess $launchResult.IsSuccess

    $isCodexPass = $dirResult.IsSuccess -and $desktopResult.IsSuccess -and $menuResult.IsSuccess -and $launchResult.IsSuccess

    return @{ IsSuccess = $isCodexPass }
}

function Run-AiUiVerificationSuite {
    Write-Host "`n=== Live 10-Point Windows Server E2E Verification Suite ===" -ForegroundColor Cyan

    $vmwareSuite = Invoke-VMwareChecks
    $claudeSuite = Invoke-ClaudeChecks
    $codexSuite  = Invoke-CodexChecks

    $isAllPass = $vmwareSuite.IsSuccess -and $claudeSuite.IsSuccess -and $codexSuite.IsSuccess

    if ($isAllPass) {
        Write-Host "`n[PASSED] All 10 E2E live checks passed successfully!`n" -ForegroundColor Green

        exit 0
    }

    Write-Host "`n[FAILED] One or more verification checks failed.`n" -ForegroundColor Red

    exit 1
}

Run-AiUiVerificationSuite
