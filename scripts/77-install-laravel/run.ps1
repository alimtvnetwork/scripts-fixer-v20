# --------------------------------------------------------------------------
#  Script 77 -- Install Laravel (Windows)
#  Installs Composer and scaffolds/configures Laravel applications on Windows.
# --------------------------------------------------------------------------
param(
    [Parameter(Position = 0)]
    [string]$Command = "all",

    [Parameter(Position = 1)]
    [string]$Path,

    [switch]$Help,
    [switch]$Interactive,
    [string]$AppName = "laravel-app",
    [string]$DbName = "laravel",
    [string]$DbUser = "root",
    [string]$DbPass = "",
    [ValidateSet("full", "cli-only", "scaffold-only")]
    [string]$Mode = "full"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"
$script:ScriptDir = $scriptDir

# -- Dot-source shared helpers ------------------------------------------------
. (Join-Path $sharedDir "logging.ps1")
. (Join-Path $sharedDir "resolved.ps1")
. (Join-Path $sharedDir "git-pull.ps1")
. (Join-Path $sharedDir "help.ps1")
. (Join-Path $sharedDir "choco-utils.ps1")
. (Join-Path $sharedDir "installed.ps1")
. (Join-Path $sharedDir "interactive.ps1")
. (Join-Path $sharedDir "install-paths.ps1")

$config = Import-JsonConfig (Join-Path $scriptDir "config.json")
$logMessages = Import-JsonConfig (Join-Path $scriptDir "log-messages.json")

if ($Help -or $Command -eq "--help") {
    Show-ScriptHelp -LogMessages $logMessages
    return
}

function Ensure-Composer {
    $composerCmd = Get-Command "composer" -ErrorAction SilentlyContinue
    if ($null -ne $composerCmd) {
        return $true
    }
    Write-Log -Level "INFO" -Message $logMessages.messages.composerNotFound
    Install-ChocoPackage -PackageName "composer"
    return ($null -ne (Get-Command "composer" -ErrorAction SilentlyContinue))
}

function Invoke-LaravelInstall {
    Write-Banner -Title $logMessages.scriptName
    Write-Log -Level "INFO" -Message $logMessages.messages.checkingComposer

    if (-not (Ensure-Composer)) {
        Write-FileError -Path "composer" -Reason "Composer could not be installed or located in PATH."
        return
    }

    if ($Mode -eq "cli-only") {
        Set-InstalledTracker -ScriptId "77"
        Write-Log -Level "OK" -Message $logMessages.messages.composerInstallSuccess
        return
    }

    $devDir = "C:\dev-tool"
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $installDir = $Path
    } else {
        $installDir = Join-Path $devDir ("www\" + $AppName)
    }

    Write-InstallPaths `
        -Tool "Laravel Framework" `
        -Source "Composer (package: laravel/laravel)" `
        -Temp "C:\Users\$env:USERNAME\AppData\Local\Composer" `
        -Target $installDir

    $parentDir = Split-Path -Parent $installDir
    if (-not (Test-Path -LiteralPath $parentDir)) {
        [void](New-Item -ItemType Directory -Path $parentDir -Force)
    }

    $artisanFile = Join-Path $installDir "artisan"
    if (-not (Test-Path -LiteralPath $artisanFile)) {
        Write-Log -Level "INFO" -Message ($logMessages.messages.scaffoldingApp -replace '\{path\}', $installDir)
        try {
            composer create-project --prefer-dist laravel/laravel $installDir --no-interaction
        } catch {
            Write-FileError -Path $installDir -Reason $_.Exception.Message
            throw
        }
    } else {
        Write-Log -Level "INFO" -Message "Laravel project already exists at $installDir -- updating dependencies..."
        Push-Location $installDir
        try {
            composer install --no-interaction
        } finally {
            Pop-Location
        }
    }

    # Configure .env
    $envFile = Join-Path $installDir ".env"
    $envExample = Join-Path $installDir ".env.example"
    if (-not (Test-Path -LiteralPath $envFile) -and (Test-Path -LiteralPath $envExample)) {
        Copy-Item -Path $envExample -Destination $envFile -Force
    }

    if (Test-Path -LiteralPath $envFile) {
        Write-Log -Level "INFO" -Message $logMessages.messages.configuringEnv
        Push-Location $installDir
        try {
            php artisan key:generate --force
            Write-Log -Level "INFO" -Message $logMessages.messages.storageLinking
            php artisan storage:link
        } catch {
            Write-Log -Level "WARN" -Message "Artisan command warning: $($_.Exception.Message)"
        } finally {
            Pop-Location
        }
    }

    Set-InstalledTracker -ScriptId "77"
    Write-Log -Level "OK" -Message ($logMessages.messages.setupComplete -replace '\{path\}', $installDir)
}

function Invoke-LaravelCheck {
    $hasComposer = ($null -ne (Get-Command "composer" -ErrorAction SilentlyContinue))
    $hasPhp = ($null -ne (Get-Command "php" -ErrorAction SilentlyContinue))
    if ($hasComposer -and $hasPhp) {
        Write-Host "  Laravel toolchain (PHP + Composer) is ready." -ForegroundColor Green
        return $true
    }
    Write-Host "  Laravel toolchain is incomplete (PHP: $hasPhp, Composer: $hasComposer)" -ForegroundColor Red
    return $false
}

switch ($Command.ToLowerInvariant()) {
    "all" { Invoke-LaravelInstall }
    "install" { Invoke-LaravelInstall }
    "scaffold" { Invoke-LaravelInstall }
    "check" { [void](Invoke-LaravelCheck) }
    "repair" {
        Remove-InstalledTracker -ScriptId "77"
        Invoke-LaravelInstall
    }
    "uninstall" {
        Remove-InstalledTracker -ScriptId "77"
        Write-Log -Level "OK" -Message $logMessages.messages.uninstallSuccess
    }
    default {
        Invoke-LaravelInstall
    }
}
