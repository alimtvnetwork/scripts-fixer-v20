# Root help raw renderer

. (Join-Path $PSScriptRoot "theme.ps1")
. (Join-Path $PSScriptRoot "usage-cmds.ps1")
. (Join-Path $PSScriptRoot "profiles.ps1")
. (Join-Path $PSScriptRoot "keywords-core.ps1")
. (Join-Path $PSScriptRoot "services-cmds.ps1")
. (Join-Path $PSScriptRoot "maintenance-cmds.ps1")
. (Join-Path $PSScriptRoot "machine-terminal-cmds.ps1")
. (Join-Path $PSScriptRoot "chrome-cmds.ps1")
. (Join-Path $PSScriptRoot "context-menus.ps1")
. (Join-Path $PSScriptRoot "exclude-tokens.ps1")
. (Join-Path $PSScriptRoot "python-libs.ps1")
. (Join-Path $PSScriptRoot "database-remote-cmds.ps1")
. (Join-Path $PSScriptRoot "keyword-table.ps1")
. (Join-Path $PSScriptRoot "scripts-table.ps1")
. (Join-Path $PSScriptRoot "orchestrator-modes.ps1")
. (Join-Path $PSScriptRoot "dev-drive.ps1")
. (Join-Path $PSScriptRoot "filter-guide.ps1")

function Show-RootHelpRaw {
    Show-VersionHeaderSafe
    Show-HelpUsageCommands
    Show-HelpProfiles
    Show-HelpKeywordsCore
    Show-HelpServices
    Show-HelpMaintenance
    Show-HelpMachineAndTerminal
    Show-HelpChrome
    Show-HelpContextMenus
    Show-HelpExcludeTokens
    Show-HelpPythonLibs
    Show-HelpDatabasesAndRemotes
    Show-KeywordTable -Inline
    Show-HelpScriptsTable
    Show-HelpScript12Modes
    Show-HelpDevDrive
    Show-HelpPerScriptAndPathChanges
    Show-HelpFilterGuide
    Show-VersionFooterSafe
}
