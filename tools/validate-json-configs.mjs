#!/usr/bin/env node
/**
 * validate-json-configs.mjs
 *
 * Parses every source JSON config in the repo and fails with the EXACT file
 * path, line, column and parser message when one is malformed.
 *
 * Guards against the class of bug where a Windows path is written with single
 * backslashes inside a JSON string (e.g. "C:\Program Files\Git"), which makes
 * PowerShell's ConvertFrom-Json throw "Bad JSON escape sequence: \P".
 *
 * Usage: node tools/validate-json-configs.mjs
 */

import { readFileSync, readdirSync, statSync } from "node:fs";
import { join, relative, basename } from "node:path";

const ROOT = process.cwd();

const SEARCH_DIRS = ["scripts", "scripts-linux", "core", "tools", "scripts-orchestrator"];
const FILE_NAMES = new Set(["config.json", "log-messages.json", "manifest.json", "registry.json"]);

// Runtime output folders -- generated at run time, never hand-edited.
const SKIP_DIRS = new Set([
  ".logs",
  ".summary",
  ".installed",
  ".resolved",
  "node_modules",
  ".git",
]);

const RED = "\x1b[31m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const CYAN = "\x1b[36m";
const RESET = "\x1b[0m";

/** Recursively collect candidate JSON files. */
function collect(dir, out) {
  let entries;
  try {
    entries = readdirSync(dir);
  } catch {
    return out;
  }
  for (const entry of entries) {
    if (SKIP_DIRS.has(entry)) continue;
    const full = join(dir, entry);
    let st;
    try {
      st = statSync(full);
    } catch {
      continue;
    }
    if (st.isDirectory()) {
      collect(full, out);
    } else if (FILE_NAMES.has(basename(full))) {
      out.push(full);
    }
  }
  return out;
}

/** Translate a JSON.parse character offset into line/column. */
function offsetToLineCol(text, offset) {
  const upto = text.slice(0, Math.max(0, offset));
  const lines = upto.split("\n");
  return { line: lines.length, column: lines[lines.length - 1].length + 1 };
}

function describeError(text, err) {
  const match = /position (\d+)/.exec(err.message);
  if (!match) return { message: err.message, line: 0, column: 0 };
  const { line, column } = offsetToLineCol(text, Number(match[1]));
  return { message: err.message, line, column };
}

function main() {
  const files = [];
  for (const dir of SEARCH_DIRS) collect(join(ROOT, dir), files);
  files.sort();

  const failures = [];
  for (const file of files) {
    const rel = relative(ROOT, file);
    let text;
    try {
      text = readFileSync(file, "utf8");
    } catch (err) {
      failures.push({ rel, line: 0, column: 0, message: `unreadable: ${err.message}` });
      continue;
    }
    if (text.trim() === "") {
      failures.push({ rel, line: 0, column: 0, message: "file is empty" });
      continue;
    }
    try {
      JSON.parse(text);
    } catch (err) {
      const info = describeError(text, err);
      failures.push({ rel, ...info });
    }
  }

  console.log(`${CYAN}JSON config validator${RESET} -- checked ${files.length} file(s)`);

  if (failures.length === 0) {
    console.log(`${GREEN}[OK]${RESET} all JSON configs parse cleanly`);
    return 0;
  }

  for (const f of failures) {
    console.error(`${RED}[XX]${RESET} path=${f.rel}`);
    console.error(`     line=${f.line} column=${f.column}`);
    console.error(`     reason=${f.message}`);
    console.error(
      `     ${YELLOW}hint${RESET}: inside JSON strings a Windows path must use doubled backslashes, e.g. "C:\\\\Program Files\\\\Git"`,
    );
  }
  console.error(`${RED}[XX]${RESET} ${failures.length} malformed JSON file(s)`);
  return 1;
}

process.exit(main());
