# syntax=docker/dockerfile:1
#
# Single-image build of the whole AlgoJob stack. All 8 processes run in one
# container under supervisord. Intended for Linux deploy with
# `network_mode: host` (see docker-compose.yml), which is what lets LiveKit's
# WebRTC media path perform natively and lets every service keep its existing
# localhost:PORT wiring unchanged.
#
# Layout in the final image — one directory per service, because every
# service's .env loading is CWD-relative and supervisord gives each program
# its own `directory=`:
#
#   /app/agent_server        /app/algojobs_service    /app/apex
#   /app/personalized        /app/nest                /app/frontend
#   /app/livekit
#
# IMPORTANT: never create /app/.env. Python's bare load_dotenv() walks *upward*
# from the CWD, so a file there would be picked up by every Python service and
# silently override their individual configs.
#
# ARCHITECTURE: builds on both arm64 and x86_64. workload-proctoring — the one
# service that forced x86_64, via mediapipe's missing ARM64 wheel — is excluded
# (see the note in the py-build stage). Re-adding it re-imposes x86_64-only.

######################################################################
# Stage 1 — Node build (nest + frontend)
# Both are built with Node 22. nest's Dockerfile pins node:22 and the
# frontend's pins node:20; Next 15.5 + React 19 run fine on 22, so the
# newer of the two is used for a single toolchain.
######################################################################
FROM node:22-bookworm-slim AS node-build
WORKDIR /build

# ---- nest: install (incl. devDeps for the build), compile, then prune ----
COPY algojob_nest/package.json algojob_nest/package-lock.json algojob_nest/
RUN cd algojob_nest && npm ci
COPY algojob_nest/tsconfig*.json algojob_nest/nest-cli.json algojob_nest/
COPY algojob_nest/src algojob_nest/src
RUN cd algojob_nest && npm run build && npm prune --omit=dev

# ---- frontend: build with placeholder tokens ----
# NEXT_PUBLIC_* are inlined by webpack at build time and cannot be changed by
# runtime env. They are baked as __TOKENS__ here and rewritten at container
# start by docker/frontend-entry.sh, so one image can be deployed against any
# public hostname. These values are browser-resolved, so on a real deploy they
# must be the server's public URL — not localhost.
COPY algojobs_frontend/package.json algojobs_frontend/package-lock.json algojobs_frontend/
RUN cd algojobs_frontend && npm ci
COPY algojobs_frontend/ algojobs_frontend/
ENV NEXT_PUBLIC_API_BASE=__API_BASE_URL__ \
    NEXT_PUBLIC_LIVEKIT_URL=__LIVEKIT_URL__ \
    NEXT_PUBLIC_LIVEKIT_DEBUG=__LIVEKIT_DEBUG__
RUN cd algojobs_frontend && npm run build


######################################################################
# Stage 2 — Python build (5 uv projects, all Python 3.12)
# Dependencies are synced before sources are copied so that a source-only
# change doesn't re-resolve/re-download the (large) dependency sets.
######################################################################
FROM python:3.12-slim-bookworm AS py-build
COPY --from=ghcr.io/astral-sh/uv:0.9.22 /uv /usr/local/bin/uv
ENV UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_LINK_MODE=copy
RUN apt-get update && apt-get install -y --no-install-recommends \
      gcc g++ python3-dev git curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# WORKDIR must be the SAME path these services occupy in the final image.
# Python venvs are not relocatable: `uv sync` bakes an absolute shebang into
# every console script (.venv/bin/uvicorn -> #!<abs>/.venv/bin/python), so
# building under /build and copying to /app yields `exec: ENOENT` at runtime.
WORKDIR /app

# ---- dependency layers ----
COPY algojob_agent_server/pyproject.toml algojob_agent_server/uv.lock agent_server/
RUN cd agent_server && uv sync --frozen --no-install-project --no-dev

COPY algojobs_service/pyproject.toml algojobs_service/uv.lock algojobs_service/
RUN cd algojobs_service && uv sync --frozen --no-install-project --no-dev

COPY apex_mircoservice/pyproject.toml apex_mircoservice/uv.lock apex/
RUN cd apex && uv sync --frozen --no-install-project --no-dev

COPY workload-personalized-learning/pyproject.toml \
     workload-personalized-learning/uv.lock personalized/
RUN cd personalized && uv sync --frozen --no-install-project --no-dev

# NOTE: workload-proctoring is intentionally NOT included. It depends on
# mediapipe, which publishes no Linux ARM64 wheel, and was the only thing
# forcing this image to linux/amd64. To add it back, restore the dependency +
# source layers and the runtime COPY for `proctoring/`, re-add its supervisord
# program, and pin `platform: linux/amd64` in docker-compose.yml again — it can
# then only be deployed to an x86_64 host.

