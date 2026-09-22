<#
.SYNOPSIS
    Dev directory path configuration and display for root dispatcher.
#>

function Invoke-PathCommand {
    param([string[]]$Args)

    # Load dev-dir helper
    $devDirHelper = Join-Path $RootDir "scripts\shared\dev-dir.ps1"
    $isHelperMissing = -not (Test-Path $devDirHelper)
    if ($isHelperMissing) {
        Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
        Write-Host "Shared helper not found: $devDirHelper"
        return
    }
    . $devDirHelper

    $firstArg = if ($Args -and $Args.Count -gt 0) { $Args[0].Trim() } else { "" }
    $isReset = $firstArg -eq "--reset" -or $firstArg -eq "reset"
    $isShowOnly = [string]::IsNullOrWhiteSpace($firstArg)

    if ($isReset) {
        Remove-SavedDevPath
        Write-Host ""
        Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
        Write-Host "Saved dev directory cleared. Smart detection will be used."
        Write-Host ""
        return
    }

    if ($isShowOnly) {
        $savedPath = Get-SavedDevPath
        $hasSavedPath = $null -ne $savedPath
        Write-Host ""
        if ($hasSavedPath) {
            Write-Host "  Current dev directory: " -NoNewline -ForegroundColor $ThemeMuted
            Write-Host "$savedPath" -ForegroundColor White
        } else {
            Write-Host "  No saved dev directory. Using smart detection (E:\dev-tool > D:\dev-tool > best drive)." -ForegroundColor $ThemeAccent
        }
        Write-Host ""
        Write-Host "  Usage:" -ForegroundColor $ThemeAccent
        Write-Host "    .\run.ps1 path D:\dev-tool          " -NoNewline; Write-Host "Set default dev directory" -ForegroundColor $ThemeMuted
        Write-Host "    .\run.ps1 path                      " -NoNewline; Write-Host "Show current dev directory" -ForegroundColor $ThemeMuted
        Write-Host "    .\run.ps1 path --reset              " -NoNewline; Write-Host "Clear saved path, use smart detection" -ForegroundColor $ThemeMuted
        Write-Host ""
        return
    }

    # Validate the path
    $targetPath = $firstArg
    $isValidFormat = $targetPath -match '^[A-Za-z]:\\'
    if (-not $isValidFormat) {
        Write-Host ""
        Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
        Write-Host "Invalid path format. Use a full path like D:\dev-tool or F:\dev-tool"
        Write-Host ""
        return
    }

    Set-SavedDevPath -Path $targetPath
    Write-Host ""
    Write-Host "  [  OK  ] " -ForegroundColor Green -NoNewline
    Write-Host "Default dev directory set to: $targetPath"
    Write-Host ""
    Write-Host "  All scripts will now use this path. Use '.\run.ps1 path --reset' to revert to smart detection." -ForegroundColor $ThemeMuted
    Write-Host ""
}

