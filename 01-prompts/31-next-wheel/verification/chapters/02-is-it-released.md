---
id: chapter-02-is-it-released
name: Chapter 2 Is It Released Checklist
description: Grounded verification matrix for the is-it-released type.
category: verification-chapter
placeholders: []
version: 1
---

# 📊 CHAPTER 2: GROUNDED VERIFICATION MATRIX & ACTIONABLE CHECKLIST

### Chapter 2.2: 'Is It Released?' Governance & Release Gate Matrix
- [ ] **1. Release Branch Separation:** Is the current branch strictly `main` (for official stable releases) or `beta` (for preview releases)?
- [ ] **2. 14-Location SemVer Sync:** Are all 14 project manifest version fields atomically updated via `npm run bump`?
- [ ] **3. Strict Attribution Invariant:** Are changelogs attributed strictly to `@aukgit` (`(Thanks to @aukgit)`) with ZERO other GitHub user handles (`@...`)?
- [ ] **4. README Synchronization:** Are both `README.md` (under "## 📝 Update log") and `README_EN.md` (under "## 📝 Changelog") update logs synchronized with the release notes?
- [ ] **5. Pre-flight Quality Gates:** Have `cd src-tauri && cargo fmt -- --check`, `cd src-tauri && cargo clippy --all-targets --all-features`, and `npm run build` all passed cleanly?
- [ ] **6. Git Tag Precision:** Does the git tag strictly match `CHANGELOG.md` heading character-for-character (`vX.Y.Z` on main, `vX.Y.Z-beta.N` on beta)?
- [ ] **7. Distribution Scripts:** Are `install.ps1` and `install.sh` verified for the target release?
- [ ] **8. Thinking Store Invalidation Toggle:** Is `SUGGESTION_DELETE_THINKING_STORE` correctly configured in `SuggestionDeleteThinkingModal.tsx`?
