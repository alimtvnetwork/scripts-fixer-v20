<#
.SYNOPSIS
    Script runner, version reporting, and installed tag detection for root dispatcher.
#>

function Get-ScriptVersion {
    $vf = Join-Path (Join-Path $RootDir "scripts") "version.json"
    $isPresent = Test-Path $vf
    if ($isPresent) {
        $data = Get-Content $vf -Raw | ConvertFrom-Json
        return $data.version
    }
    return $null
}

function Show-VersionHeader {
    $ver = Get-ScriptVersion
    $hasVersion = -not [string]::IsNullOrWhiteSpace($ver)
    if ($hasVersion) {
        Write-Host ""
        Write-Host "  Scripts Fixer v$ver" -ForegroundColor $ThemePrimary
    }
}

function Show-VersionFooter {
    $ver = Get-ScriptVersion
    if ([string]::IsNullOrWhiteSpace($ver)) { $ver = "unknown" }

        $sha    = "unknown"
    $branch = "unknown"
    $remote = $null
    $time   = "unknown"
    try {
        Push-Location $RootDir
        $hasGit = Get-Command git -ErrorAction SilentlyContinue
        if ($hasGit) {
            $s = (& git rev-parse --short=12 HEAD 2>$null) | Select-Object -First 1
            if ($s) { $sha = "$s".Trim() }
            $b = (& git rev-parse --abbrev-ref HEAD 2>$null) | Select-Object -First 1
            if ($b) { $branch = "$b".Trim() }
            $r = (& git config --get remote.origin.url 2>$null) | Select-Object -First 1
            if ($r) { $remote = "$r".Trim() }
            $t = (& git log -1 --format=%cd --date=local 2>$null) | Select-Object -First 1
            if ($t) { $time = "$t".Trim() }
        }
    } catch {} finally { Pop-Location -ErrorAction SilentlyContinue }

    Write-Host ""
    Write-Host "  scripts-fixer v$ver" -ForegroundColor $ThemePrimary -NoNewline
    Write-Host " | " -ForegroundColor $ThemeMuted -NoNewline
    Write-Host "git $sha ($branch)" -ForegroundColor $ThemeSecondary -NoNewline
    Write-Host " | " -ForegroundColor $ThemeMuted -NoNewline
    Write-Host "$time" -ForegroundColor $ThemeAccent
    if ($remote) {
        Write-Host "  repo: " -ForegroundColor $ThemeMuted -NoNewline
        Write-Host "$remote" -ForegroundColor White
    }
    Write-Host ""
}

# ── Detect installed tool version (quick, no install) ────────────────
function Get-InstalledTag {
    param([string]$ToolCmd, [string]$Flag = "--version", [scriptblock]$Parse)
    $cmd = Get-Command $ToolCmd -ErrorAction SilentlyContinue
    $isMissing = -not $cmd
    if ($isMissing) { return $null }
    try {
        $raw = & $ToolCmd $Flag 2>$null
        $ver = if ($Parse) { & $Parse "$raw" } else { "$raw".Trim() }
        $hasVer = -not [string]::IsNullOrWhiteSpace($ver)
        if ($hasVer) { return $ver }
    } catch {}
    return $null
}

