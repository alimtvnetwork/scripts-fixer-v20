#!/usr/bin/env bash
# Linux/macOS port of scripts/58-install-chrome/helpers/profile-copy.ps1
# Spec: spec/58-install-chrome/profile-copy.md
#
# Subcommands:
#   copy    <from> [to] <to>           clone a profile into a new offline profile
#   export  <name> [<outdir>] [--json|--csv|--both]
#   import  <jsonPath> to <name>
#   list                               list discovered profiles
#
# Flags: --dry-run  --yes  --force  --with-logins  --with-site-data  --with-flags  --help
# Browser: --browser chrome|chromium|brave  (default: chrome)
#
# CODE RED: every file/path error includes the offending path + reason.

set -u

__SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__SHARED_DIR="$(cd "$__SELF_DIR/../_shared" && pwd 2>/dev/null || echo "$__SELF_DIR/../_shared")"
# shellcheck disable=SC1091
[ -f "$__SHARED_DIR/logger.sh" ] && . "$__SHARED_DIR/logger.sh"
command -v info  >/dev/null 2>&1 || info()  { printf '[INFO]  %s\n' "$*"; }
command -v warn  >/dev/null 2>&1 || warn()  { printf '[WARN]  %s\n' "$*" >&2; }
command -v error >/dev/null 2>&1 || error() { printf '[ERROR] %s\n' "$*" >&2; }
# shellcheck disable=SC1091
[ -f "$__SHARED_DIR/file-error.sh" ] && . "$__SHARED_DIR/file-error.sh"

file_err() {
  # $1=path  $2=reason
  local p="${1:-<unknown>}" r="${2:-unknown}"
  if command -v write_file_error >/dev/null 2>&1; then
    write_file_error "$p" "$r"
  else
    printf '[ERROR] file: %s -- reason: %s\n' "$p" "$r" >&2
  fi
}

# ---- args -------------------------------------------------------------------
SUBCMD=""; ARG1=""; ARG2=""; ARG3=""
DRY_RUN=0; ASSUME_YES=0; FORCE=0; WITH_LOGINS=0; WITH_SITE_DATA=0; WITH_FLAGS=0
BROWSER="chrome"; EXPORT_FORMAT="both"

show_help() {
  cat <<EOF
chrome-profile-copy (Linux/macOS) -- clone/export/import Chrome profiles

Usage:
  profile-copy.sh copy   <from> [to] <to>   [flags]
  profile-copy.sh export <name> [<outdir>]  [--json|--csv|--both]
  profile-copy.sh import <jsonPath> to <name> [flags]
  profile-copy.sh list

Flags:
  --browser chrome|chromium|brave   (default: chrome)
  --dry-run        preview, no disk writes
  --yes            assume yes on prompts
  --force          overwrite destination if it exists / ignore running browser
  --with-logins    include Login Data (default off)
  --with-site-data include Local Storage / IndexedDB / Session Storage
  --with-flags     restore chrome://flags on import
  --help           this help

Examples:
  ./profile-copy.sh copy Default to Work
  ./profile-copy.sh copy "Profile 1" "Profile 2" --dry-run
  ./profile-copy.sh export Default ~/backups
  ./profile-copy.sh import ~/backups/Default/profile.json to Restored
EOF
}

POSITIONAL=()
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run|-n) DRY_RUN=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --force) FORCE=1 ;;
    --with-logins) WITH_LOGINS=1 ;;
    --with-site-data) WITH_SITE_DATA=1 ;;
    --with-flags) WITH_FLAGS=1 ;;
    --browser) shift; BROWSER="${1:-chrome}" ;;
    --json) EXPORT_FORMAT="json" ;;
    --csv) EXPORT_FORMAT="csv" ;;
    --both) EXPORT_FORMAT="both" ;;
    -h|--help) show_help; exit 0 ;;
    --) shift; while [ $# -gt 0 ]; do POSITIONAL+=("$1"); shift; done; break ;;
    -*) warn "Unknown flag: $1 (ignored)" ;;
    *) POSITIONAL+=("$1") ;;
  esac
  shift || true
