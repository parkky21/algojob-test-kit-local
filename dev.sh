#!/usr/bin/env bash
# Starts every AlgoJob service natively in one terminal.
#
# To skip a service, comment out its line below with a leading '#' — nothing
# else needs to change. Order matters a little: livekit and proctoring should
# come before agent-server, since it registers against both on startup.
#
# Usage:
#   ./dev.sh                  start infra (if needed) + all enabled services
#   ./dev.sh nest frontend    only start/stream the named services (still
#                             writes every enabled service's log to disk)
#   ./dev.sh --quiet          don't stream any logs to the terminal; just
#                             write to logs/<service>.log (tail what you need)
#   ./dev.sh --no-infra       skip the infra preflight (already running)
#   ./dev.sh --no-reclaim     don't free service ports first (see below)
#   ./dev.sh --down           stop the shared infra stack and exit
#   ./dev.sh --list           print which services are enabled/skipped and exit
#
# Every run starts fresh: before launching anything, whatever is still
# listening on an enabled service's port is stopped. Without that, a leftover
# process keeps the port, the new one exits with "Address already in use"
# buried in its own log, and everything downstream then talks to the stale
# process — which, if it has wedged, accepts connections and answers nothing,
# so callers hang until their own timeout instead of failing fast. Pass
# --no-reclaim to leave existing processes alone.
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$ROOT_DIR/logs"

# name | relative dir | command | port(s)
# Every service dir has its own top-level run script — dev.sh just calls it.
# Run a single service by hand the exact same way: cd <dir> && ./<script>.
#
# The port column is what gets reclaimed before startup. Comma-separate if a
# service listens on more than one; leave it empty for services that don't
# listen at all (agent-server is an outbound worker). Keep it in step with the
# port map in RUNBOOK.md.
SERVICES=(
  # "agent        |algojob-agent-server                                       |./run-agent.sh|"
  # "livekit      |livekit-local                                              |./run-livekit.sh|7880,7881"
  # "proctoring   |interview-proctoring                                       |./run.sh|8080"
  "algojobsvc   |interview_manager                                          |./run.sh|8000"
  "apex         |apex-assessment                                            |./run.sh|8001"
  "personalized |debug-assessment                                           |./run.sh|8070"
  "aptitude     |aptitude-assessment                                        |./run.sh|8090"
  "nest         |algojob_nest                                               |./run.sh|5001"
  "frontend     |algojobs_frontend                                          |./run.sh|3000"
)

COLORS=(31 32 33 34 35 36 91 92 93 94)
INFRA_CONTAINERS=(algojob-infra-redis algojob-infra-elasticmq algojob-infra-minio)

# Never reclaimed, even if one is mistakenly added to SERVICES above: infra runs
# in Docker and is deliberately left up between runs (it is cheap, and the
# containers are slow to restart). redis · elasticmq (+UI) · minio (+console).
INFRA_PORTS=(6379 9324 9325 9000 9001)

# Count of ports this run actually had to clear; reported at the end of the
# preflight so a clean start is distinguishable from a busy one.
RECLAIMED=0

do_list=false
do_down=false
no_infra=false
no_reclaim=false
quiet=false
service_filter=()
for arg in "$@"; do
  case "$arg" in
    --list) do_list=true ;;
    --down) do_down=true ;;
    --no-infra) no_infra=true ;;
    --no-reclaim) no_reclaim=true ;;
    --quiet|-q) quiet=true ;;
    --*)
      echo "Unknown flag: $arg (expected --list, --down, --no-infra, --no-reclaim, or --quiet)" >&2
      exit 1
      ;;
    *)
      service_filter+=("$arg")
      ;;
  esac
done

