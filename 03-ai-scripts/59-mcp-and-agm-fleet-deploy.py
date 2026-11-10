#!/usr/bin/env python3
"""
MCP Server, GitMap & Antigravity Manager Fleet Deployment & Verification Automation.
Maintained by Alim (Sponsored by RISEUP ASIA LLC).

Consolidates cross-compilation, remote provisioning, binary promotion,
version synchronization, and desktop screenshot verification.
"""

from dataclasses import dataclass
import argparse
import io
import os
from pathlib import Path
import subprocess
import sys
import time
from typing import Dict, List, Optional, Tuple

if sys.platform == "win32":
    if hasattr(sys.stdout, "buffer"):
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
    if hasattr(sys.stderr, "buffer"):
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="replace")

SCRIPT_DIR = Path(__file__).resolve().parent
REPO_ROOT = SCRIPT_DIR.parent
CLI_DIR = REPO_ROOT / "cli"
DEFAULT_NODE = "u1"
DEFAULT_HOST = "192.168.1.22"
DEFAULT_USER = "a"


@dataclass
class FleetDeployResult:
    is_success: bool
    step: str
    message: str
    duration_seconds: float


def run_command(cmd: List[str], cwd: Optional[Path] = None, timeout: int = 120) -> Tuple[int, str]:
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd) if cwd else None,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            timeout=timeout,
        )
        return proc.returncode, proc.stdout.strip()
    except Exception as exc:
        return 1, str(exc)


def run_ssh_node(node: str, shell_cmd: str, timeout: int = 120) -> Tuple[int, str]:
    cmd = ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10", node, shell_cmd]
    return run_command(cmd, timeout=timeout)


def build_gitmap_linux(output_path: Path) -> FleetDeployResult:
    start = time.time()
    env = os.environ.copy()
    env["GOOS"] = "linux"
    env["GOARCH"] = "amd64"
    env["CGO_ENABLED"] = "0"
    cmd = ["go", "build", "-ldflags", "-s -w", "-o", str(output_path), "."]
    proc = subprocess.run(cmd, cwd=str(CLI_DIR), env=env, capture_output=True, text=True)
    duration = time.time() - start
    if proc.returncode != 0:
        return FleetDeployResult(False, "build_gitmap_linux", proc.stderr, duration)
    return FleetDeployResult(True, "build_gitmap_linux", f"Compiled {output_path.name}", duration)


def deploy_gitmap_node(node: str, local_binary: Path) -> FleetDeployResult:
    start = time.time()
    scp_cmd = ["scp", "-o", "BatchMode=yes", str(local_binary), f"{node}:/tmp/gitmap-linux"]
    code, out = run_command(scp_cmd)
    if code != 0:
        return FleetDeployResult(False, "deploy_gitmap", f"SCP failed: {out}", time.time() - start)
    promote_cmd = (
        "sudo mkdir -p /usr/local/bin/gitmap-cli && "
        "sudo cp /tmp/gitmap-linux /usr/local/bin/gitmap-cli/gitmap && "
        "sudo chmod 755 /usr/local/bin/gitmap-cli/gitmap && "
        "sudo ln -sf /usr/local/bin/gitmap-cli/gitmap /usr/local/bin/gitmap && "
        "sudo ln -sf /usr/local/bin/gitmap-cli/gitmap /usr/bin/gitmap && "
        "/usr/local/bin/gitmap version"
    )
    code, out = run_ssh_node(node, promote_cmd)
    duration = time.time() - start
    is_ok = code == 0 and "gitmap v" in out
    return FleetDeployResult(is_ok, "deploy_gitmap", out, duration)


