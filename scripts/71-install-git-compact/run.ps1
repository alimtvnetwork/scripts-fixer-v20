# --------------------------------------------------------------------------
#  Script 71 -- Install git-compact
#  Compacts and prunes local git repositories (gc / reflog expire / repack)
# --------------------------------------------------------------------------
param(
    [Parameter(Position = 0)]
    [string]$Command = "install",

    # Pin a specific git-compact ref (branch / tag / commit).
    # -Tag is canonical; -Version is a back-compat alias.
    [Alias("Version")]
    [string]$Tag,

    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir  = Join-Path (Split-Path -Parent $scriptDir) "shared"

# -- Dot-source shared helpers ------------------------------------------------
. (Join-Path $sharedDir "logging.ps1")
. (Join-Path $sharedDir "resolved.ps1")
. (Join-Path $sharedDir "git-pull.ps1")
. (Join-Path $sharedDir "help.ps1")
. (Join-Path $sharedDir "dev-dir.ps1")
. (Join-Path $sharedDir "installed.ps1")
. (Join-Path $sharedDir "path-utils.ps1")
. (Join-Path $sharedDir "install-paths.ps1")

# -- Dot-source script helper -------------------------------------------------
. (Join-Path $scriptDir "helpers\git-compact.ps1")

# -- Load config & log messages -----------------------------------------------
$config      = Import-JsonConfig (Join-Path $scriptDir "config.json")
$logMessages = Import-JsonConfig (Join-Path $scriptDir "log-messages.json")

# -- Help ---------------------------------------------------------------------
if ($Help -or $Command -eq "--help" -or $Command -eq "-Help" -or $Command -eq "help") {
    Show-ScriptHelp -LogMessages $logMessages
    return
}

# -- Banner --------------------------------------------------------------------
Write-Banner -Title $logMessages.scriptName

# -- Resolve effective git ref (branch / tag / commit) ------------------------
# Precedence:  -Tag/-Version flag  >  config.gitCompact.releaseTag  >
#              config.gitCompact.fallbackTag  >  hard default "main".
$effectiveTag = $null
if (-not [string]::IsNullOrWhiteSpace($Tag)) {
    $effectiveTag = $Tag.Trim()
} elseif (-not [string]::IsNullOrWhiteSpace($config.gitCompact.releaseTag)) {
    $effectiveTag = "$($config.gitCompact.releaseTag)".Trim()
} elseif (-not [string]::IsNullOrWhiteSpace($config.gitCompact.fallbackTag)) {
    $effectiveTag = "$($config.gitCompact.fallbackTag)".Trim()
} else {
    $effectiveTag = "main"
}

# Numeric versions like "1.2.0" -> "v1.2.0"; branch names pass through.
if ($effectiveTag -match '^\d') { $effectiveTag = "v$effectiveTag" }

$config.gitCompact.releaseTag  = $effectiveTag
$config.gitCompact.fallbackTag = $effectiveTag
if ($config.gitCompact.installUrl) {
    $config.gitCompact.installUrl = $config.gitCompact.installUrl -replace '\{tag\}', $effectiveTag
}
if ($config.gitCompact.releaseZipUrl) {
    $config.gitCompact.releaseZipUrl = $config.gitCompact.releaseZipUrl -replace '\{tag\}', $effectiveTag
}

$targetDir = Resolve-GitCompactInstallDir -ToolConfig $config.gitCompact -DevDirConfig $config.devDir

# -- Triple-path trio (Source / Temp / Target) --------------------------------
Write-InstallPaths `
    -Tool   "git-compact" `
    -Action "Install" `
    -Source "$($config.gitCompact.installUrl) (irm | iex)" `
    -Temp   ($env:TEMP + "\git-compact") `
    -Target $targetDir

# -- Initialize logging --------------------------------------------------------
Initialize-Logging -ScriptName $logMessages.scriptName

try {

# -- Git pull ------------------------------------------------------------------
Invoke-GitPull

$verb = $Command.ToLower()

if ($verb -eq "uninstall") {
    Uninstall-GitCompact -ToolConfig $config.gitCompact -DevDirConfig $config.devDir -LogMessages $logMessages | Out-Null
    return
}

if ($verb -eq "check") {
    $check = Assert-GitCompactInstalled -InstallDir $targetDir -LogMessages $logMessages
    if (-not $check.Success) { Write-Log $logMessages.messages.verifyFinalFail -Level "error" }
    return
}

# -- Install -------------------------------------------------------------------
Write-Log "Using git-compact ref: $effectiveTag" -Level "info"
Write-Log "Resolved install URL: $($config.gitCompact.installUrl)" -Level "info"

$minFreeGB = 0.2
if ($config.PSObject.Properties['minFreeGB']) { $minFreeGB = [double]$config.minFreeGB }

$ok = Install-GitCompact -ToolConfig $config.gitCompact -DevDirConfig $config.devDir -LogMessages $logMessages -MinFreeGB $minFreeGB

$isSuccess = $ok -eq $true
if ($isSuccess) {
    $finalVerify = Assert-GitCompactInstalled -InstallDir $targetDir -LogMessages $logMessages
    if ($finalVerify.Success) {
        Write-Host ""
        Write-Host "============= git-compact post-install verification =============" -ForegroundColor Cyan
        Write-Host ("  [OK] git-compact --version : {0}" -f $finalVerify.Version)    -ForegroundColor Green
        Write-Host ("  [OK] resolved binary       : {0}" -f $finalVerify.BinaryPath) -ForegroundColor Green
        Write-Host "=================================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Log $logMessages.messages.setupComplete -Level "success"
    } else {
        Write-Host "  [XX] git-compact --version did not run cleanly" -ForegroundColor Red
        Write-Log "Post-install verification failed: open a NEW terminal and re-run." -Level "error"
        $isSuccess = $false
    }
}
if (-not $isSuccess) {
    Write-Log ($logMessages.messages.installFailed -replace '\{error\}', "See errors above") -Level "error"
}

} catch {
    Write-Log "Unhandled error: $_" -Level "error"
    Write-Log "Stack: $($_.ScriptStackTrace)" -Level "error"
} finally {
    $hasAnyErrors = $script:_LogErrors.Count -gt 0
    Save-LogFile -Status $(if ($hasAnyErrors) { "fail" } else { "ok" })
}
