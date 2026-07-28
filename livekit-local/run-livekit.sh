#!/bin/sh
# Runs livekit-server natively on the host (not in Docker).
#
# WHY NATIVE
# LiveKit advertises a single IP as its ICE candidate, and under bridge
# networking no value satisfies both consumers at once:
#   * the container IP (e.g. 172.24.0.7) is unreachable from the browser, so
#     the browser->LiveKit (publisher) connection never establishes — the
#     candidate's microphone audio never arrives and the interview records an
#     empty transcript (user_turn_count=0) with no error anywhere
#   * 127.0.0.1 fixes the browser but means "itself" to the agent container,
#     which then fails with "Publisher/Subscriber pc state failed"
# Bound to the host, LiveKit advertises ONE LAN address that the browser and
# the containers can both reach.
#
# --node-ip is passed explicitly rather than letting LiveKit auto-pick an
# interface, so the advertised address is deterministic. Override with
# LIVEKIT_NODE_IP=<ip> for a different interface or a remote-client setup.
#
# Prereqs: `brew install livekit`, and `docker compose up -d` at the repo root
# (LiveKit needs the Redis that stack publishes on localhost:6379).

set -eu
cd "$(dirname "$0")"

if ! command -v livekit-server >/dev/null 2>&1; then
  echo "livekit-server not found. Install it with:  brew install livekit" >&2
  exit 1
fi

# Detect the LAN IP: macOS first, then Linux.
detect_ip() {
  ipconfig getifaddr en0 2>/dev/null && return 0
  ipconfig getifaddr en1 2>/dev/null && return 0
  hostname -I 2>/dev/null | awk '{print $1}' | grep . && return 0
  return 1
}

NODE_IP="${LIVEKIT_NODE_IP:-$(detect_ip || echo '')}"

if [ -z "$NODE_IP" ]; then
  echo "Could not detect a LAN IP; letting LiveKit choose. If the browser" >&2
  echo "cannot publish audio, set LIVEKIT_NODE_IP=<your-lan-ip> and retry." >&2
  exec livekit-server --config livekit.yaml
fi

echo "[run-livekit] advertising --node-ip $NODE_IP"
echo "[run-livekit] containers should reach this host at LIVEKIT_HOST (see repo-root .env)"
exec livekit-server --config livekit.yaml --node-ip "$NODE_IP"
