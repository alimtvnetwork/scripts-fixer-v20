---
name: universal-elementor-finetune-pixel-perfect-loop
description: >-
  Autonomously fine-tune, audit, and achieve 100% pixel-perfect accuracy for Elementor and WordPress pages across multiple viewports via RSA SQLite credential vault (scripts/rsa_credential_vault.py) with on-demand decryption and retrieval every time needed, menu-first checks, CSS source allocation & color grouping, single-page default with quick match fast-forward, strict ban on !important and page-class specificity targeting, strictly unsupervised zero-pause continuous 100-300 iteration comparison loops, periodic 5-10 min progress telemetry, per-visit discrepancy MD planning, Elementor-native modifiable AST architecture, Clone-Before-Modify (-old) public backups, line-by-line copy-paste credential ingestion, immediate backend login confirmation, and default homepage fallback.
---

# Universal Elementor Fine-Tune & Pixel-Perfect Screen Comparison

> **Invocation:** `@[universal-elementor-finetune-pixel-perfect-loop](directory;.agents/skills/universal-elementor-finetune-pixel-perfect-loop)`

## Mission & Purpose
This skill provides authoritative architectural guidance, code navigation, and execution rules for:
1. **Mandatory Dual-Prerequisite Gate:** Confirm learning and memory internalization of the Python Task Automation Prompt and WordPress Actions Prompt (50 steps each) before modifying code.
2. **RSA SQLite Credential Vault Engine (`scripts/rsa_credential_vault.py`):** Passwords for both reference base site and target Elementor site are encrypted using RSA public key, stored in SQLite `data/config.db` in PascalCase table `Credentials`, and autonomously decrypted on demand using RSA private key every time needed across loops without repeatedly prompting the user.
3. **Menu-First Invariant (First Technical Job):** The AI must first inspect, compare, and fix the navigation menu (header, logo, links, mobile hamburger drawer, sticky offset) to 100% parity across all viewports before touching any page body content.
4. **CSS Source Allocation & Theme Builder Color Grouping:** Trace missing visual lines, borders, divider SVGs, and background accents to their origin (Theme Builder `elementor_library` templates vs section containers vs global kit `elementor_active_kit`). Group styles by semantic color tokens within that section or template.
5. **Single-Page Default vs. Loop All Modes & Quick Match Fast-Forward:** Focus on ONE single page (homepage first) and report back to the developer with the comparison report, unless explicitly instructed `loop all`. If visual similarity >= 99.5%, immediately announce Quick Match and advance autonomously to the next page.
6. **Strict Ban on `!important` & Page-Class Specificity Targeting:** Strictly avoid `!important` in CSS overrides. Elevate specificity cleanly using WordPress body classes: `body.page-id-<ID> .target-class` or `body.home .target-class`. Use `scripts/page_css_manager.py` for scoped rule injection.
7. **Strictly Unsupervised Autonomous Loop:** Run completely without human supervision; NEVER pause to ask "Want me to start now or wait until you're back?", "Should I proceed?", or wait for loop approvals. Operators submit prompts and sleep ("in the morning I should check all"); the AI begins comparisons and fine-tuning immediately on Step 1.
8. **Periodic 5–10 Min Progress Telemetry:** Output concise 1–2 line status updates every 5 to 10 minutes so operators monitoring logs know work is actively progressing.
9. **Per-Visit Markdown Discrepancy & Remediation Plan:** Log all visual differences and planned Python AST/CSS remedies to `checks/<slug>/discrepancies.md` (and `comparisons/<slug>/discrepancies.md`) before mutating.
10. **Elementor-Modifiable Invariant:** Every modification must map natively to Elementor Flexbox Containers, native widgets, style controls, or Elementor custom CSS so the page remains 100% visually editable in Elementor.
11. **Line-by-Line Copy-Paste Credential Ingestion:** Operator queried using single-segment line-by-line format with username, password, URLs, and admin panel login confirmation (`Can you log into the admin panel? (yes/no):`).
12. **Immediate Backend Login Confirmation Invariant:** Right after receiving credentials, the AI immediately tests `/wp-login.php`, verifies `/wp-admin/` Dashboard, confirms administrator privileges via `/wp-json/wp/v2/users/me?context=edit`, and confirms immediately to the operator before touching any pages.
13. **Bot-Challenge Bypass & Persistent Session Auth:** Uses Python `requests.Session()` with realistic modern browser headers, form login to `/wp-login.php`, and `X-WP-Nonce` extracted from `/wp-admin/` HTML. Total ban on raw curl with default UA and HTTP Basic Auth with account passwords.
14. **Clone-Before-Modify (`<slug>-old`) & In-Place Mutation Mindset:** Always clone the target page/post to `<slug>-old` with title `<Title> - Backup [Old]` before modifying the canonical slug in place.
15. **100% Public Invariant:** Both the modified canonical page and the clone backup MUST have `status: "publish"`. Total ban on draft/private statuses.
16. **Multi-Viewport Screen Matrix (`screens.json`):** Standardized coverage across viewports (Desktop Extra-Wide 1920px, Desktop Standard 1440px, Laptop 1024px, Tablet Portrait 768px, Mobile Standard 375px, Mobile Large 414px).
17. **Side-by-Side Comparison:** Compare Base Reference, -old Backup, Current Modified, and Difference Heatmap side by side for all screens.
18. **Master CSV Tracking Ledger:** Track all pages, viewports, URLs, match scores, and screenshot paths in `checks/tracking.csv` / `comparisons/comparison_ledger.csv`.
19. **Interactive Local HTML Presentation Viewer:** Generate `checks/report.html` / `comparisons/comparison_report.html` featuring a 4-column side-by-side grid and a 📋 "Copy Issue Report" button that copies a pre-formatted Markdown issue docket to clipboard.
20. **100 to 300 Iteration Continuous Feedback Loop:** Headless screenshot capture, pixel-by-pixel Pillow diffing, difference heatmaps, root-cause diagnosis, targeted CSS/AST adjustments, and browser re-verification until 100% visual parity.
21. **Sleepy Autopilot & Ambiguity Routing:** When operator signals sleepiness ("I'm a bit sleepy. Try to take the best decision possible"), proceed autonomously picking the best sensible default, recording ambiguities to `.ai-memory/ambiguity/` without interrupting the operator.
22. **Screenshot Hygiene & Git Ignore:** Screenshots stored in `screenshots/` and `comparisons/**` strictly excluded via `.gitignore`; previous turn screenshots purged at iteration $K+1$.
23. **AI Memory & 4-Part RCA Logging:** Record struggle points, root causes, and concrete remediation steps in `.ai-memory/` for future agents.

---

## Canonical Documentation & Reference Prompt
- **Master Standalone Execution Prompt:** [06-universal-elementor-finetune-pixel-perfect-loop-prompt.md](file:///d:/work/gitmap/01-prompts/35-universal-single-file-prompts/06-universal-elementor-finetune-pixel-perfect-loop-prompt.md)
- **Verbatim Gist Source:** [elementor-modify-pixel-perfect-loop.md](file:///d:/work/gitmap/01-prompts/35-universal-single-file-prompts/elementor-modify-pixel-perfect-loop.md)
- **WordPress Modification Category:** [02-universal-elementor-finetune-pixel-perfect-loop-prompt.md](file:///d:/work/gitmap/01-prompts/34-wordpress-modification/02-universal-elementor-finetune-pixel-perfect-loop-prompt.md)
