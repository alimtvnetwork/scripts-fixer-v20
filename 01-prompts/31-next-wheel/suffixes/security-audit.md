---
id: security-audit
name: Security (Secrets & Zero-Trust)
description: Secrets scrub, credential protection, input validation & zero-trust
category: security
placeholders: []
version: 1
default: false
---

### Security & Zero-Trust Audit:
- Scan for leaked secrets, API keys, tokens, or hardcoded passwords.
- Ensure reverse proxy IP security and CIDR bounds.
- Sanitize untrusted user inputs before SQLite queries or shell execution.
- Validate AES-256-GCM encrypted credential vault isolation.
