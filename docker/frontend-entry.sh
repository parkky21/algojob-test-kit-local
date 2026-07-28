#!/bin/sh
# Rewrites the __TOKEN__ placeholders baked into the Next.js build at container
# start, then execs the standalone server.
#
# This is the same trick as algojobs_frontend/startup.sh, with two changes:
#
#  1. Paths. startup.sh hardcodes /app/.next/{static,server}; in this image the
#     frontend lives at /app/frontend.
#  2. Restart correctness. startup.sh does an in-place `sed -i`, which is
#     one-shot: after the first boot the tokens are gone, so restarting with
#     different URLs silently keeps the original values. Here the pristine
#     .orig trees (snapshotted at build time) are restored first, so each start
#     genuinely re-applies the current env.
#
# Why placeholders at all: NEXT_PUBLIC_* are inlined by webpack at build time
# and cannot be changed by runtime env, but these values are resolved by the
# *browser* — so on a deploy they must be the server's public hostname, which
# isn't known at build time. Rewriting at boot keeps one image portable.
set -eu

FRONTEND_DIR=/app/frontend
STATIC_DIR="$FRONTEND_DIR/.next/static"
SERVER_DIR="$FRONTEND_DIR/.next/server"

API_BASE_URL="${API_BASE_URL:-http://localhost:5001}"
LIVEKIT_URL="${LIVEKIT_URL:-ws://localhost:7880}"
LIVEKIT_DEBUG="${LIVEKIT_DEBUG:-false}"

echo "[frontend-entry] API_BASE_URL=$API_BASE_URL"
echo "[frontend-entry] LIVEKIT_URL=$LIVEKIT_URL"
echo "[frontend-entry] LIVEKIT_DEBUG=$LIVEKIT_DEBUG"

# Restore pristine copies so re-running with new values actually takes effect.
for d in static server; do
  if [ -d "$FRONTEND_DIR/.next/$d.orig" ]; then
    rm -rf "$FRONTEND_DIR/.next/$d"
    cp -a "$FRONTEND_DIR/.next/$d.orig" "$FRONTEND_DIR/.next/$d"
  fi
done

# '|' is the sed delimiter, so a URL containing '|' would break this — URLs
# don't contain it in practice.
for dir in "$STATIC_DIR" "$SERVER_DIR"; do
  [ -d "$dir" ] || continue
  find "$dir" -type f -name '*.js' -exec sed -i \
    -e "s|__API_BASE_URL__|${API_BASE_URL}|g" \
    -e "s|__LIVEKIT_URL__|${LIVEKIT_URL}|g" \
    -e "s|__LIVEKIT_DEBUG__|${LIVEKIT_DEBUG}|g" \
    {} +
done

echo "[frontend-entry] placeholders injected; starting Next.js server"

# server.js does process.chdir(__dirname), so it must be invoked from the
# standalone root.
cd "$FRONTEND_DIR"
exec /usr/local/bin/node server.js
