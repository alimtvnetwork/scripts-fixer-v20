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

Prompt Version: 2.2.0 (Master Autonomous Standalone Edition — Unsupervised Loop, Progress Telemetry & Discrepancy Planning) Target Audience: Autonomous AI Agents (Antigravity, Cursor, Claude, ChatGPT, Muse), Full-Stack WordPress Engineers, QA Automation Leads
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

## ✅ 0. Non-Negotiable Checklist — Read Before Every Page

The AI MUST check off every box below before the first mutation of each page/post, and re-check the whole list before moving to the next page. A missed box is a failed run. No exceptions, no "later", no skipping because a previous page passed.

- [ ] **Clone first:** page/post cloned to `<slug>-old` (draft, never modified) BEFORE any mutation; clone id + slug recorded in `checks/tracking.csv` + `backups.json`. (§1.10)
- [ ] **In place:** the ORIGINAL is modified, same id, same slug. The slug is NEVER changed. (§1.10)
- [ ] **Public:** working page `status == "publish"` asserted by fresh GET after EVERY mutation (fix-up POST if needed); new pages created `publish` directly. (§1.11)
- [ ] **Side by side:** base vs Elementor compared for ALL screens/viewports, every iteration. (§1 item 5)
- [ ] **CSV:** every clone + every (page, viewport, iteration) appended to `checks/tracking.csv`. (§4.11)
- [ ] **Checks folder:** screenshots in `checks/<slug>/<viewport>/` (base / elementor / diff), latest triple kept. (§4.12)
- [ ] **Report:** `checks/report.html` regenerated after every iteration + at task end; COPY button verified working. (§4.12)
- [ ] **Homepage first:** no slug given → homepage first, then the next page. (§1.12)
- [ ] **100%:** loop until EVERY viewport is at or below 0.5% diff; fixes ONLY through the Python REST scripts, never by hand in the editor. (§1.12)
- [ ] **Backups:** filesystem `before/` + `after/` snapshots AND draft backup `<Title> - Backup [Timestamp]` in `backups.json` before mutating. (§1 items 3, 6)
- [ ] **Strictly unsupervised loop:** run completely without human supervision; NEVER pause to ask "Want me to start now or wait until you're back?", "Should I proceed?", or wait for loop approvals. The user sends the prompt and goes to sleep ("in the morning I should check all"); start comparing and fine-tuning immediately. (§1 item 1.3)
- [ ] **Periodic 5–10 min progress telemetry:** output concise 1–2 line status updates every 5 to 10 minutes so operator reviewing logs knows work is actively progressing. (§1 item 1.4)
- [ ] **Discrepancy & plan MD log:** each time a page is visited/compared, write down all visual differences and the exact planned Python script/CSS/AST fixes into `checks/<slug>/discrepancies.md` (and `comparisons/<slug>/discrepancies.md`) before mutating, so fixes can be applied rapidly. (§1 item 1.5, §4.14)
- [ ] **Elementor-modifiable invariant:** EVERY modified item must be modifiable using Elementor (Flexbox containers, native widgets, style controls, custom CSS); total ban on raw unmanageable HTML outside Elementor AST. (§1 item 1.6)
- [ ] **Line-by-line credentials:** operator queried using copy-paste ready format with line-by-line username, password, URLs, and admin panel check. (§1 item 1, §6)
- [ ] **Immediate login confirmation:** before ANY page discovery or mutation, AI authenticates via Python session, validates /wp-admin/, verifies administrator role, and emits immediate confirmation to the operator. (§1 item 1.1)
- [ ] **Bot-challenge bypass:** requests.Session with browser User-Agent used; never raw curl; nonce extracted from /wp-admin/ for REST calls. (§1 item 1.2, §4.13)
- [ ] **Sleepy autopilot & ambiguity:** if operator mentions sleepiness ("I'm a bit sleepy. Try to take the best decision possible"), proceed autonomously picking best sensible defaults and recording ambiguities to ambiguity folder. (§3)
- [ ] **Credentials:** 2x Base64 in `data/config.db`, reused, never re-asked once stored. (§1 item 1)
- [ ] **Git hygiene:** screenshots + `data/` gitignored; previous iteration screenshots pruned; `checks/tracking.csv` + `checks/report.html` committed. (§1 item 7, §4.8)
- [ ] **Memory:** struggle points + root causes logged in `.ai-memory/`; final commit + push. (§1 items 8, 9)

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

1. **Target URLs, Line-by-Line Credential Query & Immediate Login Confirmation:**
   - The AI **MUST ASK** the operator for dual-site parameters using the exact line-by-line, copy-paste ready format before touching code:
```text
================================================================================
FORMAT FOR ASKING TO THE OPERATOR (COPY-PASTE READY)
================================================================================
Base Website URL:
Base Website Username:
Base Website Password:

Elementor Website URL:
Elementor Website Username:
Elementor Website Password:

Can you log into the admin panel? (yes/no):
================================================================================
```
   - **Line-by-Line Formatting Invariant:** Each username MUST be on its own line item, and each password MUST be on its own line item. The operator can copy the block, insert values directly on each line, and paste it back into chat in one single turn.
   - **Admin Panel Verification Question:** The query MUST include `Can you log into the admin panel? (yes/no):` to ensure credentials have been confirmed in a real browser.
   - **Immediate Backend Login Confirmation Invariant (NON-NEGOTIABLE):** Right after receiving the credential payload, before inspecting pages or mutating AST, the AI **MUST IMMEDIATELY** test backend authentication using the verified Python session method. The AI **MUST CONFIRM IMMEDIATELY** right after receiving credentials:
     ```text
     ✅ Backend Login Confirmed: Successfully authenticated to WordPress Admin Panel (/wp-admin/) and REST API (/wp-json/wp/v2/users/me) as administrator.
     ```
     If login fails, the AI stops immediately and diagnoses client headers/cookies without touching any site page.

## 🔐 WordPress Backend Authentication & Bot-Challenge Bypass (Verified Session Method)

Add this to the Elementor looping prompt. Any AI reading it should be able to log in on the first try, without wasting turns on curl / Basic Auth.

### 0. The one thing to know first
The login is NOT broken. A real browser logs in fine. Scripted clients fail because a bot-verification layer in front of the site challenges non-browser requests ("One moment, please... — Please wait while your request is being verified..."). If you see that page, or a 401 `rest_not_logged_in`, you have NOT proven the password is wrong — you have proven your client was challenged. Do not keep retrying the same failing call. Change the client, not the password.

### 1. What NOT to do
- Do NOT use `curl` with its default User-Agent. It is challenged every time.
- Do NOT use HTTP Basic Auth on the REST API with the account password. WordPress only accepts Application Passwords that way; the account password returns 401 `rest_not_logged_in`. (An Application Password is 24 characters, REST-only, and can never log in via wp-login.php.)
- Do NOT call the REST API with session cookies alone and no nonce — that also returns 401. Cookie auth needs a nonce.
- There is NO REST login/token endpoint in core WordPress. Do not look for one.

### 2. The working method (Python, verified twice)
Use Python `requests` with a persistent session. Credentials come from environment variables only (`WP_USER`, `WP_PASS`) or SQLite vault `data/config.db` — never hard-code them, never write them to an unencrypted file, never commit them.

```python
import requests
s = requests.Session()
s.headers.update({
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
})
BASE = "{base url}"

# 1. GET the login page first — this sets wordpress_test_cookie.
s.get(f"{BASE}/wp-login.php", timeout=30)

# 2. POST the login form in the SAME session.
r = s.post(f"{BASE}/wp-login.php", data={
    "log": USER, "pwd": PASS,
    "wp-submit": "Log In",
    "redirect_to": f"{BASE}/wp-admin/",
    "testcookie": "1",
}, allow_redirects=True, timeout=30)
# Success = HTTP 200, final URL .../wp-admin/, title "Dashboard",
# and a wordpress_logged_in_* cookie in the session.
```

### 3. Using the REST API after login
```python
# 3. Extract the REST nonce from the admin page HTML.
admin = s.get(f"{BASE}/wp-admin/", timeout=30).text
# Find wpApiSettings nonce, e.g. "nonce":"<10 hex chars>" — try each
# candidate until one works; some nonces in the page are for other actions.

# 4. Call REST with that nonce header, reusing the same session/cookies.
r = s.get(f"{BASE}/wp-json/wp/v2/users/me?context=edit",
          headers={"X-WP-Nonce": nonce}, timeout=30)
# Success = HTTP 200, user id 55, slug "riseup-team", roles ["administrator"].
# A 403 rest_cookie_invalid_nonce means you picked the wrong nonce candidate —
# try the next one. A 401 means the session is not logged in; go back to step 2.
```

### 4. Verify before doing any work (Immediate Confirmation Gate)
Before the first mutation or page inspection, confirm all three:
1. `GET /wp-admin/` in the session returns 200 with title "Dashboard".
2. `GET /wp-json/wp/v2/users/me?context=edit` with the nonce returns 200 and roles include "administrator".
3. `GET /wp-json/wp/v2/pages?status=publish&per_page=5` returns 200.
If any of these fail, stop and diagnose the client (User-Agent, cookies, nonce) — do not touch any page.
Once verified, the AI **MUST IMMEDIATELY CONFIRM** to the operator:
`✅ Backend Login Confirmed: Successfully authenticated to WordPress Admin Panel (/wp-admin/) and REST API (/wp-json/wp/v2/users/me) as administrator.`

### 5. Dual-Site Authentication Architecture
- **Base Website (read-only reference):** {base.site.url}
- **Elementor Website (target, modify):** {elementor.site.url}
- Ask the operator for the username and password using the copy-paste line-by-line format; use them only via persistent browser session. The base site uses the same login. Public homepages return 200 on both.

   - **Base Website (Read-Only):** The benchmark reference for visual truth and DOM asset extraction. Zero write/mutation operations permitted.
   - **Elementor Website (Target & Modify):** The target WordPress/Elementor site undergoing fine-tuning. Mandatory draft backup before mutations.
   - **2-Times Base64 Encoded Credential Vault (`data/config.db`):**
     - Passwords / App-passwords provided by the user **MUST BE SAVED** into a local SQLite database at `data/config.db` under the table `Credentials`.
     - The password **MUST BE ENCODED 2 TIMES** using Base64 with strongly-typed `EncodingConstants`:
       `encoded = base64.b64encode(base64.b64encode(raw_password.encode(EncodingConstants.UTF8))).decode(EncodingConstants.ASCII)`
     - **Automatic Reuse Across Loops & Future Tasks:** Once the first connection or iteration is successful, credentials are persisted into `data/config.db`. On subsequent loops, rerun iterations, or future pages on the same sites, the AI loads credentials directly from `data/config.db` without repeatedly prompting the user.


