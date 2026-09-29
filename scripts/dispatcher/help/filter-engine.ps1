# Stream capture and keyword filtering engine for help text

function Get-HelpFilterNeedles {
    param([string]$Filter)

    if ([string]::IsNullOrWhiteSpace($Filter)) {
        return @()
    }

    return @(
        $Filter.ToLower() -split '[\s,]+' |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_.Length -gt 0 }
    )
}

function Convert-HelpRecordToItem {
    param($Record)

    $msg = ""; $fg = $null; $nl = $false
    if ($Record -is [System.Management.Automation.InformationRecord]) {
        $data = $Record.MessageData
        if ($data -is [System.Management.Automation.HostInformationMessage]) {
            $msg = [string]$data.Message
            $fg  = $data.ForegroundColor
            $nl  = [bool]$data.NoNewLine
        } else {
            $msg = [string]$data
        }
    } else {
        $msg = [string]$Record
    }

    return [pscustomobject]@{ Message = $msg; ForegroundColor = $fg; NoNewLine = $nl }
}

function Emit-HelpMatchedLine {
    param([System.Collections.Generic.List[object]]$Pending)

    foreach ($p in $Pending) {
        $hp = @{ Object = $p.Message; NoNewline = $true }
        if ($null -ne $p.ForegroundColor -and [int]$p.ForegroundColor -ge 0) {
            $hp.ForegroundColor = $p.ForegroundColor
        }
        Write-Host @hp
    }

    Write-Host ""
}

function Execute-HelpFilterSearch {
    param([array]$Records, [array]$Needles)

    $pending = New-Object System.Collections.Generic.List[object]
    $matched = 0
    $matchedPlain = New-Object System.Collections.Generic.List[string]
    $matchedRich = New-Object System.Collections.Generic.List[object]
    $perTermCounts = [ordered]@{}
    foreach ($n in $Needles) { $perTermCounts[$n] = 0 }

    foreach ($rec in $Records) {
        $item = Convert-HelpRecordToItem -Record $rec
        $pending.Add($item)

        if (-not $item.NoNewLine) {
            $combined = -join ($pending | ForEach-Object { $_.Message })
            $combinedLower = $combined.ToLower()
            $isMatch = $true
            foreach ($n in $Needles) {
                if ($combinedLower.Contains($n)) { $perTermCounts[$n]++ } else { $isMatch = $false }
            }

            if ($isMatch) {
                Emit-HelpMatchedLine -Pending $pending
                $matched++
                $matchedPlain.Add($combined.TrimEnd())
                $segments = @($pending | ForEach-Object {
                    $colorName = if ($null -ne $_.ForegroundColor) { "$($_.ForegroundColor)" } else { $null }
                    [pscustomobject]@{ text = $_.Message; color = $colorName }
                })
                $matchedRich.Add([pscustomobject]@{ line = $combined.TrimEnd(); segments = $segments })
            }

            $pending.Clear()
        }
    }

    return [pscustomobject]@{
        MatchCount    = $matched
        MatchedPlain  = $matchedPlain
        MatchedRich   = $matchedRich
        PerTermCounts = $perTermCounts
    }
}
