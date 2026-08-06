# --------------------------------------------------------------------------
#  Helper -- git-compact CLI installer
#  Uses the remote install.ps1 from GitHub, with a release-ZIP fallback.
# --------------------------------------------------------------------------

# -- Bootstrap shared helpers --------------------------------------------------
$_sharedDir = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "shared"

$_loggingPath = Join-Path $_sharedDir "logging.ps1"
if ((Test-Path $_loggingPath) -and -not (Get-Command Write-Log -ErrorAction SilentlyContinue)) {
    . $_loggingPath
}

$_devDirPath = Join-Path $_sharedDir "dev-dir.ps1"
if ((Test-Path $_devDirPath) -and -not (Get-Command Resolve-DevDir -ErrorAction SilentlyContinue)) {
    . $_devDirPath
}

$_diskPath = Join-Path $_sharedDir "disk-space.ps1"
if ((Test-Path $_diskPath) -and -not (Get-Command Test-DiskSpace -ErrorAction SilentlyContinue)) {
    . $_diskPath
}

function Resolve-GitCompactInstallDir {
    <#
    .SYNOPSIS
        Resolves the git-compact install directory.
        Priority: gitCompact.installDir override > devDir resolution > config default.
    #>
    param(
        [PSCustomObject]$ToolConfig,
        [PSCustomObject]$DevDirConfig
    )

    $hasInstallDir = -not [string]::IsNullOrWhiteSpace($ToolConfig.installDir)
    if ($hasInstallDir) { return $ToolConfig.installDir }

    $devDir = $null
    if (Get-Command Resolve-DevDir -ErrorAction SilentlyContinue) {
        $devDir = Resolve-DevDir -DevDirConfig $DevDirConfig
    }
    $hasDevDir = -not [string]::IsNullOrWhiteSpace($devDir)
    if ($hasDevDir) { return (Join-Path $devDir "GitCompact") }

    $hasDefault = -not [string]::IsNullOrWhiteSpace($DevDirConfig.default)
    if ($hasDefault) { return $DevDirConfig.default }

    return "C:\dev-tool\GitCompact"
}

function Test-GitCompactInstalled {
    param([string]$InstallDir = "")

    $cmd = Get-Command "git-compact" -ErrorAction SilentlyContinue
    $isInPath = $null -ne $cmd
    if ($isInPath) { return $true }

    $candidates = @(
        "$env:LOCALAPPDATA\git-compact\git-compact.exe",
        "C:\dev-tool\GitCompact\git-compact.exe"
    )
    $hasInstallDir = -not [string]::IsNullOrWhiteSpace($InstallDir)
    if ($hasInstallDir) { $candidates += (Join-Path $InstallDir "git-compact.exe") }

    foreach ($p in $candidates) {
        if (Test-Path $p) { return $true }
    }
    return $false
}

