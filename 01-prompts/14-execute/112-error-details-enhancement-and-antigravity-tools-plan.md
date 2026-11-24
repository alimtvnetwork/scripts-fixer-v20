# Error Details Enhancement and Antigravity Tools Master Execution Prompt

> **Prompt Sequence:** 112
> **Status:** ACTIVE / CANONICAL INSTRUCTION
> **Target Projects:** `gitmap`, `Antigravity Manager`, `Antigravity Tools`
> **Canonical Spec:** [`02-spec/21-app/112-error-details-enhancement-and-antigravity-tools-plan/01-architecture-spec.md`](file;02-spec/21-app/112-error-details-enhancement-and-antigravity-tools-plan/01-architecture-spec.md)
> **Antigravity Plan:** [`02-spec/21-app/112-error-details-enhancement-and-antigravity-tools-plan/02-antigravity-tools-plan.md`](file;02-spec/21-app/112-error-details-enhancement-and-antigravity-tools-plan/02-antigravity-tools-plan.md)

---

## 1. Goal & Execution Mandate

Autonomously implement comprehensive error detail enhancements across CLI inspection commands (`gitmap e <id>`, `gitmap errors show <id>`, `gitmap error-details [limit]`) and establish full architectural parity in `Antigravity Manager` / `Antigravity Tools`.

```text
N = 100 (Total self-loop steps budget)
A = 3   (Spawned subagents concurrency)
H = 2   (Hands / parallel operations per agent)
```

---

## 2. Mandatory Core Capabilities

### 2.1. Suggestive Commands Section
At the bottom of single error inspection views, render suggestive commands:
- **Next error:** `gitmap e <ID+1>`
- **Previous error:** `gitmap e <ID-1>`
- **5 similar by type:** `gitmap errors --type <Type> --limit 5`
- **Show last 30 details:** `gitmap error-details 30`
- **Show last 30 by type:** `gitmap errors --type <Type> --limit 30`
- **Export this to file:** `gitmap e <ID> --export ./error-<ID>.json`
- **View in JSON format:** `gitmap e <ID> --json`
- **AI understanding:** `gitmap e <ID> --ai`

### 2.2. Conditional Paths Section
- Inspect `SourceFile`, `RepoPath`, `InputsJson`, `ContextJson`, and parsed error messages.
- If paths are present, group by category (`Source File`, `Database`, `Image File`, `Workdir`, `Target Repo`).
- **CRITICAL:** If NO paths exist, strictly suppress (do not print) the `Paths:` section.

### 2.3. Conditional Reference Variables Section
- Extract execution parameters, timeouts, query limits, slug identifiers, and calculation dimensions from `InputsJson` and `ContextJson`.
- Exclude keys containing file paths.
- **CRITICAL:** If NO variables exist, strictly suppress (do not print) the `Reference Variables:` section.

### 2.4. File Export Capability (`--export <path>` / `-o <path>`)
- Serialize full structured JSON envelope (record, paths, reference variables, cause chain, stack trace, AI diagnostics, suggestive commands) to `<path>`.
- Automatically create parent directories if non-existent.
- Emit green confirmation notice.

### 2.5. AI Understanding & Diagnostics (`--ai`)
- Output structured explanation covering `Category`, `Root Cause`, and `Recommended Fix`.

### 2.6. Antigravity Tools Parity
- Add `PathsJson`, `ReferenceVariablesJson`, `AiUnderstandingJson` columns to `errors.db`.
- Add interactive action pills in the web error drawer modal.
- Support CLI commands `agm errors show <id>`, `agm errors next`, `agm error-details 30`.

---

## 3. Implementation Rules & Constraints
1. **Error Sovereignty:** Leaf functions return error directly; never call exit handlers.
2. **Function Limits:** Functions <= 15 lines max with blank line before return.
3. **Boolean Hygiene:** Positive booleans prefixed with `is` or `has` only.
4. **Git Discipline:** Clean commit using `gitmap cpf` and push.
