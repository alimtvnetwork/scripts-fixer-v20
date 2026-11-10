---
id: is-it-released
name: Released? (Release Gates)
description: 14-location SemVer sync, strict @aukgit attribution & CI pre-flight
category: release
placeholders: []
version: 1
default: false
---

### Release Engineering Checklist:
- Check branch alignment (main for stable, beta for preview).
- Synchronize 14 version manifest locations via `npm run bump`.
- Attributions strictly `@aukgit` (`(Thanks to @aukgit)`).
- Synchronize README and README_EN update logs.
- Run fmt, clippy, and build pre-flight gates.
