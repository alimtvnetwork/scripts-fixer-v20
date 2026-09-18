# Chrome Profile Copy / Export / Import

Status: shipped (MVP)
Owner: script 58 (`scripts/58-install-chrome`)
Top-level aliases: `chrome-profile-copy`, `chrome-profile-export`, `chrome-profile-import`

## Goal

Give the user a one-liner to clone a Chrome profile (bookmarks, extensions,
preferences, flags, themes) into a **new offline profile** -- no Google sign-in
required. The user can sign in later if they want.

As a side benefit, the same plumbing exposes a portable **export / import**
flow via JSON + CSV, and persists a copy ledger to a local SQLite DB so the
operation is auditable.

## Commands

| Command                                       | What it does                                                                 |
| --------------------------------------------- | ---------------------------------------------------------------------------- |
| `profile-copy <from> to <to>`                 | Copy profile `<from>` to `<to>`. Creates `<to>` offline if missing.          |
| `profile-copy <from> <to>`                    | Same, `to` keyword optional.                                                 |
| `profile-export <name> [<path>]`              | Write `<name>` to JSON + CSV (defaults to `./chrome-profiles/<name>.*`).     |
| `profile-to-json <name> [<path>]`             | Alias for `profile-export` (JSON only).                                      |
| `profile-to-csv <name> [<path>]`              | Alias for `profile-export` (CSV only).                                       |
| `profile-import <path> to <name>`             | Recreate profile `<name>` from a JSON export. Offline.                       |
| `profile-list`                                | List discovered Chrome profiles with display names.                          |

All commands accept `-DryRun`, `-Yes`, `-Help`.

## What "copy" actually copies

Source: `%LOCALAPPDATA%\Google\Chrome\User Data\<from>`
Target: `%LOCALAPPDATA%\Google\Chrome\User Data\<to>`

Whitelisted files / folders (the ones that matter for a like-for-like clone):

- `Bookmarks`, `Bookmarks.bak`
- `Preferences`, `Secure Preferences`
- `Favicons`, `Top Sites`, `History` (sqlite -- copied as-is)
- `Login Data` *(skipped by default -- credentials are tied to the source OS user;
  pass `-WithLogins` to include)*
- `Extensions/` (whole tree)
- `Extension Rules`, `Extension State`, `Extension Scripts`
- `Local Extension Settings/`, `Sync Extension Settings/`
- `Themes/`, `Web Applications/`
- `Local Storage/`, `IndexedDB/` *(opt-in via `-WithSiteData`)*

Skipped always: `Cache`, `Code Cache`, `GPUCache`, `Service Worker`, `Sync Data`,
`Sessions`, `Crash Reports` -- these are runtime / sync caches and bloat the
copy without giving the user anything they would notice.

After files are placed, the new profile is registered in the user-level
`Local State` file by adding an entry to `profile.info_cache.<to>` with the
copied `name` + a default avatar. **No google account is attached**, so
the profile shows up offline. The user can sign in from `chrome://settings`
later.

## Flags / experiments

Chrome flags live in two places:

1. `Local State` -> `browser.enabled_labs_experiments` (per-install, all profiles).
2. `Preferences` -> nothing -- flags are not per-profile in Chrome stable.

For `profile-copy`, the helper does NOT touch global flags (changing them
would affect every profile). For `profile-export`, the current
`enabled_labs_experiments` list is recorded into the JSON snapshot
*for reference only* and surfaced in the CSV under `flag,<name>`. On
`profile-import` we log a warning and skip writing them back unless
`-WithFlags` is passed.

## Export format

```
chrome-profiles/
  <name>/
    profile.json       # full snapshot (preferences subset, bookmarks tree,
                       # extensions list, flags, themes, metadata)
    profile.csv        # flat key/value: section,key,value
    profile.sqlite     # see "SQLite ledger" below
```

`profile.json` schema (top level):

```jsonc
{
  "$schema": "chrome-profile-export/v1",
  "exportedAt": "2026-06-19T12:34:56Z",
  "sourceProfile": "Default",
  "sourceDisplayName": "Work",
  "chromeVersion": "131.0.6778.86",
  "preferences": { /* whitelisted keys: homepage, search, startup, theme */ },
  "bookmarks":   { /* raw Bookmarks JSON (Chrome native shape) */ },
  "extensions":  [ { "id": "...", "name": "...", "version": "...", "enabled": true }, ... ],
  "flags":       [ "enable-quic@1", ... ],
  "themes":      { /* contents of Themes folder, base64 per file (small only) */ }
}
```

CSV is the same data flattened for grep/diff/spreadsheet review:

```
section,key,value
meta,exportedAt,2026-06-19T12:34:56Z
meta,sourceProfile,Default
extension,nngceckbapebfimnlniiiahkandclblb,Bitwarden|2024.12.0|enabled
bookmark,/Bookmarks Bar/Work/Lovable,https://lovable.dev
pref,homepage,https://www.google.com
flag,enable-quic,1
```

## SQLite ledger

Path: `%LOCALAPPDATA%\dev-server\chrome-profiles.sqlite`
(if `dev-server` is missing, the helper falls back to `./chrome-profiles/ledger.sqlite`.)

Schema:

```sql
CREATE TABLE IF NOT EXISTS profile_ops (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  op           TEXT    NOT NULL,        -- copy|export|import
  source       TEXT,
  target       TEXT,
  export_path  TEXT,
  bookmarks    INTEGER DEFAULT 0,
  extensions   INTEGER DEFAULT 0,
  bytes        INTEGER DEFAULT 0,
  ok           INTEGER NOT NULL,        -- 1=success, 0=fail
  error        TEXT,
  created_at   TEXT    NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_profile_ops_op ON profile_ops(op);
```

SQLite is opened via `System.Data.SQLite` if available, else via the bundled
`sqlite3.exe` (looked up on PATH). If neither is present the ledger write is
skipped with a `[WARN]` and the copy still succeeds.

## Safety

- **Chrome must be closed** for `profile-copy` and `profile-import`. The helper
  checks for `chrome.exe` and refuses (override with `-Force`).
- A timestamped backup of the destination profile is taken before overwrite:
  `<User Data>\<to>.bak-<yyyyMMdd-HHmmss>\`.
- `-DryRun` prints every file that would be copied and the registry-style
  `Local State` patch, without touching disk.

## Examples

```powershell
.\run.ps1 chrome-profile-copy Default to Work
.\run.ps1 chrome-profile-copy "Profile 1" "Profile 2" -DryRun
.\run.ps1 -I 58 profile-export Default
.\run.ps1 -I 58 profile-to-json "Profile 1" C:\backups\p1.json
.\run.ps1 chrome-profile-import C:\backups\p1.json to Restored
```
