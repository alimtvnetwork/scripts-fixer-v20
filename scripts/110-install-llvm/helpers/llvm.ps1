function Install-Llvm {
    param(
        [hashtable]$Config,
        [hashtable]$LogMessages
    )

    $clangCmd = Get-Command clang -ErrorAction SilentlyContinue
    if ($clangCmd) {
        $ver = (& clang --version 2>$null | Select-Object -First 1)
        Write-Log ($LogMessages.messages.llvmAlreadyInstalled -replace '\{version\}', $ver) -Level "success"
        return
    }

    Write-Log $LogMessages.messages.llvmNotFound -Level "info"

    $hasWinget = [bool](Get-Command winget -ErrorAction SilentlyContinue)
    $installed = $false

    if ($hasWinget) {
        try {
            $proc = Start-Process -FilePath "winget" -ArgumentList "install", "--id", $Config.defaultPackage, "--exact", "--accept-package-agreements", "--accept-source-agreements", "--silent" -Wait -PassThru -NoNewWindow
            if ($proc.ExitCode -eq 0) {
                $installed = $true
                Write-Log ($LogMessages.messages.llvmInstallSuccess -replace '\{version\}', "Winget") -Level "success"
            }
        } catch {
            Write-Log "Winget install failed: $_" -Level "warn"
        }
    }

    if (-not $installed) {
        $hasChoco = [bool](Get-Command choco -ErrorAction SilentlyContinue)
        if ($hasChoco) {
            try {
                $proc = Start-Process -FilePath "choco" -ArgumentList "install", $Config.chocoPackage, "-y" -Wait -PassThru -NoNewWindow
                if ($proc.ExitCode -eq 0) {
                    $installed = $true
                    Write-Log ($LogMessages.messages.llvmInstallSuccess -replace '\{version\}', "Chocolatey") -Level "success"
                }
            } catch {
                Write-Log "Chocolatey install failed: $_" -Level "warn"
            }
        }
    }

    if (-not $installed) {
        Write-Log "Failed to automatically install LLVM via Winget or Chocolatey." -Level "error"
    }
}

function Update-LlvmPath {
    param(
        [hashtable]$Config,
        [hashtable]$LogMessages
    )

    $binDir = Join-Path $Config.installDir "bin"
    if (Test-Path $binDir) {
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($currentPath -notlike "*$binDir*") {
            [Environment]::SetEnvironmentVariable("Path", "$currentPath;$binDir", "Machine")
            $env:Path = "$env:Path;$binDir"
            Write-Log ($LogMessages.messages.addingToPath -replace '\{path\}', $binDir) -Level "success"
        } else {
            Write-Log ($LogMessages.messages.pathAlreadyContains -replace '\{path\}', $binDir) -Level "info"
        }
    }
}

function Uninstall-Llvm {
    param(
        [hashtable]$Config,
        [hashtable]$LogMessages
    )
    Write-Log $LogMessages.messages.uninstalling -Level "info"
    $hasWinget = [bool](Get-Command winget -ErrorAction SilentlyContinue)
    if ($hasWinget) {
        Start-Process -FilePath "winget" -ArgumentList "uninstall", "--id", $Config.defaultPackage, "--silent" -Wait -NoNewWindow -ErrorAction SilentlyContinue
    }
    Write-Log $LogMessages.messages.uninstallSuccess -Level "success"
}