done

SUBCMD="${POSITIONAL[0]:-}"
ARG1="${POSITIONAL[1]:-}"
ARG2="${POSITIONAL[2]:-}"
ARG3="${POSITIONAL[3]:-}"

[ -z "$SUBCMD" ] && { show_help; exit 0; }

# ---- locate Chrome user data dir -------------------------------------------
user_data_dir() {
  local os; os="$(uname -s)"
  case "$BROWSER" in
    chrome)   linux_sub="google-chrome"; mac_sub="Google/Chrome" ;;
    chromium) linux_sub="chromium";      mac_sub="Chromium" ;;
    brave)    linux_sub="BraveSoftware/Brave-Browser"; mac_sub="BraveSoftware/Brave-Browser" ;;
    *) error "Unknown browser: $BROWSER"; return 1 ;;
  esac
  local candidates=()
  if [ "$os" = "Darwin" ]; then
    candidates+=("$HOME/Library/Application Support/$mac_sub")
  else
    candidates+=("$HOME/.config/$linux_sub")
    candidates+=("$HOME/.var/app/com.google.Chrome/config/google-chrome")        # flatpak
    candidates+=("$HOME/snap/chromium/common/chromium")                          # snap chromium
  fi
  for c in "${candidates[@]}"; do
    [ -d "$c" ] && { printf '%s\n' "$c"; return 0; }
  done
  file_err "${candidates[0]}" "user-data dir not found (browser=$BROWSER, never launched or not installed). Tried: ${candidates[*]}"
  return 1
}

# Print "<dir>\t<display>" lines for every discovered profile under $1.
list_profiles() {
  local ud="$1"
  local ls="$ud/Local State"
  python3 - "$ud" "$ls" <<'PY' 2>/dev/null || true
import json,os,sys
ud, ls_path = sys.argv[1], sys.argv[2]
ic = {}
try:
    with open(ls_path,'r',encoding='utf-8') as f:
        ic = ((json.load(f).get('profile') or {}).get('info_cache') or {})
except Exception: pass
seen=set()
try:
    for d in sorted(os.listdir(ud)):
        full=os.path.join(ud,d)
        if not os.path.isdir(full): continue
        if d=='Default' or d.startswith('Profile ') or os.path.exists(os.path.join(full,'Preferences')):
            info = ic.get(d) or {}
            name = info.get('name') or info.get('shortcut_name') or info.get('gaia_name') or d
            print(f"{d}\t{name}")
            seen.add(d)
except Exception: pass
PY
}

# Render an available-profiles help block when resolution fails.
profile_not_found_help() {
  local ud="$1" want="$2"
  err "source profile '$want' not found under $ud (case-insensitive dir / display-name / substring all failed)"
  local rows; rows="$(list_profiles "$ud")"
  if [ -z "$rows" ]; then
    warn "no Chrome profiles discovered. Is the browser installed and launched at least once?"
    return
  fi
  info "available profiles (use either column):"
  info "  DIR             DISPLAY NAME"
  printf '%s\n' "$rows" | awk -F'\t' '{printf "  %-14s  %s\n",$1,$2}' | while IFS= read -r line; do info "$line"; done
}

