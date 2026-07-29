#!/usr/bin/env bash
# Clones (or updates) the AlgoJob service repos into this directory, each into
# a folder matching its repo name.
#
#   ./clone.sh                 clone/update the selected repos, each on its default branch
#   ./clone.sh local-run       override the branch for every repo that has one
#   ./clone.sh --list          show the repo -> branch mapping (and enabled/skipped) and exit
#
# Selection is per-repo via env vars (CLONE_AGENT_SERVER, CLONE_ALGOJOBS_SERVICE,
# CLONE_NEST, CLONE_FRONTEND, CLONE_APEX, CLONE_PERSONALIZED, CLONE_PROCTORING —
# see the SERVICES table below), each defaulting to 1 (clone) if unset. No
# config file is read — this is stateless by design. Run ./configure.sh for an
# interactive per-repo picker (it exports these and calls this script for you),
# or export them yourself for a one-off: `CLONE_PROCTORING=0 ./clone.sh`.
#
# WARNING: four of the seven repos (algojob-agent-server, algojobs_service,
# algoapex-microservice, Algojob-debug-mise) are built into one shared Docker
# image (see Dockerfile) — skipping any of THOSE (marked "required" in --list
# / SERVICES below) means `docker compose build` fails outright on its COPY
# step, even for services you didn't skip.
#
# algojob_nest and algojobs_frontend are ALSO marked required, but for a
# narrower reason: they each build from their OWN Dockerfile now
# (docker-compose.yml's "INDEPENDENT BUILDS" note) — so skipping one of them
# only breaks building/running that one service (`docker compose build nest`
# or `build frontend`), not the shared image. (They're also still bundled
# into the shared image's own build for the all-in-one-image deploy path, so
# skipping them still blocks that path too — but not the other 4 services'
# individual containers.)
#
# Only algojob-proctoring-mise (native-only, excluded from the Docker build
# entirely) is safe to skip freely with no build-time consequences.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

ORG="https://github.com/algorootprod"

# repo (= folder name)|default-branch|CLONE_* env var|required-for-docker-build(1/0)
# algojob-proctoring-mise and Algojob-debug-mise were split out of the old
# algojob_microservice_python monorepo (see git history there) into their
# own repos; those only have `main`, not `local-run`.
SERVICES=(
  "algojob-agent-server|local-run|CLONE_AGENT_SERVER|1"
  "algojobs_service|local-run|CLONE_ALGOJOBS_SERVICE|1"
  "algojob_nest|local-run|CLONE_NEST|1"
  "algojobs_frontend|local-run|CLONE_FRONTEND|1"
  "algoapex-microservice|local-run|CLONE_APEX|1"
  "algojob-proctoring-mise|main|CLONE_PROCTORING|0"
  "Algojob-debug-mise|main|CLONE_PERSONALIZED|1"
)

: "${CLONE_AGENT_SERVER:=1}"
: "${CLONE_ALGOJOBS_SERVICE:=1}"
: "${CLONE_NEST:=1}"
: "${CLONE_FRONTEND:=1}"
: "${CLONE_APEX:=1}"
: "${CLONE_PROCTORING:=1}"
: "${CLONE_PERSONALIZED:=1}"

if [ "${1:-}" = "--list" ]; then
  printf "%-30s %-10s %-9s %s\n" "REPO (= folder)" "BRANCH" "REQUIRED" "STATUS"
  for e in "${SERVICES[@]}"; do
    IFS='|' read -r repo branch var required <<<"$e"
    status="enabled"
    [ "${!var}" != "1" ] && status="skipped ($var=0)"
    printf "%-30s %-10s %-9s %s\n" "$repo" "$branch" "$([ "$required" = "1" ] && echo yes || echo no)" "$status"
  done
  exit 0
fi

BRANCH_OVERRIDE="${1:-}"
echo "${BRANCH_OVERRIDE:+Branch override: $BRANCH_OVERRIDE (applied to every repo)}"
echo

failed=()
skipped=()
skipped_required=()
for entry in "${SERVICES[@]}"; do
  IFS='|' read -r repo default_branch var required <<<"$entry"

  if [ "${!var}" != "1" ]; then
    echo "→ $repo — skipped ($var=0)"
    skipped+=("$repo")
    [ "$required" = "1" ] && skipped_required+=("$repo")
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
  echo "Skipped: ${skipped[*]}"
fi
if [ ${#skipped_required[@]} -gt 0 ]; then
  echo
  echo "WARNING: ${skipped_required[*]} are built into the shared Docker image —" >&2
  echo "'docker compose build' / './start.sh --build' will fail without them." >&2
  echo "Re-run ./clone.sh (or ./configure.sh) without skipping them if you plan to" >&2
  echo "run the Docker stack." >&2
fi
echo
echo "All selected services present."
echo
echo "Next:"
echo "  1. cp .env.example .env          # then edit if your LAN IP differs"
echo "  2. add each service's .env       # NOT in git — get them from the team"
echo "                                   #   see README.md for the list"
echo "  3. ./start.sh"