### 1.3 Strictly Unsupervised Autonomous Execution Gate (TOTAL BAN ON APPROVAL PAUSES)
- **The Problem It Solves:** Previously, AI agents frequently performed pre-flight checks and then stalled asking:
  `"Nothing has been changed on either site yet — the next step is step 1 above. Want me to start it now, or wait until you're back?"`
  This defeats the entire purpose of autonomous execution. The operator submits the prompt and goes to sleep expecting to wake up and review completed comparisons in the morning ("in the morning I should check all").
- **Mandatory Unsupervised Contract:**
  1. **TOTAL BAN ON ASKING TO START OR PROCEED:** The AI agent **MUST NEVER** halt to ask whether to start, whether to continue, or request approval to proceed with the loop.
  2. **Instant Autonomous Transition:** Once credentials/URLs are received (or defaulted to homepage), the AI MUST immediately test login, clone the backup (`<slug>-old`), begin capturing screenshots, and run the 100–300 iteration comparison loop without pausing.
  3. **No Redundant Approval Loops:** Never ask the user to type the same thing several times or approve steps repeatedly.

### 1.4 Periodic 5–10 Minute Progress Telemetry Heartbeat
- **Live Monitoring Invariant:** During long-running 100–300 iteration loops, the AI orchestrator **MUST EMIT** a concise 1-liner or 2-liner progress update every 5 to 10 minutes (or every 5–10 iterations) into the output log so the operator knows the engine is actively working:
  ```text
  [02:45:10] ⏳ Loop Progress: Page 'home' | Iteration 42/300 | 4/6 viewports passed | Best Match: 98.6% | Active: tuning hero container padding
  ```
- **Included Telemetry Metrics:** Timestamp, current target page slug, current iteration number vs max budget, viewports passing diff threshold, best visual similarity score, and current active tuning action.

### 1.5 Per-Visit Markdown Discrepancy & Remediation Planning Log (`discrepancies.md`)
- **Persistent Remediation Plan:** Each time the AI visits and compares a page across screens, it **MUST WRITE** all identified visual differences and the exact planned remediation strategy into:
  `checks/<slug>/discrepancies.md` (and `comparisons/<slug>/discrepancies.md`)
- **Required Markdown Document Structure:**
  1. **Discrepancy Inventory per Viewport:** Specific pixel, font-size, line-height, padding, margin, container gap, and alignment gaps for Desktop, Laptop, Tablet, and Mobile.
  2. **Remediation Action Plan:** Exact Python script adjustments, Elementor AST container property changes, and scoped CSS rules planned to resolve the gap.
  3. **Rapid Fix Rationale:** Having the discrepancies and planned fixes documented in an MD file allows the AI on subsequent passes to apply surgical fixes immediately without re-analyzing from scratch.

### 1.6 Elementor-Modifiable Invariant (Core Architectural Goal)
- **"Every item should be able to modify using the elementor that is the main goal":**
- **TOTAL BAN ON NON-ELEMENTOR RAW HTML OVERRIDES:** Every single visual or structural modification made to the page **MUST BE NATIVELY MODIFIABLE USING ELEMENTOR**:
  - Layout & Alignment: Must map to Elementor Flexbox Container controls (`direction`, `justify-content`, `align-items`, `gap`, `padding`, `margin`).
  - Typography & Colors: Must map to Elementor widget style settings (`typography_typography`, `typography_font_size`, `title_color`, etc.).
  - Custom Styling: Must be injected via Elementor Custom CSS attached to the widget or container selector (`selector { ... }`).
- This guarantees that after AI completion, human designers and site maintainers can visually inspect, adjust, and edit every element inside the standard Elementor editor UI.

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
   - At the conclusion of the task, the AI must record a structured retrospective in `.ai-memory/rca/resolved/`:
     - Where the AI struggled most (e.g. stubborn padding inheritance, sticky header offset, flex wrap bugs).
     - Exact root causes identified across the iterations.
     - Concrete remediation steps taken to achieve 100% pixel-perfect fidelity.

9. **Final Atomic Commit & Push Standard:**
   - Once 100% accuracy is achieved, commit all scripts, configurations, and conversation logs using structured semantic commit messages (`git commit -m "Feature: ELEMENTOR - pixel perfect fine tuning loop completion"`).
   - Upstream push is mandatory: No Push = Not Done.

10. **Clone-Before-Modify Backup Invariant — `<slug>-old` (NON-NEGOTIABLE GATE):**
   - Before ANY mutation of a page or post on the Elementor site, the AI **MUST CLONE** it first as the backup. The clone is the backup; the original is what gets modified.
     1. `GET /wp-json/wp/v2/pages|posts/<id>?context=edit` (or resolve by slug) and read the full payload: `title`, `content`, `slug`, `status`, `template`, `meta._elementor_data`, and all postmeta. Use `pages` for pages and `posts` for posts — the same endpoint family as the original.
     2. `POST /wp-json/wp/v2/pages|posts` with `title: "<Title> - Old"`, `slug: "<slug>-old"`, `content` and `meta._elementor_data` copied verbatim from the original, `status: "draft"`.
     3. If `<slug>-old` already exists (re-run of the same page), delete it first, then recreate it from the current pre-modify state. `<slug>-old` always means "the backup of the state immediately before this run's modifications".
     4. Record the clone id and slug in `checks/tracking.csv` and in `backups.json` before touching the original.
     5. Modify the ORIGINAL in place: same id, same slug, slug unchanged. The `-old` clone is never modified.
   - **Revert precedence (try in this order, log which one was used):** (1) the `<slug>-old` clone — copy its content back over the original; (2) the filesystem `before/` snapshot via `scripts/revert_page.py`; (3) the `<Title> - Backup [Timestamp]` draft backup. The `-old` clone is the primary revert path because it is live in WordPress. `scripts/revert_page.py` treats the `-old` clone as its first revert source, ahead of the filesystem `before/` snapshot and the timestamped draft backup.
   - The `-old` clone stays `draft` forever. It is a backup, not a public page — see directive 11.

11. **Public-Visibility Invariant — working page MUST be `publish` (NON-NEGOTIABLE):**
   - Every page or post the AI modifies or creates on the Elementor site **MUST BE PUBLIC**. After every mutation, `GET` the page and assert `status == "publish"`. If the status is anything else (`draft`, `private`, `pending`), `POST` `status: "publish"` and re-verify with a fresh `GET` before continuing to the next iteration.
   - Newly created pages are created with `status: "publish"` directly — never created as draft and left that way.
   - The per-page exit gate is not passed until the public assertion holds for that page (in addition to all viewports passing the diff tolerance).
   - No conflict with the backups: the `<slug>-old` clone (directive 10) and the `<Title> - Backup [Timestamp]` draft clone (directive 6) stay `draft` by design. Backups are not public; only the working page (original slug) must be public.

12. **Homepage Default & Python-Script-Only Fix Path (NON-NEGOTIABLE):**
   - **Slug resolution order:** (1) the operator-supplied page/post slug; (2) the homepage; (3) halt and ask the operator. Never guess a slug.
   - **Homepage resolution:** the page WordPress serves at `/` — resolve via the front-page setting (`page_on_front` / `show_on_front`); fallback to the page with slug `home`; fallback to the site root URL `/`. If resolution fails, halt and ask — never guess.
   - **Loop to 100%:** run the 100–300 iteration loop (directive 5) on the homepage first, then move to the next page (operator order, or the site page-list order) and repeat from the clone-backup step (directive 10). "100% accurate" means every viewport in `screens.json` passes the 0.5% diff tolerance — not a literal 0.00% pixel diff, which real browsers cannot produce (sub-pixel rendering, fonts). Keep comparing every iteration; if any viewport fails, keep fixing.
   - **Fix path:** every fix goes through the Python REST scripts only (`scripts/finetune_loop.py`, `scripts/visual_diff.py`, `scripts/css_saver.py`, `scripts/backup_draft.py`, `scripts/clone_backup.py`, `scripts/csv_tracker.py`, `scripts/report_builder.py`). No manual Elementor editor edits, no direct WordPress dashboard changes, no hand edits to the live page. If a fix cannot be expressed through the scripts, log it as an ambiguity in `.ai-memory/ambiguous-questions/`, apply the closest scriptable fix, and keep looping.
   - **Exit gate per page:** all viewports green AND `status == "publish"` asserted AND `checks/tracking.csv` appended AND `checks/report.html` regenerated. Only then is the page done.

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
| **Non-Negotiable Checklist** | §0 items all read & confirmed | Checked off before first mutation, re-checked per page |
| **Clone-Backup (`<slug>-old`)** | `scripts/clone_backup.py` before first mutation | Clone created (title `<Title> - Old`, slug `<slug>-old`, `draft`); id + slug in `checks/tracking.csv` + `backups.json`; original modified in place, slug unchanged |
| **Public Visibility** | Working page `status == "publish"` | Asserted by fresh `GET` after every mutation; `-old` clone + draft backup stay `draft` |
| **CSV Tracking** | `checks/tracking.csv` (append-only) | One row per (page, viewport, iteration): slugs, URLs, diff %, status, backup ids, screenshot paths; committed |
| **Checks Folder & Report** | `checks/<slug>/<viewport>/` + `checks/report.html` | Latest base / Elementor / diff triple per viewport; side-by-side report with issue selector + COPY button, regenerated every iteration |
| **Homepage Default** | No slug → homepage first | Resolved via `page_on_front` / `home` / `/`; loop to 100% (all viewports ≤ 0.5%) via Python scripts only |

---

## 📜 3. Verbatim Prompt Directives (Master Gist Source)

