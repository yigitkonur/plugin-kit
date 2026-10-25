#!/bin/sh
# sync.sh REPO_DIR...   copy the canonical files into plugin repos, then refresh scripts/kit.sha256 and the rendered blocks.
#   scripts/kit/{release.py,check-manifests.py,secret-scan.py,check-links.py,render.py,ci-manifests.yml}, .github/workflows/release.yml
# It never touches a repo's own ci.yml: paste scripts/kit/ci-manifests.yml into it once (between the kit:manifests markers);
# check-manifests.py fails CI when the job drifts from the copy.
set -eu
KIT="$(cd "$(dirname "$0")" && pwd)"
[ $# -gt 0 ] || { echo "usage: sync.sh REPO_DIR..." >&2; exit 2; }
for R in "$@"; do
  R="$(cd "$R" && pwd)"
  mkdir -p "$R/scripts/kit" "$R/.github/workflows"
  cp "$KIT/release/release.py" "$R/scripts/kit/release.py"
  for f in check-manifests.py secret-scan.py check-links.py render.py ci-manifests.yml; do cp "$KIT/ci/$f" "$R/scripts/kit/$f"; done
  cp "$KIT/release/release.yml" "$R/.github/workflows/release.yml"
  chmod +x "$R/scripts/kit/"*.py
  python3 "$R/scripts/kit/check-manifests.py" --write-hashes --root "$R"
  python3 "$R/scripts/kit/render.py" --write --root "$R" || echo "sync: $R has no kit: markers yet in README.md / AGENTS.md (place them, then run render.py --write)"
  echo "synced $R"
done
