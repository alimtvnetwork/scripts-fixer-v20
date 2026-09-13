# Subtask 19.5: Windows Domain Manager Core & Showcase Engine

## Target Files
- `scripts/76-install-nginx/run.ps1`
- `scripts/76-install-nginx/helpers/showcase-manager.ps1`
- `scripts/76-install-nginx/helpers/hosts-helper.ps1`
- `scripts/76-install-nginx/readme.md`
- `scripts/76-install-nginx/log-messages.json`

## Requirements
1. **`scripts/76-install-nginx/run.ps1`**:
   - Support verbs: `install`, `help`, `add`, `rm`, `list`, `ini`, `showcase`, `start`, `stop`, `reload`, `status`, `test`.
   - Implement `Invoke-NginxAddDomain` with domain validation, vhost compilation, DB commit, INI sync, and reload.
   - Implement `Invoke-NginxRmDomain` with backup generation, conf unlinking, DB update, INI sync, and reload.
   - Implement `Invoke-NginxListDomains` with formatted output table and `--json` support.
   - Implement `Invoke-NginxIniSync` for import, export, and manual sync.
2. **`showcase-manager.ps1` & `hosts-helper.ps1`**:
   - Implements `Invoke-NginxShowcase`: provisions demonstration vhosts, deploys test assets, verifies live HTTP requests, and shows before/after states.
   - Safe hosts file reading and optional loopback mapping with backup.