# resolve a profile name (dir name OR display/shortcut/gaia name OR unique substring, all case-insensitive)
resolve_profile_dir() {
  local ud="$1" name="$2"
  [ -z "$name" ] && { file_err "<empty>" "profile name is empty"; return 1; }
  local want_lc="${name,,}"
  # 1. case-insensitive directory match
  local d
  while IFS= read -r d; do
    [ -z "$d" ] && continue
    if [ "${d,,}" = "$want_lc" ] && [ -d "$ud/$d" ]; then
      printf '%s\n' "$ud/$d"; return 0
    fi
  done < <(ls -1 "$ud" 2>/dev/null)

  # 2/3/4. Local State lookup: exact display/shortcut/gaia (ci) then unique substring
  local ls="$ud/Local State" hit
  if command -v python3 >/dev/null 2>&1; then
    hit="$(python3 - "$ud" "$ls" "$name" <<'PY'
import json,os,sys
ud, ls_path, want = sys.argv[1], sys.argv[2], sys.argv[3]
want_lc = want.lower()
ic = {}
try:
    with open(ls_path,'r',encoding='utf-8') as f:
        ic = ((json.load(f).get('profile') or {}).get('info_cache') or {})
except Exception: pass
# scan dirs too so substring fallback covers raw dir names
dirs=[]
try:
    dirs=[d for d in os.listdir(ud) if os.path.isdir(os.path.join(ud,d))]
except Exception: pass
# exact name fields (ci)
for d,info in ic.items():
    for k in ('name','shortcut_name','gaia_name','gaia_given_name','user_name'):
        v = (info.get(k) or '')
        if v and v.lower() == want_lc and os.path.isdir(os.path.join(ud,d)):
            print(d); sys.exit(0)
# unique substring against display name OR dir
cands=set()
for d,info in ic.items():
    nm=(info.get('name') or '').lower()
    if nm and want_lc in nm and os.path.isdir(os.path.join(ud,d)):
        cands.add(d)
for d in dirs:
    if want_lc in d.lower(): cands.add(d)
if len(cands)==1:
    print(next(iter(cands)))
PY
)"
    if [ -n "$hit" ] && [ -d "$ud/$hit" ]; then printf '%s\n' "$ud/$hit"; return 0; fi
  fi

  profile_not_found_help "$ud" "$name"
  return 1
}

# ---- "to" keyword stripper --------------------------------------------------
# `copy <from> to <to>`  OR  `copy <from> <to>`
normalize_copy_args() {
  if [ "${ARG2,,}" = "to" ] && [ -n "$ARG3" ]; then
    ARG2="$ARG3"; ARG3=""
  fi
}
normalize_import_args() {
  if [ "${ARG2,,}" = "to" ] && [ -n "$ARG3" ]; then
    ARG2="$ARG3"; ARG3=""
  fi
}

# ---- chrome running check ---------------------------------------------------
chrome_is_running() {
  local pat
  case "$BROWSER" in
    chrome)   pat="chrome|Google Chrome" ;;
    chromium) pat="chromium" ;;
    brave)    pat="brave" ;;
  esac
  pgrep -i -f "$pat" >/dev/null 2>&1
}

