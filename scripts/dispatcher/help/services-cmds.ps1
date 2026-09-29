# Nginx, startup, scheduling, macro, and cluster commands

function Write-HelpServiceLine {
    param([string]$Command, [string]$Comment)

    Write-Host "        $($Command.PadRight(60))" -NoNewline
    Write-Host $Comment -ForegroundColor $ThemeMuted
}

function Show-HelpNginxCommands {
    Write-Host "    Nginx Web Server & Domain Manager:" -ForegroundColor $ThemePrimary
    Write-Host "      Management & Virtual Hosts:" -ForegroundColor DarkYellow

    Write-HelpServiceLine ".\run.ps1 nginx install" "# Install Nginx Web Server via Chocolatey"
    Write-HelpServiceLine ".\run.ps1 nginx help" "# Show domain manager command help"
    Write-HelpServiceLine ".\run.ps1 nginx add example.com --type php" "# Register vhost + compile conf + sync INI & SQLite"
    Write-HelpServiceLine ".\run.ps1 nginx rm example.com" "# Remove vhost + unlink conf + sync INI & SQLite"
    Write-HelpServiceLine ".\run.ps1 nginx list" "# List all registered domains in SQLite ledger"
    Write-HelpServiceLine ".\run.ps1 nginx ini --sync" "# Bidirectional sync between SQLite and domains.ini"
    Write-HelpServiceLine ".\run.ps1 nginx showcase" "# 5-phase showcase of SQLite and INI synchronization"

    Write-Host ""
}

function Show-HelpStartupAndMacroCommands {
    Write-Host "    Startup, Task Scheduling & Macro Automation:" -ForegroundColor $ThemePrimary
    Write-Host "      Startup & Boot Automation:" -ForegroundColor DarkYellow

    Write-HelpServiceLine ".\run.ps1 startup list" "# List registered startup actions (Startup.db)"
    Write-HelpServiceLine ".\run.ps1 startup add <path|macro> [--freq on-login]" "# Register item to run on startup/login"
    Write-HelpServiceLine ".\run.ps1 startup remove <id>" "# Unregister startup item"
    Write-HelpServiceLine ".\run.ps1 startup run <id>" "# Trigger startup item interactively now"

    Write-Host "      Crontab & Scheduled Tasks:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 schedule list" "# List all scheduled jobs (Schedule.db)"
    Write-HelpServiceLine ".\run.ps1 schedule add <type> <target> <timing>" "# Register job (types: ps, bash, sh, js, macro)"
    Write-HelpServiceLine ".\run.ps1 schedule run <id>" "# Execute job immediately & record to child DB"
    Write-HelpServiceLine ".\run.ps1 schedule debug <id>" "# Inspect execution logs in ~/.scripts-fixer/schedules/<id>.db"

    Write-Host "      Interactive Macros & Workflows:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 macro list" "# List registered macros (Macro.db)"
    Write-HelpServiceLine ".\run.ps1 macro add <name> <cmd1> <cmd2>..." "# Create interactive command sequence"
    Write-HelpServiceLine ".\run.ps1 macro run <name>" "# Execute macro interactively with live output"
    Write-HelpServiceLine ".\run.ps1 macro startup add <name>" "# Register macro to execute on system startup"
    Write-HelpServiceLine ".\run.ps1 macro schedule add <name> daily" "# Schedule macro for periodic execution"

    Write-Host "      Async Monitoring & Storage Calculation:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 async <cmd> -t 5" "# Run command/service periodically & monitor output"
    Write-HelpServiceLine ".\run.ps1 storage list" "# Show split DB sizes & disk drive space calculation"
    Write-HelpServiceLine ".\run.ps1 storage partition" "# Storage partitioning options & swap expansion guides"
    Write-HelpServiceLine ".\run.ps1 pipeline errors -t" "# Wait for pipeline ETA and report error status"

    Write-Host "      Kubernetes Cluster Nodes & Remote Commands (SQLite + SSH RSA):" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 cluster list" "# List cluster nodes from SQLite"
    Write-HelpServiceLine ".\run.ps1 cluster add <name> <role> <ip>" "# Register node in SQLite"
    Write-HelpServiceLine ".\run.ps1 cluster history" "# View cluster remote command execution logs"

    Write-Host ""
}

function Show-HelpServices {
    Show-HelpNginxCommands
    Show-HelpStartupAndMacroCommands
}
