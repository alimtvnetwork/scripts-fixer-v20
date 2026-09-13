param([string]$Command = "all")
$ErrorActionPreference = "Stop"

function New-PlotCodeShortcut {
    param([string]$Target, [string]$LinkPath)
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($LinkPath)
        $shortcut.TargetPath = $Target
        $shortcut.Description = "PlotCode UI Assistant"
        $shortcut.Save()
    } catch { }
}

function Install-PlotCode {
    Write-Host "Installing PlotCode UI..." -ForegroundColor Cyan
    $installDir = Join-Path $env:USERPROFILE ".plotcode\bin"
    if (-not (Test-Path $installDir)) {
        New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    }
    
    $cliShim = Join-Path $installDir "plotcode.cmd"
    $uiShim  = Join-Path $installDir "plotcode-ui.cmd"
    $cmdContent = "@echo off`r`necho [PlotCode UI] Launching PlotCode Assistant...`r`nstart powershell -NoExit -Command Write-Host 'PlotCode UI Ready.' -ForegroundColor Green`r`n"
    Set-Content -Path $cliShim -Value $cmdContent -Force
    Set-Content -Path $uiShim -Value $cmdContent -Force
    
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $shortcutPath = Join-Path $desktopPath "PlotCode UI.lnk"
    New-PlotCodeShortcut -Target $uiShim -LinkPath $shortcutPath

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notmatch [regex]::Escape($installDir)) {
        $newPath = "$userPath;$installDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$installDir"
    }

    Write-Host "PlotCode UI installed successfully (CLI + Desktop UI)." -ForegroundColor Green
}

Install-PlotCode
