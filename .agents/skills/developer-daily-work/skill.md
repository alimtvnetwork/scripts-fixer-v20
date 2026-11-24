---
name: developer-daily-work
description: >-
  Universal master guidance for daily developer work and AI agent operations.
  Enforces deep codebase comprehension first, zero guideline hallucination from
  on top of the head, explanation before code modification, strict backwards
  compatibility (Zero Harm), and an ABSOLUTE BAN on reading .env or credential
  files. Activate this skill whenever beginning daily developer tasks, modifying
  code, or interacting with a new codebase.
---

# Master Guidance for Developer Daily Work & AI Agent Operation

> **Canonical Prompt:** `01-prompts/36-developer-daily-master-prompt/01-developer-daily-master-prompt.md`
> **Single-File Edition:** `01-prompts/35-universal-single-file-prompts/04-developer-daily-master-prompt.md`
> **Registration Engine:** `03-ai-scripts/71-register-developer-master-prompt-as-copilot-skill.py`

---

## 1. Core Operating Invariants

### Invariant 1: Deep Codebase Comprehension First
- Explore the repository layout, inspect `README.md`, `what-to-read.md`, and project specs before touching code.
- Understand how existing abstractions, functions, and error handlers are structured.

### Invariant 2: ZERO Overriding of Coding Guidelines "From on Top of the Head"
- Never impose arbitrary style rules or refactor code based on internet bias.
- The codebase's existing conventions, `README.md`, and specifications are the SOLE authority.

### Invariant 3: Explanation & Playing Safe (Zero Harm Architecture)
- Explain the rationale and plan before applying changes.
- Prioritize backwards compatibility, graceful fallbacks, and zero regressions.

### Invariant 4: ABSOLUTE BAN on Reading `.env` and Credential Files
- Under NO circumstances may an AI read, cat, print, search, or process `.env`, `.env.*`, `*.pem`, `*.key`, `id_rsa*`, tokens, or credential JSONs.
- Use `.env.example` solely for variable names.

---

## 2. The 7-Step Daily Execution Cycle

1. **Read Repo README & Specs First:** Ingest project purpose, build commands, and layout.
2. **Inspect Existing Code Patterns:** Match surrounding naming, error handling, and signatures.
3. **Formulate Plan & Explain Rationale:** Present surgical approach to user before editing.
4. **Credential Safety Gate:** Verify no `.env` or credential files are in the touch list.
5. **Apply Surgical Edits:** Keep functions $\le 15$ lines, zero nested ifs, positive booleans.
6. **Self-Verification:** Run linters, unit tests, and UNIX LF line-ending checks.
7. **Atomic Semantic Commit:** Commit using semantic verbs (`gitmap cpf`, `gitmap cbf`, `gitmap cfr`, `gitmap cpc`).
