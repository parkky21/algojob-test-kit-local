#!/usr/bin/env bash
# Clones (or updates) the AlgoJob service repos into this directory, each into
# a folder matching its (current) repo name.
#
#   ./clone.sh                 clone/update the selected repos, each on main
#   ./clone.sh local-run       override the branch for every repo (opt-in only)
#   ./clone.sh --list          show the repo -> branch mapping (and enabled/skipped) and exit
#
# Every repo clones from `main` by default. `local-run` branches still exist on
# some of these repos, but they are no longer the default — pass the branch
# name explicitly if you want one.
#
# Selection is per-repo via env vars (CLONE_AGENT_SERVER, CLONE_ALGOJOBS_SERVICE,
# CLONE_NEST, CLONE_FRONTEND, CLONE_APEX, CLONE_PERSONALIZED, CLONE_PROCTORING,
# CLONE_APTITUDE — see the SERVICES table below), each defaulting to 1 (clone)
# if unset. No config file is read — this is stateless by design. Run
# ./configure.sh for an interactive per-repo picker (it exports these and calls
# this script for you), or export them yourself for a one-off:
# `CLONE_PROCTORING=0 ./clone.sh`.
#
# WARNING: four of the eight repos (algojob-agent-server, interview_manager,
# apex-assessment, debug-assessment) are built into one shared Docker image
# (see Dockerfile) — skipping any of THOSE (marked "required" in --list /
# SERVICES below) means `docker compose build` fails outright on its COPY
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
# Only interview-proctoring and aptitude-assessment (native-only, excluded
# from the Docker build entirely) are safe to skip freely with no build-time
# consequences.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

ORG="https://github.com/algorootprod"

# folder (= repo name)|default-branch|CLONE_* env var|required-for-docker-build(1/0)
# All repos clone from `main`. Several of them also carry a `local-run` branch
# (that used to be the default here) — pass `./clone.sh local-run` if you
# specifically want those; main is what everyone should be on otherwise.
SERVICES=(
  "algojob-agent-server|main|CLONE_AGENT_SERVER|1"
  "interview_manager|main|CLONE_ALGOJOBS_SERVICE|1"
  "algojob_nest|main|CLONE_NEST|1"
  "algojobs_frontend|main|CLONE_FRONTEND|1"
  "apex-assessment|main|CLONE_APEX|1"
  "interview-proctoring|main|CLONE_PROCTORING|0"
  "debug-assessment|main|CLONE_PERSONALIZED|1"
  "aptitude-assessment|main|CLONE_APTITUDE|0"
)

# The GitHub repos above were renamed on 2026-08-03 (org: algorootprod).
# Anyone with a pre-rename checkout has these old folders lying around
# instead. Before cloning, offer to delete each old folder so the repo can
# be freshly cloned under its new name — everything downstream (Dockerfile,
# docker-compose.yml, dev.sh, configure.sh, RUNBOOK.md) now expects the new
# folder names, so leaving an old one in place just means that service gets
# skipped below.
#   old name                -> new name
#   algoapex-microservice    -> apex-assessment
#   Algojob-debug-mise       -> debug-assessment
#   algojobs_service         -> interview_manager
#   algojob-proctoring-mise  -> interview-proctoring
LEGACY_RENAMES=(
  "algoapex-microservice|apex-assessment"
  "Algojob-debug-mise|debug-assessment"
  "algojobs_service|interview_manager"
  "algojob-proctoring-mise|interview-proctoring"
)

for entry in "${LEGACY_RENAMES[@]}"; do
  IFS='|' read -r old_name new_name <<<"$entry"
  [ -d "$old_name/.git" ] || continue
  [ -d "$new_name/.git" ] && continue # already migrated

  echo "'$old_name' has been renamed to '$new_name' on GitHub."
  if [ -t 0 ]; then
    read -r -p "Delete local '$old_name' so it can be re-cloned as '$new_name'? [y/N] " ans
  else
    ans="n"
    echo "(no terminal attached, defaulting to 'n' — re-run interactively to delete it)"
  fi
  case "$ans" in
    y|Y)
      rm -rf "$old_name"
      echo "Deleted '$old_name'."
      ;;
    *)
      echo "Keeping '$old_name' as-is — '$new_name' will be skipped below until you remove it."
      ;;
  esac
  echo
done

: "${CLONE_AGENT_SERVER:=1}"
: "${CLONE_ALGOJOBS_SERVICE:=1}"
: "${CLONE_NEST:=1}"
: "${CLONE_FRONTEND:=1}"
: "${CLONE_APEX:=1}"
: "${CLONE_PROCTORING:=1}"
: "${CLONE_PERSONALIZED:=1}"
: "${CLONE_APTITUDE:=1}"

if [ "${1:-}" = "--list" ]; then
  printf "%-25s %-10s %-9s %s\n" "REPO (= folder)" "BRANCH" "REQUIRED" "STATUS"
  for e in "${SERVICES[@]}"; do
    IFS='|' read -r repo branch var required <<<"$e"
    status="enabled"
    [ "${!var}" != "1" ] && status="skipped ($var=0)"
    printf "%-25s %-10s %-9s %s\n" "$repo" "$branch" "$([ "$required" = "1" ] && echo yes || echo no)" "$status"
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
