#!/usr/bin/env bash
# Clones (or updates) the six AlgoJob service repos into this directory.
#
#   ./clone.sh                 clone/update all six on the default branch
#   ./clone.sh main            use a different branch
#   ./clone.sh --list          show the repo -> folder mapping and exit
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
DEFAULT_BRANCH="local-run"

# folder|repo
SERVICES=(
  "algojob_agent_server|algojob-agent-server"
  "algojobs_service|algojobs_service"
  "algojob_nest|algojob_nest"
  "algojobs_frontend|algojobs_frontend"
  "apex_mircoservice|algoapex-microservice"
  "algojob_microservice_python|algojob_microservice_python"
)

if [ "${1:-}" = "--list" ]; then
  printf "%-30s %s\n" "FOLDER (required)" "REPO"
  for e in "${SERVICES[@]}"; do
    printf "%-30s %s/%s.git\n" "${e%%|*}" "$ORG" "${e##*|}"
  done
  exit 0
fi

BRANCH="${1:-$DEFAULT_BRANCH}"
echo "Branch: $BRANCH"
echo

failed=()
for entry in "${SERVICES[@]}"; do
  folder="${entry%%|*}"
  repo="${entry##*|}"
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
    echo "→ $folder — cloning $repo"
    if ! git clone --branch "$BRANCH" "$url" "$folder" 2>&1 | sed 's/^/   /'; then
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

echo "All six services present."
echo
echo "Next:"
echo "  1. cp .env.example .env          # then edit if your LAN IP differs"
echo "  2. add each service's .env       # NOT in git — get them from the team"
echo "                                   #   see README.md for the list"
echo "  3. ./start.sh"
