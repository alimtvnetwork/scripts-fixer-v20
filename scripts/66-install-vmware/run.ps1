# --------------------------------------------------------------------------
#  Script 66 -- Install VMware Workstation/Player
# --------------------------------------------------------------------------
param(
    [Parameter(Position = 0)]
    [string]$Command = "install"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"

. (Join-Path $sharedDir "logging.ps1")

Write-Banner -Title "Install VMware Workstation/Player"
Initialize-Logging -ScriptName "Install VMware"

function Is-VMwareInstalled {
    $paths = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
    $hasVMware = $false
    foreach ($p in $paths) {
        $items = Get-ItemProperty $p -ErrorAction SilentlyContinue
        foreach ($i in $items) {
            if ($i.PSObject.Properties['DisplayName']) {
                $name = $i.DisplayName
                if ($name -like '*VMware Workstation*' -or $name -like '*VMware Player*') {
                    $hasVMware = $true
                }
            }
        }
    }
    return $hasVMware
}

$dbBridge = Join-Path (Split-Path -Parent $scriptDir) "shared\db_bridge.py"
function Invoke-DbRecord([string]$action, [string[]]$extraArgs) {
    if (Test-Path $dbBridge) {
        python $dbBridge $action @extraArgs 2>$null
    }
}

try {
    Write-Log "Checking for existing VMware installation..." -Level "info"
    $isInstalled = Is-VMwareInstalled

    if ($isInstalled) {
        Write-Log "VMware is already installed." -Level "success"
        Invoke-DbRecord "record-skipped" @("package", "vmware", "already installed")
    } else {
        Invoke-DbRecord "record-start" @("package", "vmware", "install")
        $url = $env:VMWARE_DOWNLOAD_URL
        $isUrlEmpty = [string]::IsNullOrWhiteSpace($url)
        if ($isUrlEmpty) {
            $url = "https://download3.vmware.com/software/WKST-1752-WIN/VMware-workstation-full-17.5.2-23775571.exe"
        }

        $tempPath = Join-Path $env:TEMP "vmware-installer.exe"
        Write-Log "Downloading VMware installer from $url..." -Level "info"
        Invoke-WebRequest -Uri $url -OutFile $tempPath -UseBasicParsing

        Write-Log "Executing installer silently..." -Level "info"
        $proc = Start-Process -FilePath $tempPath -ArgumentList "/s /v`"/qn REBOOT=ReallySuppress`"" -Wait -PassThru

        $isSuccess = $proc.ExitCode -eq 0 -or $proc.ExitCode -eq 3010
        if ($isSuccess) {
            Write-Log "VMware installed successfully." -Level "success"
            Invoke-DbRecord "record-success" @("package", "vmware", "17.5.2", "VMware Workstation installed")
        } else {
            Write-Log "Installer failed with code $($proc.ExitCode)." -Level "error"
            Invoke-DbRecord "record-failure" @("package", "vmware", "$($proc.ExitCode)", "installer failed")
        }

        Write-Log "Cleaning up installer..." -Level "info"
        Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "Error: $_" -Level "error"
    Invoke-DbRecord "record-failure" @("package", "vmware", "1", "$_")
} finally {
    Save-LogFile -Status "ok"
}
