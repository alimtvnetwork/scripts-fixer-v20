# Specification 27.08: Script Notification, Webhook Dispatch & Alerting Protocol

## 1. Executive Overview

This specification establishes the **Script Notification, Webhook Dispatch & Alerting Pipeline** for the Universal Bug Reporting System. When a defect, fatal crash, or recording session is finalized, the system must deterministically notify engineering teams, CI/CD runners, and incident response systems without human intervention.

The notification architecture supports three distinct dispatch modes:
1. **Direct Webhook HTTP POST** (JSON payload with HMAC-SHA256 signature).
2. **Local Script Execution & CLI Integration** (invoking custom developer alert scripts e.g. `.ps1`, `.sh`, `.py`).
3. **SMTP / Email Dispatch with Offline Queue Resilience** (retrying when networks are intermittent).

---

## 2. Notification Envelope & Payload Contract

Every notification event sends a standardized **Universal Notification Envelope (UNE)**:

```json
{
  "EventId": "evt-notif-20261103-164000-8812",
  "EventType": "BUG_RECORDING_FINALIZED",
  "TimestampUtc": "2026-11-03T16:40:00.124Z",
  "Severity": "ERROR",
  "Machine": {
    "Hostname": "LAB-INSPECT-04",
    "OperatingSystem": "Windows 11 Pro (10.0.26100)",
    "Username": "eng-operator-01",
    "Architecture": "x86_64",
    "Source": "harvested"
  },
  "Session": {
    "SessionId": "rec-20261103-163900-4491",
    "Title": "False Defect on Pin 1 Optical Inspection",
    "Category": "Inspection",
    "DurationMs": 42000,
    "StepCount": 12,
    "ScreenshotCount": 8,
    "InitialRoute": "/projects/smt-demo",
    "FinalRoute": "/projects/smt-demo/analyze"
  },
  "Summary": {
    "ExpectedBehavior": "Pin 1 detector should match fiducial with >85% confidence score.",
    "ActualBehavior": "Returns 0.00 score and flags FALSE_DEFECT on pocket 2.",
    "Reporter": "eng-operator-01"
  },
  "Artifacts": {
    "BundleZipPath": ".logs/recorded-bugs/rec-20261103-163900-4491/bundle.bug.zip",
    "PromptV6Path": ".logs/recorded-bugs/rec-20261103-163900-4491/prompt-v6.md",
    "PromptV7Path": ".logs/recorded-bugs/rec-20261103-163900-4491/prompt-v7.md"
  },
  "RulesBreakdown": [
    {
      "RuleId": "rule-pin1",
      "RuleName": "Pin 1 Presence",
      "PassCount": 4,
      "FailCount": 1,
      "Verdict": "FAIL"
    }
  ]
}
```

---

## 3. Dispatch Transport Modes

### Transport A: Webhook HTTP POST
- **Endpoint**: Configurable URL (e.g. `https://internal.ops.corp/api/telemetry/bugs`).
- **Headers**:
  - `Content-Type: application/json`
  - `X-Bug-Signature: sha256=<hmac_hex>`
  - `X-Correlation-Id: <correlation_id>`
- **Behavior**:
  - Timeout: 5000ms.
  - On network failure: Enqueue into local SQLite offline queue (`bug_notification_queue`).

### Transport B: Local Shell Script Execution
When the environment variable `BUG_NOTIFY_SCRIPT` is defined (or configured in `run.config.json`):
- Executes: `$BUG_NOTIFY_SCRIPT <BUNDLE_ZIP_PATH> <SESSION_ID>`
- Exit code 0 indicates success. Non-zero triggers a logged warning in `.logs/telemetry.log` and marks the delivery for retry.

### Transport C: Email Notification with Offline Queue
- Formats dual multipart MIME message:
  - **Plain Text**: Formatted ASCII table of steps, rules, and machine specs.
  - **HTML**: Dark-themed styled summary table with direct links to local bundle and screenshots.
- **Offline Storage**:
  - If offline, stores in `localStorage['cat_vision_offline_email_queue']` (web client) or `bug_notification_queue` table in SQLite (backend).
  - Automatically flushed when `navigator.onLine` fires or during preflight check of next run.

---

## 4. CLI Notification Command Interface

The CLI provides commands to inspect, retry, or manually dispatch notifications:

```bash
# 1. Trigger manual notification for a session
python bin/errors-cli.py --session rec-20261103-163900-4491 --notify

# 2. Inspect offline notification queue
python bin/errors-cli.py --list-offline-notifications

# 3. Flush and dispatch all pending offline notifications
python bin/errors-cli.py --flush-notifications
```

---

## 5. Blind-AI Implementation Checklist for Notifications

1. [x] Define `NotificationConfig` structure containing `webhookUrl`, `senderEmail`, `recipientEmail`, `isEnabled`, and `hasOfflineQueue`.
2. [x] Implement persistent storage for notification configuration (`localStorage` and SQLite settings).
3. [x] Implement payload serializer converting recorded session + breakdown into JSON envelope.
4. [x] Implement retry loop with exponential backoff for HTTP webhook dispatch.
5. [x] Ensure all notifications include exact machine hostname, OS, and user identity.
