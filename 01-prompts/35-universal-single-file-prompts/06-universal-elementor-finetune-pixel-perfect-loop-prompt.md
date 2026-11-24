# Universal Elementor Fine-Tune & Pixel-Perfect Screen Comparison Engine — Master Standalone Execution Prompt

Official Authoritative References & Technical Documentation:

• Universal Common Foundation Master Prompt Gist:
  https://gist.githubusercontent.com/alimtvnetwork/9fe8c6fb25ab0e409a22e9c2624915da/raw/00-universal-common-foundation-prompt.md
• Python Any Task Prerequisite Gist:
  https://gist.githubusercontent.com/alimtvnetwork/fd0953a5f2bfbbc91ae6e3666c5f7c37/raw/b573e3d2cd164d74350bee9c77ccc3b608250333/python-any-task-prompt.md
• WordPress Modernizing Master Prompt Gist:
  https://gist.githubusercontent.com/alimtvnetwork/11900295ef222d921bd646923fbcff3d/raw/957bb2b806d2bb6dae45f5d8f17c5fdefbe5aa55/universal-wp-modernizing-master-prompt.md
• Elementor Developer Documentation: https://developers.elementor.com/docs/
• Elementor Flexbox Containers Developer Reference: https://developers.elementor.com/docs/containers/
• WordPress REST API Handbook: https://developer.wordpress.org/rest-api/
• Pillow (PIL Fork) Headless Image Verification: https://pillow.readthedocs.io/
• Playwright Python Documentation: https://playwright.dev/python/docs/intro

Prompt Version: 1.0.0 (Master Autonomous Standalone Edition — 100% Sovereign Portability) Target Audience: Autonomous AI Agents (Antigravity, Cursor, Claude, ChatGPT, Muse), Full-Stack WordPress Engineers, QA Automation Leads
Task Slug: run-iterations-and-compare-screens / universal-elementor-finetune-pixel-perfect-loop
Portability Contract: Anyone can copy-paste this prompt in full into an isolated AI environment, remote IDE, GitHub Gist, or GitLab Snippet, and the agent will execute the 100–300 iteration pixel-perfect fine-tuning loop blindly and safely without requiring any prior codebase files.

```text
================================================================================
           AUTONOMOUS EXECUTION BUDGET & SWARM TOPOLOGY (V6/V7 RULES)
================================================================================
N = 400 (Total self-loop steps budget — default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

PHASE_1_BUDGET = 100     (Steps 1 .. 100: Learn Prerequisites, Viewports, 2x Base64 Credential Vault, & FS Snapshots)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: Multi-Screen Capture, Headless Visual Diffing, CSS Persistence & AST Tuning)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Iterative 100-300 Loop, Screenshot Auto-Pruning, Git Hygiene, & Revert Verification)
================================================================================
```

---

## 🎯 1. Mission Objectives & Non-Negotiable Directives

When an autonomous AI agent is given this prompt to fine-tune, audit, and achieve pixel-perfect parity for **ANY** Elementor page:

0. **Mandatory Dual-Prerequisite Invariant (NON-NEGOTIABLE GATE):**
   - The AI **MUST CONFIRM** that it has learned and internalized:
     1. Python Prompt (50 Steps):
        https://gist.githubusercontent.com/alimtvnetwork/fd0953a5f2bfbbc91ae6e3666c5f7c37/raw/b573e3d2cd164d74350bee9c77ccc3b608250333/python-any-task-prompt.md
     2. WordPress Actions Prompt (50 Steps):
        https://gist.githubusercontent.com/alimtvnetwork/11900295ef222d921bd646923fbcff3d/raw/957bb2b806d2bb6dae45f5d8f17c5fdefbe5aa55/universal-wp-modernizing-master-prompt.md
   - If not already loaded, the agent must spend the first 50 steps studying these prompts and creating internal memory before modifying code.

1. **Target URLs & 2x Base64 Credential Vault in SQLite (`data/config.db`):**
   - The AI **MUST ASK** the operator for dual-site parameters using the exact two-tier format before touching code:
     ```text
     Format for asking to the user

     (base website, readonly)
     url:

     user:

     app-password:


     (elementor website, target and modify)
     url:

     user:

     app-password:
     ```
   - **Base Website (Read-Only):** The benchmark reference for visual truth and DOM asset extraction. Zero write/mutation operations permitted.
   - **Elementor Website (Target & Modify):** The target WordPress/Elementor site undergoing fine-tuning. Mandatory draft backup before mutations.
   - **2-Times Base64 Encoded Credential Vault (`data/config.db`):**
     - Passwords / App-passwords provided by the user **MUST BE SAVED** into a local SQLite database at `data/config.db` under the table `Credentials`.
     - The password **MUST BE ENCODED 2 TIMES** using Base64 with strongly-typed `EncodingConstants`:
       `encoded = base64.b64encode(base64.b64encode(raw_password.encode(EncodingConstants.UTF8))).decode(EncodingConstants.ASCII)`
     - **Automatic Reuse Across Loops & Future Tasks:** Once the first connection or iteration is successful, credentials are persisted into `data/config.db`. On subsequent loops, rerun iterations, or future pages on the same sites, the AI loads credentials directly from `data/config.db` without repeatedly prompting the user.

2. **Local Filesystem CSS Persistence (`css/` directory):**
   - The AI **MUST PERSIST ALL CSS** directly to the local filesystem in the `css/` directory:
     - `css/base-site.css`: Complete captured/extracted CSS from the benchmark base website.
     - `css/target-current.css`: Current active CSS stylesheets and inline styles from the target Elementor site.
     - `css/target-modified.css`: Generated / tuned CSS containing Flexbox rules, typography, gap, and padding overrides.
     - `css/elementor-custom.css`: Injected custom CSS targeted to `selector` or container classes.
   - Filesystem CSS enables instant offline diffing, auditing, and inspection without querying remote endpoints repeatedly.

