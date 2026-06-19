# --------------------------------------------------------------------------
#  Chrome Profile Copy / Export / Import helpers
#  Spec: spec/58-install-chrome/profile-copy.md
# --------------------------------------------------------------------------
#
# Public functions:
#   Get-ChromeUserDataDir
#   Get-ChromeProfileList
#   Copy-ChromeProfile     -From <name> -To <name> [-DryRun] [-Force] [-WithLogins] [-WithSiteData]
#   Export-ChromeProfile   -Name <name> -OutDir <path> [-Format json|csv|both]
#   Import-ChromeProfile   -JsonPath <path> -To <name> [-DryRun] [-Force] [-WithFlags]
#   Write-ChromeProfileLedger -Op <copy|export|import> -Source -Target -ExportPath -Bookmarks -Extensions -Bytes -Ok -ErrorMsg
#
# All file/path errors include the offending path and reason (CODE RED rule).
# --------------------------------------------------------------------------

# Whitelisted profile assets to copy (relative paths inside the profile dir).
$script:ChromeProfileCopyIncludes = @(
    'Bookmarks','Bookmarks.bak',
    'Preferences','Secure Preferences',
    'Favicons','Top Sites','History',
    'Extensions','Extension Rules','Extension State','Extension Scripts',
    'Local Extension Settings','Sync Extension Settings',
    'Themes','Web Applications'
)
$script:ChromeProfileCopyOptional = @{
    Logins   = @('Login Data','Login Data For Account')
    SiteData = @('Local Storage','IndexedDB','Session Storage')
}
$script:ChromeProfileSkipAlways = @(
    'Cache','Code Cache','GPUCache','Service Worker','Sync Data','Sessions','Crash Reports'
)

function Get-ChromeUserDataDir {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data'),
        (Join-Path $env:LOCALAPPDATA 'Google\Chrome Beta\User Data')
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return (Resolve-Path $c).Path }
    }
    Write-Log "Chrome User Data dir not found. Tried: $($candidates -join '; '). Reason: Chrome not installed or never launched." -Level "error"
    return $null
}

function Get-ChromeProfileList {
    $userData = Get-ChromeUserDataDir
    if (-not $userData) { return @() }
    $localState = Join-Path $userData 'Local State'
    $infoCache = @{}
    if (Test-Path $localState) {
        try {
            $ls = Get-Content -Raw -LiteralPath $localState | ConvertFrom-Json
            if ($ls.profile -and $ls.profile.info_cache) {
                $ls.profile.info_cache.PSObject.Properties | ForEach-Object {
                    $infoCache[$_.Name] = $_.Value
                }
            }
        } catch {
            Write-Log "Failed to parse Local State at $localState : $_" -Level "warn"
        }
    }
    $profiles = @()
    Get-ChildItem -LiteralPath $userData -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $dir = $_.Name
        $isProfile = ($dir -eq 'Default') -or ($dir -like 'Profile *') -or (Test-Path (Join-Path $_.FullName 'Preferences'))
        if (-not $isProfile) { return }
        $displayName = if ($infoCache.ContainsKey($dir)) { $infoCache[$dir].name } else { $dir }
        $profiles += [pscustomobject]@{
            Dir         = $dir
            DisplayName = $displayName
            Path        = $_.FullName
        }
    }
    return $profiles
}

