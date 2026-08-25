# Ubuntu Profiles and CLI Architecture

This plan implements the `run` CLI for managing Ubuntu installations via grouped profiles (`ubuntu-basic`, `ubuntu+vscode`, `ubuntu+simple-dev`, `ubuntu-dev`) and individual package scripts, fulfilling the 50-step requirement.

## Context
- Command requested: `.\run install profile ubuntu+dev`
- Original spec inputs: `.lovable/spec/commands/01-run-cli.md`
- Release policy: One commit per batch. No per-task releases. Bump MINOR only when the ENTIRE plan is completed.
- Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.

## CI/CD verification
- Domain Cli maps to `linter-scripts/check-sh-syntax.sh`

## Attachments
- n/a
