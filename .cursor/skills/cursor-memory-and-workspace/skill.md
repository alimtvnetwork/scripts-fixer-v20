---
name: cursor-memory-and-workspace
description: >-
  Manage Cursor IDE memory databases, export and import conversation and composer history
  using SQLite (cursor_memory.db), inspect Cursor storage statistics, and synchronize
  repositories with Cursor Project Manager via 'gitmap cursor db' and 'gitmap cursor sync'.
---

# Cursor Memory & Workspace Management

This skill governs Cursor IDE memory management and workspace synchronization across GitMap.

## 1. Capabilities

- **Export Memory:** Snapshot active Cursor composer sessions and conversations into a portable SQLite database (`cursor_memory.db`) via `gitmap cursor db export [output.db]`.
- **Import & Restore:** Restore composer records into Cursor's `state.vscdb` with automatic pre-flight timestamped backups via `gitmap cursor db import <path.db> [--dry-run]`.
- **Storage Statistics:** Inspect real-time database sizes and record counts across `state.vscdb` and `conversation-search.db` via `gitmap cursor db stats`.
- **Read-Only SQL Queries:** Execute arbitrary read-only queries against Cursor's internal storage via `gitmap cursor db query "<sql>"`.
- **Workspace Sync:** Automatically register new repositories in Cursor's Project Manager (`projects.json`) alongside VS Code, Antigravity, and GitHub Desktop during `gitmap repo-create`, `gitmap sync`, and `gitmap scan`.

## 2. CLI Command Reference

```bash
# View storage statistics
gitmap cursor db stats

# Export memory to portable SQLite database
gitmap cursor db export

# Preview import without making changes
gitmap cursor db import backup.db --dry-run

# Execute query on Cursor state
gitmap cursor db query "SELECT composerId, name FROM composerHeaders LIMIT 5"
```
