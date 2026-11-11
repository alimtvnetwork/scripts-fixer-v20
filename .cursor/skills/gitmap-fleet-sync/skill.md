---
name: gitmap-fleet-sync
description: >-
  Autonomously synchronize canonical prompts, skills, and coding-guideline.json
  across all fleet repositories using native GitMap commands without external
  Python scripts.
---

# Native GitMap Fleet Synchronization Skill

> **Invocation:** `@[gitmap-fleet-sync](directory;.cursor/skills/gitmap-fleet-sync)`

Execute comprehensive multi-repository synchronization across the fleet using native `gitmap` CLI commands (`gitmap pull`, `gitmap cg sync --all`, `gitmap cg status --all`, `gitmap cg conflicts`, `gitmap cg resolve`, `gitmap cpc`, `gitmap cpr`, `gitmap push`). This eliminates all reliance on external Python automation scripts.

---

## 1. Core Operating Principles

1. **Native GitMap Commands Only**: All operations MUST use `gitmap` CLI binaries. TOTAL BAN on invoking ad-hoc Python sync scripts or shell loops.
2. **SSOT Dual-File Separation**:
   - `version.json`: Strictly compact repository versioning metadata (`version`, `name`, `releaseDate`, `description`). Must remain under 2 KB.
   - `coding-guideline.json`: Single Source of Truth for coding guidelines version, status, and synchronization telemetry (`syncManifest`).
3. **Mandatory Pre-Flight Pull**: Always execute `gitmap pull` across all targets before synchronizing.
4. **Three-Way Merge Parity**: GitMap native sync automatically computes Merkle section hashes and protects human edits.

---

## 2. Standard Native GitMap Execution Workflow

### Step 1: Pre-Flight Fleet Pull
Pull all repository tracking branches to ensure clean working trees:
```bash
gitmap pa
```
*(or target specific repos with `gitmap pull <path>`)*

### Step 2: Fleet Status Inspection
Inspect installed coding guideline versions across all discovered repositories:
```bash
gitmap cg status --all
```

### Step 3: Dry-Run Preview
Simulate planned file synchronizations without modifying disk:
```bash
gitmap cg sync --all --dry-run
```

### Step 4: Live Three-Way Synchronization
Apply live synchronization across all fleet repositories:
```bash
gitmap cg sync --all --yes
```
*To sync specific domains:*
- Prompts only: `gitmap cg prompt sync --all --yes`
- Skills only: `gitmap cg skill sync --all --yes`

### Step 5: Conflict Inspection & Resolution (If Any)
If sync conflicts arise:
```bash
# Inspect conflicts
gitmap cg conflicts

# Auto-resolve using merged strategy or sidecar clean
gitmap cg resolve --strategy merged
gitmap cg resolve --auto-clean
```

### Step 6: Atomic Commit & Upstream Push
Commit sync updates using GitMap semantic commit verbs:
```bash
# In each updated repository:
gitmap cpc "sync - propagate canonical prompts, skills, and coding-guideline.json"
gitmap push
```

### Step 7: Post-Sync Verification
Confirm fleet-wide active status and version consistency:
```bash
gitmap cg status --all
```
