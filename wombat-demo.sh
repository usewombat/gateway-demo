#!/usr/bin/env bash
set -euo pipefail

DEMO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect repo: WOMBAT_REPO env var → git remote → error
if [ -n "${WOMBAT_REPO:-}" ]; then
  REPO="$WOMBAT_REPO"
else
  REPO=$(git -C "$DEMO_DIR" remote get-url origin 2>/dev/null \
    | sed 's|.*github\.com[:/]||; s|\.git$||' \
    | tr -d '[:space:]') || true
fi

if [ -z "$REPO" ]; then
  echo "wombat-demo: could not detect GitHub repo from git remote." >&2
  echo "  Fork this repo on GitHub, clone your fork, and re-run." >&2
  echo "  Or set WOMBAT_REPO=owner/repo to override." >&2
  exit 1
fi

# Expand {{REPO}} in the template into a temp file
PERMISSIONS=$(mktemp /tmp/wombat-permissions-XXXXXX)
trap "rm -f '$PERMISSIONS'" EXIT
sed "s|{{REPO}}|$REPO|g" "$DEMO_DIR/permissions.template.json" > "$PERMISSIONS"

echo "[wombat-demo] repo     → $REPO" >&2
echo "[wombat-demo] manifest → $PERMISSIONS" >&2

exec wombat \
  --manifest "$PERMISSIONS" \
  --upstream github \
  --agent auto