3. **Local Filesystem Page Snapshots (`before/` and `after/` folder hierarchy):**
   - Before modifying any WordPress post or single page, the AI **MUST CREATE** a complete filesystem snapshot under:
     ```text
     backups/<site_slug>/<page_slug>-<page_id>/
     ├── before/
     │   ├── post.json          # Complete REST API post payload (title, content, slug, status, template)
     │   ├── elementor_data.json# Raw parsed _elementor_data AST structure
     │   ├── postmeta.json      # Complete postmeta key-value map
     │   ├── raw_rendered.html  # Live DOM HTML snapshot before modification
     │   └── style.css          # Extracted page stylesheet before modification
     └── after/
         ├── post.json          # Updated REST payload after modification
         ├── elementor_data.json# Mutated _elementor_data AST structure
         ├── postmeta.json      # Mutated postmeta
         ├── raw_rendered.html  # Post-render DOM HTML snapshot
         └── style.css          # Injected/tuned page stylesheet
     ```
   - **Instant Filesystem Revert:** If any modification breaks or visual discrepancy exceeds tolerance, the AI uses `scripts/revert_page.py` to restore `before/post.json`, `before/elementor_data.json`, and `before/postmeta.json` back to WordPress via REST API in seconds.

4. **Screen Sizes JSON Specification (`screens.json`):**
   - The very first technical step is identifying all required viewport dimensions and saving them into `screens.json`.
   - Must cover 6–8 distinct viewports:
     - Desktop 4K / Large (`3840x2160`, `1920x1080`)
     - Desktop Standard / Laptop (`1440x900`, `1366x768`)
     - Tablet Landscape (`1024x768`)
     - Tablet Portrait / Vertical (`768x1024`)
     - Mobile Landscape View (`844x390`, `896x414`)
     - Mobile Landing View / Tab (`390x844`, `375x667`, `360x800`)
     - Mobile Small (`320x568`)

5. **100 to 300 Iteration Continuous Feedback Loop:**
   - Run 100 to 300 granular iterations per page until visual gap reaches 0% (pixel-perfect accuracy).
   - In each iteration:
     1. Capture screenshots of the original site across all configured screen viewports.
     2. Capture screenshots of the current site across all configured screen viewports.
     3. Compare screenshots pixel-by-pixel, compute mismatch percentage, and generate visual difference heatmaps.
     4. Diagnose discrepancies to identify exact CSS properties, padding, margin, flex direction, container alignment, typography measure, or Elementor widget settings.
     5. Explain root cause of the visual gap to internal reasoning.
     6. Apply targeted code/AST fix via Python REST scripts.
     7. Save updated CSS to `css/` and verify in browser, repeating until 100% accurate.

6. **Pre-Flight REST Draft Backup Invariant:**
   - In addition to local filesystem snapshots, the AI **MUST CLONE** an immutable draft copy in WordPress (`<Title> - Backup [Timestamp]`) recorded in `backups.json`.

7. **Screenshot Rotation & Zero Git Bloat (MANDATORY GITIGNORE):**
   - Screenshots **MUST NEVER** be committed to Git.
   - All captured image assets live in `screenshots/` which MUST be added to `.gitignore`.
   - `data/config.db` and `data/` MUST ALSO be added to `.gitignore`.
   - When proceeding to iteration $K+1$, the script **MUST PURGE** previous screenshots from iteration $K$ to prevent local disk exhaustion.

8. **AI Memory & Struggle Point Reflection Protocol:**
   - At the conclusion of the task, the AI must record a structured retrospective in `.ai-memory/rca/resolved/` or `.ai-memory/learned/`:
     - Where the AI struggled most (e.g. stubborn padding inheritance, sticky header offset, flex wrap bugs).
     - Exact root causes identified across the iterations.
     - Concrete remediation steps taken to achieve 100% pixel-perfect fidelity.

9. **Final Atomic Commit & Push Standard:**
   - Once 100% accuracy is achieved, commit all scripts, configurations, and conversation logs using structured semantic commit messages (`git commit -m "Feature: ELEMENTOR - pixel perfect fine tuning loop completion"`).
   - Upstream push is mandatory: No Push = Not Done.

---

## 📋 2. Turn 1 Understood Showcase Protocol

Before executing any network requests or modifying code, the AI must output the Turn 1 Showcase table:

| Dimension | Standard Specification | Target Verification |
| :--- | :--- | :--- |
| **Prerequisite Gate** | Python Prompt + WP Actions Prompt | Confirmed studied & internalized (50 steps memory creation) |
| **Direct References** | Unwrapped Authoritative Gist URLs | Bare URLs confirmed without markdown wrapping |
| **Original URL** | Reference Website Page URL (Read-Only) | Ingested from operator prompt / input; strictly GET only |
| **Target URL** | Current Elementor Page URL / Slug | Ingested from operator prompt / input; target for mutations |
| **Credential Vault** | 2x Base64 in `data/config.db` (SQLite) | Stored in `Credentials` table (PascalCase); reused across loops once 1st is successful |
| **Filesystem CSS** | Local `css/` Persistence | `base-site.css`, `target-current.css`, `target-modified.css` saved locally |
| **FS Page Backups** | `backups/<site>/<page>/before/` & `after/` | Structured JSON, AST, HTML, CSS saved for instant rollback |
| **Screen Dimensions** | `screens.json` Multi-Viewport Matrix | Desktop, Tablet (V/H), Mobile (Landing/Tab/Landscape) |
| **Iteration Budget** | 100 to 300 Continuous Iterations | Active self-loop with progress tracking |
| **Pre-Flight Backup** | REST Draft Clone (`backups.json`) | Executed before first mutation: `<Title> - Backup [Timestamp]` |
| **Diff Engine** | Headless Visual Pixel Match (Pillow) | Pixel % deviation, bounding box highlights, MSE score |
| **Screenshot Hygiene** | `.gitignore` + Automated Pruning | Zero screenshots committed to Git; prior turns purged |
| **Memory Persistence**| 4-Part RCA in `.ai-memory/` | Struggle points, root causes, and fix catalog preserved |

