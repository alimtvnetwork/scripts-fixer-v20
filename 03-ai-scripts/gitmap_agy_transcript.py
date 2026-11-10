#!/usr/bin/env python3
"""
GitMap AGY Transcript CLI Companion & AGM Bridge
=================================================
Relative Path: 03-ai-scripts/gitmap_agy_transcript.py
Spec Reference: 02-spec/21-app/259-antigravity-manager-and-gitmap-cli-enhancements/02-cli-and-sqlite-spec.md

Bridges `gitmap agy transcript ...` CLI syntax directly to `agm transcripts`.
Enables autonomous AI agents and developers to browse, inspect, backup, and export
Antigravity conversation transcripts, tool calls, and model reasoning chains.

Usage:
  python 03-ai-scripts/gitmap_agy_transcript.py [subcommand] [flags]
  gitmap agy transcript [subcommand] [flags]

Subcommands:
  list, ls              Browse conversations with project names, human titles, and IDs
  inspect, show, view   Inspect step-by-step viewer with tool calls and thoughts
  backup, sync          Back up JSONL transcripts into SQLite database (transcripts.db)
  projects, workspaces  List all detected projects and active conversation counts
  export, md            Export clean Markdown for AI digestion (strips bulky telemetry)
  ui                    Launch or focus the AGM visual transcript viewer
  ai-help               Autonomous AI agent documentation and integration playbook

Flags:
  --project, -p <name>  Filter by project workspace path or folder name
  --instance, -i <id>   Filter by Antigravity instance ID ('lara-pub-6067', 'default', 'all')
  --limit, -l <n>       Maximum number of items to return (default: 20)
  --full                Read un-truncated transcript_full.jsonl instead of transcript.jsonl
  --steps, -s <range>   Filter steps (e.g. '1-20', '-10' for last 10 steps, '15')
  --telemetry           Include telemetry and heartbeat events (default: false)
  --file, -o <path>     Write export output to a specified file
  --json, -j            Output raw JSON for programmatic AI feeding
"""

import argparse
import json
import os
from pathlib import Path
import re
import shutil
import sqlite3
import subprocess
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")
if hasattr(sys.stderr, "reconfigure"):
    sys.stderr.reconfigure(encoding="utf-8")

REPO_ROOT = Path(__file__).resolve().parent.parent


def find_agm_binary() -> Optional[Path]:
    """Find the compiled `agm` CLI binary across standard locations."""
    # 1. Local target builds inside repository (pick newest build)
    candidates = [
        REPO_ROOT / "src-tauri" / "target" / "release" / "agm.exe",
        REPO_ROOT / "src-tauri" / "target" / "release" / "agm",
        REPO_ROOT / "src-tauri" / "target" / "debug" / "agm.exe",
        REPO_ROOT / "src-tauri" / "target" / "debug" / "agm",
    ]
    existing = [c for c in candidates if c.exists() and c.is_file()]
    if existing:
        existing.sort(key=lambda p: p.stat().st_mtime, reverse=True)
        return existing[0]

    # 2. System PATH
    which_agm = shutil.which("agm") or shutil.which("agm.exe")
    if which_agm:
        return Path(which_agm)

    # 3. User appdata or custom installs
    home = Path.home()
    candidates = [
        home / ".antigravity_tools" / "bin" / "agm.exe",
        home / "AppData" / "Local" / "agm-cli" / "agm.exe",
        home / ".cargo" / "bin" / "agm.exe",
        Path("d:/work/gitmap/bin/agm.exe"),
    ]

    for cand in candidates:
        if cand.exists() and cand.is_file():
            return cand

    return None


def forward_to_agm_binary(agm_bin: Path, args: List[str]) -> int:
    """Forward command arguments to native `agm transcripts` binary."""
    cmd = [str(agm_bin), "transcripts"] + args
    try:
        proc = subprocess.run(cmd)
        return proc.returncode
    except Exception as e:
        sys.stderr.write(f"[ERROR] Failed to run agm binary: {e}\n")
        return 1


# ==============================================================================
# Pure Python Fallback Implementation (when binary is not yet compiled)
# ==============================================================================

