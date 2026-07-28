# AlgoJob dev stack

This repo is **orchestration only** — `Dockerfile`, `docker-compose.yml`, `dev.sh`/`start.sh`, and
docs. It does not contain any AlgoJob service code. The six services each live in their own repo
and are pulled in by `./clone.sh`.

Full detail on running everything, deploying, and how each piece fits together is in
[RUNBOOK.md](RUNBOOK.md). This file is just the fastest path to a working stack.

## Why a separate repo

The six service repos carry 130+ active branches and their own CI pipelines — merging them into
one repo would mean migrating every open branch/PR and rewriting every pipeline. This repo exists
instead so the orchestration layer (which previously lived nowhere, versioned by no one) is
reproducible without disturbing any of that.

## Get the code

```bash
./clone.sh              # clones all six service repos, branch `local-run`
./clone.sh main          # or any other branch
./clone.sh --list        # see the folder <-> GitHub-repo mapping
```

Re-running `./clone.sh` later `git fetch`es rather than overwriting — it never touches whatever
branch you currently have checked out in each service folder.

## Get the secrets

**No `.env` file is in this git repo, or any of the six service repos.** Every one of them holds
live credentials (MongoDB Atlas, Neon Postgres, AWS, LiveKit, Razorpay, WhatsApp, Google OAuth,
Cloudinary...) — get them from the team's secret store, not from git history.

You need one `.env` in each of these locations (`.env.example` / `env.example` next to each one
shows the full shape):

```
./.env                                                        (this repo — LiveKit + public URLs)
algojob_agent_server/.env
algojobs_service/.env
algojob_nest/.env
algojobs_frontend/.env
apex_mircoservice/.env
algojob_microservice_python/workload-personalized-learning/.env
algojob_microservice_python/workload-proctoring/.env
```

```bash
cp .env.example .env    # then check LIVEKIT_URL / PUBLIC_API_BASE_URL match your setup
```

## Run it

```bash
./start.sh              # 9 containers + LiveKit (native, or Cloud if configured — see .env)
./start.sh --down       # stop the containers
```

First run builds the image (a few minutes). `RUNBOOK.md` covers health checks, the Keycloak
one-time realm setup, the LiveKit native-vs-Cloud toggle, and the Linux deploy path.

## What's actually in this repo

```
Dockerfile, .dockerignore       — builds all 6 services into one image
docker-compose.yml               — one container per service + redis/keycloak/elasticmq
docker-compose.host.yml          — Linux overlay: host networking for LiveKit
docker/                          — supervisord.conf, frontend-entry.sh (used by the image)
infra/                           — elasticmq.conf (local SQS emulator queue definitions)
livekit-local/                   — livekit.yaml + run-livekit.sh (native LiveKit)
dev.sh                           — all-native local dev (no Docker) for macOS
start.sh                         — docker compose up + native LiveKit, one command
clone.sh                         — bootstraps the six service repos
RUNBOOK.md                       — full documentation
```