function Get-VersionMap {
    $map = @{}
    $tools = @(
        @{ Id = "01"; Cmd = "code";      Parse = { param($r) ($r -split '\s+')[1] } },
        @{ Id = "02"; Cmd = "choco";     Parse = { param($r) if ($r -match '(\d[\d.]+)') { $Matches[1] } else { $r } } },
        @{ Id = "03"; Cmd = "node";      Parse = { param($r) $r -replace 'v','' } },
        @{ Id = "04"; Cmd = "pnpm";      Parse = { param($r) $r.Trim() } },
        @{ Id = "05"; Cmd = "python";    Parse = { param($r) ($r -replace 'Python\s*','').Trim() } },
        @{ Id = "06"; Cmd = "go";        Flag = "version"; Parse = { param($r) if ($r -match 'go(\d[\d.]+)') { $Matches[1] } else { $r } } },
        @{ Id = "07"; Cmd = "git";       Parse = { param($r) if ($r -match '(\d[\d.]+)') { $Matches[1] } else { $r } } },
        @{ Id = "08"; Cmd = "github";    Parse = { param($r) if ($r -match '(\d[\d.]+)') { $Matches[1] } else { $r } } },
        @{ Id = "09"; Cmd = "g++";       Parse = { param($r) if ($r -match '(\d[\d.]+)') { $Matches[1] } else { $r } } },
        @{ Id = "16"; Cmd = "php";       Parse = { param($r) if ($r -match '(\d[\d.]+)') { $Matches[1] } else { $r } } },
        @{ Id = "17"; Cmd = "pwsh";      Parse = { param($r) ($r -replace 'PowerShell\s*','').Trim() } },
        @{ Id = "38"; Cmd = "flutter";   Parse = { param($r) if ($r -match '(\d[\d.]+)') { $Matches[1] } else { $r } } },
        @{ Id = "39"; Cmd = "dotnet";    Parse = { param($r) $r.Trim() } },
        @{ Id = "40"; Cmd = "java";      Flag = "-version"; Parse = { param($r) if ($r -match '(\d[\d._]+)') { $Matches[1] } else { $r } } },
        @{ Id = "42"; Cmd = "ollama";    Parse = { param($r) if ($r -match '(\d[\d.]+)') { $Matches[1] } else { $r } } }
    )
    foreach ($t in $tools) {
        $flag = if ($t.Flag) { $t.Flag } else { "--version" }
        $ver = Get-InstalledTag -ToolCmd $t.Cmd -Flag $flag -Parse $t.Parse
        $hasVer = -not [string]::IsNullOrWhiteSpace($ver)
        if ($hasVer) { $map[$t.Id] = $ver }
    }

    # Registry/file-based detection for GUI apps without CLI --version
    $regApps = @(
        @{ Id = "08"; Name = "github-desktop";   Paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GitHubDesktop",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\GitHubDesktop",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\GitHubDesktop"
        )},
        @{ Id = "32"; Name = "DBeaver";          Paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DBeaver*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\DBeaver*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\DBeaver*"
        )},
        @{ Id = "33"; Name = "Notepad++";        Paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Notepad++"
        )},
        @{ Id = "34"; Name = "sticky-notes"; Paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Simple Sticky Notes*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Simple Sticky Notes*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Simple Sticky Notes*"
        )},
        @{ Id = "36"; Name = "obs";       Paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OBS Studio",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OBS Studio",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\OBS Studio"
        )},
        @{ Id = "37"; Name = "wt";  Paths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*WindowsTerminal*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*WindowsTerminal*",
            "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*WindowsTerminal*",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*Windows Terminal*",
            "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*Windows Terminal*"
        )}
    )

    foreach ($app in $regApps) {
        $isAlreadyDetected = $map.ContainsKey($app.Id)
        if ($isAlreadyDetected) { continue }

        foreach ($regPath in $app.Paths) {
            $keys = Get-Item $regPath -ErrorAction SilentlyContinue
            $hasKeys = $null -ne $keys
            if (-not $hasKeys) { continue }

            foreach ($key in $keys) {
                $displayVersion = $key.GetValue("DisplayVersion")
                $hasDisplayVersion = -not [string]::IsNullOrWhiteSpace($displayVersion)
                if ($hasDisplayVersion) {
                    $map[$app.Id] = "$displayVersion".Trim()
                    break
                }
            }

            $isNowDetected = $map.ContainsKey($app.Id)
            if ($isNowDetected) { break }
        }
    }

    # Winget detection
    $isWingetMissing = -not $map.ContainsKey("14")
    if ($isWingetMissing) {
        $wingetCmd = Get-Command "winget" -ErrorAction SilentlyContinue
        $hasWinget = $null -ne $wingetCmd
        if ($hasWinget) {
            try {
                $wingetRaw = & winget --version 2>$null
                $wingetVer = "$wingetRaw".Trim() -replace '^v',''
                $hasWingetVer = -not [string]::IsNullOrWhiteSpace($wingetVer)
                if ($hasWingetVer) { $map["14"] = $wingetVer }
            } catch {}
        }
    }

    return $map
}



