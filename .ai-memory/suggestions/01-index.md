# Suggestions Master Index: 01-index.md

> **Updated:** 2026-09-13  
> **Status:** Synchronized Single Source of Truth  
> **Tracker File:** [`.ai-memory/suggestions.md`](../suggestions.md)

---

## 1. Active Suggestions

| Suggestion Title | Priority | Status | Cycle Added |
| :--- | :---: | :---: | :--- |
| Model catalog auto-update from Hugging Face | High | Pending | v0.26.0 cycle |
| SHA256 checksums in catalog | High | Pending | v0.26.0 cycle |
| Parallel model downloads via aria2c batch mode | High | Pending | v0.26.0 cycle |
| GUI/TUI interface for model picker | Medium | Pending | v0.26.0 cycle |
| Model benchmarking after download | Medium | Pending | v0.26.0 cycle |
| Model size estimation from parameter count | Medium | Pending | v0.26.0 cycle |
| Export/import model selections as preset files | Medium | Pending | v0.26.0 cycle |
| Model catalog web viewer | Medium | Pending | v0.26.0 cycle |
| Cross-machine settings sync via cloud storage | Low | Pending | v0.26.0 cycle |
| Linux/macOS support for install scripts (not just bootstrap) | Low | Pending | v0.26.0 cycle |
| Docker, Rust script additions | Low | Pending | v0.26.0 cycle |

---

## 2. Implemented Suggestions

| Suggestion Title | Version Implemented | Date | Notes |
| :--- | :---: | :---: | :--- |
| Bump probe range default 20 → 30 | v0.36.0 | 2026-04-18 | Increased discovery headroom in `install.ps1`/`install.sh` |
| `-Version` / `--version` diagnostic flag | v0.36.0 | 2026-04-18 | Added probe diagnostics without cloning |
| Always fresh-clone in bootstrap | v0.35.0 | 2026-04-18 | Replaced `git pull` with wipe + fresh clone |
| `models search <query>` — Ollama Hub live search | v0.34.0 | 2026-04-17 | Regex parser anchored on stable `x-test-*` markers |
| `models uninstall` orchestrator subcommand | v0.34.0 | 2026-04-17 | Multi-backend listing, multi-select, and deletion |
| Install bootstrap auto-discovery | v0.31.0 | 2026-04-17 | Parallel HEAD probes with redirect-loop guard |
| `scripts/models/` unified orchestrator | v0.32.0 | 2026-04-17 | Thin dispatcher delegating to `picker.ps1` |
| Speed-tier column + filter in model picker | v0.26.0 | 2026-04-16 | Instant/fast/moderate/slow speed tiers |
| RAM auto-detection filter | v0.26.0 | 2026-04-16 | WMI `Get-CimInstance` for RAM detection |
| Nginx Domain Manager with SQLite & INI Architecture | v1.27.0 | 2026-09-09 | Full CLI domain manager (`add`, `rm`, `list`, `ini`, `showcase`) with SQLite persistence |
