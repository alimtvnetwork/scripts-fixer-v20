# Ambiguity: Nginx Domain Manager CLI Syntax, Storage & Showcase Format

> **Status:** resolved  
> **Category:** Architecture & CLI Grammar  
> **Target:** Script 76 (Cross-Platform Nginx Suite)

---

## Question / Scope

What CLI syntax, persistence mechanism, and showcase behavior should be supported for the Nginx Domain Manager?
1. Top-level CLI invocation format (`/run nginx install`, `nginx help`, etc.).
2. Database storage technology for domain registry.
3. INI file synchronization and showcase mechanism.

---

## Resolution

- **Answered on:** 2026-09-09
- **Decision:**
  - Support top-level commands: `/run nginx install`, `nginx help`, `nginx add domain.com`, `nginx add sub.domain`, `nginx rm domain.com`, `nginx list`, `nginx ini`, `nginx showcase`.
  - Use SQLite (`nginx-domains.sqlite3`) with zero-dependency multi-tier fallback (native CLI -> Python standard library bridge).
  - Use declarative INI synchronization (`domains.ini` on Windows, per-site `/etc/nginx/sites.d/<domain>.ini` and master `/etc/nginx/sites.ini` on Linux).
  - Provide a 5-phase interactive showcase demonstrating before/after mutations in real-time across SQLite, INI, and vhosts.
- **Applied solution:**
  - Windows: `scripts/76-install-nginx/run.ps1`, `helpers/sqlite-adapter.ps1`, `helpers/ini-parser.ps1`, `helpers/vhost-compiler.ps1`, `helpers/showcase-manager.ps1`.
  - Linux: `scripts-linux/76-install-nginx/run.sh`, `modules/db_engine.sh`, `modules/ini_engine.sh`, `modules/vhost_engine.sh`, `modules/domain_manager.sh`, `modules/showcase.sh`.
  - Dispatchers: `run.ps1` and `scripts-linux/run.sh`.
