#!/usr/bin/env node
/**
 * Parity test: runs a script's PowerShell and Bash entrypoints in `--version`
 * mode and diffs their emitted status JSON. Fails on structural divergence.
 *
 * Usage:
 *   node tools/test-parity.cjs <scriptId>
 *
 * Skips silently when pwsh or bash is missing (CI matrix covers both shells).
 */
const fs = require("fs");
const path = require("path");
const cp = require("child_process");
const yaml = require("js-yaml");

const ROOT = path.resolve(__dirname, "..");
const id = process.argv[2];
if (!id) { console.error("usage: test-parity.cjs <scriptId>"); process.exit(2); }

const doc = yaml.load(fs.readFileSync(path.join(ROOT, "registry.yaml"), "utf8"));
const entry = doc.scripts.find((s) => s.id === id);
if (!entry) { console.error(`[FAIL] no registry entry for id=${id}`); process.exit(2); }

function run(cmd, args) {
  try {
    const r = cp.spawnSync(cmd, args, { encoding: "utf8", timeout: 30000 });
    return { ok: r.status === 0, stdout: r.stdout || "", stderr: r.stderr || "" };
  } catch (e) { return { ok: false, stdout: "", stderr: e.message }; }
}
function lastJson(s) {
  const m = s.match(/\{[\s\S]*\}\s*$/);
  if (!m) return null;
  try { return JSON.parse(m[0]); } catch { return null; }
}

const winFolder = entry.windows && entry.windows.folder;
const linFolder = entry.linux && entry.linux.folder;
const psPath = winFolder ? path.join(ROOT, "scripts", winFolder, "run.ps1") : null;
const shPath = linFolder ? path.join(ROOT, "scripts-linux", linFolder, "run.sh") : null;

const psHave = psPath && fs.existsSync(psPath) && cp.spawnSync("pwsh", ["-v"]).status === 0;
const shHave = shPath && fs.existsSync(shPath);

if (!psHave || !shHave) {
  console.log(`[SKIP] parity for ${id}: ps=${!!psHave} sh=${!!shHave}`);
  process.exit(0);
}

const ps = run("pwsh", ["-NoProfile", "-File", psPath, "--version"]);
const sh = run("bash", [shPath, "--version"]);

const psJ = lastJson(ps.stdout);
const shJ = lastJson(sh.stdout);
if (!psJ || !shJ) {
  console.error(`[WARN] parity ${id}: missing structured JSON (ps=${!!psJ} sh=${!!shJ}). Adopt status contract.`);
  process.exit(0); // warn-only until contract is rolled out
}

const keys = ["scriptId", "command", "outcome"];
const diffs = keys.filter((k) => psJ[k] !== shJ[k]);
if (diffs.length) {
  console.error(`[FAIL] parity ${id}: divergent keys ${diffs.join(",")}\n  ps=${JSON.stringify(psJ)}\n  sh=${JSON.stringify(shJ)}`);
  process.exit(1);
}
console.log(`[OK] parity ${id}: ps and sh agree on ${keys.join(",")}`);
