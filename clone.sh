#!/usr/bin/env bash
# Clones (or updates) the seven AlgoJob service repos into this directory.
#
#   ./clone.sh                 clone/update all seven, each on its default branch
#   ./clone.sh local-run       override the branch for every repo that has one
#   ./clone.sh --list          show the folder -> repo -> branch mapping and exit
#
# IMPORTANT: the folder names are not cosmetic. The Dockerfile's build context
# is this directory and it COPYs each service by exact path, and
# docker-compose.yml mounts each service's .env by exact path. Several repo
# names differ from the folder they must land in (and `apex_mircoservice`
# carries a typo that is load-bearing), so the mapping below is explicit
# rather than derived from the repo name.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

ORG="https://github.com/algorootprod"

# folder|repo|default-branch
# workload-proctoring and workload-personalized-learning were split out of the
# old algojob_microservice_python monorepo (see git history there) into their
# own repos; those only have `main`, not `local-run`.
SERVICES=(
  "algojob_agent_server|algojob-agent-server|local-run"
  "algojobs_service|algojobs_service|local-run"
  "algojob_nest|algojob_nest|local-run"
  "algojobs_frontend|algojobs_frontend|local-run"
  "apex_mircoservice|algoapex-microservice|local-run"
  "workload-proctoring|algojob-proctoring-mise|main"
  "workload-personalized-learning|Algojob-debug-mise|main"
)

if [ "${1:-}" = "--list" ]; then
  printf "%-30s %-32s %s\n" "FOLDER (required)" "REPO" "BRANCH"
  for e in "${SERVICES[@]}"; do
    IFS='|' read -r folder repo branch <<<"$e"
    printf "%-30s %-32s %s\n" "$folder" "$repo" "$branch"
  done
  exit 0
fi

BRANCH_OVERRIDE="${1:-}"
echo "${BRANCH_OVERRIDE:+Branch override: $BRANCH_OVERRIDE (applied to every repo)}"
echo

failed=()
for entry in "${SERVICES[@]}"; do
  IFS='|' read -r folder repo default_branch <<<"$entry"
  branch="${BRANCH_OVERRIDE:-$default_branch}"
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

echo "All seven services present."
echo
echo "Next:"
echo "  1. cp .env.example .env          # then edit if your LAN IP differs"
echo "  2. add each service's .env       # NOT in git — get them from the team"
echo "                                   #   see README.md for the list"
echo "  3. ./start.sh"
