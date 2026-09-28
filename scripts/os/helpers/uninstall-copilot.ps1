<#
.SYNOPSIS
    Windows Copilot deep uninstaller, package purger, and policy debloater.
#>

function Write-FileError {
    param(
        [string]$FilePath,
        [string]$Reason,
        [string]$Path = $FilePath
    )

    $target = if ($FilePath) { $FilePath } else { $Path }
    Write-Host "  [ FAIL ] FILE-ERROR path='$target' reason='$Reason'" -ForegroundColor Red
}

function Stop-CopilotProcesses {
    Write-Host "Stopping running Copilot processes..." -ForegroundColor Cyan
    Get-Process -Name "*Copilot*", "*copilot*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 300
}

function Remove-CopilotAppxPackages {
    Write-Host "Removing Copilot AppX packages..." -ForegroundColor Cyan

    try {
        Get-AppxPackage -AllUsers *Copilot* -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -FilePath "AppX:Copilot" -Reason $_.Exception.Message
    }
}

function Remove-CopilotProvisionedPackages {
    Write-Host "Removing Copilot provisioned AppX packages..." -ForegroundColor Cyan

    try {
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object {
            $_.PackageName -like "*Copilot*"
        } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -FilePath "AppXProvisioned:Copilot" -Reason $_.Exception.Message
    }
}

function Set-RegistryDwordSafely {
    param(
        [string]$KeyPath,
        [string]$ValueName,
        [int]$ValueData
    )

    $hasKey = Test-Path -LiteralPath $KeyPath

    if (-not $hasKey) {
        try {
            New-Item -Path $KeyPath -Force -ErrorAction SilentlyContinue | Out-Null
        } catch {
            Write-FileError -FilePath $KeyPath -Reason $_.Exception.Message
            return
        }
    }

    try {
        Set-ItemProperty -Path $KeyPath -Name $ValueName -Value $ValueData -Type DWord -Force -ErrorAction SilentlyContinue
    } catch {
        Write-FileError -FilePath "$KeyPath\$ValueName" -Reason $_.Exception.Message
    }
}

function Set-CopilotDisablePolicies {
    Write-Host "Applying Windows Copilot disable registry policies..." -ForegroundColor Cyan

    Set-RegistryDwordSafely -KeyPath "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -ValueName "TurnOffWindowsCopilot" -ValueData 1
    Set-RegistryDwordSafely -KeyPath "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -ValueName "TurnOffWindowsCopilot" -ValueData 1
    Set-RegistryDwordSafely -KeyPath "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -ValueName "ShowCopilotButton" -ValueData 0
    Set-RegistryDwordSafely -KeyPath "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -ValueName "HubsSidebarEnabled" -ValueData 0
}

function Uninstall-WindowsCopilot {
    Write-Host "Starting Windows Copilot uninstallation..." -ForegroundColor Cyan

    Stop-CopilotProcesses
    Remove-CopilotAppxPackages
    Remove-CopilotProvisionedPackages
    Set-CopilotDisablePolicies

    Write-Host "[  OK  ] Windows Copilot uninstalled and disabled." -ForegroundColor Green
}

Uninstall-WindowsCopilot
