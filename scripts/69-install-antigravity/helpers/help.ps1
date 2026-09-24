function Show-AgyHelp {
    Write-Host ""
    Write-Host "  Antigravity (agy) -- Google Antigravity IDE & CLI Manager" -ForegroundColor Cyan
    Write-Host "  ========================================================" -ForegroundColor Gray
    Write-Host "  USAGE: " -ForegroundColor Yellow -NoNewline
    Write-Host ".\run.ps1 agy <action> [flags]" -ForegroundColor White
    Write-Host ""
    Write-Host "  ACTIONS:" -ForegroundColor Yellow
    Write-Host "    clear | clean       " -ForegroundColor Green -NoNewline
    Write-Host "Predict or apply conversation pruning & cache scrubbing" -ForegroundColor Gray
    Write-Host "    cache clear         " -ForegroundColor Green -NoNewline
    Write-Host "Alias for 'agy clear' (prunes heavy conversations & clears app caches)" -ForegroundColor Gray
    Write-Host "    cache-clear         " -ForegroundColor Green -NoNewline
    Write-Host "Alias for 'agy clear'" -ForegroundColor Gray
    Write-Host "    predict             " -ForegroundColor Green -NoNewline
    Write-Host "Run in non-destructive prediction mode (default without -y)" -ForegroundColor Gray
    Write-Host "    list-backups        " -ForegroundColor Green -NoNewline
    Write-Host "List all historical conversation pruning transactions" -ForegroundColor Gray
    Write-Host "    undo [tx-id]        " -ForegroundColor Green -NoNewline
    Write-Host "Restore pruned conversations from 'latest' or a specific transaction ID" -ForegroundColor Gray
    Write-Host "    install             " -ForegroundColor Green -NoNewline
    Write-Host "Install Antigravity IDE and CLI (agy)" -ForegroundColor Gray
    Write-Host "    cli                 " -ForegroundColor Green -NoNewline
    Write-Host "Install Antigravity CLI only (agy)" -ForegroundColor Gray
    Write-Host "    check               " -ForegroundColor Green -NoNewline
    Write-Host "Check Antigravity installation status" -ForegroundColor Gray
    Write-Host "    uninstall           " -ForegroundColor Green -NoNewline
    Write-Host "Uninstall Antigravity IDE and CLI" -ForegroundColor Gray
    Write-Host "    help                " -ForegroundColor Green -NoNewline
    Write-Host "Show this help screen" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  FLAGS (for clear / clean / cache clear):" -ForegroundColor Yellow
    Write-Host "    --keep <N> | -k <N> | -k<N> | <N>  " -ForegroundColor Green -NoNewline
    Write-Host "Keep latest N conversations intact (default: all preserved, only heavy pruned)" -ForegroundColor Gray
    Write-Host "    -y | --yes                         " -ForegroundColor Green -NoNewline
    Write-Host "Apply changes (without -y, runs safe prediction only)" -ForegroundColor Gray
    Write-Host "    --kill                             " -ForegroundColor Green -NoNewline
    Write-Host "Terminate running Antigravity processes before clearing" -ForegroundColor Gray
    Write-Host "    --threshold <KB> | -t <KB> | -t<KB> " -ForegroundColor Green -NoNewline
    Write-Host "Conversation size threshold in KB (default: 200 KB)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  EXAMPLES:" -ForegroundColor Yellow
    Write-Host "    .\run.ps1 agy clear                  # Preview cleanup savings without modifying files" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy cache clear -k1        # Preview mode keeping latest 1 conversation intact" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy cache clear            # Same as 'agy clear' (preview mode)" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy cache-clear            # Shorthand alias for cache clear" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy clear -k10 -y          # Apply: keep latest 10 conversations, scrub caches" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy cache clear -y --kill  # Kill running agy processes & scrub caches" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy undo latest            # Revert the last pruning transaction" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy list-backups           # View past backup transaction IDs" -ForegroundColor Green
    Write-Host "    .\run.ps1 agy install                # Install Antigravity IDE & CLI" -ForegroundColor Green
    Write-Host "    .\run.ps1 clean-agy 10               # Root shortcut to prune keeping latest 10" -ForegroundColor Green
    Write-Host ""
    Write-Host "  STANDALONE CLEANERS:" -ForegroundColor Yellow
    Write-Host "    python scripts/os-ai-clean.py --check       # Preview brain & temp cache cleaner" -ForegroundColor Green
    Write-Host "    python scripts/os-ai-clean.py --clean-all   # Purge Antigravity brain & OS temp AI dumps" -ForegroundColor Green
    Write-Host "    .\run.ps1 os dev-clean                      # Clean developer tool caches (Go, npm, pip, cargo)" -ForegroundColor Green
    Write-Host ""
}
