---
name: gitmap-zip-packaging-and-peak
description: >-
  Autonomously package release binaries with companion automated installers via gitmap zip-bin-downloader
  and inspect zip archive contents with visual directory trees, sizes, and compression ratios via gitmap peak without extracting.
---

# GitMap Zip Packaging & Visual Archive Inspection

> **Invocation:** `@[gitmap-zip-packaging-and-peak](directory;.agents/skills/gitmap-zip-packaging-and-peak)`

Use this skill when tasked with:
1. Packaging GitMap (or other binaries) into versioned release archives with companion PowerShell (`install.ps1`) and POSIX (`install.sh`) installer scripts via `gitmap zip-bin-downloader`.
2. Inspecting and exploring zip archive contents without extracting, visualizing hierarchical folder trees, sizes, and compression ratios via `gitmap peak` (or `gitmap peek`).
3. Auto-discovering and auditing zip archives across workspaces or user Downloads folders.

## 1. Zip Release Packaging (`gitmap zip-bin-downloader`)

Packages compiled binaries with automated companion installers into versioned release archives, mirroring Antigravity Manager (`agm zip`) packaging architecture.

### CLI Usage

```bash
gitmap zip-bin-downloader [destination_path] [flags]
```

### Aliases

- `gitmap zip-downloader`
- `gitmap bin-downloader`
- `gitmap zip-bin`
- `gitmap bin-zip`
- `gitmap downloader`
- `gitmap zip bin-downloader`

### Flags

| Flag | Description |
| :--- | :--- |
| `-o`, `--out`, `--dir <path>` | Custom destination directory or target zip file. |
| `-b`, `--binary <path>` | Custom binary path to package (defaults to active `gitmap.exe`). |
| `-f`, `--force` | Force recompression, bypassing deduplication cache. |
| `--no-reveal` | Suppress opening Windows Explorer or system file manager on completion. |
| `-h`, `--help` | Display terminal help documentation. |

### Architectural Invariants

1. **Companion Scripts:** Generates and embeds self-contained `install.ps1` and `install.sh` scripts both inside the zip archive and beside it in the staging folder.
2. **7-Zip Ultra Compression:** Uses 7-Zip LZMA2 (`-mx=9`) when available; falls back seamlessly to Go standard library `archive/zip` DEFLATE.
3. **Deduplication Caching:** If an identical non-empty archive already exists in the staging directory, packaging is skipped and the archive is instantly revealed (unless `--force`).
4. **Audit History Persistence:** Records every invocation in SQLite `ArchiveHistory` table (`gitmap.db`).

---

## 2. Visual Archive Inspection (`gitmap peak` / `peek`)

Inspects zip archives with visual directory tree structure, sizes, and compression metrics without extracting files.

### CLI Usage

```bash
gitmap peak [zipPath | directory] [flags]
```

### Aliases

- `gitmap peek`
- `gitmap zip-peak`
- `gitmap zip-peek`
- `gitmap pz`
- `gitmap zip peak`
- `gitmap zip peek`

### Flags

| Flag | Description |
| :--- | :--- |
| `--tree` | Hierarchical folder tree rendering with sizes (default mode). |
| `--flat`, `-l` | Flat list of entries (`tar -tf` or `unzip -l` style). |
| `--details`, `-d` | Detailed uncompressed/compressed sizes, timestamps, and permissions. |
| `--json` | Full structured JSON metadata output for automation and pipelines. |
| `-r`, `--recursive` | Recursively discover `.zip` files when a directory path is provided. |
| `-h`, `--help` | Display terminal help documentation. |

### Auto-Discovery Rules

When no path argument is provided (`gitmap peak`):
1. Scans current working directory for `*.zip`.
2. Scans immediate subdirectories of current directory (`*/*.zip`).
3. Scans user Downloads directory (`Downloads/*.zip`).
4. Scans immediate subdirectories of Downloads (`Downloads/*/*.zip`).
5. Displays all discovered archives in sequence.

---

## 3. Reference Files & Documentation

- Implementation: `cli/cmdzip/zip_peak_cmd.go`, `cli/cmdzip/zip_peak_reader.go`, `cli/cmdzip/zip_peak_tree.go`, `cli/cmdzip/zip_peak_scanner.go`
- Packaging: `cli/cmdzip/bin_downloader_cmd.go`, `cli/cmdzip/bin_compressor.go`, `cli/cmdzip/installer_templates.go`
- Help Docs: `cli/helpdoc/peak.md`, `cli/helpdoc/peek.md`, `cli/helpdoc/zip-bin-downloader.md`
- Architecture Specification: `02-spec/21-app/458-gitmap-zip-feature-implementation/01-architecture-spec.md`
