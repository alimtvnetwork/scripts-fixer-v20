---
id: test-and-coverage
name: Tests & Cov (Mock Isolation & Suites)
description: Targeted unit tests, mock isolation, error branch coverage & no OS mutation
category: testing
placeholders: []
version: 1
default: false
---

### Unit Testing & Mock Isolation:
- Run targeted unit tests for touched modules locally.
- Never execute real OS shutdown, reboot, or destructive system calls.
- Inject mock executors and verify mock call durations.
- Verify both happy-path and error-branch coverage.
