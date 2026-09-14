# Completed Plan: 28-sqlite-db-profile-vmware

## Overview
Implemented an integrated, zero-dependency SQLite database tracking system, profile idempotency tree rendering, and automated VMware tools & shared folder management across Linux and Windows scripts in the repository.

### Key Deliverables Completed
1. **SQLite Database Common Engine**:
   - Database location: ${SCRIPTS_FIXER_DB:-C:\Users\Administrator/.local/share/scripts-fixer/scripts-fixer.db} on Linux and $LOCALAPPDATA/scripts-fixer/scripts-fixer.db on Windows (fallback to .data/scripts-fixer.db).
   - Strictly ignored by .gitignore (*.db, *.sqlite, *.sqlite3, *.db-shm, *.db-wal, *.db-journal, .data/, .db/).
   - Python bridge scripts/shared/db_bridge.py: schema migrations, packages, profiles, install_logs, and rror_logs tables.
   - Dual-engine shell wrapper scripts-linux/_shared/db.sh and scripts/shared/db.sh: nsure_db, db_record_start, db_record_success, db_record_failure, db_record_skipped, db_is_installed, db_get_status.
   - PowerShell database recording integrated into scripts/66-install-vmware/run.ps1.

2. **Profile Idempotency & Tree Display**:
   - Enhanced scripts/shared/profile_tree.py with component check functions (check_component_installed, is_profile_installed) and CLI commands (is-installed, show-installed).
   - When already installed (without --force): outputs [  OK  ] Profile '<name>' is already installed. and displays the formatted hierarchy tree with [✔ Already Installed] annotations.
   - Idempotency check logs skipped status to the SQLite database.

3. **VMware Tools & Shared Folder Integration (Linux & Windows)**:
   - Automated installation of open-vm-tools and open-vm-tools-desktop via scripts/os/ubuntu/install-vmware-tools.sh.
   - Automated mounting of VMware shared folders (.host:/ to /mnt/hgfs) via scripts/os/ubuntu/vmware-mount-shared.sh.
   - Guaranteed one-time desktop symlink creation (~/Desktop/SharedDirectories -> /mnt/hgfs) avoiding redundant re-links or broken targets.
   - Boot persistence via systemd service mware-mount-shared.service and crontab fallback @reboot.
   - Windows installer scripts/66-install-vmware/run.ps1 updated with StrictMode property safety and SQLite event recording.

4. **Dispatchers, Parity & Verification**:
   - scripts/run.sh updated with top-level mware, mware-tools, mware-mount commands, profile idempotency skipping, and SQLite logging.
   - Single source of truth egistry.yaml updated with Windows 66-install-vmware mapping, synced via 	ools/registry-sync.cjs.
   - scripts/shared/install-keywords.json updated with mware, mware-tools, mwaretools pointing to script 66.
   - Shell completions for bash, zsh, and powershell updated and verified in sync via 	ools/gen-completions.cjs --check.
   - Verified in Git Bash and PowerShell.
