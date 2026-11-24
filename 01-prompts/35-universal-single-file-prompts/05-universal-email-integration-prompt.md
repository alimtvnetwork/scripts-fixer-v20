# Universal Email Integration Engine — Master Standalone Execution Prompt

> **Official Authoritative References & Technical Documentation:**
> - **RFC 5321 — Simple Mail Transfer Protocol (SMTP):** [https://datatracker.ietf.org/doc/html/rfc5321](https://datatracker.ietf.org/doc/html/rfc5321)
> - **RFC 5322 — Internet Message Format:** [https://datatracker.ietf.org/doc/html/rfc5322](https://datatracker.ietf.org/doc/html/rfc5322)
> - **RFC 3501 & RFC 9051 — Internet Message Access Protocol (IMAP4rev1 / IMAP4rev2):** [https://datatracker.ietf.org/doc/html/rfc9051](https://datatracker.ietf.org/doc/html/rfc9051)
> - **RFC 1939 — Post Office Protocol - Version 3 (POP3):** [https://datatracker.ietf.org/doc/html/rfc1939](https://datatracker.ietf.org/doc/html/rfc1939)
> - **RFC 2045 & RFC 2046 — Multipurpose Internet Mail Extensions (MIME):** [https://datatracker.ietf.org/doc/html/rfc2046](https://datatracker.ietf.org/doc/html/rfc2046)
> - **RFC 8314 — Cleartext Considered Obsolete (TLS Ports 465, 993, 995):** [https://datatracker.ietf.org/doc/html/rfc8314](https://datatracker.ietf.org/doc/html/rfc8314)
> - **RFC 8017 — PKCS #1: RSA Cryptography Specifications Version 2.2 (OAEP):** [https://datatracker.ietf.org/doc/html/rfc8017](https://datatracker.ietf.org/doc/html/rfc8017)
> - **Google Workspace & Gmail App Passwords Reference:** [https://support.google.com/accounts/answer/185833](https://support.google.com/accounts/answer/185833)
> - **Microsoft Office 365 Exchange Online SMTP/IMAP Settings:** [https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/pop3-and-imap4/pop3-and-imap4](https://learn.microsoft.com/en-us/exchange/clients-and-mobile-in-exchange-online/pop3-and-imap4/pop3-and-imap4)
>
> **Prompt Version:** 5.0.0 (Master Autonomous Standalone Edition — 100% Sovereign Portability)
> **Target Audience:** Autonomous AI Agents (Antigravity, Cursor, Claude, ChatGPT, Muse), Full-Stack Developers, DevOps Engineers
> **Portability Contract:** Anyone can copy-paste this prompt in full into an isolated AI environment, remote IDE, GitHub Gist, or GitLab Snippet, and the agent will execute the email integration task blindly and safely without requiring any prior codebase files.

```text
================================================================================
           AUTONOMOUS EXECUTION BUDGET & SWARM TOPOLOGY (V6/V7 RULES)
================================================================================
N = 400 (Total self-loop steps budget — default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

PHASE_1_BUDGET = 100     (Steps 1 .. 100: Auth Probe, Credential Slot Encryption, TLS Handshake Assertion)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: Outbound Sender Pipeline, MIME Multipart Synthesis, Attachment Encoding)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Inbound Reader Engine, IMAP Folder Parsing, SQL Repository Logging)
================================================================================
```

---

## 🎯 1. Mission Objectives & Non-Negotiable Directives

When an autonomous AI agent is given this prompt to integrate, construct, or audit **ANY** email subsystem:

1. **Polyglot Portability Invariant:**
   - The integration patterns, security slots, and configuration envelopes must be implementable in **any** programming language without semantic distortion (Python, PowerShell, Bash/Shell, Go, Node.js, C#, PHP, Rust).
2. **Zero Plaintext Passwords Invariant (The 3-Slot Standard):**
   - Application passwords and SMTP/IMAP credentials **MUST NEVER** be stored in plaintext.
   - **Primary Security Mode (Asymmetric RSA-2048/4096 OAEP)**: Passwords are encrypted into 3 slots (`slot_1`, `slot_2`, `slot_3`) using an RSA public key. The private key remains strictly isolated in an environment variable (`EMAIL_RSA_PRIVATE_KEY`) or secure system vault.
   - **Portable Fallback Mode (Dual-Pass Base64 in 3 Equal Splits)**: If RSA libraries cannot be deployed, the password string is deterministically divided into 3 equal splits, each split is Base64-encoded twice (`Base64(Base64(part))`), and persisted in `slot_a`, `slot_b`, `slot_c`.
3. **MIME Multipart RFC 2046 Conformance:**
   - Outbound emails containing HTML must always provide a paired plain text fallback (`multipart/alternative`).
   - Outbound emails with binary attachments must wrap the message in `multipart/mixed`, encoding attachments in Base64 with appropriate MIME `Content-Type` and `Content-Disposition: attachment; filename="..."`.
4. **Strict TLS/SSL Enforcement (No Cleartext Transmissions):**
   - Outbound connections must use STARTTLS (Port 587) or SMTPS (Port 465) with TLS 1.2+ minimum.
   - Inbound connections must use IMAPS (Port 993) or POP3S (Port 995). Cleartext port 25 or port 110 submissions without explicit TLS are strictly prohibited.
5. **SQL Repository Pattern & PascalCase Persistence:**
   - Store configuration, credential slots, outbound queues, and inbound logs in PascalCase tables behind strict repository interfaces.
6. **Robust Error Handling & Leaf Sovereignty:**
   - Leaf functions return strongly-typed errors; no unhandled crashes, socket leaks, or premature process exits.

---

## 📋 2. Turn 1 Understood Showcase Protocol

Before executing any modifications or network calls, the AI must output the Turn 1 Showcase table:

| Dimension | Standard Specification | Target Verification |
| :--- | :--- | :--- |
| **Provider Profile** | Gmail / Office 365 / SendGrid / Generic | Resolved host and port configuration |
| **Outbound Port & TLS** | Port 587 (STARTTLS) or Port 465 (SMTPS) | Tested via TLS handshake before DATA payload |
| **Inbound Port & TLS** | Port 993 (IMAP over SSL/TLS) | Tested via IMAP CAPABILITY & LOGIN |
| **Password Slot Storage** | RSA-2048 OAEP (Primary) or 3-Split Dual B64 | Verified slots reassemble to exact password string |
| **MIME Structure** | `multipart/mixed` + `multipart/alternative` | Plain text + HTML body + Base64 attachments |
| **Database Persistence** | PascalCase SQLite via Repository Pattern | Encapsulated in `EmailAccounts`, `EmailQueue`, `EmailLogs` |

---

## 🔐 3. The 3-Slot Password Security Architecture

### 3.1 Mathematical Division for 3 Splits
Given a password string $P$ of length $L$:
- Split 1 length: $l_1 = \lceil L / 3 \rceil$
- Split 2 length: $l_2 = \lceil (L - l_1) / 2 \rceil$
- Split 3 length: $l_3 = L - l_1 - l_2$

```python
def split_password_into_three(password: str) -> tuple[str, str, str]:
    L = len(password)
    l1 = (L + 2) // 3
    l2 = (L - l1 + 1) // 2
    return password[0:l1], password[l1:l1+l2], password[l1+l2:L]
```

### 3.2 Dual-Pass Base64 Transformation
For each split $k \in \{1, 2, 3\}$:
$$\text{slot}_k = \text{Base64}(\text{Base64}(\text{part}_k))$$
Reversal:
$$\text{part}_k = \text{Base64}^{-1}(\text{Base64}^{-1}(\text{slot}_k))$$

```json
{
  "auth_method": "base64_3_split_dual",
  "encoding": "base64_twice",
  "account": "user@gmail.com",
  "slots": {
    "slot_a": "VkVkT2JFMUhWV2s9",
    "slot_b": "Vm0xd1ExTXlTa2M9",
    "slot_c": "V2xkU2MxSnFVbGs9"
  }
}
```

### 3.3 Asymmetric RSA-2048/4096 OAEP Slot Architecture
- Public key encrypts the password into 3 discrete cipher blocks (`slot_1`, `slot_2`, `slot_3`).
- Private key decrypts and verifies slots in memory prior to SMTP/IMAP AUTH.

```json
{
  "auth_method": "rsa_3_slot",
  "key_fingerprint": "SHA256:7e9a2b8c4d...",
  "slots": {
    "slot_1": "dGhpcyBpcyByc2EgY2lwaGVydGV4dCBibG9jayAx...",
    "slot_2": "dGhpcyBpcyByc2EgY2lwaGVydGV4dCBibG9jayAy...",
    "slot_3": "dGhpcyBpcyByc2EgY2lwaGVydGV4dCBibG9jayAz..."
  }
}
```

---

## 🌐 4. Provider Connection Matrices

### 4.1 Gmail (Google Workspace)
- **SMTP Server**: `smtp.gmail.com`
  - Port: `587` (STARTTLS, Recommended) or `465` (SSL/TLS)
  - Username: Full email address (`user@gmail.com`)
  - Password: **Google App Password** (16 characters, 2-Factor Authentication required)
- **IMAP Server**: `imap.gmail.com`
  - Port: `993` (SSL/TLS mandatory)

### 4.2 Microsoft Office 365 / Outlook
- **SMTP Server**: `smtp.office365.com`
  - Port: `587` (STARTTLS mandatory)
  - Username: Full email address (`user@organization.com`)
- **IMAP Server**: `outlook.office365.com`
  - Port: `993` (SSL/TLS mandatory)

### 4.3 Transactional Relays (SendGrid, Mailgun, Amazon SES)
- **SendGrid**: Host `smtp.sendgrid.net:587`, User: `apikey`, Pass: `<API_KEY>`
- **Mailgun**: Host `smtp.mailgun.org:587`, User: `postmaster@<domain>`, Pass: `<SMTP_PASSWORD>`
- **Amazon SES**: Host `email-smtp.<region>.amazonaws.com:587`, User: `<SES_ACCESS_KEY>`, Pass: `<SES_SECRET>`

---

## 💻 5. Polyglot Implementation Catalog

### 5.1 Python Implementation (Outbound & Inbound + Slots)

```python
import base64
import email
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import imaplib
import os
import smtplib
import ssl
from typing import List, Optional


class CredentialSlotManager:
    """Manages 3-slot password encoding and decoding."""

    @staticmethod
    def encode_dual_base64_slots(password: str) -> dict:
        L = len(password)
        l1 = (L + 2) // 3
        l2 = (L - l1 + 1) // 2
        p1, p2, p3 = password[0:l1], password[l1:l1+l2], password[l1+l2:L]

        def enc2(s: str) -> str:
            b1 = base64.b64encode(s.encode("utf-8"))
            return base64.b64encode(b1).decode("ascii")

        return {"slot_a": enc2(p1), "slot_b": enc2(p2), "slot_c": enc2(p3)}

    @staticmethod
    def decode_dual_base64_slots(slots: dict) -> str:
        def dec2(s: str) -> str:
            b1 = base64.b64decode(s.encode("ascii"))
            return base64.b64decode(b1).decode("utf-8")

        return dec2(slots["slot_a"]) + dec2(slots["slot_b"]) + dec2(slots["slot_c"])


class UniversalEmailClient:
    """Universal SMTP sender and IMAP receiver."""

    def __init__(self, smtp_host: str, smtp_port: int, imap_host: str, imap_port: int, user: str, slots: dict):
        self.smtp_host = smtp_host
        self.smtp_port = smtp_port
        self.imap_host = imap_host
        self.imap_port = imap_port
        self.user = user
        self.password = CredentialSlotManager.decode_dual_base64_slots(slots)

    def send_email(self, to: str, subject: str, text_body: str, html_body: Optional[str] = None, attachments: Optional[List[str]] = None) -> bool:
        msg = MIMEMultipart("mixed")
        msg["From"] = self.user
        msg["To"] = to
        msg["Subject"] = subject

        alt = MIMEMultipart("alternative")
        alt.attach(MIMEText(text_body, "plain", "utf-8"))
        if html_body:
            alt.attach(MIMEText(html_body, "html", "utf-8"))
        msg.attach(alt)

        for path in (attachments or []):
            if os.path.isfile(path):
                with open(path, "rb") as f:
                    part = MIMEApplication(f.read(), Name=os.path.basename(path))
                    part["Content-Disposition"] = f'attachment; filename="{os.path.basename(path)}"'
                    msg.attach(part)

        context = ssl.create_default_context()
        with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
            server.ehlo()
            server.starttls(context=context)
            server.ehlo()
            server.login(self.user, self.password)
            server.send_message(msg)
        return True

    def read_unseen_emails(self, max_count: int = 5) -> List[dict]:
        results = []
        context = ssl.create_default_context()
        with imaplib.IMAP4_SSL(self.imap_host, self.imap_port, ssl_context=context) as imap:
            imap.login(self.user, self.password)
            imap.select("INBOX")
            status, data = imap.search(None, "UNSEEN")
            if status != "OK" or not data[0]:
                return results

            uids = data[0].split()[-max_count:]
            for uid in uids:
                s, fetch_data = imap.fetch(uid, "(RFC822)")
                if s == "OK":
                    msg = email.message_from_bytes(fetch_data[0][1])
                    results.append({
                        "uid": uid.decode("ascii"),
                        "from": msg.get("From"),
                        "subject": msg.get("Subject"),
                        "date": msg.get("Date"),
                    })
        return results
```

---

### 5.2 PowerShell Implementation

```powershell
<#
.SYNOPSIS
  Universal Email Sender and Slot Reassembler in PowerShell 7+
#>

function Reassemble-DualBase64Slots {
    param([hashtable]$Slots)
    $partA = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Slots.slot_a))))
    $partB = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Slots.slot_b))))
    $partC = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Slots.slot_c))))
    return "$partA$partB$partC"
}

function Send-UniversalEmail {
    param(
        [string]$SmtpHost = "smtp.gmail.com",
        [int]$Port = 587,
        [string]$Username,
        [hashtable]$PasswordSlots,
        [string]$To,
        [string]$Subject,
        [string]$BodyHtml,
        [string[]]$Attachments
    )

    $password = Reassemble-DualBase64Slots -Slots $PasswordSlots
    $secPass = ConvertTo-SecureString $password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($Username, $secPass)

    $mail = New-Object System.Net.Mail.MailMessage
    $mail.From = New-Object System.Net.Mail.MailAddress($Username)
    $mail.To.Add($To)
    $mail.Subject = $Subject
    $mail.Body = $BodyHtml
    $mail.IsBodyHtml = $true

    foreach ($file in $Attachments) {
        if (Test-Path $file) {
            $mail.Attachments.Add((New-Object System.Net.Mail.Attachment($file)))
        }
    }

    $smtp = New-Object System.Net.Mail.SmtpClient($SmtpHost, $Port)
    $smtp.EnableSsl = $true
    $smtp.Credentials = $credential.GetNetworkCredential()
    $smtp.Send($mail)
    $mail.Dispose()
    $smtp.Dispose()
    Write-Host "✓ Email sent successfully via $SmtpHost:$Port to $To"
}
```

---

### 5.3 Shell / Bash Implementation (`curl` + `openssl`)

```bash
#!/usr/bin/env bash
# Universal Email Dispatcher via curl and openssl

decode_slot() {
  echo "$1" | base64 -d | base64 -d
}

SEND_EMAIL() {
  local SMTP_HOST="$1"
  local SMTP_PORT="$2"
  local USERNAME="$3"
  local SLOT_A="$4"
  local SLOT_B="$5"
  local SLOT_C="$6"
  local RECIPIENT="$7"
  local SUBJECT="$8"
  local BODY="$9"

  local PASS="$(decode_slot "$SLOT_A")$(decode_slot "$SLOT_B")$(decode_slot "$SLOT_C")"

  local TMP_MAIL=$(mktemp)
  cat <<EOF > "$TMP_MAIL"
From: <${USERNAME}>
To: <${RECIPIENT}>
Subject: ${SUBJECT}
MIME-Version: 1.0
Content-Type: text/html; charset=utf-8

${BODY}
EOF

  curl --ssl-reqd \
       --url "smtp://${SMTP_HOST}:${SMTP_PORT}" \
       --user "${USERNAME}:${PASS}" \
       --mail-from "${USERNAME}" \
       --mail-rcpt "${RECIPIENT}" \
       --upload-file "$TMP_MAIL"

  rm -f "$TMP_MAIL"
}
```

---

### 5.4 Go Implementation

```go
package emailutil

import (
	"crypto/tls"
	"encoding/base64"
	"fmt"
	"net/smtp"
	"strings"
)

type PasswordSlots struct {
	SlotA string `json:"slot_a"`
	SlotB string `json:"slot_b"`
	SlotC string `json:"slot_c"`
}

func ReassembleSlots(slots PasswordSlots) (string, error) {
	dec := func(s string) (string, error) {
		b1, err := base64.StdEncoding.DecodeString(s)
		if err != nil {
			return "", err
		}
		b2, err := base64.StdEncoding.DecodeString(string(b1))
		return string(b2), err
	}

	p1, err := dec(slots.SlotA)
	if err != nil {
		return "", err
	}
	p2, err := dec(slots.SlotB)
	if err != nil {
		return "", err
	}
	p3, err := dec(slots.SlotC)
	if err != nil {
		return "", err
	}

	return p1 + p2 + p3, nil
}

func SendEmail(host string, port int, user string, slots PasswordSlots, to, subject, htmlBody string) error {
	pass, err := ReassembleSlots(slots)
	if err != nil {
		return err
	}

	addr := fmt.Sprintf("%s:%d", host, port)
	auth := smtp.PlainAuth("", user, pass, host)

	header := make(map[string]string)
	header["From"] = user
	header["To"] = to
	header["Subject"] = subject
	header["MIME-Version"] = "1.0"
	header["Content-Type"] = "text/html; charset=UTF-8"

	msg := ""
	for k, v := range header {
		msg += fmt.Sprintf("%s: %s\r\n", k, v)
	}
	msg += "\r\n" + htmlBody

	return smtp.SendMail(addr, auth, user, []string{to}, []byte(msg))
}
```

---

## 🗄️ 6. Database Schema & SQL Repository Pattern

```sql
CREATE TABLE IF NOT EXISTS EmailAccounts (
    Id TEXT PRIMARY KEY,
    EmailAddress TEXT NOT NULL UNIQUE,
    DisplayName TEXT NOT NULL,
    ProviderType TEXT NOT NULL,
    SmtpHost TEXT NOT NULL,
    SmtpPort INTEGER NOT NULL,
    SmtpSecurity TEXT NOT NULL,
    ImapHost TEXT,
    ImapPort INTEGER,
    IsActive INTEGER NOT NULL DEFAULT 1,
    CreatedAt TEXT NOT NULL,
    UpdatedAt TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS EmailCredentials (
    AccountId TEXT PRIMARY KEY,
    AuthMethod TEXT NOT NULL,
    SlotA TEXT NOT NULL,
    SlotB TEXT NOT NULL,
    SlotC TEXT NOT NULL,
    KeyFingerprint TEXT,
    UpdatedAt TEXT NOT NULL,
    FOREIGN KEY(AccountId) REFERENCES EmailAccounts(Id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS EmailQueue (
    Id TEXT PRIMARY KEY,
    AccountId TEXT NOT NULL,
    RecipientTo TEXT NOT NULL,
    Subject TEXT NOT NULL,
    BodyPlain TEXT,
    BodyHtml TEXT,
    AttachmentPaths TEXT,
    Status TEXT NOT NULL,
    RetryCount INTEGER NOT NULL DEFAULT 0,
    CreatedAt TEXT NOT NULL,
    FOREIGN KEY(AccountId) REFERENCES EmailAccounts(Id)
);
```

---

## 🛡️ 7. End-to-End Verification Protocol

1. **Slot Symmetry Assertion**:
   - Verify that any password encoded into `slot_a`, `slot_b`, `slot_c` or `slot_1`, `slot_2`, `slot_3` decrypts/de-obfuscates to the exact original byte sequence.
2. **TLS Handshake Assertion**:
   - Assert server presents a valid certificate chain for the target hostname (preventing MITM attacks).
3. **MIME Conformance Check**:
   - Verify boundary strings conform to RFC 2046 and headers contain valid `Date`, `Message-ID`, and `Content-Type`.
4. **Offline Mock Mode**:
   - Support local testing against Python's built-in `smtpd` or a mock SMTP container without external network credentials.
