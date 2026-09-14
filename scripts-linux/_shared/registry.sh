#!/usr/bin/env bash
# Read scripts-linux/registry.json and expose helpers.

__REG_FILE="$(dirname "${BASH_SOURCE[0]}")/../registry.json"

has_jq() {
  command -v jq >/dev/null 2>&1
}

registry_list_ids() {
  if has_jq; then
    jq -r '.scripts[].id' "$__REG_FILE" 2>/dev/null

    return 0
  fi

  grep -oE '"id": *"[^"]+"' "$__REG_FILE" | cut -d'"' -f4
}

registry_get_folder() {
  local id="$1"

  if has_jq; then
    jq -r --arg id "$id" '.scripts[] | select(.id==$id) | .folder' "$__REG_FILE" 2>/dev/null

    return 0
  fi

  grep -A3 "\"id\": *\"$id\"" "$__REG_FILE" | grep "\"folder\":" | head -n1 | cut -d'"' -f4
}

registry_list_all() {
  if has_jq; then
    jq -r '.scripts[] | "\(.id)\t\(.folder)\t\(.title)"' "$__REG_FILE" 2>/dev/null

    return 0
  fi

  awk '
    /"id":/     { gsub(/.*"id": *"|" *,?$/, ""); id=$0 }
    /"folder":/ { gsub(/.*"folder": *"|" *,?$/, ""); fld=$0 }
    /"title":/  { gsub(/.*"title": *"|" *,?$/, ""); if (id != "") print id "\t" fld "\t" $0; id=""; fld="" }
  ' "$__REG_FILE"
}

registry_phase_ids() {
  local phase="$1"

  if has_jq; then
    jq -r --arg p "$phase" '.scripts[] | select(.phase==$p) | .id' "$__REG_FILE" 2>/dev/null

    return 0
  fi

  grep -B2 -A2 "\"phase\": *\"$phase\"" "$__REG_FILE" | grep "\"id\":" | cut -d'"' -f4
}
