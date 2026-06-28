#!/usr/bin/env node
/**
 * Run tools/test-parity.cjs over every registry entry that exists on BOTH
 * Windows and Linux. Aggregates results. Skips quietly if pwsh/bash absent.
 */
const fs = require("fs");
const path = require("path");
const cp = require("child_process");
const yaml = require("js-yaml");

const ROOT = path.resolve(__dirname, "..");
const reg = yaml.load(fs.readFileSync(path.join(ROOT, "registry.yaml"), "utf8"));

const dual = reg.scripts.filter((s) => s.windows && s.linux);
let pass = 0, fail = 0, skip = 0;
for (const s of dual) {
  const r = cp.spawnSync("node", [path.join(__dirname, "test-parity.cjs"), s.id], { encoding: "utf8" });
  process.stdout.write(r.stdout || "");
  if (r.stderr) process.stderr.write(r.stderr);
  if (r.status === 0 && /\[OK\]/.test(r.stdout)) pass++;
  else if (r.status === 0) skip++;
  else fail++;
}
console.log(`\n[summary] parity: pass=${pass} skip=${skip} fail=${fail} (of ${dual.length} dual-OS scripts)`);
process.exit(fail ? 1 : 0);
