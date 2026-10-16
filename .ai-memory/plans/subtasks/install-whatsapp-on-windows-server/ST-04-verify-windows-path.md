# ST-04: Verify regular Windows path (read-only)

## Goal

Ensure Script 49's existing regular Windows install path is intact and unaffected by ST-01/ST-02 changes.

## Work

1. Read-only review of `scripts/49-install-whatsapp/` (do NOT modify).
2. Verify: Chocolatey → official installer fallback chain is preserved for Workstation SKUs.
3. Verify: no Server-specific logic leaks into the Workstation path.
4. Report any issues found to the lead; do not fix (lead coordinates).

## Acceptance

- Review complete
- Written report of findings (no changes made)
