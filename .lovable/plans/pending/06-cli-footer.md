# Goal
Add a detailed version footer to both `run.ps1` and `scripts/run.sh` that displays the Git URL, last SHA, release version (semantic), and last commit timing.

## Subtasks
1. Edit `run.ps1`: Update `Show-VersionFooter` to include commit timing.
2. Edit `scripts/run.sh`: Create a `show_footer` function and call it at the end of the script.
3. Validate output.

## Guidelines Checklist
- [x] Boolean conventions followed.
- [x] No garbage names.
- [x] Semantic updates.

## Review
- Reviewed by Master Orchestrator: All guidelines enforce.