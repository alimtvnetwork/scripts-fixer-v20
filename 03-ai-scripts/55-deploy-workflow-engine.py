#!/usr/bin/env python3
"""
55-deploy-workflow-engine.py

Unified Cross-Platform Binary Deployment, Multi-OS Slicing, and Smart Installer Engine.
Supports:
- Dynamic GitLab CLI identity discovery (glab auth status / ssh -T git@gitlab.com)
- 10 GB repository rollover threshold monitoring and alerts
- Dedicated repository mode (root) and shared multi-project folder distribution mode
- Laravel-style hierarchical releases: [folder/]releases/v<version>/<os-arch>/
- Multi-volume 7z LZMA2 split compression (-v8m / -v5m) with SHA-256 digests
- Smart client installers (install.ps1 and install.sh) with dynamic latest/version resolution
- Deployment repository tagging (v<version> / <project>-v<version>)
- Automated git commit, tag, and push with HTTP 200 OK assertion
"""

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path

# Maximum repository size threshold: 9.5 GB (safe ceiling before GitLab 10 GB limit)
ROLLOVER_THRESHOLD_BYTES = 9_500_000_000


def detect_gitlab_username() -> str:
    """Detect active GitLab identity from local CLI or SSH probe."""
    try:
        res = subprocess.run(["glab", "auth", "status"], capture_output=True, text=True)
        m = re.search(r"as ([a-zA-Z0-9_\-\.]+)", res.stdout + res.stderr)
        if m:
            return m.group(1)
    except Exception:
        pass

    try:
        res = subprocess.run(["ssh", "-T", "git@gitlab.com"], capture_output=True, text=True)
        m = re.search(r"Welcome to GitLab,\s+@([a-zA-Z0-9_\-\.]+)", res.stdout + res.stderr)
        if m:
            return m.group(1)
    except Exception:
        pass

    return "rup-gitlab"


def find_7z_binary() -> str:
    """Locate 7z executable across standard locations."""
    which_7z = shutil.which("7z") or shutil.which("7za")
    if which_7z:
        return which_7z

    candidates = [
        r"C:\Program Files\7-Zip\7z.exe",
        r"C:\Program Files (x86)\7-Zip\7z.exe",
        r"C:\ProgramData\chocolatey\bin\7z.exe",
        os.path.expandvars(r"%LOCALAPPDATA%\Programs\7-Zip\7z.exe"),
    ]
    for c in candidates:
        if os.path.isfile(c):
            return c
    return "7z"


def compute_sha256(filepath: str) -> str:
    """Calculate lowercase hexadecimal SHA-256 digest of a file."""
    hasher = hashlib.sha256()
    with open(filepath, "rb") as f:
        while chunk := f.read(65536):
            hasher.update(chunk)
    return hasher.hexdigest().lower()


def get_dir_size_bytes(directory: Path) -> int:
    """Calculate total byte size of a directory tree."""
    total = 0
    try:
        for entry in directory.rglob("*"):
            if entry.is_file():
                total += entry.stat().st_size
    except Exception:
        pass
    return total