function Resolve-ChromeProfileDir {
    # Resolve a user-supplied token to an on-disk profile directory.
    # Match order (all case-insensitive):
    #   1. Exact directory name (e.g. "Profile 3", "Default")
    #   2. Exact display name from Local State info_cache (e.g. "Lovable")
    #   3. Exact shortcut/gaia name from info_cache
    #   4. Unique substring match against display name OR directory
    # On failure returns $null so the caller can render available-profiles help
    # instead of a fake path. The gitmap bug was "passed display name was treated
    # as a directory name and we returned a bogus path" -- this guards against it.
    param([string]$NameOrDir, [string]$UserDataDir)
    if (-not $UserDataDir) { $UserDataDir = Get-ChromeUserDataDir }
    if (-not $UserDataDir) { return $null }
    if ([string]::IsNullOrWhiteSpace($NameOrDir)) { return $null }

    $list = Get-ChromeProfileList
    # 1. exact dir
    $byDir = $list | Where-Object { $_.Dir -ieq $NameOrDir } | Select-Object -First 1
    if ($byDir) { return $byDir.Path }
    # 2. exact display name
    $byName = $list | Where-Object { $_.DisplayName -ieq $NameOrDir } | Select-Object -First 1
    if ($byName) { return $byName.Path }
    # 3. shortcut_name / gaia_name fallback (rebuild from Local State)
    $localState = Join-Path $UserDataDir 'Local State'
    if (Test-Path $localState) {
        try {
            $ls = Get-Content -Raw -LiteralPath $localState | ConvertFrom-Json
            if ($ls.profile -and $ls.profile.info_cache) {
                foreach ($p in $ls.profile.info_cache.PSObject.Properties) {
                    $v = $p.Value
                    $names = @($v.name, $v.shortcut_name, $v.gaia_name, $v.gaia_given_name, $v.user_name) | Where-Object { $_ }
                    if ($names | Where-Object { "$_" -ieq $NameOrDir }) {
                        return (Join-Path $UserDataDir $p.Name)
                    }
                }
            }
        } catch {}
    }
    # 4. unique substring match
    $contains = @($list | Where-Object {
        ("$($_.DisplayName)".ToLower().Contains($NameOrDir.ToLower())) -or
        ("$($_.Dir)".ToLower().Contains($NameOrDir.ToLower()))
    })
    if ($contains.Count -eq 1) { return $contains[0].Path }
    return $null
}

function Write-ChromeProfileNotFound {
    param([string]$NameOrDir, [string]$UserDataDir)
    if (-not $UserDataDir) { $UserDataDir = Get-ChromeUserDataDir }
    Write-Log "Source profile '$NameOrDir' not found under $UserDataDir. Reason: no directory or display name matches (case-insensitive, substring)." -Level "error"
    $list = Get-ChromeProfileList
    if ($list.Count -eq 0) {
        Write-Log "No Chrome profiles discovered. Is Chrome installed and launched at least once?" -Level "warn"
        return
    }
    Write-Log "Available profiles (use either column with --from/--name):" -Level "info"
    Write-Log ("  {0,-14}  {1}" -f 'DIR', 'DISPLAY NAME') -Level "info"
    foreach ($p in ($list | Sort-Object Dir)) {
        Write-Log ("  {0,-14}  {1}" -f $p.Dir, $p.DisplayName) -Level "info"
    }
}


function Test-ChromeRunning {
    return $null -ne (Get-Process -Name 'chrome' -ErrorAction SilentlyContinue)
}

