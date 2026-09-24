#!/usr/bin/env bash
# _clear-agy-args.sh -- CLI argument parsing for clear-agy.sh.
# Part of 69-install-antigravity.

parse_arguments() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --predict|-p|--dry-run|predict)
        IS_PREDICT=1
        shift
        ;;
      --yes|-y|clean|clear)
        IS_YES=1
        IS_PREDICT=0
        shift
        ;;
      --undo)
        UNDO_TX="${2:-}"
        shift 2
        ;;
      --list-backups|list-backups|backups)
        IS_LIST_BACKUPS=1
        shift
        ;;
      -t[0-9]*|--threshold=[0-9]*)
        _val="${1#*-t}"
        _val="${_val#*=}"
        THRESHOLD="$_val"
        shift
        ;;
      --threshold|-t)
        THRESHOLD="${2:-200}"
        shift 2
        ;;
      -k[0-9]*|--keep=[0-9]*)
        _val="${1#*-k}"
        _val="${_val#*=}"
        KEEP_COUNT="$_val"
        shift
        ;;
      --keep|-k)
        KEEP_COUNT="${2:-0}"
        shift 2
        ;;
      [0-9]*)
        KEEP_COUNT="$1"
        shift
        ;;
      --kill)
        IS_KILL=1
        shift
        ;;
      --json)
        IS_JSON=1
        shift
        ;;
      -h|--help)
        echo "Usage: clear-agy.sh [count] [--keep <N>] [--predict] [--yes] [--undo <tx_id>] [--threshold <KB>] [--kill] [--json]"
        exit 0
        ;;
      *)
        shift
        ;;
    esac
  done
}
