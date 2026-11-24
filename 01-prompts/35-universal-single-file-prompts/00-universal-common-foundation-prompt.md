# Universal Common Foundation & Execution Standards — Master Sovereign Prompt

Official Authoritative References & Technical Standards:
• Python Any Task Prerequisite Gist:
  https://gist.githubusercontent.com/alimtvnetwork/fd0953a5f2bfbbc91ae6e3666c5f7c37/raw/b573e3d2cd164d74350bee9c77ccc3b608250333/python-any-task-prompt.md
• WordPress Modernizing Master Prompt Gist:
  https://gist.githubusercontent.com/alimtvnetwork/11900295ef222d921bd646923fbcff3d/raw/957bb2b806d2bb6dae45f5d8f17c5fdefbe5aa55/universal-wp-modernizing-master-prompt.md
• Elementor Pixel-Perfect Loop Master Prompt Gist:
  https://gist.githubusercontent.com/alimtvnetwork/9ee32e9568d0afc4ee4c49c86bedb9e8/raw/elementor-modify-pixel-perfect-loop.md
• Universal AI Memory Folder Structure Prompt Gist:
  https://gist.githubusercontent.com/alimtvnetwork/faa0881913e4029b36951828418f5316/raw/07-universal-ai-memory-folder-structure-prompt.md
• PEP 8 – Style Guide for Python Code: https://peps.python.org/pep-0008/
• SQLite Documentation & DDL Standards: https://www.sqlite.org/lang.html

Prompt Version: 1.0.0 (Master Sovereign Foundation Edition — 100% Sovereign Portability)
Target Audience: Autonomous AI Agents (Antigravity, Cursor, Claude, ChatGPT, Muse), Full-Stack Systems Engineers, QA Automation Leads
Task Slug: universal-common-foundation / common-execution-standards
Portability Contract: This prompt serves as the master shared architectural foundation for all autonomous AI tasks, multi-agent swarms, and domain-specific execution prompts. Specialized prompts (Python, WordPress, Elementor) inherit from this standard, eliminating duplicate boilerplate across the ecosystem.

```text
================================================================================
           AUTONOMOUS EXECUTION BUDGET & SWARM TOPOLOGY (V6/V7 RULES)
================================================================================
N = 400 (Total self-loop steps budget — default: 400)
A = 3   (MANDATORY number of spawned autonomous subagents running concurrently, default: 3)
H = 2   (Operational hands per agent: dual-task batch capacity & parallel tool dispatch, default: 2)
C = 30  (Tool calls per worker before it must report, default: 30)

PHASE_1_BUDGET = 100     (Steps 1 .. 100: Planning, Discovery, Credential Vault, Dynamic $WORK & Scaffolding)
PHASE_2_BUDGET = 150     (Steps 101 .. 250: Core Execution, Modular Functions, Telemetry, Diffing & Invariants)
PHASE_3_BUDGET = 150     (Steps 251 .. 400: Iterative Tuning, Verification, Zero Git Bloat & Upstream Push)
================================================================================
```

---

## 🎯 1. Turn 1 Understood Showcase Protocol

Before executing any file modifications, network calls, or CLI commands, the autonomous AI agent **MUST OUTPUT** a comprehensive Turn 1 Showcase table demonstrating full comprehension across all 5 mandatory pillars:

1. **Pillar 1: Strategic Intent & Systems Reasoning:** Articulate overarching architectural goal, user intent, operational rationale, and systems integration mechanics.
2. **Pillar 2: Explicit Scope Boundaries:** Strict two-column partition defining In-Scope deliverables vs. strictly Excluded or Deferred items.
3. **Pillar 3: Non-Negotiable Constraints & Negative Guardrails:** Explicit recitation of active constraints: ban on raw searches, ban on git commands in subagents, ban on absolute paths, ban on CRLF, ban on magic strings, ban on snake_case database tables.
4. **Pillar 4: Blast Radius & Dependency Topology:** Map impacted subsystems, files, downstream callers, and prompt/skill indexes with risk containment strategies.
5. **Pillar 5: Multi-Agent Concurrency Topology:** Detail swarm structure (`A = 3`, `H = 2`, Capacity = 6), disjoint file assignments, and immediate dynamic respawn.

