#!/usr/bin/env bash
# Starts the AlgoJob stack: the selected services in Docker + LiveKit natively.
#
#   ./start.sh                       containers (detached) + native livekit-server (foreground)
#   ./start.sh --only=nest,frontend  just those services (shorthand for setting all six START_* vars)
#   ./start.sh --no-livekit          containers only
#   ./start.sh --build               build the selected app services and exit
#   ./start.sh --down                stop containers (and this script's livekit, via Ctrl-C)
#
# Which app services actually start is controlled by env vars (START_APEX,
# START_NEST, START_FRONTEND, START_ALGOJOBS_SERVICE, START_PERSONALIZED,
# START_AGENT_SERVER), each defaulting to 1 (start) if unset. No config file
# is read — this is stateless by design. Run ./configure.sh for an interactive
# per-service picker (it exports these and calls this script for you), export
# them yourself for a one-off (`START_APEX=0 ./start.sh`), or pass --only=
# with a comma-separated list of: algojobs-service, apex, personalized, nest,
# frontend, agent-server — e.g. `./start.sh --only=nest,frontend` starts
# exactly those two (and turns every other service off, overriding whatever
# the START_* env vars say).
# Infra (redis/elasticmq/minio) always starts regardless of selection.
#
# LiveKit is the one service left outside Docker. It advertises a single IP as
# its ICE candidate, and under bridge networking no value works for both the
# browser and the in-Docker agent at the same time — the container IP is
# unreachable from the browser (audio never arrives, interviews record an empty
# transcript), while 127.0.0.1 means "itself" to the agent container. Bound to
# the host it advertises one LAN address that both can reach.
#
# Docker Compose cannot start a host process, so this wrapper does it. LiveKit
# runs in the FOREGROUND: its logs are visible and Ctrl-C stops it. Containers
# are deliberately left running afterwards (containers can be slow to restart);
# use ./start.sh --down to stop them.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

no_livekit=false
do_down=false
do_build=false
only_services=""
for arg in "$@"; do
  case "$arg" in
    --no-livekit) no_livekit=true ;;
    --down) do_down=true ;;
    --build) do_build=true ;;
    --only=*) only_services="${arg#--only=}" ;;
    *) echo "Unknown flag: $arg (expected --only=<list>, --no-livekit, --build, or --down)" >&2; exit 1 ;;
  esac
done

# --only=... is shorthand that overrides the START_* env vars wholesale: it
# turns every service off, then flips on just the ones named. This has to
# happen BEFORE the `: "${VAR:=1}"` defaulting below, since that defaulting
# only fires on an unset var — an --only-driven "0" must win over it.
if [ -n "$only_services" ]; then
  START_ALGOJOBS_SERVICE=0
  START_APEX=0
  START_PERSONALIZED=0
  START_NEST=0
  START_FRONTEND=0
  START_AGENT_SERVER=0
  IFS=',' read -ra selected <<<"$only_services"
  for s in "${selected[@]}"; do
    case "$s" in
      algojobs-service) START_ALGOJOBS_SERVICE=1 ;;
      apex) START_APEX=1 ;;
      personalized) START_PERSONALIZED=1 ;;
      nest) START_NEST=1 ;;
      frontend) START_FRONTEND=1 ;;
      agent-server) START_AGENT_SERVER=1 ;;
      *)
        echo "Unknown service in --only: '$s' (expected: algojobs-service, apex, personalized, nest, frontend, agent-server)" >&2
        exit 1
        ;;
    esac
  done
fi

: "${START_ALGOJOBS_SERVICE:=1}"
: "${START_APEX:=1}"
: "${START_PERSONALIZED:=1}"
: "${START_NEST:=1}"
: "${START_FRONTEND:=1}"
: "${START_AGENT_SERVER:=1}"

# frontend depends_on nest at the compose level — Compose errors out
# ("depends on undefined service") if nest's profile isn't also active.
if [ "$START_FRONTEND" = "1" ] && [ "$START_NEST" != "1" ]; then
  echo "frontend depends_on nest (docker-compose.yml) — enabling nest too."
  START_NEST=1
fi

