#!/usr/bin/env bash
# Starts every AlgoJob service natively in one terminal.
#
# To skip a service, comment out its line below with a leading '#' — nothing
# else needs to change. Order matters a little: livekit and proctoring should
# come before agent-server, since it registers against both on startup.
#
# Usage:
#   ./dev.sh              start infra (if needed) + all enabled services
#   ./dev.sh --no-infra   skip the infra preflight (already running)
#   ./dev.sh --down       stop the shared infra stack and exit
#   ./dev.sh --list       print which services are enabled/skipped and exit
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$ROOT_DIR/logs"

# name | relative dir | command
# Every service dir has its own top-level run script — dev.sh just calls it.
# Run a single service by hand the exact same way: cd <dir> && ./<script>.
SERVICES=(
  "livekit      |livekit-local                                              |./run-livekit.sh"
  "proctoring   |algojob-proctoring-mise                                    |./run.sh"
  "algojobsvc   |algojobs_service                                           |./run.sh"
  "apex         |algoapex-microservice                                      |./run.sh"
  "personalized |Algojob-debug-mise                                         |./run.sh"
  "nest         |algojob_nest                                               |./run.sh"
  "frontend     |algojobs_frontend                                          |./run.sh"
  "agent        |algojob-agent-server                                       |./run-agent.sh"
)

COLORS=(31 32 33 34 35 36 91 92 93 94)
INFRA_CONTAINERS=(algojob-infra-redis algojob-infra-keycloak algojob-infra-elasticmq algojob-infra-minio)

do_list=false
do_down=false
no_infra=false
for arg in "$@"; do
  case "$arg" in
    --list) do_list=true ;;
    --down) do_down=true ;;
    --no-infra) no_infra=true ;;
    *)
      echo "Unknown flag: $arg (expected --list, --down, or --no-infra)" >&2
      exit 1
      ;;
  esac
done

if $do_list; then
  echo "Enabled services (edit the SERVICES array in dev.sh to change):"
  for entry in "${SERVICES[@]}"; do
    name="$(cut -d'|' -f1 <<<"$entry" | xargs)"
    echo "  - $name"
  done
  exit 0
fi

if $do_down; then
  echo "Stopping shared infra..."
  (cd "$ROOT_DIR/infra" && docker compose down)
  exit 0
fi

if ! $no_infra; then
  # A native Homebrew Redis on 6379 would block the Docker one from binding.
  if command -v brew >/dev/null 2>&1 && brew services list 2>/dev/null | grep -qE "^redis\s+started"; then
    echo "Stopping native Homebrew redis (would collide with infra's Docker redis on 6379)..."
    brew services stop redis
  fi

  echo "Starting shared infra (redis, keycloak, elasticmq, minio)..."
  (cd "$ROOT_DIR/infra" && docker compose up -d)

  echo "Waiting for infra to become healthy..."
  for container in "${INFRA_CONTAINERS[@]}"; do
    status="starting"
    for _ in $(seq 1 60); do
      status="$(docker inspect --format '{{.State.Health.Status}}' "$container" 2>/dev/null || echo "missing")"
      [ "$status" = "healthy" ] && break
      sleep 2
    done
    echo "  $container: $status"
    if [ "$status" != "healthy" ]; then
      echo "  -> did not become healthy in time; check 'docker compose -f infra/docker-compose.yml logs $container'" >&2
    fi
  done
fi

mkdir -p "$LOG_DIR"
: > "$LOG_DIR/.gitkeep"

trap 'echo; echo "Stopping all services..."; kill 0' INT TERM EXIT

idx=0
for entry in "${SERVICES[@]}"; do
  name="$(cut -d'|' -f1 <<<"$entry" | xargs)"
  dir="$(cut -d'|' -f2 <<<"$entry" | xargs)"
  cmd="$(cut -d'|' -f3 <<<"$entry" | xargs)"
  color="${COLORS[$((idx % ${#COLORS[@]}))]}"
  idx=$((idx + 1))

  if [ ! -d "$ROOT_DIR/$dir" ]; then
    echo "Skipping $name — directory not found: $dir" >&2
    continue
  fi

  echo "Starting $name  ($dir  ->  $cmd)"
  (
    cd "$ROOT_DIR/$dir" || exit 1
    eval "$cmd"
  ) 2>&1 \
    | awk -v prefix="[$name] " -v color="$color" \
        '{ printf "\033[%sm%s%s\033[0m\n", color, prefix, $0; fflush() }' \
    | tee -a "$LOG_DIR/$name.log" &

  sleep 1.5
done

echo
echo "All enabled services launched. Logs are also written to $LOG_DIR/<service>.log"
echo "Press Ctrl-C to stop everything (infra is left running — use ./dev.sh --down to stop it)."
echo

wait
