# Profile metadata loader and entry renderer

function Get-HelpProfilePaths {
    $baseDir = if (Test-Path variable:RootDir) { $RootDir } else { (Split-Path (Split-Path $PSScriptRoot -Parent) -Parent) }

    return [pscustomobject]@{
        ConfigPath    = Join-Path $baseDir "scripts\profile\config.json"
        AliasesPath   = Join-Path $baseDir "scripts\profile\profile-aliases.json"
        ValidatorPath = Join-Path $baseDir "scripts\shared\profile-config-validator.ps1"
    }
}

function Load-HelpProfileEntries {
    param([string]$ConfigPath, [bool]$HasValidator)

    $entries = @()
    if ($HasValidator) {
        $cfgValidation = Test-ProfileConfig -FilePath $ConfigPath
        foreach ($pname in $cfgValidation.ProfileNames) {
            $pdef = $null
            try { $pdef = (Get-Content $ConfigPath -Raw | ConvertFrom-Json).profiles.$pname } catch {}
            $plabel = if ($pdef -and $pdef.label) { [string]$pdef.label } else { "" }
            $pdesc  = if ($pdef -and $pdef.description) { [string]$pdef.description } elseif ($plabel) { $plabel } else { "" }
            $entries += [pscustomobject]@{ Name = [string]$pname; Label = $plabel; Description = $pdesc }
        }

        return $entries
    }

    if (Test-Path $ConfigPath) {
        try {
            $cfg = Get-Content $ConfigPath -Raw | ConvertFrom-Json
            foreach ($pname in $cfg.profiles.PSObject.Properties.Name) {
                $pdef   = $cfg.profiles.$pname
                $plabel = if ($pdef.label) { [string]$pdef.label } else { "" }
                $pdesc  = if ($pdef.description) { [string]$pdef.description } elseif ($plabel) { $plabel } else { "" }
                $entries += [pscustomobject]@{ Name = [string]$pname; Label = $plabel; Description = $pdesc }
            }
        } catch {}
    }

    return $entries
}

function Show-HelpProfileItems {
    param([array]$Entries, [hashtable]$AliasesByTarget)

    $pc = 16
    foreach ($entry in $Entries) {
        $line = if ([string]::IsNullOrWhiteSpace($entry.Description)) { $entry.Label } else { $entry.Description }
        Write-Host "    $($entry.Name.PadRight($pc))" -NoNewline -ForegroundColor Green
        Write-Host $line -ForegroundColor $ThemeMuted

        $hasAlias = $AliasesByTarget.ContainsKey($entry.Name)
        if ($hasAlias) {
            foreach ($a in $AliasesByTarget[$entry.Name]) {
                $kindTag = if ($a.Kind -eq "fallback") { "[fallback]" } else { "[exact]   " }
                Write-Host ("    {0}  {1} " -f (" " * $pc), $kindTag) -NoNewline -ForegroundColor DarkCyan
                Write-Host ("{0,-14} -> {1}" -f $a.Name, $entry.Name) -NoNewline -ForegroundColor $ThemeSecondary
                if ($entry.Description) {
                    Write-Host ("  ({0})" -f $entry.Description) -ForegroundColor $ThemeMuted
                } else {
                    Write-Host ""
                }
                if ($a.Kind -eq "fallback" -and $a.Reason) {
                    Write-Host ("    {0}             reason: {1}" -f (" " * $pc), $a.Reason) -ForegroundColor $ThemeMuted
                }
            }
        }
    }
}
