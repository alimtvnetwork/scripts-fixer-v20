<#
.SYNOPSIS
    Antigravity database telemetry helper.
#>

function Record-AntigravityDbSuccess {
    param([string]$Mode = "cli")

    try {
        $parentDir = Split-Path -Parent $PSScriptRoot
        $sharedDir = Join-Path (Split-Path -Parent $parentDir) "shared"
        $bridge = Join-Path $sharedDir "db_bridge.py"
        $hasBridge = Test-Path $bridge

        if ($hasBridge) {
            python $bridge record-success package "antigravity" "1.0.0" "Google Antigravity ($Mode) installed" 2>$null
        }
    } catch { }
}
