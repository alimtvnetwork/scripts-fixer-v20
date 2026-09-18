---
name: Current workflow status
description: What is done and what is pending as of v1.27.0
type: workflow
---

# Workflow Status -- v1.39.0 (2026-09-13)

## ✅ Done This Session (v1.39.0)

| Task | Status | Details |
|------|--------|---------|
| Git Reconcile & Remote Sync | ✅ Done | Merged local commits (`472f32e`, `0a66ec1`) with remote releases v1.34.0..v1.38.0 into unified commit `9a09475` |
| Conflict Resolution across Codebase | ✅ Done | Cleanly resolved conflicts in `run.ps1`, `changelog.md`, `version.json`, `readme.md`, `install-keywords.json`, and `.ai-memory/` indices |
| Git Push to Upstream | ✅ Done | Pushed merged `main` (`9a09475`) to `origin/main` (GitHub) without force-pushing |
| Working Tree In-Place Synchronization | ✅ Done | Working tree in `scripts-fixer` 100% clean and synchronized with `origin/main` |
| Standalone Nginx Installer & Suite | ✅ Done | `scripts-linux/76-install-nginx/`, `scripts/76-install-nginx/` with multi-vhost & snippets |
| Nginx Port Changer Enhancement | ✅ Done | `scripts-linux/86-change-port-nginx/` with `--site` and multi-vhost editing |
| WordPress Nginx Hardening | ✅ Done | `scripts-linux/70-install-wordpress-ubuntu/` with FastCGI cache, sensitive file block, and XML-RPC protection |
| Laravel Stack Installer & Automation | ✅ Done | `scripts-linux/77-install-laravel-ubuntu/` and `scripts/77-install-laravel/` with DB & Nginx automation |
| Nginx Domain Manager CLI verbs | ✅ Done | `install`, `help`, `add <domain>`, `rm <domain>`, `list`, `ini`, `showcase` across `run.ps1` and `run.sh` |
| Zero-Dependency SQLite Persistence | ✅ Done | `nginx-domains.sqlite3` with native `sqlite3` CLI + `sqlite-bridge.py` fallback and UTF-8 BOM decoding |
| Tri-State Bidirectional INI Sync | ✅ Done | `domains.ini` (Windows) & `/etc/nginx/sites.ini` (Linux) two-way reconciliation with SQLite & vhosts |
| Automated 5-Phase Showcase | ✅ Done | Terminal demo showing Before -> Add Domains -> Mutated SQLite & INI -> Vhosts -> Rollback |
| High-Performance Exploration Tool | ✅ Done | `03-ai-scripts/17-fast-file-reader.py` with directory mtime caching in `tmp/cache/` (<15ms) |
| Canonical Governance & Spec Files | ✅ Done | `.ai-memory/folder-structure.md`, `.ai-memory/coding-guidelines.md`, `.ai-memory/02-spec/commands/02-nginx-domain-manager.md` |
| AI Prompt & Rules Setup | ✅ Done | `01-prompts/`, `.agents/rules/`, `.ai-memory/prompts.md`, `.ai-memory/suggestions/01-index.md` |
| Changes History & Transaction Logs | ✅ Done | `05-changes-history/01-index.md`, `18-nginx-wordpress-laravel/`, `19-nginx-domain-manager-sqlite/` |

## 🔄 In Progress

_None._

## ⏳ Pending

| Task | Priority | Notes |
|------|----------|-------|
| Kubernetes multi-node cluster setup | Medium | Plan `01-kubernetes-suite.md` |
| VMware Workstation Pro & Fusion Automation | Low | Plan `02-vmware-suite.md` |
| Advanced Terminal Customization & ZSH Profiles | Low | Plan `03-terminal-and-langs.md` |
| Database Clustering & Backup Tools | Low | Plan `04-databases.md` |

## 🚫 Blocked / Avoid

| Item | Reason |
|------|--------|
| Disabling or bypassing CI/CD validation | Hard rule from `strictly-avoid.md` #19 |
| Windows backslashes in Nginx vhost configs | Hard rule from `strictly-avoid.md` #18 |
| Literal multibyte Unicode glyphs in PS 5.1 | Hard rule from `strictly-avoid.md` #16 |
| Null-coalescing `??` operators in PS scripts | Hard rule from `strictly-avoid.md` #14 |
