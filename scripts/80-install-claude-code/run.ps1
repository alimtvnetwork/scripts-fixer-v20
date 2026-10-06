param([string]$Command = "all")
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"

$loggingPath = Join-Path $sharedDir "logging.ps1"
$hasLogging = Test-Path $loggingPath

if ($hasLogging) {
    . $loggingPath
}

$installPathsScript = Join-Path $sharedDir "install-paths.ps1"
$hasInstallPaths = Test-Path $installPathsScript

if ($hasInstallPaths) {
    . $installPathsScript
}

$pathUtilsScript = Join-Path $sharedDir "path-utils.ps1"
$hasPathUtils = Test-Path $pathUtilsScript

if ($hasPathUtils) {
    . $pathUtilsScript
}

function Invoke-SafeFileError {
    param([hashtable]$ErrorParams)

    $hasFileError = $null -ne (Get-Command Write-FileError -ErrorAction SilentlyContinue)

    if ($hasFileError) {
        Write-FileError -FilePath $ErrorParams.FilePath -Operation $ErrorParams.Operation -Reason $ErrorParams.Reason -Module "install-claude-code"

        return
    }

    Write-Error "[$($ErrorParams.Operation)] $($ErrorParams.FilePath): $($ErrorParams.Reason)"

    return
}

function Ensure-DirectoryExists {
    param([string]$TargetDirectory)

    $isTargetPresent = Test-Path $TargetDirectory

    if ($isTargetPresent) {
        return @{ IsSuccess = $true; DirectoryPath = $TargetDirectory }
    }

    try {
        New-Item -ItemType Directory -Path $TargetDirectory -Force | Out-Null
    } catch {
        $err = @{ FilePath = $TargetDirectory; Operation = "create-directory"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{
        IsSuccess = (Test-Path $TargetDirectory)
        DirectoryPath = $TargetDirectory
    }
}

function Find-ClaudeDesktopExecutable {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Claude\Claude.exe"),
        "C:\Program Files\Anthropic\Claude\Claude.exe",
        (Join-Path $env:LOCALAPPDATA "AnthropicClaude\claude.exe"),
        "C:\Users\Administrator\AppData\Local\AnthropicClaude\claude.exe"
    )

    foreach ($path in $candidates) {
        $hasPath = Test-Path $path

        if ($hasPath) {
            return @{ IsFound = $true; ExecutablePath = $path }
        }
    }

    return @{ IsFound = $false; ExecutablePath = $null }
}

function Install-ClaudeDesktopViaWinget {
    $wingetCmd = Get-Command "winget" -ErrorAction SilentlyContinue
    $hasWinget = $null -ne $wingetCmd

    if (-not $hasWinget) {
        return @{ IsSuccess = $false; Message = "winget is not available" }
    }

    Write-Host "Installing Anthropic.Claude desktop application via winget..." -ForegroundColor Cyan
    $wingetArgs = "install Anthropic.Claude --silent --accept-package-agreements --accept-source-agreements"
    $process = Start-Process -FilePath "winget.exe" -ArgumentList $wingetArgs -Wait -PassThru -NoNewWindow
    $isInstallSuccess = ($process.ExitCode -eq 0)

    return @{
        IsSuccess = $isInstallSuccess
        ExitCode = $process.ExitCode
    }
}

function Install-ClaudeDesktopViaDownload {
    param([string]$TempDirectory)

    $installerUrl = "https://downloads.claude.ai/releases/win32/x64/Claude-Setup-x64.exe"
    $installerPath = Join-Path $TempDirectory "ClaudeSetup.exe"

    try {
        Write-Host "Downloading Claude Desktop installer from $installerUrl..." -ForegroundColor Cyan
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
        Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -NoNewWindow
    } catch {
        $err = @{ FilePath = $installerPath; Operation = "download-and-execute"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    $isDownloadedAndRun = Test-Path $installerPath

    return @{
        IsSuccess = $isDownloadedAndRun
        InstallerPath = $installerPath
    }
}

function Find-SquirrelClaudeDir {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "AnthropicClaude"),
        "C:\Users\Administrator\AppData\Local\AnthropicClaude"
    )

    foreach ($dir in $candidates) {
        $exe = Join-Path $dir "claude.exe"
        $hasExe = Test-Path $exe

        if ($hasExe) {
            return $dir
        }
    }

    return $null
}

function Sync-ClaudeFiles {
    param(
        [string]$SourceDir,
        [string]$TargetDir
    )

    Ensure-DirectoryExists -TargetDirectory $TargetDir | Out-Null

    try {
        Copy-Item -Path "$SourceDir\*" -Destination $TargetDir -Recurse -Force | Out-Null
    } catch {
        $err = @{ FilePath = $TargetDir; Operation = "sync-claude-files"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{ IsSuccess = (Test-Path (Join-Path $TargetDir "claude.exe")) }
}

function Ensure-DefaultClaudeDirectory {
    $defaultClaudeDir = Join-Path $env:LOCALAPPDATA "Programs\Claude"
    $defaultClaudeExe = Join-Path $defaultClaudeDir "Claude.exe"
    $hasDefaultExe = Test-Path $defaultClaudeExe

    if ($hasDefaultExe) {
        return @{ IsSuccess = $true; TargetPath = $defaultClaudeExe }
    }

    $squirrelDir = Find-SquirrelClaudeDir
    $hasSquirrelDir = -not [string]::IsNullOrWhiteSpace($squirrelDir)

    if ($hasSquirrelDir) {
        Sync-ClaudeFiles -SourceDir $squirrelDir -TargetDir $defaultClaudeDir | Out-Null
    }

    $isDefaultReady = Test-Path $defaultClaudeExe

    return @{
        IsSuccess = $isDefaultReady
        TargetPath = $defaultClaudeExe
    }
}

function Install-ClaudeCodeNpm {
    $npmCmd = Get-Command "npm" -ErrorAction SilentlyContinue
    $hasNpm = $null -ne $npmCmd

    if (-not $hasNpm) {
        return @{ IsSuccess = $false; Message = "npm not found" }
    }

    Write-Host "Installing @anthropic-ai/claude-code via npm..." -ForegroundColor Cyan
    try {
        npm install -g @anthropic-ai/claude-code 2>$null | Out-Null
    } catch {
        Write-Host "  [ NOTE ] npm install completed with non-fatal status." -ForegroundColor DarkGray
    }

    return @{ IsSuccess = $true }
}

function Write-ClaudeShims {
    param([hashtable]$ShimParams)

    $installDir = $ShimParams.InstallDir
    $desktopExe = $ShimParams.DesktopExe
    $cliShim = Join-Path $installDir "claude.cmd"
    $uiShim  = Join-Path $installDir "claude-ui.cmd"

    $uiCmdContent = "@echo off`r`nstart `"`" `"$desktopExe`" %*`r`n"
    $cliCmdContent = "@echo off`r`nsetlocal`r`nfor /f `"tokens=*`" %%i in ('where claude 2^>nul') do (`r`n    if /i not `"%%i`"==`"%~f0`" (`r`n        `"%%i`" %*`r`n        exit /b %ERRORLEVEL%`r`n    )`r`n)`r`nnpx @anthropic-ai/claude-code %*`r`n"

    try {
        Set-Content -Path $uiShim -Value $uiCmdContent -Force
        Set-Content -Path $cliShim -Value $cliCmdContent -Force
    } catch {
        $err = @{ FilePath = $uiShim; Operation = "write-shims"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    $isUiShimReady = Test-Path $uiShim

    return @{
        IsSuccess = $isUiShimReady
        UiShim = $uiShim
    }
}

function Get-ClaudeIconLocation {
    param([string]$TargetPath)

    $defaultDir = Join-Path $env:LOCALAPPDATA "Programs\Claude"
    $appIco = Join-Path $defaultDir "app.ico"
    $hasIco = Test-Path $appIco

    if ($hasIco) {
        return $appIco
    }

    return "$TargetPath,0"
}

function Get-ShortcutWorkingDirectory {
    param([hashtable]$Params)

    $hasExplicitWorkDir = $Params.ContainsKey("WorkingDirectory") -and -not [string]::IsNullOrWhiteSpace($Params.WorkingDirectory)

    if ($hasExplicitWorkDir) {
        return $Params.WorkingDirectory
    }

    return (Split-Path -Parent $Params.TargetPath)
}

function New-ClaudeShortcut {
    param([hashtable]$ShortcutParams)

    $isShortcutCreated = $false

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($ShortcutParams.LinkPath)
        $shortcut.TargetPath = $ShortcutParams.TargetPath
        $shortcut.WorkingDirectory = Get-ShortcutWorkingDirectory -Params $ShortcutParams
        $shortcut.IconLocation = Get-ClaudeIconLocation -TargetPath $ShortcutParams.TargetPath
        $shortcut.Description = $ShortcutParams.Description
        $shortcut.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
        $isShortcutCreated = $true
    } catch {
        $err = @{ FilePath = $ShortcutParams.LinkPath; Operation = "create-shortcut"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{
        IsSuccess = $isShortcutCreated
        LinkPath = $ShortcutParams.LinkPath
    }
}

function Get-DesktopCandidates {
    $candidates = [System.Collections.Generic.List[string]]::new()
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $hasDesktopPath = -not [string]::IsNullOrWhiteSpace($desktopPath)

    if ($hasDesktopPath) {
        $candidates.Add($desktopPath) | Out-Null
    }

    $userDesktop = Join-Path $env:USERPROFILE "Desktop"
    $candidates.Add($userDesktop) | Out-Null

    $adminDesktop = "C:\Users\Administrator\Desktop"
    $hasAdminDesktop = Test-Path $adminDesktop

    if ($hasAdminDesktop) {
        $candidates.Add($adminDesktop) | Out-Null
    }

    return $candidates
}

function Get-StartMenuCandidates {
    $candidates = [System.Collections.Generic.List[string]]::new()
    $programsPath = [Environment]::GetFolderPath("Programs")
    $hasProgramsPath = -not [string]::IsNullOrWhiteSpace($programsPath)

    if ($hasProgramsPath) {
        $candidates.Add($programsPath) | Out-Null
    }

    $commonPrograms = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    $hasCommonPrograms = Test-Path $commonPrograms

    if ($hasCommonPrograms) {
        $candidates.Add($commonPrograms) | Out-Null
    }

    $userPrograms = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    $candidates.Add($userPrograms) | Out-Null

    return $candidates
}

function Update-ClaudePath {
    param([string]$InstallDir)

    Add-ToMachinePath -Directory $InstallDir | Out-Null
    Add-ToUserPath -Directory $InstallDir | Out-Null

    return @{ IsSuccess = $true; InstallDir = $InstallDir }
}

function Install-ClaudeCodeUI {
    Write-Host "Installing Claude Code UI & Desktop Application..." -ForegroundColor Cyan

    $defaultDir = Join-Path $env:LOCALAPPDATA "Programs\Claude"
    $userBinDir = Join-Path $env:USERPROFILE ".claude\bin"
    $tempDir    = Join-Path $env:TEMP "claude-ui-install"

    Ensure-DirectoryExists -TargetDirectory $userBinDir | Out-Null
    Ensure-DirectoryExists -TargetDirectory $tempDir | Out-Null

    $hasLogPaths = $null -ne (Get-Command Write-InstallPaths -ErrorAction SilentlyContinue)

    if ($hasLogPaths) {
        Write-InstallPaths -Tool "Claude Code UI" -Source "winget:Anthropic.Claude" -Temp $tempDir -Target $defaultDir
    }

    $desktopExeInfo = Find-ClaudeDesktopExecutable

    if (-not $desktopExeInfo.IsFound) {
        Install-ClaudeDesktopViaWinget | Out-Null
        $desktopExeInfo = Find-ClaudeDesktopExecutable
    }

    if (-not $desktopExeInfo.IsFound) {
        Install-ClaudeDesktopViaDownload -TempDirectory $tempDir | Out-Null
        $desktopExeInfo = Find-ClaudeDesktopExecutable
    }

    Ensure-DefaultClaudeDirectory | Out-Null
    $resolvedDefaultExe = Join-Path $defaultDir "Claude.exe"
    $hasResolvedDefault = Test-Path $resolvedDefaultExe

    if ($hasResolvedDefault) {
        $activeExe = $resolvedDefaultExe
    } else {
        $activeExe = $desktopExeInfo.ExecutablePath
    }

    Install-ClaudeCodeNpm | Out-Null

    $userShimParams = @{ InstallDir = $userBinDir; DesktopExe = $activeExe }
    $uiShimResult = Write-ClaudeShims -ShimParams $userShimParams

    $progShimParams = @{ InstallDir = $defaultDir; DesktopExe = $activeExe }
    Write-ClaudeShims -ShimParams $progShimParams | Out-Null

    $workDir = Split-Path -Parent $activeExe
    $desktopCandidates = Get-DesktopCandidates

    foreach ($candidateDir in $desktopCandidates) {
        Ensure-DirectoryExists -TargetDirectory $candidateDir | Out-Null
        $shortcutParamsUi = @{
            TargetPath = $activeExe
            WorkingDirectory = $workDir
            LinkPath = (Join-Path $candidateDir "Claude Code UI.lnk")
            Description = "Claude Code Desktop GUI Application"
        }
        New-ClaudeShortcut -ShortcutParams $shortcutParamsUi | Out-Null

        $shortcutParamsLegacy = @{
            TargetPath = $activeExe
            WorkingDirectory = $workDir
            LinkPath = (Join-Path $candidateDir "Claude Code.lnk")
            Description = "Claude Code Desktop GUI Application"
        }
        New-ClaudeShortcut -ShortcutParams $shortcutParamsLegacy | Out-Null
    }

    $startMenuCandidates = Get-StartMenuCandidates

    foreach ($menuDir in $startMenuCandidates) {
        Ensure-DirectoryExists -TargetDirectory $menuDir | Out-Null
        $menuParams = @{
            TargetPath = $activeExe
            WorkingDirectory = $workDir
            LinkPath = (Join-Path $menuDir "Claude Code UI.lnk")
            Description = "Claude Code Desktop GUI Application"
        }
        New-ClaudeShortcut -ShortcutParams $menuParams | Out-Null
    }

    Update-ClaudePath -InstallDir $userBinDir | Out-Null
    Remove-FromUserPath -Directory $defaultDir | Out-Null
    Remove-FromMachinePath -Directory $defaultDir | Out-Null

    Write-Host "Claude Code UI installed successfully (Desktop GUI + CLI)." -ForegroundColor Green

    return @{
        IsSuccess = $true
        InstallDirectory = $defaultDir
        BinDirectory = $userBinDir
        ExecutablePath = $activeExe
    }
}

Install-ClaudeCodeUI
