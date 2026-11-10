---
id: next-wheel-terminal-verification
name: Terminal Verification Gate
description: Terminal gate block appended when the final slot is reached.
category: next-wheel
placeholders: []
version: 1
---

## Terminal Verification Gate (End of Tunnel Reached)

You have reached the end of the tunnel. Full compilation, automated testing, and end-to-end verification are now MANDATORY:
1. Run compiler checks and build pipelines (`npm run build` / `cargo clippy --all-targets --all-features` / `go build ./...`).
2. Execute all local test suites to 100% green pass.
3. Verify E2E execution per @[execute-with-e2e](directory;.agents/skills/execute-with-e2e/skill.md) / `01-prompts/14-execute/08-execute-with-e2e.md`.
4. Conclude with an atomic GitMap commit and minor release ceremony.
