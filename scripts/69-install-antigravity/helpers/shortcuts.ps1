<#
.SYNOPSIS
    Desktop and Start Menu shortcut helpers for Antigravity.
#>

function New-AntigravityShortcut {
    param(
        [Parameter(Mandatory = $true)][string]$TargetPath,
        [Parameter(Mandatory = $true)][string]$ShortcutPath,
        [string]$Description = "Google Antigravity",
        [string]$IconLocation
    )

    try {
        $parent = Split-Path -Parent $ShortcutPath
        $hasParent = Test-Path $parent

        if (-not $hasParent) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($ShortcutPath)
        $shortcut.TargetPath = $TargetPath
        $shortcut.WorkingDirectory = Split-Path -Parent $TargetPath
        $shortcut.Description = $Description

        if ($IconLocation) {
            $shortcut.IconLocation = $IconLocation
        }

        $shortcut.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
    } catch {
        Write-Host "  [ NOTE ] Failed to create shortcut at $ShortcutPath : $($_.Exception.Message)" -ForegroundColor DarkGray
    }
}

function Create-DesktopShortcut {
    param([string]$TargetExe)

    $desktopDir = [Environment]::GetFolderPath("Desktop")
    $hasDesktop = $desktopDir -and (Test-Path $desktopDir)

    if ($hasDesktop) {
        $desktopShortcut = Join-Path $desktopDir "Antigravity.lnk"
        New-AntigravityShortcut -TargetPath $TargetExe -ShortcutPath $desktopShortcut -Description "Google Antigravity" -IconLocation "$TargetExe,0"
        Write-Host "Created Desktop shortcut: $desktopShortcut" -ForegroundColor Cyan
    }
}

function Create-StartMenuShortcut {
    param([string]$TargetExe)

    $programsDir = [Environment]::GetFolderPath("Programs")
    $hasPrograms = $programsDir -and (Test-Path $programsDir)

    if ($hasPrograms) {
        $startMenuShortcut = Join-Path $programsDir "Antigravity.lnk"
        New-AntigravityShortcut -TargetPath $TargetExe -ShortcutPath $startMenuShortcut -Description "Google Antigravity" -IconLocation "$TargetExe,0"
        Write-Host "Created Start Menu shortcut: $startMenuShortcut" -ForegroundColor Cyan
    }
}

function Create-Shortcuts {
    param(
        [string]$IdePath,
        [Parameter(Mandatory = $true)][string]$InstallDir
    )

    $hasIde = $IdePath -and (Test-Path $IdePath)
    $targetExe = if ($hasIde) { $IdePath } else { Join-Path $InstallDir "antigravity.exe" }

    Create-DesktopShortcut -TargetExe $targetExe
    Create-StartMenuShortcut -TargetExe $targetExe
}
