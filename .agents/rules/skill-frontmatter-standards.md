---
description: Enforces mandatory YAML frontmatter on all skill files to prevent Antigravity customization loader failures.
trigger: always_on
---

# Skill File YAML Frontmatter Standards & Validation (RCA-32)

Whenever creating, modifying, or refactoring any Antigravity or Cursor skill file (`.agents/skills/*/skill.md`, `.cursor/skills/*/skill.md`), you MUST strictly adhere to the following frontmatter standard. Failing to include valid YAML frontmatter causes Google Antigravity to crash-load the customization and emit `Skill skill.md invalid frontmatter format`.

## 1. Mandatory Schema Contract
1. **Line 1 Opening Fence:** The very first line of every skill file MUST be exactly `---` (no leading whitespace, no comments, no markdown title before it).
2. **Mandatory `name` Field:** Must define `name: <skill-name>` matching kebab-case lowercase identifiers. Never name a skill `skill.md`.
3. **Mandatory `description` Field:** Must define `description: >-` containing a clear explanation of what the skill does and when the agent should activate it.
4. **Closing Fence:** Must close with `---` followed by a single empty line before the `# <Title>` markdown header.

```markdown
---
name: my-feature-skill
description: >-
  Describe what the skill does and when to activate it.
---

# My Feature Skill
...
```

## 2. Pre-Commit Validation Rule
Before completing any task that touches skill files, run the automated validator:
```bash
python 03-ai-scripts/53-skill-frontmatter-validator.py
```
Exit code 0 is mandatory.
