#!/usr/bin/env node
/**
 * Allowlist budget guard: spec-linter allowlist may only shrink, never grow.
 * Stores the maximum allowed count in tools/spec-linter.allowlist.budget.json.
 * CI fails if the current allowlist exceeds the budget.
 *
 * Usage:
 *   node tools/allowlist-budget.cjs           # check
 *   node tools/allowlist-budget.cjs --seal    # snapshot current count as new budget (must be <= old)
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const ALLOW = path.join(__dirname, "spec-linter.allowlist.json");
const BUDGET = path.join(__dirname, "spec-linter.allowlist.budget.json");

const allow = JSON.parse(fs.readFileSync(ALLOW, "utf8")).allow || [];
const current = allow.length;

let budget = current;
if (fs.existsSync(BUDGET)) {
  budget = JSON.parse(fs.readFileSync(BUDGET, "utf8")).max;
}

const seal = process.argv.includes("--seal");
if (seal) {
  if (current > budget) {
    console.error(`[FAIL] cannot seal: current ${current} exceeds existing budget ${budget}.`);
    process.exit(1);
  }
  fs.writeFileSync(BUDGET, JSON.stringify({ max: current, sealedAt: new Date().toISOString() }, null, 2) + "\n");
  console.log(`[OK] sealed allowlist budget at ${current}`);
  process.exit(0);
}

if (current > budget) {
  console.error(`[FAIL] spec-linter allowlist grew: ${current} > budget ${budget}. Remove an entry or fix the spec.`);
  process.exit(1);
}
console.log(`[OK] allowlist budget: ${current}/${budget} (only shrinks allowed)`);
