<#
.SYNOPSIS
    Antigravity State Preservation & Project Conversation Backup Helper.
#>

function Write-FileError {
    param(
        [string]$FilePath,
        [string]$Reason,
        [string]$Path = $FilePath
    )

    $target = if ($FilePath) { $FilePath } else { $Path }
    Write-Host "  [ FAIL ] FILE-ERROR path='$target' reason='$Reason'" -ForegroundColor Red
}

function Ensure-BackupDirectory {
    param([string]$DirPath)

    $hasDir = Test-Path -LiteralPath $DirPath
    if ($hasDir) {
        return
    }

    try {
        New-Item -ItemType Directory -Path $DirPath -Force | Out-Null
    } catch {
        Write-FileError -FilePath $DirPath -Reason $_.Exception.Message
    }
}

function Save-JsonBackupFiles {
    param(
        [string]$JsonContent,
        [string]$PrimaryPath,
        [string]$MirrorPath
    )

    $primaryDir = Split-Path -Parent $PrimaryPath
    Ensure-BackupDirectory -DirPath $primaryDir
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)

    try {
        [System.IO.File]::WriteAllText($PrimaryPath, $JsonContent, $utf8NoBom)
    } catch {
        Write-FileError -FilePath $PrimaryPath -Reason $_.Exception.Message
    }

    try {
        [System.IO.File]::WriteAllText($MirrorPath, $JsonContent, $utf8NoBom)
    } catch {
        Write-FileError -FilePath $MirrorPath -Reason $_.Exception.Message
    }
}

function Get-StateExtractionScript {
    $code = @'
import json, os, sys, urllib.parse, sqlite3, re
from datetime import datetime, timezone

user_profile = os.environ.get("USERPROFILE") or os.path.expanduser("~")
gemini_dir = os.path.join(user_profile, ".gemini", "antigravity")
db_path = os.path.join(gemini_dir, "conversation_summaries.db")
brain_dir = os.path.join(gemini_dir, "brain")

items = []
seen_ids = set()

if os.path.isfile(db_path):
    try:
        conn = sqlite3.connect(db_path)
        cur = conn.cursor()
        cur.execute("SELECT conversation_id, title, workspace_uris FROM conversation_summaries")
        for cid, title, raw_uris in cur.fetchall():
            if not cid or cid in seen_ids:
                continue
            seen_ids.add(cid)
            proj_path = ""
            proj_name = ""
            if raw_uris:
                try:
                    uris = json.loads(raw_uris) if isinstance(raw_uris, str) else raw_uris
                    if isinstance(uris, list) and uris:
                        u_unquote = urllib.parse.unquote(uris[0])
                        if u_unquote.startswith("file:///"):
                            proj_path = u_unquote[8:]
                        elif u_unquote.startswith("file://"):
                            proj_path = u_unquote[7:]
                        else:
                            proj_path = u_unquote
                        proj_path = proj_path.replace("\\", "/")
                        proj_name = os.path.basename(proj_path.rstrip("/"))
                except Exception:
                    pass
            items.append({
                "conversation_id": cid,
                "conversation_name": title or cid,
                "project_name": proj_name,
                "project_path": proj_path
            })
        conn.close()
    except Exception:
        pass

if not items and os.path.isdir(brain_dir):
    try:
        for entry in os.listdir(brain_dir):
            epath = os.path.join(brain_dir, entry)
            if not os.path.isdir(epath) or entry in seen_ids:
                continue
            seen_ids.add(entry)
            proj_path = ""
            proj_name = ""
            tpath = os.path.join(epath, ".system_generated", "logs", "transcript.jsonl")
            if os.path.isfile(tpath):
                try:
                    with open(tpath, "r", encoding="utf-8", errors="ignore") as f:
                        for _ in range(25):
                            line = f.readline()
                            if not line:
                                break
                            m = re.search(r'file:///([a-zA-Z0-9_\-\.%/]+)', line)
                            if m:
                                raw_p = urllib.parse.unquote(m.group(1)).replace("\\", "/")
                                proj_path = raw_p
                                proj_name = os.path.basename(raw_p.rstrip("/"))
                                break
                except Exception:
                    pass
            items.append({
                "conversation_id": entry,
                "conversation_name": entry,
                "project_name": proj_name,
                "project_path": proj_path
            })
    except Exception:
        pass

projects_map = {}
for item in items:
    p_name = item["project_name"] or "Unknown"
    p_path = item["project_path"] or "Unknown"
    key = (p_name, p_path)
    if key not in projects_map:
        projects_map[key] = {
            "project_name": p_name,
            "project_path": p_path,
            "conversations": []
        }
    projects_map[key]["conversations"].append({
        "conversation_id": item["conversation_id"],
        "conversation_name": item["conversation_name"]
    })

saved_at = datetime.now(timezone.utc).isoformat()
payload = {
    "saved_at": saved_at,
    "total_conversations": len(items),
    "projects": list(projects_map.values()),
    "items": items
}
print(json.dumps(payload, indent=2))
'@

    return $code
}

function Invoke-StateBackupPython {
    $script = Get-StateExtractionScript

    try {
        $output = & python -c $script
        return $output
    } catch {
        Write-FileError -FilePath "conversation_summaries.db" -Reason $_.Exception.Message
        return $null
    }
}

function Export-AntigravityState {
    Write-Host "Preserving Antigravity state & conversations..." -ForegroundColor Cyan

    $primaryPath = Join-Path $env:USERPROFILE ".scripts-fixer\antigravity-projects-backup.json"
    $mirrorPath = Join-Path $env:USERPROFILE "antigravity-projects-backup.json"

    $jsonResult = Invoke-StateBackupPython
    $hasValidJson = -not [string]::IsNullOrWhiteSpace($jsonResult)

    if (-not $hasValidJson) {
        Write-FileError -FilePath $primaryPath -Reason "Extraction generated empty state"
        return $null
    }

    Save-JsonBackupFiles -JsonContent $jsonResult -PrimaryPath $primaryPath -MirrorPath $mirrorPath

    $totalCount = 0
    try {
        $parsed = $jsonResult | ConvertFrom-Json
        $totalCount = $parsed.total_conversations
    } catch {
        $totalCount = 0
    }

    Write-Host "[  OK  ] Preserved project metadata & conversations -> $primaryPath ($totalCount conversations)" -ForegroundColor Green

    return $primaryPath
}
