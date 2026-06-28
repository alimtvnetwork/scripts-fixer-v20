<#
.SYNOPSIS
    Lovable unified state store (PowerShell side).

.DESCRIPTION
    Append-only JSONL at .state/events.jsonl. Single source for doctor/audit/kimodo.
#>

$script:StateRoot = if ($env:LOVABLE_STATE_ROOT) { $env:LOVABLE_STATE_ROOT } else {
    Join-Path (Split-Path -Parent $PSScriptRoot) ".state"
}
$script:StateLog = Join-Path $script:StateRoot "events.jsonl"

function Initialize-State {
    $isPresent = Test-Path $script:StateRoot
    if (-not $isPresent) {
        try { New-Item -ItemType Directory -Path $script:StateRoot -Force | Out-Null }
        catch {
            Write-Host "[STATE FAIL] cannot create '$script:StateRoot' -- $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    if (-not (Test-Path $script:StateLog)) {
        try { New-Item -ItemType File -Path $script:StateLog -Force | Out-Null }
        catch {
            Write-Host "[STATE FAIL] cannot create '$script:StateLog' -- $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }
    return $true
}

function Write-StateEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$ScriptId,
        [Parameter(Mandatory)] [string]$Command,
        [Parameter(Mandatory)] [string]$Outcome,
        [string]$Version,
        [string]$Method,
        [string]$ScriptName,
        [int]$DurationMs = 0,
        [hashtable]$Error,
        [hashtable]$Paths
    )
    $isReady = Initialize-State
    if (-not $isReady) { return }

    $payload = [ordered]@{
        ts             = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        scriptId       = $ScriptId
        scriptName     = $ScriptName
        command        = $Command
        platform       = "windows"
        outcome        = $Outcome
        version        = if ($Version) { $Version } else { $null }
        method         = if ($Method) { $Method } else { $null }
        paths          = if ($Paths)  { $Paths }   else { @{} }
        durationMs     = $DurationMs
        projectVersion = if ($env:LOVABLE_PROJECT_VERSION) { $env:LOVABLE_PROJECT_VERSION } else { "unknown" }
        host           = $env:COMPUTERNAME
        user           = $env:USERNAME
        error          = if ($Error) { $Error } else { $null }
    }
    $json = ($payload | ConvertTo-Json -Compress -Depth 6)
    try {
        Add-Content -Path $script:StateLog -Value $json -Encoding UTF8
    }
    catch {
        Write-Host "[STATE FAIL] append failed at '$script:StateLog' -- $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Get-StateEvents {
    [CmdletBinding()]
    param(
        [string]$ScriptId,
        [string]$Outcome,
        [int]$Last = 0
    )
    if (-not (Test-Path $script:StateLog)) { return @() }
    $lines = Get-Content -Path $script:StateLog -Encoding UTF8
    $events = foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) { continue }
        try { $line | ConvertFrom-Json } catch { continue }
    }
    if ($ScriptId) { $events = $events | Where-Object { $_.scriptId -eq $ScriptId } }
    if ($Outcome)  { $events = $events | Where-Object { $_.outcome  -eq $Outcome  } }
    if ($Last -gt 0) { $events = $events | Select-Object -Last $Last }
    return $events
}

Export-ModuleMember -Function Write-StateEvent, Get-StateEvents, Initialize-State -ErrorAction SilentlyContinue
