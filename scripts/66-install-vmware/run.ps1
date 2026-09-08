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
            $hasMatch = $i.DisplayName -like '*VMware Workstation*' -or $i.DisplayName -like '*VMware Player*'
            if ($hasMatch) { $hasVMware = $true }
        }
    }
    return $hasVMware
}

try {
    Write-Log "Checking for existing VMware installation..." -Level "info"
    $isInstalled = Is-VMwareInstalled
    
    if ($isInstalled) {
        Write-Log "VMware is already installed." -Level "success"
    } else {
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
        } else {
            Write-Log "Installer failed with code $($proc.ExitCode)." -Level "error"
        }
        
        Write-Log "Cleaning up installer..." -Level "info"
        Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
    }
} catch {
    Write-Log "Error: $_" -Level "error"
} finally {
    Save-LogFile -Status "ok"
}
