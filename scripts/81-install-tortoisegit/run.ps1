# --------------------------------------------------------------------------
#  Script 81 -- Install TortoiseGit 2.4.0.2
#  Supports Windows 10/11 & Windows Server
# --------------------------------------------------------------------------
param(
    [Parameter(Position = 0)]
    [string]$Command = "install",

    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir  = Join-Path (Split-Path -Parent $scriptDir) "shared"

. (Join-Path $sharedDir "logging.ps1")
. (Join-Path $sharedDir "resolved.ps1")
. (Join-Path $sharedDir "git-pull.ps1")
. (Join-Path $sharedDir "help.ps1")
. (Join-Path $sharedDir "installed.ps1")
. (Join-Path $sharedDir "choco-utils.ps1")
. (Join-Path $sharedDir "install-paths.ps1")

. (Join-Path $scriptDir "helpers\tortoisegit.ps1")

$config      = Import-JsonConfig (Join-Path $scriptDir "config.json")
$logMessages = Import-JsonConfig (Join-Path $scriptDir "log-messages.json")

$hasHelpFlag = $Help -or ($Command -eq "--help")

if ($hasHelpFlag) {
    Show-ScriptHelp -LogMessages $logMessages
    return
}

Write-Banner -Title $logMessages.scriptName

Write-InstallPaths `
    -Tool   "TortoiseGit" `
    -Source "Chocolatey (tortoisegit 2.4.0.2) | packages.chocolatey.org Nupkg MSI" `
    -Temp   ($env:TEMP + "\TortoiseGitInstall") `
    -Target ($env:ProgramFiles + "\TortoiseGit")
Initialize-Logging -ScriptName $logMessages.scriptName

try {

    Invoke-GitPull

    $isCheckCommand = $Command.ToLower() -eq "check"

    if ($isCheckCommand) {
        $isInstalled = Test-IsTortoiseGitInstalled

        if ($isInstalled) {
            $tgitPath = Get-TortoiseGitPath
            Write-Log "TortoiseGit is installed: $tgitPath" -Level "success"
        } else {
            Write-Log "TortoiseGit is not installed." -Level "warn"
        }

        return
    }

    $isUninstall = $Command.ToLower() -eq "uninstall"

    if ($isUninstall) {
        Uninstall-TortoiseGit -WaConfig $config.tortoisegit -LogMessages $logMessages
        return
    }

    $isInstallSuccess = Install-TortoiseGit -WaConfig $config.tortoisegit -LogMessages $logMessages

    if ($isInstallSuccess) {
        Write-Log $logMessages.messages.setupComplete -Level "success"
    } else {
        Write-Log ($logMessages.messages.installFailed -replace '\{error\}', "Installation failed") -Level "error"
    }

} catch {
    Write-Log "Unhandled error: $_" -Level "error"
    Write-Log "Stack: $($_.ScriptStackTrace)" -Level "error"
} finally {
    $hasLogErrors = ($null -ne (Get-Variable -Name "_LogErrors" -Scope Script -ErrorAction SilentlyContinue)) -and ($null -ne $script:_LogErrors)
    $hasAnyErrors = $hasLogErrors -and ($script:_LogErrors.Count -gt 0)

    if ($null -ne (Get-Command Save-LogFile -ErrorAction SilentlyContinue) -and ($null -ne (Get-Variable -Name "_LogFile" -Scope Script -ErrorAction SilentlyContinue)) -and ($null -ne $script:_LogFile)) {
        Save-LogFile -Status $(if ($hasAnyErrors) { "fail" } else { "ok" })
    }
}