function Copy-ChromeProfile {
    param(
        [Parameter(Mandatory)] [string]$From,
        [Parameter(Mandatory)] [string]$To,
        [switch]$DryRun,
        [switch]$Force,
        [switch]$WithLogins,
        [switch]$WithSiteData
    )
    $userData = Get-ChromeUserDataDir
    if (-not $userData) { return $false }

    $srcDir = Resolve-ChromeProfileDir -NameOrDir $From -UserDataDir $userData
    if (-not $srcDir -or -not (Test-Path $srcDir)) {
        Write-ChromeProfileNotFound -NameOrDir $From -UserDataDir $userData
        return $false
    }
    $dstDir = Join-Path $userData $To
    $isNewProfile = -not (Test-Path $dstDir)

    if (Test-ChromeRunning -and -not $Force) {
        Write-Log "Chrome appears to be running. Close all Chrome windows (or pass -Force) before copying. Path: $srcDir." -Level "error"
        return $false
    }

    Write-Log ("Source: {0}" -f $srcDir) -Level "info"
    Write-Log ("Target: {0} ({1})" -f $dstDir, $(if($isNewProfile){'NEW offline profile'}else{'EXISTING -- will be backed up'})) -Level "info"

    if (-not $isNewProfile) {
        $backup = "{0}.bak-{1}" -f $dstDir, (Get-Date -Format 'yyyyMMdd-HHmmss')
        if ($DryRun) {
            Write-Log "[dry-run] Would back up existing target to: $backup" -Level "info"
        } else {
            try {
                Rename-Item -LiteralPath $dstDir -NewName (Split-Path -Leaf $backup) -ErrorAction Stop
                Write-Log "Backed up existing target -> $backup" -Level "success"
            } catch {
                Write-Log "Failed to back up existing target at $dstDir : $_" -Level "error"
                return $false
            }
        }
    }

    if (-not $DryRun) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }

    $includes = @($script:ChromeProfileCopyIncludes)
    if ($WithLogins)   { $includes += $script:ChromeProfileCopyOptional.Logins }
    if ($WithSiteData) { $includes += $script:ChromeProfileCopyOptional.SiteData }

    $copiedBytes = 0L
    $copiedItems = 0
    foreach ($rel in $includes) {
        $srcPath = Join-Path $srcDir $rel
        if (-not (Test-Path $srcPath)) { continue }
        $dstPath = Join-Path $dstDir $rel
        if ($DryRun) {
            Write-Log "[dry-run] copy $rel" -Level "info"
            $copiedItems++
            continue
        }
        try {
            $isContainer = (Get-Item -LiteralPath $srcPath).PSIsContainer
            if ($isContainer) {
                Copy-Item -LiteralPath $srcPath -Destination $dstPath -Recurse -Force -ErrorAction Stop
                $sz = (Get-ChildItem -LiteralPath $dstPath -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            } else {
                Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force -ErrorAction Stop
                $sz = (Get-Item -LiteralPath $dstPath).Length
            }
            if ($sz) { $copiedBytes += [int64]$sz }
            $copiedItems++
        } catch {
            Write-Log "Failed to copy $srcPath -> $dstPath : $_" -Level "error"
        }
    }

    # Strip account binding from copied Preferences to make it offline.
    $copiedPrefs = Join-Path $dstDir 'Preferences'
    if ((-not $DryRun) -and (Test-Path $copiedPrefs)) {
        try {
            $prefs = Get-Content -Raw -LiteralPath $copiedPrefs | ConvertFrom-Json
            $accountKeys = @('account_info','google','gaia_cookie','signin')
            foreach ($k in $accountKeys) {
                if ($prefs.PSObject.Properties.Name -contains $k) {
                    $prefs.PSObject.Properties.Remove($k)
                }
            }
            ($prefs | ConvertTo-Json -Depth 64 -Compress) | Set-Content -LiteralPath $copiedPrefs -Encoding UTF8
            Write-Log "Stripped account binding from $copiedPrefs (offline profile)." -Level "info"
        } catch {
            Write-Log "Could not strip account binding from $copiedPrefs : $_" -Level "warn"
        }
    }

    # Register the new profile in Local State so Chrome shows it in the picker.
    $localState = Join-Path $userData 'Local State'
    if ((-not $DryRun) -and (Test-Path $localState)) {
        try {
            $ls = Get-Content -Raw -LiteralPath $localState | ConvertFrom-Json
            if (-not $ls.profile) { $ls | Add-Member -NotePropertyName profile -NotePropertyValue ([pscustomobject]@{}) }
            if (-not $ls.profile.info_cache) { $ls.profile | Add-Member -NotePropertyName info_cache -NotePropertyValue ([pscustomobject]@{}) }
            $entry = [pscustomobject]@{
                name = $To
                is_using_default_name = $false
                is_using_default_avatar = $true
                avatar_icon = 'chrome://theme/IDR_PROFILE_AVATAR_26'
            }
            if ($ls.profile.info_cache.PSObject.Properties.Name -contains $To) {
                $ls.profile.info_cache.$To = $entry
            } else {
                $ls.profile.info_cache | Add-Member -NotePropertyName $To -NotePropertyValue $entry -Force
            }
            ($ls | ConvertTo-Json -Depth 64 -Compress) | Set-Content -LiteralPath $localState -Encoding UTF8
            Write-Log "Registered profile '$To' in Local State." -Level "success"
        } catch {
            Write-Log "Failed to update Local State at $localState : $_" -Level "warn"
        }
    } elseif ($DryRun) {
        Write-Log "[dry-run] Would patch $localState -> profile.info_cache.$To" -Level "info"
    }

    $mb = [math]::Round($copiedBytes / 1MB, 2)
    Write-Log ("Profile copy complete: {0} item(s), {1} MB." -f $copiedItems, $mb) -Level "success"

    $extCount = 0
    $extDir = Join-Path $dstDir 'Extensions'
    if (Test-Path $extDir) {
        $extCount = (Get-ChildItem -LiteralPath $extDir -Directory -ErrorAction SilentlyContinue).Count
    }

    Write-ChromeProfileLedger -Op 'copy' -Source $From -Target $To -Extensions $extCount -Bytes $copiedBytes -Ok ($copiedItems -gt 0)
    return $true
}

function _Flatten-Bookmarks {
    param($Node, [string]$Path = '')
    $out = @()
    if (-not $Node) { return $out }
    if ($Node.type -eq 'url') {
        $out += [pscustomobject]@{ path = $Path; url = $Node.url; name = $Node.name }
    }
    if ($Node.children) {
        foreach ($child in $Node.children) {
            $sub = if ($child.type -eq 'folder') { "$Path/$($child.name)" } else { $Path }
            $out += _Flatten-Bookmarks -Node $child -Path $sub
        }
    }
    return $out
}