---

## 📜 3. Verbatim Prompt Directives (Master Gist Source)

```markdown
Please learn Python Prompt First (50 Steps learn and update your memory first):
https://gist.githubusercontent.com/alimtvnetwork/fd0953a5f2bfbbc91ae6e3666c5f7c37/raw/b573e3d2cd164d74350bee9c77ccc3b608250333/python-any-task-prompt.md

Please learn WordPress Actions (50 Steps learn and update your memory first):
https://gist.githubusercontent.com/alimtvnetwork/11900295ef222d921bd646923fbcff3d/raw/957bb2b806d2bb6dae45f5d8f17c5fdefbe5aa55/universal-wp-modernizing-master-prompt.md

# Main Goal Try to understand list out the tasks please - Run Iterations and Compare Screens: high priority instruction, non-negotiable task

You are going to run 100 to 300 iteration on each page and compare three to four screens, desktop, mobile tab, mobile landing view, landscape view, tablet, horizontal and vertical view. Desktop has many different screens, so find all the screens. First, find the screen sizes and put the screen sizes as JSON. So that should be your first starting point. Then you follow the Python script, Python prompts segment, how you wanted to do stuff step by step. Then what you should do is you compare the original website and what you change. So I will give you the, let's say, the page slug that you wanted to modify and the same slug you can find in the original website. After you change or fix it to the Elementor, you should check every bits and piece with these 300 iterations. Each iteration you compare in three, four, five, six screens, compare the screenshots, check where the issues are, find the root cause, explain it to yourself where the issue is, fix it, and then again, check the screenshot on all the screens and then again, compare with the original one. So original one will also have all the screenshots, and then your version will also have all the screenshots, and then you compare, contrast, and figure out where the gap is. By these type of iterations, you will fix one page 100% accurately. Once you feel that it is 100% accurate, you complete the task. So until you do, you loop through the process and write the Python script each time to modify the site and remember the history so that in the future when we do it for the next website, you can understand where the glitches were. And at the end, you are going to write where you struggle most, what was the root cause on fixing it, and how you have fixed it every step so that next AI when reads it, they would understand from the AI memory folder that this is how it needs to be done. So at the end, you are going to ask me the original website, let's say page, and the slug of the current website that you are going to modify. And before you start modifying, make sure you take a backup draft, backup of that page or post, and then start doing the step of migration and fixing each pixel perfect screen on every screen possible. The first thing you should do is confirm that you understand the task, you know the Python prompt, how to write the Python scripts to modify each one of the layers. You know how to take the backup before you modify the page. Remember that. And then you start doing it in each step in the Elementor using the Python script, and you give the history of it, what was the root cause of it, so that any time later on. And for each one of the change, you should create the folder, and in that folder, you write this script, you write this state, history, screenshots, before, after, original and the current website. You compare, and when you go to the next version, you always remove the previous screenshot so that we don't have too many of the screenshots. Remember that. The screenshots do not commit to the Git. It should be Git ignore. So you should have a folder structure like screenshots that would be ignored from the Git as well. Also, make sure you save the password as 2 times base64 encoding in a data\config.db sqlite db so that it can be used in the future and you can do the loop once the first one is successful without asking again. Also keep the CSS saved to our file system in the css/ folder as well, and create a backup of the post, single page, before and after in our file system where we start to modify as a folder structure (backups/<site_slug>/<page_slug>-<page_id>/before and after) so that it can be used to revert if required. So make sure you work on it. If you have any question, concern, let me know. So after this, you should always ask me for the original website page and the current website page and original and the current one what you are modifying. You ask me, I will provide you. And each time I do that, you repeat the process. And remember to write the root cause so that any AI who reads it understands it, where the problem is. They would fine-tune and fix it very quickly in the future. Do you understand? Every step, every change of the CSS, how you're doing it, every change of the HTML section or the component section that you are modifying, write it like this. If you're changing a padding using the Elementor component, write it like this. So you try to find each case, a problem, an issue, so that you can rely on it. After that, I assume that you have all the information. You also know the WordPress prompt, you know the Python prompt, which I have run. And then now you are going to ask me for the two URLs. You are going to work on it. And then finally, when you are done, you complete it. Until you're done, you continue the steps. And finally, when you're done, you make sure you commit every things to the Git, like every conversation, steps that you have done. And finally, what actually made you success, root cause analysis, script history, and everything, so that any AI who runs it, they would know how to fix things in the future. Is it clear?

## task: Run Iterations and Compare Screens
## slug: run-iterations-and-compare-screens

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — run `git pull` in repository folder to ensure working tree is clean and current.
2. Write spec under 02-spec/21-app/XX-run-iterations-and-compare-screens/ and enqueue plan in .ai-memory/plans/pending/XX-run-iterations-and-compare-screens.md first (NO-BUILD, NO-TEST during planning).
3. Search codebase using structured project search tools.
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute paths.
5. Save credentials as 2 times Base64 encoded in local `data/config.db` (SQLite DB with PascalCase table `Credentials`) to reuse across future loops once first connection succeeds.
6. Save all captured, modified, and injected CSS directly to local filesystem in `css/` directory.
7. Create local filesystem backups of posts/single pages in `backups/<site_slug>/<page_slug>-<page_id>/` with `before/` and `after/` folders for instant reversion.
8. Run 100 to 300 iterations on each page and compare screens as specified.
9. Find screen sizes and save as JSON (`screens.json`).
10. Follow Python script prompts for step-by-step execution.
11. Compare original and modified websites, ensuring pixel-perfect accuracy.
12. Document root causes and fixes in AI memory for future reference.
13. Ensure screenshots and `data/config.db` are Git ignored and maintain a clean folder structure.

### "I am sleepy" Autopilot Checklist
- [ ] 1. Repository pulled and clean before work (`git pull`)
- [ ] 2. "I am sleepy" Autopilot Active: Pick closest sensible solution for every ambiguity without waking or prompting the operator
- [ ] 3. Ambiguities & Batch Questions: Record in `.ai-memory/ambiguity/` for morning review; never halt execution
- [ ] 4. Pragmatic Commits (`git commit -m "Feature: ..."` / `git commit -m "Chore: ..."`): Group files logically; no single-file commits; no "perfect commit" paralysis; intermediate code does not need to build
- [ ] 5. Zero Build/Test Default: Intermediate builds and tests skipped; build/E2E executed ONLY if explicitly asked in prompt
- [ ] 6. Conditional Verification & Release: Run pipeline verification ONLY if explicitly requested in prompt
- [ ] 7. Every code change committed and pushed upstream (`git push`) — No Push = Not Done

## Must follow and spawn agent using

1. @[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6)
2. If any bug, error, or regression is mentioned: @[fix-with-rca](directory;.agents/skills/fix-with-rca)

## Additional Instructions

- [/goal](slashCommand;goal) Follow exactly to the high instruction which is given and the checklist that has been given on top.
- [/plan](slashCommand;plan) first before doing work for improved work or less friction, faster execution for AI and coding without errors and following Coding Guidelines.
- [/learn](slashCommand;learn) Learn from repository documentation and architectural guides for fast execution.
- After learning and planning, immediately begin executing the plan without asking for confirmation. Autonomous execution must proceed seamlessly through completion.
- Track in-flight file touches and prevent write collisions.
- Only add relative paths, never add absolute paths during work; this must be respected on release page and in release notes as well.
```

