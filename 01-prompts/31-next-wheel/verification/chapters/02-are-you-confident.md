---
id: chapter-02-are-you-confident
name: Chapter 2 Are You Confident Checklist
description: Grounded verification matrix for the are-you-confident type.
category: verification-chapter
placeholders: []
version: 1
---

# 📊 CHAPTER 2: GROUNDED VERIFICATION MATRIX & ACTIONABLE CHECKLIST

### Chapter 2.3: 'Are You Confident?' Architectural & Code Quality Matrix
- [ ] **1. Compact Functions:** Are functions bounded to <= 15 lines of core logic with single responsibility?
- [ ] **2. Guard Clauses & Early Returns:** Are nested `if/else` structures flattened with guard returns and clean constructor returns?
- [ ] **3. Positive Boolean Polarity:** Are all boolean flags positive, implicit (`if (isReady)`), and free of double negatives (`!isDisabled`)?
- [ ] **4. Zero Silent Errors:** Does every catch block and error result route to the error store (`captureException`/`trackWarning`) or `AppError` (no bare `catch {}`)?
- [ ] **5. Vertical Rhythm:** Is vertical line spacing enforced (blank lines around blocks and before returns)?
- [ ] **6. Relative Paths:** Are all referenced file paths strictly repository-relative (`src/...`, `02-spec/...`) without absolute machine paths?
