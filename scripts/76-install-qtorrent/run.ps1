param([string]$Command = "install")

function Install-Qbittorrent {
    Write-Host "Installing qBittorrent..." -ForegroundColor Cyan
    choco install qbittorrent -y
}

function Uninstall-Qbittorrent {
    Write-Host "Uninstalling qBittorrent..." -ForegroundColor Cyan
    choco uninstall qbittorrent -y
}

$isInstall = $Command -eq "install" -or $Command -eq "all"
$isUninstall = $Command -eq "uninstall"

if ($isInstall) {
    Install-Qbittorrent
} elseif ($isUninstall) {
    Uninstall-Qbittorrent
}