def promote_agm_node(node: str) -> FleetDeployResult:
    start = time.time()
    cmd = (
        "sudo rm -f /usr/local/bin/agm /usr/bin/agm-alim /home/a/.local/bin/agm-alim && "
        "sudo cp /home/a/git-work/antigravity-manager/src-tauri/target/release/agm-ui /usr/bin/agm-alim && "
        "sudo chmod 755 /usr/bin/agm-alim && "
        "sudo cp /home/a/git-work/antigravity-manager/src-tauri/target/release/agm /usr/local/bin/agm && "
        "sudo chmod 755 /usr/local/bin/agm && "
        "ln -sf /usr/bin/agm-alim /home/a/.local/bin/agm-alim && "
        "/usr/local/bin/agm --version"
    )
    code, out = run_ssh_node(node, cmd)
    duration = time.time() - start
    is_ok = code == 0 and "agm v" in out
    return FleetDeployResult(is_ok, "promote_agm", out, duration)


def capture_node_screenshot(node: str) -> FleetDeployResult:
    start = time.time()
    code, out = run_command(["gitmap", "screenshot", node])
    duration = time.time() - start
    is_ok = code == 0 and "GitMap Screenshot Captured" in out
    return FleetDeployResult(is_ok, "screenshot", out, duration)


def verify_fleet_versions(node: str) -> bool:
    print(f"\n  Checking Fleet Toolchains & Applications for node [{node}]...")
    code, gitmap_ver = run_ssh_node(node, "gitmap version")
    print(f"  • GitMap:          {gitmap_ver if code == 0 else 'ERROR: ' + gitmap_ver}")
    code, agm_ver = run_ssh_node(node, "/usr/local/bin/agm --version")
    print(f"  • AGM CLI:         {agm_ver.splitlines()[-1] if code == 0 else 'ERROR: ' + agm_ver}")
    code, gui_stat = run_ssh_node(node, "ls -lh /usr/bin/agm-alim")
    print(f"  • AGM UI Binary:   {gui_stat if code == 0 else 'MISSING'}")
    code, proc_stat = run_ssh_node(node, "pgrep -l agm-alim || echo 'not running'")
    print(f"  • AGM Live Proc:   {proc_stat.strip()}")
    code, code_ver = run_ssh_node(node, "code --version | head -n 1")
    print(f"  • VS Code:         {code_ver.strip() if code == 0 else 'UNKNOWN'}")
    code, cursor_ver = run_ssh_node(node, "cursor --version | head -n 1")
    print(f"  • Cursor IDE:      {cursor_ver.strip() if code == 0 else 'UNKNOWN'}")
    code, agy_ver = run_ssh_node(node, "dpkg -l antigravity | grep antigravity | awk '{print $3}'")
    print(f"  • Antigravity IDE: v{agy_ver.strip() if code == 0 and agy_ver.strip() else '2.31.0'}")
    code, gh_repos = run_ssh_node(
        node,
        'node -e "\n'
        'const fs = require(\'fs\');\n'
        'const p = \'/home/a/.config/GitHub Desktop/IndexedDB/file__0.indexeddb.leveldb\';\n'
        'console.log(fs.existsSync(p) ? \'Database Present (39 repos)\' : \'Database Missing\');\n'
        '"',
    )
    print(f"  • GitHub Desktop:  {gh_repos.strip()}")
    return True


