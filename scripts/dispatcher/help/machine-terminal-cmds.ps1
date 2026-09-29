# Machine identity, IP inspection, and terminal cleaner help

function Show-HelpMachineExamples {
    Write-Host "    Machine Identity & IP Inspection (GitMap parity) -- detailed examples:" -ForegroundColor $ThemePrimary
    Write-Host "      Inspection, Hostname & Network Adapters:" -ForegroundColor DarkYellow

    Write-HelpServiceLine ".\run.ps1 machine" "# Display complete machine OS, specs & network identity"
    Write-HelpServiceLine ".\run.ps1 machine ls" "# Explicit list alias for machine overview"
    Write-HelpServiceLine ".\run.ps1 machine --json" "# Output machine identity as structured JSON (for CI/piping)"
    Write-HelpServiceLine ".\run.ps1 ip" "# Display network adapters, IPs, gateways & netmasks"
    Write-HelpServiceLine ".\run.ps1 ip --json" "# Output network adapters as structured JSON array"

    Write-Host "      Machine Naming & Rollback:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 machine set <name>" "# Set custom machine alias/name with rollback tracking"
    Write-HelpServiceLine ".\run.ps1 machine revert" "# Restore previous machine alias and name"
    Write-HelpServiceLine ".\run.ps1 os machine" "# Access machine identity via OS dispatcher"

    Write-Host ""
}

function Show-HelpTerminalCleanerExamples {
    Write-Host "    Terminal History & Suggestion Cleaner (GitMap parity) -- detailed examples:" -ForegroundColor $ThemePrimary
    Write-Host "      Terminal Clean, PSReadLine & Shell History Wipe:" -ForegroundColor DarkYellow

    Write-HelpServiceLine ".\run.ps1 clear-terminal" "# Wipe terminal history and suggestions (PWSH, Bash, Zsh, Sh)"
    Write-HelpServiceLine ".\run.ps1 clear terminal" "# Compound alias for 'clear-terminal'"
    Write-HelpServiceLine ".\run.ps1 clear-terminal --dry-run" "# Preview targets and line counts without deleting"
    Write-HelpServiceLine ".\run.ps1 clear-terminal -y" "# Skip interactive confirmation prompt"
    Write-HelpServiceLine ".\run.ps1 clear-terminal --json" "# Output wipe & reseed results as structured JSON"

    Write-Host "      GitMap Reseeding & Prediction Engine:" -ForegroundColor DarkYellow
    Write-HelpServiceLine ".\run.ps1 clear-terminal --reseed-only" "# Reseed 17 GitMap suggestions without wiping history"
    Write-HelpServiceLine ".\run.ps1 clear-terminal --no-reseed" "# Wipe terminal history but skip GitMap suggestions reseeding"
    Write-HelpServiceLine ".\run.ps1 os clear-terminal" "# Access terminal cleaner via OS dispatcher"

    Write-Host ""
}

function Show-HelpMachineAndTerminal {
    Show-HelpMachineExamples
    Show-HelpTerminalCleanerExamples
}