# ---- ledger -----------------------------------------------------------------
ledger_path() {
  local base="${XDG_DATA_HOME:-$HOME/.local/share}/dev-server"
  if mkdir -p "$base" 2>/dev/null; then
    printf '%s/chrome-profiles.sqlite\n' "$base"
  else
    mkdir -p ./chrome-profiles 2>/dev/null || true
    printf './chrome-profiles/ledger.sqlite\n'
  fi
}
ledger_write() {
  # op source target export_path bookmarks extensions bytes ok error
  local db; db="$(ledger_path)"
  command -v sqlite3 >/dev/null 2>&1 || { warn "sqlite3 not found; ledger entry skipped (op=$1)"; return 0; }
  sqlite3 "$db" >/dev/null 2>&1 <<SQL
CREATE TABLE IF NOT EXISTS profile_ops (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  op TEXT NOT NULL, source TEXT, target TEXT, export_path TEXT,
  bookmarks INTEGER DEFAULT 0, extensions INTEGER DEFAULT 0, bytes INTEGER DEFAULT 0,
  ok INTEGER NOT NULL, error TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
CREATE INDEX IF NOT EXISTS idx_profile_ops_op ON profile_ops(op);
INSERT INTO profile_ops(op,source,target,export_path,bookmarks,extensions,bytes,ok,error)
VALUES ('$1','$2','$3','$4',$5,$6,$7,$8,'${9//\'/\'\'}');
SQL
}

# ---- whitelist --------------------------------------------------------------
COPY_INCLUDES=(
  "Bookmarks" "Bookmarks.bak"
  "Preferences" "Secure Preferences"
  "Favicons" "Top Sites" "History"
  "Extensions" "Extension Rules" "Extension State" "Extension Scripts"
  "Local Extension Settings" "Sync Extension Settings"
  "Themes" "Web Applications"
)
LOGIN_FILES=( "Login Data" "Login Data For Account" )
SITE_DATA_FILES=( "Local Storage" "IndexedDB" "Session Storage" )

# ---- subcommand: list -------------------------------------------------------
cmd_list() {
  local ud; ud="$(user_data_dir)" || return 1
  info "Chrome user-data: $ud"
  local ls="$ud/Local State"
  if [ -f "$ls" ] && command -v python3 >/dev/null 2>&1; then
    python3 - "$ls" "$ud" <<'PY'
import json,sys,os
ls,ud=sys.argv[1],sys.argv[2]
try:
    with open(ls,'r',encoding='utf-8') as f: d=json.load(f)
except Exception as e:
    print(f"[WARN] Local State parse failed: {e}"); d={}
ic=((d.get('profile') or {}).get('info_cache')) or {}
seen=set()
for entry in sorted(os.listdir(ud)):
    p=os.path.join(ud,entry)
    if not os.path.isdir(p): continue
    if entry=='Default' or entry.startswith('Profile ') or os.path.isfile(os.path.join(p,'Preferences')):
        name=(ic.get(entry) or {}).get('name', entry)
        print(f"  {entry:<20} {name}")
        seen.add(entry)
PY
  else
    ls -d "$ud"/Default "$ud"/Profile\ * 2>/dev/null | sed 's#^#  #'
  fi
}

# ---- subcommand: copy -------------------------------------------------------
cmd_copy() {
  normalize_copy_args
  local from="$ARG1" to="$ARG2"
  [ -z "$from" ] || [ -z "$to" ] && { error "usage: copy <from> to <to>"; return 2; }

  local ud; ud="$(user_data_dir)" || return 1
  local src; src="$(resolve_profile_dir "$ud" "$from")" || return 1
  local dst="$ud/$to"

  if chrome_is_running && [ $FORCE -eq 0 ]; then
    error "$BROWSER is running; close it or pass --force. (profile-copy aborted)"
    return 1
  fi

  if [ -e "$dst" ]; then
    if [ $FORCE -eq 0 ]; then
      error "Destination already exists: $dst (pass --force to overwrite, a backup is taken)"
      return 1
    fi
    local bak="$dst.bak-$(date +%Y%m%d-%H%M%S)"
    info "Backing up existing destination -> $bak"
    [ $DRY_RUN -eq 0 ] && mv "$dst" "$bak"
  fi

  info "copy: $src  ->  $dst   (dry-run=$DRY_RUN)"
  [ $DRY_RUN -eq 0 ] && mkdir -p "$dst"

  local includes=( "${COPY_INCLUDES[@]}" )
  [ $WITH_LOGINS -eq 1 ]    && includes+=( "${LOGIN_FILES[@]}" )
  [ $WITH_SITE_DATA -eq 1 ] && includes+=( "${SITE_DATA_FILES[@]}" )

  local copied_bytes=0 ext_count=0 bm_count=0
  for item in "${includes[@]}"; do
    local s="$src/$item" d="$dst/$item"
    if [ ! -e "$s" ]; then continue; fi
    if [ $DRY_RUN -eq 1 ]; then
      info "  + $item"
    else
      cp -a -- "$s" "$d" 2>/dev/null || { file_err "$s" "copy failed (-> $d)"; continue; }
    fi
  done

  # Count extensions and bookmarks (best effort)
  [ -d "$src/Extensions" ] && ext_count=$(find "$src/Extensions" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
  if [ -f "$src/Bookmarks" ] && command -v python3 >/dev/null 2>&1; then
    bm_count=$(python3 -c "
import json,sys
try:
    d=json.load(open('$src/Bookmarks','r',encoding='utf-8'))
    n=0
    def walk(x):
        global n
        if isinstance(x,dict):
            if x.get('type')=='url': n+=1
            for v in x.values(): walk(v)
        elif isinstance(x,list):
            for v in x: walk(v)
    walk(d.get('roots',{}))
    print(n)
except Exception: print(0)
")
  fi
  [ -d "$dst" ] && copied_bytes=$(du -sb "$dst" 2>/dev/null | awk '{print $1}') || copied_bytes=0

  # ---- patch Local State (strip account binding on dest) -------------------
  local ls="$ud/Local State"
  if [ -f "$ls" ] && command -v python3 >/dev/null 2>&1; then
    if [ $DRY_RUN -eq 0 ]; then
      cp -a "$ls" "$ls.bak-$(date +%Y%m%d-%H%M%S)" 2>/dev/null || warn "Local State backup failed (continuing)"
      python3 - "$ls" "$to" "$from" <<'PY'
import json,sys
ls,to,frm=sys.argv[1],sys.argv[2],sys.argv[3]
try:
    with open(ls,'r',encoding='utf-8') as f: d=json.load(f)
except Exception as e:
    print(f"[ERROR] Local State unreadable: {ls} -- {e}"); sys.exit(1)
prof=d.setdefault('profile',{})
ic=prof.setdefault('info_cache',{})
src_info=ic.get(frm,{}) if isinstance(ic.get(frm),dict) else {}
new=dict(src_info) if src_info else {}
new['name']=to
new['is_using_default_name']=False
# strip any account/sync binding so the new profile is offline
for k in ('gaia_id','user_name','hosted_domain','gaia_name','gaia_given_name','gaia_picture_file_name'):
    new.pop(k,None)
ic[to]=new
order=prof.get('profiles_order')
if isinstance(order,list) and to not in order: order.append(to)
with open(ls,'w',encoding='utf-8') as f: json.dump(d,f,separators=(',',':'))
print(f"[OK] Local State patched: registered profile dir '{to}' (name='{to}', offline)")
PY
    else
      info "  (dry-run) would register '$to' in $ls (offline, account stripped)"
    fi
  else
    warn "Local State not patched (file missing or python3 unavailable): $ls"
  fi

  # ---- strip Preferences account binding on destination -------------------
  local prefs="$dst/Preferences"
  if [ -f "$prefs" ] && command -v python3 >/dev/null 2>&1 && [ $DRY_RUN -eq 0 ]; then
    python3 - "$prefs" <<'PY'
import json,sys
p=sys.argv[1]
try:
    with open(p,'r',encoding='utf-8') as f: d=json.load(f)
except Exception as e:
    print(f"[ERROR] Preferences unreadable: {p} -- {e}"); sys.exit(0)
for top in ('google','signin','account_info','sync','account_tracker_service'):
    d.pop(top,None)
with open(p,'w',encoding='utf-8') as f: json.dump(d,f,separators=(',',':'))
print(f"[OK] Preferences stripped of account binding: {p}")
PY
  fi

  info "copy done: extensions=$ext_count bookmarks=$bm_count bytes=$copied_bytes"
  ledger_write "copy" "$from" "$to" "" "$bm_count" "$ext_count" "$copied_bytes" 1 ""
  return 0
}

# ---- subcommand: export -----------------------------------------------------
cmd_export() {
  local name="$ARG1" outdir="${ARG2:-./chrome-profiles}"
  [ -z "$name" ] && { error "usage: export <name> [<outdir>]"; return 2; }
  local ud; ud="$(user_data_dir)" || return 1
  local src; src="$(resolve_profile_dir "$ud" "$name")" || return 1
  local target_dir="$outdir/$name"
  info "export: $src  ->  $target_dir   (format=$EXPORT_FORMAT, dry-run=$DRY_RUN)"
  [ $DRY_RUN -eq 0 ] && mkdir -p "$target_dir"
  command -v python3 >/dev/null 2>&1 || { error "python3 required for export"; return 1; }

  local json_out="$target_dir/profile.json" csv_out="$target_dir/profile.csv"
  if [ $DRY_RUN -eq 1 ]; then
    info "  (dry-run) would write $json_out and $csv_out"
    return 0
  fi

  python3 - "$src" "$name" "$json_out" "$csv_out" "$EXPORT_FORMAT" "$ud" <<'PY'
import json,os,sys,datetime
src,name,json_out,csv_out,fmt,ud=sys.argv[1:7]
def safe_load(p):
    try:
        with open(p,'r',encoding='utf-8') as f: return json.load(f)
    except Exception as e:
        print(f"[WARN] cannot read {p}: {e}"); return {}
prefs=safe_load(os.path.join(src,'Preferences'))
bookmarks=safe_load(os.path.join(src,'Bookmarks'))
local_state=safe_load(os.path.join(ud,'Local State'))
flags=((local_state.get('browser') or {}).get('enabled_labs_experiments')) or []
# extensions
exts=[]
ext_dir=os.path.join(src,'Extensions')
if os.path.isdir(ext_dir):
    for ext_id in sorted(os.listdir(ext_dir)):
        ext_path=os.path.join(ext_dir,ext_id)
        if not os.path.isdir(ext_path): continue
        vers=sorted([v for v in os.listdir(ext_path) if os.path.isdir(os.path.join(ext_path,v))])
        if not vers: continue
        manifest=safe_load(os.path.join(ext_path,vers[-1],'manifest.json'))
        exts.append({
            "id":ext_id,
            "name":manifest.get('name',ext_id),
            "version":manifest.get('version',vers[-1]),
            "enabled":True
        })
pref_subset={k:prefs.get(k) for k in ('homepage','homepage_is_newtabpage','session','browser','extensions') if k in prefs}
snap={
  "$schema":"chrome-profile-export/v1",
  "exportedAt":datetime.datetime.utcnow().isoformat(timespec='seconds')+'Z',
  "sourceProfile":os.path.basename(src),
  "sourceDisplayName":name,
  "preferences":pref_subset,
  "bookmarks":bookmarks,
  "extensions":exts,
  "flags":flags
}
if fmt in ('json','both'):
    with open(json_out,'w',encoding='utf-8') as f: json.dump(snap,f,indent=2)
    print(f"[OK] wrote {json_out}")
if fmt in ('csv','both'):
    rows=[("section","key","value"),("meta","exportedAt",snap["exportedAt"]),
          ("meta","sourceProfile",snap["sourceProfile"])]
    for e in exts: rows.append(("extension",e["id"],f"{e['name']}|{e['version']}|{'enabled' if e['enabled'] else 'disabled'}"))
    for fl in flags: rows.append(("flag",fl,"1"))
    def walk(node,path=""):
        if isinstance(node,dict):
            if node.get('type')=='url':
                rows.append(("bookmark",path+'/'+node.get('name',''),node.get('url','')))
            for k,v in node.items(): walk(v,path)
            if node.get('children'):
                for c in node['children']: walk(c,path+'/'+node.get('name','') if node.get('name') else path)
        elif isinstance(node,list):
            for c in node: walk(c,path)
    walk(bookmarks.get('roots',{}))
    import csv
    with open(csv_out,'w',encoding='utf-8',newline='') as f:
        w=csv.writer(f); w.writerows(rows)
    print(f"[OK] wrote {csv_out}")
print(f"[STATS] extensions={len(exts)} flags={len(flags)}")
PY
  local bytes_w; bytes_w=$(du -sb "$target_dir" 2>/dev/null | awk '{print $1}')
  ledger_write "export" "$name" "" "$target_dir" 0 0 "${bytes_w:-0}" 1 ""
}

# ---- subcommand: import -----------------------------------------------------
cmd_import() {
  normalize_import_args
  local json_path="$ARG1" to="$ARG2"
  [ -z "$json_path" ] || [ -z "$to" ] && { error "usage: import <jsonPath> to <name>"; return 2; }
  [ -f "$json_path" ] || { file_err "$json_path" "import JSON file not found"; return 1; }
  local ud; ud="$(user_data_dir)" || return 1
  local dst="$ud/$to"

  if chrome_is_running && [ $FORCE -eq 0 ]; then
    error "$BROWSER is running; close it or pass --force."
    return 1
  fi
  if [ -e "$dst" ] && [ $FORCE -eq 0 ]; then
    error "Destination already exists: $dst (pass --force)"
    return 1
  fi

  info "import: $json_path  ->  $dst   (dry-run=$DRY_RUN, withFlags=$WITH_FLAGS)"
  [ $DRY_RUN -eq 1 ] && { info "(dry-run) would create $dst and patch Local State"; return 0; }
  command -v python3 >/dev/null 2>&1 || { error "python3 required for import"; return 1; }
  mkdir -p "$dst"

  python3 - "$json_path" "$dst" "$ud" "$to" "$WITH_FLAGS" <<'PY'
import json,os,sys
jp,dst,ud,to,wf=sys.argv[1:6]
with open(jp,'r',encoding='utf-8') as f: snap=json.load(f)
# Bookmarks
bm=snap.get('bookmarks') or {}
with open(os.path.join(dst,'Bookmarks'),'w',encoding='utf-8') as f:
    json.dump(bm,f,separators=(',',':'))
print(f"[OK] wrote {os.path.join(dst,'Bookmarks')}")
# Preferences (subset)
prefs=snap.get('preferences') or {}
with open(os.path.join(dst,'Preferences'),'w',encoding='utf-8') as f:
    json.dump(prefs,f,separators=(',',':'))
print(f"[OK] wrote {os.path.join(dst,'Preferences')}")
# Register in Local State
ls=os.path.join(ud,'Local State')
try:
    with open(ls,'r',encoding='utf-8') as f: d=json.load(f)
except Exception as e:
    print(f"[ERROR] Local State unreadable: {ls} -- {e}"); sys.exit(1)
prof=d.setdefault('profile',{}); ic=prof.setdefault('info_cache',{})
ic[to]={"name":to,"is_using_default_name":False}
if wf=='1':
    fl=snap.get('flags') or []
    browser=d.setdefault('browser',{})
    browser['enabled_labs_experiments']=fl
    print(f"[OK] restored {len(fl)} chrome://flags (global)")
else:
    print("[WARN] chrome://flags skipped (pass --with-flags to restore)")
with open(ls,'w',encoding='utf-8') as f: json.dump(d,f,separators=(',',':'))
print(f"[OK] Local State registered profile '{to}'")
ext_count=len(snap.get('extensions') or [])
print(f"[NOTE] {ext_count} extension(s) recorded in snapshot are NOT auto-installed -- open chrome://extensions and install from Web Store.")
PY
  local bytes_w; bytes_w=$(du -sb "$dst" 2>/dev/null | awk '{print $1}')
  ledger_write "import" "" "$to" "$json_path" 0 0 "${bytes_w:-0}" 1 ""
}

# ---- dispatch ---------------------------------------------------------------
case "${SUBCMD,,}" in
  copy|profile-copy)            cmd_copy ;;
  export|profile-export|profile-to-json|profile-to-csv)
    case "${SUBCMD,,}" in
      profile-to-json) EXPORT_FORMAT="json" ;;
      profile-to-csv)  EXPORT_FORMAT="csv" ;;
    esac
    cmd_export ;;
  import|profile-import)        cmd_import ;;
  list|profile-list)            cmd_list ;;
  help|-h|--help)               show_help ;;
  *) error "Unknown subcommand: $SUBCMD"; show_help; exit 2 ;;
esac
