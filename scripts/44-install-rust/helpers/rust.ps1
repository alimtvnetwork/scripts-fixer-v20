# --------------------------------------------------------------------------
#  Rust toolchain helper functions
# --------------------------------------------------------------------------

# -- Bootstrap shared helpers --------------------------------------------------
$_sharedDir = Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) "shared"
$_loggingPath = Join-Path $_sharedDir "logging.ps1"
if ((Test-Path $_loggingPath) -and -not (Get-Command Write-Log -ErrorAction SilentlyContinue)) {
    . $_loggingPath
}


function Get-CargoBinPath {
    param($Config)

    $cargoHome = $Config.path.cargoHome
    $hasCustomCargoHome = -not [string]::IsNullOrWhiteSpace($cargoHome)
    if ($hasCustomCargoHome) {
        return (Join-Path $cargoHome "bin")
    }

    return (Join-Path $env:USERPROFILE ".cargo\bin")
}


function Sync-ProcessCargoPath {
    param([string]$CargoBin)

    $isBinMissing = -not (Test-Path $CargoBin)
    if ($isBinMissing) {
        return
    }

    $isNotInProcessPath = $env:Path -notlike "*$CargoBin*"
    if ($isNotInProcessPath) {
        $env:Path = "$CargoBin;$env:Path"
    }
}


function Find-RustcExecutable {
    param([string]$CargoBin)

    $cmd = Get-Command rustc -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    $binRustc = Join-Path $CargoBin "rustc.exe"
    $hasBinRustc = Test-Path $binRustc
    if ($hasBinRustc) {
        return $binRustc
    }

    return $null
}


function Invoke-RustupFallbackInstall {
    param($Config, $LogMessages)

    $hasChoco = Get-Command choco -ErrorAction SilentlyContinue
    if (-not $hasChoco) {
        Write-Log "Chocolatey not available for fallback Rust install" -Level "error"
        return $false
    }

    Write-Log "Attempting Chocolatey fallback: choco install rustup.install" -Level "info"
    $proc = Start-Process -FilePath $hasChoco.Source -ArgumentList @("install", "rustup.install", "-y", "--no-progress") -Wait -PassThru -NoNewWindow
    $isSuccess = ($proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010)

    return $isSuccess
}


function Install-Rust {
    param(
        $Config,
        $LogMessages
    )

    $cargoBin = Get-CargoBinPath -Config $Config
    Sync-ProcessCargoPath -CargoBin $cargoBin

    $existing = Find-RustcExecutable -CargoBin $cargoBin
    if ($existing) {
        Handle-ExistingRust -Config $Config -LogMessages $LogMessages -ExistingPath $existing
        return
    }

    Execute-FreshRustInstall -Config $Config -LogMessages $LogMessages -CargoBin $cargoBin
}


function Handle-ExistingRust {
    param(
        $Config,
        $LogMessages,
        [string]$ExistingPath
    )

    $currentVersion = try { & $ExistingPath --version 2>$null } catch { $null }
    $hasVersion = -not [string]::IsNullOrWhiteSpace($currentVersion)

    if ($hasVersion) {
        $isAlreadyTracked = Test-AlreadyInstalled -Name "rust" -CurrentVersion $currentVersion
        if ($isAlreadyTracked) {
            Write-Log ($LogMessages.messages.rustAlreadyInstalled -replace '\{version\}', $currentVersion) -Level "info"
            return
        }
    }

    Write-Log ($LogMessages.messages.rustAlreadyInstalled -replace '\{version\}', $currentVersion) -Level "info"

    $isUpgradeDisabled = -not $Config.alwaysUpgradeToLatest
    if ($isUpgradeDisabled) {
        return
    }

    Update-RustToolchain -Config $Config -LogMessages $LogMessages
}


function Update-RustToolchain {
    param(
        $Config,
        $LogMessages
    )

    try {
        $previousErrorPref = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        & rustup update $Config.defaultToolchain 2>$null | Out-Null
        $ErrorActionPreference = $previousErrorPref
        $newVersion = try { & rustc --version 2>$null } catch { $null }
        $isVersionEmpty = [string]::IsNullOrWhiteSpace($newVersion)
        if ($isVersionEmpty) { $newVersion = "(version pending)" }

        Write-Log ($LogMessages.messages.rustUpgradeSuccess -replace '\{version\}', $newVersion) -Level "success"
        Save-InstalledRecord -Name "rust" -Version "$newVersion".Trim()
    } catch {
        Write-Log "Rust upgrade failed: $_" -Level "error"
        Save-InstalledError -Name "rust" -ErrorMessage "$_"
    }
}