```markdown
Please learn Python Prompt First (50 Steps learn and update your memory first):
https://gist.githubusercontent.com/alimtvnetwork/fd0953a5f2bfbbc91ae6e3666c5f7c37/raw/b573e3d2cd164d74350bee9c77ccc3b608250333/python-any-task-prompt.md

Please learn WordPress Actions (50 Steps learn and update your memory first):
https://gist.githubusercontent.com/alimtvnetwork/11900295ef222d921bd646923fbcff3d/raw/957bb2b806d2bb6dae45f5d8f17c5fdefbe5aa55/universal-wp-modernizing-master-prompt.md

# Main Goal Try to understand list out the tasks please - Run Iterations and Compare Screens: high priority instruction, non-negotiable task

You are going to run 100 to 300 iteration on each page and compare three to four screens, desktop, mobile tab, mobile landing view, landscape view, tablet, horizontal and vertical view. Desktop has many different screens, so find all the screens. First, find the screen sizes and put the screen sizes as JSON. So that should be your first starting point. Then you follow the Python script, Python prompts segment, how you wanted to do stuff step by step. Then what you should do is you compare the original website and what you change. So I will give you the, let's say, the page slug that you wanted to modify and the same slug you can find in the original website. After you change or fix it to the Elementor, you should check every bits and piece with these 300 iterations. Each iteration you compare in three, four, five, six screens, compare the screenshots, check where the issues are, find the root cause, explain it to yourself where the issue is, fix it, and then again, check the screenshot on all the screens and then again, compare with the original one. So original one will also have all the screenshots, and then your version will also have all the screenshots, and then you compare, contrast, and figure out where the gap is. By these type of iterations, you will fix one page 100% accurately. Once you feel that it is 100% accurate, you complete the task. So until you do, you loop through the process and write the Python script each time to modify the site and remember the history so that in the future when we do it for the next website, you can understand where the glitches were. And at the end, you are going to write where you struggle most, what was the root cause on fixing it, and how you have fixed it every step so that next AI when reads it, they would understand from the AI memory folder that this is how it needs to be done. So at the end, you are going to ask me the original website, let's say page, and the slug of the current website that you are going to modify. And before you start modifying, make sure you take a backup draft, backup of that page or post, and then start doing the step of migration and fixing each pixel perfect screen on every screen possible. Before you modify any page or post, clone it first as <slug>-old — that clone is the backup and you never touch it again; you modify the original in place, its slug never changes, and after every change you confirm the working page is public while the -old clone and the draft backup stay draft. Track every page, every screen and every iteration in checks/tracking.csv, keep the latest base, Elementor and diff screenshots side by side in checks/<slug>/<viewport>/, and rebuild checks/report.html after every iteration so I can open it locally, pick a page and a screen, and copy an issue report back to you. If I give you no slug, start with the homepage and keep looping until every screen is 100% accurate, fixing only through the Python scripts. The first thing you should do is confirm that you understand the task, you know the Python prompt, how to write the Python scripts to modify each one of the layers. You know how to take the backup before you modify the page. Remember that. And then you start doing it in each step in the Elementor using the Python script, and you give the history of it, what was the root cause of it, so that any time later on. And for each one of the change, you should create the folder, and in that folder, you write this script, you write this state, history, screenshots, before, after, original and the current website. You compare, and when you go to the next version, you always remove the previous screenshot so that we don't have too many of the screenshots. Remember that. The screenshots do not commit to the Git. It should be Git ignore. So you should have a folder structure like screenshots that would be ignored from the Git as well. Also, make sure you save the password as 2 times base64 encoding in a data\config.db sqlite db so that it can be used in the future and you can do the loop once the first one is successful without asking again. Also keep the CSS saved to our file system in the css/ folder as well, and create a backup of the post, single page, before and after in our file system where we start to modify as a folder structure (backups/<site_slug>/<page_slug>-<page_id>/before and after) so that it can be used to revert if required. So make sure you work on it. If you have any question, concern, let me know. So after this, you should always ask me for the original website page and the current website page and original and the current one what you are modifying. You ask me, I will provide you. And each time I do that, you repeat the process. And remember to write the root cause so that any AI who reads it understands it, where the problem is. They would fine-tune and fix it very quickly in the future. Do you understand? Every step, every change of the CSS, how you're doing it, every change of the HTML section or the component section that you are modifying, write it like this. If you're changing a padding using the Elementor component, write it like this. So you try to find each case, a problem, an issue, so that you can rely on it. After that, I assume that you have all the information. You also know the WordPress prompt, you know the Python prompt, which I have run. And then now you are going to ask me for the two URLs. You are going to work on it. And then finally, when you are done, you complete it. Until you're done, you continue the steps. And finally, when you're done, you make sure you commit every things to the Git, like every conversation, steps that you have done. And finally, what actually made you success, root cause analysis, script history, and everything, so that any AI who runs it, they would know how to fix things in the future. Is it clear?

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
14. Clone-before-modify: before mutating any page or post, clone it as `<slug>-old` (title `<Title> - Old`, status `draft`, content + `_elementor_data` verbatim); if `<slug>-old` already exists, delete it and recreate it from the current pre-modify state. Record clone id + slug in `checks/tracking.csv` and `backups.json`. Modify the ORIGINAL in place — same id, same slug. Revert order: `-old` clone first, then filesystem `before/` snapshot, then the timestamped draft backup.
15. Public invariant: after every mutation, GET the working page and assert `status == "publish"`; if not, POST status `publish` and re-verify. New pages are created with `status: "publish"`. The `-old` clone and the draft backup stay `draft` — only the working page must be public. A page is not done until the public assertion holds.
16. CSV tracking: append one row per (page, viewport, iteration) to `checks/tracking.csv` after every iteration — never rewrite the file. Columns: timestamp, page_slug, elementor_slug, old_slug, base_url, elementor_url, page_type, viewport, iteration, diff_percent, status, backup_old_id, backup_draft_title, before_path, after_path, screenshot_base, screenshot_elementor, screenshot_diff, notes. The CSV is committed to Git; it is the audit trail.
17. Checks folder: keep the latest base / Elementor / diff screenshot triple in `checks/<page-slug>/<viewport-id>/` for every viewport, so base and Elementor can be compared side by side for ALL screens. Per-iteration sets live in `checks/<page-slug>/<viewport-id>/iteration-<NNN>/` and are pruned like `screenshots/` (gitignored); the latest triple is always kept and committed.
18. HTML report: regenerate `checks/report.html` after every iteration and at task end. Single self-contained file, opened locally with no server. Per page it shows base vs Elementor side by side for every viewport with diff %, iteration, status, and links to both URLs. Per (page, viewport) row it has an issue selector (viewport picker + free-text issue box) and a COPY button that copies the structured report block (base URL + slug, Elementor URL + slug, screen + dimensions, iteration, diff %, issue text) so the user can paste it back and the AI resumes at that exact (page, viewport, iteration).
19. Homepage default: if no page slug is given, start with the homepage first — resolve via `page_on_front` / `show_on_front`, fallback slug `home`, fallback site root `/`. If resolution fails, halt and ask; never guess a slug. After the homepage reaches 100%, move to the next page and repeat from the clone step.
20. Python-only fix path to 100%: every fix goes through the Python REST scripts only — no manual Elementor editor edits, no dashboard changes. "100% accurate" means every viewport passes the 0.5% diff tolerance. Loop up to 300 iterations per page, comparing all screens every iteration, until all viewports pass. A page is done only when all viewports are green AND status is `publish` AND `checks/tracking.csv` is appended AND `checks/report.html` is regenerated.
21. Non-Negotiable Checklist (§0): before the first mutation of each page/post, read the checklist at the top of this prompt and check off every box; re-check the whole list before moving to the next page. A missed box is a failed run — no exceptions, no "later".

### "I am sleepy" Autopilot Checklist
- [ ] 1. Repository pulled and clean before work (`git pull`)
- [ ] 2. "I am sleepy" Autopilot Active: When the operator says "I'm a bit sleepy. Try to take the best decision possible", pick the closest sensible solution for every ambiguity without waking or prompting the operator. Record all ambiguities to the ambiguity folder (`.ai-memory/ambiguity/new/` or `.ai-memory/ambiguous-questions/01-new-ambiguity/`) and proceed autonomously through all iterations.
- [ ] 3. Ambiguities & Batch Questions: Record in `.ai-memory/ambiguous-questions/` for morning review; never halt execution
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

# checks/: latest per-viewport triple is committed (audit trail); per-iteration sets are pruned
!checks/**/*.png
!checks/**/*.jpg
checks/*/*/iteration-*/

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

python3 scripts/finetune_loop.py --slug home --iterations 300
```

### 4.10 Clone-Before-Modify Backup Engine (`scripts/clone_backup.py`)

Reference implementation (also kept at `02-spec/21-app/102-elementor-prompt-enhancement/artifacts/clone-backup.py`):

