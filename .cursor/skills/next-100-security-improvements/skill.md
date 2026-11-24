---
name: next-100-security-improvements
description: "Autonomously scan, audit, discover, model, and document 100 concrete security improvements and threat mitigations across 10 security clusters using an 8-field specification schema, review-first gating, and pending plan enqueueing."
---

# Next 100 Security Improvements Skill

> **Invocation:** `@[next-100-security-improvements](directory;.agents/skills/next-100-security-improvements)`

Autonomously conduct an exhaustive, 10-cluster security diagnostic audit across the target repository and ecosystem, inspect IPC boundaries, credential vaults, REST endpoints, database queries, and filesystem interactions, and synthesize exactly 100 concrete, defense-in-depth security improvements and threat mitigations structured into 10 thematic security clusters.

## 10 Security Clusters
1. **Cluster 01: Credential Vaulting & Secret Hygiene** (Zero plaintext tokens in git repositories, Master AES vaulting in SQLite, Telegram Bot token encryption, environment variable scrubbing, pre-commit secret leak gates).
2. **Cluster 02: Tauri v2 IPC Command & Event Sandboxing** (Granular capability-based command permission policies, IPC argument validation, origin checks, window management restriction).
3. **Cluster 03: Subprocess Execution & Windows Job Breakaway Hardening** (`spawn_with_job_breakaway_fallback`, argument sanitization, banning raw batch file execution in `Command::new`, path traversal guards on binaries).
4. **Cluster 04: Local HTTP/REST & WebSocket Endpoint Security** (Ports 19527 & 8045 bind address validation `127.0.0.1`, Origin/Host header inspection, strict CORS restrictions, CSRF prevention for REST mutations, rate limiting).
5. **Cluster 05: SQLite Split-DB & SQL Injection Defense** (Parameterized queries everywhere, transaction isolation, Split-DB permission boundaries, secure WAL deletion, preventing dynamic table name injection in SQLite visualizer/REST).
6. **Cluster 06: File System Path Traversal & Workspace Isolation** (Canonicalizing workspace paths, directory traversal guards `..`, file permission enforcement, safe temporary directory lifecycle, preventing symlink escapes).
7. **Cluster 07: Prompt Sanitization, Context Scrubbing & Injection Defense** (Agent-client prompt sanitization, intercepting adversarial system prompt overrides, filtering leaked secrets in conversation transcripts, stripping risky headers).
8. **Cluster 08: Multi-Instance Profile Isolation & Data Leakage Prevention** (Workspace storage partition, preventing cross-profile cookie/token sharing, process sandboxing, credential leakage across multi-tenant fleet).
9. **Cluster 09: Telemetry, Crash Logs & PII Anonymization** (Redacting user filesystem paths, usernames, and hostnames in anonymous crash telemetry, error database sanitization).
10. **Cluster 10: Supply Chain, Crate Auditing & Dependency Integrity** (Automated `cargo audit` and `npm audit` scanning in CI/CD, pinning trusted crate and npm package versions with verifiable checksum locks).

## Associated Canonical Prompt
- [`01-prompts/30-improvements/09-next-100-security-improvements.md`](file;01-prompts/30-improvements/09-next-100-security-improvements.md)
