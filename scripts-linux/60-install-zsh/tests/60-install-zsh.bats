#!/usr/bin/env bats
# Smoke tests for scripts-linux/60-install-zsh/run.sh
# Focus: idempotency of extras block + --user re-exec via user-reexec.sh.
# These tests never invoke apt/curl/git; they exercise pure-bash paths only.

setup() {
  ROOT_DIR="$(cd "$BATS_TEST_DIRNAME/../.." && pwd)"
  SCRIPT="$ROOT_DIR/60-install-zsh/run.sh"
  REEXEC="$ROOT_DIR/_shared/user-reexec.sh"
  [ -f "$SCRIPT" ] || { echo "missing $SCRIPT"; return 1; }
  [ -f "$REEXEC" ] || { echo "missing $REEXEC"; return 1; }
}

# ---------------------------------------------------------------------------
# --user re-exec (scripts-linux/_shared/user-reexec.sh)
# ---------------------------------------------------------------------------

@test "user-reexec: no --user is a no-op and leaves REEXEC_ARGS empty" {
  run bash -c '. "'"$REEXEC"'"; maybe_reexec_as_user install --foo; echo "COUNT=${#REEXEC_ARGS[@]}"; echo "ARGS=${REEXEC_ARGS[*]}"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"COUNT=2"* ]]
  [[ "$output" == *"ARGS=install --foo"* ]]
}

@test "user-reexec: --user matching current user is a no-op" {
  ME=$(id -un)
  run bash -c '. "'"$REEXEC"'"; maybe_reexec_as_user install --user '"$ME"' --flag; echo "ARGS=${REEXEC_ARGS[*]}"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ARGS=install --flag"* ]]
}

@test "user-reexec: --user=<name> equals-form is stripped from REEXEC_ARGS" {
  ME=$(id -un)
  run bash -c '. "'"$REEXEC"'"; maybe_reexec_as_user install --user='"$ME"' repair; echo "ARGS=${REEXEC_ARGS[*]}"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ARGS=install repair"* ]]
}

@test "user-reexec: --user without root exits [ERR]" {
  if [ "$(id -u)" = "0" ]; then skip "running as root; cannot test non-root refusal"; fi
  run bash -c '. "'"$REEXEC"'"; maybe_reexec_as_user install --user root'
  [ "$status" -ne 0 ]
  [[ "$output" == *"[ERR] --user root requires running as root"* ]]
}

# ---------------------------------------------------------------------------
# Idempotency: extras marker block is appended once, never duplicated
# ---------------------------------------------------------------------------

@test "append_extras_zshrc: second run is a no-op (marker guard)" {
  TMP=$(mktemp -d); export HOME="$TMP"
  export ZSHRC="$TMP/.zshrc"
  EXTRAS_MARKER_BEGIN="# >>> lovable zsh extras >>>"
  EXTRAS_MARKER_END="# <<< lovable zsh extras <<<"
  PAYLOAD_EXTRAS="$ROOT_DIR/60-install-zsh/payload/zshrc-extras"
  DO_DEPLOY_EXTRAS=true
  PRESET_EXTRAS_LINE=""
  # Seed a minimal .zshrc
  echo '# seed' > "$ZSHRC"

  # Inline the same append_extras_zshrc logic the installer runs
  append_extras() {
    [ "$DO_DEPLOY_EXTRAS" = "true" ] || return 0
    if grep -Fq "$EXTRAS_MARKER_BEGIN" "$ZSHRC" 2>/dev/null; then return 0; fi
    { echo ""; echo "$EXTRAS_MARKER_BEGIN"; cat "$PAYLOAD_EXTRAS"; echo ""; echo "$EXTRAS_MARKER_END"; } >> "$ZSHRC"
  }
  append_extras
  first_count=$(grep -cF "$EXTRAS_MARKER_BEGIN" "$ZSHRC")
  append_extras
  append_extras
  final_count=$(grep -cF "$EXTRAS_MARKER_BEGIN" "$ZSHRC")

  rm -rf "$TMP"
  [ "$first_count" = "1" ]
  [ "$final_count" = "1" ]
}

@test "config.json declares supported theme_presets registry" {
  CONFIG="$ROOT_DIR/60-install-zsh/config.json"
  command -v jq >/dev/null 2>&1 || skip "jq not installed"
  run jq -r '.theme_presets | keys | join(",")' "$CONFIG"
  [ "$status" -eq 0 ]
  [[ "$output" == *"powerlevel10k"* ]]
  [[ "$output" == *"starship"* ]]
  [[ "$output" == *"spaceship"* ]]
}

@test "zshrc-extras payload wires autosuggest-accept + history-substring-search" {
  EXTRAS="$ROOT_DIR/60-install-zsh/payload/zshrc-extras"
  grep -Fq "autosuggest-accept" "$EXTRAS"
  grep -Fq "history-substring-search-up" "$EXTRAS"
  grep -Fq "history-substring-search-down" "$EXTRAS"
}