```python
#!/usr/bin/env python3
"""
clone_backup.py — Clone-before-modify backup for Elementor pages/posts.

Implements spec 102 §3.1 (directive §1.10): before ANY mutation of a page or
post on the Elementor site, clone it to `<slug>-old` as a draft. The `-old`
clone is the backup and is never modified; the ORIGINAL is modified in
place (same id, same slug, status `publish`).

Flow:
  1. GET the original by slug (context=edit).
  2. DELETE the existing `<slug>-old` clone first when a re-run finds one.
  3. POST the clone: title `<Title> - Old`, slug `<slug>-old`, content and
     meta copied verbatim, status `draft`.
  4. Record the clone in `backups.json` and append the clone row to
     `checks/tracking.csv` (via csv_tracker).

Depends on `csv_tracker.py` in the same `scripts/` directory.
"""
from __future__ import annotations

import argparse
import base64
import json
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any, Optional

from csv_tracker import append_tracking_row, build_clone_row


class WpConstants:
    """WordPress REST constants (no magic strings)."""
    REST_PREFIX: str = "wp-json/wp/v2"
    OLD_SUFFIX: str = "-old"
    OLD_TITLE_SUFFIX: str = " - Old"
    STATUS_DRAFT: str = "draft"
    CONTEXT_EDIT: str = "edit"
    FORCE_DELETE: str = "force=true"
    ENCODING_UTF8: str = "utf-8"
    BACKUPS_LEDGER: str = "backups.json"


class SnapshotStage(str, Enum):
    """Filesystem snapshot stages."""
    BEFORE = "before"
    AFTER = "after"


class PostType(str, Enum):
    """WordPress post types handled by the clone step."""
    PAGE = "pages"
    POST = "posts"


class ErrorCode(str, Enum):
    """Typed error codes for clone-backup failures."""
    FETCH_FAILED = "CLONE_FETCH_FAILED"
    CREATE_FAILED = "CLONE_CREATE_FAILED"
    DELETE_FAILED = "CLONE_DELETE_FAILED"
    NOT_FOUND = "CLONE_NOT_FOUND"
    INVALID_RESPONSE = "CLONE_INVALID_RESPONSE"


@dataclass(frozen=True)
class AppError(Exception):
    """Typed application error envelope."""
    code: ErrorCode
    message: str

    def __str__(self) -> str:
        return f"[{self.code.value}] {self.message}"


def build_auth_header(username: str, app_password: str) -> str:
    """Build a Basic auth header from WordPress application-password credentials."""
    token = base64.b64encode(f"{username}:{app_password}".encode(WpConstants.ENCODING_UTF8))
    return f"Basic {token.decode(WpConstants.ENCODING_UTF8)}"


def rest_get_json(url: str, auth_header: str) -> Any:
    """GET a URL and return the decoded JSON body."""
    request = urllib.request.Request(url, headers={"Authorization": auth_header})
    try:
        with urllib.request.urlopen(request) as response:
            return json.loads(response.read().decode(WpConstants.ENCODING_UTF8))
    except urllib.error.HTTPError as err:
        raise AppError(ErrorCode.FETCH_FAILED, f"GET {url} failed: HTTP {err.code}") from err
    except urllib.error.URLError as err:
        raise AppError(ErrorCode.FETCH_FAILED, f"GET {url} failed: {err.reason}") from err


def rest_post_json(url: str, auth_header: str, payload: dict) -> dict:
    """POST a JSON payload and return the decoded JSON body."""
    body = json.dumps(payload).encode(WpConstants.ENCODING_UTF8)
    headers = {"Authorization": auth_header, "Content-Type": "application/json"}
    request = urllib.request.Request(url, data=body, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(request) as response:
            return json.loads(response.read().decode(WpConstants.ENCODING_UTF8))
    except urllib.error.HTTPError as err:
        raise AppError(ErrorCode.CREATE_FAILED, f"POST {url} failed: HTTP {err.code}") from err
    except urllib.error.URLError as err:
        raise AppError(ErrorCode.CREATE_FAILED, f"POST {url} failed: {err.reason}") from err


def rest_delete(url: str, auth_header: str) -> None:
    """DELETE a URL (force delete, no trash)."""
    request = urllib.request.Request(url, headers={"Authorization": auth_header}, method="DELETE")
    try:
        with urllib.request.urlopen(request) as response:
            response.read()
    except urllib.error.HTTPError as err:
        raise AppError(ErrorCode.DELETE_FAILED, f"DELETE {url} failed: HTTP {err.code}") from err
    except urllib.error.URLError as err:
        raise AppError(ErrorCode.DELETE_FAILED, f"DELETE {url} failed: {err.reason}") from err


def find_by_slug(site_url: str, auth_header: str, post_type: PostType, slug: str) -> Optional[dict]:
    """Return the first post/page with the slug, or None."""
    base = site_url.rstrip("/")
    url = f"{base}/{WpConstants.REST_PREFIX}/{post_type.value}?slug={slug}&context={WpConstants.CONTEXT_EDIT}"
    result = rest_get_json(url, auth_header)
    if not isinstance(result, list):
        raise AppError(ErrorCode.INVALID_RESPONSE, f"Expected a list from {url}")
    return result[0] if result else None


def fetch_original(site_url: str, auth_header: str, post_type: PostType, slug: str) -> dict:
    """Fetch the original page/post by slug; raise when missing."""
    original = find_by_slug(site_url, auth_header, post_type, slug)
    if original is None:
        raise AppError(ErrorCode.NOT_FOUND, f"No {post_type.value} with slug '{slug}'")
    return original


def old_slug_for(slug: str) -> str:
    """Return the backup clone slug for a page slug."""
    return f"{slug}{WpConstants.OLD_SUFFIX}"


def delete_existing_old_clone(site_url: str, auth_header: str, post_type: PostType, slug: str) -> Optional[int]:
    """Delete the existing -old clone, if any; return its id or None."""
    old_slug = old_slug_for(slug)
    existing = find_by_slug(site_url, auth_header, post_type, old_slug)
    if existing is None:
        return None
    old_id = int(existing.get("id", 0))
    delete_url = f"{site_url.rstrip('/')}/{WpConstants.REST_PREFIX}/{post_type.value}/{old_id}?{WpConstants.FORCE_DELETE}"
    rest_delete(delete_url, auth_header)
    return old_id


def build_clone_payload(original: dict, slug: str) -> dict:
    """Build the POST payload for the -old draft clone."""
    title = original.get("title", {})
    raw_title = title.get("raw", "") if isinstance(title, dict) else ""
    content = original.get("content", {})
    raw_content = content.get("raw", "") if isinstance(content, dict) else ""
    return {
        "title": f"{raw_title}{WpConstants.OLD_TITLE_SUFFIX}",
        "slug": old_slug_for(slug),
        "content": raw_content,
        "status": WpConstants.STATUS_DRAFT,
        "meta": original.get("meta", {}),
        "template": original.get("template", ""),
    }


def create_old_clone(site_url: str, auth_header: str, post_type: PostType, original: dict, slug: str) -> dict:
    """POST the -old draft clone and return the created object."""
    payload = build_clone_payload(original, slug)
    url = f"{site_url.rstrip('/')}/{WpConstants.REST_PREFIX}/{post_type.value}"
    created = rest_post_json(url, auth_header, payload)
    if not isinstance(created, dict) or "id" not in created:
        raise AppError(ErrorCode.INVALID_RESPONSE, "Clone POST did not return an object with id")
    return created


def load_backups_ledger() -> list:
    """Load backups.json records (JSON:API-style {data: [...]}) or return []."""
    ledger = Path(WpConstants.BACKUPS_LEDGER)
    if not ledger.exists():
        return []
    try:
        doc = json.loads(ledger.read_text(encoding=WpConstants.ENCODING_UTF8))
    except json.JSONDecodeError:
        return []
    if isinstance(doc, dict):
        return doc.get("data", []) if isinstance(doc.get("data", []), list) else []
    return doc if isinstance(doc, list) else []


def save_backups_ledger(records: list) -> None:
    """Write backups.json records back to disk."""
    ledger = Path(WpConstants.BACKUPS_LEDGER)
    with open(ledger, "w", encoding=WpConstants.ENCODING_UTF8, newline="\n") as handle:
        json.dump({"data": records}, handle, indent=2)


def build_old_clone_record(original: dict, created: dict, slug: str, now: datetime) -> dict:
    """Build the backups.json record for an -old clone."""
    return {
        "id": f"oldClone{original.get('id')}-{now.strftime('%Y%m%dT%H%M%SZ')}",
        "type": "oldCloneBackup",
        "attributes": {
            "timestamp": now.isoformat(),
            "originalPageId": original.get("id"),
            "originalSlug": slug,
            "oldSlug": old_slug_for(slug),
            "oldCloneId": created.get("id"),
            "status": WpConstants.STATUS_DRAFT,
        },
    }


def record_old_clone(original: dict, created: dict, slug: str) -> dict:
    """Append the -old clone record to backups.json and return it."""
    record = build_old_clone_record(original, created, slug, datetime.now(timezone.utc))
    records = load_backups_ledger()
    records.append(record)
    save_backups_ledger(records)
    return record


def snapshot_path(site_slug: str, slug: str, page_id: int, stage: SnapshotStage) -> str:
    """Return the filesystem snapshot path for a stage (before/after)."""
    return f"backups/{site_slug}/{slug}-{page_id}/{stage.value}/"


def record_clone_csv(csv_path: str, page_slug: str, base_url: str, elementor_url: str, page_type: str, old_slug: str, old_id: Any, draft_title: str, before_path: str, after_path: str) -> dict:
    """Append the clone-event row to checks/tracking.csv."""
    row = build_clone_row(
        page_slug, page_slug, old_slug, base_url, elementor_url,
        page_type, old_id, draft_title, before_path, after_path,
    )
    append_tracking_row(csv_path, row)
    return row


def build_clone_summary(original_id: int, slug: str, created: dict, deleted_id: Optional[int], record: dict, row: dict) -> dict:
    """Build the JSON summary returned by the clone step."""
    return {
        "original_id": original_id,
        "original_slug": slug,
        "old_slug": old_slug_for(slug),
        "old_clone_id": created.get("id"),
        "deleted_old_id": deleted_id,
        "backup_record_id": record.get("id"),
        "csv_row": row,
    }


def clone_page_as_old(site_url: str, base_url: str, auth_header: str, post_type: PostType, slug: str, site_slug: str, csv_path: str) -> dict:
    """Run the full clone-before-modify step and return a summary."""
    original = fetch_original(site_url, auth_header, post_type, slug)
    deleted_id = delete_existing_old_clone(site_url, auth_header, post_type, slug)
    created = create_old_clone(site_url, auth_header, post_type, original, slug)
    record = record_old_clone(original, created, slug)
    original_id = int(original.get("id", 0))
    before = snapshot_path(site_slug, slug, original_id, SnapshotStage.BEFORE)
    after = snapshot_path(site_slug, slug, original_id, SnapshotStage.AFTER)
    row = record_clone_csv(
        csv_path, slug, base_url, str(original.get("link", site_url)),
        post_type.value, old_slug_for(slug), created.get("id", ""),
        "", before, after,
    )
    return build_clone_summary(original_id, slug, created, deleted_id, record, row)


def build_parser() -> argparse.ArgumentParser:
    """Build the CLI parser for clone-backup.py."""
    parser = argparse.ArgumentParser(description="Clone a WP page/post to <slug>-old before modifying it")
    parser.add_argument("--site-url", required=True, help="Elementor site root URL")
    parser.add_argument("--base-url", required=True, help="Base page URL (read-only reference)")
    parser.add_argument("--slug", required=True, help="Page/post slug to clone")
    parser.add_argument("--type", dest="post_type", default="pages", choices=["pages", "posts"], help="Post type")
    parser.add_argument("--username", required=True, help="WordPress username")
    parser.add_argument("--app-password", required=True, help="WordPress application password")
    parser.add_argument("--site-slug", default="elementor", help="Site slug for snapshot paths")
    parser.add_argument("--csv", default="checks/tracking.csv", help="Tracking CSV path")
    return parser


def main(argv: Optional[list[str]] = None) -> int:
    """CLI entry point: clone a page/post to <slug>-old."""
    args = build_parser().parse_args(argv)
    auth_header = build_auth_header(args.username, args.app_password)
    post_type = PostType(args.post_type)
    try:
        summary = clone_page_as_old(
            args.site_url, args.base_url, auth_header, post_type,
            args.slug, args.site_slug, args.csv,
        )
    except AppError as err:
        print(str(err), file=sys.stderr)
        return 1
    print(json.dumps(summary, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

Contract — `scripts/clone_backup.py` clones a WordPress page or post as the `<slug>-old` backup before any mutation:
- Inputs: Elementor site URL, auth header, page/post id or slug, endpoint family (`pages` or `posts`).
- `GET /wp-json/wp/v2/pages|posts/<id>?context=edit` and read the full payload (`title`, `content`, `slug`, `status`, `template`, `meta._elementor_data`, postmeta).
- If a page/post with slug `<slug>-old` already exists, delete it first, then recreate it from the current pre-modify state.
- `POST /wp-json/wp/v2/pages|posts` with `title: "<Title> - Old"`, `slug: "<slug>-old"`, verbatim `content` + `meta._elementor_data`, `status: "draft"`.
- Records the clone id and slug in `checks/tracking.csv` (via `scripts/csv_tracker.py`) and in `backups.json` before returning.
- Revert path: copy the `-old` clone content back over the original in place (same id, same slug); `scripts/revert_page.py` treats the `-old` clone as its first revert source, ahead of the filesystem `before/` snapshot and the timestamped draft backup.
- The `-old` clone is never modified after creation and never published.

### 4.11 CSV Tracking Engine (`scripts/csv_tracker.py`)

Reference implementation (also kept at `02-spec/21-app/102-elementor-prompt-enhancement/artifacts/csv-tracker.py`):

```python
#!/usr/bin/env python3
"""
csv_tracker.py — Append-only tracking CSV writer for Elementor fine-tuning.

Implements spec 102 §3.3: one row per (page, viewport, iteration) in
`checks/tracking.csv`, plus one clone row per backup event (viewport
`clone`, iteration `0`). The file is never rewritten, only appended; it is
committed to Git as the audit trail. Schema: see `tracking-schema.md`.
"""
from __future__ import annotations