### Master Turn 1 Verification Schema
```markdown
| Dimension | Standard Specification | Target Verification |
| :--- | :--- | :--- |
| **Prerequisite Gate** | Common Foundation + Domain Gists | Confirmed studied & internalized (50 steps memory creation) |
| **Direct References** | Unwrapped Authoritative Gist URLs | Bare URLs confirmed without markdown wrapping |
| **Encoding Standard** | `EncodingConstants` (UTF-8, ASCII) | Zero raw string encoding literals; constants enforced |
| **Database Schema** | PascalCase Tables in SQLite | `Credentials`, `TaskExecutions`, `WpCredentials`, `PageBackups` |
| **SQL Encapsulation** | SQL Queries in Strongly-Typed Enums | Zero inline multi-line SQL strings inside function bodies |
| **JSON Standard** | GitMap `data` & `attributes` Pattern | Zero underscores in our JSON keys; lower camelCase |
| **Regex Compilation** | Thread-Safe `LazyRegex` Engine | Pattern cached on demand; zero repeated `re.compile()` |
| **OS Paths** | Dynamic Resolution via `OsPathConstants` | Zero hardcoded `C:\Windows\...`; dynamic functions & env vars |
| **Workspace Root** | Dynamic `$WORK` Resolution | Derived from `$WORK`, `$GITMAP_WORK_DIR`, or user prompt; 0 hardcoding |
| **Credential Vault** | 2-Stage Base64 SQLite (`data/config.db`) | Reused across loops once first connection succeeds |
| **Filesystem Backups**| `backups/<site>/<slug>/before/` & `after/` | Complete JSON, AST, HTML, CSS snapshots for instant revert |
| **Code Limits** | Functions $\le 15$ lines, Files $\le 200$ lines | 0 nested ifs, positive booleans `is*`/`has*`, monadic Result |
| **Git Hygiene** | Zero Git Bloat + Upstream Push | Screenshots, temp DBs, logs git-ignored; No Push = Not Done |
```

---

## 🔒 2. Character Encoding Hygiene & Constants Contract

Raw magic strings for character encodings (`"utf-8"`, `"ascii"`, `"utf-16"`, `"latin-1"`) are **STRICTLY FORBIDDEN** across all functions, scripts, and prompts.

### Reference Implementation: `EncodingConstants`
```python
from typing import Final


class EncodingConstants:
    """Standard character encoding format constants."""

    UTF8: Final[str] = "utf-8"
    ASCII: Final[str] = "ascii"
    UTF16: Final[str] = "utf-16"
    LATIN1: Final[str] = "latin-1"
```

### Usage Enforcement:
- Always use: `raw_bytes.decode(EncodingConstants.UTF8)`
- Always use: `raw_string.encode(EncodingConstants.ASCII)`
- Always use: `open(file_path, "r", encoding=EncodingConstants.UTF8)`
- Always use: `file_path.read_text(encoding=EncodingConstants.UTF8)`

---

## 🗄️ 3. PascalCase SQLite Tables & Strongly-Typed SQL Enums

### 3.1 PascalCase Table Naming Invariant (NON-NEGOTIABLE)
All SQLite tables across all repositories, prompts, and temporary databases **MUST BE PASCALCASE**. Snake_case table names (e.g. `task_executions`, `wp_credentials`, `page_backups`) are strictly banned.

```python
from enum import Enum
from typing import Final


class TableType(str, Enum):
    """PascalCase SQLite database table names."""

    CREDENTIALS = "Credentials"
    TASK_EXECUTIONS = "TaskExecutions"
    WP_CREDENTIALS = "WpCredentials"
    PAGE_BACKUPS = "PageBackups"
    AUDIT_LOGS = "AuditLogs"
    VISUAL_DIFFS = "VisualDiffs"


class TableConstants:
    """Immutable table name string constants."""

    CREDENTIALS: Final[str] = "Credentials"
    TASK_EXECUTIONS: Final[str] = "TaskExecutions"
    WP_CREDENTIALS: Final[str] = "WpCredentials"
    PAGE_BACKUPS: Final[str] = "PageBackups"
    AUDIT_LOGS: Final[str] = "AuditLogs"
    VISUAL_DIFFS: Final[str] = "VisualDiffs"
```

