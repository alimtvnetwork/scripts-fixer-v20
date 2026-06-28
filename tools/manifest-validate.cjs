#!/usr/bin/env node
/**
 * Validates every manifest.json against core/contracts/manifest.schema.json.
 * Exit 1 on any failure (used by pre-commit + CI).
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const SCHEMA = JSON.parse(fs.readFileSync(path.join(ROOT, "core/contracts/manifest.schema.json"), "utf8"));

const SKIP = new Set([".logs", ".installed", ".resolved", ".state", "node_modules", ".git", ".gitmap"]);
function* walk(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    if (SKIP.has(e.name)) continue;
    const p = path.join(dir, e.name);
    if (e.isDirectory()) yield* walk(p);
    else if (e.name === "manifest.json") yield p;
  }
}

// Minimal validator -- checks required, types, patterns, enums. Avoids ajv to stay zero-dep.
function validate(obj, schema, where) {
  const errs = [];
  function check(value, sub, p) {
    if (sub.const !== undefined && value !== sub.const) errs.push(`${p}: expected const ${JSON.stringify(sub.const)}`);
    if (sub.enum && !sub.enum.includes(value)) errs.push(`${p}: ${value} not in [${sub.enum}]`);
    if (sub.type) {
      const types = Array.isArray(sub.type) ? sub.type : [sub.type];
      const actual = Array.isArray(value) ? "array" : (value === null ? "null" : typeof value);
      if (!types.includes(actual)) errs.push(`${p}: expected ${types}, got ${actual}`);
    }
    if (sub.pattern && typeof value === "string" && !new RegExp(sub.pattern).test(value)) {
      errs.push(`${p}: '${value}' fails /${sub.pattern}/`);
    }
    if (sub.required && typeof value === "object" && value !== null) {
      for (const req of sub.required) if (!(req in value)) errs.push(`${p}: missing required '${req}'`);
    }
    if (sub.properties && typeof value === "object" && value !== null) {
      for (const [k, v] of Object.entries(value)) {
        if (sub.properties[k]) check(v, resolveRef(sub.properties[k]), `${p}.${k}`);
        else if (sub.additionalProperties === false) errs.push(`${p}: unknown key '${k}'`);
      }
    }
  }
  function resolveRef(s) {
    if (s.$ref) {
      const key = s.$ref.replace("#/definitions/", "");
      return schema.definitions[key];
    }
    return s;
  }
  check(obj, schema, where);
  return errs;
}

const targets = [path.join(ROOT, "scripts"), path.join(ROOT, "scripts-linux")];
let failed = 0, ok = 0;
for (const root of targets) {
  if (!fs.existsSync(root)) continue;
  for (const file of walk(root)) {
    let body;
    try { body = JSON.parse(fs.readFileSync(file, "utf8")); }
    catch (e) { console.error(`[FAIL] ${path.relative(ROOT, file)} parse: ${e.message}`); failed++; continue; }
    const errs = validate(body, SCHEMA, path.relative(ROOT, file));
    if (errs.length) { failed++; console.error(`[FAIL] ${path.relative(ROOT, file)}`); errs.forEach(e => console.error("       " + e)); }
    else ok++;
  }
}
console.log(`[OK] ${ok} manifest(s) valid, ${failed} failed`);
process.exit(failed ? 1 : 0);