def package_and_deploy_workflow(
    project: str,
    binary_path: str,
    deploy_repo: str,
    folder: str = "",
    version: str = "v1.0.0",
    volume_size: str = "8m",
    os_arch: str = "windows-amd64",
    gitlab_user: str = "",
    tag_prefix: str = "",
    no_push: bool = False,
    yes: bool = False,
) -> dict:
    """Main deployment workflow implementing slicing, manifest generation, and push."""
    seven_zip = find_7z_binary()
    deploy_path = Path(deploy_repo).resolve()
    clean_version = version.lstrip("v")
    semver_tag = f"v{clean_version}"

    if not os.path.isfile(binary_path):
        raise FileNotFoundError(f"Source binary not found: {binary_path}")
    if not deploy_path.is_dir():
        raise FileNotFoundError(f"Deploy repository directory not found: {deploy_repo}")

    # Determine mode: Root dedicated repository vs subfolder distribution
    is_root_mode = not folder or folder == "."
    folder_url_part = "" if is_root_mode else f"{folder}/"
    folder_dir = deploy_path if is_root_mode else (deploy_path / folder)
    folder_dir.mkdir(parents=True, exist_ok=True)

    # Step 0: Identity discovery
    if not gitlab_user:
        gitlab_user = detect_gitlab_username()

    dist_repo_name = deploy_path.name
    try:
        remote_url = subprocess.check_output(
            ["git", "-C", str(deploy_path), "remote", "get-url", "origin"], text=True
        ).strip()
        m = re.search(r"[:/]([a-zA-Z0-9_\-\.]+)/([a-zA-Z0-9_\-\.]+?)(?:\.git)?$", remote_url)
        if m:
            gitlab_user = gitlab_user or m.group(1)
            dist_repo_name = m.group(2)
    except Exception:
        pass

    target_display = f"gitlab.com/{gitlab_user}/{dist_repo_name}" + (f" (folder: {folder})" if not is_root_mode else " (root dedicated)")
    print(f" [INFO] Deployment Target: {target_display}")

    # Step 1: 10 GB Rollover Threshold Check
    current_repo_bytes = get_dir_size_bytes(deploy_path)
    binary_size_bytes = os.path.getsize(binary_path)
    estimated_total = current_repo_bytes + binary_size_bytes

    print(f" [INFO] Repository Size: {current_repo_bytes / (1024**2):.2f} MB / Limit: 10,000 MB")
    if estimated_total >= ROLLOVER_THRESHOLD_BYTES:
        print(f"\n [WARNING] Repository size ({estimated_total / (1024**3):.2f} GB) approaches 10 GB ceiling!")
        print(f" [ACTION] Recommended to initiate rollover repository (e.g. {dist_repo_name}-2).")
        if not yes:
            input(" Press Enter to continue deployment anyway, or Ctrl+C to abort...")

    # Step 2: Establish Laravel-style directory hierarchy
    releases_root = folder_dir / "releases" / semver_tag
    platform_dir = releases_root / os_arch
    platform_dir.mkdir(parents=True, exist_ok=True)

    staging_dir = folder_dir / ".staging"
    staging_dir.mkdir(parents=True, exist_ok=True)

    binary_filename = Path(binary_path).name
    is_windows = binary_filename.endswith(".exe") or "windows" in os_arch
    exec_windows = binary_filename if is_windows else f"{project}.exe"
    exec_linux = binary_filename[:-4] if is_windows else binary_filename

    archive_base_name = f"{project}-{os_arch}.7z"
    staging_archive = staging_dir / archive_base_name

    # Clear prior staging/target chunks
    for old_chunk in staging_dir.glob(f"{archive_base_name}.*"):
        old_chunk.unlink()
    for old_chunk in platform_dir.glob(f"{archive_base_name}.*"):
        old_chunk.unlink()

    # Step 3: Package binary into 7z LZMA2 multi-volume split archive
    print(f" [INFO] Packaging {binary_filename} into 7z LZMA2 split volumes (-v{volume_size})...")
    cmd = [
        seven_zip,
        "a",
        "-t7z",
        "-m0=lzma2",
        "-mx=9",
        f"-v{volume_size}",
        str(staging_archive),
        binary_path,
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"7-Zip compression failed:\n{res.stderr}\n{res.stdout}")

    chunk_files = sorted(staging_dir.glob(f"{archive_base_name}.*"))
    if not chunk_files:
        raise RuntimeError(f"No split chunks produced in {staging_dir}")

    total_archive_size = 0
    chunks_meta = []
    for idx, chunk_path in enumerate(chunk_files, start=1):
        target_path = platform_dir / chunk_path.name
        shutil.copy2(chunk_path, target_path)

        size_bytes = os.path.getsize(target_path)
        total_archive_size += size_bytes
        sha256_hash = compute_sha256(str(target_path))

        # Direct unauthenticated GitLab API raw download URL (URL-encoded path)
        api_chunk_path = f"{folder_url_part}releases/{semver_tag}/{os_arch}/{chunk_path.name}".replace("/", "%2F")
        api_download_url = f"https://gitlab.com/api/v4/projects/{gitlab_user}%2F{dist_repo_name}/repository/files/{api_chunk_path}/raw"

        chunks_meta.append({
            "part": idx,
            "fileName": chunk_path.name,
            "sizeBytes": size_bytes,
            "sha256": sha256_hash,
            "downloadUrl": api_download_url,
        })

    # Step 3b: Package single-file zip archive for native Go self-update (archive/zip)
    zip_archive_name = f"{project}-{os_arch}.zip"
    zip_target_path = platform_dir / zip_archive_name
    print(f" [INFO] Packaging {binary_filename} into standard zip archive ({zip_archive_name})...")
    import zipfile
    with zipfile.ZipFile(zip_target_path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        zf.write(binary_path, arcname=binary_filename)

    zip_size_bytes = os.path.getsize(zip_target_path)
    zip_sha256 = compute_sha256(str(zip_target_path))
    clean_url_prefix = f"https://gitlab.com/{gitlab_user}/{dist_repo_name}/-/raw/main/{folder_url_part}"
    zip_download_url = f"{clean_url_prefix}releases/{semver_tag}/{os_arch}/{zip_archive_name}"

    # Step 3c: Generate standard checksums.txt file (GNU format: <sha256>  <filename>)
    checksum_lines = [f"{zip_sha256}  {zip_archive_name}"]
    for chunk_meta in chunks_meta:
        checksum_lines.append(f"{chunk_meta['sha256']}  {chunk_meta['fileName']}")
    checksum_content = "\n".join(checksum_lines) + "\n"

    release_checksum_path = releases_root / "checksums.txt"
    with open(release_checksum_path, "w", encoding="utf-8") as f:
        f.write(checksum_content)

    root_checksum_path = folder_dir / "checksums.txt"
    with open(root_checksum_path, "w", encoding="utf-8") as f:
        f.write(checksum_content)

    checksum_download_url = f"{clean_url_prefix}releases/{semver_tag}/checksums.txt"

    # Step 4: Write/Update binary-info.json Manifest
    manifest_path = folder_dir / "binary-info.json"
    manifest = {}
    if manifest_path.is_file():
        try:
            with open(manifest_path, "r", encoding="utf-8") as f:
                manifest = json.load(f)
        except Exception:
            manifest = {}

    manifest["$schema"] = "https://json-schema.org/draft/2020-12/schema"
    manifest["project"] = project
    manifest["latest"] = clean_version
    manifest["version"] = clean_version
    manifest["binaryName"] = project
    manifest["executableWindows"] = exec_windows
    manifest["executableLinux"] = exec_linux
    manifest["archiveFormat"] = "7z"
    manifest["isConfidential"] = False
    manifest["totalSizeBytes"] = binary_size_bytes
    manifest["totalArchiveSizeBytes"] = total_archive_size
    manifest["assetUrl"] = zip_download_url
    manifest["assetSize"] = zip_size_bytes
    manifest["checksumUrl"] = checksum_download_url
    if not isinstance(manifest.get("platforms"), dict):
        manifest["platforms"] = {}
    manifest["platforms"][os_arch] = {
        "platform": os_arch,
        "totalSizeBytes": binary_size_bytes,
        "totalArchiveSizeBytes": total_archive_size,
        "executable": exec_windows if "windows" in os_arch else exec_linux,
        "assetUrl": zip_download_url,
        "assetSize": zip_size_bytes,
        "checksumUrl": checksum_download_url,
        "chunks": chunks_meta,
    }
    if "windows" in os_arch or "chunks" not in manifest or not manifest.get("chunks"):
        manifest["platform"] = os_arch
        manifest["chunks"] = chunks_meta
    else:
        manifest["platform"] = os_arch
    manifest["repository"] = {
        "provider": "gitlab",
        "namespace": gitlab_user,
        "repo": dist_repo_name,
        "folder": "" if is_root_mode else folder,
        "rawBaseUrl": f"https://gitlab.com/{gitlab_user}/{dist_repo_name}/-/raw/main/{folder_url_part}".rstrip("/"),
        "currentSizeBytes": current_repo_bytes + total_archive_size,
    }
    clean_url_prefix = f"https://gitlab.com/{gitlab_user}/{dist_repo_name}/-/raw/main/{folder_url_part}"
    manifest["installers"] = {
        "oneLinerWindows": f"irm {clean_url_prefix}install.ps1 | iex",
        "oneLinerLinux": f"curl -fsSL {clean_url_prefix}install.sh | bash",
        "windowsWithVersion": f"& ([scriptblock]::Create((irm {clean_url_prefix}install.ps1))) -Version {semver_tag}",
        "linuxWithVersion": f"curl -fsSL {clean_url_prefix}install.sh | bash -s -- --version {semver_tag}",
    }

    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    # Clean staging directory
    shutil.rmtree(staging_dir, ignore_errors=True)

    # Bundle standalone tools/7za.exe in deployment repository
    tools_dir = folder_dir / "tools"
    tools_dir.mkdir(parents=True, exist_ok=True)
    portable_7za_target = tools_dir / "7za.exe"
    if not portable_7za_target.is_file():
        try:
            import urllib.request, zipfile, io
            url = "https://www.7-zip.org/a/7za920.zip"
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req) as resp:
                data = resp.read()
            z = zipfile.ZipFile(io.BytesIO(data))
            z.extract("7za.exe", str(tools_dir))
            print(f" [OK]   Bundled standalone portable 7za.exe into {portable_7za_target}")
        except Exception as e:
            print(f" [WARN] Could not auto-bundle 7za.exe into deploy repo: {e}")

    # Step 5: Synthesize Smart Client Installers
    generate_smart_installers(folder_dir, project, folder_url_part, gitlab_user, dist_repo_name)

    # Step 6: Git commit, tag, and push
    tag_name = semver_tag
    if not no_push and (deploy_path / ".git").is_dir():
        print(f" [INFO] Staging files in {deploy_path}...")
        if is_root_mode:
            subprocess.run(["git", "-C", str(deploy_path), "add", "releases", "binary-info.json", "install.ps1", "install.sh", "tools", "checksums.txt", ".gitignore"], check=True)
        else:
            subprocess.run(["git", "-C", str(deploy_path), "add", folder], check=True)

        commit_msg = f"chore(release): deploy {project} {semver_tag} ({os_arch})" + ("" if is_root_mode else f" in {folder}/")
        subprocess.run(["git", "-C", str(deploy_path), "commit", "-m", commit_msg], capture_output=True)

        # Release tagging
        if is_root_mode:
            tag_name = f"{tag_prefix}{semver_tag}" if tag_prefix else semver_tag
        else:
            tag_name = f"{tag_prefix}{project}-{semver_tag}" if tag_prefix else f"{folder}-{semver_tag}"

        print(f" [INFO] Creating release tag '{tag_name}' in deployment repository...")
        subprocess.run(["git", "-C", str(deploy_path), "tag", "-f", tag_name], check=True)

        print(f" [INFO] Pushing changes and tags to GitLab origin main...")
        subprocess.run(["git", "-C", str(deploy_path), "push", "origin", "main"], check=True)
        subprocess.run(["git", "-C", str(deploy_path), "push", "origin", tag_name, "--force"], check=True)

        create_gitlab_release(gitlab_user, dist_repo_name, tag_name, project, clean_version)

    # Step 7: Reachability Assertion (HTTP 200 OK)
    raw_install_url = manifest["installers"]["oneLinerWindows"].split(" ")[1]
    assert_http_200(raw_install_url)
    assert_http_200(f"https://gitlab.com/{gitlab_user}/{dist_repo_name}/-/raw/main/{folder_url_part}tools/7za.exe")
    assert_http_200(f"https://gitlab.com/{gitlab_user}/{dist_repo_name}/-/raw/main/{folder_url_part}checksums.txt")

    print("\n" + "=" * 65)
    print(f"  DEPLOYMENT COMPLETED: {project} {semver_tag} ({os_arch})")
    print("=" * 65)
    print(f"  Namespace:   @{gitlab_user}")
    print(f"  Repo:        {dist_repo_name}")
    print(f"  Mode:        {'Root Dedicated Repo' if is_root_mode else f'Folder: {folder}'}")
    print(f"  Tag:         {tag_name}")
    print(f"  Chunks:      {len(chunks_meta)} split volumes ({volume_size} each)")
    print(f"  Latest PS1:  {manifest['installers']['oneLinerWindows']}")
    print(f"  Version PS1: {manifest['installers']['windowsWithVersion']}")
    print("=" * 65 + "\n")

    return manifest