def get_brain_directories() -> List[Tuple[str, Path]]:
    """Discover all Antigravity brain directories across instances."""
    discovered: List[Tuple[str, Path]] = []
    seen = set()

    home = Path.home()

    # 1. Check home .gemini folders
    default_candidates = [
        home / ".gemini" / "antigravity" / "brain",
        home / ".gemini" / "brain",
    ]
    for cand in default_candidates:
        if cand.exists() and cand.is_dir():
            canon = cand.resolve()
            if canon not in seen:
                seen.add(canon)
                discovered.append(("default", cand))

    # 2. Check ~/.antigravity_tools instances
    instances_dir = home / ".antigravity_tools" / "instances"
    if instances_dir.exists() and instances_dir.is_dir():
        for item in instances_dir.iterdir():
            if item.is_dir():
                cand = item / "home" / ".gemini" / "antigravity" / "brain"
                if cand.exists() and cand.is_dir():
                    canon = cand.resolve()
                    if canon not in seen:
                        seen.add(canon)
                        discovered.append((item.name, cand))

    return discovered


def resolve_conversation_files(conv_dir: Path) -> Tuple[Optional[Path], bool]:
    """Resolve transcript file (prefers transcript_full.jsonl if non-empty)."""
    logs_dir = conv_dir / ".system_generated" / "logs"
    full_path = logs_dir / "transcript_full.jsonl"
    if full_path.exists() and full_path.stat().st_size > 0:
        return full_path, True

    reg_path = logs_dir / "transcript.jsonl"
    if reg_path.exists():
        return reg_path, False

    return None, False


def clean_title(raw_text: str) -> str:
    """Clean raw user prompt or system message into human title."""
    txt = raw_text.strip()
    if not txt:
        return "Untitled Conversation"

    if "<USER_REQUEST>" in txt:
        m = re.search(r"<USER_REQUEST>(.*?)</USER_REQUEST>", txt, re.DOTALL)
        if m:
            txt = m.group(1).strip()

    if "content=" in txt:
        m = re.search(r"content=(.*)", txt, re.DOTALL)
        if m:
            txt = m.group(1).strip()

    # Strip XML tags
    txt = re.sub(r"<[^>]+>", " ", txt)
    # Strip markdown code blocks & symbols
    txt = txt.replace("```", " ").replace("`", "").replace("**", "").replace("*", "")
    txt = txt.replace("##", "").replace("#", "").replace("> ", " ")
    txt = re.sub(r"\s+", " ", txt).strip()

    if len(txt) <= 80:
        return txt
    return txt[:77].rsplit(" ", 1)[0] + "..."


def read_conversation_meta(conv_dir: Path, instance_id: str) -> Optional[Dict[str, Any]]:
    """Extract metadata for an individual conversation session."""
    conv_id = conv_dir.name
    tf, has_full = resolve_conversation_files(conv_dir)
    if not tf:
        return None

    title = ""
    project_name = "default"
    project_path = "unknown"
    step_count = 0
    created_at = ""
    updated_at = ""

    try:
        with open(tf, "r", encoding="utf-8", errors="replace") as f:
            lines = f.readlines()
            step_count = len(lines)

            for line in lines[:30]:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                    content = obj.get("content", "") or ""
                    tp = obj.get("type", "")
                    src = obj.get("source", "")

                    if not created_at and obj.get("created_at"):
                        created_at = obj["created_at"]

                    if (tp == "USER_INPUT" or src in ("USER_EXPLICIT", "USER")) and src != "SYSTEM":
                        if not title and content:
                            title = clean_title(content)

                    # Extract project info
                    if "Active Workspaces:" in content:
                        m = re.search(r"Active Workspaces:\s*\n-\s*(.*)", content)
                        if m:
                            project_path = m.group(1).strip().replace("\\", "/")
                            project_name = Path(project_path).name.lower()
                    elif "Command Working Directory:" in content:
                        m = re.search(r"Command Working Directory:\s*(.*)", content)
                        if m:
                            project_path = m.group(1).strip().replace("\\", "/")
                            project_name = Path(project_path).name.lower()

                    if not title and content and tp not in ("TOKEN_USAGE", "HEARTBEAT", "TELEMETRY"):
                        title = clean_title(content)
                except Exception:
                    continue

            if lines:
                try:
                    last_obj = json.loads(lines[-1].strip())
                    updated_at = last_obj.get("created_at", created_at)
                except Exception:
                    updated_at = created_at
    except Exception:
        return None

    if not title:
        title = f"Session {conv_id[:8]}"

    return {
        "conversation_id": conv_id,
        "instance_id": instance_id,
        "title": title,
        "project_name": project_name,
        "project_path": project_path,
        "step_count": step_count,
        "created_at": created_at,
        "updated_at": updated_at,
        "source_file": str(tf),
        "has_full_log": has_full,
    }


