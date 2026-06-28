<#
.SYNOPSIS
    --json output mode helpers. When LOVABLE_JSON_OUT=1, scripts suppress
    decorative Write-Host (via Set-JsonMode) and emit a single JSON envelope
    at the end via Write-JsonEnvelope.

    Conforms to core/contracts/status.schema.json.
#>

function Test-JsonMode {
    return ($env:LOVABLE_JSON_OUT -eq "1")
}

function Set-JsonMode {
    param([switch]$On, [switch]$Off)
    if ($On)  { $env:LOVABLE_JSON_OUT = "1" }
    if ($Off) { $env:LOVABLE_JSON_OUT = "0" }
}

function Write-JsonEnvelope {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$ScriptId,
        [Parameter(Mandatory)] [string]$Command,
        [Parameter(Mandatory)] [string]$Outcome,
        [string]$ScriptName,
        [string]$Version,
        [string]$Method,
        [datetime]$StartedAt = (Get-Date),
        [hashtable]$Paths,
        [hashtable]$Error,
        [hashtable]$Extras
    )
    $finished = Get-Date
    $payload = [ordered]@{
        schemaVersion = "1.0"
        scriptId   = $ScriptId
        scriptName = $ScriptName
        command    = $Command
        platform   = "windows"
        shell      = "powershell"
        outcome    = $Outcome
        version    = if ($Version) { $Version } else { $null }
        method     = if ($Method)  { $Method }  else { $null }
        paths      = if ($Paths)   { $Paths }   else { @{} }
        startedAt  = $StartedAt.ToUniversalTime().ToString("o")
        finishedAt = $finished.ToUniversalTime().ToString("o")
        durationMs = [int]([math]::Max(0, ($finished - $StartedAt).TotalMilliseconds))
        projectVersion = if ($env:LOVABLE_PROJECT_VERSION) { $env:LOVABLE_PROJECT_VERSION } else { "unknown" }
        error      = if ($Error)  { $Error }  else { $null }
        extras     = if ($Extras) { $Extras } else { @{} }
    }
    # Always emit to stdout regardless of JSON mode -- this IS the JSON output.
    Write-Output ($payload | ConvertTo-Json -Compress -Depth 8)
}