function Export-ChromeProfile {
    param(
        [Parameter(Mandatory)] [string]$Name,
        [string]$OutDir,
        [ValidateSet('json','csv','both')] [string]$Format = 'both'
    )
    $userData = Get-ChromeUserDataDir
    if (-not $userData) { return $false }
    $srcDir = Resolve-ChromeProfileDir -NameOrDir $Name -UserDataDir $userData
    if (-not (Test-Path $srcDir)) {
        Write-Log "Source profile not found at $srcDir. Reason: no directory matches '$Name' under $userData." -Level "error"
        return $false
    }
    if (-not $OutDir) { $OutDir = Join-Path (Get-Location) ("chrome-profiles\" + ($Name -replace '[\\/:*?"<>|]','_')) }
    New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

    $prefsPath = Join-Path $srcDir 'Preferences'
    $bookmarksPath = Join-Path $srcDir 'Bookmarks'
    $localState = Join-Path $userData 'Local State'

    $prefs = $null; $bookmarks = $null; $flags = @(); $chromeVersion = ''
    try { if (Test-Path $prefsPath)     { $prefs     = Get-Content -Raw -LiteralPath $prefsPath     | ConvertFrom-Json } } catch { Write-Log "Could not parse $prefsPath : $_" -Level "warn" }
    try { if (Test-Path $bookmarksPath) { $bookmarks = Get-Content -Raw -LiteralPath $bookmarksPath | ConvertFrom-Json } } catch { Write-Log "Could not parse $bookmarksPath : $_" -Level "warn" }
    try {
        if (Test-Path $localState) {
            $ls = Get-Content -Raw -LiteralPath $localState | ConvertFrom-Json
            if ($ls.browser -and $ls.browser.enabled_labs_experiments) { $flags = @($ls.browser.enabled_labs_experiments) }
        }
    } catch { Write-Log "Could not parse $localState : $_" -Level "warn" }

    # Extensions discovered from filesystem.
    $extensions = @()
    $extRoot = Join-Path $srcDir 'Extensions'
    if (Test-Path $extRoot) {
        Get-ChildItem -LiteralPath $extRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $id = $_.Name
            $verDir = Get-ChildItem -LiteralPath $_.FullName -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
            $name = $id; $version = ''
            if ($verDir) {
                $version = $verDir.Name
                $manifest = Join-Path $verDir.FullName 'manifest.json'
                if (Test-Path $manifest) {
                    try {
                        $m = Get-Content -Raw -LiteralPath $manifest | ConvertFrom-Json
                        if ($m.name) { $name = $m.name }
                    } catch { }
                }
            }
            $extensions += [pscustomobject]@{ id = $id; name = $name; version = $version; enabled = $true }
        }
    }

    $prefSubset = [ordered]@{}
    if ($prefs) {
        foreach ($k in @('homepage','homepage_is_newtabpage','session','browser','search','default_search_provider_data','extensions.theme')) {
            $parts = $k -split '\.'
            $cur = $prefs
            $ok = $true
            foreach ($p in $parts) {
                if ($cur -and ($cur.PSObject.Properties.Name -contains $p)) { $cur = $cur.$p } else { $ok = $false; break }
            }
            if ($ok) { $prefSubset[$k] = $cur }
        }
    }

    $snapshot = [ordered]@{
        '$schema'         = 'chrome-profile-export/v1'
        exportedAt        = (Get-Date).ToUniversalTime().ToString('o')
        sourceProfile     = (Split-Path -Leaf $srcDir)
        sourceDisplayName = $Name
        chromeVersion     = $chromeVersion
        preferences       = $prefSubset
        bookmarks         = $bookmarks
        extensions        = $extensions
        flags             = $flags
    }

    $jsonPath = Join-Path $OutDir 'profile.json'
    $csvPath  = Join-Path $OutDir 'profile.csv'
    $bookmarkRows = @()
    if ($bookmarks -and $bookmarks.roots) {
        foreach ($rootKey in $bookmarks.roots.PSObject.Properties.Name) {
            $bookmarkRows += _Flatten-Bookmarks -Node $bookmarks.roots.$rootKey -Path "/$rootKey"
        }
    }

    if ($Format -in @('json','both')) {
        try {
            ($snapshot | ConvertTo-Json -Depth 64) | Set-Content -LiteralPath $jsonPath -Encoding UTF8
            Write-Log "Wrote JSON snapshot: $jsonPath" -Level "success"
        } catch {
            Write-Log "Failed to write JSON snapshot to $jsonPath : $_" -Level "error"
            return $false
        }
    }
    if ($Format -in @('csv','both')) {
        try {
            $rows = New-Object System.Collections.Generic.List[object]
            $rows.Add([pscustomobject]@{section='meta'; key='exportedAt';        value=$snapshot.exportedAt})
            $rows.Add([pscustomobject]@{section='meta'; key='sourceProfile';     value=$snapshot.sourceProfile})
            $rows.Add([pscustomobject]@{section='meta'; key='sourceDisplayName'; value=$snapshot.sourceDisplayName})
            foreach ($e in $extensions) {
                $rows.Add([pscustomobject]@{section='extension'; key=$e.id; value="$($e.name)|$($e.version)|$(if($e.enabled){'enabled'}else{'disabled'})"})
            }
            foreach ($b in $bookmarkRows) {
                $rows.Add([pscustomobject]@{section='bookmark'; key=("{0}/{1}" -f $b.path, $b.name); value=$b.url})
            }
            foreach ($k in $prefSubset.Keys) {
                $rows.Add([pscustomobject]@{section='pref'; key=$k; value=("{0}" -f $prefSubset[$k])})
            }
            foreach ($f in $flags) {
                $rows.Add([pscustomobject]@{section='flag'; key=$f; value='1'})
            }
            $rows | Export-Csv -LiteralPath $csvPath -NoTypeInformation -Encoding UTF8
            Write-Log "Wrote CSV snapshot: $csvPath ($($rows.Count) rows)" -Level "success"
        } catch {
            Write-Log "Failed to write CSV snapshot to $csvPath : $_" -Level "error"
            return $false
        }
    }

    $bytes = 0L
    if (Test-Path $jsonPath) { $bytes += (Get-Item $jsonPath).Length }
    if (Test-Path $csvPath)  { $bytes += (Get-Item $csvPath).Length }
    Write-ChromeProfileLedger -Op 'export' -Source $Name -ExportPath $OutDir `
        -Bookmarks $bookmarkRows.Count -Extensions $extensions.Count -Bytes $bytes -Ok $true
    return $true
}

function Import-ChromeProfile {
    param(
        [Parameter(Mandatory)] [string]$JsonPath,
        [Parameter(Mandatory)] [string]$To,
        [switch]$DryRun,
        [switch]$Force,
        [switch]$WithFlags
    )
    if (-not (Test-Path $JsonPath)) {
        Write-Log "Import JSON not found at $JsonPath. Reason: file does not exist." -Level "error"
        return $false
    }
    $userData = Get-ChromeUserDataDir
    if (-not $userData) { return $false }
    if (Test-ChromeRunning -and -not $Force) {
        Write-Log "Chrome appears to be running. Close all windows (or pass -Force) before importing into $To." -Level "error"
        return $false
    }
    try {
        $snap = Get-Content -Raw -LiteralPath $JsonPath | ConvertFrom-Json
    } catch {
        Write-Log "Failed to parse import JSON at $JsonPath : $_" -Level "error"
        return $false
    }
    $dstDir = Join-Path $userData $To
    if ($DryRun) {
        Write-Log "[dry-run] Would create profile dir: $dstDir" -Level "info"
        Write-Log "[dry-run] Would write Bookmarks, Preferences subset, and register profile in Local State." -Level "info"
        return $true
    }
    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null

    if ($snap.bookmarks) {
        try {
            ($snap.bookmarks | ConvertTo-Json -Depth 64) | Set-Content -LiteralPath (Join-Path $dstDir 'Bookmarks') -Encoding UTF8
        } catch {
            Write-Log "Failed to write Bookmarks to $dstDir : $_" -Level "warn"
        }
    }
    if ($snap.preferences) {
        try {
            ($snap.preferences | ConvertTo-Json -Depth 64 -Compress) | Set-Content -LiteralPath (Join-Path $dstDir 'Preferences') -Encoding UTF8
        } catch {
            Write-Log "Failed to write Preferences to $dstDir : $_" -Level "warn"
        }
    }

    # Register in Local State.
    $localState = Join-Path $userData 'Local State'
    if (Test-Path $localState) {
        try {
            $ls = Get-Content -Raw -LiteralPath $localState | ConvertFrom-Json
            if (-not $ls.profile.info_cache) { $ls.profile | Add-Member -NotePropertyName info_cache -NotePropertyValue ([pscustomobject]@{}) }
            $entry = [pscustomobject]@{
                name = $To
                is_using_default_name = $false
                is_using_default_avatar = $true
                avatar_icon = 'chrome://theme/IDR_PROFILE_AVATAR_26'
            }
            $ls.profile.info_cache | Add-Member -NotePropertyName $To -NotePropertyValue $entry -Force
            if ($WithFlags -and $snap.flags) {
                if (-not $ls.browser) { $ls | Add-Member -NotePropertyName browser -NotePropertyValue ([pscustomobject]@{}) }
                $ls.browser | Add-Member -NotePropertyName enabled_labs_experiments -NotePropertyValue @($snap.flags) -Force
                Write-Log "Applied $($snap.flags.Count) flag(s) from snapshot." -Level "info"
            } elseif ($snap.flags -and $snap.flags.Count -gt 0) {
                Write-Log "Snapshot contains $($snap.flags.Count) flag(s); skipped (pass -WithFlags to apply -- they affect ALL profiles)." -Level "warn"
            }
            ($ls | ConvertTo-Json -Depth 64 -Compress) | Set-Content -LiteralPath $localState -Encoding UTF8
        } catch {
            Write-Log "Failed to update Local State at $localState : $_" -Level "warn"
        }
    }

    $extCount = if ($snap.extensions) { @($snap.extensions).Count } else { 0 }
    Write-Log "Imported profile '$To' from $JsonPath (extensions in manifest: $extCount). Re-install extensions via 'chrome ext' if needed." -Level "success"
    Write-ChromeProfileLedger -Op 'import' -Target $To -ExportPath $JsonPath -Extensions $extCount -Ok $true
    return $true
}

function Get-ChromeProfileLedgerPath {
    $dirCandidates = @(
        (Join-Path $env:LOCALAPPDATA 'dev-server'),
        (Join-Path (Get-Location) 'chrome-profiles')
    )
    foreach ($d in $dirCandidates) {
        try {
            if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
            return (Join-Path $d 'chrome-profiles.sqlite')
        } catch { continue }
    }
    return $null
}

function Write-ChromeProfileLedger {
    param(
        [Parameter(Mandatory)] [ValidateSet('copy','export','import')] [string]$Op,
        [string]$Source, [string]$Target, [string]$ExportPath,
        [int]$Bookmarks = 0, [int]$Extensions = 0, [int64]$Bytes = 0,
        [bool]$Ok = $true, [string]$ErrorMsg
    )
    $dbPath = Get-ChromeProfileLedgerPath
    if (-not $dbPath) { Write-Log "SQLite ledger: no writable location found -- skipping." -Level "warn"; return }
    $sqlite = Get-Command sqlite3.exe -ErrorAction SilentlyContinue
    if (-not $sqlite) {
        Write-Log "SQLite ledger: sqlite3.exe not on PATH -- skipping (op=$Op, target=$Target). Path that would be used: $dbPath" -Level "warn"
        return
    }
    $schema = @"
CREATE TABLE IF NOT EXISTS profile_ops (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  op TEXT NOT NULL, source TEXT, target TEXT, export_path TEXT,
  bookmarks INTEGER DEFAULT 0, extensions INTEGER DEFAULT 0, bytes INTEGER DEFAULT 0,
  ok INTEGER NOT NULL, error TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_profile_ops_op ON profile_ops(op);
"@
    function _SqlEsc([string]$s) { if ($null -eq $s) { return 'NULL' }; return "'" + ($s -replace "'","''") + "'" }
    $insert = "INSERT INTO profile_ops(op,source,target,export_path,bookmarks,extensions,bytes,ok,error) VALUES ($(_SqlEsc $Op),$(_SqlEsc $Source),$(_SqlEsc $Target),$(_SqlEsc $ExportPath),$Bookmarks,$Extensions,$Bytes,$([int]$Ok),$(_SqlEsc $ErrorMsg));"
    try {
        $tmp = New-TemporaryFile
        Set-Content -LiteralPath $tmp -Value "$schema`n$insert" -Encoding UTF8
        & $sqlite.Source $dbPath ".read `"$tmp`""
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        Write-Log "Ledger updated: $dbPath (op=$Op)" -Level "info"
    } catch {
        Write-Log "Failed to write SQLite ledger at $dbPath : $_" -Level "warn"
    }
}
