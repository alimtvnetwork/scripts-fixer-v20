# --------------------------------------------------------------------------
#  Script 67 -- Install Cloud CLIs
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

Write-Banner -Title "Install Cloud CLIs"
Initialize-Logging -ScriptName "Install Cloud CLIs"

function Is-AwsInstalled {
    $isFound = (Get-Command aws -ErrorAction SilentlyContinue) -ne $null
    return $isFound
}

function Install-AwsCli {
    $isInstalled = Is-AwsInstalled
    if ($isInstalled) {
        Write-Log "AWS CLI is already installed." -Level "success"
        return
    }
    $url = "https://awscli.amazonaws.com/AWSCLIV2.msi"
    $tempPath = Join-Path $env:TEMP "awscliv2.msi"
    Write-Log "Downloading AWS CLI..." -Level "info"
    Invoke-WebRequest -Uri $url -OutFile $tempPath -UseBasicParsing
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$tempPath`" /qn /norestart" -Wait -NoNewWindow
    Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
}

function Is-GcpInstalled {
    $isFound = (Get-Command gcloud -ErrorAction SilentlyContinue) -ne $null
    return $isFound
}

function Install-GcpSdk {
    $isInstalled = Is-GcpInstalled
    if ($isInstalled) {
        Write-Log "Google Cloud SDK is already installed." -Level "success"
        return
    }
    $url = "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
    $tempPath = Join-Path $env:TEMP "gcp-installer.exe"
    Write-Log "Downloading GCP SDK..." -Level "info"
    Invoke-WebRequest -Uri $url -OutFile $tempPath -UseBasicParsing
    Start-Process -FilePath $tempPath -ArgumentList "/S /norestart" -Wait -NoNewWindow
    Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
}

function Is-AzureInstalled {
    $isFound = (Get-Command az -ErrorAction SilentlyContinue) -ne $null
    return $isFound
}

function Install-AzureCli {
    $isInstalled = Is-AzureInstalled
    if ($isInstalled) {
        Write-Log "Azure CLI is already installed." -Level "success"
        return
    }
    $url = "https://aka.ms/installazurecliwindows"
    $tempPath = Join-Path $env:TEMP "azure-cli.msi"
    Write-Log "Downloading Azure CLI..." -Level "info"
    Invoke-WebRequest -Uri $url -OutFile $tempPath -UseBasicParsing
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$tempPath`" /qn /norestart" -Wait -NoNewWindow
    Remove-Item -Path $tempPath -Force -ErrorAction SilentlyContinue
}

try {
    Install-AwsCli
    Install-GcpSdk
    Install-AzureCli
} catch {
    Write-Log "Error: $_" -Level "error"
} finally {
    Save-LogFile -Status "ok"
}