# All six app profiles — used only for --down, to make sure nothing gets
# orphaned if your selection changed since the `up` that started it (e.g.
# nest built its own separate image; if it's not in ALL_APP_PROFILES here, a
# leftover nest container from an earlier run wouldn't get cleaned up).
ALL_APP_PROFILES=(--profile algojobs-service --profile apex --profile personalized --profile nest --profile frontend --profile agent-server)

# The selected app profiles — used for both `up` and `--build`. Unlike before
# nest/frontend got their own independent Dockerfiles, building is NOT "cheap
# to always do in full" anymore: algojobs-service/apex/personalized/agent-server
# still share one image (so building any of those always builds the whole
# thing regardless of which of the 4 you pick), but nest/frontend are now
# separate builds that fail outright if their repo wasn't cloned — so --build
# must respect the same selection as `up`, not force all 6.
profile_flags=()
[ "$START_ALGOJOBS_SERVICE" = "1" ] && profile_flags+=(--profile algojobs-service)
[ "$START_APEX" = "1" ] && profile_flags+=(--profile apex)
[ "$START_PERSONALIZED" = "1" ] && profile_flags+=(--profile personalized)
[ "$START_NEST" = "1" ] && profile_flags+=(--profile nest)
[ "$START_FRONTEND" = "1" ] && profile_flags+=(--profile frontend)
[ "$START_AGENT_SERVER" = "1" ] && profile_flags+=(--profile agent-server)

if $do_build; then
  echo "Building (${profile_flags[*]:-infra only, nothing to build})..."
  # ${arr[@]+...} guard: see the note on the `up` call below re: bash 3.2.
  docker compose ${profile_flags[@]+"${profile_flags[@]}"} build
  exit $?
fi

if $do_down; then
  echo "Stopping containers..."
  # --profile docker-livekit is required to also remove a livekit container left
  # over from the Linux/host-networking path, and all app profiles are passed
  # so `down` isn't fooled by a different START_* selection than the `up` that
  # started these containers — `docker compose down` silently skips profiled
  # services that aren't active, leaving them running (e.g. livekit holding
  # port 7880).
  docker compose --profile docker-livekit "${ALL_APP_PROFILES[@]}" down
  echo "If livekit-server is still running natively, stop it with Ctrl-C in its terminal."
  exit 0
fi

echo "Starting containers (${profile_flags[*]:-infra only})..."
# --wait blocks until services with healthchecks report healthy, so Redis is
# ready before LiveKit (which depends on it) starts.
# The ${arr[@]+...} guard avoids bash 3.2's "unbound variable" on an empty
# array under `set -u` (macOS ships 3.2 by default — no fix until 4.4).
if ! docker compose ${profile_flags[@]+"${profile_flags[@]}"} up -d --wait; then
  echo
  echo "docker compose up failed. Check 'docker compose ps' and 'docker compose logs'." >&2
  exit 1
fi
docker compose ps --format "table {{.Service}}\t{{.Status}}"

if $no_livekit; then
  echo
  echo "Skipping LiveKit (--no-livekit). Interviews will not work without it."
  exit 0
fi

# If the root .env points at a remote LiveKit (Cloud or self-hosted wss://),
# there is nothing to run locally — the services already talk to it directly.
livekit_url="$(grep -E '^LIVEKIT_URL=' .env 2>/dev/null | tail -1 | cut -d= -f2-)"
case "$livekit_url" in
  wss://*|https://*)
    echo
    echo "LIVEKIT_URL is remote ($livekit_url) — not starting a local server."
    echo "Services connect to it directly. Containers are up; nothing else to do."
    exit 0
    ;;
esac

if ! command -v livekit-server >/dev/null 2>&1; then
  echo
  echo "livekit-server not found — containers are up, but interviews need it." >&2
  echo "Install with:  brew install livekit    then re-run ./start.sh" >&2
  exit 1
fi

# LiveKit binds these on the host; a leftover process would silently win.
for port in 7880 7881; do
  if lsof -nP -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; then
    echo
    echo "Port $port is already in use — stop that process first:" >&2
    lsof -nP -iTCP:"$port" -sTCP:LISTEN | awk 'NR==2{print "  " $1 " (pid " $2 ")"}' >&2
    exit 1
  fi
done

echo
echo "Containers up. Starting LiveKit natively (Ctrl-C to stop; containers keep running)."
echo
exec ./livekit-local/run-livekit.sh