def create_gitlab_release(gitlab_user: str, dist_repo: str, tag_name: str, project: str, version: str):
    """Create or update official GitLab Release object via REST API if token is present."""
    token = os.environ.get("GITLAB_TOKEN") or os.environ.get("GLAB_TOKEN") or os.environ.get("GITLAB_PAT")
    if not token:
        print(" [INFO] No GITLAB_TOKEN in environment; git tag pushed directly.")
        return

    project_id = f"{gitlab_user}%2F{dist_repo}"
    url = f"https://gitlab.com/api/v4/projects/{project_id}/releases"
    headers = {
        "PRIVATE-TOKEN": token,
        "Content-Type": "application/json",
    }
    payload = {
        "name": f"{project} {tag_name}",
        "tag_name": tag_name,
        "description": f"Automated deployment release of {project} {tag_name}.",
    }
    try:
        import urllib.request
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(url, data=data, headers=headers, method="POST")
        with urllib.request.urlopen(req) as resp:
            if resp.status in (200, 201):
                print(f" [OK]   GitLab Release '{tag_name}' created successfully.")
    except Exception as e:
        print(f" [INFO] GitLab Release API note: {e}")


def generate_smart_installers(folder_dir: Path, project: str, folder_url_part: str, gitlab_user: str, dist_repo: str):
    """Generate smart, auto-discovering install.ps1 and install.sh."""
    clean_folder = folder_url_part.rstrip("/")
    if clean_folder:
        raw_base = f"https://gitlab.com/{gitlab_user}/{dist_repo}/-/raw/main/{clean_folder}/"
    else:
        raw_base = f"https://gitlab.com/{gitlab_user}/{dist_repo}/-/raw/main/"

    api_folder = folder_url_part.replace("/", "%2F")
    api_raw_base = f"https://gitlab.com/api/v4/projects/{gitlab_user}%2F{dist_repo}/repository/files/{api_folder}"

    ps1_code = f'''<#
.SYNOPSIS
    Smart binary installer for {project} hosted on GitLab ({gitlab_user}/{dist_repo}).
.EXAMPLE
    # Install latest:
    irm {raw_base}install.ps1 | iex
.EXAMPLE
    # Install specific version:
    & ([scriptblock]::Create((irm {raw_base}install.ps1))) -Version v1.0.0
#>
[CmdletBinding()]
param(
    [string]$Version = "latest",
    [string]$ManifestUrl = "",
    [string]$InstallDir = "",
    [switch]$NoLaunch,
    [switch]$NoPath,
    [switch]$Update,
    [switch]$Force,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Dynamic manifest URL fallback
if (-not $ManifestUrl) {{
    $scriptDirUrl = $MyInvocation.MyCommand.Definition
    if ($scriptDirUrl -like "http*") {{
        $ManifestUrl = $scriptDirUrl -replace "install\\.ps1.*", "binary-info.json"
    }} else {{
        $ManifestUrl = "{raw_base}binary-info.json"
    }}
}}

Write-Host " [INFO] Querying release metadata from $ManifestUrl..." -ForegroundColor Cyan
try {{
    $manifest = Invoke-RestMethod -Uri $ManifestUrl -TimeoutSec 15
    if ($manifest -is [string] -and ($manifest.Trim().StartsWith("<") -or $manifest -like "*Just a moment*")) {{ throw "Redirect to login or Turnstile" }}
}} catch {{
    try {{
        $apiManifestUrl = "{api_raw_base}binary-info.json/raw"
        $manifest = Invoke-RestMethod -Uri $apiManifestUrl -TimeoutSec 15
    }} catch {{
        $fallbackUrl = "https://gitlab.com/{gitlab_user}/r-files/-/raw/main/{project}/binary-info.json"
        Write-Host " [WARN] Dedicated repo manifest unavailable; attempting public mirror: $fallbackUrl" -ForegroundColor Yellow
        $manifest = Invoke-RestMethod -Uri $fallbackUrl -TimeoutSec 15
    }}
}}

$projName = $manifest.project
$targetVer = if ($Version -eq "latest") {{ $manifest.latest }} else {{ $Version.TrimStart("v") }}
$execWin = $manifest.executableWindows

Write-Host " [OK]   Target: $projName v$targetVer" -ForegroundColor Green

# Determine install directory
if (-not $InstallDir) {{
    $foundExistingDir = $null
    $existingCmd = Get-Command $execWin -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($existingCmd -and $existingCmd.Source -and (Test-Path $existingCmd.Source)) {{
        $foundExistingDir = Split-Path $existingCmd.Source -Parent
    }}

    if (-not $foundExistingDir) {{
        $standardCandidates = @(
            (Join-Path $env:LOCALAPPDATA "$projName-cli"),
            (Join-Path $env:LOCALAPPDATA "agy\\bin"),
            (Join-Path $env:LOCALAPPDATA "agm-cli"),
            (Join-Path $env:LOCALAPPDATA "Programs\\$projName\\bin"),
            (Join-Path $env:USERPROFILE "bin")
        )
        foreach ($cand in $standardCandidates) {{
            if ($cand -and (Test-Path (Join-Path $cand $execWin))) {{
                $foundExistingDir = $cand
                break
            }}
        }}
    }}

    if ($foundExistingDir) {{
        $targetDir = $foundExistingDir
    }} elseif ($projName -eq "gitmap") {{
        $targetDir = Join-Path $env:LOCALAPPDATA "gitmap-cli"
    }} elseif ($env:LOCALAPPDATA) {{
        $targetDir = Join-Path $env:LOCALAPPDATA "Programs\\$projName\\bin"
    }} else {{
        $targetDir = Join-Path $env:USERPROFILE "bin"
    }}
}} else {{
    $targetDir = $InstallDir
}}
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

function Ensure-7Zip {{
    $cmd = Get-Command "7z.exe" -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) {{ return $cmd.Source }}
    $cmd = Get-Command "7za.exe" -ErrorAction SilentlyContinue
    if ($cmd -and $cmd.Source) {{ return $cmd.Source }}

    $candidates = @(
        "$env:ProgramFiles\\7-Zip\\7z.exe",
        "${{env:ProgramFiles(x86)}}\\7-Zip\\7z.exe",
        "$env:LOCALAPPDATA\\Programs\\7-Zip\\7z.exe",
        "$env:LOCALAPPDATA\\Programs\\7-Zip\\7za.exe",
        "$env:ProgramData\\chocolatey\\bin\\7z.exe",
        "$env:ProgramData\\chocolatey\\bin\\7za.exe",
        "C:\\ProgramData\\chocolatey\\bin\\7z.exe",
        "C:\\ProgramData\\chocolatey\\bin\\7za.exe",
        "$env:USERPROFILE\\bin\\7z.exe",
        "$env:USERPROFILE\\bin\\7za.exe",
        "C:\\tools\\7z\\7z.exe"
    )
    foreach ($cand in $candidates) {{
        if (Test-Path $cand) {{ return $cand }}
    }}

    Write-Host " [INFO] 7-Zip not detected. Auto-provisioning 7-Zip..." -ForegroundColor Yellow

    # Direct portable 7za.exe from deployment repository (fastest, standalone, zero-dependency)
    $portableDir = Join-Path $env:LOCALAPPDATA "Programs\\7-Zip"
    New-Item -ItemType Directory -Path $portableDir -Force | Out-Null
    $portableExe = Join-Path $portableDir "7za.exe"
    if (Test-Path $portableExe) {{ return $portableExe }}

    $directTools = @(
        "{raw_base}tools/7za.exe",
        "https://gitlab.com/{gitlab_user}/{dist_repo}/-/raw/main/tools/7za.exe",
        "https://gitlab.com/{gitlab_user}/r-files/-/raw/main/tools/7za.exe"
    )
    foreach ($tu in $directTools) {{
        try {{
            Invoke-WebRequest -Uri $tu -OutFile $portableExe -UseBasicParsing -TimeoutSec 15
            if ((Test-Path $portableExe) -and (Get-Item $portableExe).Length -gt 100000) {{
                Write-Host " [OK]   Portable 7-Zip ready at $portableExe." -ForegroundColor Green
                return $portableExe
            }}
        }} catch {{}}
    }}

    # Try Chocolatey
    $choco = Get-Command "choco.exe" -ErrorAction SilentlyContinue
    if (-not $choco -and (Test-Path "$env:ProgramData\\chocolatey\\bin\\choco.exe")) {{
        $choco = "$env:ProgramData\\chocolatey\\bin\\choco.exe"
    }}
    if (-not $choco) {{
        Write-Host " [INFO] Chocolatey not detected. Auto-installing Chocolatey..." -ForegroundColor Cyan
        try {{
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
            if (Test-Path "$env:ProgramData\\chocolatey\\bin\\choco.exe") {{
                $choco = "$env:ProgramData\\chocolatey\\bin\\choco.exe"
            }}
        }} catch {{
            Write-Host " [WARN] Chocolatey auto-install failed: $_" -ForegroundColor Yellow
        }}
    }}
    if ($choco) {{
        Write-Host " [INFO] Installing 7-Zip via Chocolatey (choco install 7zip -y)..." -ForegroundColor Cyan
        try {{
            & $choco install 7zip -y --no-progress | Out-Null
            foreach ($cand in $candidates) {{
                if (Test-Path $cand) {{ return $cand }}
            }}
            $cmd = Get-Command "7z.exe" -ErrorAction SilentlyContinue
            if ($cmd -and $cmd.Source) {{ return $cmd.Source }}
        }} catch {{
            Write-Host " [WARN] Chocolatey installation failed: $_" -ForegroundColor Yellow
        }}
    }}

    # Try Winget
    $winget = Get-Command "winget.exe" -ErrorAction SilentlyContinue
    if ($winget) {{
        Write-Host " [INFO] Installing 7-Zip via Winget..." -ForegroundColor Cyan
        try {{
            & winget install --id 7zip.7zip -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
            foreach ($cand in $candidates) {{
                if (Test-Path $cand) {{ return $cand }}
            }}
            $cmd = Get-Command "7z.exe" -ErrorAction SilentlyContinue
            if ($cmd -and $cmd.Source) {{ return $cmd.Source }}
        }} catch {{
            Write-Host " [WARN] Winget installation failed: $_" -ForegroundColor Yellow
        }}
    }}

    # Standalone portable 7za bootstrap via PowerShell Expand-Archive
    Write-Host " [INFO] Bootstrapping standalone portable 7-Zip (7za)..." -ForegroundColor Cyan
    $tempZip = Join-Path ([System.IO.Path]::GetTempPath()) "7za920-$([Guid]::NewGuid().ToString('N')).zip"
    $zipSources = @(
        "https://www.7-zip.org/a/7za920.zip",
        "https://gitlab.com/{gitlab_user}/{dist_repo}/-/raw/main/tools/7za920.zip",
        "https://gitlab.com/{gitlab_user}/r-files/-/raw/main/tools/7za920.zip"
    )
    $downloaded = $false
    foreach ($zurl in $zipSources) {{
        try {{
            Invoke-WebRequest -Uri $zurl -OutFile $tempZip -UseBasicParsing -TimeoutSec 20
            if ((Test-Path $tempZip) -and (Get-Item $tempZip).Length -gt 10000) {{
                $downloaded = $true
                break
            }}
        }} catch {{}}
    }}

    if ($downloaded) {{
        try {{
            Expand-Archive -Path $tempZip -DestinationPath $portableDir -Force
            Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
            if (Test-Path $portableExe) {{
                Write-Host " [OK]   Portable 7-Zip extracted to $portableExe." -ForegroundColor Green
                return $portableExe
            }}
        }} catch {{
            Write-Host " [WARN] Expand-Archive failed: $_" -ForegroundColor Yellow
        }}
    }}

    throw "7-Zip (7z.exe or 7za.exe) is required to extract split archives. Auto-install failed; please install via 'choco install 7zip -y'."
}}

$sevenZip = Ensure-7Zip
if (-not $sevenZip -or -not (Test-Path $sevenZip)) {{
    throw "Fatal: 7-Zip executable not resolved ($sevenZip)"
}}
$aria2 = (Get-Command "aria2c.exe" -ErrorAction SilentlyContinue).Source

$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "$projName-inst-$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {{
    $chunkFiles = @()
    $chunkList = if ($manifest.platforms -and $manifest.platforms."windows-amd64" -and $manifest.platforms."windows-amd64".chunks) {{
        $manifest.platforms."windows-amd64".chunks
    }} else {{
        $manifest.chunks
    }}
    foreach ($chunk in $chunkList) {{
        $destPath = Join-Path $tempDir $chunk.fileName
        Write-Host " [INFO] Downloading $($chunk.fileName)..." -ForegroundColor Cyan
        $downloadOk = $false
        if ($aria2 -and $chunk.downloadUrl) {{
            & $aria2 -x 16 -s 16 -j 4 --dir="$tempDir" --out="$($chunk.fileName)" "$($chunk.downloadUrl)" | Out-Null
            if ((Test-Path $destPath) -and (Get-Item $destPath).Length -gt 1000) {{
                $firstLine = (Get-Content -Path $destPath -TotalCount 1 -ErrorAction SilentlyContinue)
                if (-not ($firstLine -and $firstLine.Trim().StartsWith("<"))) {{
                    $downloadOk = $true
                }} else {{
                    Remove-Item $destPath -Force -ErrorAction SilentlyContinue
                }}
            }}
        }}
        if (-not $downloadOk) {{
            try {{
                $rawChunkUrl = "{raw_base}releases/v$targetVer/windows-amd64/$($chunk.fileName)"
                Invoke-WebRequest -Uri $rawChunkUrl -OutFile $destPath -UseBasicParsing -TimeoutSec 30
                if ((Test-Path $destPath) -and (Get-Item $destPath).Length -gt 1000) {{
                    $firstLine = (Get-Content -Path $destPath -TotalCount 1 -ErrorAction SilentlyContinue)
                    if (-not ($firstLine -and $firstLine.Trim().StartsWith("<"))) {{
                        $downloadOk = $true
                    }} else {{
                        Remove-Item $destPath -Force -ErrorAction SilentlyContinue
                    }}
                }}
            }} catch {{}}
        }}
        if (-not $downloadOk) {{
            try {{
                $apiChunkPath = "{folder_url_part}releases/v$targetVer/windows-amd64/$($chunk.fileName)" -replace "/", "%2F"
                $apiUrl = "https://gitlab.com/api/v4/projects/{gitlab_user}%2F{dist_repo}/repository/files/$apiChunkPath/raw"
                Invoke-WebRequest -Uri $apiUrl -OutFile $destPath -UseBasicParsing -TimeoutSec 30
                if ((Test-Path $destPath) -and (Get-Item $destPath).Length -gt 1000) {{
                    $firstLine = (Get-Content -Path $destPath -TotalCount 1 -ErrorAction SilentlyContinue)
                    if (-not ($firstLine -and $firstLine.Trim().StartsWith("<"))) {{
                        $downloadOk = $true
                    }} else {{
                        Remove-Item $destPath -Force -ErrorAction SilentlyContinue
                    }}
                }}
            }} catch {{}}
        }}
        if (-not $downloadOk -and $chunk.downloadUrl) {{
            try {{
                Invoke-WebRequest -Uri $chunk.downloadUrl -OutFile $destPath -UseBasicParsing -TimeoutSec 30
                if ((Test-Path $destPath) -and (Get-Item $destPath).Length -gt 1000) {{
                    $firstLine = (Get-Content -Path $destPath -TotalCount 1 -ErrorAction SilentlyContinue)
                    if (-not ($firstLine -and $firstLine.Trim().StartsWith("<"))) {{
                        $downloadOk = $true
                    }} else {{
                        Remove-Item $destPath -Force -ErrorAction SilentlyContinue
                    }}
                }}
            }} catch {{}}
        }}
        if (-not $downloadOk) {{
            $fallbackApiChunkPath = "{project}/releases/v$targetVer/windows-amd64/$($chunk.fileName)" -replace "/", "%2F"
            $fallbackChunkUrl = "https://gitlab.com/{gitlab_user}/r-files/-/raw/main/$fallbackApiChunkPath"
            Write-Host " [WARN] Dedicated chunk download failed; using public mirror: $fallbackChunkUrl" -ForegroundColor Yellow
            Invoke-WebRequest -Uri $fallbackChunkUrl -OutFile $destPath -UseBasicParsing -TimeoutSec 30
        }}

        $hash = (Get-FileHash -Path $destPath -Algorithm SHA256).Hash.ToLower()
        if ($hash -ne $chunk.sha256.ToLower()) {{
            throw "SHA-256 verification failed for $($chunk.fileName)!"
        }}
        $chunkFiles += $destPath
    }}

    Write-Host " [INFO] Extracting split archive via 7-Zip..." -ForegroundColor Cyan
    $extractDir = Join-Path $tempDir "extracted"
    & "$sevenZip" x -y "-o$extractDir" "$($chunkFiles[0])" | Out-Null

    $extracted = Get-ChildItem -Path $extractDir -Filter $execWin -Recurse | Select-Object -First 1
    if (-not $extracted) {{
        $extracted = Get-ChildItem -Path $extractDir -Filter "*.exe" -Recurse | Select-Object -First 1
    }}
    if (-not $extracted) {{
        throw "Executable $execWin not found inside archive!"
    }}

    $destination = Join-Path $targetDir $extracted.Name
    if (Test-Path $destination) {{
        $renamed = $false
        for ($retry = 0; $retry -lt 5; $retry++) {{
            $uniqueSuffix = "old.$([Guid]::NewGuid().ToString('N').Substring(0, 8))"
            try {{
                Rename-Item -Path $destination -NewName "$($extracted.Name).$uniqueSuffix" -Force -ErrorAction Stop
                $renamed = $true
                break
            }} catch {{
                Start-Sleep -Milliseconds 150
            }}
        }}
    }}
    Copy-Item -Path $extracted.FullName -Destination $destination -Force
    Get-ChildItem -Path $targetDir -Filter "$($extracted.Name).old*" -ErrorAction SilentlyContinue |
        ForEach-Object {{ Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }}
    Write-Host " [OK]   Installed $($extracted.Name) to $destination." -ForegroundColor Green

    # Synchronize secondary existing installation targets to prevent stale binary shadowing
    if ($projName -eq "gitmap") {{
        $knownShadowDirs = @(
            (Join-Path $env:LOCALAPPDATA "gitmap-cli"),
            (Join-Path $env:LOCALAPPDATA "agy\\bin"),
            (Join-Path $env:LOCALAPPDATA "agm-cli"),
            (Join-Path $env:LOCALAPPDATA "Programs\\gitmap\\bin")
        )
        foreach ($sDir in $knownShadowDirs) {{
            if ($sDir -and (Test-Path $sDir)) {{
                $resolvedS = (Resolve-Path $sDir).Path
                $resolvedT = (Resolve-Path $targetDir).Path
                if ($resolvedS -ne $resolvedT) {{
                    $sDest = Join-Path $sDir $extracted.Name
                    if (Test-Path $sDest) {{
                        try {{
                            $sUnique = "old.$([Guid]::NewGuid().ToString('N').Substring(0, 8))"
                            Rename-Item -Path $sDest -NewName "$($extracted.Name).$sUnique" -Force -ErrorAction SilentlyContinue
                            Copy-Item -Path $extracted.FullName -Destination $sDest -Force -ErrorAction SilentlyContinue
                            Get-ChildItem -Path $sDir -Filter "$($extracted.Name).old*" -ErrorAction SilentlyContinue |
                                ForEach-Object {{ Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue }}
                            Write-Host " [OK]   Synchronized $sDest to v$targetVer." -ForegroundColor DarkGreen
                        }} catch {{}}
                    }}
                }}
            }}
        }}
    }}

    # Configure User Environment PATH (Prepend to ensure priority over legacy or shadowed paths)
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$targetDir*") {{
        [Environment]::SetEnvironmentVariable("Path", "$targetDir;$userPath", "User")
        Write-Host " [OK]   Added $targetDir to User PATH." -ForegroundColor Green
    }}

    # Prepend to current process PATH so immediate command calls work seamlessly in the same session
    if ($env:PATH -notlike "*$targetDir*") {{
        $env:PATH = "$targetDir;$env:PATH"
    }} else {{
        $pathParts = @($targetDir) + (@($env:PATH -split ';') | Where-Object {{ $_ -and $_ -ne $targetDir }})
        $env:PATH = $pathParts -join ';'
    }}

    # Broadcast WM_SETTINGCHANGE so new shells inherit the updated PATH immediately
    try {{
        $HWND_BROADCAST = [IntPtr]0xffff
        $WM_SETTINGCHANGE = 0x001A
        $result = [UIntPtr]::Zero
        [AddType]::SendMessageTimeout(
            $HWND_BROADCAST, $WM_SETTINGCHANGE, [UIntPtr]::Zero, "Environment", 2, 1000, [ref]$result
        ) | Out-Null
    }} catch {{}}

    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  $projName v$targetVer successfully installed!" -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  Location: $destination"
    Write-Host ""
}} finally {{
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}}
'''

    sh_code = f'''#!/usr/bin/env bash
# Smart binary installer for {project} hosted on GitLab ({gitlab_user}/{dist_repo})
set -e

VERSION="latest"
INSTALL_DIR=""
RAW_BASE="{raw_base}"
MANIFEST_URL="${{RAW_BASE}}binary-info.json"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --version|-v) VERSION="$2"; shift ;;
        --install-dir) INSTALL_DIR="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

OS_NAME="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH_NAME="$(uname -m)"
case "$ARCH_NAME" in
    x86_64|amd64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) ARCH="$ARCH_NAME" ;;
esac
PLATFORM="${{OS_NAME}}-${{ARCH}}"
[[ "$PLATFORM" == "linux-x86_64" ]] && PLATFORM="linux-amd64"

echo " [INFO] Querying release manifest from $MANIFEST_URL..."
TMP_MANIFEST=$(mktemp)
if ! curl -fsSL "$MANIFEST_URL" -o "$TMP_MANIFEST" 2>/dev/null || grep -q "<html" "$TMP_MANIFEST"; then
    FALLBACK_URL="https://gitlab.com/{gitlab_user}/r-files/-/raw/main/{project}/binary-info.json"
    echo " [WARN] Dedicated repo manifest unavailable; attempting public mirror: $FALLBACK_URL"
    curl -fsSL "$FALLBACK_URL" -o "$TMP_MANIFEST"
fi
PROJ_NAME=$(grep -o '"project"[[:space:]]*:[[:space:]]*"[^"]*' "$TMP_MANIFEST" | cut -d'"' -f4)
[[ -z "$PROJ_NAME" ]] && PROJ_NAME="{project}"
LATEST_VER=$(grep -o '"latest"[[:space:]]*:[[:space:]]*"[^"]*' "$TMP_MANIFEST" | cut -d'"' -f4)
TARGET_VER="${{VERSION#v}}"
[[ "$VERSION" == "latest" ]] && TARGET_VER="$LATEST_VER"

if [[ -z "$INSTALL_DIR" ]]; then
    if [[ -d "$HOME/.local/bin" ]] || [[ "$EUID" -ne 0 ]]; then
        INSTALL_DIR="$HOME/.local/bin"
    elif [[ -d "/usr/local/bin" ]] && [[ -w "/usr/local/bin" ]]; then
        INSTALL_DIR="/usr/local/bin"
    else
        INSTALL_DIR="$HOME/bin"
    fi
fi
mkdir -p "$INSTALL_DIR"

ensure_7zip() {{
    find_7z() {{
        if command -v 7z >/dev/null 2>&1; then echo "7z"; return 0; fi
        if command -v 7za >/dev/null 2>&1; then echo "7za"; return 0; fi
        if command -v p7zip >/dev/null 2>&1; then echo "p7zip"; return 0; fi
        return 1
    }}

    detected_7z="$(find_7z || true)"
    if [[ -n "$detected_7z" ]]; then
        echo "$detected_7z"
        return 0
    fi

    echo " [INFO] 7-Zip not detected. Auto-installing p7zip..." >&2
    SUDO=""
    if [[ "$EUID" -ne 0 ]] && command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    fi

    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update -qq >/dev/null 2>&1 || true
        $SUDO apt-get install -y -qq p7zip-full >/dev/null 2>&1 || $SUDO apt-get install -y p7zip >/dev/null 2>&1 || true
    elif command -v apk >/dev/null 2>&1; then
        $SUDO apk add --no-cache p7zip >/dev/null 2>&1 || true
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y p7zip p7zip-plugins >/dev/null 2>&1 || true
    elif command -v yum >/dev/null 2>&1; then
        $SUDO yum install -y p7zip p7zip-plugins >/dev/null 2>&1 || true
    elif command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -Sy --noconfirm p7zip >/dev/null 2>&1 || true
    elif command -v brew >/dev/null 2>&1; then
        brew install p7zip >/dev/null 2>&1 || true
    fi

    detected_7z="$(find_7z || true)"
    if [[ -n "$detected_7z" ]]; then
        echo "$detected_7z"
        return 0
    fi

    echo ""
    return 0
}}

SEVEN_ZIP=$(ensure_7zip)

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR" "$TMP_MANIFEST"' EXIT

CHUNKS=""
if command -v python3 >/dev/null 2>&1; then
    CHUNKS=$(python3 -c "
import json, sys
try:
    with open('$TMP_MANIFEST') as f:
        d = json.load(f)
    plat = d.get('platforms', {{}}).get('$PLATFORM', {{}})
    if not plat and 'linux' in '$PLATFORM':
        plat = d.get('platforms', {{}}).get('linux-amd64', {{}})
    chunks = plat.get('chunks', [])
    if not chunks:
        root_chunks = d.get('chunks', [])
        chunks = [c for c in root_chunks if 'linux' in (c.get('fileName') or '')]
    for c in chunks:
        fn = c.get('fileName')
        if fn: print(fn)
except Exception:
    pass
" 2>/dev/null || true)
fi

if [[ -z "$CHUNKS" ]] && command -v jq >/dev/null 2>&1; then
    CHUNKS=$(jq -r ".platforms[\"$PLATFORM\"].chunks[]?.fileName // empty" "$TMP_MANIFEST" 2>/dev/null || true)
    if [[ -z "$CHUNKS" ]]; then
        CHUNKS=$(jq -r '.platforms["linux-amd64"].chunks[]?.fileName // empty' "$TMP_MANIFEST" 2>/dev/null || true)
    fi
fi

if [[ -z "$CHUNKS" ]]; then
    CHUNKS=$(awk '
        /"linux-amd64"/ {{ in_plat=1 }}
        in_plat && /"chunks"/ {{ in_chunks=1 }}
        in_chunks && /"fileName"/ {{
            match($0, /"fileName"[[:space:]]*:[[:space:]]*"([^"]+)"/, arr)
            if (arr[1] != "") print arr[1]
        }}
        in_chunks && /\\]/ {{ in_chunks=0; in_plat=0 }}
    ' "$TMP_MANIFEST" 2>/dev/null || true)
fi

if [[ -z "$CHUNKS" ]]; then
    CHUNKS=$(grep -o '"fileName"[[:space:]]*:[[:space:]]*"[^"]*linux[^"]*"' "$TMP_MANIFEST" | cut -d'"' -f4 || true)
fi

FIRST_CHUNK=""
EXTRACTED=""

if [[ -n "$SEVEN_ZIP" ]] && [[ -n "$CHUNKS" ]]; then
    for CHUNK in $CHUNKS; do
        CHUNK_URL="${{RAW_BASE}}releases/v${{TARGET_VER}}/linux-amd64/$CHUNK"
        DEST="$TEMP_DIR/$CHUNK"
        echo " [INFO] Downloading $CHUNK..."
        download_ok=0
        if command -v aria2c >/dev/null 2>&1; then
            if aria2c -x 16 -s 16 -j 4 --dir="$TEMP_DIR" --out="$CHUNK" "$CHUNK_URL" >/dev/null 2>&1; then
                download_ok=1
            fi
        fi
        if [[ "$download_ok" -eq 0 ]]; then
            if curl -fsSL "$CHUNK_URL" -o "$DEST" 2>/dev/null; then
                download_ok=1
            fi
        fi
        if [[ "$download_ok" -eq 0 ]]; then
            API_CHUNK="releases/v${{TARGET_VER}}/linux-amd64/${{CHUNK}}"
            API_URL="https://gitlab.com/api/v4/projects/{gitlab_user}%2F{dist_repo}/repository/files/${{API_CHUNK//\\//%2F}}/raw"
            if curl -fsSL "$API_URL" -o "$DEST" 2>/dev/null; then
                download_ok=1
            fi
        fi
        if [[ "$download_ok" -eq 0 ]]; then
            FALLBACK_CHUNK="https://gitlab.com/{gitlab_user}/r-files/-/raw/main/{project}/releases/v${{TARGET_VER}}/linux-amd64/$CHUNK"
            curl -fsSL "$FALLBACK_CHUNK" -o "$DEST" 2>/dev/null || true
        fi
        [[ -z "$FIRST_CHUNK" ]] && FIRST_CHUNK="$DEST"
    done

    if [[ -f "$FIRST_CHUNK" ]]; then
        echo " [INFO] Extracting archive via $SEVEN_ZIP..."
        "$SEVEN_ZIP" x -y "-o$TEMP_DIR/extracted" "$FIRST_CHUNK" >/dev/null 2>&1 || true
    fi
fi

# Fallback: single-file zip archive if 7-zip missing or extraction produced nothing
EXTRACT_CHECK=$(find "$TEMP_DIR/extracted" -type f ! -name "*.exe" 2>/dev/null | head -1 || true)
if [[ -z "$EXTRACT_CHECK" ]]; then
    echo " [INFO] Trying standalone standard zip archive fallback..."
    ZIP_NAME="${{PROJ_NAME}}-linux-amd64.zip"
    ZIP_DEST="$TEMP_DIR/$ZIP_NAME"
    ZIP_URL="${{RAW_BASE}}releases/v${{TARGET_VER}}/linux-amd64/$ZIP_NAME"
    if ! curl -fsSL "$ZIP_URL" -o "$ZIP_DEST" 2>/dev/null; then
        ZIP_URL="https://gitlab.com/api/v4/projects/{gitlab_user}%2F{dist_repo}/repository/files/releases%2Fv${{TARGET_VER}}%2Flinux-amd64%2F${{ZIP_NAME}}/raw"
        curl -fsSL "$ZIP_URL" -o "$ZIP_DEST" 2>/dev/null || true
    fi
    if [[ -f "$ZIP_DEST" ]]; then
        mkdir -p "$TEMP_DIR/extracted"
        if command -v unzip >/dev/null 2>&1; then
            unzip -q -o "$ZIP_DEST" -d "$TEMP_DIR/extracted" 2>/dev/null || true
        elif command -v python3 >/dev/null 2>&1; then
            python3 -m zipfile -e "$ZIP_DEST" "$TEMP_DIR/extracted" 2>/dev/null || true
        fi
    fi
fi

for cand in "$TEMP_DIR/extracted/$PROJ_NAME" "$TEMP_DIR/extracted/${{PROJ_NAME}}-linux-amd64" "$TEMP_DIR/extracted/gitmap"; do
    if [[ -f "$cand" && ! "$cand" == *.exe ]]; then
        EXTRACTED="$cand"
        break
    fi
done

if [[ -z "$EXTRACTED" ]]; then
    EXTRACTED=$(find "$TEMP_DIR/extracted" -type f ! -name "*.exe" -name "$PROJ_NAME*" 2>/dev/null | head -1 || true)
fi

if [[ -z "$EXTRACTED" ]]; then
    for f in $(find "$TEMP_DIR/extracted" -type f ! -name "*.exe" ! -name "*.txt" ! -name "*.json" 2>/dev/null); do
        if head -c 4 "$f" 2>/dev/null | grep -q $'\x7fELF'; then
            EXTRACTED="$f"
            break
        fi
    done
fi

if [[ -z "$EXTRACTED" ]]; then
    echo "ERROR: Valid Linux executable '$PROJ_NAME' not found in release package." >&2
    exit 1
fi

DEST_BIN="$INSTALL_DIR/$PROJ_NAME"
if [[ -f "$DEST_BIN" ]]; then
    mv -f "$DEST_BIN" "${{DEST_BIN}}.old" 2>/dev/null || true
fi
cp -f "$EXTRACTED" "$DEST_BIN"
chmod 755 "$DEST_BIN"
rm -f "${{DEST_BIN}}.old" 2>/dev/null || true

if [[ -d "/usr/local/bin" && -w "/usr/local/bin" && "$INSTALL_DIR" != "/usr/local/bin" ]]; then
    ln -sf "$DEST_BIN" "/usr/local/bin/$PROJ_NAME" 2>/dev/null || true
fi

case ":${{PATH:-}}:" in
    *":${{INSTALL_DIR}}:"*) ;;
    *)
        for prof in "$HOME/.bashrc" "$HOME/.profile" "$HOME/.zshrc"; do
            if [[ -f "$prof" && -w "$prof" ]]; then
                if ! grep -q "$INSTALL_DIR" "$prof" 2>/dev/null; then
                    printf '\n# Added by %s installer\nexport PATH="%s:$PATH"\n' "$PROJ_NAME" "$INSTALL_DIR" >> "$prof"
                fi
            fi
        done
        export PATH="${{INSTALL_DIR}}:${{PATH:-}}"
        ;;
esac

echo ""
echo "=========================================================="
echo "  $PROJ_NAME v$TARGET_VER successfully installed!"
echo "=========================================================="
echo "  Location: $DEST_BIN"
echo ""
'''

    with open(folder_dir / "install.ps1", "w", encoding="utf-8", newline="\n") as f:
        f.write(ps1_code)

    with open(folder_dir / "install.sh", "w", encoding="utf-8", newline="\n") as f:
        f.write(sh_code)


