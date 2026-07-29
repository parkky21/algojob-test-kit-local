#!/usr/bin/env bash
# Clones (or updates) the AlgoJob service repos into this directory, each into
# a folder matching its repo name.
#
#   ./clone.sh                 clone/update the selected repos, each on its default branch
#   ./clone.sh local-run       override the branch for every repo that has one
#   ./clone.sh --list          show the repo -> branch mapping (and enabled/skipped) and exit
#
# Six of the seven repos are always cloned: they're built into one shared
# Docker image (see Dockerfile), so the build needs all of them present
# regardless of which containers you plan to start. Only algojob-proctoring-mise
# (native-only — excluded from the Docker build) is toggleable, via
# CLONE_PROCTORING in services.conf. Run ./configure.sh for an interactive
# picker, or copy services.conf.example to services.conf and edit by hand.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

if [ -f services.conf ]; then
  source services.conf
elif [ -f services.conf.example ]; then
  source services.conf.example
fi
: "${CLONE_PROCTORING:=1}"

ORG="https://github.com/algorootprod"

# repo (= folder name)|default-branch
# algojob-proctoring-mise and Algojob-debug-mise were split out of the old
# algojob_microservice_python monorepo (see git history there) into their
# own repos; those only have `main`, not `local-run`.
SERVICES=(
  "algojob-agent-server|local-run"
  "algojobs_service|local-run"
  "algojob_nest|local-run"
  "algojobs_frontend|local-run"
  "algoapex-microservice|local-run"
  "algojob-proctoring-mise|main"
  "Algojob-debug-mise|main"
)

if [ "${1:-}" = "--list" ]; then
  printf "%-30s %-10s %s\n" "REPO (= folder)" "BRANCH" "STATUS"
  for e in "${SERVICES[@]}"; do
    IFS='|' read -r repo branch <<<"$e"
    status="enabled"
    if [ "$repo" = "algojob-proctoring-mise" ] && [ "$CLONE_PROCTORING" != "1" ]; then
      status="skipped (CLONE_PROCTORING=0)"
    fi
    printf "%-30s %-10s %s\n" "$repo" "$branch" "$status"
  done
  exit 0
fi

BRANCH_OVERRIDE="${1:-}"
echo "${BRANCH_OVERRIDE:+Branch override: $BRANCH_OVERRIDE (applied to every repo)}"
echo

failed=()
skipped=()
for entry in "${SERVICES[@]}"; do
  IFS='|' read -r repo default_branch <<<"$entry"

  if [ "$repo" = "algojob-proctoring-mise" ] && [ "$CLONE_PROCTORING" != "1" ]; then
    echo "→ $repo — skipped (CLONE_PROCTORING=0 in services.conf)"
    skipped+=("$repo")
    continue
  fi

  branch="${BRANCH_OVERRIDE:-$default_branch}"
  folder="$repo"
  url="$ORG/$repo.git"

  if [ -d "$folder/.git" ]; then
    echo "→ $folder — exists, fetching"
    # Deliberately fetch rather than checkout/pull: developers work across many
    # branches here, and silently moving someone's working tree would be rude.
    if ! git -C "$folder" fetch --all --prune >/dev/null 2>&1; then
      failed+=("$folder (fetch failed)")
      continue
    fi
    printf "   on branch: %s\n" "$(git -C "$folder" branch --show-current 2>/dev/null)"
  else
    echo "→ $folder — cloning $repo ($branch)"
    # NOTE: `cmd | sed ...; if [ $? ...` — not `if ! cmd | sed`, which would
    # check sed's exit status (always 0) instead of git clone's.
    git clone --branch "$branch" "$url" "$folder" 2>&1 | sed 's/^/   /'
    clone_status="${PIPESTATUS[0]}"
    if [ "$clone_status" -ne 0 ]; then
      failed+=("$folder (clone failed)")
    fi
  fi
done

echo
if [ ${#failed[@]} -gt 0 ]; then
  echo "Some repos did not sync:" >&2
  for f in "${failed[@]}"; do echo "  - $f" >&2; done
  echo "Check your GitHub access, then re-run." >&2
  exit 1
fi

if [ ${#skipped[@]} -gt 0 ]; then
  echo "Skipped (see services.conf): ${skipped[*]}"
fi
echo "All selected services present."
echo
echo "Next:"
echo "  1. cp .env.example .env          # then edit if your LAN IP differs"
echo "  2. add each service's .env       # NOT in git — get them from the team"
echo "                                   #   see README.md for the list"
echo "  3. ./start.sh"
