# Project Overview

## Identity

**Name:** Dev Tools Setup
**Version:** v0.36.0
**Type:** PowerShell automation toolkit + React documentation site (placeholder)
**Platform:** Windows 10/11

## What It Does

Automated installer and configurator for developer tools on Windows. 43 PowerShell scripts covering:
- Dev tools (VS Code, Node.js, Python, Go, Git, C++, PHP, PowerShell, Flutter, .NET, Java)
- Databases (MySQL, MariaDB, PostgreSQL, SQLite, MongoDB, CouchDB, Redis, Cassandra, Neo4j, Elasticsearch, DuckDB, LiteDB)
- AI tools (Ollama, llama.cpp with 81-model GGUF catalog)
- Utilities (context menus, settings sync, Windows tweaks, DBeaver, Notepad++, OBS, Windows Terminal)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Scripts | PowerShell 5.1+ / PowerShell 7+ |
| Package manager | Chocolatey (primary), Winget (secondary) |
| Web app | React 18 + Vite 5 + Tailwind CSS v3 + TypeScript 5 |
| Config format | JSON (config.json + log-messages.json per script) |

## Key Directories

| Path | Purpose |
|------|---------|
| `scripts/` | All 43 install scripts (numbered folders) |
| `scripts/shared/` | Shared PowerShell helper modules |
| `02-spec/` | Specification docs per script |
| `settings/` | App config presets (NPP, OBS, WT, DBeaver) |
| `.ai-memory/` | AI context, memory, plan, prompts |
| `.installed/` | Tool install tracking (gitignored) |
| `.resolved/` | Runtime state persistence (gitignored) |
| `.logs/` | Script execution logs (gitignored) |
| `src/` | React web app source |

## Navigation Map

- **Plan:** `.ai-memory/plan.md`
- **Memory index:** `.ai-memory/memory/index.md`
- **Suggestions:** `.ai-memory/suggestions.md`
- **Strictly avoid:** `.ai-memory/strictly-avoid.md`
- **Prompts:** `01-prompts/`
- **Script registry:** `scripts/registry.json`
- **Version:** `scripts/version.json`
- **Changelog:** `changelog.md`
