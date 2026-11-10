---
id: run-100-steps
name: 100 Steps (V6 parent task)
description: Break the prompt into 100+ sequential steps via execute-parent-task-with-n-steps-v6
category: architecture
placeholders: []
version: 1
default: false
---

Must follow and spawn agent using
[execute-parent-task-with-n-steps-v6](directory;.agents/skills/execute-parent-task-with-n-steps-v6)

Break the user request into 100+ sequential steps, execute them continuously, and do not stop until the task is done, tested, and released.