in_filter() {
  local name="$1"
  [ ${#service_filter[@]} -eq 0 ] && return 0
  local f
  for f in "${service_filter[@]}"; do
    [ "$f" = "$name" ] && return 0
  done
  return 1
}

if $do_list; then
  echo "Enabled services (edit the SERVICES array in dev.sh to change):"
  for entry in "${SERVICES[@]}"; do
    name="$(cut -d'|' -f1 <<<"$entry" | xargs)"
    ports="$(cut -d'|' -f4 <<<"$entry" | xargs)"
    printf "  - %-13s %s\n" "$name" "${ports:+port ${ports}}"
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

  echo "Starting shared infra (redis, elasticmq, minio)..."
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

# ---- port preflight --------------------------------------------------------

# PIDs listening on $1, minus this script and anything owned by Docker.
#
# Docker is excluded rather than killed because when the stack is run the other
# way (./start.sh) the ports belong to com.docker.backend, and killing that
# takes down the whole Docker VM rather than one service.
listeners_on() {
  local port="$1" pid comm
  command -v lsof >/dev/null 2>&1 || return 0
  lsof -nP -iTCP:"$port" -sTCP:LISTEN -t 2>/dev/null | sort -u | while IFS= read -r pid; do
    [ -z "$pid" ] && continue
    [ "$pid" = "$$" ] && continue
    comm="$(ps -o comm= -p "$pid" 2>/dev/null)"
    case "$comm" in
      *com.docker*|*Docker*|*docker*) continue ;;
    esac
    printf '%s\n' "$pid"
  done
}

# Free one port so the service about to start can bind it.
reclaim_port() {
  local name="$1" port="$2" reserved pids pid waited

  for reserved in "${INFRA_PORTS[@]}"; do
    if [ "$port" = "$reserved" ]; then
      echo "  $name: refusing to reclaim $port — that is an infra port, left alone by design" >&2
      return 0
    fi
  done

  pids="$(listeners_on "$port")"
  [ -z "$pids" ] && return 0

  echo "  $name: port $port is in use by PID(s) $(echo $pids) — stopping them"
  RECLAIMED=$((RECLAIMED + 1))
  # shellcheck disable=SC2086 — deliberate word splitting; one PID per line.
  kill $pids 2>/dev/null

  # SIGTERM first, but do not trust it. The case this preflight exists for is a
  # process that has stopped responding, and those ignore it.
  waited=0
  while [ "$waited" -lt 20 ]; do
    sleep 0.25
    pids="$(listeners_on "$port")"
    [ -z "$pids" ] && return 0
    waited=$((waited + 1))
  done

  echo "  $name: port $port still held after SIGTERM — sending SIGKILL"
  # shellcheck disable=SC2086
  kill -9 $pids 2>/dev/null
  sleep 0.5

  pids="$(listeners_on "$port")"
  if [ -n "$pids" ]; then
    echo "  $name: port $port STILL held by $(echo $pids) — $name will fail to bind." >&2
    echo "         Check it by hand: lsof -nP -iTCP:$port -sTCP:LISTEN" >&2
    return 1
  fi
}

if ! $no_reclaim; then
  echo "Freeing service ports so everything starts fresh..."
  RECLAIMED=0
  for entry in "${SERVICES[@]}"; do
    name="$(cut -d'|' -f1 <<<"$entry" | xargs)"
    dir="$(cut -d'|' -f2 <<<"$entry" | xargs)"
    ports="$(cut -d'|' -f4 <<<"$entry" | xargs)"
    [ -z "$ports" ] && continue
    [ -d "$ROOT_DIR/$dir" ] || continue
    # Split on commas for the services that listen on more than one.
    IFS=',' read -r -a port_list <<<"$ports"
    for port in "${port_list[@]}"; do
      port="$(echo "$port" | xargs)"
      [ -z "$port" ] && continue
      reclaim_port "$name" "$port"
    done
  done
  if [ "$RECLAIMED" -eq 0 ]; then
    echo "  nothing was listening — all ports were already free."
  fi
  echo
fi

mkdir -p "$LOG_DIR"
: > "$LOG_DIR/.gitkeep"

cleanup() {
  # Disarm immediately so kill 0 below (which signals this process too)
  # can't re-enter this handler, and so the later natural EXIT doesn't
  # print a second time.
  trap '' INT TERM EXIT
  echo
  echo "Stopping all services..."
  kill 0 2>/dev/null
}
trap cleanup INT TERM EXIT

# Neither npm nor uv services install themselves — if deps look missing or
# stale, install/sync before starting.
ensure_deps() {
  local dir="$ROOT_DIR/$1"

  if [ -f "$dir/package.json" ]; then
    local marker="$dir/node_modules"
    local need_install=false
    if [ ! -d "$marker" ]; then
      need_install=true
    elif [ "$dir/package.json" -nt "$marker" ]; then
      need_install=true
    elif [ -f "$dir/package-lock.json" ] && [ "$dir/package-lock.json" -nt "$marker" ]; then
      need_install=true
    fi

    if $need_install; then
      echo "Installing npm dependencies in $1..."
      (cd "$dir" && npm i) || { echo "npm i failed in $1" >&2; exit 1; }
    fi
  fi

  if [ -f "$dir/pyproject.toml" ]; then
    local venv="$dir/.venv"
    local need_sync=false
    if [ ! -d "$venv" ]; then
      need_sync=true
    elif [ "$dir/pyproject.toml" -nt "$venv" ]; then
      need_sync=true
    elif [ -f "$dir/uv.lock" ] && [ "$dir/uv.lock" -nt "$venv" ]; then
      need_sync=true
    fi

    if $need_sync; then
      echo "Creating/syncing uv environment in $1..."
      (cd "$dir" && uv sync) || { echo "uv sync failed in $1" >&2; exit 1; }
    fi
  fi
}

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

  ensure_deps "$dir"

  if ! in_filter "$name"; then
    echo "Starting $name in background, not streaming (not in filter: ${service_filter[*]})"
    (
      trap - INT TERM EXIT
      cd "$ROOT_DIR/$dir" || exit 1
      eval "$cmd"
    ) >>"$LOG_DIR/$name.log" 2>&1 &
    sleep 1.5
    continue
  fi

  if $quiet; then
    echo "Starting $name  ($dir  ->  $cmd)  [quiet: logging to $LOG_DIR/$name.log only]"
    (
      trap - INT TERM EXIT
      cd "$ROOT_DIR/$dir" || exit 1
      eval "$cmd"
    ) 2>&1 \
      | awk -v prefix="[$name] " '{ print prefix $0; fflush() }' \
      >>"$LOG_DIR/$name.log" &
  else
    echo "Starting $name  ($dir  ->  $cmd)"
    (
      trap - INT TERM EXIT
      cd "$ROOT_DIR/$dir" || exit 1
      eval "$cmd"
    ) 2>&1 \
      | awk -v prefix="[$name] " -v color="$color" \
          '{ printf "\033[%sm%s%s\033[0m\n", color, prefix, $0; fflush() }' \
      | tee -a "$LOG_DIR/$name.log" &
  fi

  sleep 1.5
done

echo
echo "All enabled services launched. Logs are also written to $LOG_DIR/<service>.log"
if $quiet || [ ${#service_filter[@]} -gt 0 ]; then
  echo "Not streaming everything to this terminal — tail what you need, e.g.:"
  echo "  tail -f $LOG_DIR/<service>.log"
fi
echo "Press Ctrl-C to stop everything (infra is left running — use ./dev.sh --down to stop it)."
echo

wait
