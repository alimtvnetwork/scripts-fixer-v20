#!/usr/bin/env python3
"""
74-publish-muse-gists.py — Publish Muse General and Private Prompts as GitHub Gists.
Resolves token via Git Credential Manager / git config / environment and publishes via GitHub API.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import urllib.error
import urllib.request
from pathlib import Path


def resolve_github_token() -> str:
    """Resolve active GitHub access token from env, gh cli, git config, or Git Credential Manager."""
    for env_var in ("GH_TOKEN", "GITHUB_TOKEN"):
        if os.environ.get(env_var):
            return os.environ[env_var].strip()

    # Try gh auth token
    try:
        res = subprocess.run(["gh", "auth", "token"], capture_output=True, text=True)
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.strip()
    except Exception:
        pass

    # Try git config
    try:
        res = subprocess.run(["git", "config", "--get", "github.token"], capture_output=True, text=True)
        if res.returncode == 0 and res.stdout.strip():
            return res.stdout.strip()
    except Exception:
        pass

    # Try Git Credential Manager
    try:
        proc = subprocess.Popen(
            ["git", "-c", "credential.interactive=never", "credential", "fill"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        out, _ = proc.communicate("protocol=https\nhost=github.com\n\n")
        for line in out.splitlines():
            if line.startswith("password="):
                tok = line.split("=", 1)[1].strip()
                if tok:
                    return tok
    except Exception:
        pass

    return ""


def check_token(token: str) -> bool:
    """Check token scopes and user info. Returns True if gist scope is present."""
    req = urllib.request.Request(
        "https://api.github.com/user",
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "User-Agent": "GitMap-Muse-Publisher",
            "X-GitHub-Api-Version": "2022-11-28",
        }
    )
    try:
        with urllib.request.urlopen(req) as resp:
            headers = resp.headers
            scopes = headers.get("X-OAuth-Scopes", "")
            user_data = json.loads(resp.read().decode("utf-8"))
            login = user_data.get("login", "")
            has_gist = "gist" in [s.strip().lower() for s in scopes.split(",") if s.strip()]
            print(f"[OK] Authenticated as {login}. Token scopes: [{scopes}] (has_gist={has_gist})")
            return has_gist
    except urllib.error.HTTPError as e:
        print(f"[WARN] Error checking user: {e.code} {e.reason}", file=sys.stderr)
        return False


def publish_gist(token: str, filename: str, content: str, description: str, is_public: bool, gist_id: str = "") -> dict:
    """Publish or update a gist via GitHub REST API."""
    if gist_id:
        url = f"https://api.github.com/gists/{gist_id}"
        method = "PATCH"
        payload = {
            "description": description,
            "files": {
                filename: {
                    "content": content
                }
            }
        }
    else:
        url = "https://api.github.com/gists"
        method = "POST"
        payload = {
            "description": description,
            "public": is_public,
            "files": {
                filename: {
                    "content": content
                }
            }
        }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={
            "Authorization": f"Bearer {token}",
            "Accept": "application/vnd.github+json",
            "Content-Type": "application/json",
            "User-Agent": "GitMap-Muse-Publisher",
            "X-GitHub-Api-Version": "2022-11-28",
        },
        method=method
    )

    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        err_body = e.read().decode("utf-8", errors="replace")
        print(f"HTTPError {e.code}: {e.reason}\n{err_body}", file=sys.stderr)
        raise


def main() -> None:
    token = resolve_github_token()
    if not token:
        print("[FAIL] Could not resolve GitHub token from environment, git config, or Git Credential Manager.", file=sys.stderr)
        sys.exit(1)

    print(f"[OK] Resolved GitHub token (length={len(token)}, prefix={token[:4]}...)")
    has_gist_scope = check_token(token)
    if not has_gist_scope:
        print("\n[NOTICE] The active GitHub Personal Access Token lacks the 'gist' OAuth scope.")
        print("  • To enable automated Gist publishing, grant 'gist' scope at: https://github.com/settings/tokens")
        print("  • Or supply a token with gist scope: $env:GH_TOKEN=\"<token_with_gist>\"; gitmap py 03-ai-scripts/74-publish-muse-gists.py")
        print("\n[FALLBACK] Raw repository links for Muse prompts:")
        print("  • General Prompt: https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/01-prompts/27-muse-prompts/general/01-muse-master-prompt.md")
        print("  • Private Prompt: https://raw.githubusercontent.com/alimtvnetwork/gitmap-v28/main/01-prompts/27-muse-prompts/private/01-muse-master-prompt.md")
        return

    repo_root = Path(__file__).resolve().parent.parent
    general_path = repo_root / "01-prompts" / "27-muse-prompts" / "general" / "01-muse-master-prompt.md"
    private_path = repo_root / "01-prompts" / "27-muse-prompts" / "private" / "01-muse-master-prompt.md"

    if not general_path.exists():
        print(f"[FAIL] Missing general prompt: {general_path}", file=sys.stderr)
        sys.exit(1)
    if not private_path.exists():
        print(f"[FAIL] Missing private prompt: {private_path}", file=sys.stderr)
        sys.exit(1)

    general_content = general_path.read_text(encoding="utf-8")
    private_content = private_path.read_text(encoding="utf-8")

    out_file = repo_root / ".ai-memory" / "temp-agents" / "muse-gists.json"
    existing_gen_id = ""
    existing_priv_id = ""
    if out_file.exists():
        try:
            prev = json.loads(out_file.read_text(encoding="utf-8"))
            existing_gen_id = prev.get("general", {}).get("gist_id", "")
            existing_priv_id = prev.get("private", {}).get("gist_id", "")
        except Exception:
            pass

    action_gen = "Updating" if existing_gen_id else "Publishing"
    print(f"\n1. {action_gen} Muse General Prompt (Public Gist: {existing_gen_id or 'new'})...")
    res_gen = publish_gist(
        token=token,
        filename="01-muse-master-prompt-general.md",
        content=general_content,
        description="Muse Master Prompt (General) — Onboarding, Fleet Orchestration & Autonomous Execution",
        is_public=True,
        gist_id=existing_gen_id,
    )
    gen_url = res_gen.get("html_url", "")
    gen_raw = res_gen.get("files", {}).get("01-muse-master-prompt-general.md", {}).get("raw_url", "")
    print(f"   ✓ Public Gist: {gen_url}")
    print(f"   ✓ Raw URL: {gen_raw}")

    action_priv = "Updating" if existing_priv_id else "Publishing"
    print(f"\n2. {action_priv} Muse Private Prompt (Secret Gist: {existing_priv_id or 'new'})...")
    res_priv = publish_gist(
        token=token,
        filename="01-muse-master-prompt-private.md",
        content=private_content,
        description="Muse Master Prompt (Private) — MD ALIM UL KARIM",
        is_public=False,
        gist_id=existing_priv_id,
    )
    priv_url = res_priv.get("html_url", "")
    priv_raw = res_priv.get("files", {}).get("01-muse-master-prompt-private.md", {}).get("raw_url", "")
    print(f"   ✓ Secret Gist: {priv_url}")
    print(f"   ✓ Raw URL: {priv_raw}")

    # Output summary JSON
    summary = {
        "general": {
            "html_url": gen_url,
            "raw_url": gen_raw,
            "gist_id": res_gen.get("id", ""),
            "public": True
        },
        "private": {
            "html_url": priv_url,
            "raw_url": priv_raw,
            "gist_id": res_priv.get("id", ""),
            "public": False
        }
    }
    out_file = repo_root / ".ai-memory" / "temp-agents" / "muse-gists.json"
    out_file.parent.mkdir(parents=True, exist_ok=True)
    out_file.write_text(json.dumps(summary, indent=2), encoding="utf-8")
    print(f"\n[DONE] Saved gist publication record to {out_file}")


if __name__ == "__main__":
    main()
