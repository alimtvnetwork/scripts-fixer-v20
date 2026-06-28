#!/usr/bin/env node
/**
 * Spec linter: every spec/NN-* readme.md (and major spec/<name> readme.md)
 * must contain the canonical headings: Commands, Flags, Exit Codes,
 * Verification. Exits non-zero on any miss.
 *
 * Required = H2 (## ...) match (case-insensitive). Subsections OK.
 *
 * Skips: 00-* meta specs, 2025-batch/* legacy notes, /suggestions/, /shared/.
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const SPEC = path.join(ROOT, "spec");
const REQUIRED = ["Commands", "Flags", "Exit Codes", "Verification"];
const SKIP_DIR = /^(00-|2025-batch|suggestions|shared|audit|doctor|kimodo|release-pipeline|bump-version|choco-update)/i;

function findReadmes(dir, out = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (SKIP_DIR.test(e.name)) continue;
      findReadmes(full, out);
    } else if (/^readme\.md$/i.test(e.name)) {
      // Only lint NN-* numbered specs (the user-facing install/script specs).
      const rel = path.relative(SPEC, full);
      const top = rel.split(path.sep)[0];
      if (/^\d{2,3}-/.test(top)) out.push(full);
    }
  }
  return out;
}

const files = findReadmes(SPEC);
const allowlistPath = path.join(__dirname, "spec-linter.allowlist.json");
const allowlist = fs.existsSync(allowlistPath)
  ? JSON.parse(fs.readFileSync(allowlistPath, "utf8")).allow || []
  : [];
const isAllowed = (rel) => allowlist.some((p) => rel.replace(/\\/g, "/") === p);

let failed = 0, ok = 0;
for (const f of files) {
  const rel = path.relative(ROOT, f).replace(/\\/g, "/");
  if (isAllowed(rel)) { console.log(`[SKIP] ${rel} (allowlisted)`); continue; }
  const body = fs.readFileSync(f, "utf8");
  const headings = (body.match(/^##\s+.+$/gm) || []).map((h) => h.replace(/^##\s+/, "").trim().toLowerCase());
  const missing = REQUIRED.filter((r) => !headings.some((h) => h === r.toLowerCase() || h.startsWith(r.toLowerCase())));
  if (missing.length === 0) { ok++; continue; }
  console.error(`[FAIL] ${rel}`);
  for (const m of missing) console.error(`       missing H2: ## ${m}`);
  failed++;
}

console.log(`[OK] ${ok}/${files.length} spec readmes have required headings, ${failed} failed`);
if (failed) {
  console.error("Add the missing '## Commands / ## Flags / ## Exit Codes / ## Verification' sections,");
  console.error("or allowlist a legacy file in tools/spec-linter.allowlist.json.");
  process.exit(1);
}
