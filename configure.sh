#!/usr/bin/env bash
# Interactive picker for which AlgoJob repos to clone and which services to
# start. Fully ephemeral — asks every time, writes no config file. Answers
# only live as exported env vars for the rest of this run, which clone.sh and
# start.sh both read directly (each defaults everything to "on" if unset, so
# running them standalone without ./configure.sh is unaffected).
#
#   ./configure.sh
#
# WARNING: algojob-agent-server, interview_manager, apex-assessment, and
# debug-assessment are built into one shared Docker image (see Dockerfile)
# — declining to clone any of THOSE breaks `docker compose build` outright,
# even for repos you didn't decline. algojob_nest and algojobs_frontend each
# build from their own Dockerfile instead (docker-compose.yml's "INDEPENDENT
# BUILDS" note), so declining one of those only affects that one service —
# e.g. you can clone/build/start just nest + frontend without the other four
# at all. Only interview-proctoring and aptitude-assessment (native-only) are
# always safe to skip with zero build-time consequences. This script warns
# inline per-repo.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

# folder|label|CLONE_* var|required-for-docker-build(1/0)|START_* var (empty = not a compose service)
REPOS=(
  "algojob-agent-server|agent-server — LiveKit interview agent worker|CLONE_AGENT_SERVER|1|START_AGENT_SERVER"
  "interview_manager|algojobs-service — AI HR Service (FastAPI)|CLONE_ALGOJOBS_SERVICE|1|START_ALGOJOBS_SERVICE"
  "algojob_nest|nest — backend API (NestJS)|CLONE_NEST|1|START_NEST"
  "algojobs_frontend|frontend — web UI (Next.js)|CLONE_FRONTEND|1|START_FRONTEND"
  "apex-assessment|apex — AlgoApex assessment (FastAPI + SQS workers)|CLONE_APEX|1|START_APEX"
  "debug-assessment|personalized — content generation (FastAPI)|CLONE_PERSONALIZED|1|START_PERSONALIZED"
  "interview-proctoring|proctoring — AI exam proctoring (native-only, not in the Docker build)|CLONE_PROCTORING|0|"
  "aptitude-assessment|aptitude — diagnostic aptitude testing (native-only, not in the Docker build)|CLONE_APTITUDE|0|"
)

echo "AlgoJob setup — clone selection"
echo "agent-server, algojobs-service, apex, and personalized share ONE Docker image"
echo "— declining any of those breaks 'docker compose build' entirely, even for"
echo "repos you keep. nest and frontend each build independently (their own"
echo "Dockerfile), so you can clone/build/run just those two on their own. Only"
echo "proctoring and aptitude (native-only) are always safe to skip."
echo

for entry in "${REPOS[@]}"; do
  IFS='|' read -r folder label var required _ <<<"$entry"
  default="Y/n"
  present=""
  [ -d "$folder/.git" ] && present=" (already present locally)"
  read -r -p "Clone/update $label?$present [$default] " ans
  ans="${ans:-y}"
  case "$ans" in
    y|Y) printf -v "$var" '1' ;;
    *)
      printf -v "$var" '0'
      if [ "$folder" = "algojob_nest" ] || [ "$folder" = "algojobs_frontend" ]; then
        echo "  NOTE: this only breaks building/starting $label itself — the other"
        echo "  services aren't affected (it builds from its own Dockerfile)."
      elif [ "$required" = "1" ]; then
        echo "  WARNING: this repo is required for the shared Docker image build —"
        echo "  'docker compose build' / './start.sh --build' will fail without it,"
        echo "  even for services you didn't decline."
      fi
      ;;
  esac
done

if [ "${CLONE_FRONTEND}" = "1" ] && [ "${CLONE_NEST}" != "1" ]; then
  echo
  echo "frontend's build depends on nest at the compose level too — cloning nest too."
  CLONE_NEST=1
fi

echo
echo "Which services should ./start.sh actually launch (Docker only — doesn't"
echo "affect what you just chose to clone)?"
echo

for entry in "${REPOS[@]}"; do
  IFS='|' read -r _ label _ _ start_var <<<"$entry"
  [ -z "$start_var" ] && continue
  default="Y/n"
  read -r -p "Start $label? [$default] " ans
  ans="${ans:-y}"
  case "$ans" in
    y|Y) printf -v "$start_var" '1' ;;
    *) printf -v "$start_var" '0' ;;
  esac
done

if [ "${START_FRONTEND:-0}" = "1" ] && [ "${START_NEST:-0}" != "1" ]; then
  echo
  echo "frontend depends_on nest at the compose level (docker-compose.yml) — enabling nest too."
  START_NEST=1
fi

export CLONE_AGENT_SERVER CLONE_ALGOJOBS_SERVICE CLONE_NEST CLONE_FRONTEND CLONE_APEX \
  CLONE_PERSONALIZED CLONE_PROCTORING CLONE_APTITUDE \
  START_AGENT_SERVER START_ALGOJOBS_SERVICE START_NEST START_FRONTEND START_APEX \
  START_PERSONALIZED

echo
read -r -p "Run ./clone.sh now with these choices? [Y/n] " do_clone
if [ "${do_clone:-y}" != "n" ] && [ "${do_clone:-y}" != "N" ]; then
  ./clone.sh
fi

echo
read -r -p "Build the shared Docker image now? (./start.sh --build) [Y/n] " do_build
if [ "${do_build:-y}" != "n" ] && [ "${do_build:-y}" != "N" ]; then
  ./start.sh --build
fi

echo
read -r -p "Start the selected services now with ./start.sh? [Y/n] " do_start
if [ "${do_start:-y}" != "n" ] && [ "${do_start:-y}" != "N" ]; then
  ./start.sh
fi