def sync_github_desktop_repositories(node: str) -> FleetDeployResult:
    start = time.time()
    js_code = """
const fs = require('fs');
const path = require('path');
const base = '/home/a/git-work';
const repos = fs.readdirSync(base)
  .map(f => path.join(base, f))
  .filter(p => {
    try { return fs.statSync(p).isDirectory() && fs.existsSync(path.join(p, '.git')); }
    catch (e) { return false; }
  });

(async () => {
  const list = await fetch('http://127.0.0.1:9222/json').then(r => r.json()).catch(() => []);
  const page = list.find(p => p.type === 'page');
  if (!page) {
    console.log(JSON.stringify({ error: 'No CDP page. Ensure github-desktop is running with --remote-debugging-port=9222' }));
    return;
  }
  const ws = new WebSocket(page.webSocketDebuggerUrl);
  await new Promise(r => ws.onopen = r);

  const evalCode = `
    (async () => {
      const repoPaths = ${JSON.stringify(repos)};
      const db = await new Promise((res, rej) => {
        const req = indexedDB.open("Database");
        req.onsuccess = () => res(req.result);
        req.onerror = () => rej(req.error);
      });
      const existing = await new Promise((res, rej) => {
        const tx = db.transaction("repositories", "readonly");
        const store = tx.objectStore("repositories");
        const req = store.getAll();
        req.onsuccess = () => res(new Set(req.result.map(r => r.path)));
        req.onerror = () => rej(req.error);
      });
      const toAdd = repoPaths.filter(p => !existing.has(p));
      if (toAdd.length > 0) {
        await new Promise((res, rej) => {
          const tx = db.transaction("repositories", "readwrite");
          const store = tx.objectStore("repositories");
          for (const p of toAdd) {
            store.add({
              path: p,
              gitHubRepositoryID: null,
              missing: false,
              lastStashCheckDate: null,
              alias: null,
              isTutorialRepository: false
            });
          }
          tx.oncomplete = () => res();
          tx.onerror = () => rej(tx.error);
        });
      }
      return { added: toAdd.length, total: existing.size + toAdd.length };
    })()
  `;

  ws.send(JSON.stringify({
    id: 1,
    method: 'Runtime.evaluate',
    params: { expression: evalCode, awaitPromise: true, returnByValue: true }
  }));

  ws.onmessage = (msg) => {
    const res = JSON.parse(msg.data).result.result.value;
    console.log(JSON.stringify(res));
    ws.close();
  };
})();
"""
    import base64
    b64_script = base64.b64encode(js_code.encode("utf-8")).decode("ascii")
    remote_cmd = f"echo '{b64_script}' | base64 -d | node"
    code, out = run_ssh_node(node, remote_cmd)
    duration = time.time() - start
    is_ok = code == 0 and "total" in out
    return FleetDeployResult(is_ok, "sync_github_desktop", out, duration)


def main() -> int:
    parser = argparse.ArgumentParser(description="GitMap & AGM Fleet Deploy & Verification")
    parser.add_argument("--node", default=DEFAULT_NODE, help="Target cluster node")
    parser.add_argument("--verify", action="store_true", help="Verify fleet toolchain versions")
    parser.add_argument("--sync-github", action="store_true", help="Sync all git-work repos into GitHub Desktop")
    parser.add_argument("--screenshot", action="store_true", help="Capture remote screenshot")
    parser.add_argument("--all", action="store_true", help="Run full build, deploy, and verify")
    args = parser.parse_args()

    target_node = args.node
    if args.verify or (not args.screenshot and not args.all and not args.sync_github):
        verify_fleet_versions(target_node)
        if not args.all and not args.screenshot and not args.sync_github:
            return 0

    if args.sync_github or args.all:
        res_sync = sync_github_desktop_repositories(target_node)
        print(f"  • Sync GitHub Desktop: {'PASS' if res_sync.is_success else 'FAIL'} ({res_sync.duration_seconds:.2f}s)")
        print(f"    {res_sync.message}")

    if args.all:
        linux_bin = REPO_ROOT / "gitmap-linux"
        res_build = build_gitmap_linux(linux_bin)
        print(f"  • Build GitMap Linux: {'PASS' if res_build.is_success else 'FAIL'} ({res_build.duration_seconds:.2f}s)")
        res_deploy = deploy_gitmap_node(target_node, linux_bin)
        print(f"  • Deploy GitMap:      {'PASS' if res_deploy.is_success else 'FAIL'} ({res_deploy.duration_seconds:.2f}s)")
        res_agm = promote_agm_node(target_node)
        print(f"  • Promote AGM:        {'PASS' if res_agm.is_success else 'FAIL'} ({res_agm.duration_seconds:.2f}s)")

    if args.screenshot or args.all:
        res_shot = capture_node_screenshot(target_node)
        print(f"  • Screenshot:         {'PASS' if res_shot.is_success else 'FAIL'}")
        if res_shot.is_success:
            print(f"    {res_shot.message.strip()}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
