# ============================================================
# taskbar-align-left.ps1
# Align the Windows 11 taskbar (and Start menu) to the LEFT.
# Usage:
#   .\scripts\taskbar-align-left.ps1          # left-align (default)
#   .\scripts\taskbar-align-left.ps1 -Center  # restore center alignment
# ============================================================
[CmdletBinding()]
param(
    [switch]$Center
)

$value = if ($Center) { 1 } else { 0 }
$label = if ($Center) { 'CENTER' } else { 'LEFT' }
$path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

Write-Host "[taskbar-align] Setting TaskbarAl=$value ($label) at $path" -ForegroundColor Cyan

try {
    New-ItemProperty -Path $path -Name 'TaskbarAl' -Value $value `
        -PropertyType DWord -Force -Confirm:$false | Out-Null
    Stop-Process -Name explorer -Force -ErrorAction Stop
    Write-Host "[taskbar-align] OK - taskbar aligned $label and Explorer restarted." -ForegroundColor Green
}
catch {
    Write-Host "[taskbar-align] FAILED at $path : $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
