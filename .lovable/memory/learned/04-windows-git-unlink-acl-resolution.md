---
name: Windows Git Unlink ACL Resolution & In-Place Sync
description: Resolution pattern for git checkout/unlink "Invalid argument" permission errors
type: learned
---

# Windows Git Unlink ACL Resolution & In-Place Sync

## Problem Encountered
When running `git pull`, `git checkout`, or `git merge` on Windows, Git may fail with:
```
error: unable to unlink old '<filename>': Invalid argument
```
This occurs when files created by Administrator processes have inherited ACLs that grant `BUILTIN\Users` only Read/Write/Execute (`0x1201bf`), but lack the Win32 `DELETE` access right (`0x10000`).
When Git attempts to overwrite or checkout files, it calls Win32 `DeleteFileW` prior to writing. The OS returns `ERROR_ACCESS_DENIED` (5), which Git's Unix-to-Win32 compatibility layer reports as `Invalid argument`.

Non-interactive automated agent shells cannot run elevated commands with UAC prompts (`Start-Process -Verb RunAs` fails with "The request is not supported").

## Solution Pattern
1. **Isolated Unprivileged Worktree / Clone**:
   Create a clean clone or worktree in a directory owned directly by the standard user (e.g. `D:\wp-work\riseup-asia\sync-work`).
2. **Perform Merge / Resolution in Isolated Tree**:
   Resolve all merge conflicts, update manifests, run test suites, commit the merge, and push directly to upstream remote (`github/main`).
3. **In-Place Working Tree Synchronization**:
   - In the target repository, update references using `git fetch origin` and `git reset --mixed origin/main` (which updates HEAD and index without touching disk files).
   - Use PowerShell `Copy-Item -Force` or Python `shutil.copyfile` to overwrite modified files in place. In-place overwrite uses `GENERIC_WRITE` (truncate) which succeeds with standard write rights, bypassing the `DeleteFileW` ACL restriction.
   - Clean up the temporary directory after verifying clean status (`git status` -> clean working tree).
