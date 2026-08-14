# AlgoJob dev stack

Orchestration only — service code lives in 8 repos, pulled in by `clone.sh` (every repo clones from `main`). Full docs: [RUNBOOK.md](RUNBOOK.md).

## Setup

```bash
./clone.sh
cp .env.example .env
```

Also add `.env` in each service dir (values from the team secret store):

```
algojob-agent-server/.env
interview_manager/.env
algojob_nest/.env
algojobs_frontend/.env
apex-assessment/.env
debug-assessment/.env
interview-proctoring/.env
aptitude-assessment/.env
```

```bash
./configure.sh   # optional interactive picker: clone + services + start
```

## Run natively (macOS dev)

```bash
./dev.sh                  # infra (Docker) + all enabled services, one terminal
./dev.sh nest frontend    # only stream these services (others still run + log)
./dev.sh --quiet          # don't stream logs, just write to logs/<service>.log
./dev.sh --no-infra       # skip the infra preflight (already running)
./dev.sh --down           # stop the shared infra stack
./dev.sh --list           # show which services are enabled
```

## Run in Docker (full stack)

```bash
./start.sh --build         # build the selected app services (default: all)
./start.sh                 # containers + native LiveKit (Ctrl-C stops LiveKit only)
./start.sh --no-livekit    # containers only
./start.sh --down          # stop containers
```

## Selective services

6 app services: `algojobs-service` `apex` `personalized` `nest` `frontend` `agent-server`
(`frontend` always pulls in `nest`).

```bash
./start.sh --only=nest,frontend
START_APEX=0 START_PERSONALIZED=0 ./start.sh
```

## Single service

```bash
docker compose build <service>
docker compose up -d <service>
```

`<service>`: `frontend` `nest` `apex` `personalized` `agent-server` `algojobs-service` `elasticmq` `redis` `minio`

## LiveKit: Cloud vs native

Toggle in the repo-root `.env` (`LiveKit source` block):

```
# Cloud
LIVEKIT_URL=wss://<project>.livekit.cloud
PUBLIC_LIVEKIT_URL=wss://<project>.livekit.cloud

# Native
LIVEKIT_URL=ws://host.docker.internal:7880
PUBLIC_LIVEKIT_URL=ws://localhost:7880
```

```bash
./start.sh   # auto-detects Cloud (wss://) vs native
docker compose up -d --force-recreate agent-server algojobs-service frontend   # after switching
```

## Verify

```bash
docker compose ps
docker compose logs agent-server | grep -o '"url": "[^"]*"' | tail -1   # confirm which LiveKit it's using
curl localhost:3000/api/config
curl localhost:8000/health          # interview_manager
curl localhost:8001/v1/health       # apex
curl localhost:8070/health          # personalized
curl localhost:5001/health          # nest
```
