# Theme and version helpers for root-help

if (-not (Test-Path variable:ThemePrimary)) {
    $ThemePrimary = "Green"
}

if (-not (Test-Path variable:ThemeSecondary)) {
    $ThemeSecondary = "Cyan"
}

if (-not (Test-Path variable:ThemeAccent)) {
    $ThemeAccent = "Yellow"
}

if (-not (Test-Path variable:ThemeMuted)) {
    $ThemeMuted = "DarkGray"
}

if (-not (Test-Path variable:ThemeError)) {
    $ThemeError = "Red"
}

function Show-VersionHeaderSafe {
    $hasCmd = $null -ne (Get-Command Show-VersionHeader -ErrorAction SilentlyContinue)

    if ($hasCmd) {
        Show-VersionHeader
    }
}

function Show-VersionFooterSafe {
    $hasCmd = $null -ne (Get-Command Show-VersionFooter -ErrorAction SilentlyContinue)

    if ($hasCmd) {
        Show-VersionFooter
    }
}