def parse_steps_range(range_str: str, total_steps: int) -> Tuple[int, int]:
    """Parse range string like '-10', '1-20', '15' into [start, end) index bounds."""
    s = range_str.strip()
    if not s:
        return 0, total_steps

    if s.startswith("-"):
        count = int(s[1:])
        return max(0, total_steps - count), total_steps

    if s.endswith("-"):
        start = int(s[:-1])
        return start, total_steps

    if "-" in s:
        parts = s.split("-", 1)
        start = int(parts[0]) if parts[0].strip() else 0
        end = int(parts[1]) if parts[1].strip() else total_steps
        return start, min(total_steps, end + 1)

    try:
        single = int(s)
        return single, min(total_steps, single + 1)
    except ValueError:
        return 0, total_steps


def python_list(args: argparse.Namespace) -> None:
    """Pure python listing of conversations."""
    brains = get_brain_directories()
    results = []

    for inst_id, brain_dir in brains:
        if args.instance and args.instance.lower() != "all" and inst_id.lower() != args.instance.lower():
            continue
        if not brain_dir.exists():
            continue
        for item in brain_dir.iterdir():
            if item.is_dir():
                meta = read_conversation_meta(item, inst_id)
                if meta:
                    if args.project:
                        p_lower = args.project.lower()
                        if p_lower not in meta["project_name"].lower() and p_lower not in meta["project_path"].lower():
                            continue
                    results.append(meta)

    results.sort(key=lambda x: x["updated_at"], reverse=True)
    results = results[:args.limit]

    if args.json:
        print(json.dumps(results, indent=2))
        return

    if not results:
        print("No conversation transcripts found.")
        return

    print(f"\nDiscovered Antigravity Conversations ({len(results)}):")
    print(f"{'ID (Short)':<10} {'Project':<22} {'Instance':<15} {'Steps':<7} Title")
    print("-" * 96)
    for r in results:
        sid = r["conversation_id"][:8]
        sproj = r["project_name"][:20]
        sinst = r["instance_id"][:13]
        stitle = r["title"][:46]
        print(f"{sid:<10} {sproj:<22} {sinst:<15} {r['step_count']:<7} {stitle}")
    print("-" * 96)
    print("Tip: Run 'gitmap agy transcript inspect <id>' to inspect steps or 'gitmap agy transcript export <id>'.")


