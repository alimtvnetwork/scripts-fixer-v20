function Install-Jq {
    if (Get-Command jq -ErrorAction SilentlyContinue) { Write-Host "jq is already installed." -ForegroundColor Green; return }
    Write-Host "Installing jq via Scoop..."
    scoop install jq
}
function Install-Yq {
    if (Get-Command yq -ErrorAction SilentlyContinue) { Write-Host "yq is already installed." -ForegroundColor Green; return }
    Write-Host "Installing yq via Scoop..."
    scoop install yq
}
function Install-Zellij {
    if (Get-Command zellij -ErrorAction SilentlyContinue) { Write-Host "Zellij is already installed." -ForegroundColor Green; return }
    Write-Host "Installing Zellij via Scoop..."
    scoop install zellij
}
function Install-Fnm {
    if (Get-Command fnm -ErrorAction SilentlyContinue) { Write-Host "fnm is already installed." -ForegroundColor Green; return }
    Write-Host "Installing fnm via Scoop..."
    scoop install fnm
    $profilePath = $PROFILE
    if (-not (Test-Path $profilePath)) { New-Item -Path $profilePath -ItemType File -Force | Out-Null }
    $fnmEnv = 'fnm env --use-on-cd | Out-String | Invoke-Expression'
    if (-not ((Get-Content $profilePath -Raw) -match "fnm env")) {
        Add-Content -Path $profilePath -Value $fnmEnv
        Write-Host "Added fnm env to $profilePath" -ForegroundColor Green
    }
}
function Install-Uv {
    if (Get-Command uv -ErrorAction SilentlyContinue) { Write-Host "uv is already installed." -ForegroundColor Green; return }
    Write-Host "Installing uv via Scoop..."
    scoop install uv
}
function Install-Rustup {
    if (Get-Command rustup -ErrorAction SilentlyContinue) { Write-Host "rustup is already installed." -ForegroundColor Green; return }
    Write-Host "Installing rustup via Scoop..."
    scoop install rustup
}
function Install-PostgreSQL-Scoop {
    if (Get-Command psql -ErrorAction SilentlyContinue) { Write-Host "PostgreSQL is already installed." -ForegroundColor Green; return }
    Write-Host "Installing PostgreSQL via Scoop..."
    scoop install postgresql
}
function Install-MongoDB-Scoop {
    if (Get-Command mongosh -ErrorAction SilentlyContinue) { Write-Host "MongoDB is already installed." -ForegroundColor Green; return }
    Write-Host "Installing MongoDB via Scoop..."
    scoop install mongodb
}
function Install-DBeaver-Scoop {
    if (Get-Command dbeaver -ErrorAction SilentlyContinue) { Write-Host "DBeaver is already installed." -ForegroundColor Green; return }
    Write-Host "Installing DBeaver via Scoop (extras bucket)..."
    scoop bucket add extras
    scoop install dbeaver
}
function Install-Compass-Scoop {
    if (Get-Command mongodb-compass -ErrorAction SilentlyContinue) { Write-Host "MongoDB Compass is already installed." -ForegroundColor Green; return }
    Write-Host "Installing MongoDB Compass via Scoop (extras bucket)..."
    scoop bucket add extras
    scoop install mongodb-compass
}
function Install-PgAdmin-Scoop {
    if (Get-Command pgadmin4 -ErrorAction SilentlyContinue) { Write-Host "pgAdmin is already installed." -ForegroundColor Green; return }
    Write-Host "Installing pgAdmin via Scoop (extras bucket)..."
    scoop bucket add extras
    scoop install pgadmin4
}
function Show-DatabaseMenu {
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host " Database Installer Menu " -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host "1) PostgreSQL"
    Write-Host "2) MongoDB"
    Write-Host "3) DBeaver"
    Write-Host "4) MongoDB Compass"
    Write-Host "5) pgAdmin"
    Write-Host "q) Quit"
    $choice = Read-Host "Select an option"
    switch ($choice) {
        "1" { Install-PostgreSQL-Scoop }
        "2" { Install-MongoDB-Scoop }
        "3" { Install-DBeaver-Scoop }
        "4" { Install-Compass-Scoop }
        "5" { Install-PgAdmin-Scoop }
        "q" { Write-Host "Exiting menu." }
        default { Write-Host "Invalid choice." }
    }
}
