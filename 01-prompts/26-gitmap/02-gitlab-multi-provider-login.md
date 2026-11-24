> [!IMPORTANT]
> Prompt Version: 6.1.0
> Runtime: Google Antigravity 2.0 (IDE and CLI) & Cursor IDE
> Category: 26-gitmap
> Invoke: /gitmap gitlab-login
>
> **Top-Instruction Priority Mandate (Above Precedence):**
> Whatever instructions, constraints, domain rules, or user prompts are given ABOVE this prompt (or passed as leading task input) are HIGHEST PRIORITY and MUST BE FOLLOWED as strictly NON-NEGOTIABLE.
> This prompt provides the autonomous execution engine; top instructions provide the mission authority.

# GitMap GitLab Multi-Provider Authentication & Namespace Integration — Canonical Specification (must follow)

> **Antigravity Slash Command Compatibility:**
> Use `[/goal](slashCommand;goal)` to run long-running execution without stopping until verified.
> Use `[/learn](slashCommand;learn)` to persist learned architectural conventions and rules.

You are pair programming with **GitMap**, the ultra-fast developer companion and autonomous CLI engine designed for AI coding agents and software engineers.

---

## 1. Provider-Specific Login Invariants & Routing Rules

1. **Default Login Invariant**:
   - Invocations of bare `gitmap login` (with or without flags like `ssh`, `token`, `browser-flow`, `--status`) MUST ALWAYS target **GitHub** by default.
   - Preserves complete backwards compatibility for existing automated pipelines, agent scripts, and developer workflows.

2. **Explicit Provider Targeting**:
   - `gitmap login github [args...]`: Explicitly directs the login request to GitHub.
   - `gitmap login gitlab [args...]`: Explicitly directs the login request to GitLab.
   - `gitmap gitlab login [args...]`: Symmetrical alias under the `gitlab` root command.

3. **SSH-First Verification Flow**:
   - When running `gitmap login gitlab` (or `gitmap gitlab login`) without explicit credentials:
     - Automatically probes SSH transport via `ssh -T git@gitlab.com`.
     - When verified (e.g. `Welcome to GitLab, @<user>!`), prints verification card:
       ```text
       ✔ SSH verified for <user> (GitLab).
         • Host      : gitlab.com
         • Account   : @<user>
         • Transport : git@gitlab.com (SSH)
         • Status    : Authorized
       ```
     - When unverified, displays public key path and step-by-step guidance to register the key at `https://gitlab.com/-/user_settings/ssh_keys`.

4. **Personal Access Token (PAT) Flow**:
   - `gitmap login gitlab token <PAT>` (or `gitmap gitlab login token <PAT>`):
     - Validates the token against `https://gitlab.com/api/v4/user`.
     - Confirms user identity and grants API access.

5. **Namespace vs. Repository URL Disambiguation**:
   - User or group URLs (e.g. `https://gitlab.com/<username>`) MUST NOT be forwarded to `git clone`.
   - GitMap intercepts namespace URLs, connects to the GitLab v4 API (`/users?username=:user`), and presents profile and accessible repository inventories.

---

## 2. Command Reference Table

| Command | Provider | Action | Fallback / Behavior |
| :--- | :--- | :--- | :--- |
| `gitmap login` | GitHub | Default GitHub login flow | SSH-first probe, device/token fallback |
| `gitmap login github` | GitHub | Explicit GitHub login flow | Interactive menu / SSH-first |
| `gitmap login gitlab` | GitLab | Explicit GitLab login flow | SSH-first probe (`git@gitlab.com`) |
| `gitmap gitlab login` | GitLab | Symmetrical alias for GitLab login | Symmetrical with `gitmap login gitlab` |
| `gitmap login gitlab token <PAT>` | GitLab | Token validation & login | Validates via `api/v4/user` |
| `gitmap gitlab connect <target>` | GitLab | Probe user or group profile | Queries user details & projects |
| `gitmap gitlab status` | GitLab | Check provider & auth telemetry | Reports CLI, token, and SSH state |
| `gitmap provider status` | Unified | Check active & default provider | Lists both GitHub and GitLab states |
| `gitmap provider set <provider>` | Unified | Update default remote host | Persists choice to configuration |

---

## 3. Strict Coding Guidelines & Implementation Constraints

1. **15-Line Function Limit**:
   - Functions <= 8 lines preferred, <= 15 lines max. Decompose multi-step routines into discrete single-responsibility helpers.
2. **Zero Nested Conditionals**:
   - Flatten all nested if statements using guard clauses and early returns.
3. **Boolean Naming**:
   - All boolean variables and fields MUST begin with `is` or `has` ONLY (`isVerified`, `hasToken`, `isDefault`).
   - TOTAL BAN on negative booleans (`isNotValid`, `unverified`).
4. **Leaf Error Sovereignty**:
   - Leaf functions returning `error` MUST return the error directly (`return err` or `return apperror.WrapSimple(...)`).
   - Leaf functions MUST NEVER call exit handlers (`cliexit.HandleError`) or `os.Exit`.
5. **No Magic Strings or Integers**:
   - Use strongly-typed constants and enums for provider identifiers (`constants.ProviderGitHub`, `constants.ProviderGitLab`).
   - Never pass raw integer exit codes.
6. **Strict Relative Paths**:
   - All citations, plans, and specs must use relative repository paths. TOTAL BAN on absolute filesystem paths.
