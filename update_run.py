import re

with open('run.ps1', 'r', encoding='utf-8') as f:
    ps1 = f.read()

# 1. Add bare commands
bare_cmds = '''    $isBareExportConfigCommand = $normalizedCommand -eq "export-config"
    $isBareImportConfigCommand = $normalizedCommand -eq "import-config"
'''
ps1 = ps1.replace('    $isBareExportCommand  = $normalizedCommand -eq "export"', 
                  '    $isBareExportCommand  = $normalizedCommand -eq "export"\n' + bare_cmds, 1)

# 2. Add to isReadOnlyBare
ps1 = ps1.replace('-or $isBareDoctorCommand -or $isBareReportCommand',
                  '-or $isBareDoctorCommand -or $isBareReportCommand -or $isBareExportConfigCommand', 1)

# 3. Add to isDispatchingBareSubcommand
ps1 = ps1.replace('-or $isBareExportCommand ',
                  '-or $isBareExportCommand -or $isBareExportConfigCommand -or $isBareImportConfigCommand ', 1)

# 4. Add dispatch blocks
dispatch_blocks = '''    } elseif ($isBareExportConfigCommand) {
        Show-VersionHeader
        Invoke-ExportConfigCommand -Args $Install
        exit 0
    } elseif ($isBareImportConfigCommand) {
        Show-VersionHeader
        Invoke-ImportConfigCommand -Args $Install
        exit 0
'''
ps1 = ps1.replace('    } elseif ($isBareExportCommand) {', dispatch_blocks + '    } elseif ($isBareExportCommand) {', 1)

# 5. Add functions near Invoke-ExportCommand
funcs = '''
function Invoke-ExportConfigCommand {
    param([string[]]$Args)
    $hasApp = $null -ne $Args -and $Args.Count -gt 0
    if (-not $hasApp) { Write-Host "Usage: export-config <app>"; return }
    $app = $Args[0]
    $backupDir = Join-Path $RootDir "configs"
    $hasBackup = Test-Path $backupDir
    if (-not $hasBackup) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
    if ($app -eq "qtorrent") { Copy-Config (Join-Path $env:APPDATA "qBittorrent") (Join-Path $backupDir "qtorrent") }
    if ($app -eq "utorrent") { Copy-Config (Join-Path $env:APPDATA "uTorrent") (Join-Path $backupDir "utorrent") }
    if ($app -eq "vscode") { Copy-Config (Join-Path $env:APPDATA "Code\\User") (Join-Path $backupDir "vscode") }
}

function Invoke-ImportConfigCommand {
    param([string[]]$Args)
    $hasApp = $null -ne $Args -and $Args.Count -gt 0
    if (-not $hasApp) { Write-Host "Usage: import-config <app>"; return }
    $app = $Args[0]
    $backupDir = Join-Path $RootDir "configs"
    if ($app -eq "qtorrent") { Copy-Config (Join-Path $backupDir "qtorrent") (Join-Path $env:APPDATA "qBittorrent") }
    if ($app -eq "utorrent") { Copy-Config (Join-Path $backupDir "utorrent") (Join-Path $env:APPDATA "uTorrent") }
    if ($app -eq "vscode") { Copy-Config (Join-Path $backupDir "vscode") (Join-Path $env:APPDATA "Code\\User") }
}

function Copy-Config {
    param([string]$Src, [string]$Dest)
    $hasSrc = Test-Path $Src
    if (-not $hasSrc) { Write-Host "Source not found: $Src"; return }
    $hasDest = Test-Path $Dest
    if (-not $hasDest) { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }
    Copy-Item -Path "$Src\\*" -Destination $Dest -Recurse -Force
    Write-Host "Copied config to $Dest"
}
'''
ps1 = ps1.replace('function Invoke-ExportCommand {', funcs + '\nfunction Invoke-ExportCommand {', 1)

# 6. Add to help menu
help_lines = '''    Write-Host "    $(\\".\\run.ps1 export-config <app>\\".PadRight($col))" -NoNewline; Write-Host "Export app config (qtorrent, utorrent, vscode)" -ForegroundColor $ThemeMuted
    Write-Host "    $(\\".\\run.ps1 import-config <app>\\".PadRight($col))" -NoNewline; Write-Host "Import app config (qtorrent, utorrent, vscode)" -ForegroundColor $ThemeMuted
'''
ps1 = ps1.replace('Write-Host "    $(\\".\\run.ps1 export\\".PadRight($col))" -NoNewline;', help_lines + '    Write-Host "    $(\\".\\run.ps1 export\\".PadRight($col))" -NoNewline;', 1)

with open('run.ps1', 'w', encoding='utf-8', newline='\n') as f:
    f.write(ps1)

print('Updated run.ps1')