function Execute-FreshRustInstall {
    param(
        $Config,
        $LogMessages,
        [string]$CargoBin
    )

    Write-Log $LogMessages.messages.rustNotFound -Level "info"
    $rustupExe = Join-Path $env:TEMP "rustup-init.exe"

    try {
        Write-Log $LogMessages.messages.downloadingRustup -Level "info"
        Invoke-DownloadWithRetry -Uri $Config.rustupUrl -OutFile $rustupExe

        Write-Log ($LogMessages.messages.runningRustupInit -replace '\{toolchain\}', $Config.defaultToolchain) -Level "info"
        & $rustupExe -y --default-toolchain $Config.defaultToolchain --profile default 2>&1 | Out-Null
    } catch {
        Write-FileError -FilePath $rustupExe -Operation "execute" -Reason "rustup-init download/exec failed: $_" -Module "Execute-FreshRustInstall"
        $hasFallbackSucceeded = Invoke-RustupFallbackInstall -Config $Config -LogMessages $LogMessages
        if (-not $hasFallbackSucceeded) {
            Save-InstalledError -Name "rust" -ErrorMessage "$_"
            return
        }
    }

    Sync-ProcessCargoPath -CargoBin $CargoBin
    $installedVersion = try { & (Join-Path $CargoBin "rustc.exe") --version 2>$null } catch { $null }
    Write-Log ($LogMessages.messages.rustInstallSuccess -replace '\{version\}', $installedVersion) -Level "success"
    Save-InstalledRecord -Name "rust" -Version "$installedVersion".Trim()

    $isTempPresent = Test-Path $rustupExe
    if ($isTempPresent) { Remove-Item $rustupExe -Force -ErrorAction SilentlyContinue }
}


function Install-RustComponents {
    param(
        $Config,
        $LogMessages
    )

    $cargoBin = Get-CargoBinPath -Config $Config
    Sync-ProcessCargoPath -CargoBin $cargoBin

    $rustupExe = Join-Path $cargoBin "rustup.exe"
    $hasRustupExe = Test-Path $rustupExe
    $rustupCmd = $null
    if ($hasRustupExe) {
        $rustupCmd = $rustupExe
    } else {
        $foundCmd = Get-Command rustup -ErrorAction SilentlyContinue
        if ($foundCmd) {
            $rustupCmd = $foundCmd.Source
        }
    }

    $isRustupMissing = [string]::IsNullOrWhiteSpace($rustupCmd)
    if ($isRustupMissing) {
        Write-Log "rustup not found -- cannot install components" -Level "warn"
        return
    }

    Install-ConfiguredComponents -Config $Config -LogMessages $LogMessages -RustupPath $rustupCmd
    Add-WasmTargetIfNeeded -Config $Config -LogMessages $LogMessages -RustupPath $rustupCmd
    Install-CargoPackagesIfNeeded -Config $Config -LogMessages $LogMessages -CargoBin $cargoBin
}


function Install-ConfiguredComponents {
    param(
        $Config,
        $LogMessages,
        [string]$RustupPath
    )

    $installedComponents = try { & $RustupPath component list --installed 2>$null } catch { @() }
    foreach ($comp in @("clippy", "rustfmt", "rust-analyzer")) {
        $isEnabled = $Config.components.$comp
        if (-not $isEnabled) { continue }

        $isAlreadyInstalled = $installedComponents -match $comp
        if ($isAlreadyInstalled) {
            Write-Log ($LogMessages.messages.componentAlreadyInstalled -replace '\{component\}', $comp) -Level "info"
            continue
        }

        Write-Log ($LogMessages.messages.componentInstalling -replace '\{component\}', $comp) -Level "info"
        try {
            $prevErrorPref = $ErrorActionPreference
            $ErrorActionPreference = "Continue"
            & $RustupPath component add $comp 2>$null | Out-Null
            $ErrorActionPreference = $prevErrorPref
            Write-Log ($LogMessages.messages.componentInstallSuccess -replace '\{component\}', $comp) -Level "success"
        } catch {
            Write-Log "Failed to install component $comp`: $_" -Level "error"
        }
    }
}


