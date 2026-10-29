# Recent session — 2026-10-29

This note records what was created and shipped on 2026-10-29. Paths below are relative git paths.

## go-email-reader

- Specifications for warm-up sequences 08 through 13 are in `02-spec/21-app/08-ui-and-warm-up-algorithm-improvements/` through `02-spec/21-app/13-ui-and-warm-up-algorithm-improvements/`.
- Plans are in `.ai-memory/plans/pending/08-ui-and-warm-up-algorithm-improvements.md` through `.ai-memory/plans/pending/13-ui-and-warm-up-algorithm-improvements.md`.
- Sequence 08 is the connector and gate map. Sequence 09 is brakes. Sequence 10 is the send lease and cool-down. Sequence 11 is the shadow compare. Sequence 12 is the pace envelope. Sequence 13 is the shared quiet window.
- The live tick now consults `internal/warmup/gatefeed.go`. A peer can tighten the remaining-send cap and cannot raise it. An absent or stale peer does not stop local warm-up. Local quiet hours hold. A quiet skip does not send. A dry run does not spend the cap. The gate order is health, cadence, connector, theme.
- The reader UI gate map reads `GET /api/warmup/gates`.
- Commit `f3864ee` is on `main` and is pushed. The remote uses SSH.
- Sequences 08 through 13 stay pending as catalogs. Only the gate engine is implemented.
- `user.email` is `local@gitmap`. The name is `gitmap automation`.

## gitmap-v28

- Cursor-like IDE setup landed in `cli/cmdide/ide_setup.go`, `cli/cmdide/setup/`, and `cli/cmdui/ui_server_ide_setup.go`.
- The spec is `02-spec/21-app/352-cursor-like-ide-setup-from-gitmap/`.
- Pushed commits include `3229df9b4`, `864012968`, and `04690b952`.
- `cli/cov` is a coverage profile and was not committed.

## repo-cache

- Commit `f474298` stores heatmap databases, including `.heatmap/06-cursor/go-email-reader/heatmap.db`.
- SQLite `-shm` and `-wal` sidecars were not committed.

## Push denied

These local commits are still unpushed because GitHub denied `alimtvnetwork`:

- `alim.karim.profile` (19 commits)
- `kubernetes-training-v1` (19 commits)
- `common-linux-installer` (1 commit)

## Rules learned

- Do not put a personal access token in a git remote URL. Use SSH.
- Do not commit coverage profiles or SQLite sidecar files.

## Last 30 commits in this repo

```text
047f2c83 chore(version) - bump to v1.62.32
31ae4cb6 feat(sync) - sync canonical v6 execute suite, gitmap heatmap telemetry, skills, and prompts (29-Oct-26 06:32 pm)
e9e52b5e chore(version) - bump to v1.62.31
da6cedb3 feat(sync) - sync canonical v6 execute suite, gitmap heatmap telemetry, skills, and prompts (29-Oct-26 04:24 pm)
c256213b chore(version) - bump to v1.62.30
1819f3ce feat(sync) - sync canonical v6 execute suite, gitmap heatmap telemetry, skills, and prompts (29-Oct-26 03:18 pm)
3b3c5975 chore(version) - bump to v1.62.29
7c969f17 feat(sync) - sync canonical v6 execute suite, gitmap heatmap telemetry, skills, and prompts (29-Oct-26 02:55 pm)
315b6ddd chore(version) - bump to v1.62.28
17189819 feat(sync) - sync canonical v6 execute suite, gitmap heatmap telemetry, skills, and prompts (28-Oct-26 10:19 am)
6bf2567a chore(version) - bump to v1.62.27
f2022d5d feat(sync) - sync canonical v6 execute suite, gitmap heatmap telemetry, skills, and prompts
ca869273 chore(version) - bump to v1.62.26
48eb43f4 feat(sync) - sync canonical v6 execute suite, gitmap heatmap telemetry, skills, and prompts
372431be chore(version): bump to v1.62.25
717ce96c feat(sync): sync canonical prompts, skills, gitmap agent standards, and purge deprecated 46 task manager
97ca49a6 chore(version): bump to v1.62.24
4e625221 feat(sync): sync canonical prompts, skills, gitmap agent standards, and purge deprecated 46 task manager
2b2e2982 chore(version): bump to v1.62.23
64e316b4 feat(sync): sync canonical prompts, skills, gitmap agent standards, and purge deprecated 46 task manager
351fa007 chore(version): bump to v1.62.22
34d432a1 feat(sync): sync canonical prompts, skills, gitmap agent standards, and purge deprecated 46 task manager
ed17f661 feat(profile): add agm-build-tools profile and aliases for rust and llvm toolchain
ecd06dc7 chore(version): bump to v1.62.20
44310a8f feat(sync): sync canonical prompts, skills, gitmap agent standards, and purge deprecated 46 task manager
c170301d chore(version) - bump to v1.62.19
316b96f3 feat(sync) - sync canonical v6 execute suite, gitmap heatmap telemetry, skills, and prompts
23968776 chore(version): bump to v1.62.18
68fa988b feat(sync): sync canonical prompts, skills, gitmap agent standards, and purge deprecated 46 task manager
3c9f43e6 chore(version) - bump to v1.62.17
```