import argparse
import csv
import json
import sys
from datetime import datetime, timezone
from enum import Enum
from pathlib import Path
from typing import Any, Optional


class TrackingConstants:
    """Tracking CSV constants (no magic strings)."""
    DEFAULT_CSV_PATH: str = "checks/tracking.csv"
    ENCODING_UTF8: str = "utf-8"
    NEWLINE: str = ""
    CLONE_VIEWPORT: str = "clone"
    CLONE_ITERATION: int = 0
    TIMESTAMP_FORMAT: str = "%Y-%m-%dT%H:%M:%SZ"


TRACKING_COLUMNS: tuple[str, ...] = (
    "timestamp", "page_slug", "elementor_slug", "old_slug", "base_url",
    "elementor_url", "page_type", "viewport", "iteration", "diff_percent",
    "status", "backup_old_id", "backup_draft_title", "before_path",
    "after_path", "screenshot_base", "screenshot_elementor",
    "screenshot_diff", "notes",
)


class PageType(str, Enum):
    """WordPress content types tracked in the CSV."""
    PAGE = "page"
    POST = "post"


class TrackingStatus(str, Enum):
    """Row status values (spec 102 §3.3)."""
    BACKUP_CREATED = "backup_created"
    IN_PROGRESS = "in_progress"
    PASS = "pass"
    FAIL = "fail"
    REVERTED = "reverted"


def utc_now_iso() -> str:
    """Return the current UTC timestamp in ISO 8601 Zulu form."""
    return datetime.now(timezone.utc).strftime(TrackingConstants.TIMESTAMP_FORMAT)


def ensure_header(csv_path: str) -> None:
    """Create the CSV with its frozen header when missing or empty."""
    path = Path(csv_path)
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.stat().st_size > 0:
        return
    with open(path, "w", encoding=TrackingConstants.ENCODING_UTF8, newline=TrackingConstants.NEWLINE) as handle:
        writer = csv.DictWriter(handle, fieldnames=list(TRACKING_COLUMNS))
        writer.writeheader()


def append_tracking_row(csv_path: str, row: dict[str, Any]) -> dict[str, Any]:
    """Append one row (never rewrite); unknown keys are dropped."""
    ensure_header(csv_path)
    clean = {column: row.get(column, "") for column in TRACKING_COLUMNS}
    with open(csv_path, "a", encoding=TrackingConstants.ENCODING_UTF8, newline=TrackingConstants.NEWLINE) as handle:
        writer = csv.DictWriter(handle, fieldnames=list(TRACKING_COLUMNS))
        writer.writerow(clean)
    return clean


def identity_columns(page_slug: str, elementor_slug: str, old_slug: str, base_url: str, elementor_url: str, page_type: str) -> dict[str, Any]:
    """Return the six identity columns of a tracking row."""
    return {
        "page_slug": page_slug,
        "elementor_slug": elementor_slug,
        "old_slug": old_slug,
        "base_url": base_url,
        "elementor_url": elementor_url,
        "page_type": page_type,
    }


def build_row(identity: dict[str, Any], overrides: dict[str, Any]) -> dict[str, Any]:
    """Merge identity columns, blank event columns, and overrides."""
    row = {column: "" for column in TRACKING_COLUMNS}
    row["timestamp"] = utc_now_iso()
    row.update(identity)
    row.update(overrides)
    return row


def build_clone_row(page_slug: str, elementor_slug: str, old_slug: str, base_url: str, elementor_url: str, page_type: str, backup_old_id: Any, backup_draft_title: str, before_path: str, after_path: str) -> dict[str, Any]:
    """Build the clone-event row (viewport 'clone', iteration 0)."""
    identity = identity_columns(page_slug, elementor_slug, old_slug, base_url, elementor_url, page_type)
    overrides = {
        "viewport": TrackingConstants.CLONE_VIEWPORT,
        "iteration": TrackingConstants.CLONE_ITERATION,
        "status": TrackingStatus.BACKUP_CREATED.value,
        "backup_old_id": backup_old_id,
        "backup_draft_title": backup_draft_title,
        "before_path": before_path,
        "after_path": after_path,
    }
    return build_row(identity, overrides)


def build_iteration_row(page_slug: str, elementor_slug: str, old_slug: str, base_url: str, elementor_url: str, page_type: str, viewport: str, iteration: int, diff_percent: float, status: str, backup_old_id: Any, screenshot_base: str, screenshot_elementor: str, screenshot_diff: str, before_path: str = "", after_path: str = "", backup_draft_title: str = "", notes: str = "") -> dict[str, Any]:
    """Build one per-(page, viewport, iteration) tracking row."""
    identity = identity_columns(page_slug, elementor_slug, old_slug, base_url, elementor_url, page_type)
    event = {
        "viewport": viewport,
        "iteration": iteration,
        "diff_percent": f"{diff_percent:.2f}",
        "status": status,
        "backup_old_id": backup_old_id,
        "screenshot_base": screenshot_base,
        "screenshot_elementor": screenshot_elementor,
        "screenshot_diff": screenshot_diff,
        "notes": notes,
    }
    paths = {"backup_draft_title": backup_draft_title, "before_path": before_path, "after_path": after_path}
    return build_row(identity, {**event, **paths})


def read_rows(csv_path: str) -> list[dict[str, str]]:
    """Read all tracking rows; return [] when the file is missing."""
    path = Path(csv_path)
    if not path.exists():
        return []
    with open(path, "r", encoding=TrackingConstants.ENCODING_UTF8, newline=TrackingConstants.NEWLINE) as handle:
        return list(csv.DictReader(handle))


def latest_rows(rows: list[dict[str, str]]) -> dict[tuple[str, str], dict[str, str]]:
    """Return the highest-iteration row per (page_slug, viewport)."""
    latest: dict[tuple[str, str], dict[str, str]] = {}
    for row in rows:
        key = (row.get("page_slug", ""), row.get("viewport", ""))
        current = latest.get(key)
        if current is None or int(row.get("iteration", 0) or 0) > int(current.get("iteration", 0) or 0):
            latest[key] = row
    return latest


def build_parser() -> argparse.ArgumentParser:
    """Build the CLI parser for csv-tracker.py."""
    parser = argparse.ArgumentParser(description="Append-only Elementor tracking CSV writer")
    parser.add_argument("--csv", default=TrackingConstants.DEFAULT_CSV_PATH, help="Tracking CSV path")
    parser.add_argument("--row-json", required=True, help="Row fields as a JSON object")
    return parser