function Add-WasmTargetIfNeeded {
    param(
        $Config,
        $LogMessages,
        [string]$RustupPath
    )

    $isWasmEnabled = $Config.targets.addWasm
    if (-not $isWasmEnabled) { return }

    $wasmTarget = $Config.targets.wasmTarget
    $installedTargets = try { & $RustupPath target list --installed 2>$null } catch { @() }
    $isWasmPresent = $installedTargets -match $wasmTarget

    if ($isWasmPresent) {
        Write-Log ($LogMessages.messages.targetAlreadyAdded -replace '\{target\}', $wasmTarget) -Level "info"
        return
    }

    Write-Log ($LogMessages.messages.targetAdding -replace '\{target\}', $wasmTarget) -Level "info"
    try {
        $prevErrorPref = $ErrorActionPreference
        $ErrorActionPreference = "Continue"
        & $RustupPath target add $wasmTarget 2>$null | Out-Null
        $ErrorActionPreference = $prevErrorPref
        Write-Log "WASM target $wasmTarget added successfully" -Level "success"
    } catch {
        Write-Log "Failed to add target $wasmTarget`: $_" -Level "error"
    }
}


function Install-CargoPackagesIfNeeded {
    param(
        $Config,
        $LogMessages,
        [string]$CargoBin
    )

    $isCargoPackagesEnabled = $Config.cargoPackages.enabled
    if (-not $isCargoPackagesEnabled) { return }

    $cargoExe = Join-Path $CargoBin "cargo.exe"
    foreach ($pkg in $Config.cargoPackages.packages) {
        Write-Log ($LogMessages.messages.cargoPackageInstalling -replace '\{package\}', $pkg) -Level "info"
        try {
            & $cargoExe install $pkg 2>&1 | Out-Null
            Write-Log ($LogMessages.messages.cargoPackageSuccess -replace '\{package\}', $pkg) -Level "success"
        } catch {
            Write-Log "Failed to install cargo package $pkg`: $_" -Level "error"
        }
    }
}


function Update-RustPath {
    param(
        $Config,
        $LogMessages
    )

    $isPathUpdateDisabled = -not $Config.path.updateUserPath
    if ($isPathUpdateDisabled) { return }

    $cargoBin = Get-CargoBinPath -Config $Config
    Sync-ProcessCargoPath -CargoBin $cargoBin

    $isAlreadyInUser = Test-InPath -Directory $cargoBin -Scope "User"
    if ($isAlreadyInUser) {
        Write-Log ($LogMessages.messages.pathAlreadyContains -replace '\{path\}', $cargoBin) -Level "info"
    } else {
        Write-Log ($LogMessages.messages.addingToPath -replace '\{path\}', $cargoBin) -Level "info"
        Add-ToUserPath -Directory $cargoBin | Out-Null
    }

    # Also register in Machine PATH if admin rights exist
    $hasAdminRights = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($hasAdminRights) {
        $isAlreadyInMachine = Test-InPath -Directory $cargoBin -Scope "Machine"
        if (-not $isAlreadyInMachine) {
            Add-ToMachinePath -Directory $cargoBin | Out-Null
        }
    }
}


function Uninstall-Rust {
    param(
        $Config,
        $LogMessages
    )

    Write-Log $LogMessages.messages.uninstalling -Level "info"
    $cargoBin = Get-CargoBinPath -Config $Config
    Sync-ProcessCargoPath -CargoBin $cargoBin

    $rustupExe = Join-Path $cargoBin "rustup.exe"
    $hasRustup = (Test-Path $rustupExe) -or (Get-Command rustup -ErrorAction SilentlyContinue)

    if (-not $hasRustup) {
        Write-Log "rustup not found -- nothing to uninstall" -Level "warn"
        return
    }

    try {
        & rustup self uninstall -y 2>&1 | Out-Null
        Write-Log $LogMessages.messages.uninstallSuccess -Level "success"
    } catch {
        Write-Log ($LogMessages.messages.uninstallFailed) -Level "error"
    }

    Remove-InstalledRecord -Name "rust"
    Remove-ResolvedData -ScriptFolder "44-install-rust"

    Write-Log $LogMessages.messages.uninstallComplete -Level "success"
}
