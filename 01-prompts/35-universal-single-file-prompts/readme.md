# Universal Standalone Single-File Prompts (`35-universal-single-file-prompts`)

> **Directory Version:** 1.0.0
> **Target Audience:** Developers, DevOps Engineers, AI Prompters, Autonomous Agents
> **Key Feature:** 100% Sovereign Single-File Prompts with Zero External Dependencies

---

## 📖 Overview & Purpose

This directory hosts the **all-in-one, standalone single-file editions** of the universal automation prompts. While Categories `33-universal-python-task` and `34-wordpress-modification` provide modular, multi-file workspace layouts with separate `code/` trees and test fixtures, this directory is specifically tailored for **direct human and AI copy-paste portability**.

Every file in this folder contains:
1. **The Complete Prompt Directives:** Master budgets, multi-agent quotas, mission objectives, and task-scoped topology.
2. **Full Embedded Production Code:** Verbatim source code for launchers (`run.ps1`, `run.sh`), Python error handlers (`app_errors.py` with `Result[T]` & `AppError`), strongly-typed enums (`core_enums.py`), constant classes (`core_constants.py`), dual-channel loggers (`task_logger.py`), modular handlers (`task_runner.py`), and CLI dispatchers (`cli_dispatcher.py`).
3. **Turn 1 Understood Showcase Protocol:** Standardized verification acknowledgment table.
4. **100/100 Evaluation Rubric:** Auditable quality gate and score matrix.

Anyone can open any `.md` file in this directory, click **Copy**, and paste it into GitHub Gists, GitLab Snippets, Cursor, Antigravity, Claude, ChatGPT, or a fresh machine—and it works immediately without cloning submodules or resolving local repository paths.

---

## 📑 Single-File Prompt Index

- [`00-universal-common-foundation-prompt.md`](00-universal-common-foundation-prompt.md) — Master Sovereign Foundation Edition. Establishes the core shared standards for all autonomous AI agents: character encoding hygiene (`EncodingConstants`), PascalCase SQLite database tables, SQL encapsulation in strongly-typed enums (`TaskSqlType`, `CredentialSqlType`), dynamic OS path resolution (`OsPathConstants`), GitMap JSON Standards (0 underscores, lower camelCase, `data`/`attributes` envelope), dynamic `$WORK` resolution, and 2-stage Base64 credential vault.
- [`01-universal-python-task-automation-prompt.md`](01-universal-python-task-automation-prompt.md) — Master Single-File Standalone Prompt for Python Task Automation. Covers Windows sound fixes, VMware network resets, WhatsApp/Electron cache cleaning, OS disk space optimization, package management, and background service automation. Contains complete embedded Python modules, monadic `Result[T]` error handling, SQL repository pattern (`ITaskRepository` & `SqliteTaskRepository`), and cross-platform launchers.
- [`02-universal-wordpress-elementor-modification-prompt.md`](02-universal-wordpress-elementor-modification-prompt.md) — Master Single-File Standalone Prompt for WordPress & Elementor Modernization. Covers 3-stage base64 credential security, pre-flight draft backup snapshots in `backups.json`, Elementor Flexbox container synthesis, Pillow visual diffing (`visual_diff.py`), and self-healing REST API error management.
- [`03-universal-binary-deployment-prompt.md`](03-universal-binary-deployment-prompt.md) — Master Single-File Standalone Prompt for Universal Binary Deployment & Public Distribution. Covers dynamic GitLab CLI identity discovery, parameterized variable repository naming (`<REPO_NAME>`), mandatory explicit public visibility (`--public`), unauthenticated raw `HTTP 200 OK` assertions, 10 GB repository rollover guard, multi-OS 7z LZMA2 chunking (`-v8m`/`-v5m`), and smart client installers (`install.ps1`, `install.sh`).
- [`04-developer-daily-master-prompt.md`](04-developer-daily-master-prompt.md) — Master Single-File Standalone Prompt for Developer Daily Work & AI Operation. Enforces deep codebase comprehension first, zero guideline hallucination, explanation and safety gates (Zero Harm), total ban on reading `.env` and credential files, and multi-platform AI registration via `03-ai-scripts/71-register-developer-master-prompt-as-copilot-skill.py`.
- [`05-universal-email-integration-prompt.md`](05-universal-email-integration-prompt.md) — Master Single-File Standalone Prompt for Universal Email Integration. Covers RFC 5321/5322/3501 standards, SMTP/IMAP/POP3 adapters, RSA-4096 OAEP credential security (`email-credentials.json`), Lemon background daemon, rate limiting, and email dispatchers.
- [`06-universal-elementor-finetune-pixel-perfect-loop-prompt.md`](06-universal-elementor-finetune-pixel-perfect-loop-prompt.md) — Master Single-File Standalone Prompt for Elementor Fine-Tuning & Pixel-Perfect Screen Comparison. Runs an autonomous 100–300 iteration feedback loop across 6–8 viewports (`screens.json`), headless Pillow visual diffing (`visual_diff.py`), REST API pre-flight draft backup snapshots (`backups.json`), screenshot rotation and Git ignore enforcement, and AI memory persistence.
- [`07-universal-ai-memory-folder-structure-prompt.md`](07-universal-ai-memory-folder-structure-prompt.md) — Master Single-File Standalone Prompt for Universal AI Memory Architecture & One-Shot Scaffolding Engine. Details the full canonical `.ai-memory/` hierarchy, index specifications (`what-to-read.md`, `strictly-avoid.md`, `README.md`, `folder-structure.md`, `coding-guidelines.md`), and embeds the dependency-free Python scaffolding engine (`scaffold_ai_memory.py`) to initialize memory environments in one shot.
- [`elementor-modify-pixel-perfect-loop.md`](elementor-modify-pixel-perfect-loop.md) — Raw verbatim GitHub Gist source prompt for rapid human copy-pasting.

---

## 🏛️ Multi-File vs. Single-File Structure

| Feature | Multi-File Editions (`33-` & `34-`) | Single-File Editions (`35-`) |
| :--- | :--- | :--- |
| **Primary Use Case** | Repository development, code modularity, shared testing | Direct copy-paste to external chat, gists, or remote IDEs |
| **Code Placement** | Split into `code/scripts/*.py` & `fixture/` | Embedded directly inside the `.md` file |
| **External Dependencies** | Depends on sibling files in workspace | **Zero** — 100% self-contained |
| **Launchers** | Standalone files (`run.ps1`, `run.sh`) | Fully included in Markdown code fences |
| **Scoring** | 100 / 100 | **100 / 100** |