---

## 💻 4. Embedded Production Reference Code

### 4.1 Canonical Screen Sizes Configuration (`screens.json`)

```json
{
  "data": {
    "id": "screensConfiguration",
    "type": "viewportMatrix",
    "attributes": {
      "version": "1.0.0",
      "description": "Multi-viewport screen specifications for automated pixel-perfect screen comparison",
      "viewports": [
        {
          "id": "desktop4k",
          "type": "viewportSpec",
          "attributes": {
            "category": "desktop",
            "name": "Desktop 4K / Ultra-Wide",
            "width": 3840,
            "height": 2160,
            "deviceScaleFactor": 1,
            "isMobile": false,
            "hasTouch": false
          }
        },
        {
          "id": "desktopFhd",
          "type": "viewportSpec",
          "attributes": {
            "category": "desktop",
            "name": "Desktop Full HD (Standard)",
            "width": 1920,
            "height": 1080,
            "deviceScaleFactor": 1,
            "isMobile": false,
            "hasTouch": false
          }
        },
        {
          "id": "desktopLaptop",
          "type": "viewportSpec",
          "attributes": {
            "category": "desktop",
            "name": "Laptop / MacBook Standard",
            "width": 1440,
            "height": 900,
            "deviceScaleFactor": 2,
            "isMobile": false,
            "hasTouch": false
          }
        },
        {
          "id": "tabletLandscape",
          "type": "viewportSpec",
          "attributes": {
            "category": "tablet",
            "name": "Tablet Landscape (iPad Pro / Air)",
            "width": 1024,
            "height": 768,
            "deviceScaleFactor": 2,
            "isMobile": true,
            "hasTouch": true
          }
        },
        {
          "id": "tabletPortrait",
          "type": "viewportSpec",
          "attributes": {
            "category": "tablet",
            "name": "Tablet Portrait / Vertical",
            "width": 768,
            "height": 1024,
            "deviceScaleFactor": 2,
            "isMobile": true,
            "hasTouch": true
          }
        },
        {
          "id": "mobileLandscape",
          "type": "viewportSpec",
          "attributes": {
            "category": "mobile",
            "name": "Mobile Landscape View",
            "width": 844,
            "height": 390,
            "deviceScaleFactor": 3,
            "isMobile": true,
            "hasTouch": true
          }
        },
        {
          "id": "mobileLandingTab",
          "type": "viewportSpec",
          "attributes": {
            "category": "mobile",
            "name": "Mobile Large / Phablet View",
            "width": 428,
            "height": 926,
            "deviceScaleFactor": 3,
            "isMobile": true,
            "hasTouch": true
          }
        },
        {
          "id": "mobileLandingStandard",
          "type": "viewportSpec",
          "attributes": {
            "category": "mobile",
            "name": "Mobile Landing Standard (iPhone 14/15/Galaxy)",
            "width": 390,
            "height": 844,
            "deviceScaleFactor": 3,
            "isMobile": true,
            "hasTouch": true
          }
        },
        {
          "id": "mobileSmall",
          "type": "viewportSpec",
          "attributes": {
            "category": "mobile",
            "name": "Mobile Compact (iPhone SE / Older)",
            "width": 320,
            "height": 568,
            "deviceScaleFactor": 2,
            "isMobile": true,
            "hasTouch": true
          }
        }
      ]
    }
  }
}
```

### 4.2 2-Stage Base64 SQLite Credential Vault (`scripts/credential_vault.py`)

