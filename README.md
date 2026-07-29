# AlgoJob dev stack

Orchestration only — service code lives in 7 repos, pulled in by `clone.sh`. Full docs: [RUNBOOK.md](RUNBOOK.md).

## Setup

```bash
./clone.sh
cp .env.example .env
```

Also add `.env` in each service dir (get values from the team secret store):

```
algojob-agent-server/.env
algojobs_service/.env
algojob_nest/.env
algojobs_frontend/.env
algoapex-microservice/.env
Algojob-debug-mise/.env
algojob-proctoring-mise/.env
```

## Build + run (full stack)

```bash
docker compose build
./start.sh                # containers + native LiveKit (Ctrl-C stops LiveKit only)
./start.sh --no-livekit   # containers only
./start.sh --down         # stop containers
```

## Build + run a single service only

```bash
docker compose build <service>
docker compose up -d <service>
```

`<service>`: `frontend` `nest` `apex` `personalized` `agent-server` `algojobs-service` `elasticmq` `redis` `keycloak`

Only rebuilds/recreates that one container — the rest of the stack keeps running.

## LiveKit: Cloud vs native

Toggle in the repo-root `.env` (`LiveKit source` block — swap which lines are commented):

```
# Cloud
LIVEKIT_URL=wss://<project>.livekit.cloud
PUBLIC_LIVEKIT_URL=wss://<project>.livekit.cloud

# Native
LIVEKIT_URL=ws://host.docker.internal:7880
PUBLIC_LIVEKIT_URL=ws://localhost:7880
```

```bash
./start.sh                # Cloud: skips native LiveKit automatically (wss:// URL detected)
./start.sh                # Native: also starts livekit-server on the host
docker compose up -d --force-recreate agent-server algojobs-service frontend   # after switching, pick up the change
```

## Verify

```bash
docker compose ps
docker compose logs agent-server | grep -o '"url": "[^"]*"' | tail -1   # confirm which LiveKit it's using
curl localhost:3000/api/config
curl localhost:8000/health          # algojobs_service
curl localhost:8001/v1/health       # apex
curl localhost:8070/health          # personalized
curl localhost:5001/health          # nest
```
