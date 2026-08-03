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
#   ./dev.sh --down           stop the shared infra stack and exit
#   ./dev.sh --list           print which services are enabled/skipped and exit
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$ROOT_DIR/logs"

# name | relative dir | command
# Every service dir has its own top-level run script — dev.sh just calls it.
# Run a single service by hand the exact same way: cd <dir> && ./<script>.
SERVICES=(
  # "livekit      |livekit-local                                              |./run-livekit.sh"
  # "proctoring   |interview-proctoring                                       |./run.sh"
  # "algojobsvc   |interview_manager                                          |./run.sh"
  # "apex         |apex-assessment                                            |./run.sh"
  # "personalized |debug-assessment                                           |./run.sh"
  "nest         |algojob_nest                                               |./run.sh"
  "frontend     |algojobs_frontend                                          |./run.sh"
  # "agent        |algojob-agent-server                                       |./run-agent.sh"
)

COLORS=(31 32 33 34 35 36 91 92 93 94)
INFRA_CONTAINERS=(algojob-infra-redis algojob-infra-elasticmq algojob-infra-minio)

do_list=false
do_down=false
no_infra=false
quiet=false
service_filter=()
for arg in "$@"; do
  case "$arg" in
    --list) do_list=true ;;
    --down) do_down=true ;;
    --no-infra) no_infra=true ;;
    --quiet|-q) quiet=true ;;
    --*)
      echo "Unknown flag: $arg (expected --list, --down, --no-infra, or --quiet)" >&2
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