### 3.2 SQL Encapsulation in Strongly-Typed Enums
Raw multi-line SQL strings embedded inside business logic functions are **STRICTLY FORBIDDEN**. Every SQL DDL, DML, or query statement must be defined as an enum member:

```python
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


class TaskSqlType(str, Enum):
    """Encapsulated SQL statements for task execution audit data."""

    PRAGMA_BUSY_TIMEOUT = "PRAGMA busy_timeout = 5000"
    CREATE_TASKS_TABLE = (
        "CREATE TABLE IF NOT EXISTS TaskExecutions ("
        "taskId TEXT PRIMARY KEY, "
        "action TEXT NOT NULL, "
        "category TEXT NOT NULL, "
        "status TEXT NOT NULL, "
        "targetPath TEXT NOT NULL, "
        "itemsAffected INTEGER NOT NULL, "
        "durationSec REAL NOT NULL, "
        "executedAt TEXT NOT NULL"
        ")"
    )
    INSERT_TASK = (
        "INSERT INTO TaskExecutions ("
        "taskId, action, category, status, targetPath, itemsAffected, durationSec, executedAt"
        ") VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
    )
    SELECT_ALL_RECENT = (
        "SELECT taskId, action, category, status, targetPath, itemsAffected, durationSec, executedAt "
        "FROM TaskExecutions ORDER BY executedAt DESC LIMIT ?"
    )
```

---

## 📂 4. Dynamic Operating System Paths Resolution (`OsPathConstants`)

Hardcoding operating system paths (such as `r"C:\Windows\Temp"`, `r"C:\Windows\Prefetch"`, `r"C:\Windows\Minidump"`) is **STRICTLY FORBIDDEN**.
All temporary, cache, and diagnostic paths must be dynamically resolved at runtime via standard Python OS functions (`tempfile.gettempdir()`) and environment variables (`SystemRoot`, `WINDIR`) with full POSIX compatibility:

```python
import os
import tempfile
from pathlib import Path


def _resolve_system_root() -> Path:
    if os.name == "nt":
        root_str = os.environ.get("SystemRoot") or os.environ.get("WINDIR") or "C:\\Windows"
        return Path(root_str)
    return Path("/")


def _resolve_windows_temp() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Temp"
    return Path("/tmp")


def _resolve_user_temp() -> Path:
    return Path(tempfile.gettempdir())


def _resolve_prefetch() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Prefetch"
    return _resolve_user_temp() / "prefetch"


def _resolve_crash_dumps() -> Path:
    if os.name == "nt":
        return _resolve_system_root() / "Minidump"
    var_crash = Path("/var/crash")
    return var_crash if var_crash.exists() else _resolve_user_temp()


class OsPathConstants:
    """Standard operating system and directory cache paths resolved dynamically."""

    DEFAULT_LOGS_DIR = "logs"
    DEFAULT_LOG_FILE = "logs/task.log"
    DEFAULT_SUMMARY_FILE = "logs/taskSummary.json"

    @classmethod
    def get_system_root(cls) -> Path:
        """Resolve OS system root directory dynamically across Windows and POSIX."""
        return _resolve_system_root()

    @classmethod
    def get_windows_temp(cls) -> Path:
        """Resolve system temporary directory dynamically."""
        return _resolve_windows_temp()

    @classmethod
    def get_user_temp(cls) -> Path:
        """Resolve user temporary directory using standard tempfile OS function."""
        return _resolve_user_temp()

    @classmethod
    def get_prefetch(cls) -> Path:
        """Resolve Windows prefetch directory dynamically."""
        return _resolve_prefetch()

    @classmethod
    def get_crash_dumps(cls) -> Path:
        """Resolve system crash dumps / minidump directory dynamically."""
        return _resolve_crash_dumps()

    # Dynamic class-level string properties evaluated at module load
    WINDOWS_TEMP = str(_resolve_windows_temp())
    USER_TEMP = str(_resolve_user_temp())
    PREFETCH = str(_resolve_prefetch())
    CRASH_DUMPS = str(_resolve_crash_dumps())
```

---

