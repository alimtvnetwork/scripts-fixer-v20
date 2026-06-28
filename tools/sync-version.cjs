#!/usr/bin/env node
/**
 * Syncs the canonical version from scripts/version.json into root version.json.
 * scripts/version.json is the single source of truth (touched by bump-version.ps1).
 * root version.json keeps its rich metadata (Title, Authors, RepoUrl, ...) and
 * only its `Version` / `version` / `updated` fields are rewritten.
 *
 * Usage:
 *   node tools/sync-version.cjs           # write
 *   node tools/sync-version.cjs --check   # exit 1 on drift
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const SRC = path.join(ROOT, "scripts", "version.json");
const DST = path.join(ROOT, "version.json");

const canonical = JSON.parse(fs.readFileSync(SRC, "utf8")).version;
if (!canonical) {
  console.error(`[FAIL] no .version in ${SRC}`);
  process.exit(2);
}

const today = new Date().toISOString().slice(0, 10);
const root = JSON.parse(fs.readFileSync(DST, "utf8"));
const updated = { ...root, Version: canonical, version: canonical, updated: today };
const out = JSON.stringify(updated, null, 2) + "\n";

if (process.argv.includes("--check")) {
  const onDisk = fs.readFileSync(DST, "utf8");
  // Compare only Version/version fields to avoid date churn on read-only checks.
  const onDiskParsed = JSON.parse(onDisk);
  if (onDiskParsed.Version !== canonical || onDiskParsed.version !== canonical) {
    console.error(
      `[DRIFT] root version.json (${onDiskParsed.version}) != scripts/version.json (${canonical}).`
    );
    console.error("Run: node tools/sync-version.cjs");
    process.exit(1);
  }
  console.log(`[OK] version in sync (${canonical})`);
  process.exit(0);
}

fs.writeFileSync(DST, out);
console.log(`[OK] root version.json -> ${canonical} (${today})`);
