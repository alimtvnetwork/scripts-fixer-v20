# ST-01: Windows Server detection + install chain

## Goal

Add Windows Server awareness to `scripts/49-install-whatsapp/`.

## Work

1. Add `Test-IsWindowsServer` function to `helpers/whatsapp.ps1`:
   - Uses `(Get-CimInstance Win32_OperatingSystem).ProductType -ne 1`
   - Guard clause style, `is*` prefix per AGENTS.md
   - Micro-function (≤8 lines logic)

2. Server install chain in `Install-WhatsApp`:
   - When Server detected: try Chocolatey → official WhatsAppSetup.exe → winget (if available), in order
   - Verify `Get-WhatsAppPath` after each; stop at first success
   - Log clearly which method is being tried

3. `config.json`: add `serverChain` array + `timeouts` block (`downloadSeconds`, `installSeconds`)

4. `log-messages.json`: add messages for Server detection, chain steps

## Acceptance

- `Test-IsWindowsServer` returns correct boolean for ProductType 1 vs 2/3
- Chain order correct on Server; Workstation path unchanged
- PowerShell syntax valid
