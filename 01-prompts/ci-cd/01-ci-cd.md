# CI/CD Validation Protocol: `ci-cd`

> **Version:** 2.2.0  
> **Scope:** Local test execution and pipeline readiness verification.

---

## Directives
1. Run manifest validation: `node tools/manifest-validate.cjs`.
2. Run JSON configuration validation: `node tools/validate-json-configs.mjs`.
3. Run smoke test runner: `node tools/smoke-check.mjs --id <ID>`.
4. NEVER disable, bypass, or comment out CI/CD checks to achieve a pass.
