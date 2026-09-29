# Dynamic dev directory and drive detection helper

function Get-HelpSavedDevPath {
    $baseDir = if (Test-Path variable:RootDir) { $RootDir } else { (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) }
    $helperPath = Join-Path $baseDir "scripts\shared\dev-dir.ps1"
    $isHelperPresent = Test-Path $helperPath

    if (-not $isHelperPresent) {
        return $null
    }

    try {
        . $helperPath
        return Get-SavedDevPath
    } catch {
        return $null
    }
}

function Scan-HelpBestDrive {
    param([int]$MinFreeGB, [string]$SysLetter)

    $disks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop
    $diskMap = @{}
    foreach ($d in $disks) {
        $letter = $d.DeviceID.Substring(0, 1)
        $diskMap[$letter] = [math]::Round($d.FreeSpace / 1GB, 1)
    }

    $hasGoodE = $diskMap.ContainsKey("E") -and $diskMap["E"] -ge $MinFreeGB
    if ($hasGoodE) {
        return [pscustomobject]@{ Letter = "E"; Source = "auto-detected: E: drive ($($diskMap['E']) GB free)" }
    }

    $hasGoodD = $diskMap.ContainsKey("D") -and $diskMap["D"] -ge $MinFreeGB
    if ($hasGoodD) {
        return [pscustomobject]@{ Letter = "D"; Source = "auto-detected: D: drive ($($diskMap['D']) GB free)" }
    }

    $best = $diskMap.GetEnumerator() |
        Where-Object { $_.Key -ne $SysLetter -and $_.Key -ne "E" -and $_.Key -ne "D" -and $_.Value -ge $MinFreeGB } |
        Sort-Object Value -Descending | Select-Object -First 1

    $hasBest = $null -ne $best
    if ($hasBest) {
        return [pscustomobject]@{ Letter = $best.Key; Source = "auto-detected: $($best.Key): drive ($($best.Value) GB free)" }
    }

    return $null
}

function Resolve-HelpDefaultDevDirectory {
    $savedPath = Get-HelpSavedDevPath
    $hasSavedPath = -not [string]::IsNullOrWhiteSpace($savedPath)

    if ($hasSavedPath) {
        return [pscustomobject]@{ Default = $savedPath; Source = "saved via .\run.ps1 path" }
    }

    $minFreeGB = 10
    $sysLetter = if ([string]::IsNullOrWhiteSpace($env:SystemDrive)) { "C" } else { $env:SystemDrive.TrimEnd('\').Substring(0, 1) }
    $bestDrive = $null
    try {
        $bestDrive = Scan-HelpBestDrive -MinFreeGB $minFreeGB -SysLetter $sysLetter
    } catch {}

    $hasBestDrive = $null -ne $bestDrive
    if ($hasBestDrive) {
        return [pscustomobject]@{ Default = "$($bestDrive.Letter):\dev-tool"; Source = $bestDrive.Source }
    }

    return [pscustomobject]@{ Default = "${sysLetter}:\dev-tool"; Source = "fallback to system drive (no qualified drive >= $minFreeGB GB free)" }
}

function Show-HelpDevDrive {
    $resolved = Resolve-HelpDefaultDevDirectory

    Write-Host "    Default dev directory: " -NoNewline -ForegroundColor $ThemeMuted
    Write-Host "$($resolved.Default) " -NoNewline -ForegroundColor White
    Write-Host "($($resolved.Source))" -ForegroundColor $ThemeMuted
    Write-Host "    Override with: " -NoNewline -ForegroundColor $ThemeMuted; Write-Host ".\run.ps1 -I 12 -- -Path F:\dev-tool" -ForegroundColor White
    Write-Host "    Default VS Code edition: " -NoNewline -ForegroundColor $ThemeMuted; Write-Host "Stable" -ForegroundColor White
    Write-Host "    Default sync mode: " -NoNewline -ForegroundColor $ThemeMuted; Write-Host "Overwrite" -ForegroundColor White
    Write-Host ""
}
