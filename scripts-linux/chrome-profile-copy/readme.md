# chrome-profile-copy (Linux / macOS)

Bash port of `scripts/58-install-chrome/helpers/profile-copy.ps1`.
Spec: [`spec/58-install-chrome/profile-copy.md`](../../spec/58-install-chrome/profile-copy.md).

## Commands

```bash
# Clone profile "Default" into a new offline profile "Work"
./profile-copy.sh copy Default to Work

# Same, "to" keyword optional, preview only
./profile-copy.sh copy "Profile 1" "Profile 2" --dry-run

# Export to JSON + CSV under ./chrome-profiles/Default/
./profile-copy.sh export Default

# Export JSON only to a chosen folder
./profile-copy.sh export Default ~/backups --json

# Restore a snapshot into a new profile
./profile-copy.sh import ~/backups/Default/profile.json to Restored

# List discovered profiles (with display names)
./profile-copy.sh list

# Target Brave or Chromium instead of Chrome
./profile-copy.sh --browser brave list
./profile-copy.sh --browser chromium copy Default to Work
```

## Flags

| Flag                | Meaning                                                          |
| ------------------- | ---------------------------------------------------------------- |
| `--dry-run` / `-n`  | Preview only, no disk writes                                     |
| `--yes` / `-y`      | Assume yes on prompts                                            |
| `--force`           | Overwrite destination (timestamped backup is taken) / ignore running browser |
| `--with-logins`     | Include `Login Data` files                                       |
| `--with-site-data`  | Include `Local Storage`, `IndexedDB`, `Session Storage`          |
| `--with-flags`      | Restore `chrome://flags` on `import` (global, all profiles)      |
| `--browser <id>`    | `chrome` (default) \| `chromium` \| `brave`                      |
| `--json` / `--csv`  | Export format (default: both)                                    |

## User-data dir lookup

| OS    | Browser   | Path                                                       |
| ----- | --------- | ---------------------------------------------------------- |
| Linux | chrome    | `~/.config/google-chrome`                                  |
| Linux | chromium  | `~/.config/chromium`, `~/snap/chromium/common/chromium`    |
| Linux | brave     | `~/.config/BraveSoftware/Brave-Browser`                    |
| macOS | chrome    | `~/Library/Application Support/Google/Chrome`              |
| macOS | chromium  | `~/Library/Application Support/Chromium`                   |
| macOS | brave     | `~/Library/Application Support/BraveSoftware/Brave-Browser`|

## Ledger

Every `copy` / `export` / `import` is logged to a SQLite ledger:

- `${XDG_DATA_HOME:-~/.local/share}/dev-server/chrome-profiles.sqlite`
- falls back to `./chrome-profiles/ledger.sqlite` if the dev-server dir is not writable

Inspect with:

```bash
sqlite3 ~/.local/share/dev-server/chrome-profiles.sqlite \
  "SELECT created_at,op,source,target,ok,bytes FROM profile_ops ORDER BY id DESC LIMIT 20;"
```

## Notes

- Chrome **must be closed** before `copy` / `import` (override with `--force`).
- The new profile is registered **offline** -- account/sync binding is stripped
  from both `Local State` and the copied `Preferences`.
- Extensions are listed in the JSON snapshot but not auto-installed on import;
  Chrome requires Web Store installation. Open `chrome://extensions` after import.
