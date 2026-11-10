---
id: refactor-dry
name: Refactor DRY (Deduplication & Clean Helpers)
description: Pattern deduplication, clean helper extraction & zero logic drift
category: architecture
placeholders: []
version: 1
default: false
---

### Code DRYness & Architectural Hygiene:
- Identify repeated logic blocks across modules and extract shared helpers.
- Eliminate redundant slice wrappers using variadic / spread patterns.
- Preserve original business logic, comments, and docstrings.
- Verify zero functional regression after extraction.
