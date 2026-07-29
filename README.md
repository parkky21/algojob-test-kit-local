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

Optional: run `./configure.sh` instead of `./clone.sh` — it interactively asks, repo by
repo, whether to clone it, then service by service, whether `./start.sh` should launch
it, then offers to run `./clone.sh` / `./start.sh --build` / `./start.sh` for you with
those choices. It's fully ephemeral: nothing is written to disk, so it asks again every
time you run it. See [Selective services](#selective-services) below.

## Build + run (full stack)

```bash
./start.sh --build         # build the shared image (always builds all 6 app services —
                            # see "Selective services" below for why)
./start.sh                 # containers + native LiveKit (Ctrl-C stops LiveKit only)
./start.sh --no-livekit    # containers only
./start.sh --down          # stop containers
```

## Selective services

The 6 app services in `docker-compose.yml` (`algojobs-service`, `apex`, `personalized`,
`nest`, `frontend`, `agent-server`) are each gated behind a Compose `profiles:` entry
matching their name — same mechanism already used for `livekit`. Bare `docker compose
up -d` / `docker compose build` therefore only touch infra (`redis`/`keycloak`/
`elasticmq`/`minio`) by default; nothing app-level starts or builds without a profile.

`./start.sh` and `./start.sh --build` pass the right `--profile` flags for you, driven
by env vars (`START_APEX`, `START_NEST`, `START_FRONTEND`, `START_ALGOJOBS_SERVICE`,
`START_PERSONALIZED`, `START_AGENT_SERVER` — each defaults to `1`/on if unset). Use
`./configure.sh` for an interactive picker, or export them yourself for a one-off:
`START_APEX=0 START_PERSONALIZED=0 ./start.sh`. Nothing persists to disk — every
invocation without an explicit override starts everything.

Note: `frontend` depends on `nest` at the Compose level, so enabling `frontend` always
enables `nest` too (`configure.sh`/`start.sh` do this automatically; disabling `nest`
while leaving `frontend` on isn't a valid combination — Compose would refuse to start).

`clone.sh` works the same way for which repos to clone, via `CLONE_AGENT_SERVER`,
`CLONE_ALGOJOBS_SERVICE`, `CLONE_NEST`, `CLONE_FRONTEND`, `CLONE_APEX`,
`CLONE_PERSONALIZED`, `CLONE_PROCTORING`. **Six of the seven repos are built into the one
shared Docker image**, so declining to clone any of those breaks `docker compose build`
outright, even for repos you didn't decline (`clone.sh --list` marks which ones are
required; `configure.sh` warns inline if you decline one). Only
`algojob-proctoring-mise` (native-only, already excluded from the Docker build for arch
reasons) is genuinely safe to skip.

## Build + run a single service only

```bash
docker compose build <service>
docker compose up -d <service>
```

`<service>`: `frontend` `nest` `apex` `personalized` `agent-server` `algojobs-service` `elasticmq` `redis` `keycloak` `minio`

Only rebuilds/recreates that one container — the rest of the stack keeps running.
Naming a service explicitly here bypasses profile filtering, so this always works
regardless of `START_*` env vars (`frontend` still needs `nest` running, though —
Compose won't auto-start a profile-gated dependency just because you named the
dependent service).

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
