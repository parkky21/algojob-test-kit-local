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

Optional: run `./configure.sh` to interactively pick which app services you actually
want running (e.g. just `frontend` + `nest` while working on the backend). It writes
`services.conf`, which `clone.sh` and `start.sh` both read. Skip this and everything
clones/starts by default — see [Selective services](#selective-services) below.

## Build + run (full stack)

```bash
./start.sh --build         # build the shared image (see docker-compose.yml comment: this
                            # always builds all 6 app services, regardless of services.conf)
./start.sh                 # containers (per services.conf) + native LiveKit (Ctrl-C stops LiveKit only)
./start.sh --no-livekit    # containers only
./start.sh --down          # stop containers
```

## Selective services

The 6 app services in `docker-compose.yml` (`algojobs-service`, `apex`, `personalized`,
`nest`, `frontend`, `agent-server`) are each gated behind a Compose `profiles:` entry
matching their name — same mechanism already used for `livekit`. Bare `docker compose
up -d` / `docker compose build` therefore only touch infra (`redis`/`keycloak`/
`elasticmq`/`minio`) by default; nothing app-level starts or builds without a profile.

`./start.sh` and `./start.sh --build` read `services.conf` and pass the right
`--profile` flags for you — that's the supported way to run a subset. Generate/edit it
with `./configure.sh`, or copy `services.conf.example` (defaults to everything on) and
edit by hand. It's gitignored — a per-machine preference, like `.env`.

Note: `frontend` depends on `nest` at the Compose level, so enabling `frontend` always
enables `nest` too (`configure.sh`/`start.sh` do this automatically; disabling `nest`
while leaving `frontend` on isn't a valid combination — Compose would refuse to start).

All 6 repos are still cloned and built into the one shared image regardless of this
selection — see the note in `services.conf.example`. Only `algojob-proctoring-mise`
(native-only, already excluded from the Docker build for arch reasons) is actually
skippable at clone time, via `CLONE_PROCTORING` in the same file.

## Build + run a single service only

```bash
docker compose build <service>
docker compose up -d <service>
```

`<service>`: `frontend` `nest` `apex` `personalized` `agent-server` `algojobs-service` `elasticmq` `redis` `keycloak` `minio`

Only rebuilds/recreates that one container — the rest of the stack keeps running.
Naming a service explicitly here bypasses profile filtering, so this works regardless
of what's in `services.conf`.

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