function Invoke-ScriptById {
    param(
        [int]$ScriptId,
        [hashtable]$ExtraArgs = @{}
    )

    $prefix = "{0:D2}" -f $ScriptId
    $registryPath = Join-Path $RootDir "scripts\registry.json"
    $isRegistryAvailable = Test-Path $registryPath

    $scriptDir = $null
    if ($isRegistryAvailable) {
        $registry = Get-Content $registryPath -Raw | ConvertFrom-Json
        $folderName = $registry.scripts.$prefix

        $isRegistered = [bool]$folderName
        if ($isRegistered) {
            $scriptDir = Get-Item (Join-Path $RootDir "scripts\$folderName") -ErrorAction SilentlyContinue
        }
    } else {
        $pattern = Join-Path $RootDir "scripts/$prefix-*"
        $scriptDir = @(Get-Item $pattern -ErrorAction SilentlyContinue |
            Where-Object { $_.PSIsContainer -and (Test-Path (Join-Path $_.FullName "run.ps1")) }) |
            Select-Object -First 1
    }

    $isScriptMissing = -not $scriptDir -or -not (Test-Path $scriptDir.FullName)
    if ($isScriptMissing) {
        Write-Host ""
        Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
        Write-Host "No script folder found for ID $prefix"
        return $false
    }

    $scriptFile = Join-Path $scriptDir.FullName "run.ps1"
    $isRunFileMissing = -not (Test-Path $scriptFile)
    if ($isRunFileMissing) {
        Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
        Write-Host "run.ps1 not found in $($scriptDir.Name)"
        return $false
    }

    # Clean & create logs folder
    $logsDir = Join-Path $scriptDir.FullName "logs"
    if (Test-Path $logsDir) {
        Remove-Item -Path $logsDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    New-Item -Path $logsDir -ItemType Directory -Force | Out-Null

    Write-Host ""
    Write-Host "  [ RUN   ] " -ForegroundColor $ThemePrimary -NoNewline
    Write-Host "Executing: $($scriptDir.Name)\run.ps1"
    Write-Host ""

    # Final sanity check on the splat hashtable -- catches malformed path
    # values that survived the early dispatcher check (e.g. ones added by
    # group expansion or by another helper).
    $hasArgValidator = $null -ne (Get-Command Test-ChildScriptArgs -ErrorAction SilentlyContinue)
    if ($hasArgValidator) {
        $isChildArgsOk = Test-ChildScriptArgs -ExtraArgs $ExtraArgs -ScriptId $ScriptId
        if (-not $isChildArgsOk) {
            Write-Host "  [ SKIP ] Refusing to invoke child script with malformed path arguments." -ForegroundColor $ThemeError
            return $false
        }
    }

    # Build a copy-pasteable, fully-quoted preview of the exact child command
    # line so the user can see every resolved parameter value (paths, flags,
    # switches) before -- and as -- it runs.
    $cmdPreviewParts = New-Object System.Collections.Generic.List[string]
    $quotedScript = '"' + $scriptFile + '"'
    $cmdPreviewParts.Add('&') | Out-Null
    $cmdPreviewParts.Add($quotedScript) | Out-Null

    if ($ExtraArgs -is [hashtable]) {
        foreach ($key in ($ExtraArgs.Keys | Sort-Object)) {
            $val = $ExtraArgs[$key]
            if ($null -eq $val) {
                $cmdPreviewParts.Add("-$key") | Out-Null
                continue
            }
            if ($val -is [bool] -or $val -is [switch]) {
                if ([bool]$val) { $cmdPreviewParts.Add("-$key") | Out-Null }
                continue
            }
            if ($val -is [System.Array]) {
                $joined = ($val | ForEach-Object { '"' + ([string]$_).Replace('"','`"') + '"' }) -join ','
                $cmdPreviewParts.Add("-$key $joined") | Out-Null
                continue
            }
            $sval = [string]$val
            $escaped = $sval.Replace('"','`"')
            $cmdPreviewParts.Add("-$key `"$escaped`"") | Out-Null
        }
    }
    elseif ($ExtraArgs) {
        foreach ($a in @($ExtraArgs)) {
            if ($null -eq $a) { continue }
            $sa = [string]$a
            if ($sa -match '^-' -or ($sa -notmatch '\s')) {
                $cmdPreviewParts.Add($sa) | Out-Null
            } else {
                $cmdPreviewParts.Add('"' + $sa.Replace('"','`"') + '"') | Out-Null
            }
        }
    }

    $cmdPreview = $cmdPreviewParts -join ' '

    Write-Host "  [ CMD  ] " -ForegroundColor DarkCyan -NoNewline
    Write-Host $cmdPreview -ForegroundColor Gray
    Write-Host ""

    if (Get-Command Write-Log -ErrorAction SilentlyContinue) {
        try {
            Write-Log -Level "info" -Event "child.invoke" -Data @{
                scriptId = $ScriptId
                script   = $scriptFile
                command  = $cmdPreview
            }
        } catch { }
    }

    # ------------------------------------------------------------------
    # Bulletproof child invocation
    # ------------------------------------------------------------------
    # `& $scriptFile @ExtraArgs` is fragile: if $ExtraArgs is ever an
    # ARRAY (not a hashtable) and its first element is an unquoted path
    # like "C:\Program Files\foo", PowerShell tries to execute that path
    # as a command and dies with:
    #   The term 'C:\Program' is not recognized as the name of a cmdlet...
    #
    # We have already validated $ExtraArgs above, but we add one more
    # safety net here so the failure mode -- if it ever recurs -- is a
    # clear logged error instead of a cryptic CommandNotFoundException.
    # ------------------------------------------------------------------

    $isExtraArgsHashtable = $ExtraArgs -is [hashtable]
    $isExtraArgsEmpty     = $null -eq $ExtraArgs -or `
                            ($isExtraArgsHashtable -and $ExtraArgs.Count -eq 0) -or `
                            (-not $isExtraArgsHashtable -and @($ExtraArgs).Count -eq 0)

    try {
        if ($isExtraArgsEmpty) {
            # No args -- safest path. Quote $scriptFile defensively even
            # though dispatcher-built paths never contain spaces.
            & "$scriptFile"
        }
        elseif ($isExtraArgsHashtable) {
            # Named-parameter splat -- safe even with spaces in values.
            & "$scriptFile" @ExtraArgs
        }
        else {
            # Array form -- this is the dangerous case. Coerce every
            # element to a string and pass via the array splat. PowerShell
            # will treat each element as a single argument (NOT re-parse
            # spaces), so "C:\Program Files\x" stays one arg.
            $argList = @()
            foreach ($a in @($ExtraArgs)) {
                if ($null -eq $a) { continue }
                $argList += [string]$a
            }
            & "$scriptFile" @argList
        }
    } catch [System.Management.Automation.CommandNotFoundException] {
        # The classic "C:\Program is not recognized" failure. Log the
        # exact offending token + the full ExtraArgs payload so the next
        # run is debuggable instead of mysterious.
        $token = $_.Exception.CommandName
        $dump  = try { ($ExtraArgs | ConvertTo-Json -Depth 5 -Compress) } catch { "$ExtraArgs" }
        Write-Host ""
        Write-Host "  [ FAIL ] " -ForegroundColor $ThemeError -NoNewline
        Write-Host "Child invocation failed: PowerShell tried to execute '$token' as a command." -ForegroundColor White
        Write-Host "          script    : $scriptFile" -ForegroundColor $ThemeMuted
        Write-Host "          ExtraArgs : $dump"        -ForegroundColor $ThemeMuted
        Write-Host "          hint      : a path containing spaces was passed unquoted into a positional parameter." -ForegroundColor $ThemeAccent

        if (Get-Command Write-FileError -ErrorAction SilentlyContinue) {
            Write-FileError -FilePath $token -Operation "invoke-child" `
                -Reason "Token '$token' parsed as command. ExtraArgs=$dump" -Module "Invoke-ScriptById"
        }
        return $false
    }
    return $true
}

# ── Load choco-update helper ─────────────────────────────────────────
. (Join-Path $RootDir "scripts\shared\choco-update.ps1")


