---
name: ci-cd
description: Execute local CI/CD validation protocols, manifest verification, JSON schema checks, and smoke tests without bypassing pipelines.
---

# CI/CD Validation Protocol (`ci-cd`)

Runs comprehensive local CI/CD checks, schema validations, and smoke tests to guarantee pipeline readiness before pushing commits.

## Core Directives
1. **Manifest Validation**: Execute `node tools/manifest-validate.cjs` to confirm script registry integrity.
2. **JSON Schema Validation**: Execute `node tools/validate-json-configs.mjs` to ensure all `config.json` and `log-messages.json` conform.
3. **Smoke Test Execution**: Run targeted smoke tests via `node tools/smoke-check.mjs --id <ID>`.
4. **Zero-Bypass Policy**: NEVER disable, comment out, or bypass CI/CD checks or GitHub Actions workflows to force a pipeline to pass.
