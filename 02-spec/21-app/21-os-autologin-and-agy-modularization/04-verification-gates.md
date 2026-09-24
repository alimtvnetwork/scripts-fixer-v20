# Specification 21: OS Auto-Login Integration & AGY Commands Modularization — Verification Gates

> **Spec ID:** 21-app/04-verification-gates  
> **Status:** `active`  

---

## 1. Quality & Verification Gates

### Gate 1: Sizing Constraints
- All Python files created in `agy_optimizer/` are strictly **<= 100 lines**.
- All helper scripts target **<= 8 lines** of execution logic per function (max 15 lines).
- No nested `if` statements (guard clauses only).

### Gate 2: Boolean Standard
- Only `is*` and `has*` positive prefixes allowed in variable names, parameter names, and flags.

### Gate 3: Python Testing & Compilation
- Python files pass `python -m py_compile` without warnings.
- Python unit test runner verifies all functions in `agy_optimizer` package (models, scanner, pruner, backup db, predictor, applier).
- Root `agy_optimizer.py` backward compatibility verified.

### Gate 4: Cross-OS Auto-Login Verification
- Windows helper executes `status`, `enable --dry-run`, `disable --dry-run` with exit code 0.
- Ubuntu helper executes `status`, `enable --dry-run`, `disable --dry-run` with exit code 0.
- Dispatchers `scripts/os/run.ps1` and `run.ps1` correctly route `autologin` commands.