function Assert-GitCompactInstalled {
    <#
    .SYNOPSIS
        Post-install verifier. Runs `git-compact --version`, refreshing PATH
        from the registry and probing known folders when the binary is not
        yet resolvable in the current session.
    .OUTPUTS
        Hashtable: Success, Version, BinaryPath, ExitCode, Output.
    #>
    param(
        [string]$InstallDir,
        $LogMessages
    )

    $result = @{ Success = $false; Version = ""; BinaryPath = ""; ExitCode = -1; Output = "" }

    Write-Log $LogMessages.messages.verifyStart -Level "info"

    $cmd = Get-Command "git-compact" -ErrorAction SilentlyContinue
    $isMissing = $null -eq $cmd
    if ($isMissing) {
        Write-Log $LogMessages.messages.verifyMissing -Level "warn"

        # Refresh PATH from registry (machine + user).
        $before = ($env:Path -split ';').Count
        $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath    = [Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = "$machinePath;$userPath"
        $added = ($env:Path -split ';').Count - $before
        Write-Log ($LogMessages.messages.verifyRefreshed -replace '\{count\}', "$added") -Level "info"

        $probe = @(
            "$env:LOCALAPPDATA\git-compact\git-compact.exe",
            "C:\dev-tool\GitCompact\git-compact.exe"
        )
        $hasInstallDir = -not [string]::IsNullOrWhiteSpace($InstallDir)
        if ($hasInstallDir) { $probe += (Join-Path $InstallDir "git-compact.exe") }

        foreach ($p in $probe) {
            if (Test-Path $p) {
                $env:Path = (Split-Path -Parent $p) + ";" + $env:Path
                break
            }
        }
        $cmd = Get-Command "git-compact" -ErrorAction SilentlyContinue
    }

    $stillMissing = $null -eq $cmd
    if ($stillMissing) {
        Write-FileError -Path (Join-Path $InstallDir "git-compact.exe") `
                        -Reason "git-compact binary not found on PATH and not present in the resolved install directory after install"
        Write-Log $LogMessages.messages.verifyFinalFail -Level "error"
        return $result
    }

    $result.BinaryPath = $cmd.Source
    try {
        $out = & git-compact --version 2>&1
        $result.ExitCode = $LASTEXITCODE
        $result.Output   = ($out | Out-String).Trim()
    } catch {
        $result.Output = "$_"
    }

    $isOk = ($result.ExitCode -eq 0) -and (-not [string]::IsNullOrWhiteSpace($result.Output))
    if (-not $isOk) {
        Write-Log (($LogMessages.messages.verifyExitCode -replace '\{code\}', "$($result.ExitCode)") -replace '\{output\}', $result.Output) -Level "error"
        Write-FileError -Path $result.BinaryPath -Reason "'git-compact --version' exited code=$($result.ExitCode) output=$($result.Output)"
        return $result
    }

    $result.Version = ($result.Output -replace '^\s*git-compact\s*', '').Trim()
    $result.Success = $true
    Write-Log ($LogMessages.messages.verifyOk -replace '\{version\}', $result.Version) -Level "success"
    Write-Log ($LogMessages.messages.verifyBinaryAt -replace '\{path\}', $result.BinaryPath) -Level "info"
    return $result
}

function Install-GitCompact {
    <#
    .SYNOPSIS
        Installs git-compact: remote one-liner first, release ZIP as fallback.
    .OUTPUTS
        $true on success, $false on failure.
    #>
    param(
        [PSCustomObject]$ToolConfig,
        [PSCustomObject]$DevDirConfig,
        $LogMessages,
        [double]$MinFreeGB = 0.2
    )

    $isDisabled = $ToolConfig.enabled -ne $true
    if ($isDisabled) {
        Write-Log $LogMessages.messages.disabled -Level "warn"
        return $true
    }

    $installDir = Resolve-GitCompactInstallDir -ToolConfig $ToolConfig -DevDirConfig $DevDirConfig
    $ToolConfig.installDir = $installDir
    Write-Log ($LogMessages.messages.installDir -replace '\{path\}', $installDir) -Level "info"

    Write-Log $LogMessages.messages.checking -Level "info"
    $isPresent = Test-GitCompactInstalled -InstallDir $installDir
    if ($isPresent) {
        Write-Log $LogMessages.messages.found -Level "info"
        Set-InstalledState -Name "git-compact" -Status "already-installed" -ErrorAction SilentlyContinue
        return $true
    }
    Write-Log $LogMessages.messages.notFound -Level "info"

    # Disk-space preflight.
    if (Get-Command Test-DiskSpace -ErrorAction SilentlyContinue) {
        $parent = Split-Path -Parent $installDir
        $probeDir = if ([string]::IsNullOrWhiteSpace($parent)) { $installDir } else { $parent }
        $hasSpace = Test-DiskSpace -TargetPath $probeDir -RequiredGB $MinFreeGB -Label "git-compact"
        if (-not $hasSpace) {
            Write-FileError -Path $probeDir -Reason "Insufficient disk space for git-compact install (needed ${MinFreeGB} GB)"
            return $false
        }
    }

    New-Item -ItemType Directory -Path $installDir -Force -ErrorAction SilentlyContinue | Out-Null

    # -- 1. Remote installer -------------------------------------------------
    Write-Log $LogMessages.messages.downloadingInstaller -Level "info"
    $installerOk = $false
    try {
        $script = Invoke-RestMethod -Uri $ToolConfig.installUrl -UseBasicParsing -ErrorAction Stop
        Write-Log $LogMessages.messages.runningInstaller -Level "info"
        & ([scriptblock]::Create($script)) -InstallDir $installDir
        $installerOk = $true
    } catch {
        Write-FileError -Path $ToolConfig.installUrl -Reason "Remote installer failed: $_"
        Write-Log $LogMessages.messages.remoteInstallerFailed -Level "warn"
    }

    # -- 2. ZIP fallback -----------------------------------------------------
    if (-not $installerOk) {
        $zipUrl = $ToolConfig.releaseZipUrl
        Write-Log ($LogMessages.messages.downloadingZip -replace '\{url\}', $zipUrl) -Level "info"
        try {
            $tmpZip = Join-Path $env:TEMP "git-compact.zip"
            Invoke-WebRequest -Uri $zipUrl -OutFile $tmpZip -UseBasicParsing -ErrorAction Stop
            Expand-Archive -Path $tmpZip -DestinationPath $installDir -Force
            Remove-Item $tmpZip -Force -ErrorAction SilentlyContinue
            Write-Log ($LogMessages.messages.zipExtracted -replace '\{path\}', $installDir) -Level "info"
            $installerOk = $true
        } catch {
            Write-FileError -Path $zipUrl -Reason "ZIP fallback failed: $_"
            Write-Log ($LogMessages.messages.zipFallbackFailed -replace '\{error\}', "$_") -Level "error"
            return $false
        }
    }

    # -- 3. PATH -------------------------------------------------------------
    if (Get-Command Add-ToUserPath -ErrorAction SilentlyContinue) {
        Add-ToUserPath -Path $installDir | Out-Null
    }
    $isOnSessionPath = ($env:Path -split ';') -contains $installDir
    if (-not $isOnSessionPath) { $env:Path = "$installDir;$env:Path" }

    Write-Log $LogMessages.messages.installSuccess -Level "success"
    Set-InstalledState -Name "git-compact" -Status "installed" -ErrorAction SilentlyContinue
    return $true
}

function Uninstall-GitCompact {
    param(
        [PSCustomObject]$ToolConfig,
        [PSCustomObject]$DevDirConfig,
        $LogMessages
    )

    $name = "git-compact"
    Write-Log ($LogMessages.messages.uninstalling -replace '\{name\}', $name) -Level "info"

    $installDir = Resolve-GitCompactInstallDir -ToolConfig $ToolConfig -DevDirConfig $DevDirConfig
    $removed = $false

    $targets = @(
        (Join-Path $installDir "git-compact.exe"),
        "$env:LOCALAPPDATA\git-compact\git-compact.exe"
    )
    foreach ($t in $targets) {
        if (Test-Path $t) {
            try {
                Remove-Item $t -Force -ErrorAction Stop
                $removed = $true
            } catch {
                Write-FileError -Path $t -Reason "Removal failed: $_"
            }
        }
    }

    if ($removed) {
        Write-Log ($LogMessages.messages.uninstallSuccess -replace '\{name\}', $name) -Level "success"
    } else {
        Write-Log ($LogMessages.messages.uninstallFailed -replace '\{name\}', $name) -Level "warn"
    }

    Remove-InstalledState -Name "git-compact" -ErrorAction SilentlyContinue
    Write-Log $LogMessages.messages.uninstallComplete -Level "info"
    return $removed
}
