# Subtask Execution Protocol: `execute`

> **Version:** 2.2.0  
> **Scope:** Multi-agent autonomous task execution.

---

## Directives
1. Strict 2-agent concurrency limit.
2. Maintain active file locks in `.ai-memory/01-index.md`.
3. Verify all code changes using platform-specific smoke tests and syntax validators.
4. Perform atomic tri-state synchronization across databases, configurations, and service virtual hosts.
