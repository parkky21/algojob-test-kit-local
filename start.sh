#!/usr/bin/env bash
# Starts the whole AlgoJob stack: 9 services in Docker + LiveKit natively.
#
#   ./start.sh              containers (detached) + native livekit-server (foreground)
#   ./start.sh --no-livekit containers only
#   ./start.sh --down       stop containers (and this script's livekit, via Ctrl-C)
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
# are deliberately left running afterwards (Keycloak is slow to restart);
# use ./start.sh --down to stop them.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

no_livekit=false
do_down=false
for arg in "$@"; do
  case "$arg" in
    --no-livekit) no_livekit=true ;;
    --down) do_down=true ;;
    *) echo "Unknown flag: $arg (expected --no-livekit or --down)" >&2; exit 1 ;;
  esac
done

if $do_down; then
  echo "Stopping containers..."
  # --profile docker-livekit is required to also remove a livekit container left
  # over from the Linux/host-networking path: `docker compose down` silently
  # skips profiled services, leaving it running and holding port 7880.
  docker compose --profile docker-livekit down
  echo "If livekit-server is still running natively, stop it with Ctrl-C in its terminal."
  exit 0
fi

echo "Starting containers..."
# --wait blocks until services with healthchecks report healthy, so Redis is
# ready before LiveKit (which depends on it) starts.
if ! docker compose up -d --wait; then
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
