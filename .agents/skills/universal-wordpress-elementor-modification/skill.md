---
name: universal-wordpress-elementor-modification
description: >-
  Autonomously modernize, fix, and convert WordPress websites and pages into native Elementor JSON component structures. Enforces Python prompt prerequisite gate, differentiates WordPress user passwords from Application Passwords (recommending App Passwords), supports isolated temp SQLite database credential storage (%TEMP%/gitmap/wp_credentials.db) via SQL Repository Pattern and RSA-OAEP asymmetric encryption for JSON storage, pre-flight draft backup invariants in backups.json (<title> - Backup [Timestamp]), pluggable function and step injection via pipeline.json and ITransformStep protocol, in-memory caching wrapper (FileSystemCache), component-scoped CSS builder (ScopedCssBuilder) using selector keyword, mandatory AI documentation header contract, visual screenshot diff auditing (assets/), and site-specific isolation under sites/<domain_slug>/.
---

# Universal WordPress & Elementor Modification

When an autonomous AI agent is tasked with modernizing, fixing, or converting WordPress pages:

0. **Mandatory Python Task Prerequisite Check:** Before taking any modifying action or creating files, the AI **MUST ASSERT** that the Universal Python Task Automation engine has been executed (`01-prompts/33-universal-python-task/01-universal-python-task-automation-prompt.md`). If uninitialized, the AI **MUST HALT IMMEDIATELY** and state verbatim:
   > **"Please run the Python prompt first and then the WordPress prompt."**
1. **Never mutate a live page blindly:** The AI **MUST ALWAYS** create an isolated draft backup via the WordPress REST API (`<title> - Backup [YYYY-MM-DD HH:mm:ss]`) before applying any modifications.
2. **Password Taxonomy & Credential Security:** The secret can be provided as a standard **WordPress password** (master dashboard password) or an **Application Password**. Both are distinct. The AI **STRONGLY RECOMMENDS** using the Application Password for REST API operations. Credentials must never be committed to Git. The primary recommended store is an isolated SQLite database in the OS temp directory (`%TEMP%/gitmap/wp_credentials.db`). If saving to JSON (`wp-credentials.json`), asymmetric **RSA-OAEP with SHA-256** encryption is mandatory with local private key held in `~/.ssh/wp_rsa`.
3. **Pluggable Function & Step Injection Pipeline:** All AST transformations, widget additions, and CSS mutations must be modularized into stackable classes implementing `ITransformStep` inside `scripts/transformations/<step_slug>.py` and loaded dynamically via `pipeline.json` and `PipelineWrapper`. The core CLI dispatcher is never directly polluted with task-specific transformation code.
4. **In-Memory File Caching (`FileSystemCache`):** Assets, ASTs, and configs are read through `FileSystemCache`, which invalidates cache entries automatically using file `stat().st_mtime_ns` and SHA-256 freshness tracking.
5. **Structured Elementor Conversion:** Convert existing HTML, mockups, or legacy widgets into native Elementor JSON structures (`_elementor_data`) using best-fit components (Container, Heading, Text Editor, Button, Image, Icon Box).
6. **Hierarchical Lowercase IDs & Scoped CSS:** Assign semantic, lowercase, hyphen-separated IDs (`settings._element_id`) from top-level wrappers (`#hero-section`) down to nested elements (`#hero-cta-btn`), apply BEM classes (`settings._css_classes`), and inject scoped styles (`settings.custom_css`) using `ScopedCssBuilder` with the `selector` keyword (zero global leakage).
7. **Mandatory AI Documentation Header Contract:** Every custom transformation step file authored by an AI must include a standardized header specifying `USER REQUEST`, `PURPOSE`, `PROCESS`, and a verifiable `CHECKLIST`.
8. **Visual Screenshot Diff Verification:** Capture before and after screenshots of the live site, compare against design mockups, calculate layout differences, and iteratively refine CSS.
9. **Task-Scoped Python Execution Engine:** All operations are executed via modular Python scripts housed in `XX-<slug>/` with cross-platform launchers (`run.ps1` and `run.sh`).
10. **Site-Specific Isolation:** Store site-specific logic under `sites/<domain_slug>/` while general reusable API functions reside in `scripts/`.

## Task Folder Topology

```text
<workspace_root>/
└── XX-<slug>/                    # E.g. 02-homepage-elementor-conversion
    ├── run.ps1                   # Windows PowerShell launcher
    ├── run.sh                    # Linux/macOS POSIX launcher
    ├── pipeline.json             # JSON transformation pipeline specification
    ├── readme.md                 # Elementor mapping history, page IDs modified, diff metrics
    ├── what-to-read.md           # Site credentials status, theme hierarchy, backup links
    ├── wp-credentials.json       # RSA-OAEP encrypted credential store (.gitignore enforced)
    ├── backups.json              # Registry of pre-flight draft page backups
    ├── conversation/             # Turn-by-turn prompt & response traces
    │   └── XX-<slug>.md
    ├── assets/                   # Visual verification screenshots & diff artifacts
    │   ├── before-render.png
    │   ├── target-mockup.png
    │   ├── after-render.png
    │   └── visual-diff.png
    ├── sites/                    # Website-specific configuration & transpilation
    │   └── <domain_slug>/
    │       ├── site_config.json
    │       └── page_builder.py
    └── scripts/                  # Reusable WordPress REST & Elementor API engine
        ├── core_enums.py         # Elementor widget types, post statuses, exit codes
        ├── wp_auth_crypto.py     # RSA-OAEP asymmetric encryption & key management
        ├── wp_credential_repo.py # Isolated temp SQLite credential repository
        ├── wp_auth.py            # Connection probe and authentication dispatcher
        ├── wp_rest_client.py     # Pages/posts CRUD, safe draft backups
        ├── elementor_schema.py   # Elementor JSON data structures & widget models
        ├── transform_protocol.py # ITransformStep protocol, TransformContext, registry
        ├── pipeline_engine.py    # FileSystemCache & PipelineWrapper runner
        ├── css_engine.py         # ScopedCssBuilder & design token interpolator
        ├── transformations/      # Pluggable transformation step implementations
        │   └── hero_modernization.py
        ├── visual_diff.py        # Headless browser screenshot comparison
        └── cli_dispatcher.py     # Argparse CLI orchestrator with pipeline subcommand
```