def main(argv: Optional[list[str]] = None) -> int:
    """CLI entry point: append one JSON row to the tracking CSV."""
    args = build_parser().parse_args(argv)
    row = json.loads(args.row_json)
    appended = append_tracking_row(args.csv, row)
    print(json.dumps(appended, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

Contract — `scripts/csv_tracker.py` maintains the append-only audit trail at `checks/tracking.csv`:
- One row per (page, viewport, iteration), appended after every iteration; the file is never rewritten, only appended.
- Columns (19, in order): `timestamp, page_slug, elementor_slug, old_slug, base_url, elementor_url, page_type, viewport, iteration, diff_percent, status, backup_old_id, backup_draft_title, before_path, after_path, screenshot_base, screenshot_elementor, screenshot_diff, notes`.
- `page_slug` is the working (original) slug; `elementor_slug` is the same slug on the Elementor site; `old_slug` is `<slug>-old`.
- `screenshot_base`, `screenshot_elementor`, `screenshot_diff` are paths under `checks/<page-slug>/<viewport-id>/`.
- `status` is the working page status asserted after the mutation (`publish` expected; any other value is a failure to fix before the next iteration).
- The CSV is committed to Git. `scripts/report_builder.py` reads it as the single source of truth for `checks/report.html`.

### 4.12 HTML Summary Report Builder (`scripts/report_builder.py`) and Report Template (`checks/report.html`)

Reference implementation (also kept at `02-spec/21-app/102-elementor-prompt-enhancement/artifacts/report-builder.py`):

```python
#!/usr/bin/env python3
"""
report_builder.py — Build checks/report.html from checks/tracking.csv.

Implements spec 102 §3.5: reads the tracking rows and the
`checks/<slug>/<viewport>/` images, injects a JSON snapshot into the
`comparison-report.html` template, and writes `checks/report.html`.
The report opens locally with no server and no external dependencies.
Regenerate after every iteration and at task end.
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Optional

from csv_tracker import TrackingConstants, latest_rows, read_rows


class ReportConstants:
    """Report builder constants (no magic strings)."""
    CHECKS_DIR: str = "checks"
    REPORT_FILE: str = "report.html"
    TEMPLATE_FILE: str = "comparison-report.html"
    TRACKING_CSV: str = "checks/tracking.csv"
    SCREENS_FILE: str = "screens.json"
    SNAPSHOT_TOKEN: str = "{{TRACKING_SNAPSHOT_JSON}}"
    GENERATED_AT_TOKEN: str = "{{GENERATED_AT}}"
    BASE_IMAGE: str = "base.png"
    ELEMENTOR_IMAGE: str = "elementor.png"
    DIFF_IMAGE: str = "diff.png"
    ENCODING_UTF8: str = "utf-8"
    TIMESTAMP_FORMAT: str = "%Y-%m-%dT%H:%M:%SZ"


def load_screens() -> dict[str, dict[str, Any]]:
    """Load screens.json viewports keyed by id; return {} when missing."""
    path = Path(ReportConstants.SCREENS_FILE)
    if not path.exists():
        return {}
    try:
        doc = json.loads(path.read_text(encoding=ReportConstants.ENCODING_UTF8))
    except json.JSONDecodeError:
        return {}
    viewports = doc.get("data", {}).get("attributes", {}).get("viewports", [])
    return {vp.get("id", ""): vp for vp in viewports if isinstance(vp, dict)}


def viewport_dimensions(viewport: dict) -> Optional[str]:
    """Return 'WxH' for a screens.json viewport, or None."""
    attrs = viewport.get("attributes", {})
    width = attrs.get("width")
    height = attrs.get("height")
    if width is None or height is None:
        return None
    return f"{width}x{height}"


def image_rel_path(checks_dir: Path, slug: str, viewport: str, name: str) -> str:
    """Return the relative image path, or '' when the file is missing."""
    candidate = checks_dir / slug / viewport / name
    if not candidate.exists():
        return ""
    return f"{slug}/{viewport}/{name}"


def viewport_snapshot(checks_dir: Path, slug: str, viewport: str, row: dict, screens: dict) -> dict:
    """Build one viewport entry for the report JSON snapshot."""
    screen = screens.get(viewport, {})
    return {
        "viewport": viewport,
        "name": screen.get("attributes", {}).get("name", viewport),
        "dimensions": viewport_dimensions(screen),
        "iteration": int(row.get("iteration", 0) or 0),
        "diff_percent": row.get("diff_percent", ""),
        "status": row.get("status", ""),
        "base_image": image_rel_path(checks_dir, slug, viewport, ReportConstants.BASE_IMAGE),
        "elementor_image": image_rel_path(checks_dir, slug, viewport, ReportConstants.ELEMENTOR_IMAGE),
        "diff_image": image_rel_path(checks_dir, slug, viewport, ReportConstants.DIFF_IMAGE),
    }


def page_viewports(rows: list[dict[str, str]], checks_dir: Path, screens: dict, slug: str) -> list[dict]:
    """Return the latest viewport snapshots for one page."""
    latest = latest_rows(rows)
    viewports = []
    for (row_slug, viewport), row in latest.items():
        if row_slug != slug or viewport == TrackingConstants.CLONE_VIEWPORT:
            continue
        viewports.append(viewport_snapshot(checks_dir, slug, viewport, row, screens))
    return sorted(viewports, key=lambda vp: vp["viewport"])


def page_snapshot(slug: str, rows: list[dict[str, str]], checks_dir: Path, screens: dict) -> dict:
    """Build one page entry for the report JSON snapshot."""
    first = rows[0]
    return {
        "page_slug": slug,
        "elementor_slug": first.get("elementor_slug", slug),
        "old_slug": first.get("old_slug", ""),
        "base_url": first.get("base_url", ""),
        "elementor_url": first.get("elementor_url", ""),
        "page_type": first.get("page_type", ""),
        "backup_old_id": first.get("backup_old_id", ""),
        "viewports": page_viewports(rows, checks_dir, screens, slug),
    }


def group_rows_by_page(rows: list[dict[str, str]]) -> dict[str, list[dict[str, str]]]:
    """Group tracking rows by page_slug, preserving first-seen order."""
    grouped: dict[str, list[dict[str, str]]] = {}
    for row in rows:
        grouped.setdefault(row.get("page_slug", ""), []).append(row)
    return grouped


def build_snapshot(csv_path: str, checks_dir: Path) -> dict:
    """Build the full report JSON snapshot from tracking.csv + checks/."""
    rows = read_rows(csv_path)
    screens = load_screens()
    grouped = group_rows_by_page(rows)
    pages = [page_snapshot(slug, page_rows, checks_dir, screens) for slug, page_rows in grouped.items()]
    return {
        "generated_at": datetime.now(timezone.utc).strftime(ReportConstants.TIMESTAMP_FORMAT),
        "csv_path": csv_path,
        "pages": pages,
    }


def render_report(template_path: Path, snapshot: dict) -> str:
    """Inject the JSON snapshot + timestamp into the HTML template."""
    template = template_path.read_text(encoding=ReportConstants.ENCODING_UTF8)
    rendered = template.replace(ReportConstants.SNAPSHOT_TOKEN, json.dumps(snapshot, indent=2))
    return rendered.replace(ReportConstants.GENERATED_AT_TOKEN, snapshot["generated_at"])


def resolve_template(template_arg: str) -> Path:
    """Resolve the template path (CLI value, else next to this script)."""
    candidate = Path(template_arg)
    if candidate.exists():
        return candidate
    sibling = Path(__file__).resolve().parent / template_arg
    return sibling


def build_report(csv_path: str, checks_dir: str, template_path: str) -> Path:
    """Generate checks/report.html and return its path."""
    checks = Path(checks_dir)
    checks.mkdir(parents=True, exist_ok=True)
    snapshot = build_snapshot(csv_path, checks)
    output = checks / ReportConstants.REPORT_FILE
    output.write_text(render_report(resolve_template(template_path), snapshot), encoding=ReportConstants.ENCODING_UTF8)
    return output


def build_parser() -> argparse.ArgumentParser:
    """Build the CLI parser for report-builder.py."""
    parser = argparse.ArgumentParser(description="Build checks/report.html from checks/tracking.csv")
    parser.add_argument("--csv", default=ReportConstants.TRACKING_CSV, help="Tracking CSV path")
    parser.add_argument("--checks-dir", default=ReportConstants.CHECKS_DIR, help="Checks folder")
    parser.add_argument("--template", default=ReportConstants.TEMPLATE_FILE, help="HTML template path")
    return parser


def main(argv: Optional[list[str]] = None) -> int:
    """CLI entry point: build the HTML comparison report."""
    args = build_parser().parse_args(argv)
    output = build_report(args.csv, args.checks_dir, args.template)
    print(f"Report written to: {output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

Contract — `scripts/report_builder.py` regenerates `checks/report.html` from `checks/tracking.csv` plus the images in `checks/<page-slug>/<viewport-id>/`, after every iteration and at task end:
- Output is a single self-contained HTML file that opens locally with no server and no backend.
- Per page: base vs Elementor screenshots side by side for every viewport, with diff %, iteration, status, and links to the base and Elementor URLs.
- Per (page, viewport) row: an issue selector (viewport picker + free-text issue box) and a COPY button. The button builds the structured report block below and copies it with `navigator.clipboard`, falling back to a textarea selection when clipboard access is unavailable:
  ```text
  Elementor issue report
  Base: <base_url> (slug: <base_slug>)
  Elementor: <elementor_url> (slug: <elementor_slug>)
  Screen: <viewport_id> <width>x<height>
  Iteration: <NNN> | Diff: <x.xx>%
  Issue: <user text>
  ```
- The user pastes that block back to the AI; the AI resumes from that exact (page, viewport, iteration).
- `checks/report.html` is committed to Git.


Reference HTML template `checks/report.html` (also kept at `02-spec/21-app/102-elementor-prompt-enhancement/artifacts/comparison-report.html`):

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Elementor comparison report</title>
<style>
  :root { color-scheme: light; }
  * { box-sizing: border-box; }
  body { margin: 0; font-family: system-ui, -apple-system, "Segoe UI", sans-serif; color: #1c2333; background: #f4f6f9; line-height: 1.45; }
  header { background: #16213a; color: #fff; padding: 20px 24px 16px; }
  header h1 { margin: 0 0 6px; font-size: 22px; }
  header p { margin: 4px 0; color: #c6d2e8; font-size: 14px; }
  header a { color: #9ec5ff; }
  nav#page-nav { margin-top: 12px; display: flex; flex-wrap: wrap; gap: 8px; }
  nav#page-nav a { background: #24365c; color: #fff; text-decoration: none; padding: 5px 10px; border-radius: 20px; font-size: 13px; }
  .filters { margin-top: 14px; display: flex; gap: 8px; align-items: center; font-size: 13px; }
  .filters button { border: 1px solid #4a5f8a; background: transparent; color: #fff; padding: 5px 12px; border-radius: 20px; cursor: pointer; font-size: 13px; }
  .filters button.active { background: #fff; color: #16213a; border-color: #fff; }
  main { max-width: 1240px; margin: 0 auto; padding: 20px 16px 48px; }
  section.page { background: #fff; border: 1px solid #d8dee9; border-radius: 10px; padding: 18px 20px; margin-bottom: 24px; }
  section.page h2 { margin: 0 0 4px; font-size: 19px; }
  section.page h2 .type { font-size: 12px; background: #eef2f8; border: 1px solid #d8dee9; border-radius: 4px; padding: 2px 6px; color: #52627d; vertical-align: middle; margin-left: 6px; }
  .page-links { font-size: 13px; color: #52627d; margin: 6px 0 14px; overflow-wrap: anywhere; }
  .page-links a { color: #1d5fd6; }
  .page-links code { background: #eef2f8; padding: 1px 5px; border-radius: 4px; font-size: 12px; }
  .viewport-card { border: 1px solid #d8dee9; border-radius: 8px; padding: 14px; margin-bottom: 16px; }
  .viewport-head { display: flex; flex-wrap: wrap; gap: 8px; align-items: center; margin-bottom: 10px; }
  .viewport-head h3 { margin: 0; font-size: 15px; }
  .badge { font-size: 12px; font-weight: 700; padding: 2px 8px; border-radius: 20px; text-transform: uppercase; }
  .badge.pass { background: #dcf5e3; color: #14663a; }
  .badge.fail { background: #fde3e3; color: #9c1f1f; }
  .badge.in_progress { background: #fff3cd; color: #7a5b00; }
  .badge.reverted { background: #e6e8ec; color: #4b5563; }
  .badge.backup_created { background: #dde9ff; color: #1d4fa3; }
  .meta { font-size: 13px; color: #52627d; }
  .images { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; }
  @media (max-width: 760px) { .images { grid-template-columns: 1fr; } }
  figure { margin: 0; }
  figure figcaption { font-size: 12px; font-weight: 700; color: #52627d; margin-bottom: 4px; text-transform: uppercase; letter-spacing: 0.04em; }
  figure img { width: 100%; display: block; border: 1px solid #d8dee9; border-radius: 6px; background: #fff; }
  .missing { border: 1px dashed #b7c1d3; border-radius: 6px; background: #f4f6f9; color: #52627d; font-size: 13px; padding: 18px 12px; text-align: center; overflow-wrap: anywhere; }
  .issue { margin-top: 12px; border-top: 1px solid #e6eaf1; padding-top: 12px; }
  .issue label { display: block; font-size: 13px; font-weight: 700; margin-bottom: 4px; }
  .issue select, .issue textarea { width: 100%; font: inherit; font-size: 14px; padding: 8px; border: 1px solid #b7c1d3; border-radius: 6px; background: #fff; color: inherit; }
  .issue textarea { min-height: 64px; resize: vertical; margin-top: 8px; }
  .issue-row { display: flex; gap: 8px; margin-top: 10px; align-items: center; }
  .copy-btn { background: #1d5fd6; color: #fff; border: none; padding: 9px 18px; border-radius: 6px; font-size: 14px; font-weight: 700; cursor: pointer; }
  .copy-btn:hover { background: #184eb2; }
  .copied { font-size: 13px; color: #14663a; font-weight: 700; }
  #empty-state { background: #fff; border: 1px solid #d8dee9; border-radius: 10px; padding: 28px 22px; text-align: center; color: #52627d; }
  footer { text-align: center; color: #7a879c; font-size: 12px; padding: 0 16px 28px; }
</style>
</head>
<body>
<header>
  <h1>Elementor comparison report</h1>
  <p>Generated: <span id="generated-at">{{GENERATED_AT}}</span> &middot; Source: <code>checks/tracking.csv</code></p>
  <p>Open this file locally (double-click). No server needed. For any viewport that looks wrong, pick the screen, describe the issue, press COPY, and paste the block back to the AI.</p>
  <nav id="page-nav" aria-label="Pages"></nav>
  <div class="filters" role="group" aria-label="Filter by status">
    <span>Show:</span>
    <button type="button" data-filter="all" class="active">All</button>
    <button type="button" data-filter="pass">Pass</button>
    <button type="button" data-filter="fail">Fail</button>
  </div>
</header>
<main id="report"></main>
<div id="empty-state" hidden>
  <h2>No tracking rows yet</h2>
  <p>This report is empty because <code>checks/tracking.csv</code> has no rows. Run the loop once (clone, capture, compare) and regenerate with <code>scripts/report_builder.py</code>.</p>
</div>
<footer>Elementor fine-tune loop &middot; spec 102 &middot; 100% accurate means every viewport at or below 0.5% diff.</footer>

<script id="tracking-snapshot" type="application/json">{{TRACKING_SNAPSHOT_JSON}}</script>
<script>
(function () {
  "use strict";

  function loadSnapshot() {
    var node = document.getElementById("tracking-snapshot");
    if (!node) { return { pages: [] }; }
    try {
      var parsed = JSON.parse(node.textContent);
      if (parsed && Array.isArray(parsed.pages)) { return parsed; }
    } catch (err) { /* fall through to the empty snapshot */ }
    return { pages: [] };
  }

  function el(tag, className, text) {
    var node = document.createElement(tag);
    if (className) { node.className = className; }
    if (text !== undefined && text !== null) { node.textContent = text; }
    return node;
  }

  function link(href, text) {
    var anchor = document.createElement("a");
    anchor.href = href;
    anchor.target = "_blank";
    anchor.rel = "noopener";
    anchor.textContent = text;
    return anchor;
  }

  function badge(status) {
    return el("span", "badge " + status, status.replace("_", " "));
  }

  function imageFigure(label, src) {
    var figure = document.createElement("figure");
    figure.appendChild(el("figcaption", null, label));
    if (!src) {
      figure.appendChild(el("div", "missing", "Image not available yet"));
      return figure;
    }
    var img = document.createElement("img");
    img.loading = "lazy";
    img.alt = label;
    img.src = src;
    img.addEventListener("error", function () {
      var box = el("div", "missing", "Image not available: " + src);
      img.replaceWith(box);
    });
    figure.appendChild(img);
    return figure;
  }

  function buildReportBlock(page, viewport) {
    var screen = viewport.dimensions ? viewport.viewport + " " + viewport.dimensions : viewport.viewport;
    var issue = viewport.issueInput ? viewport.issueInput.value : "";
    var lines = [
      "Elementor issue report",
      "Base: " + page.base_url + " (slug: " + page.page_slug + ")",
      "Elementor: " + page.elementor_url + " (slug: " + page.elementor_slug + ")",
      "Screen: " + screen,
      "Iteration: " + viewport.iteration + " | Diff: " + viewport.diff_percent + "%",
      "Issue: " + issue
    ];
    return lines.join("\n");
  }

  function copyText(text, button, note) {
    function done() {
      note.textContent = "Copied";
      button.disabled = true;
      setTimeout(function () { note.textContent = ""; button.disabled = false; }, 2500);
    }
    function textareaFallback() {
      var ta = document.createElement("textarea");
      ta.value = text;
      ta.style.position = "fixed";
      ta.style.opacity = "0";
      document.body.appendChild(ta);
      ta.select();
      try { document.execCommand("copy"); done(); }
      catch (err) { note.textContent = "Copy failed — select the text manually"; }
      document.body.removeChild(ta);
    }
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done, textareaFallback);
    } else {
      textareaFallback();
    }
  }

  function viewportCard(page, viewport) {
    var card = el("article", "viewport-card");
    card.dataset.status = viewport.status || "";
    card.dataset.viewport = viewport.viewport;

    var head = el("div", "viewport-head");
    head.appendChild(el("h3", null, viewport.name + " (" + viewport.viewport + ")"));
    head.appendChild(badge(viewport.status || "in_progress"));
    var dims = viewport.dimensions ? viewport.dimensions : "";
    var metaText = "Iteration " + viewport.iteration + "  |  Diff " + viewport.diff_percent + "%" + (dims ? "  |  " + dims : "");
    head.appendChild(el("span", "meta", metaText));
    card.appendChild(head);

    var images = el("div", "images");
    images.appendChild(imageFigure("Base", viewport.base_image));
    images.appendChild(imageFigure("Elementor", viewport.elementor_image));
    images.appendChild(imageFigure("Diff", viewport.diff_image));
    card.appendChild(images);

    var issue = el("div", "issue");
    issue.appendChild(el("label", null, "Report an issue on this screen"));
    var select = document.createElement("select");
    select.setAttribute("aria-label", "Screen with the issue");
    page.viewports.forEach(function (vp) {
      var option = document.createElement("option");
      option.value = vp.viewport;
      option.textContent = vp.name + " (" + vp.viewport + ")" + (vp.dimensions ? " " + vp.dimensions : "");
      if (vp.viewport === viewport.viewport) { option.selected = true; }
      select.appendChild(option);
    });
    issue.appendChild(select);
    var textarea = document.createElement("textarea");
    textarea.placeholder = "Describe what is wrong on this screen (for example: hero heading sits 24px too low on mobile)";
    textarea.setAttribute("aria-label", "Issue description");
    issue.appendChild(textarea);

    var row = el("div", "issue-row");
    var button = el("button", "copy-btn", "COPY issue report");
    button.type = "button";
    var note = el("span", "copied", "");
    button.addEventListener("click", function () {
      var chosenId = select.value;
      var chosen = page.viewports.find(function (vp) { return vp.viewport === chosenId; }) || viewport;
      var chosenWithIssue = {
        viewport: chosen.viewport,
        dimensions: chosen.dimensions,
        iteration: chosen.iteration,
        diff_percent: chosen.diff_percent,
        issueInput: textarea
      };
      copyText(buildReportBlock(page, chosenWithIssue), button, note);
    });
    row.appendChild(button);
    row.appendChild(note);
    issue.appendChild(row);
    card.appendChild(issue);
    return card;
  }

  function pageSection(page) {
    var section = el("section", "page");
    section.id = "page-" + page.page_slug;
    var heading = el("h2", null, page.page_slug);
    heading.appendChild(el("span", "type", page.page_type || "page"));
    section.appendChild(heading);

    var links = el("p", "page-links");
    links.appendChild(document.createTextNode("Base: "));
    links.appendChild(link(page.base_url, page.base_url));
    links.appendChild(document.createTextNode("  |  Elementor: "));
    links.appendChild(link(page.elementor_url, page.elementor_url));
    if (page.old_slug) {
      links.appendChild(document.createTextNode("  |  Backup clone: "));
      links.appendChild(el("code", null, page.old_slug));
      if (page.backup_old_id) {
        links.appendChild(document.createTextNode(" (id " + page.backup_old_id + ")"));
      }
    }
    section.appendChild(links);

    if (!page.viewports || page.viewports.length === 0) {
      section.appendChild(el("p", "meta", "No viewport comparisons recorded yet for this page."));
      return section;
    }
    page.viewports.forEach(function (viewport) {
      section.appendChild(viewportCard(page, viewport));
    });
    return section;
  }

  function render(snapshot) {
    var report = document.getElementById("report");
    var nav = document.getElementById("page-nav");
    var empty = document.getElementById("empty-state");
    var generated = document.getElementById("generated-at");
    if (snapshot.generated_at) { generated.textContent = snapshot.generated_at; }
    if (!snapshot.pages || snapshot.pages.length === 0) {
      empty.hidden = false;
      return;
    }
    empty.hidden = true;
    snapshot.pages.forEach(function (page) {
      var navLink = link("#page-" + page.page_slug, page.page_slug);
      nav.appendChild(navLink);
      report.appendChild(pageSection(page));
    });
  }

  function applyFilter(status) {
    document.querySelectorAll(".filters button").forEach(function (btn) {
      btn.classList.toggle("active", btn.dataset.filter === status);
    });
    document.querySelectorAll(".viewport-card").forEach(function (card) {
      var show = status === "all" || card.dataset.status === status;
      card.hidden = !show;
    });
    document.querySelectorAll("section.page").forEach(function (section) {
      var visible = section.querySelectorAll(".viewport-card:not([hidden])").length;
      var hasNote = section.querySelectorAll(".viewport-card").length === 0;
      section.hidden = !hasNote && visible === 0;
    });
  }

  document.querySelectorAll(".filters button").forEach(function (btn) {
    btn.addEventListener("click", function () { applyFilter(btn.dataset.filter); });
  });

  render(loadSnapshot());
})();
</script>
</body>
</html>
```
---

### 4.13 Verified WordPress Backend Session Authentication Engine (`scripts/wp_session_auth.py`)

```python
#!/usr/bin/env python3
"""
wp_session_auth.py — WordPress Backend Session Authentication & Bot-Bypass Engine.
Authenticates against /wp-login.php using persistent requests.Session, extracts
wpApiSettings REST nonce from /wp-admin/, and verifies administrator privileges.
"""
from __future__ import annotations

import os
import re
import sys
from dataclasses import dataclass
from typing import Final, Optional
import requests

BROWSER_UA: Final[str] = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
)

DEFAULT_HEADERS: Final[dict[str, str]] = {
    "User-Agent": BROWSER_UA,
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
}

NONCE_PATTERN: Final[re.Pattern[str]] = re.compile(r'"nonce":"([a-f0-9]{10})"')


@dataclass(frozen=True)
class AuthSession:
    session: requests.Session
    base_url: str
    nonce: str
    username: str
    is_admin: bool


def create_browser_session() -> requests.Session:
    session = requests.Session()
    session.headers.update(DEFAULT_HEADERS)
    return session


def fetch_test_cookie(session: requests.Session, base_url: str) -> None:
    login_url = f"{base_url.rstrip('/')}/wp-login.php"
    session.get(login_url, timeout=30)


def post_login_form(session: requests.Session, base_url: str, user: str, pwd: str) -> requests.Response:
    login_url = f"{base_url.rstrip('/')}/wp-login.php"
    payload = {
        "log": user,
        "pwd": pwd,
        "wp-submit": "Log In",
        "redirect_to": f"{base_url.rstrip('/')}/wp-admin/",
        "testcookie": "1",
    }
    return session.post(login_url, data=payload, allow_redirects=True, timeout=30)


def extract_rest_nonce(session: requests.Session, base_url: str) -> str:
    admin_url = f"{base_url.rstrip('/')}/wp-admin/"
    resp = session.get(admin_url, timeout=30)
    match = NONCE_PATTERN.search(resp.text)
    if not match:
        raise RuntimeError("Failed to extract wpApiSettings nonce from /wp-admin/")
    return match.group(1)


def verify_admin_privileges(session: requests.Session, base_url: str, nonce: str) -> bool:
    endpoint = f"{base_url.rstrip('/')}/wp-json/wp/v2/users/me?context=edit"
    resp = session.get(endpoint, headers={"X-WP-Nonce": nonce}, timeout=30)
    if resp.status_code != 200:
        return False
    data = resp.json()
    roles = data.get("roles", [])
    return "administrator" in roles


def authenticate_wordpress(base_url: str, user: str, pwd: str) -> AuthSession:
    session = create_browser_session()
    fetch_test_cookie(session, base_url)
    post_login_form(session, base_url, user, pwd)
    nonce = extract_rest_nonce(session, base_url)
    is_admin = verify_admin_privileges(session, base_url, nonce)
    if not is_admin:
        raise PermissionError(f"User '{user}' does not have administrator role.")
    print(f"✅ Backend Login Confirmed: Successfully authenticated to {base_url} as administrator.")
    return AuthSession(session=session, base_url=base_url, nonce=nonce, username=user, is_admin=is_admin)


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: wp_session_auth.py <base_url> <username> <password>")
        sys.exit(1)
    auth = authenticate_wordpress(sys.argv[1], sys.argv[2], sys.argv[3])
    print(f"Nonce: {auth.nonce}, Admin: {auth.is_admin}")
```


---

### 4.14 Discrepancy Logger & Progress Telemetry Engine (`scripts/discrepancy_logger.py`)

```python
#!/usr/bin/env python3
"""
discrepancy_logger.py — Discrepancy Markdown Planner & Progress Telemetry Engine.
Logs per-visit visual differences and planned Python AST/CSS remedies into
checks/<slug>/discrepancies.md, and emits periodic 5-10 min progress telemetry.
"""
from __future__ import annotations

import os
from datetime import datetime
from pathlib import Path
from typing import Any, Dict, List


def emit_progress_telemetry(
    page_slug: str,
    iteration: int,
    max_iterations: int,
    passed_viewports: int,
    total_viewports: int,
    best_match_score: float,
    active_action: str,
) -> None:
    """Emit concise 1-2 line status update for live monitoring."""
    now_str = datetime.now().strftime("%H:%M:%S")
    msg = (
        f"[{now_str}] ⏳ Loop Progress: Page '{page_slug}' | "
        f"Iteration {iteration}/{max_iterations} | "
        f"{passed_viewports}/{total_viewports} viewports passed | "
        f"Best Match: {best_match_score:.1f}% | "
        f"Active: {active_action}"
    )
    print(msg, flush=True)


def log_discrepancy_plan(
    page_slug: str,
    iteration: int,
    discrepancies: List[Dict[str, Any]],
    planned_fixes: List[Dict[str, Any]],
) -> Path:
    """Write per-visit visual gaps and planned Elementor AST/CSS fixes to discrepancies.md."""
    target_dir = Path("checks") / page_slug
    target_dir.mkdir(parents=True, exist_ok=True)
    comp_dir = Path("comparisons") / page_slug
    comp_dir.mkdir(parents=True, exist_ok=True)

    lines = [
        f"# Visual Discrepancy & Remediation Plan: `{page_slug}`",
        "",
        f"- **Page Slug:** `{page_slug}`",
        f"- **Iteration:** `{iteration}`",
        f"- **Generated At:** `{datetime.now().isoformat()}`",
        "",
        "## 1. Discrepancy Inventory per Viewport",
    ]

    for d in discrepancies:
        lines.append(f"- **{d.get('viewport', 'Screen')}**: {d.get('description', 'Diff detected')} (Deviation: {d.get('diff_percent', 0.0):.2f}%)")

    lines.extend([
        "",
        "## 2. Planned Remediation Actions (Python Script & CSS Changes)",
    ])

    for f in planned_fixes:
        lines.append(f"- **Target Element:** `{f.get('element_id', 'container')}`")
        lines.append(f"  - **Elementor AST Property:** `{f.get('property', 'setting')}` -> `{f.get('value', 'val')}`")
        if f.get("css_rule"):
            lines.append(f"  - **Scoped CSS Rule:** `{f.get('css_rule')}`")

    lines.extend([
        "",
        "## 3. Elementor Modifiability Guarantee",
        "- All planned modifications map directly to native Elementor Flexbox container controls, widget settings, or Elementor custom CSS.",
        "- Zero raw HTML hacks outside of Elementor AST `_elementor_data`.",
        "",
    ])

    content = "
".join(lines)
    for p in [target_dir / "discrepancies.md", comp_dir / "discrepancies.md"]:
        with open(p, "w", encoding="utf-8", newline="
") as fp:
            fp.write(content)

    print(f"📝 Discrepancy plan written to: {target_dir / 'discrepancies.md'}")
    return target_dir / "discrepancies.md"
```


---

## 🏆 5. 100/100 Evaluation Rubric

| Criterion | Points | Verification Standard |
| :--- | :---: | :--- |
| **Prerequisites Gate** | 10 | Explicit confirmation of Python prompt and WP actions prompt learning (50 steps). |
| **URL & Scope Ingestion** | 10 | Operator explicitly asked for and provided both original and target website URLs. |
| **2x Base64 SQLite Credential Vault** | 10 | Credentials encoded 2x Base64 in `data/config.db`; automatically reused once 1st is successful. |
| **Local Filesystem CSS & Backups** | 10 | CSS saved in `css/`; post/single page backups saved in `backups/<site>/<page>/before/` & `after/`. |
| **Multi-Screen Matrix (`screens.json`)** | 10 | Complete JSON schema defining 6+ viewport sizes (Desktop, Tablet V/H, Mobile Landing/Tab/Landscape). |
| **Iterative Comparison Loop (100–300)** | 10 | Active loop running up to 300 iterations, computing pixel-by-pixel visual diffs until 100% fidelity. |
| **Zero Git Bloat & Screenshot Rotation** | 10 | `.gitignore` active; previous turn screenshots automatically purged each iteration. |
| **AI Memory & Struggle Point RCA** | 5 | Complete retrospective documented in `.ai-memory/` recording struggles, root causes, and solutions. |
| **Clone-Backup (`<slug>-old`)** | 10 | Clone created before first mutation (title `<Title> - Old`, slug `<slug>-old`, `draft`); id + slug in `checks/tracking.csv` + `backups.json`; original modified in place, slug unchanged; revert order followed. |
| **Public Visibility** | 5 | Working page `status == "publish"` asserted by fresh `GET` after every mutation; new pages created `publish`; `-old` clone + draft backup stay `draft`. |
| **CSV Tracking & HTML Report** | 10 | `checks/tracking.csv` append-only, one row per (page, viewport, iteration); `checks/<slug>/<viewport>/` latest triple kept; `checks/report.html` regenerated every iteration with side-by-side views, issue selector, and a working COPY button. |
| **Total** | **100** | **Ready for autonomous copy-paste execution anywhere.** |

---

## 👥 6. Operator Interrogation & Dual-Site Parameters Contract

Before executing any network requests or modifying Elementor widgets, the AI MUST explicitly query the user in the following exact format:

```text
================================================================================
FORMAT FOR ASKING TO THE OPERATOR (COPY-PASTE READY)
================================================================================
Base Website URL:
Base Website Username:
Base Website Password:

Elementor Website URL:
Elementor Website Username:
Elementor Website Password:

Can you log into the admin panel? (yes/no):
================================================================================
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
   - **Invariant:** Target of modifications. The AI MUST create an isolated draft backup (`<Title> - Backup [Timestamp]`) recorded in `backups.json` AND a filesystem snapshot in `backups/<site_slug>/<page_slug>-<page_id>/before/` BEFORE modifying any post, page, or postmeta. After every mutation the AI asserts the working page is public (`status == "publish"` by fresh `GET`, fixing up with a `POST` if needed) — see directive 11. The `<slug>-old` clone and the draft backup stay `draft`.
3. **2-Times Base64 Credential Storage & Reuse Flow:**
   - On the first successful connection to the sites, the credentials are encoded 2-times using Base64 with strongly-typed `EncodingConstants`:
     `encoded = base64.b64encode(base64.b64encode(raw_password.encode(EncodingConstants.UTF8))).decode(EncodingConstants.ASCII)`
   - Saved into local SQLite database `data/config.db` in table `Credentials`.
   - On all future loops, iterations, and subsequent pages, credentials are automatically loaded from `data/config.db` without repeatedly prompting the user.

### Slug Default & Homepage Rule:
- If the operator provides no page/post slug, the AI starts with the homepage first — resolved via the front-page setting (`page_on_front` / `show_on_front`), falling back to the page with slug `home`, then to the site root URL `/`. If resolution fails, the AI halts and asks the operator; it never guesses a slug.
- The loop then runs to 100% (every viewport ≤ 0.5% diff) on the homepage before moving to the next page, fixing only through the Python REST scripts (see directive 12).