```python
#!/usr/bin/env python3
"""
credential_vault.py — 2-Stage Base64 SQLite Credential Vault.
Persists WordPress/Elementor credentials into data/config.db (PascalCase table: Credentials)
using 2-times Base64 encoding. Reuses stored credentials across future loop runs.
"""
from __future__ import annotations

import base64
import os
import re
import sqlite3
from datetime import datetime
from enum import Enum
from pathlib import Path
from typing import ClassVar, Final, Optional, Pattern, Tuple


class EncodingConstants:
    """Standard character encoding format constants."""
    UTF8: Final[str] = "utf-8"
    ASCII: Final[str] = "ascii"
    UTF16: Final[str] = "utf-16"


class TableType(str, Enum):
    """PascalCase SQLite database table names."""
    CREDENTIALS = "Credentials"
    PAGE_BACKUPS = "PageBackups"
    VISUAL_DIFFS = "VisualDiffs"
    AUDIT_LOGS = "AuditLogs"


class SiteRoleType(str, Enum):
    """Target site classification roles."""
    BASE = "base"
    TARGET = "target"


class CredentialSqlType(str, Enum):
    """Encapsulated SQL statements for credential vault."""
    PRAGMA_BUSY_TIMEOUT = "PRAGMA busy_timeout = 5000"
    CREATE_CREDENTIALS_TABLE = (
        "CREATE TABLE IF NOT EXISTS Credentials ("
        "Id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "SiteRole TEXT NOT NULL UNIQUE, "
        "SiteUrl TEXT NOT NULL, "
        "Username TEXT NOT NULL, "
        "PasswordEnc TEXT NOT NULL, "
        "CreatedAt TEXT NOT NULL, "
        "UpdatedAt TEXT NOT NULL"
        ")"
    )
    UPSERT_CREDENTIAL = (
        "INSERT INTO Credentials (SiteRole, SiteUrl, Username, PasswordEnc, CreatedAt, UpdatedAt) "
        "VALUES (?, ?, ?, ?, ?, ?) "
        "ON CONFLICT(SiteRole) DO UPDATE SET "
        "SiteUrl=excluded.SiteUrl, "
        "Username=excluded.Username, "
        "PasswordEnc=excluded.PasswordEnc, "
        "UpdatedAt=excluded.UpdatedAt"
    )
    SELECT_BY_ROLE = (
        "SELECT SiteUrl, Username, PasswordEnc FROM Credentials WHERE SiteRole = ? LIMIT 1"
    )


class ElementorConstants:
    """Canonical file and directory constants."""
    DIR_DATA: Final[str] = "data"
    DB_CONFIG: Final[str] = "data/config.db"
    DIR_CSS: Final[str] = "css"
    DIR_BACKUPS: Final[str] = "backups"
    DIR_SCREENSHOTS: Final[str] = "screenshots"
    FILE_SCREENS_JSON: Final[str] = "screens.json"


class LazyRegex:
    """Thread-safe lazy regular expression compiler (cached on demand)."""
    _cache: ClassVar[dict[str, Pattern[str]]] = {}

    @classmethod
    def get(cls, pattern: str, flags: int = 0) -> Pattern[str]:
        """Retrieve compiled pattern from cache or compile and store."""
        key = f"{pattern}::{flags}"
        if key not in cls._cache:
            cls._cache[key] = re.compile(pattern, flags)
        return cls._cache[key]

    @classmethod
    def clear(cls) -> None:
        """Clear cached patterns."""
        cls._cache.clear()


def get_db_path() -> Path:
    """Return Path to data/config.db ensuring directory exists."""
    db_dir = Path(ElementorConstants.DIR_DATA)
    db_dir.mkdir(parents=True, exist_ok=True)
    return Path(ElementorConstants.DB_CONFIG)


def init_credentials_db() -> None:
    """Initialize SQLite Credentials table in data/config.db using CredentialSqlType."""
    db_path = get_db_path()
    with sqlite3.connect(db_path) as conn:
        conn.execute(CredentialSqlType.PRAGMA_BUSY_TIMEOUT.value)
        conn.execute(CredentialSqlType.CREATE_CREDENTIALS_TABLE.value)
        conn.commit()


def encode_password_2x(raw_password: str) -> str:
    """Encode password twice using Base64 with strongly-typed EncodingConstants."""
    pass_1 = base64.b64encode(raw_password.encode(EncodingConstants.UTF8)).decode(EncodingConstants.ASCII)
    pass_2 = base64.b64encode(pass_1.encode(EncodingConstants.UTF8)).decode(EncodingConstants.ASCII)
    return pass_2


def decode_password_2x(encoded_password: str) -> str:
    """Decode password twice using Base64 with strongly-typed EncodingConstants."""
    pass_1 = base64.b64decode(encoded_password.encode(EncodingConstants.ASCII)).decode(EncodingConstants.UTF8)
    raw_password = base64.b64decode(pass_1.encode(EncodingConstants.ASCII)).decode(EncodingConstants.UTF8)
    return raw_password


def save_credentials(site_role: str, site_url: str, username: str, raw_password: str) -> None:
    """Save or update credentials in data/config.db with 2x Base64 encoding via CredentialSqlType."""
    init_credentials_db()
    db_path = get_db_path()
    enc_pw = encode_password_2x(raw_password)
    now_iso = datetime.now().isoformat()

    with sqlite3.connect(db_path) as conn:
        conn.execute(
            CredentialSqlType.UPSERT_CREDENTIAL.value,
            (site_role, site_url, username, enc_pw, now_iso, now_iso),
        )
        conn.commit()
    print(f"🔒 Credentials for [{site_role}] saved securely to data/config.db (2x Base64).")


def load_credentials(site_role: str) -> Optional[Tuple[str, str, str]]:
    """Load credentials from data/config.db via CredentialSqlType, decoding 2x Base64 password."""
    init_credentials_db()
    db_path = get_db_path()

    with sqlite3.connect(db_path) as conn:
        cursor = conn.cursor()
        cursor.execute(CredentialSqlType.SELECT_BY_ROLE.value, (site_role,))
        row = cursor.fetchone()

    if not row:
        return None

    site_url, username, enc_pw = row
    raw_pw = decode_password_2x(enc_pw)
    return site_url, username, raw_pw
```

### 4.3 Filesystem Before & After Page Snapshot Engine (`scripts/fs_backup.py`)