## Password Types: WordPress Password vs. Application Password

| Attribute | WordPress User Password (Master) | Application Password (RECOMMENDED) |
| :--- | :--- | :--- |
| **Intended Purpose** | Browser dashboard login (`/wp-admin`) | REST API automation & headless scripts |
| **Generation Origin** | Initial user provisioning | WP Admin: **Users** -> **Profile** (WP 5.6+) |
| **Format** | User-selected string | 24-character key (`xxxx xxxx xxxx xxxx xxxx xxxx`) |
| **Scope & Blast Radius** | Full master account privileges across CMS | Scoped strictly to REST API; cannot access `/wp-admin` |
| **Revocation Safety** | Changing password disrupts browser sessions | Revocable independently with zero master account impact |
| **2FA / MFA** | Fails or blocked if 2FA/SSO plugin active | Bypasses 2FA natively in WordPress Core |
| **Recommendation** | **DISCOURAGED for API Automation** | **STRONGLY RECOMMENDED for All Operations** |

## Credential Storage Architecture

The AI must ask the user their preferred storage option:

### Option 1: (Recommended) Isolated Temp SQLite Database
- **Path:** `Path(tempfile.gettempdir()) / "gitmap" / "wp_credentials.db"`
- **Zero Git Risk:** Stored completely outside the repository working tree.
- **Contract:** SQL Repository Pattern (`IWpCredentialRepository`, `SqliteWpCredentialRepository`) with PascalCase `WpCredentials` table, camelCase columns, and positive booleans (`isActive`, `hasAppPassword`).

### Option 2: Local JSON Config with Asymmetric RSA-OAEP Encryption
If stored in `wp-credentials.json`, the secret **MUST** be encrypted via `RSA-OAEP-SHA256`:
- **Private Key:** Stored locally in `~/.ssh/wp_rsa` or `%TEMP%/gitmap/wp_rsa.pem` (never in Git).
- **JSON Schema:**
  ```json
  {
    "site_url": "https://example.com",
    "username": "automation_admin",
    "password_type": "app_password",
    "encryption": {
      "algorithm": "RSA-OAEP-SHA256",
      "key_size_bits": 2048,
      "key_fingerprint": "SHA256:7QmBhtDiW4znYv2nKGGRad...",
      "encrypted_password": "k8V...<base64_ciphertext>...=="
    },
    "created_at": "2026-11-18T12:00:00Z"
  }
  ```

## Pluggable Transformation Pipeline & Scoped CSS Engine

1. **Step Injection Contract:**
   All transformation steps implement `ITransformStep`:
   - `compile(context: TransformContext) -> Result[bool]`
   - `modify_ast(ast: dict[str, Any], context: TransformContext) -> Result[dict[str, Any]]`
   - `modify_css(existing_css: str, context: TransformContext) -> Result[str]`
   - `validate(ast: dict[str, Any]) -> Result[bool]`
2. **`pipeline.json` Execution:**
   The pipeline executes steps sequentially, wrapping each in monadic error gates. Dry-run mode (`--dry-run`) runs AST and CSS modifications in memory without dispatching network requests to WordPress.
3. **`ScopedCssBuilder` Enforcement:**
   All CSS rules must use Elementor's `selector` keyword to guarantee component encapsulation with zero global stylesheet leakage.
4. **AI Documentation Header Contract:**
   Every transformation step must begin with a structured header documenting `USER REQUEST`, `PURPOSE`, `PROCESS`, and `CHECKLIST`.

## Pre-Flight Draft Backup Invariant

Before modifying any post, page, or template:
1. `GET /wp-json/wp/v2/pages/<id>` retrieves current raw content and `_elementor_data`.
2. `POST /wp-json/wp/v2/pages` creates a complete duplicate draft with:
   - `title`: `<original_title> - Backup [YYYY-MM-DD HH:mm:ss]`
   - `status`: `draft`
   - `meta._elementor_data`: original elementor payload
3. The backup ID is recorded in `backups.json`.
4. Only upon HTTP 201 Created does the modification proceed.

## Terminal Display Standard & Left-Hand Padding Invariant

Every WordPress task runner must implement `scripts/terminal_ui.py` to produce readable, polished CLI output:
1. **2-Space Left Padding Invariant (`LEFT_PAD = "  "`):** All printed lines must maintain a minimum 2-space left margin to prevent text from sticking against the terminal borders.
2. **Hierarchical Box-Drawing Characters:** Unicode branches (`├──`, `│  `, `└──`) for structured display of target domains, page IDs, AST transformations, and visual diff percentages.
3. **Status Badges & Error Trees (Zero Swallowing):** Explicit bracketed badges (`[PASS]`, `[FAIL]`, `[BACKED-UP]`, `[DIFF-OK]`) and formatted error diagnostic trees.
