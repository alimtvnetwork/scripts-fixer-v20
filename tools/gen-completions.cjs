#!/usr/bin/env node
/**
 * Generate shell completions for `run` / `os` dispatchers from registry.yaml.
 * Outputs:
 *   completions/run.bash
 *   completions/run.zsh
 *   completions/run.ps1
 *
 *   --check    fail if generated files are stale
 */
const fs = require("fs");
const path = require("path");
const yaml = require("js-yaml");

const ROOT = path.resolve(__dirname, "..");
const OUT = path.join(ROOT, "completions");
const reg = yaml.load(fs.readFileSync(path.join(ROOT, "registry.yaml"), "utf8"));

const ids = reg.scripts.map((s) => s.id);
const aliases = [];
for (const s of reg.scripts) {
  const w = s.windows && s.windows.folder;
  const l = s.linux && s.linux.folder;
  if (w) aliases.push(w.replace(/^\d+-/, ""));
  if (l && l !== w) aliases.push(l.replace(/^\d+-/, ""));
}
const allTargets = Array.from(new Set([...ids, ...aliases])).sort();
const cmds = ["install", "uninstall", "check", "repair", "list", "doctor", "version"];

const bash = `# bash completion for run
_run_complete() {
  local cur prev
  COMPREPLY=()
  cur="\${COMP_WORDS[COMP_CWORD]}"
  prev="\${COMP_WORDS[COMP_CWORD-1]}"
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "${cmds.join(" ")}" -- "$cur") )
  else
    COMPREPLY=( $(compgen -W "${allTargets.join(" ")} all --json --help" -- "$cur") )
  fi
}
complete -F _run_complete run
complete -F _run_complete ./run.sh
`;

const zsh = `#compdef run
_run() {
  local -a cmds targets
  cmds=(${cmds.map((c) => `'${c}'`).join(" ")})
  targets=(${allTargets.map((t) => `'${t}'`).join(" ")} 'all')
  if (( CURRENT == 2 )); then
    _describe 'command' cmds
  else
    _describe 'target' targets
  fi
}
compdef _run run
`;

const pwsh = `# PowerShell completion for run.ps1
Register-ArgumentCompleter -CommandName 'run','run.ps1','./run.ps1' -ScriptBlock {
    param($wordToComplete, $commandAst, $cursorPosition)
    $cmds    = @(${cmds.map((c) => `'${c}'`).join(",")})
    $targets = @(${allTargets.map((t) => `'${t}'`).join(",")} ,'all')
    $pos = $commandAst.CommandElements.Count
    $pool = if ($pos -le 2) { $cmds } else { $targets }
    $pool | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}
`;

if (!fs.existsSync(OUT)) fs.mkdirSync(OUT, { recursive: true });
const files = { "run.bash": bash, "run.zsh": zsh, "run.ps1": pwsh };

const check = process.argv.includes("--check");
let drift = 0;
for (const [name, body] of Object.entries(files)) {
  const p = path.join(OUT, name);
  const existing = fs.existsSync(p) ? fs.readFileSync(p, "utf8") : "";
  if (check) {
    if (existing !== body) { console.error(`[DRIFT] completions/${name}`); drift++; }
  } else {
    fs.writeFileSync(p, body);
    console.log(`[OK] wrote completions/${name}`);
  }
}
if (check && drift) { console.error(`[FAIL] ${drift} completion file(s) drifted. Run: node tools/gen-completions.cjs`); process.exit(1); }
if (check) console.log("[OK] completions in sync");