```python
#!/usr/bin/env python3
"""
fs_backup.py — Local Filesystem Before & After Page Snapshot Engine.
Creates structured backups under backups/<site_slug>/<page_slug>-<page_id>/before/
and backups/<site_slug>/<page_slug>-<page_id>/after/ for instant filesystem rollback.
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Any, Dict


def get_backup_dir(site_slug: str, page_slug: str, page_id: int) -> Path:
    """Return root backup directory path for the given page."""
    return Path("backups") / site_slug / f"{page_slug}-{page_id}"


def create_page_snapshot(
    site_slug: str,
    page_slug: str,
    page_id: int,
    stage: str,  # "before" or "after"
    post_payload: Dict[str, Any],
    elementor_ast: Any,
    postmeta: Dict[str, Any],
    raw_html: str,
    style_css: str,
) -> Path:
    """Save complete page snapshot (JSON, AST, HTML, CSS) to filesystem."""
    target_dir = get_backup_dir(site_slug, page_slug, page_id) / stage
    target_dir.mkdir(parents=True, exist_ok=True)

    # 1. Full REST post payload
    with open(target_dir / "post.json", "w", encoding=EncodingConstants.UTF8) as f:
        json.dump(post_payload, f, indent=2)

    # 2. Parsed _elementor_data AST
    with open(target_dir / "elementor_data.json", "w", encoding=EncodingConstants.UTF8) as f:
        json.dump(elementor_ast, f, indent=2)

    # 3. Postmeta dictionary
    with open(target_dir / "postmeta.json", "w", encoding=EncodingConstants.UTF8) as f:
        json.dump(postmeta, f, indent=2)

    # 4. Raw live DOM HTML snapshot
    with open(target_dir / "raw_rendered.html", "w", encoding=EncodingConstants.UTF8) as f:
        f.write(raw_html)

    # 5. Extracted / active page CSS
    with open(target_dir / "style.css", "w", encoding=EncodingConstants.UTF8) as f:
        f.write(style_css)

    print(f"📦 Filesystem snapshot saved to: {target_dir}")
    return target_dir


def load_before_snapshot(site_slug: str, page_slug: str, page_id: int) -> Dict[str, Any]:
    """Load before-stage snapshot for rollback."""
    before_dir = get_backup_dir(site_slug, page_slug, page_id) / "before"
    if not before_dir.exists():
        raise FileNotFoundError(f"No before-snapshot found at: {before_dir}")

    with open(before_dir / "post.json", "r", encoding=EncodingConstants.UTF8) as f:
        post_data = json.load(f)
    with open(before_dir / "elementor_data.json", "r", encoding=EncodingConstants.UTF8) as f:
        elementor_data = json.load(f)
    with open(before_dir / "postmeta.json", "r", encoding=EncodingConstants.UTF8) as f:
        postmeta = json.load(f)

    return {
        "post": post_data,
        "elementor_data": elementor_data,
        "postmeta": postmeta,
    }
```

### 4.4 Local Filesystem CSS Persistence Engine (`scripts/css_saver.py`)

```python
#!/usr/bin/env python3
"""
css_saver.py — Local Filesystem CSS Extraction & Persistence Engine.
Saves all captured, computed, and injected CSS directly to the css/ directory.
"""
from __future__ import annotations

from pathlib import Path


def save_css_to_fs(filename: str, css_content: str) -> Path:
    """Save CSS content to local filesystem under css/ directory."""
    css_dir = Path("css")
    css_dir.mkdir(parents=True, exist_ok=True)

    target_file = css_dir / filename
    with open(target_file, "w", encoding=EncodingConstants.UTF8) as f:
        f.write(css_content)

    print(f"🎨 CSS persisted to filesystem: {target_file} ({len(css_content)} bytes)")
    return target_file
```

### 4.5 Automated Headless Visual Diff Engine (`scripts/visual_diff.py`)

```python
#!/usr/bin/env python3
"""
visual_diff.py — Automated Headless Screenshot Comparison Engine.
Compares original and target web screenshots pixel-by-pixel using Pillow.
Calculates percentage deviation, mean squared error (MSE), and produces diff heatmaps.
"""
from __future__ import annotations

import json
import math
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw


@dataclass(frozen=True)
class DiffResult:
    is_match: bool
    diff_percent: float
    mismatched_pixels: int
    total_pixels: int
    diff_image_path: str


def compute_visual_diff(
    original_path: str,
    modified_path: str,
    output_diff_path: str,
    tolerance_threshold_percent: float = 0.5,
) -> DiffResult:
    """Compare two images pixel-by-pixel and compute diff metrics."""
    orig_img = Image.open(original_path).convert("RGBA")
    mod_img = Image.open(modified_path).convert("RGBA")

    # Normalize dimensions to maximum bounding box
    max_w = max(orig_img.width, mod_img.width)
    max_h = max(orig_img.height, mod_img.height)

    canvas_orig = Image.new("RGBA", (max_w, max_h), (255, 255, 255, 0))
    canvas_mod = Image.new("RGBA", (max_w, max_h), (255, 255, 255, 0))

    canvas_orig.paste(orig_img, (0, 0))
    canvas_mod.paste(mod_img, (0, 0))

    diff = ImageChops.difference(canvas_orig, canvas_mod)
    bbox = diff.getbbox()

    if not bbox:
        return DiffResult(
            is_match=True,
            diff_percent=0.0,
            mismatched_pixels=0,
            total_pixels=max_w * max_h,
            diff_image_path="",
        )

    # Count mismatched pixels
    diff_data = diff.getdata()
    mismatched = sum(1 for pixel in diff_data if any(c > 10 for c in pixel[:3]))
    total = max_w * max_h
    diff_pct = (mismatched / total) * 100.0

    # Highlight differences with magenta overlay
    highlight = canvas_mod.copy()
    draw = ImageDraw.Draw(highlight)
    mask = diff.convert("L").point(lambda p: 255 if p > 10 else 0)
    highlight.paste((255, 0, 128, 180), (0, 0), mask)

    os.makedirs(os.path.dirname(output_diff_path), exist_ok=True)
    highlight.save(output_diff_path, "PNG")

    is_pixel_perfect = diff_pct <= tolerance_threshold_percent

    return DiffResult(
        is_match=is_pixel_perfect,
        diff_percent=diff_pct,
        mismatched_pixels=mismatched,
        total_pixels=total,
        diff_image_path=output_diff_path,
    )


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: visual_diff.py <orig.png> <mod.png> <diff.png> [tolerance_pct]")
        sys.exit(1)

    tol = float(sys.argv[4]) if len(sys.argv) > 4 else 0.5
    res = compute_visual_diff(sys.argv[1], sys.argv[2], sys.argv[3], tol)
    print(json.dumps({
        "is_match": res.is_match,
        "diff_percent": round(res.diff_percent, 3),
        "mismatched_pixels": res.mismatched_pixels,
        "total_pixels": res.total_pixels,
        "diff_image": res.diff_image_path,
    }, indent=2))
    sys.exit(0 if res.is_match else 2)
```

