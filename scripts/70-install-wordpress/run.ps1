# --------------------------------------------------------------------------
#  Script 70 -- Install WordPress (Windows)
#  Installs and configures WordPress on MySQL, PHP, and Nginx.
# --------------------------------------------------------------------------
param(
    [Parameter(Position = 0)]
    [string]$Command = "all",

    [Parameter(Position = 1)]
    [string]$Path,

    [switch]$Help,
    [switch]$Interactive,
    [string]$DbName = "wordpress",
    [string]$DbUser = "wp_user",
    [string]$DbPass,
    [int]$SitePort = 80,
    [ValidateSet("full", "wp-only")]
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

function Generate-SecurePassword([int]$Length = 20) {
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $bytes = New-Object byte[] $Length
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $res = New-Object char[] $Length
    for ($i = 0; $i -lt $Length; $i++) {
        $res[$i] = $chars[$bytes[$i] % $chars.Length]
    }
    return -join $res
}

function Invoke-WordPressInstall {
    Write-Banner -Title $logMessages.scriptName
    Write-Log -Level "INFO" -Message $logMessages.messages.checkingPrereqs

    # Resolve dev directory
    $devDir = "C:\dev-tool"
    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        $installDir = $Path
    } else {
        $installDir = Join-Path $devDir "www\wordpress"
    }

    if (-not (Test-Path -LiteralPath $installDir)) {
        [void](New-Item -ItemType Directory -Path $installDir -Force -ErrorAction Stop)
    }

    $tempZip = Join-Path $env:TEMP "wordpress-latest.zip"
    Write-InstallPaths `
        -Tool "WordPress CMS" `
        -Source $config.wordpress.downloadUrl `
        -Temp $tempZip `
        -Target $installDir

    Write-Log -Level "INFO" -Message ($logMessages.messages.downloadingWp -replace '\{url\}', $config.wordpress.downloadUrl)
    try {
        Invoke-WebRequest -Uri $config.wordpress.downloadUrl -OutFile $tempZip -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-FileError -Path $tempZip -Reason $_.Exception.Message
        throw
    }

    # Verify checksums if available
    Write-Log -Level "INFO" -Message $logMessages.messages.verifyingChecksum
    $sha1Url = "$($config.wordpress.downloadUrl).sha1"
    try {
        $expectedSha1 = (Invoke-RestMethod -Uri $sha1Url -UseBasicParsing).Trim()
        $actualSha1 = (Get-FileHash -Path $tempZip -Algorithm SHA1).Hash.ToLowerInvariant()
        if ($actualSha1 -eq $expectedSha1.ToLowerInvariant()) {
            Write-Log -Level "OK" -Message $logMessages.messages.checksumOk
        } else {
            Write-FileError -Path $tempZip -Reason "SHA1 mismatch. Expected: $expectedSha1, Actual: $actualSha1"
        }
    } catch {
        Write-Log -Level "WARN" -Message "Could not verify remote SHA1 checksum: $($_.Exception.Message)"
    }

    Write-Log -Level "INFO" -Message ($logMessages.messages.extracting -replace '\{path\}', $installDir)
    try {
        Expand-Archive -Path $tempZip -DestinationPath (Split-Path -Parent $installDir) -Force
        Remove-Item -LiteralPath $tempZip -Force -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -Path $installDir -Reason $_.Exception.Message
        throw
    }

    if ([string]::IsNullOrWhiteSpace($DbPass)) {
        $DbPass = Generate-SecurePassword
    }

    # Generate wp-config.php with live salts
    Write-Log -Level "INFO" -Message $logMessages.messages.configuringWp
    $wpConfigFile = Join-Path $installDir "wp-config.php"
    $saltUrl = "https://api.wordpress.org/secret-key/1.1/salt/"
    $salts = ""
    try {
        $salts = (Invoke-RestMethod -Uri $saltUrl -UseBasicParsing).Trim()
    } catch {
        $salts = "# Salts fallback`ndefine('AUTH_KEY', '$((New-Guid).ToString())');"
    }

    $wpConfigContent = @"
<?php
define('DB_NAME', '$DbName');
define('DB_USER', '$DbUser');
define('DB_PASSWORD', '$DbPass');
define('DB_HOST', '127.0.0.1:3306');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

$salts

`$table_prefix = 'wp_';
define('WP_DEBUG', false);

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
"@

    Set-Content -LiteralPath $wpConfigFile -Value $wpConfigContent -Encoding UTF8

    # Save credentials securely
    $credsDir = Join-Path (Split-Path -Parent (Split-Path -Parent $scriptDir)) ".installed"
    if (-not (Test-Path -LiteralPath $credsDir)) {
        [void](New-Item -ItemType Directory -Path $credsDir -Force)
    }
    $credsFile = Join-Path $credsDir "70-wordpress-credentials.json"
    @{
        appName = "WordPress"
        dbName = $DbName
        dbUser = $DbUser
        dbPass = $DbPass
        installPath = $installDir
        installedAt = (Get-Date).ToString("o")
    } | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath $credsFile -Encoding UTF8

    Set-InstalledTracker -ScriptId "70"
    Write-Log -Level "OK" -Message ($logMessages.messages.setupComplete -replace '\{url\}', "http://localhost:$SitePort/")
}

function Invoke-WordPressCheck {
    $devDir = "C:\dev-tool"
    $installDir = if (-not [string]::IsNullOrWhiteSpace($Path)) { $Path } else { Join-Path $devDir "www\wordpress" }
    $cfg = Join-Path $installDir "wp-config.php"
    if (Test-Path -LiteralPath $cfg) {
        Write-Host "  WordPress wp-config.php exists at $cfg" -ForegroundColor Green
        return $true
    }
    Write-Host "  WordPress is NOT installed or configured at $installDir" -ForegroundColor Red
    return $false
}

switch ($Command.ToLowerInvariant()) {
    "all" { Invoke-WordPressInstall }
    "install" { Invoke-WordPressInstall }
    "check" { [void](Invoke-WordPressCheck) }
    "repair" {
        Remove-InstalledTracker -ScriptId "70"
        Invoke-WordPressInstall
    }
    "uninstall" {
        Remove-InstalledTracker -ScriptId "70"
        Write-Log -Level "OK" -Message $logMessages.messages.uninstallSuccess
    }
    default {
        Invoke-WordPressInstall
    }
}