def python_inspect(args: argparse.Namespace) -> None:
    """Pure python inspection of conversation steps."""
    brains = get_brain_directories()
    target_conv = None

    query = args.id_or_title.strip().lower()

    for inst_id, brain_dir in brains:
        if not brain_dir.exists():
            continue
        for item in brain_dir.iterdir():
            if item.is_dir():
                cid = item.name.lower()
                if query in ("current", "latest") or cid == query or cid.startswith(query):
                    target_conv = (inst_id, item)
                    break
        if target_conv and query not in ("current", "latest"):
            break

    if not target_conv:
        sys.stderr.write(f"[ERROR] Conversation '{args.id_or_title}' not found.\n")
        sys.exit(1)

    inst_id, conv_dir = target_conv
    tf, has_full = resolve_conversation_files(conv_dir)
    if not tf:
        sys.stderr.write(f"[ERROR] No transcript file found in {conv_dir}.\n")
        sys.exit(1)

    steps = []
    with open(tf, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    steps.append(json.loads(line))
                except Exception:
                    pass

    start_idx, end_idx = parse_steps_range(args.steps or "", len(steps))
    sliced_steps = steps[start_idx:end_idx]

    if not args.telemetry:
        sliced_steps = [
            s for s in sliced_steps
            if s.get("type") not in ("TOKEN_USAGE", "HEARTBEAT", "TELEMETRY", "PROGRESS", "METRICS")
        ]

    if args.json:
        print(json.dumps(sliced_steps, indent=2))
        return

    meta = read_conversation_meta(conv_dir, inst_id) or {}
    print("=" * 90)
    print(f"Conversation: {meta.get('title', 'Unknown')}")
    print(f"ID:           {conv_dir.name}")
    print(f"Project:      {meta.get('project_name', 'default')} ({meta.get('project_path', 'unknown')})")
    print(f"Instance:     {inst_id}")
    print(f"Source File:  {tf}")
    print(f"Steps:        Showing {len(sliced_steps)} steps (Total: {len(steps)})")
    print("=" * 90)

    for s in sliced_steps:
        s_idx = s.get("step_index", "?")
        s_src = s.get("source", "?")
        s_type = s.get("type", "?")
        s_stat = s.get("status", "?")
        s_time = s.get("created_at", "")

        print(f"\n--- [Step {s_idx}] {s_src} ({s_type}) | Status: {s_stat} | {s_time} ---")
        if s.get("thinking"):
            print("\n  [Thinking]")
            for l in s["thinking"].strip().splitlines():
                print(f"    {l}")
        if s.get("tool_calls"):
            print("\n  [Tool Calls]")
            print(f"    {json.dumps(s['tool_calls'], indent=4)}")
        if s.get("content"):
            print("\n  [Content]")
            for l in str(s["content"]).strip().splitlines():
                print(f"    {l}")

    print("\n" + "=" * 90)


def python_export(args: argparse.Namespace) -> None:
    """Pure python markdown export."""
    brains = get_brain_directories()
    target_conv = None
    query = args.id_or_title.strip().lower()

    for inst_id, brain_dir in brains:
        if not brain_dir.exists():
            continue
        for item in brain_dir.iterdir():
            if item.is_dir():
                cid = item.name.lower()
                if query in ("current", "latest") or cid == query or cid.startswith(query):
                    target_conv = (inst_id, item)
                    break
        if target_conv and query not in ("current", "latest"):
            break

    if not target_conv:
        sys.stderr.write(f"[ERROR] Conversation '{args.id_or_title}' not found.\n")
        sys.exit(1)

    inst_id, conv_dir = target_conv
    meta = read_conversation_meta(conv_dir, inst_id) or {}
    tf, _ = resolve_conversation_files(conv_dir)

    steps = []
    if tf:
        with open(tf, "r", encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        steps.append(json.loads(line))
                    except Exception:
                        pass

    start_idx, end_idx = parse_steps_range(args.steps or "", len(steps))
    sliced_steps = steps[start_idx:end_idx]

    if not args.telemetry:
        sliced_steps = [
            s for s in sliced_steps
            if s.get("type") not in ("TOKEN_USAGE", "HEARTBEAT", "TELEMETRY", "PROGRESS", "METRICS")
        ]

    out = []
    out.append(f"# Conversation: {meta.get('title', 'Unknown')}\n")
    out.append(f"- **Conversation ID:** `{conv_dir.name}`")
    out.append(f"- **Instance:** `{inst_id}`")
    out.append(f"- **Project:** `{meta.get('project_name', 'default')}` (`{meta.get('project_path', 'unknown')}`)")
    out.append(f"- **Timestamps:** Created: `{meta.get('created_at', '')}` | Updated: `{meta.get('updated_at', '')}`")
    out.append(f"- **Step Count:** {len(sliced_steps)}\n\n---\n")

    for s in sliced_steps:
        out.append(f"### Step {s.get('step_index', '?')} [{s.get('type', '?')}] - Status: {s.get('status', '?')}")
        out.append(f"*Source: {s.get('source', '?')} | Timestamp: {s.get('created_at', '')}*\n")
        if s.get("thinking"):
            out.append("<details><summary>Thought Process</summary>\n")
            out.append(s["thinking"].strip() + "\n")
            out.append("</details>\n")
        if s.get("content"):
            out.append(str(s["content"]).strip() + "\n")
        if s.get("tool_calls"):
            out.append("**Tool Calls:**\n```json\n" + json.dumps(s["tool_calls"], indent=2) + "\n```\n")
        out.append("---\n")

    md = "\n".join(out)
    if args.file:
        dest = Path(args.file)
        dest.write_text(md, encoding="utf-8")
        print(f"[OK] Exported conversation to {dest} ({len(sliced_steps)} steps).")
    else:
        print(md)


def print_ai_help() -> None:
    """Print AI agent playbook and instructions."""
    print("""GitMap AGY Transcript CLI - AI Agent Playbook
===============================================
Enables autonomous AI coding agents to discover, inspect, and extract context from
Antigravity pairs and subagent executions.

Command Recipes for AI Agents:
1. Discover project sessions:
   $ gitmap agy transcript list --project <name> --limit 10 --json
2. Inspect recent reasoning thoughts & tool calls:
   $ gitmap agy transcript inspect current --steps -10 --full --json
3. Feed clean digest into context window:
   $ gitmap agy transcript export current --steps -20
4. Sync conversation logs to SQLite:
   $ gitmap agy transcript backup --all

Invariants:
- Strictly relative Git paths in all documentation and commands.
- Telemetry records (HEARTBEAT, TOKEN_USAGE) are stripped on export.
""")


def main() -> int:
    args = sys.argv[1:]

    # Check for direct AI help
    if "ai-help" in args or "--ai-help" in args:
        print_ai_help()
        return 0

    # 1. Attempt delegation to compiled agm binary first for maximum speed
    agm_bin = find_agm_binary()
    if agm_bin and os.environ.get("AGM_PREFER_PYTHON") != "1":
        return forward_to_agm_binary(agm_bin, args)

    # 2. Pure Python Fallback parser
    parser = argparse.ArgumentParser(
        prog="gitmap agy transcript",
        description="Inspect, parse, browse, and backup Antigravity conversation transcripts."
    )
    subparsers = parser.add_subparsers(dest="subcommand", help="Subcommand to run")

    # Subcommand: list
    p_list = subparsers.add_parser("list", aliases=["ls"], help="List conversations")
    p_list.add_argument("--project", "-p", help="Filter by project name or workspace path")
    p_list.add_argument("--instance", "-i", help="Filter by instance ID ('all', 'default')")
    p_list.add_argument("--limit", "-l", type=int, default=20, help="Max items to list")
    p_list.add_argument("--json", "-j", action="store_true", help="Output raw JSON")

    # Subcommand: inspect
    p_inspect = subparsers.add_parser("inspect", aliases=["show", "view"], help="Inspect conversation steps")
    p_inspect.add_argument("id_or_title", nargs="?", default="current", help="Conversation ID, prefix, or 'current'")
    p_inspect.add_argument("--steps", "-s", help="Step range ('1-20', '-10', '15')")
    p_inspect.add_argument("--full", action="store_true", help="Prefer transcript_full.jsonl")
    p_inspect.add_argument("--telemetry", action="store_true", help="Include telemetry events")
    p_inspect.add_argument("--json", "-j", action="store_true", help="Output raw JSON")

    # Subcommand: export
    p_export = subparsers.add_parser("export", aliases=["md"], help="Export clean Markdown")
    p_export.add_argument("id_or_title", nargs="?", default="current", help="Conversation ID or 'current'")
    p_export.add_argument("--steps", "-s", help="Step range")
    p_export.add_argument("--telemetry", action="store_true", help="Include telemetry events")
    p_export.add_argument("--file", "-o", help="Write to file path")

    # Subcommand: projects
    p_projects = subparsers.add_parser("projects", aliases=["workspaces"], help="List detected projects")
    p_projects.add_argument("--json", "-j", action="store_true", help="Output raw JSON")

    # Subcommand: backup
    p_backup = subparsers.add_parser("backup", aliases=["sync"], help="Back up transcripts into SQLite")
    p_backup.add_argument("--all", action="store_true", help="Sync all conversations")
    p_backup.add_argument("--project", "-p", help="Filter by project name")

    parsed = parser.parse_args(args)

    if parsed.subcommand in ("list", "ls") or not parsed.subcommand:
        python_list(parsed)
    elif parsed.subcommand in ("inspect", "show", "view"):
        python_inspect(parsed)
    elif parsed.subcommand in ("export", "md"):
        python_export(parsed)
    elif parsed.subcommand in ("projects", "workspaces"):
        parsed.project = None
        parsed.instance = None
        parsed.limit = 100
        python_list(parsed)
    elif parsed.subcommand in ("backup", "sync"):
        print("[INFO] SQLite archival backup delegated to agm binary. Run `agm transcripts backup`.")
    else:
        parser.print_help()

    return 0


if __name__ == "__main__":
    sys.exit(main())
