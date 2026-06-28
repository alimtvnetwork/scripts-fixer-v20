<#
.SYNOPSIS
    doctor --fix: ties together every drift / hygiene check and (optionally)
    auto-repairs the ones that have writer counterparts.

.DESCRIPTION
    Read-only mode (default):
      - registry-sync   --check  (registry.yaml -> JSONs)
      - sync-version    --check  (scripts/version.json -> root version.json)
      - manifest-validate        (per-script manifest.json vs schema)
      - scan-legacy-fixer-refs   (no stale v8/v9/v10 references)
      - check-required-packages  (critical npm deps installed)

    With -Fix:
      - registry-sync             (rewrite JSONs)
      - sync-version              (rewrite root version.json)
      - fix-and-verify-legacy-refs (auto-replace stale refs)

    Always prints a GRANT-style "missing pieces" report at the end:
      [PASS]/[FIX]/[FAIL]  <check>  -- <fix command if applicable>
#>
function Invoke-DoctorFix {
    [CmdletBinding()]
    param(
        [switch]$Fix,
        [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot | Split-Path -Parent)
    )

    Write-Host ""
    Write-Host "  Project Doctor -- $(if ($Fix) { 'FIX' } else { 'CHECK' }) mode" -ForegroundColor Cyan
    Write-Host "  =====================================" -ForegroundColor DarkGray
    Write-Host ""

    $report = New-Object System.Collections.Generic.List[object]
    $node   = (Get-Command node -ErrorAction SilentlyContinue)
    $bash   = (Get-Command bash -ErrorAction SilentlyContinue)

    function Add-Row($name, $status, $fixCmd = "", $detail = "") {
        $report.Add([pscustomobject]@{ Check = $name; Status = $status; Detail = $detail; Fix = $fixCmd }) | Out-Null
        $color = switch ($status) { "PASS" {"Green"} "FIX" {"Cyan"} "WARN" {"Yellow"} "FAIL" {"Red"} default {"Gray"} }
        Write-Host ("    [{0}] {1}" -f $status, $name) -ForegroundColor $color -NoNewline
        if ($detail) { Write-Host " -- $detail" -ForegroundColor DarkGray } else { Write-Host "" }
    }

    function Invoke-Probe {
        param([string]$Name, [string]$CheckCmd, [string]$FixCmd, [switch]$RequiresBash)
        if ($RequiresBash -and -not $bash) { Add-Row $Name "WARN" "" "bash not available -- runs in CI"; return }
        if (-not $node)                    { Add-Row $Name "WARN" "" "node not available";              return }
        Push-Location $RepoRoot
        try {
            $null = Invoke-Expression "$CheckCmd 2>&1"
            $ok = $LASTEXITCODE -eq 0
        } catch { $ok = $false }
        Pop-Location
        if ($ok) { Add-Row $Name "PASS"; return }
        if (-not $Fix -or -not $FixCmd) { Add-Row $Name "FAIL" $FixCmd "drift detected"; return }
        Push-Location $RepoRoot
        try {
            Invoke-Expression $FixCmd | Out-Host
            $fixedOk = $LASTEXITCODE -eq 0
        } catch { $fixedOk = $false }
        Pop-Location
        if ($fixedOk) { Add-Row $Name "FIX" $FixCmd "auto-repaired" }
        else          { Add-Row $Name "FAIL" $FixCmd "fix command failed" }
    }

    Invoke-Probe "registry-sync (yaml->json)" "node tools/registry-sync.cjs --check" "node tools/registry-sync.cjs"
    Invoke-Probe "version-sync (scripts->root)" "node tools/sync-version.cjs --check"  "node tools/sync-version.cjs"
    Invoke-Probe "manifest schema validation"  "node tools/manifest-validate.cjs"      ""
    Invoke-Probe "legacy fixer-ref scan"       "bash tools/scan-legacy-fixer-refs.sh"  "bash tools/fix-and-verify-legacy-refs.sh" -RequiresBash
    $reqPkg = Join-Path $RepoRoot "tools/check-required-packages.mjs"
    if (Test-Path $reqPkg) {
        Invoke-Probe "required-package check"  "node tools/check-required-packages.mjs" ""
    }

    Write-Host ""
    Write-Host "  GRANT-style report" -ForegroundColor Cyan
    Write-Host "  ------------------" -ForegroundColor DarkGray
    $missing = $report | Where-Object { $_.Status -eq "FAIL" }
    if ($missing.Count -eq 0) {
        Write-Host "    All checks green." -ForegroundColor Green
    } else {
        foreach ($m in $missing) {
            $hint = if ($m.Fix) { "Run: $($m.Fix)" } else { "Resolve manually." }
            Write-Host ("    MISSING: {0,-40}  {1}" -f $m.Check, $hint) -ForegroundColor Yellow
        }
        Write-Host ""
        Write-Host "    Tip: re-run with --fix to auto-repair drift checks." -ForegroundColor DarkGray
    }

    if ($env:LOVABLE_JSON_OUT -eq "1") {
        $payload = [ordered]@{
            command   = "doctor-fix"
            mode      = if ($Fix) { "fix" } else { "check" }
            checks    = $report
            timestamp = (Get-Date).ToUniversalTime().ToString("o")
        }
        Write-Output ($payload | ConvertTo-Json -Depth 5)
    }

    $failed = ($report | Where-Object { $_.Status -eq "FAIL" }).Count
    return $failed
}
