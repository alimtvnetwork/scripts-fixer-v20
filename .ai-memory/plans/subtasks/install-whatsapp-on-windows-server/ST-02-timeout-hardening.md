# ST-02: Timeout hardening (all install steps)

## Goal

No install step may block forever (user: "Install is stuck, always check with timeout").

## Work

1. Downloads: ensure `Invoke-WebRequest` uses `-TimeoutSec` from config (default 300s).
2. Installer execution: `Start-Process -PassThru` + `$proc.WaitForExit($timeoutMs)`; kill process on expiry; log timeout as error and continue to next chain method.
3. Chocolatey step: wrap `Install-ChocoPackage` call with timeout (job-based or process wait).
4. All timeout values from `config.json` `timeouts` block; sensible defaults when config missing.

## Acceptance

- Every network call has a timeout
- Every installer execution has a timeout with kill-on-expiry
- Timeout events are logged (not silent)
- PowerShell syntax valid