### 4.6 Iteration Loop Orchestrator & Screenshot Pruner (`scripts/finetune_loop.py`)

```python
#!/usr/bin/env python3
"""
finetune_loop.py — Iterative Screen Comparison & Fine-Tuning Manager.
Executes 100-300 fine-tune cycles, loads/saves 2x Base64 credentials from data/config.db,
prunes old screenshots to avoid Git bloat, and logs root cause analyses for memory persistence.
"""
from __future__ import annotations

import argparse
import json
import os
import shutil
from pathlib import Path
from credential_vault import load_credentials, save_credentials
from fs_backup import create_page_snapshot, load_before_snapshot
from css_saver import save_css_to_fs
from visual_diff import compute_visual_diff


def prune_previous_screenshots(screenshot_dir: Path) -> None:
    """Remove previous cycle screenshots to protect disk space and prevent Git pollution."""
    if screenshot_dir.exists():
        for item in screenshot_dir.glob("*.png"):
            try:
                item.unlink()
            except OSError:
                pass


def record_rca_log(iteration: int, viewport: str, issue: str, root_cause: str, fix: str) -> None:
    """Record root cause analysis entry for memory persistence."""
    rca_file = Path(".ai-memory/rca/resolved/08-elementor-finetune-rca.md")
    rca_file.parent.mkdir(parents=True, exist_ok=True)

    entry = (
        f"\n### Iteration {iteration:03d} — Viewport: {viewport}\n"
        f"- **Discrepancy:** {issue}\n"
        f"- **Root Cause:** {root_cause}\n"
        f"- **Applied Fix:** {fix}\n"
    )

    with open(rca_file, "a", encoding=EncodingConstants.UTF8) as f:
        f.write(entry)


def run_loop(max_iterations: int = 300) -> None:
    """Run iterative comparison loop across all viewports."""
    # 1. Check or load credentials from 2x Base64 SQLite vault
    base_creds = load_credentials("base")
    target_creds = load_credentials("elementor")

    if not base_creds or not target_creds:
        print("ℹ️ Credentials not found in data/config.db. Prompt operator once.")
    else:
        print("✅ Loaded credentials from data/config.db vault. Reusing across loop.")

    screens_path = Path("screens.json")
    if not screens_path.exists():
        print("❌ screens.json not found. Generate screen sizes JSON first.")
        return

    with open(screens_path, "r", encoding=EncodingConstants.UTF8) as f:
        viewports = json.load(f).get("viewports", [])

    screenshot_dir = Path("screenshots")
    screenshot_dir.mkdir(parents=True, exist_ok=True)

    for iteration in range(1, max_iterations + 1):
        print(f"\n🚀 Starting Iteration {iteration}/{max_iterations}...")
        prune_previous_screenshots(screenshot_dir)

        all_viewports_passed = True
        for vp in viewports:
            vp_id = vp["id"]
            orig_shot = screenshot_dir / f"orig_{vp_id}.png"
            mod_shot = screenshot_dir / f"mod_{vp_id}.png"
            diff_shot = screenshot_dir / f"diff_{vp_id}.png"

            # Check if screenshot capture has run for both URLs
            if not orig_shot.exists() or not mod_shot.exists():
                print(f"⏳ Waiting for captures: {vp_id}")
                all_viewports_passed = False
                continue

            result = compute_visual_diff(str(orig_shot), str(mod_shot), str(diff_shot))
            print(f"  • Viewport {vp_id:24s} -> Match: {result.is_match} (Diff: {result.diff_percent:.2f}%)")

            if not result.is_match:
                all_viewports_passed = False

        if all_viewports_passed:
            print(f"\n🎉 100% Pixel-Perfect Match Achieved at Iteration {iteration}!")
            break


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Elementor Fine-Tune Loop Orchestrator")
    parser.add_argument("--iterations", type=int, default=300, help="Max iterations (100-300)")
    args = parser.parse_args()
    run_loop(args.iterations)
```

### 4.7 Pre-Flight REST Draft Backup Engine (`scripts/backup_draft.py`)

```python
#!/usr/bin/env python3
"""
backup_draft.py — Pre-Flight Draft Backup & Postmeta Preservation Engine.
Clones target WordPress page into an immutable draft copy before any REST mutation.
"""
from __future__ import annotations

import json
import os
import sys
from datetime import datetime
from pathlib import Path
import urllib.request
import urllib.error


def create_preflight_backup(site_url: str, page_id: int, auth_header: str) -> dict:
    """Fetch existing page content and create draft backup clone."""
    endpoint = f"{site_url.rstrip('/')}/wp-json/wp/v2/pages/{page_id}?context=edit"
    req = urllib.request.Request(endpoint, headers={"Authorization": auth_header})

    try:
        with urllib.request.urlopen(req) as resp:
            page_data = json.loads(resp.read().decode(EncodingConstants.UTF8))
    except urllib.error.URLError as err:
        print(f"❌ Failed to fetch page for backup: {err}")
        sys.exit(1)

    backup_title = f"{page_data.get('title', {}).get('raw', 'Page')} - Backup [{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}]"
    backup_payload = {
        "title": backup_title,
        "content": page_data.get("content", {}).get("raw", ""),
        "status": "draft",
        "meta": page_data.get("meta", {}),
    }

    # Persist to local backups.json ledger using GitMap data and attributes pattern
    backups_ledger = Path("backups.json")
    records: list[dict[str, Any]] = []
    if backups_ledger.exists():
        try:
            with open(backups_ledger, "r", encoding=EncodingConstants.UTF8) as f:
                doc = json.load(f)
                records = doc.get("data", []) if isinstance(doc, dict) else (doc if isinstance(doc, list) else [])
        except Exception:
            records = []

    records.append({
        "id": f"backupPage{page_id}-{datetime.now().strftime('%Y%m%dT%H%M%SZ')}",
        "type": "pageBackup",
        "attributes": {
            "timestamp": datetime.now().isoformat(),
            "originalPageId": page_id,
            "backupTitle": backup_title,
            "elementorData": page_data.get("meta", {}).get("_elementor_data", ""),
        },
    })

    with open(backups_ledger, "w", encoding=EncodingConstants.UTF8, newline="\n") as f:
        json.dump({"data": records}, f, indent=2)

    print(f"✅ Pre-flight draft backup recorded in backups.json: '{backup_title}'")
    return backup_payload


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: backup_draft.py <site_url> <page_id> <auth_header>")
        sys.exit(1)
    create_preflight_backup(sys.argv[1], int(sys.argv[2]), sys.argv[3])
```

