#!/usr/bin/env python3
"""
54-deploy-folder-distribution.py

Universal autonomous binary deployment and folder distribution engine.
Packages compiled binaries into 7-Zip multi-part volumes, calculates SHA-256
digests, synthesizes binary-info.json manifests, generates aria2c client
installers, and commits/pushes to a public distribution repository folder.

Usage:
    python 54-deploy-folder-distribution.py --project gitmap --binary-path /path/to/gitmap.exe \
        --deploy-repo d:\\work\\deploy\\r-files --folder gitmap --version v6.692.0 --volume-size 8m

    python 54-deploy-folder-distribution.py --project agm --binary-path /path/to/agm.exe \
        --deploy-repo d:\\work\\deploy\\r-files --folder agm --version v4.329.0 --volume-size 3m
"""

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import urllib.request
from pathlib import Path


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


def package_and_deploy(
    project: str,
    binary_path: str,
    deploy_repo: str,
    folder: str,
    version: str,
    volume_size: str,
    no_push: bool,
) -> dict:
    """Package binary into 7z volumes and deploy to folder inside deploy repo."""
    clean_version = version.lstrip("v")
    semver_tag = f"v{clean_version}"
    seven_zip = find_7z_binary()

    if not os.path.isfile(binary_path):
        raise FileNotFoundError(f"Source binary not found: {binary_path}")
    if not os.path.isdir(deploy_repo):
        raise FileNotFoundError(f"Deploy repository not found: {deploy_repo}")

    binary_size = os.path.getsize(binary_path)
    binary_name = Path(binary_path).name
    is_windows = binary_name.endswith(".exe")
    exec_windows = binary_name if is_windows else f"{binary_name}.exe"
    exec_linux = binary_name[:-4] if is_windows else binary_name

    folder_dir = Path(deploy_repo) / folder
    releases_dir = folder_dir / "releases" / semver_tag
    releases_dir.mkdir(parents=True, exist_ok=True)

    staging_dir = folder_dir / ".staging"
    staging_dir.mkdir(parents=True, exist_ok=True)

    archive_base_name = f"{project}-windows-amd64.7z" if is_windows else f"{project}-linux-amd64.7z"
    staging_archive = staging_dir / archive_base_name

    # Clean prior split chunks
    for old_chunk in staging_dir.glob(f"{archive_base_name}.*"):
        old_chunk.unlink()
    for old_chunk in releases_dir.glob(f"{archive_base_name}.*"):
        old_chunk.unlink()

    # Step 1: 7-Zip LZMA2 multi-volume split archive creation
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
    print(f" [INFO] Packaging {binary_name} into multi-part 7z volumes (-v{volume_size})...")
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        raise RuntimeError(f"7-Zip compression failed:\n{res.stderr}\n{res.stdout}")

    # Step 2: Collect generated chunks and calculate SHA-256
    chunk_files = sorted(staging_dir.glob(f"{archive_base_name}.*"))
    if not chunk_files:
        raise RuntimeError(f"No split chunks produced in {staging_dir}")

    total_archive_size = 0
    chunks_meta = []
    base_raw_url = f"https://gitlab.com/rup-gitlab/r-files/-/raw/main/{folder}/releases/{semver_tag}"

    for idx, chunk_path in enumerate(chunk_files, start=1):
        target_path = releases_dir / chunk_path.name
        shutil.copy2(chunk_path, target_path)

        size_bytes = os.path.getsize(target_path)
        total_archive_size += size_bytes
        sha256_hash = compute_sha256(str(target_path))

        chunks_meta.append(
            {
                "part": idx,
                "fileName": chunk_path.name,
                "sizeBytes": size_bytes,
                "sha256": sha256_hash,
                "downloadUrl": f"{base_raw_url}/{chunk_path.name}",
            }
        )

    # Step 3: Write binary-info.json manifest
    manifest = {
        "$schema": "https://json-schema.org/draft/2020-12/schema",
        "project": project,
        "version": clean_version,
        "releaseDate": subprocess.check_output(["git", "log", "-1", "--format=%cI"], cwd=deploy_repo).decode().strip() or "2026-11-17T12:00:00Z",
        "binaryName": project,
        "executableWindows": exec_windows,
        "executableLinux": exec_linux,
        "archiveFormat": "7z",
        "isConfidential": False,
        "issueId": 1,
        "issueUrl": f"https://gitlab.com/rup-gitlab/r-files/-/tree/main/{folder}",
        "totalSizeBytes": binary_size,
        "totalArchiveSizeBytes": total_archive_size,
        "chunks": chunks_meta,
        "installers": {
            "oneLinerWindows": f"irm https://gitlab.com/rup-gitlab/r-files/-/raw/main/{folder}/install.ps1 | iex",
            "oneLinerLinux": f"curl -fsSL https://gitlab.com/rup-gitlab/r-files/-/raw/main/{folder}/install.sh | bash",
        },
    }

    manifest_path = folder_dir / "binary-info.json"
    with open(manifest_path, "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=2)

    # Clean staging
    shutil.rmtree(staging_dir, ignore_errors=True)

    # Step 4: Generate folder install.ps1 & install.sh
    generate_installers(folder_dir, project, folder)

    # Step 5: Git commit and push
    if not no_push and (Path(deploy_repo) / ".git").is_dir():
        print(f" [INFO] Staging and committing to deploy repository...")
        subprocess.run(["git", "-C", deploy_repo, "add", folder], check=True)
        commit_msg = f"chore(release): update {project} {semver_tag} in {folder}/"
        subprocess.run(["git", "-C", deploy_repo, "commit", "-m", commit_msg], capture_output=True)
        print(f" [INFO] Pushing to GitLab origin main...")
        subprocess.run(["git", "-C", deploy_repo, "push", "origin", "main"], check=True)

    return manifest


def generate_installers(folder_dir: Path, project: str, folder: str):
    """Generate high-speed aria2c install.ps1 and install.sh for the folder."""
    raw_base = f"https://gitlab.com/rup-gitlab/r-files/-/raw/main/{folder}"

    ps1_content = f'''<#
.SYNOPSIS
    High-speed binary installer for {project} hosted in rup-gitlab/r-files/{folder}.
.EXAMPLE
    irm {raw_base}/install.ps1 | iex
#>
[CmdletBinding()]
param(
    [string]$ManifestUrl = "{raw_base}/binary-info.json",
    [string]$InstallDir = "",
    [switch]$Force,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

function Write-Info([string]$msg) {{ if (-not $Quiet) {{ Write-Host " [INFO] $msg" -ForegroundColor Cyan }} }}
function Write-Ok([string]$msg)   {{ Write-Host " [OK]   $msg" -ForegroundColor Green }}
function Write-Fail([string]$msg) {{ Write-Host " [FAIL] $msg" -ForegroundColor Red }}

# 1. Fetch Manifest
Write-Info "Fetching release manifest from $ManifestUrl..."
try {{
    $manifest = Invoke-RestMethod -Uri $ManifestUrl -TimeoutSec 15
}} catch {{
    Write-Fail "Failed to fetch manifest: $_"
    exit 1
}}

$projectName = $manifest.project
$version = $manifest.version
$execWindows = $manifest.executableWindows
Write-Ok "Resolved $projectName v$version."

# 2. Resolve Target Install Directory
if (-not $InstallDir) {{
    $targetDir = Join-Path $env:USERPROFILE "bin"
    if (-not (Test-Path $targetDir)) {{
        $targetDir = Join-Path $env:LOCALAPPDATA "Programs\\$projectName\\bin"
    }}
}} else {{
    $targetDir = $InstallDir
}}
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
Write-Info "Target install directory: $targetDir"

# 3. Locate Tools (aria2c and 7z)
$sevenZip = (Get-Command "7z.exe" -ErrorAction SilentlyContinue).Source
if (-not $sevenZip) {{
    $candidates = @(
        "C:\\Program Files\\7-Zip\\7z.exe",
        "C:\\ProgramData\\chocolatey\\bin\\7z.exe",
        "$env:LOCALAPPDATA\\Programs\\7-Zip\\7z.exe"
    )
    foreach ($c in $candidates) {{
        if (Test-Path $c) {{ $sevenZip = $c; break }}
    }}
}}

$aria2 = (Get-Command "aria2c.exe" -ErrorAction SilentlyContinue).Source

# 4. Download Chunks to Temp Directory
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "{project}-install-$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

try {{
    $chunkFiles = @()
    foreach ($chunk in $manifest.chunks) {{
        $destPath = Join-Path $tempDir $chunk.fileName
        $url = $chunk.downloadUrl
        Write-Info "Downloading $($chunk.fileName)..."

        if ($aria2) {{
            & $aria2 -x 16 -s 16 -j 4 --dir="$tempDir" --out="$($chunk.fileName)" "$url" | Out-Null
        }} else {{
            Invoke-WebRequest -Uri $url -OutFile $destPath -UseBasicParsing
        }}

        # Verify SHA-256
        $actualHash = (Get-FileHash -Path $destPath -Algorithm SHA256).Hash.ToLower()
        if ($actualHash -ne $chunk.sha256.ToLower()) {{
            throw "Checksum mismatch for $($chunk.fileName)!"
        }}
        $chunkFiles += $destPath
    }}
    Write-Ok "All chunks downloaded and cryptographically verified."

    # 5. Extract Archive
    $firstChunk = $chunkFiles[0]
    $extractDir = Join-Path $tempDir "extracted"
    New-Item -ItemType Directory -Path $extractDir -Force | Out-Null

    if ($sevenZip) {{
        & $sevenZip x -y "-o$extractDir" "$firstChunk" | Out-Null
    }} else {{
        throw "7-Zip (7z.exe) is required for extraction. Install via: winget install 7zip.7zip"
    }}

    # 6. Deploy Binary with Atomic Swapping
    $extractedBinary = Get-ChildItem -Path $extractDir -Filter $execWindows -Recurse | Select-Object -First 1
    if (-not $extractedBinary) {{
        throw "Could not find $execWindows in extracted archive."
    }}

    $destinationBinary = Join-Path $targetDir $execWindows
    if (Test-Path $destinationBinary) {{
        $oldPath = "$destinationBinary.old"
        if (Test-Path $oldPath) {{ Remove-Item $oldPath -Force -ErrorAction SilentlyContinue }}
        Rename-Item -Path $destinationBinary -NewName "$execWindows.old" -Force
    }}
    Copy-Item -Path $extractedBinary.FullName -Destination $destinationBinary -Force
    Write-Ok "Installed $execWindows to $destinationBinary."

    # 7. PATH Registration
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    if ($userPath -notlike "*$targetDir*") {{
        [Environment]::SetEnvironmentVariable("Path", "$userPath;$targetDir", "User")
        Write-Ok "Added $targetDir to User PATH."
    }}

    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  $projectName v$version successfully installed!           " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "  Location: $destinationBinary"
    Write-Host ""

}} finally {{
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}}
'''

    with open(folder_dir / "install.ps1", "w", encoding="utf-8") as f:
        f.write(ps1_content)

    sh_content = f'''#!/usr/bin/env bash
set -euo pipefail

MANIFEST_URL="{raw_base}/binary-info.json"
INSTALL_DIR="${{HOME}}/.local/bin"
mkdir -p "${{INSTALL_DIR}}"

echo " [INFO] Fetching manifest from ${{MANIFEST_URL}}..."
MANIFEST=$(curl -fsSL "${{MANIFEST_URL}}")
PROJECT=$(echo "${{MANIFEST}}" | grep -o '"project": "[^"]*' | cut -d'"' -f4)
VERSION=$(echo "${{MANIFEST}}" | grep -o '"version": "[^"]*' | cut -d'"' -f4)
EXEC_NAME=$(echo "${{MANIFEST}}" | grep -o '"executableLinux": "[^"]*' | cut -d'"' -f4)

echo " [OK]   Resolved ${{PROJECT}} v${{VERSION}}."

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "${{TEMP_DIR}}"' EXIT

CHUNK_URLS=$(echo "${{MANIFEST}}" | grep -o '"downloadUrl": "[^"]*' | cut -d'"' -f4)

for url in ${{CHUNK_URLS}}; do
    FILENAME=$(basename "${{url}}")
    echo " [INFO] Downloading ${{FILENAME}}..."
    if command -v aria2c >/dev/null 2>&1; then
        aria2c -x 16 -s 16 -d "${{TEMP_DIR}}" -o "${{FILENAME}}" "${{url}}" >/dev/null
    else
        curl -fsSL -o "${{TEMP_DIR}}/${{FILENAME}}" "${{url}}"
    fi
done

FIRST_CHUNK=$(find "${{TEMP_DIR}}" -name "*.7z.001" | head -n 1)
7z x -y -o"${{TEMP_DIR}}/extracted" "${{FIRST_CHUNK}}" >/dev/null

EXTRACTED_BIN=$(find "${{TEMP_DIR}}/extracted" -type f -name "${{EXEC_NAME}}" | head -n 1)
cp "${{EXTRACTED_BIN}}" "${{INSTALL_DIR}}/${{EXEC_NAME}}"
chmod +x "${{INSTALL_DIR}}/${{EXEC_NAME}}"

echo " [OK]   Installed ${{EXEC_NAME}} to ${{INSTALL_DIR}}/${{EXEC_NAME}}."
'''

    with open(folder_dir / "install.sh", "w", encoding="utf-8") as f:
        f.write(sh_content)


def main():
    parser = argparse.ArgumentParser(description="Universal public folder deployment engine.")
    parser.add_argument("--project", required=True, help="Project name (e.g. gitmap, agm)")
    parser.add_argument("--binary-path", required=True, help="Path to compiled executable binary")
    parser.add_argument("--deploy-repo", default=r"d:\work\deploy\r-files", help="Path to deploy repository")
    parser.add_argument("--folder", required=True, help="Target folder inside deploy repo (e.g. gitmap, agm)")
    parser.add_argument("--version", default="v6.692.0", help="Release version tag")
    parser.add_argument("--volume-size", default="8m", help="7-Zip volume chunk size (e.g. 8m, 3m)")
    parser.add_argument("--no-push", action="store_true", help="Skip git push")

    args = parser.parse_args()

    manifest = package_and_deploy(
        project=args.project,
        binary_path=args.binary_path,
        deploy_repo=args.deploy_repo,
        folder=args.folder,
        version=args.version,
        volume_size=args.volume_size,
        no_push=args.no_push,
    )

    print("\n" + "=" * 60)
    print("  Deployment Completed Successfully!")
    print("=" * 60)
    print(f"  Project:    {manifest['project']} v{manifest['version']}")
    print(f"  Folder:     {args.folder}")
    print(f"  Chunks:     {len(manifest['chunks'])}")
    print(f"  One-Liner:  {manifest['installers']['oneLinerWindows']}")
    print("=" * 60 + "\n")


if __name__ == "__main__":
    main()
