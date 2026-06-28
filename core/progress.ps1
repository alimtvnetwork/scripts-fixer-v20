<#
.SYNOPSIS
    Progress + ETA wrapper. Computes ETA from elapsed/percent and forwards
    to Write-Progress. Honors $env:LOVABLE_JSON_OUT (silent in JSON mode).
#>
$script:__ProgressStart = @{}

function Start-ProgressETA {
    param([Parameter(Mandatory)] [string]$Id, [Parameter(Mandatory)] [string]$Activity)
    $script:__ProgressStart[$Id] = [pscustomobject]@{ Start = Get-Date; Activity = $Activity }
}

function Write-ProgressETA {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Id,
        [Parameter(Mandatory)] [int]$PercentComplete,
        [string]$Status = ""
    )
    if ($env:LOVABLE_JSON_OUT -eq "1") { return }
    $info = $script:__ProgressStart[$Id]
    if (-not $info) { Start-ProgressETA -Id $Id -Activity "Working"; $info = $script:__ProgressStart[$Id] }
    $elapsed = (Get-Date) - $info.Start
    $eta = "?"
    if ($PercentComplete -gt 0 -and $PercentComplete -lt 100) {
        $totalSec = $elapsed.TotalSeconds * (100.0 / $PercentComplete)
        $remaining = [TimeSpan]::FromSeconds([math]::Max(0, $totalSec - $elapsed.TotalSeconds))
        $eta = "{0:mm\:ss}" -f $remaining
    } elseif ($PercentComplete -ge 100) { $eta = "00:00" }
    $full = if ($Status) { "$Status -- ETA $eta" } else { "ETA $eta" }
    Write-Progress -Activity $info.Activity -Status $full -PercentComplete ([math]::Min(100, [math]::Max(0, $PercentComplete)))
}

function Stop-ProgressETA {
    param([Parameter(Mandatory)] [string]$Id)
    $info = $script:__ProgressStart[$Id]
    if ($info) { Write-Progress -Activity $info.Activity -Completed; $script:__ProgressStart.Remove($Id) | Out-Null }
}