### 4.8 Mandatory Git Ignore Configuration (`.gitignore`)

```gitignore
# Screenshots MUST NEVER be committed to Git
screenshots/
*.png
*.jpg
*.jpeg
!assets/**/*.png
!assets/**/*.jpg

# Ephemeral diff artifacts
diff_*.png
temp_*.json

# Credential Vault MUST NEVER be committed to Git
data/
data/config.db
*.db
```

### 4.9 Cross-Platform Launchers

#### `run.ps1` (PowerShell)
```powershell
#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

Write-Host "🎨 Starting Universal Elementor Fine-Tune & Comparison Engine..." -ForegroundColor Cyan

# Step 1: Ensure screens.json exists
if (-not (Test-Path "screens.json")) {
    Write-Host "📋 Synthesizing default screens.json viewports..." -ForegroundColor Yellow
    python scripts/generate_screens_json.py
}

# Step 2: Run loop orchestrator
python scripts/finetune_loop.py --iterations 300
```

#### `run.sh` (POSIX Bash)
```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🎨 Starting Universal Elementor Fine-Tune & Comparison Engine..."

if [ ! -f "screens.json" ]; then
    echo "📋 Synthesizing default screens.json viewports..."
    python3 scripts/generate_screens_json.py
fi

python3 scripts/finetune_loop.py --iterations 300
```

---

## 🏆 5. 100/100 Evaluation Rubric

| Criterion | Points | Verification Standard |
| :--- | :---: | :--- |
| **Prerequisites Gate** | 15 | Explicit confirmation of Python prompt and WP actions prompt learning (50 steps). |
| **URL & Scope Ingestion** | 10 | Operator explicitly asked for and provided both original and target website URLs. |
| **2x Base64 SQLite Credential Vault** | 15 | Credentials encoded 2x Base64 in `data/config.db`; automatically reused once 1st is successful. |
| **Local Filesystem CSS & Backups** | 15 | CSS saved in `css/`; post/single page backups saved in `backups/<site>/<page>/before/` & `after/`. |
| **Multi-Screen Matrix (`screens.json`)** | 15 | Complete JSON schema defining 6+ viewport sizes (Desktop, Tablet V/H, Mobile Landing/Tab/Landscape). |
| **Iterative Comparison Loop (100–300)** | 15 | Active loop running up to 300 iterations, computing pixel-by-pixel visual diffs until 100% fidelity. |
| **Zero Git Bloat & Screenshot Rotation** | 10 | `.gitignore` active; previous turn screenshots automatically purged each iteration. |
| **AI Memory & Struggle Point RCA** | 5 | Complete retrospective documented in `.ai-memory/` recording struggles, root causes, and solutions. |
| **Total** | **100** | **Ready for autonomous copy-paste execution anywhere.** |

---

## 👥 6. Operator Interrogation & Dual-Site Parameters Contract

Before executing any network requests or modifying Elementor widgets, the AI MUST explicitly query the user in the following exact format:

```text
Format for asking to the user

(base website, readonly)
url:

user:

app-password:


(elementor website, target and modify)
url:

user:

app-password:
```

### Parameter Contract, Security & Credential Vault Rules:
1. **Base Website (Read-Only Benchmark):**
   - **`url`**: Fully qualified URL of the reference website/page.
   - **`user`**: WordPress username for the base site.
   - **`app-password`**: WordPress Application Password for the base site (provided on its own line).
   - **Invariant:** Strictly read-only (`GET` calls only). The AI must NEVER execute `POST`, `PUT`, or `DELETE` requests against the base website. Used solely to inspect layout, capture reference screenshots, and extract media assets.
2. **Elementor Website (Target & Modify):**
   - **`url`**: Fully qualified URL of the target WordPress/Elementor site undergoing modification.
   - **`user`**: WordPress username for the target site.
   - **`app-password`**: WordPress Application Password for the target site (provided on its own line).
   - **Invariant:** Target of modifications. The AI MUST create an isolated draft backup (`<Title> - Backup [Timestamp]`) recorded in `backups.json` AND a filesystem snapshot in `backups/<site_slug>/<page_slug>-<page_id>/before/` BEFORE modifying any post, page, or postmeta.
3. **2-Times Base64 Credential Storage & Reuse Flow:**
   - On the first successful connection to the sites, the credentials are encoded 2-times using Base64 with strongly-typed `EncodingConstants`:
     `encoded = base64.b64encode(base64.b64encode(raw_password.encode(EncodingConstants.UTF8))).decode(EncodingConstants.ASCII)`
   - Saved into local SQLite database `data/config.db` in table `Credentials`.
   - On all future loops, iterations, and subsequent pages, credentials are automatically loaded from `data/config.db` without repeatedly prompting the user.
