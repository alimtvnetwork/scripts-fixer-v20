---
id: rerun-schema
name: Rerun Messages & Template Schema Specification
description: Copy-AI-format schema prompt for generating rerun messages or templates in JSON or YAML.
category: rerun
placeholders: [nudge, insert, prompt, attachments, round, total]
version: 1
---

# Antigravity Manager (AGM) Rerun Messages & Template Schema Specification

Use this guide to generate new rerun messages or templates in JSON or YAML.

### Format 1: JSON Schema
```json
{
  "version": "1.0",
  "exported_at": "2026-11-04T10:00:00Z",
  "templates": [
    {
      "id": "discipline-code-hygiene",
      "name": "Discipline & Code Hygiene Check",
      "description": "Enforces strict coding standards, no-nesting, and RCA discipline",
      "template": "{nudge}\n\nCoding Directives:\n{insert}\n\n---\n{prompt}",
      "is_default": false
    }
  ]
}
```

### Format 2: YAML Schema
```yaml
# AGM Rerun Messages & Templates Schema v1.0
version: "1.0"
templates:
  - id: "ui-ux-fixes"
    name: "UI / UX Modernization Directives"
    description: "Enforces 4-plane depth, button hover palettes, and contrast"
    is_default: false
    template: |-
      {nudge}

      UI Directives:
      {insert}

      Original Prompt:
      {prompt}
```

### Supported Template Variable Placeholders
- `{nudge}`: The randomized or chosen nudge question (e.g. "Is it completed?")
- `{insert}`: The insert part text (e.g. Discipline prompt, UI guidelines, E2E check)
- `{prompt}`: The original task prompt text
- `{attachments}`: Staged screenshot / diagram image file references
- `{round}`: The current rerun iteration count (e.g. 1)
- `{total}`: Total number of scheduled reruns (e.g. 3)