## 📋 5. GitMap JSON Standards: Zero Underscores & `data`/`attributes` Pattern

### 5.1 Non-Negotiable Contract
- **TOTAL BAN ON UNDERSCORES (`_`)**: In all JSON property names generated, saved, or configured by our code.
- **Mandatory Lower camelCase**: All JSON property keys must be lower camelCase (`taskId`, `isEnabled`, `modulePath`, `className`, `durationSec`, `targetPath`).
- **GitMap `data` & `attributes` Envelope Pattern**: Top-level JSON payloads must encapsulate identity, type, and properties inside `data` and `attributes`:

#### Single Entity Envelope:
```json
{
  "data": {
    "id": "pipelineConfig01",
    "type": "pipelineConfiguration",
    "attributes": {
      "pipelineName": "Universal Task Execution Pipeline",
      "version": "1.0.0",
      "configDir": "config",
      "steps": []
    }
  }
}
```

#### Step / Item Collection Envelope:
```json
{
  "id": "step01CacheCleanup",
  "type": "pipelineStep",
  "attributes": {
    "modulePath": "scripts.steps.sample_fix_step",
    "className": "SampleFixStep",
    "isEnabled": true,
    "description": "Purge system temporary files and verify memory",
    "params": {
      "targetPath": "${WORK}/logs",
      "isDryRun": false
    }
  }
}
```

### 5.2 External Protocol Scope Boundary (WordPress REST Exception)
WordPress core REST endpoints (`/wp/v2/pages`, `/wp/v2/posts`) utilize third-party WordPress protocol fields (`_elementor_data`, `post_title`, `post_content`, `post_status`). These are external WordPress core properties and cannot be changed when communicating with WordPress endpoints. However, all configuration files (`pipeline.json`), output reports (`taskSummary.json`), viewports manifests (`screens.json`), and local ledgers (`backups.json`) authored or owned by our code MUST strictly adhere to zero underscores, lower camelCase, and the GitMap `data`/`attributes` envelope.

---

## 📁 6. Canonical Project Directory Architecture

```text
XX-<slug>/
├── config/
│   ├── env.ini             # Cross-platform environment variables
│   └── pipeline.json       # Pluggable pipeline steps (GitMap data & attributes envelope)
├── data/                   # Git-ignored local databases
│   └── config.db           # SQLite credential vault (PascalCase tables)
├── logs/                   # Structured execution logs
│   ├── task.log            # ANSI-stripped line log
│   └── taskSummary.json    # JSON execution report (GitMap data & attributes envelope)
├── backups/                # Before/After snapshots (<site>/<slug>/before/ & after/)
├── css/                    # Benchmarked & tuned CSS files
├── scripts/                # Modular Python scripts (functions <= 15 lines)
│   ├── core_constants.py   # OsPathConstants, EncodingConstants, LazyRegex
│   ├── core_enums.py       # ActionType, ExitCodeType, TaskSqlType
│   ├── pipeline_engine.py  # Pluggable step runner
│   └── cli_dispatcher.py   # Main CLI entry point
└── tests/                  # Unit tests (100% pass)
```

---

## ⚡ 7. Thread-Safe Lazy Regular Expression Engine

Direct calls to `re.compile()`, `re.match()`, `re.search()`, or `re.sub()` scattered across scripts or tight loops are **STRICTLY FORBIDDEN**. Regular expressions must be compiled on demand and cached thread-safely:

```python
import re
from typing import ClassVar, Pattern


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
```

---

## 🌐 8. Dynamic Cross-Platform $WORK Directory Resolution

### 5.1 Zero Hardcoded Paths Invariant
Hardcoding absolute paths (e.g. `D:\work`, `D:\work\gitmap`, `/work`, `/home/user/work`) is **STRICTLY FORBIDDEN**.
Paths must be dynamically discovered using the following cascade:
1. Environment variable `$WORK` (if set and directory exists).
2. Fallback environment variable `$GITMAP_WORK_DIR` (if set and directory exists).
3. Parent repository root (e.g. `(cwd / "..")` if `.git` exists).
4. Interactive user prompt (if running in interactive terminal: `"Please enter your WORK workspace directory path:"`).

