#!/usr/bin/env bash
# Smoke tests for scripts-linux/chrome-profile-copy/profile-copy.sh
# and (best-effort) for scripts/58-install-chrome/helpers/profile-copy.ps1
#
# These tests build a fake Chrome user-data dir in a temp HOME and run the
# script against it. They never touch the real user's profile.

set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SCRIPT="$ROOT/scripts-linux/chrome-profile-copy/profile-copy.sh"
[ -x "$SCRIPT" ] || chmod +x "$SCRIPT" 2>/dev/null || true

PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  [PASS] %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  [FAIL] %s\n' "$1" >&2; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP"
UD="$HOME/.config/google-chrome"
mkdir -p "$UD/Default/Extensions/abcd1234/1.0"
cat >"$UD/Default/Preferences" <<'JSON'
{ "homepage":"https://example.com", "google":{"services":{"username":"x@y"}},
  "signin":{"allowed":true}, "account_info":[{"gaia":"123"}] }
JSON
cat >"$UD/Default/Bookmarks" <<'JSON'
{ "roots": { "bookmark_bar": { "name":"Bar","children":[
  {"type":"url","name":"Lovable","url":"https://lovable.dev"} ] } } }
JSON
cat >"$UD/Default/Extensions/abcd1234/1.0/manifest.json" <<'JSON'
{ "name":"Fake Ext", "version":"1.0" }
JSON
cat >"$UD/Local State" <<'JSON'
{ "profile":{ "info_cache":{ "Default":{"name":"Work","gaia_id":"123"} }, "profiles_order":["Default"] },
  "browser":{ "enabled_labs_experiments":["enable-quic@1"] } }
JSON

echo "== test 1: list discovers profile =="
out="$(bash "$SCRIPT" list 2>&1)"
echo "$out" | grep -q "Default" && ok "list shows Default" || bad "list output: $out"

echo "== test 2: dry-run copy =="
out="$(bash "$SCRIPT" copy Default to Cloned --dry-run 2>&1)"
echo "$out" | grep -qi "dry-run" && ok "dry-run logs intent" || bad "dry-run output: $out"
[ ! -e "$UD/Cloned" ] && ok "dry-run leaves disk untouched" || bad "dry-run created $UD/Cloned"

echo "== test 3: real copy clones bookmarks + strips account =="
bash "$SCRIPT" copy Default to Cloned >/tmp/copylog.txt 2>&1
[ -f "$UD/Cloned/Bookmarks" ]   && ok "Bookmarks copied"   || { bad "Bookmarks missing"; cat /tmp/copylog.txt; }
[ -d "$UD/Cloned/Extensions/abcd1234" ] && ok "Extensions copied" || bad "Extensions missing"
grep -q '"google"' "$UD/Cloned/Preferences" && bad "Preferences still contains google block" || ok "Preferences google block stripped"
grep -q '"signin"' "$UD/Cloned/Preferences" && bad "Preferences still contains signin block" || ok "Preferences signin block stripped"
grep -q '"Cloned"' "$UD/Local State" && ok "Local State registered Cloned" || bad "Local State not patched"
grep -q '"gaia_id"' <(python3 -c "import json; d=json.load(open('$UD/Local State')); print(json.dumps(d['profile']['info_cache'].get('Cloned',{})))") \
  && bad "Cloned profile still has gaia_id" || ok "Cloned profile is offline (no gaia_id)"

echo "== test 4: refuses to overwrite without --force =="
out="$(bash "$SCRIPT" copy Default to Cloned 2>&1 || true)"
echo "$out" | grep -qi "already exists" && ok "refuses overwrite" || bad "did not refuse: $out"

echo "== test 5: --force overwrites with backup =="
bash "$SCRIPT" copy Default to Cloned --force >/dev/null 2>&1
ls "$UD"/Cloned.bak-* >/dev/null 2>&1 && ok "timestamped backup created" || bad "no backup folder"

echo "== test 6: export writes json + csv =="
bash "$SCRIPT" export Default "$TMP/out" >/tmp/explog.txt 2>&1
[ -f "$TMP/out/Default/profile.json" ] && ok "profile.json written" || { bad "profile.json missing"; cat /tmp/explog.txt; }
[ -f "$TMP/out/Default/profile.csv" ]  && ok "profile.csv written"  || bad "profile.csv missing"
grep -q "Fake Ext" "$TMP/out/Default/profile.json" && ok "export captured extension" || bad "extension missing from export"
grep -q "Lovable" "$TMP/out/Default/profile.json"  && ok "export captured bookmark"  || bad "bookmark missing from export"

echo "== test 7: import recreates profile from snapshot =="
bash "$SCRIPT" import "$TMP/out/Default/profile.json" to Restored >/tmp/implog.txt 2>&1
[ -f "$UD/Restored/Bookmarks" ]   && ok "import wrote Bookmarks"   || { bad "Bookmarks missing"; cat /tmp/implog.txt; }
[ -f "$UD/Restored/Preferences" ] && ok "import wrote Preferences" || bad "Preferences missing"
grep -q '"Restored"' "$UD/Local State" && ok "import registered Restored" || bad "Restored not in Local State"

echo "== test 8: unknown subcommand exits non-zero =="
bash "$SCRIPT" wat 2>/dev/null && bad "unknown subcommand returned 0" || ok "unknown subcommand exits non-zero"

echo
echo "== summary: PASS=$PASS  FAIL=$FAIL =="
[ $FAIL -eq 0 ]
