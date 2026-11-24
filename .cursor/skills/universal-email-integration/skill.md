---
name: universal-email-integration
description: >-
  Autonomously design, integrate, and verify universal email sending and reading across any programming language (Python, PowerShell, Bash, Go, Node.js, C#, PHP, Rust), enforcing the 3-Slot Password Security Architecture (RSA-2048 OAEP and 3-split dual Base64), provider connection matrices (Gmail, Office 365, SendGrid, Amazon SES), and PascalCase SQLite persistence.
---

# Universal Email Integration Skill

> **Invocation:** `@[universal-email-integration](directory;.agents/skills/universal-email-integration)`

## Mission & Purpose
This skill provides authoritative architectural guidance, code navigation, and execution rules for:
1. **Universal Email Sending:** Multi-part MIME generation (`multipart/mixed` + `multipart/alternative`), SMTP transmission over STARTTLS (Port 587) and direct SSL/TLS (Port 465), plain text + HTML bodies, and Base64 attachment encoding.
2. **Universal Email Reading:** Inbound IMAP4rev1 (Port 993) and POP3 (Port 995) mailbox ingestion, server-side search (`UNSEEN`, `SINCE`), UID tracking, header parsing, and attachment extraction.
3. **The 3-Slot Password Security Architecture:**
   - **Primary Tier (RSA-2048/4096 OAEP)**: Passwords encrypted into 3 slots (`slot_1`, `slot_2`, `slot_3`) using an RSA public key, with the private key strictly isolated in environment variables (`EMAIL_RSA_PRIVATE_KEY`) or system keystores.
   - **Portable Fallback Tier (Dual-Pass Base64 in 3 Equal Splits)**: Passwords divided into 3 equal splits ($\lceil L/3 \rceil$, $\lceil (L-l_1)/2 \rceil$, remainder), each encoded with Base64 twice (`Base64(Base64(part))`), and stored in `slot_a`, `slot_b`, `slot_c`.
4. **Provider Connection Profiles:** Out-of-the-box configuration for Gmail (App Passwords), Microsoft Office 365 / Outlook, SendGrid, Mailgun, Amazon SES, and generic self-hosted Postfix/Dovecot servers.
5. **SQL Repository Pattern:** PascalCase SQLite database schema (`EmailAccounts`, `EmailCredentials`, `EmailQueue`, `EmailLogs`, `ReceivedMessages`, `MessageAttachments`).

---

## Canonical Documentation & Reference Prompt
- **Master Standalone Execution Prompt:** [05-universal-email-integration-prompt.md](file:///d:/work/gitmap/01-prompts/35-universal-single-file-prompts/05-universal-email-integration-prompt.md)
- **Architecture Spec:** [01-architecture-spec.md](file:///d:/work/gitmap/02-spec/21-app/486-universal-email-integration-spec/01-architecture-spec.md)
- **AI Instructions:** [02-ai-instructions.md](file:///d:/work/gitmap/02-spec/21-app/486-universal-email-integration-spec/02-ai-instructions.md)
- **Execution Plan:** [486-universal-email-integration-spec.md](file:///d:/work/gitmap/.ai-memory/plans/pending/486-universal-email-integration-spec.md)

---

## Key Execution Invariants
- **Strict TLS/SSL Enforcement**: Never transmit email credentials or message payloads over unencrypted cleartext ports (Port 25 or Port 110) without TLS upgrade.
- **Leaf Error Sovereignty**: Functions return strongly-typed errors directly to callers; no unhandled crashes or unclosed socket connections.
- **Symmetric Slot Verification**: Always assert that slot reassembly produces the exact original password before attempting SMTP/IMAP authentication.
