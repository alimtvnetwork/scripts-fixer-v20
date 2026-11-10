---
id: next-wheel-actionable-plan
name: Plan Actionable Items
description: Non-negotiable checklist for the plan action.
category: next-wheel
placeholders: []
version: 1
---

# Actionable Items Must Follow Non-Negotiable

1. Git pull BEFORE starting any work — first try `gitmap pull <repo path>` (or run `gitmap pull` in repository folder); if that fails, fall back to regular `git pull` and resolve any merge conflicts so the repository is completely up to date and clean before starting.
2. Write spec under @[02-spec/21-app/XX-improvements/] and enqueue plan task in @[.ai-memory/plans/pending/XX-improvements.md] (subtasks in @[.ai-memory/plans/subtasks/XX-improvements/]) first.
3. Search codebase exclusively via GitMap (gitmap aum search, gitmap find, gitmap cat, gitmap ps, gitmap py, gitmap llm train); TOTAL BAN on rg, ripgrep, grep, git grep, Select-String.
4. Strictly use relative Git paths (02-spec/..., .ai-memory/..., cmd/...); never add absolute filesystem paths.
5. Improve as per directed.
6. Must follow non negociable - follow coding guidelines @[.agents/skills/follow-coding-guidelines/skill.md] and @[02-spec/02-coding-guidelines].
7. Must follow non negociable - @[02-spec/03-error-manage/readme.md] and @[02-spec/03-error-manage] proper to the letter.
