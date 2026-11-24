# GitMap Clone Method Suggestion Master Execution Prompt

> **Prompt Sequence:** 113
> **Status:** ACTIVE / CANONICAL INSTRUCTION
> **Target Projects:** `gitmap`
> **Canonical Spec:** [`02-spec/21-app/113-gitmap-clone-method-suggestion/01-architecture-spec.md`](file;02-spec/21-app/113-gitmap-clone-method-suggestion/01-architecture-spec.md)
> **Ambiguity Document:** [`.ai-memory/ambiguity/new/113-gitmap-clone-method-suggestion-ambiguity.md`](file;.ai-memory/ambiguity/new/113-gitmap-clone-method-suggestion-ambiguity.md)

---

## 1. Goal & Execution Mandate

Autonomously implement an intelligent, context-aware repository suggestion engine across all GitMap clone methods (`gitmap clone`, `gitmap cfr`, `gitmap cfrp`, `gitmap reclone`). When a user inputs a partial, hyphenated, or near-match repository identifier (e.g. `gitmap-v`, `story-telling`), GitMap must search across both local cataloged repositories and backed-up GitHub repositories on the machine, and render high-confidence suggestion boxes using the exact clone method verb invoked by the user.

```text
N = 100 (Total self-loop steps budget)
A = 3   (Spawned subagents concurrency)
H = 2   (Hands / parallel operations per agent)
```

---

## 2. Core Capabilities & Invariants

### 2.1. Clone Verb Preservation
- If invoked via `gitmap cfr <target>`, suggest `gitmap cfr <suggested-target>`.
- If invoked via `gitmap cfrp <target>`, suggest `gitmap cfrp <suggested-target>`.
- If invoked via `gitmap reclone <target>`, suggest `gitmap reclone <suggested-target>`.
- If invoked via `gitmap clone <target>`, suggest `gitmap clone <suggested-target>`.
- TOTAL BAN on hardcoding `gitmap clone` across all clone verbs.

### 2.2. Token Decomposition & Hyphen-Aware Matching
- Split query and repository identifiers by hyphens (`-`), underscores (`_`), and slashes (`/`).
- Prefix match: `gitmap-` matches `alimtvnetwork/gitmap-v28`.
- Stem match: strip version suffixes (`-v[0-9]+`) to compare base stems.
- Edit distance: Levenshtein tolerance $\le 3$ for minor spelling errors.
- Score suggestions with confidence levels ($95\%$ prefix, $90\%$ base stem, $80\%$ edit distance).

### 2.3. Unified Knowledge Base Search
- Search local `Repo` table in `gitmap.db` (`Slug`, `RepoName`, `Alias`, `SshUrl`, `HttpsUrl`).
- Search cached GitHub organization repositories and profile inventories.
- Deduplicate candidates and present top 5 ranked suggestions in Catppuccin / Tokyo Night diagnostic box.

### 2.4. Coding Guidelines & Release Invariants
- Functions $\le 15$ lines max with blank line before returns.
- Strictly positive booleans (`is*`, `has*` only).
- Leaf error sovereignty: return errors directly, outer handlers exit.
- Minor version bump release ceremony (`gitmap cpr`) and local binary deployment (`gitmap swap-binary`).

---

## 3. Autonomous Execution Protocol
1. **Wave 1:** Implement `repo_matcher.go` with token splitting, stem matching, and unit tests.
2. **Wave 2:** Refactor `gh_resolver.go`, `clonefixrepo.go`, `reporeclone.go`, and `clone.go` to preserve clone verbs.
3. **Wave 3:** Integrate local catalog and GitHub backup repo knowledge sources and author E2E integration tests.
4. **Wave 4:** Minor version bump release, local binary swap, and live verification.
