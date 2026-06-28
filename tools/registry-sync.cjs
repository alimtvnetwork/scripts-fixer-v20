#!/usr/bin/env node
/**
 * Single Source of Truth for the script registry.
 *
 * Source: registry.yaml at repo root.
 * Emits : scripts/registry.json       (Windows -- {id: folder} map)
 *         scripts-linux/registry.json (Linux/macOS -- array of {id, folder, phase, title})
 *
 * Usage:
 *   node tools/registry-sync.cjs              # generate JSONs from YAML
 *   node tools/registry-sync.cjs --check      # exit 1 if generated JSONs differ from on-disk
 *   node tools/registry-sync.cjs --bootstrap  # build registry.yaml from current JSONs (one-shot)
 */
const fs = require("fs");
const path = require("path");
const yaml = require("js-yaml");

const ROOT = path.resolve(__dirname, "..");
const YAML_PATH = path.join(ROOT, "registry.yaml");
const WIN_JSON = path.join(ROOT, "scripts", "registry.json");
const LIN_JSON = path.join(ROOT, "scripts-linux", "registry.json");

function readJson(p) {
  return JSON.parse(fs.readFileSync(p, "utf8"));
}

function bootstrap() {
  const win = readJson(WIN_JSON).scripts; // {id: folder}
  const linDoc = readJson(LIN_JSON);
  const lin = Object.fromEntries(linDoc.scripts.map((s) => [s.id, s]));

  const allIds = Array.from(new Set([...Object.keys(win), ...Object.keys(lin)])).sort(
    (a, b) => parseInt(a, 10) - parseInt(b, 10)
  );

  const entries = allIds.map((id) => {
    const w = win[id];
    const l = lin[id];
    const entry = { id };
    if (w) {
      entry.windows = { folder: w };
    }
    if (l) {
      entry.linux = { folder: l.folder, phase: l.phase, title: l.title };
      entry.macos = { folder: l.folder, phase: l.phase, title: l.title };
    }
    return entry;
  });

  const doc = {
    version: linDoc.version || "0.0.0",
    description:
      "Single source of truth for the cross-platform script registry. " +
      "Generated artefacts: scripts/registry.json (Windows), scripts-linux/registry.json (Linux+macOS). " +
      "Run `node tools/registry-sync.cjs` after editing.",
    scripts: entries,
  };

  fs.writeFileSync(YAML_PATH, yaml.dump(doc, { lineWidth: 200, noRefs: true }));
  console.log(`[OK] wrote ${YAML_PATH} (${entries.length} entries)`);
}

function generate() {
  if (!fs.existsSync(YAML_PATH)) {
    console.error(`[FAIL] ${YAML_PATH} missing. Run --bootstrap first.`);
    process.exit(2);
  }
  const doc = yaml.load(fs.readFileSync(YAML_PATH, "utf8"));

  // Windows JSON: {id: folder} map
  const winMap = {};
  for (const s of doc.scripts) {
    if (s.windows && s.windows.folder) winMap[s.id] = s.windows.folder;
  }
  const winOut = {
    _comment:
      "GENERATED from registry.yaml -- DO NOT EDIT BY HAND. Run `node tools/registry-sync.cjs`.",
    scripts: winMap,
  };

  // Linux JSON: array of {id, folder, phase, title}
  const linArr = [];
  for (const s of doc.scripts) {
    if (s.linux && s.linux.folder) {
      linArr.push({
        id: s.id,
        folder: s.linux.folder,
        phase: s.linux.phase || "",
        title: s.linux.title || "",
      });
    }
  }
  const linOut = {
    version: doc.version,
    description:
      "GENERATED from registry.yaml -- DO NOT EDIT BY HAND. Run `node tools/registry-sync.cjs`.",
    scripts: linArr,
  };

  return {
    win: JSON.stringify(winOut, null, 2) + "\n",
    lin: JSON.stringify(linOut, null, 2) + "\n",
  };
}

function cmdWrite() {
  const { win, lin } = generate();
  fs.writeFileSync(WIN_JSON, win);
  fs.writeFileSync(LIN_JSON, lin);
  console.log(`[OK] wrote ${WIN_JSON}`);
  console.log(`[OK] wrote ${LIN_JSON}`);
}

function cmdCheck() {
  const { win, lin } = generate();
  const onDiskWin = fs.readFileSync(WIN_JSON, "utf8");
  const onDiskLin = fs.readFileSync(LIN_JSON, "utf8");
  let drift = false;
  if (onDiskWin !== win) {
    console.error(`[DRIFT] ${WIN_JSON} differs from generated output.`);
    drift = true;
  }
  if (onDiskLin !== lin) {
    console.error(`[DRIFT] ${LIN_JSON} differs from generated output.`);
    drift = true;
  }
  if (drift) {
    console.error("Run: node tools/registry-sync.cjs");
    process.exit(1);
  }
  console.log("[OK] registry JSONs match registry.yaml");
}

const arg = process.argv[2];
if (arg === "--bootstrap") bootstrap();
else if (arg === "--check") cmdCheck();
else cmdWrite();
