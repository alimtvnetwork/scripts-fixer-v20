function Install-TerminalUtils {
    Write-Host "Installing Terminal Utilities..."
    scoop install jq yq zellij
}
function Install-LangManagers {
    Write-Host "Installing Language Managers..."
    scoop install fnm uv rustup
}