### 5.2 Reference Implementation: `config/env.ini`
```ini
# --- Universal Environment Variables Configuration (config/env.ini) ---
# Dynamic path expansion: Never hardcode absolute paths!
# Resolved at runtime from $WORK, fallback $GITMAP_WORK_DIR, or interactive operator prompt.
work=${WORK}
workdir=${WORK}/${PROJECT_SLUG}
root=${WORK}
logs=${WORK}/${PROJECT_SLUG}/logs
```

### 5.3 Survives OS Restart & On-The-Fly Mutation
- **PowerShell (`run.ps1`):** Configures Windows User Registry via `[System.Environment]::SetEnvironmentVariable("WORK", $workDir, "User")` and appends `if ($env:WORK) { $global:WORK = $env:WORK }` to `$PROFILE` so `cd $WORK` works with the dollar sign.
- **POSIX Shell (`run.sh`):** Exports `WORK` and persists `export WORK="$WORK"` in `~/.bashrc` and `~/.zshrc`.
- **On-the-Fly Command:** Supports `-SetEnv "KEY=VALUE"` / `--set-env KEY=VALUE` which simultaneously writes to `config/env.ini`, updates `os.environ`, and persists to OS user environment across reboots.

---

## 🔐 9. 2-Stage Base64 SQLite Credential Vault Contract

Credentials provided by the operator (URLs, usernames, application passwords) must be safeguarded:
1. **Location:** `data/config.db` (SQLite database).
2. **Table:** PascalCase `Credentials`.
3. **Encoding:** Must be encoded **2 times** using Base64:
   ```python
   def encode_password_2x(raw_password: str) -> str:
       """Encode password twice using Base64."""
       pass_1 = base64.b64encode(raw_password.encode(EncodingConstants.UTF8)).decode(EncodingConstants.ASCII)
       pass_2 = base64.b64encode(pass_1.encode(EncodingConstants.UTF8)).decode(EncodingConstants.ASCII)
       return pass_2

   def decode_password_2x(encoded_password: str) -> str:
       """Decode password twice using Base64."""
       pass_1 = base64.b64decode(encoded_password.encode(EncodingConstants.ASCII)).decode(EncodingConstants.UTF8)
       raw_password = base64.b64decode(pass_1.encode(EncodingConstants.ASCII)).decode(EncodingConstants.UTF8)
       return raw_password
   ```
4. **Autonomous Loop Reuse:** Once the first connection succeeds, credentials are stored in `data/config.db`. All subsequent loops, iterations, and subagents load from `data/config.db` without prompting the user again.
5. **Security Isolation:** `data/` and `data/config.db` **MUST BE ADDED TO `.gitignore`**.

---

## 💾 10. Local Filesystem Snapshot & Rollback Architecture

Before mutating any remote or local resource (post, page, file, stylesheet, database row):
1. **Directory Structure:**
   ```text
   backups/<site_slug>/<resource_slug>-<id>/
   ├── before/
   │   ├── payload.json       # Complete REST payload / AST data
   │   ├── rendered.html      # DOM snapshot before mutation
   │   └── style.css          # Extracted CSS before mutation
   └── after/
       ├── payload.json       # Mutated REST payload / AST data
       ├── rendered.html      # Post-mutation DOM snapshot
       └── style.css          # Injected/modified CSS
   ```
2. **Instant Rollback:** If any verification step or screenshot diff fails tolerance, the AI reverts to `before/` in seconds via REST API or filesystem copy.
3. **Local CSS Persistence:** All benchmark and tuned CSS must be persisted to `css/` (`base-site.css`, `target-current.css`, `target-modified.css`).

---

## 🧹 11. Zero Git Bloat & Completion Invariant

1. **Mandatory `.gitignore` Entries:**
   ```gitignore
   data/
   data/config.db
   screenshots/
   logs/*.log
   temp/
   __pycache__/
   *.pyc
   ```
2. **Pragmatic Commits:** Commit using structured semantic verbs (`git commit -m "Feature: MODULE - summary"` or `gitmap cpf "MODULE - summary"`).
3. **Upstream Push Invariant:** Every code change must be pushed upstream to the remote tracking branch.
   **No Push = Not Done.**
