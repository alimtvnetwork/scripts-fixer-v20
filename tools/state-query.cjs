#!/usr/bin/env node
/**
 * Unified state query CLI used by doctor / audit / kimodo.
 *
 * Examples:
 *   node tools/state-query.cjs                        # tail all events
 *   node tools/state-query.cjs --script 01            # only script 01 events
 *   node tools/state-query.cjs --outcome failed       # only failures
 *   node tools/state-query.cjs --last 20              # last 20 events
 *   node tools/state-query.cjs --summary              # per-script count + last outcome
 *   node tools/state-query.cjs --json                 # raw JSON array
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const LOG = process.env.LOVABLE_STATE_LOG || path.join(ROOT, ".state", "events.jsonl");

if (!fs.existsSync(LOG)) {
  console.error(`[INFO] no state log at ${LOG}`);
  process.exit(0);
}

const argv = process.argv.slice(2);
const flag = (n) => { const i = argv.indexOf(n); return i >= 0 ? argv[i + 1] : null; };
const has  = (n) => argv.includes(n);

let events = fs.readFileSync(LOG, "utf8").split("\n").filter(Boolean).map((l) => {
  try { return JSON.parse(l); } catch { return null; }
}).filter(Boolean);

const fScript = flag("--script");
const fOut    = flag("--outcome");
const last    = parseInt(flag("--last") || "0", 10);
if (fScript) events = events.filter((e) => e.scriptId === fScript);
if (fOut)    events = events.filter((e) => e.outcome === fOut);
if (last > 0) events = events.slice(-last);

if (has("--summary")) {
  const by = {};
  for (const e of events) {
    by[e.scriptId] = by[e.scriptId] || { count: 0, last: null };
    by[e.scriptId].count++;
    by[e.scriptId].last = e;
  }
  const rows = Object.entries(by).sort().map(([id, v]) => ({
    id, runs: v.count, outcome: v.last.outcome, version: v.last.version || "-", ts: v.last.ts
  }));
  console.table(rows);
  process.exit(0);
}
if (has("--json")) {
  process.stdout.write(JSON.stringify(events, null, 2) + "\n");
  process.exit(0);
}
for (const e of events) {
  console.log(`${e.ts}  ${e.platform.padEnd(7)}  ${String(e.scriptId).padEnd(3)}  ${e.command.padEnd(10)}  ${e.outcome.padEnd(18)}  ${e.version || "-"}`);
}
