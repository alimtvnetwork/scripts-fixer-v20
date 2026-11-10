---
id: chapter-02-security-audit
name: Chapter 2 Security Audit Checklist
description: Grounded verification matrix for the security-audit type.
category: verification-chapter
placeholders: []
version: 1
---

# 📊 CHAPTER 2: GROUNDED VERIFICATION MATRIX & ACTIONABLE CHECKLIST

### Chapter 2.5: Security & Zero-Trust Audit Matrix
- [ ] **1. Secrets & Credentials:** Zero hardcoded tokens, OAuth client secrets, or private keys in source code or committed artifacts.
- [ ] **2. Network & CIDR Bounds:** Reverse proxy enforces IP allowlists/blacklists, curfew windows, and Cloudflared Zero Trust tunnels.
- [ ] **3. Input Sanitization:** All user parameters, paths, and CLI arguments sanitized against directory traversal and command injection.
- [ ] **4. Safe Keyring & Vault Storage:** Credentials encrypted with AES-256-GCM in separate security SQLite vaults.
