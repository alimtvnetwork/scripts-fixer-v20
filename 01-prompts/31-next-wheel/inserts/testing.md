---
id: testing
name: Test Evidence Checklist
description: Sectioned testing insert: targeted tests, error branches, coverage of touched modules, and honest green criteria.
category: insert
placeholders: []
version: 1
---

Why was this declared done without test evidence? Run the targeted checks for every touched module (name the exact check command and module), cover the happy path and the error branches (invalid input, missing files, failed dependencies, permission errors) with observed outcomes, report a green claim only with the exact check, result, and head it ran on, never report success for a skipped, blocked, or truncated check, and close with a per-module scorecard (module, check, result, failures carried forward with diagnostics).