# ---- source layers ----
COPY algojob_agent_server/ agent_server/
RUN cd agent_server && uv sync --frozen --no-dev

COPY algojobs_service/ algojobs_service/
RUN cd algojobs_service && uv sync --frozen --no-dev

COPY apex_mircoservice/ apex/
RUN cd apex && uv sync --frozen --no-dev

COPY workload-personalized-learning/ personalized/
RUN cd personalized && uv sync --frozen --no-dev

# Pre-download the agent's Silero VAD + turn-detector models. main.py loads VAD
# eagerly during prewarm, so without this the first job pays a network fetch —
# and fails outright in an egress-restricted deploy.
# XDG_CACHE_HOME is pinned under /app so the cache is actually captured by the
# COPY into the final stage; left at its default it lands in /root/.cache and is
# silently dropped.
ENV XDG_CACHE_HOME=/app/agent_server/.cache
RUN cd agent_server && uv run --module livekit.agents download-files

# One shared copy of the AWS RDS/DocumentDB CA bundle (several services each
# fetch their own identical copy in their standalone Dockerfiles).
RUN curl -sS https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem \
      -o /app/global-bundle.pem


######################################################################
# Stage 3 — Runtime
######################################################################
FROM python:3.12-slim-bookworm

# libgl1/libglib2.0-0 (the OpenCV/MediaPipe runtime deps) are omitted along
# with workload-proctoring. Compilers are deliberately not carried over.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      procps \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir supervisor==4.3.0

# Node runtime only — nest runs `node dist/main`, the frontend runs
# `node server.js`; neither needs npm at runtime.
COPY --from=node:22-bookworm-slim /usr/local/bin/node /usr/local/bin/node

# LiveKit server binary (the install script picks the right arch).
RUN curl -sSL https://get.livekit.io | bash

WORKDIR /app

# ---- Python services (project dir + its .venv) ----
COPY --from=py-build /app/agent_server      /app/agent_server
COPY --from=py-build /app/algojobs_service  /app/algojobs_service
COPY --from=py-build /app/apex              /app/apex
COPY --from=py-build /app/personalized      /app/personalized
COPY --from=py-build /app/global-bundle.pem /app/global-bundle.pem

# ---- nest: compiled output + production deps ----
COPY --from=node-build /build/algojob_nest/dist         /app/nest/dist
COPY --from=node-build /build/algojob_nest/node_modules /app/nest/node_modules
COPY --from=node-build /build/algojob_nest/package.json /app/nest/package.json

# ---- frontend: standalone server + assets ----
# `output: 'standalone'` deliberately excludes .next/static and public/, so both
# are copied in alongside the traced server bundle.
COPY --from=node-build /build/algojobs_frontend/.next/standalone /app/frontend
COPY --from=node-build /build/algojobs_frontend/.next/static     /app/frontend/.next/static
COPY --from=node-build /build/algojobs_frontend/public           /app/frontend/public

# Pristine snapshots of the two trees that contain the __TOKEN__ placeholders.
# frontend-entry.sh restores from these before each rewrite, so a restart with
# different public URLs actually takes effect — an in-place `sed -i` is
# one-shot and would otherwise leave the first boot's values baked in.
RUN cp -a /app/frontend/.next/static /app/frontend/.next/static.orig \
 && cp -a /app/frontend/.next/server /app/frontend/.next/server.orig

# ---- LiveKit config ----
COPY livekit-local/livekit.yaml /app/livekit/livekit.yaml

# ---- process supervision ----
COPY docker/supervisord.conf   /etc/supervisor/supervisord.conf
COPY docker/frontend-entry.sh  /usr/local/bin/frontend-entry.sh
RUN chmod +x /usr/local/bin/frontend-entry.sh

ENV TLS_CA_FILE=/app/global-bundle.pem \
    DOCDB_CA_BUNDLE=/app/global-bundle.pem \
    XDG_CACHE_HOME=/app/agent_server/.cache \
    PYTHONUNBUFFERED=1

# Browser-facing defaults. Override these at deploy time with the server's
# public URL — they are baked into JS served to the browser, so `localhost`
# only works when the browser is on the same machine as the container.
ENV PUBLIC_API_BASE_URL=http://localhost:5001 \
    PUBLIC_LIVEKIT_URL=ws://localhost:7880 \
    PUBLIC_LIVEKIT_DEBUG=false

# nest's NODE_ENV. Production is correct for deploy, but nest's validateConfig
# then requires real (non-placeholder) auth secrets in algojob_nest/.env.
ENV NEST_NODE_ENV=production

# frontend 3000 · nest 5001 · livekit 7880/7881/7882(udp) · algojobs_service 8000
# apex 8001 · personalized 8070   (proctoring/8080 excluded — see note above)
EXPOSE 3000 5001 7880 7881 7882/udp 8000 8001 8070

CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
