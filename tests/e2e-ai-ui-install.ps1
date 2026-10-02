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

function Test-ClaudeDefaultDirectory {
    $claudePaths = @(
        (Join-Path $env:LOCALAPPDATA "Programs\Claude\Claude.exe"),
        (Join-Path $env:LOCALAPPDATA "AnthropicClaude\claude.exe"),
        "C:\Program Files\Anthropic\Claude\Claude.exe"
    )

    $resolvedApp = $null
    foreach ($path in $claudePaths) {
        $isPresent = Test-Path $path

        if ($isPresent) {
            $resolvedApp = $path
            break
        }
    }

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

function Test-ClaudeDesktopShortcut {
    $desktopFolders = @(
        [Environment]::GetFolderPath("Desktop"),
        (Join-Path $env:USERPROFILE "Desktop"),
        "C:\Users\Administrator\Desktop"
    )

    $resolvedShortcut = $null
    foreach ($dir in $desktopFolders) {
        $hasDir = -not [string]::IsNullOrWhiteSpace($dir)

        if (-not $hasDir) { continue }

        $shortcutUi = Join-Path $dir "Claude Code UI.lnk"
        $hasShortcutUi = Test-Path $shortcutUi

        if ($hasShortcutUi) {
            $resolvedShortcut = $shortcutUi
            break
        }

        $shortcutLegacy = Join-Path $dir "Claude Code.lnk"
        $hasShortcutLegacy = Test-Path $shortcutLegacy

        if ($hasShortcutLegacy) {
            $resolvedShortcut = $shortcutLegacy
            break
        }
    }

    $hasFound = -not [string]::IsNullOrWhiteSpace($resolvedShortcut)

    if (-not $hasFound) {
        $err = @{ FilePath = "Desktop\Claude Code UI.lnk"; Operation = "verify-shortcut"; Reason = "Desktop shortcut missing" }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{ IsSuccess = $hasFound; ShortcutPath = $resolvedShortcut }
}

function Test-CodexDesktopShortcut {
    $desktopFolders = @(
        [Environment]::GetFolderPath("Desktop"),
        (Join-Path $env:USERPROFILE "Desktop"),
        "C:\Users\Administrator\Desktop"
    )

    $resolvedShortcut = $null
    foreach ($dir in $desktopFolders) {
        $hasDir = -not [string]::IsNullOrWhiteSpace($dir)

        if (-not $hasDir) { continue }

        $shortcut = Join-Path $dir "Codex UI.lnk"
        $hasShortcut = Test-Path $shortcut

        if ($hasShortcut) {
            $resolvedShortcut = $shortcut
            break
        }
    }

    $hasFound = -not [string]::IsNullOrWhiteSpace($resolvedShortcut)

    if (-not $hasFound) {
        $err = @{ FilePath = "Desktop\Codex UI.lnk"; Operation = "verify-shortcut"; Reason = "Codex desktop shortcut missing" }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{ IsSuccess = $hasFound; ShortcutPath = $resolvedShortcut }
}

function Test-LaunchClaudeApplication {
    param([string]$ExecutablePath)

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

function Test-LaunchCodexApplication {
    param([string]$ExecutablePath)

    $isLaunchSuccess = $false
    try {
        # Start process and verify it spawns a valid process ID
        $proc = Start-Process -FilePath $ExecutablePath -PassThru -NoNewWindow
        Start-Sleep -Milliseconds 1200
        $isAlive = -not $proc.HasExited

        if ($isAlive) {
            $isLaunchSuccess = $true
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        } else {
            $isLaunchSuccess = ($proc.ExitCode -eq 0)
        }
    } catch {
        $err = @{ FilePath = $ExecutablePath; Operation = "launch-test"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{ IsSuccess = $isLaunchSuccess; ExecutablePath = $ExecutablePath }
}

function Run-AiUiVerificationSuite {
    Write-Host "`n=== Live End-to-End AI UI Verification Suite ===" -ForegroundColor Cyan

    $claudeDirResult = Test-ClaudeDefaultDirectory
    Write-Host "  [ CHECK 1 ] Claude UI default directory: $($claudeDirResult.IsSuccess)" -ForegroundColor $(if ($claudeDirResult.IsSuccess) { "Green" } else { "Red" })

    $codexDirResult = Test-CodexDefaultDirectory
    Write-Host "  [ CHECK 2 ] Codex UI default directory:  $($codexDirResult.IsSuccess)" -ForegroundColor $(if ($codexDirResult.IsSuccess) { "Green" } else { "Red" })

    $claudeShortcutResult = Test-ClaudeDesktopShortcut
    Write-Host "  [ CHECK 3 ] Claude Code UI desktop link: $($claudeShortcutResult.IsSuccess)" -ForegroundColor $(if ($claudeShortcutResult.IsSuccess) { "Green" } else { "Red" })

    $codexShortcutResult = Test-CodexDesktopShortcut
    Write-Host "  [ CHECK 4 ] Codex UI desktop link:       $($codexShortcutResult.IsSuccess)" -ForegroundColor $(if ($codexShortcutResult.IsSuccess) { "Green" } else { "Red" })

    $claudeLaunchResult = Test-LaunchClaudeApplication -ExecutablePath $claudeDirResult.Path
    Write-Host "  [ CHECK 5 ] Claude UI executable launch: $($claudeLaunchResult.IsSuccess)" -ForegroundColor $(if ($claudeLaunchResult.IsSuccess) { "Green" } else { "Red" })

    $codexLaunchResult = Test-LaunchCodexApplication -ExecutablePath $codexDirResult.Path
    Write-Host "  [ CHECK 6 ] Codex UI executable launch:  $($codexLaunchResult.IsSuccess)" -ForegroundColor $(if ($codexLaunchResult.IsSuccess) { "Green" } else { "Red" })

    $isAllPass = $claudeDirResult.IsSuccess -and
                 $codexDirResult.IsSuccess -and
                 $claudeShortcutResult.IsSuccess -and
                 $codexShortcutResult.IsSuccess -and
                 $claudeLaunchResult.IsSuccess -and
                 $codexLaunchResult.IsSuccess

    if ($isAllPass) {
        Write-Host "`n[PASSED] All 6 E2E AI UI install and launch checks passed successfully!`n" -ForegroundColor Green
        exit 0
    }

    Write-Host "`n[FAILED] One or more AI UI checks failed.`n" -ForegroundColor Red
    exit 1
}

Run-AiUiVerificationSuite
