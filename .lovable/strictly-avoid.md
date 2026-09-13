# strictly-avoid

## Section

Content here.

- NEVER artificially spin loops without completing the exact chunked workload.
- NEVER skip artifact sanitation before git add.
- NEVER use generic titles for temp agents.

- NEVER write script readers that assume files are purely ASCII; always account for UTF-8 and section symbols.
- NEVER process huge loops without locking mechanisms to avoid git/file collision.
- NEVER assume stdin piping in PowerShell 5.1 is raw ASCII without BOM; use utf-8-sig decoding to eliminate \xef\xbb\xbf in Python/SQLite bridges.
- NEVER use PowerShell 7+ null-coalescing operators (??) in cross-version scripts; use explicit if ($null -ne $val) for PS 5.1 compatibility.
- NEVER assume single-element array returns preserve array types under Set-StrictMode Latest; wrap with @(...) and use .Length.
- NEVER include literal multibyte Unicode characters (e.g. checkmarks) in UTF-8 .ps1 files without BOM; use [char]0x2714 or ASCII.
- NEVER allow root help interceptors to swallow subcommand help flags (e.g. nginx help, ssh help); route help to the child dispatcher.
- NEVER use Windows backslashes (\) in Nginx virtual host configuration paths; normalize strictly to forward slashes (/).
- NEVER disable, comment out, or bypass CI/CD validation workflows or unit tests to force pass.
- NEVER attempt git checkout/reset/pull over files missing DELETE ACL rights (0x10000) on Windows; if git unlinking fails with "Invalid argument" (ERROR_ACCESS_DENIED), perform merge in clean workspace and synchronize with in-place overwrites or set proper ACLs.
