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
interview_manager/.env
algojob_nest/.env
algojobs_frontend/.env
apex-assessment/.env
debug-assessment/.env
interview-proctoring/.env
```

Optional: run `./configure.sh` instead of `./clone.sh` — it interactively asks, repo by
repo, whether to clone it, then service by service, whether `./start.sh` should launch
it, then offers to run `./clone.sh` / `./start.sh --build` / `./start.sh` for you with
those choices. It's fully ephemeral: nothing is written to disk, so it asks again every
time you run it. See [Selective services](#selective-services) below.

## Build + run (full stack)

```bash
./start.sh --build         # build the selected app services (default: all)
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
enables `nest` too (`configure.sh`/`start.sh` do this automatically for both cloning and
starting; disabling `nest` while leaving `frontend` on isn't a valid combination —
Compose refuses even to resolve the config, let alone start).

**`nest` and `frontend` build independently** — each has its own `Dockerfile` in its own
repo (`algojob_nest/Dockerfile`, `algojobs_frontend/Dockerfile`), separate from the
shared image the other four use. That means:
- `docker compose build nest frontend` only needs those two repos cloned — the other
  four (`algojobs-service`, `apex`, `personalized`, `agent-server`) aren't touched.
- Editing frontend code and running `docker compose build frontend nest` only rebuilds
  frontend's layers (nest is cache-fast once built once) — it never rebuilds the shared
  image or requires the other four repos to exist.
- The other four still share **one** image (`algojob-stack:latest`) built from the root
  `Dockerfile`, which unconditionally needs all four of *those* repos present —
  declining any one of them breaks `docker compose build` for all four, even the ones
  you didn't decline.

`clone.sh` mirrors this via `CLONE_AGENT_SERVER`, `CLONE_ALGOJOBS_SERVICE`,
`CLONE_NEST`, `CLONE_FRONTEND`, `CLONE_APEX`, `CLONE_PERSONALIZED`, `CLONE_PROCTORING`
(`clone.sh --list` marks which repos are required for what; `configure.sh` warns inline
per-repo). Only `interview-proctoring` (native-only, excluded from the Docker build
entirely) is unconditionally safe to skip.

## Build + run a single service only

```bash
docker compose build <service> [<service> ...]
docker compose up -d <service> [<service> ...]
```

`<service>`: `frontend` `nest` `apex` `personalized` `agent-server` `algojobs-service` `elasticmq` `redis` `keycloak` `minio`

Only rebuilds/recreates the named container(s) — the rest of the stack keeps running.
Naming a service explicitly bypasses profile filtering, so this always works regardless
of `START_*` env vars — **except** `frontend` depends on `nest` structurally
(`depends_on` in `docker-compose.yml`), so `docker compose build frontend` /
`up -d frontend` *alone* fails with `no such service: nest`; you always need
`docker compose build frontend nest` / `up -d frontend nest` together (Compose
validates the dependency graph the same way for `build` as it does for `up`).

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
curl localhost:8000/health          # interview_manager
curl localhost:8001/v1/health       # apex
curl localhost:8070/health          # personalized
curl localhost:5001/health          # nest
```
