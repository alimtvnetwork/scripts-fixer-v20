#!/usr/bin/env bash
# zsh-fanout step 01: unpack the controller-supplied tarball of
# scripts-linux/{_shared,60-install-zsh,61-install-zsh-theme-switcher,62-install-zsh-clear}
# into REMOTE_BUNDLE_DIR on this host.
#
# Required env: ZSH_BUNDLE_B64
# Optional env: REMOTE_TMP (default /tmp), REMOTE_BUNDLE_DIR (default /opt/zsh-fanout)
set -e
REMOTE_TMP="${REMOTE_TMP:-/tmp}"
REMOTE_BUNDLE_DIR="${REMOTE_BUNDLE_DIR:-/opt/zsh-fanout}"
TARBALL="$REMOTE_TMP/zsh-fanout-bundle.tgz"

if [ -z "${ZSH_BUNDLE_B64:-}" ]; then
  echo "[FILE-ERROR] path=ZSH_BUNDLE_B64 reason=env var empty -- controller must export the base64 tarball" >&2
  exit 2
fi
mkdir -p "$REMOTE_TMP" || { echo "[FILE-ERROR] path=$REMOTE_TMP reason=mkdir failed on $(hostname)" >&2; exit 2; }
sudo mkdir -p "$REMOTE_BUNDLE_DIR" || { echo "[FILE-ERROR] path=$REMOTE_BUNDLE_DIR reason=sudo mkdir failed on $(hostname)" >&2; exit 2; }

if ! printf '%s' "$ZSH_BUNDLE_B64" | base64 -d > "$TARBALL" 2>/dev/null; then
  echo "[FILE-ERROR] path=$TARBALL reason=base64 decode failed" >&2
  exit 2
fi
if ! sudo tar -xzf "$TARBALL" -C "$REMOTE_BUNDLE_DIR"; then
  echo "[FILE-ERROR] path=$REMOTE_BUNDLE_DIR reason=tar extract failed" >&2
  exit 2
fi
sudo chmod -R a+rX "$REMOTE_BUNDLE_DIR"
sudo find "$REMOTE_BUNDLE_DIR" -name 'run.sh' -exec chmod +x {} \;
rm -f "$TARBALL"
echo "[OK] zsh-fanout: bundle landed at $REMOTE_BUNDLE_DIR on $(hostname)"
