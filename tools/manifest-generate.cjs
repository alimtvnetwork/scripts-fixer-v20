#!/usr/bin/env node
/**
 * Generates a stub manifest.json in every NN-*/ folder, sourced from
 * registry.yaml. Existing manifests are left alone unless --force.
 *
 * Usage:
 *   node tools/manifest-generate.cjs                # create missing only
 *   node tools/manifest-generate.cjs --force        # rewrite all
 *   node tools/manifest-generate.cjs --dry-run      # preview
 */
const fs = require("fs");
const path = require("path");
const yaml = require("js-yaml");

const ROOT = path.resolve(__dirname, "..");
const REG = path.join(ROOT, "registry.yaml");
const force = process.argv.includes("--force");
const dry = process.argv.includes("--dry-run");

const doc = yaml.load(fs.readFileSync(REG, "utf8"));
let created = 0, skipped = 0, rewrote = 0;

for (const s of doc.scripts) {
  const platforms = {};
  if (s.windows) platforms.windows = { folder: s.windows.folder, entrypoint: "run.ps1" };
  if (s.linux)   platforms.linux   = { folder: s.linux.folder,   entrypoint: "run.sh"  };
  if (s.macos)   platforms.macos   = { folder: s.macos.folder,   entrypoint: "run.sh"  };

  const manifest = {
    schemaVersion: "1.0",
    id: s.id,
    name: (s.linux && s.linux.title) || (s.windows && s.windows.folder) || s.id,
    summary: (s.linux && s.linux.title) || "",
    aliases: [],
    platforms,
    depends_on: [],
    idempotent: true,
    destructive: false,
    commands: ["install"],
    phase: (s.linux && s.linux.phase) || "",
    tags: []
  };

  // Write to each platform's folder so the dispatcher always finds it locally.
  for (const plat of Object.keys(platforms)) {
    const folder = platforms[plat].folder;
    const baseDir = plat === "windows" ? path.join(ROOT, "scripts", folder) : path.join(ROOT, "scripts-linux", folder);
    if (!fs.existsSync(baseDir)) continue;
    const out = path.join(baseDir, "manifest.json");
    const exists = fs.existsSync(out);
    if (exists && !force) { skipped++; continue; }
    const body = JSON.stringify(manifest, null, 2) + "\n";
    if (dry) {
      console.log(`[DRY] ${exists ? "rewrite" : "create"} ${path.relative(ROOT, out)}`);
    } else {
      fs.writeFileSync(out, body);
      if (exists) rewrote++; else created++;
    }
  }
}

console.log(`[OK] created=${created} rewrote=${rewrote} skipped=${skipped}`);
