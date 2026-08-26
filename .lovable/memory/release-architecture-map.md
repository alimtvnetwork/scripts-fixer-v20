# Release Architecture Map

## Source of Truth
- `version.json`: Contains the semantic version string for the CLI. All scripts (`run.ps1`, `run.sh`) parse this file to display the version footer.

## How to cut a release
1. Update `version.json` with the new semantic version (e.g. Minor bump: `1.12.0` -> `1.13.0`).
2. Commit the changes.
3. Push to the main branch.
4. The CLI scripts dynamically extract this version at runtime so no hardcoded string changes in the bash/ps1 files are required.

## Restrictions
- NEVER modify or scan `*test*` or `*.spec.*` files during a release version replacement as they contain mock data.
