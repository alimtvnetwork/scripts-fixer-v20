# Run Beyond Compare 5 installer
param (
    [int]$Version = 5,
    [switch]$Uninstall = $false
)

$scriptRoot = $PSScriptRoot
$repoRoot = Split-Path (Split-Path $scriptRoot -Parent) -Parent
$installerPath = Join-Path $repoRoot "scripts\os\windows\install-bcompare.ps1"

if (-not (Test-Path $installerPath)) {
    $installerPath = Join-Path $scriptRoot "..\os\windows\install-bcompare.ps1"
}

if ($Uninstall) {
    & $installerPath -Version $Version -Uninstall
} else {
    & $installerPath -Version $Version
}
