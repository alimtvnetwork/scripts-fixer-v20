param([string]$Command = "install")

function Install-Utorrent {
    Write-Host "Installing uTorrent..." -ForegroundColor Cyan
    choco install utorrent -y
}

function Uninstall-Utorrent {
    Write-Host "Uninstalling uTorrent..." -ForegroundColor Cyan
    choco uninstall utorrent -y
}

$isInstall = $Command -eq "install" -or $Command -eq "all"
$isUninstall = $Command -eq "uninstall"

if ($isInstall) {
    Install-Utorrent
} elseif ($isUninstall) {
    Uninstall-Utorrent
}