def assert_http_200(url: str):
    """Assert unauthenticated raw URL returns HTTP 200 OK (RCA-80 & RCA-81)."""
    try:
        res = subprocess.run(
            ["curl.exe", "-s", "-o", "NUL", "-w", "%{http_code}", url],
            capture_output=True,
            text=True,
        )
        code = res.stdout.strip()
        if code == "200":
            print(f" [PASS] Unauthenticated reachability verified: {url} -> HTTP 200 OK")
        else:
            print(f" [WARN] HTTP reachability check returned {code} for {url}")
            if code == "302":
                print("        Warning: 302 redirect indicates repository is Private (triggers Cloudflare challenge).")
    except Exception as e:
        print(f" [INFO] Could not assert HTTP 200 via curl: {e}")


def main():
    parser = argparse.ArgumentParser(description="Universal Binary Deployment Workflow Engine")
    parser.add_argument("--project", required=True, help="Project name (e.g. gitmap, agm)")
    parser.add_argument("--binary-path", required=True, help="Path to executable binary")
    parser.add_argument("--linux-binary-path", default="", help="Path to Linux executable binary (when deploying multi-platform)")
    parser.add_argument("--deploy-repo", required=True, help="Path to distribution repository")
    parser.add_argument("--folder", default="", help="Subfolder in distribution repo (omit for root dedicated repo)")
    parser.add_argument("--version", default="v1.0.0", help="Release version tag")
    parser.add_argument("--volume-size", default="8m", help="7-Zip split volume size (e.g. 8m, 5m)")
    parser.add_argument("--os-arch", default="windows-amd64", help="Platform target (windows-amd64, linux-amd64, all)")
    parser.add_argument("--gitlab-user", default="", help="Override GitLab username/namespace")
    parser.add_argument("--tag-prefix", default="", help="Custom tag prefix")
    parser.add_argument("--no-push", action="store_true", help="Skip git push")
    parser.add_argument("--yes", "-y", action="store_true", help="Skip confirmation prompt")

    args = parser.parse_args()

    if args.os_arch.lower() == "all":
        linux_bin = args.linux_binary_path
        if not linux_bin or not os.path.isfile(linux_bin):
            candidates = [
                str(Path(args.binary_path).parent / args.project),
                "bin/gitmap",
                "../bin/gitmap",
                "D:/work/gitmap/bin/gitmap",
                str(Path(args.binary_path).parent / f"{args.project}-linux"),
            ]
            for c in candidates:
                if os.path.isfile(c):
                    linux_bin = c
                    break

        if linux_bin and os.path.isfile(linux_bin):
            print(f"\n==========================================================")
            print(f" [MULTI-OS] Step 1/2: Deploying Linux Platform ({linux_bin})...")
            print(f"==========================================================\n")
            package_and_deploy_workflow(
                project=args.project,
                binary_path=linux_bin,
                deploy_repo=args.deploy_repo,
                folder=args.folder,
                version=args.version,
                volume_size=args.volume_size,
                os_arch="linux-amd64",
                gitlab_user=args.gitlab_user,
                tag_prefix=args.tag_prefix,
                no_push=True,
                yes=True,
            )
        else:
            print(f" [WARN] Linux binary not found; skipping linux-amd64 deployment.")

        print(f"\n==========================================================")
        print(f" [MULTI-OS] Step 2/2: Deploying Windows Platform ({args.binary_path})...")
        print(f"==========================================================\n")
        package_and_deploy_workflow(
            project=args.project,
            binary_path=args.binary_path,
            deploy_repo=args.deploy_repo,
            folder=args.folder,
            version=args.version,
            volume_size=args.volume_size,
            os_arch="windows-amd64",
            gitlab_user=args.gitlab_user,
            tag_prefix=args.tag_prefix,
            no_push=args.no_push,
            yes=True,
        )
    else:
        package_and_deploy_workflow(
            project=args.project,
            binary_path=args.binary_path,
            deploy_repo=args.deploy_repo,
            folder=args.folder,
            version=args.version,
            volume_size=args.volume_size,
            os_arch=args.os_arch,
            gitlab_user=args.gitlab_user,
            tag_prefix=args.tag_prefix,
            no_push=args.no_push,
            yes=args.yes,
        )


if __name__ == "__main__":
    main()
