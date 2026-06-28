<#
.SYNOPSIS
    Cross-platform interactive picker (PowerShell side).
    Backend preference: Out-ConsoleGridView (PS7) -> fzf -> numbered prompt.
#>
function Get-PickerBackend {
    if ($env:LOVABLE_PICKER) { return $env:LOVABLE_PICKER }
    $hasOcgv = Get-Command Out-ConsoleGridView -ErrorAction SilentlyContinue
    if ($hasOcgv) { return "ocgv" }
    $hasFzf = Get-Command fzf -ErrorAction SilentlyContinue
    if ($hasFzf) { return "fzf" }
    return "numbered"
}

function Select-Item {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string]$Title,
        [Parameter(Mandatory)] [string[]]$Items,
        [switch]$Multi
    )
    $backend = Get-PickerBackend
    switch ($backend) {
        "ocgv" {
            $mode = if ($Multi) { "Multiple" } else { "Single" }
            return $Items | Out-ConsoleGridView -Title $Title -OutputMode $mode
        }
        "fzf" {
            $fzfArgs = @("--prompt", "$Title > ", "--height=40%", "--reverse")
            if ($Multi) { $fzfArgs += "--multi" }
            return $Items | & fzf @fzfArgs
        }
        default {
            Write-Host $Title -ForegroundColor Cyan
            for ($i=0; $i -lt $Items.Count; $i++) {
                Write-Host ("  {0,2}) {1}" -f ($i+1), $Items[$i])
            }
            $prompt = if ($Multi) { "choice (comma-separated, ranges 1-3 ok)" } else { "choice" }
            $raw = Read-Host $prompt
            $picks = New-Object System.Collections.Generic.List[string]
            foreach ($tok in $raw.Split(',').Trim()) {
                if ($tok -match '^(\d+)-(\d+)$') {
                    for ($j=[int]$Matches[1]; $j -le [int]$Matches[2]; $j++) { $picks.Add($Items[$j-1]) | Out-Null }
                } elseif ($tok -match '^\d+$') {
                    $picks.Add($Items[[int]$tok - 1]) | Out-Null
                }
            }
            if ($Multi) { return $picks } else { return $picks[0] }
        }
    }
}
