---
name: visibility-from-pasted-urls
description: >-
  Implement gitmap make-private and make-public --from so a pasted GitHub dump,
  Markdown file, or JSON file sets those repos private or public. Use when the
  user asks to bulk-change visibility from URLs, a paste, Markdown, or JSON.
---

# Visibility from pasted URLs

Read `.ai-memory/plans/pending/102-visibility-from-pasted-urls.md` and then the four files in `.ai-memory/plans/subtasks/102-visibility-from-pasted-urls/` in numeric order. That plan is the contract. Do not invent a second command or a second JSON shape.

Before editing, open and follow these skills. The invocations are mandatory:

- `@[gitmap](directory;.agents/skills/gitmap)` and `@[gitmap](directory;.cursor/skills/gitmap)`
- `@[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6)` and `@[execute-parent-task-with-n-steps-v6](directory;.cursor/skills/execute-parent-task-with-n-steps-v6)`
- Canonical prompt: `01-prompts/14-execute/02-execute-parent-task-with-n-steps-v6.md`
- `.cursor/skills/read-memory-enhanced/skill.md`
- `02-spec/17-consolidated-guidelines/34-compiled-simple-coding-guidelines.md`
- `cli/cmdvisibility/visibility.go`
- `cli/cmdvisibility/visibilityapplyone.go`

Apply these rules while implementing:

- `--from <path>` on `make-private` and `make-public` is the whole feature.
- `--from -` reads stdin.
- Titles, blank lines, and one-segment profile URLs are skipped.
- A URL next to a "Page not found" title is still a repo URL.
- Duplicates collapse to the first `owner/repo`.
- Call `applyOneRepo`. Do not call `mustResolveVisibilityContext` on the `--from` path.
- `make-public` confirms once unless `--yes` is set. `make-private` does not confirm.
- Put the same examples in `cli/helpdoc/make-private.md`, `cli/helpdoc/make-public.md`, and `src/data/commands.ts`.
- Verify with `go test ./cli/cmdvisibility/ -count=1 -run "TestParseVisibility"` only.
