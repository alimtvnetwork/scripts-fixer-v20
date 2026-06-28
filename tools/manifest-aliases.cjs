#!/usr/bin/env node
/**
 * Aggregate aliases from every NN-*/manifest.json into one file per platform
 * for run.ps1 / run.sh to source instead of hard-coding tables.
 *
 * Outputs:
 *   scripts/aliases.generated.json         { alias: { id, folder } }
 *   scripts-linux/aliases.generated.json
 *
 *   --check    fail on drift
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
function collect(baseDir) {
  const map = {};
  if (!fs.existsSync(baseDir)) return map;
  for (const ent of fs.readdirSync(baseDir, { withFileTypes: true })) {
    if (!ent.isDirectory()) continue;
    const mf = path.join(baseDir, ent.name, "manifest.json");
    if (!fs.existsSync(mf)) continue;
    try {
      const m = JSON.parse(fs.readFileSync(mf, "utf8"));
      const aliases = Array.isArray(m.aliases) ? m.aliases : [];
      for (const a of aliases) map[a] = { id: m.id || "", folder: ent.name };
    } catch (e) { console.error(`[WARN] bad manifest ${mf}: ${e.message}`); }
  }
  return Object.fromEntries(Object.entries(map).sort(([a],[b]) => a.localeCompare(b)));
}

const outs = {
  "scripts/aliases.generated.json": collect(path.join(ROOT, "scripts")),
  "scripts-linux/aliases.generated.json": collect(path.join(ROOT, "scripts-linux")),
};

const check = process.argv.includes("--check");
let drift = 0;
for (const [rel, data] of Object.entries(outs)) {
  const p = path.join(ROOT, rel);
  const body = JSON.stringify(data, null, 2) + "\n";
  const existing = fs.existsSync(p) ? fs.readFileSync(p, "utf8") : "";
  if (check) {
    if (existing !== body) { console.error(`[DRIFT] ${rel}`); drift++; }
  } else {
    fs.writeFileSync(p, body);
    console.log(`[OK] wrote ${rel} (${Object.keys(data).length} aliases)`);
  }
}
if (check && drift) { console.error(`[FAIL] alias files drifted. Run: node tools/manifest-aliases.cjs`); process.exit(1); }
if (check) console.log("[OK] alias files in sync");
