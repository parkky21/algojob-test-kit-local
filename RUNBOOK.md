# Running AlgoJob

Two supported paths:

- **Local development (macOS)** — everything native, one command: `./dev.sh`. See below.
- **Docker (Linux deploy, or local smoke test)** — one container per service from a single shared
  image: `docker compose up -d --build` from the repo root. See [Docker deploy](#docker-deploy).

---

# Running AlgoJob locally

All 7 services run natively (no Docker) for app code — `npm run dev`, `npm run start:dev`,
`uv run main.py`. Only four infra pieces run in Docker: Redis, Keycloak, ElasticMQ (a local
SQS-compatible emulator), and MinIO (a local S3-compatible emulator), because they're
stateful/Java(-ish) and nobody edits their code.

MongoDB (Atlas) and Postgres (Neon) stay cloud-hosted — every service's `.env` already points at
them, unchanged.

## One command

```bash
./dev.sh
```

Starts shared infra (stopping a native Homebrew Redis on 6379 first, if running), waits for it to
report healthy, then launches every enabled service in one terminal with prefixed, color-coded
output — also written to `logs/<service>.log`. Ctrl-C stops all native services; infra is left
running (cheap, and Keycloak is slow to restart). `./dev.sh --down` stops infra.

To skip a service (e.g. you don't need proctoring or personalized-learning today), comment out its
line in the `SERVICES` array at the top of `dev.sh` — nothing else changes. `./dev.sh --list` shows
what's currently enabled.

## Manual — one terminal per service

Every service directory has its own top-level run script — `dev.sh` just calls it. To run one
service by hand, `cd` into its directory and run its script; nothing else to remember. Order only
matters loosely: bring up infra first, then livekit + proctoring before agent-server (it registers
against both on startup).

```bash
# once, before anything else
brew services stop redis          # frees 6379 for the Docker one
cd infra && docker compose up -d  # redis, keycloak, elasticmq, minio
```

### livekit-local — LiveKit server (native)
```bash
cd livekit-local && ./run-livekit.sh
```
- Port: **7880** (WS/HTTP), 7881 (RTC TCP), 7882 (RTC UDP)
- Requires: `infra` up (its Redis, for LiveKit's own control-plane state), `livekit-server` binary
  installed (`brew install livekit`)
- Config: `livekit.yaml` in this directory, used as-is
- No health endpoint — check the script's own log for `starting LiveKit server`

### algojob-agent-server — LiveKit interview agent worker (native)
```bash
cd algojob-agent-server && ./run-agent.sh
```
- No port — outbound worker only (connects to LiveKit, doesn't listen)
- Requires: `livekit-local` and `algojob-proctoring-mise` already running
- `.env` already correct as-is (`LIVEKIT_URL=ws://localhost:7880`,
  `PROCTOR_API_URL=ws://localhost:8080/ws/proctor`) — nothing to add
- Check: log line `registered worker` with `"url": "ws://localhost:7880"`

### algojobs_service — AI HR Service (FastAPI)
```bash
cd algojobs_service && ./run.sh
```
- Port: **8000**
- Requires: `infra` up (redis)
- `.env` already has `REDIS_URL=redis://localhost:6379/0`, `LIVEKIT_URL=ws://localhost:7880`,
  `PROCTOR_API_URL=ws://localhost:8080/ws/proctor` — nothing to add
- Health: `curl localhost:8000/health`

### algoapex-microservice — AlgoApex assessment service (FastAPI + SQS consumers)
```bash
cd algoapex-microservice && ./run.sh
```
- Port: **8001** (from `.env`'s `API_PORT=8001` — `run.sh`/`scripts/run_api.sh` reads it explicitly
  since bash doesn't source `.env` on its own)
- Requires: `infra` up (elasticmq, minio)
- `.env` already has `API_PORT=8001` and the local `SQS_ENDPOINT_URL`/`SQS_*_URL` overrides —
  nothing to add. `RUN_CONSUMERS=true` means this one process also hosts the signup/test-completed
  consumers — no separate worker terminals needed for normal dev.
- To point audio storage (`AUDIO_STORAGE=s3`) at the local MinIO instead of real AWS S3, set in
  `.env`: `S3_ENDPOINT_URL=http://localhost:9000`, `AWS_ACCESS_KEY_ID=minioadmin`,
  `AWS_SECRET_ACCESS_KEY=minioadmin`. Unset `S3_ENDPOINT_URL` (and restore real creds) to go back
  to real S3 — everything else about the code path is unchanged either way.
- Health: `curl localhost:8001/v1/health`
- Optional standalone workers (only if you need them running outside the API process):
  `./scripts/run_worker.sh signup` / `test_completed` / `cron_consumer`

### Algojob-debug-mise — content generation (FastAPI)
```bash
cd Algojob-debug-mise && ./run.sh
```
- Port: **8070**
- Requires: nothing local — only cloud Mongo
- Health: `curl localhost:8070/health`

### algojob-proctoring-mise — AI exam proctoring (FastAPI + YOLO/MediaPipe)
```bash
cd algojob-proctoring-mise && ./run.sh
```
- Port: **8080**
- Requires: nothing local — only cloud Mongo (`.env`'s `MONGODB_URI` was repointed at the shared
  Atlas cluster; the original AWS DocumentDB host is VPC-only and unreachable from outside AWS)
- Health: `curl localhost:8080/health`

### algojob_nest — backend API (NestJS)
```bash
cd algojob_nest && ./run.sh
```
- Port: **5001**
- Requires: `infra` up (redis, keycloak, minio)
- `.env` already has `REDIS_HOST=localhost`/`REDIS_PORT=6379`, `KEYCLOAK_URL=http://localhost:8180`,
  and the local `SQS_ENDPOINT_URL`/`SQS_*_URL` overrides — nothing to add
- To point audio storage at the local MinIO instead of real AWS S3, set in `.env`:
  `S3_ENDPOINT_URL=http://localhost:9000`, `AWS_ACCESS_KEY_ID=minioadmin`,
  `AWS_SECRET_ACCESS_KEY=minioadmin` (`S3_PUBLIC_ENDPOINT_URL` can be omitted natively — it
  defaults to `S3_ENDPOINT_URL`, and everything is already `localhost`)
- Health: `curl localhost:5001/health` — also watch the startup log for the
  `IntegrationConnectivityService` summary (Mongo/Redis/Keycloak/AlgoApex OK/FAIL per integration)
- One-time manual step: create realm `algo-jobs` in the Keycloak admin console
  (`http://localhost:8180`, admin/admin) — until then `keycloak: FAIL` in that summary is expected

### algojobs_frontend — web UI (Next.js)
```bash
cd algojobs_frontend && ./run.sh
```
- Port: **3000**
- Requires: `algojobs_nest` (for `BACKEND_API_URL`) and `livekit-local` (for `NEXT_PUBLIC_LIVEKIT_URL`)
  for full functionality, but starts fine without them
- `.env` already has `NEXT_PUBLIC_LIVEKIT_URL=ws://localhost:7880` — nothing to add
- Check: `curl localhost:3000/api/config` should return `"livekitUrl":"ws://localhost:7880"`

## Port map

| Service | Port |
|---|---|
| frontend | 3000 |
| nest | 5001 |
| redis (infra) | 6379 |
| livekit (native) | 7880 / 7881 / 7882 |
| algojobs_service | 8000 |
| apex | 8001 |
| Algojob-debug-mise | 8070 |
| algojob-proctoring-mise | 8080 |
| keycloak (infra) | 8180 |
| elasticmq (infra) | 9324 (+9325 UI) |
| minio (infra) | 9000 (+9001 console) |

## Health checks

```bash
curl localhost:8000/health          # algojobs_service
curl localhost:8001/v1/health       # apex
curl localhost:8070/health          # Algojob-debug-mise
curl localhost:8080/health          # algojob-proctoring-mise
curl localhost:5001/health          # nest
curl localhost:3000                 # frontend
curl localhost:3000/api/config      # confirm livekitUrl is ws://localhost:7880, not a cloud host
curl -f localhost:9000/minio/health/live  # minio
```

## Offline S3 (MinIO)

MinIO stands in for AWS S3 so audio uploads work without network access. Console at
`http://localhost:9000/minio/console` (or `:9001` when run standalone) — creds
`minioadmin`/`minioadmin` by default (override via `MINIO_ROOT_USER`/`MINIO_ROOT_PASSWORD` in the
root `.env`). The bucket `algojobterraformstate` is auto-created on startup by the one-shot
`minio-init` container — no manual setup needed. Requires Docker Compose >= 2.20 for `up --wait`
to correctly treat that container's clean exit as success.

nest's own startup logs also run a connectivity prober (`integration-connectivity.service.ts`)
that reports OK/SKIP/FAIL for Mongo, Redis, Keycloak, and AlgoApex on boot — the fastest signal
that wiring is correct.

## Why native for local development

The one real reason is **WebRTC**. Docker containers on macOS run inside a Linux VM (Docker
Desktop), so LiveKit's and agent-server's real-time media takes an extra network hop through the VM
boundary. Running those natively avoids it, which matters for interview quality.

Redis/Keycloak/ElasticMQ have no such problem — they're plain TCP, so Docker is fine there and far
simpler than installing Java locally for Keycloak and ElasticMQ.

Note: an earlier version of this document claimed Docker's DNS resolver broke `mongodb+srv://` SRV
lookups to Atlas. **That was wrong** — a direct test (`docker run python:3.12-slim` + `pymongo`
against the same URI) connects fine from inside a container, and the Dockerised stack now reports
`mongodb: OK`. Mongo connectivity is not a reason to avoid Docker.

---

# Docker deploy

The repo root has a `Dockerfile` + `docker-compose.yml` that build every service into **one shared
image**, then run **one container per service** from it, alongside redis/keycloak/elasticmq.

## One container per service — plus LiveKit natively

`docker-compose.yml` runs **one container per service**, all from a single shared image. The
Dockerfile builds every service into one image under `/app/<svc>`; each container then runs a
different process from it. One build, proper per-service isolation.

**LiveKit is the one exception — it runs natively on the host.** Start everything with:

```bash
./start.sh                # 9 containers + native livekit-server (foreground)
./start.sh --no-livekit   # containers only
./start.sh --down         # stop containers
```

Or run the two halves yourself:

```bash
docker compose build              # builds algojob-stack:latest once
docker compose up -d              # 9 services
cd livekit-local && ./run-livekit.sh   # native, separate terminal

docker compose logs -f nest       # per-service logs
docker compose restart apex       # per-service restart
docker compose ps
```

### Switching LiveKit: Cloud vs local native

Both are supported, and it's **one place to change** — the `LiveKit source` block in the repo-root
`.env`. `docker-compose.yml` passes those values to agent-server, algojobs-service and the frontend,
overriding each service's own `.env`, so the URL and key/secret can't drift out of sync (the key
signs the tokens the URL validates — mismatch them and every join fails).

**Cloud** (currently active) — publicly reachable, so the browser and the containers use the *same*
URL. No native process, no ICE/`--node-ip` problem, and it works off-network. Billed by usage, and
media leaves your machine.

```
LIVEKIT_URL=wss://<project>.livekit.cloud
LIVEKIT_API_KEY=…
LIVEKIT_API_SECRET=…
PUBLIC_LIVEKIT_URL=wss://<project>.livekit.cloud     # same URL for the browser
```

**Local native** — comment out the Cloud block and uncomment the native one. Note the two URLs
**differ, and must**: containers reach the host via `host.docker.internal`, the browser needs
`localhost`. Cloud has no such split.

```
LIVEKIT_URL=ws://host.docker.internal:7880           # containers
PUBLIC_LIVEKIT_URL=ws://localhost:7880               # browser
```

`./start.sh` reads `LIVEKIT_URL` and skips launching a local server when it sees a `wss://` URL, so
the same command works for both. After switching, recreate the consumers so they pick up the change:

```bash
docker compose up -d --force-recreate agent-server algojobs-service frontend
```

Confirm which one is actually in use — this is the check that matters:

```bash
docker compose logs agent-server | grep -o '"url": "[^"]*"' | tail -1
curl -s localhost:3000/api/config          # livekitUrl the browser will use
```

### Why local LiveKit is not in Docker

LiveKit advertises a **single IP as its ICE candidate**, and under bridge networking no value
satisfies both consumers at once:

| `--node-ip` | Browser (on your machine) | agent-server (in Docker) |
|---|---|---|
| auto → container IP (`172.x`) | unreachable ❌ | reachable ✅ |
| `127.0.0.1` | reachable ✅ | means *itself* ❌ |

The first case fails **silently and confusingly**: signalling succeeds, the room is created, the
agent joins and the session shuts down cleanly — but `publisherCandidates` never gets a `[selected]`
pair, so the candidate's microphone audio never arrives and the interview records an empty
transcript (`user_turn_count=0` → "Candidate did not speak enough"). The second case fails loudly
with `Publisher/Subscriber pc state failed`.

Bound to the host, LiveKit advertises one LAN address that the browser **and** the containers can
both reach. `run-livekit.sh` detects that address and passes `--node-ip` explicitly so it is
deterministic; containers reach it via `LIVEKIT_HOST` (repo-root `.env`, default
`host.docker.internal` — set it to your LAN IP if that fails to resolve).

The `livekit` compose service still exists but is gated behind `profiles: ["docker-livekit"]`, so
it never starts by default. It is appropriate on **Linux** together with `docker-compose.host.yml`,
where host networking makes ICE a non-issue:

```bash
docker compose --profile docker-livekit -f docker-compose.yml -f docker-compose.host.yml up -d
```

Note that `docker compose down` **skips profiled services**, so a stray `livekit` container can
keep holding port 7880. Use `docker compose --profile docker-livekit down` (which is what
`./start.sh --down` does).

**Verified working on macOS** — all services healthy, cross-container wiring confirmed:
`agent-server` registers against `ws://livekit:7880`, apex polls `http://elasticmq:9324`, and
nest reports `algoapex: OK`.

Networking is plain bridge with service-name DNS, which behaves identically on Linux and macOS.
Services address each other by service name (`nest` → `apex:8001`), so the cross-service URLs are
overridden per service in the compose file. That's safe because real env vars take precedence over
the mounted `.env` files in all three runtimes (`@nestjs/config`, `@next/env`, `python-dotenv`).

### Linux deploy: add the host-networking overlay

```bash
docker compose -f docker-compose.yml -f docker-compose.host.yml up -d
```

Bridge networking is poor for WebRTC — LiveKit advertises ICE candidates as raw IPs, and inside a
bridge network that's a private `172.x` address no external browser can reach. The overlay switches
everything to host networking, which removes the NAT hop. **Linux only**: host networking is a
Linux kernel feature; on Docker Desktop it binds inside the VM and nothing is reachable from macOS
(verified). On macOS, run `livekit-local/run-livekit.sh` natively for real interview testing.

## Deploying to the server, step by step

**Getting the code there.** The repo root is not a git repo (each service directory is its own
repo, and the root-level files — `Dockerfile`, `docker-compose.yml`, `docker/`, `infra/`, `dev.sh`
— aren't tracked anywhere). The Docker build context is this whole tree, so ship it with `rsync`
rather than `git clone`:

```bash
# from your machine, in the Algo-jobs directory
rsync -avz --delete \
  --exclude '.venv' --exclude 'node_modules' --exclude '.next' \
  --exclude '.git' --exclude 'logs' --exclude '__pycache__' \
  --exclude 'analysis' --exclude 'staging' \
  ./ user@your-server:/opt/algojob/
```

The excludes matter: they drop ~5GB of build artifacts that get rebuilt inside the image anyway,
plus `analysis/` and `staging/` which aren't part of the deployed stack (`.dockerignore` already
keeps them out of the build). That takes the transfer from ~495MB down to ~160MB.

**`.env` files are included on purpose.** They're gitignored, so they exist *only* on your machine —
but the container mounts them at runtime (they're deliberately never baked into the image). rsync
over SSH carries them securely. Without them the services will fail to start; `algojobs_service` in
particular raises at import if its required vars are missing, so you'll see it immediately.

**On the server:**

```bash
cd /opt/algojob

# Prereqs: Docker Engine + compose plugin, on an x86_64 host (see below)
docker --version && docker compose version

# Point the browser-facing URLs at the server's public hostname — the browser
# is NOT on the same machine as the container, so localhost won't work here.
export PUBLIC_API_BASE_URL=https://algojob.example.com
export PUBLIC_LIVEKIT_URL=wss://algojob.example.com:7880
# Only needed if MinIO's default (http://localhost:9000) isn't reachable from
# the browser on this deploy — same reasoning as the two URLs above.
export PUBLIC_S3_ENDPOINT_URL=https://algojob.example.com:9000

docker compose up -d --build     # first build takes a while (~5-6GB image)
docker compose logs -f algojob
```

**Verify, in this order:**

```bash
docker compose ps                                   # all 4 containers healthy
docker compose ps                                   # all 10 containers up

curl localhost:8000/health        # algojobs_service
curl localhost:8001/v1/health     # apex
curl localhost:8070/health        # personalized-learning
curl localhost:8080/health        # proctoring
curl localhost:5001/health        # nest
curl localhost:3000/api/config    # frontend — check livekitUrl is your PUBLIC_LIVEKIT_URL
curl -f localhost:9000/minio/health/live  # minio
```

Then check nest's startup log for its `IntegrationConnectivityService` summary — it reports
OK/FAIL for Mongo, Redis, Keycloak and AlgoApex in one line, which is the fastest signal that
everything wired up.

**Firewall:** open 3000 (frontend), 5001 (nest API) and LiveKit's 7880/tcp, 7881/tcp,
7882/udp to clients. The rest (8000/8001/8070/8080/6379/8180/9324) are internal — keep them closed.

**Expect one failure on first boot:** `keycloak: FAIL — realm "algo-jobs" missing`. Create that
realm once at `http://your-server:8180` (admin/admin by default — change it via `KEYCLOAK_ADMIN` /
`KEYCLOAK_ADMIN_PASSWORD`).

## algojob-proctoring-mise is NOT in this image

The container runs **7 of the 8 services**. `algojob-proctoring-mise` is excluded because it depends on
**mediapipe**, which publishes only `manylinux_2_28_x86_64`, `macosx_11_0_arm64`, and `win_amd64`
wheels — there is **no Linux ARM64 wheel**, so including it fails the build on Apple Silicon and
rules out ARM servers (Graviton/Ampere) entirely:

```
error: Distribution `mediapipe==0.10.31` can't be installed because it doesn't
have a source distribution or wheel for the current platform
```

With it excluded the image builds natively on **both arm64 and x86_64**, with no QEMU emulation and
no `platform:` pin.

**What you lose:** nothing starts on port 8080. `algojobs_service` and `algojob-agent-server` keep
`PROCTOR_API_URL=ws://localhost:8080/ws/proctor` in their `.env`, which simply won't answer.
Proctoring is opt-in per interview (the `proctoring_enabled` job-metadata flag), so non-proctored
interviews are unaffected — but proctored ones will fail to connect.

**To run proctoring**, either start it natively alongside the container
(`cd algojob-proctoring-mise && ./run.sh`), or add it back to the image —
restore its dependency/source layers and runtime `COPY` in the `Dockerfile`, re-add its
`supervisord.conf` program, and pin `platform: linux/amd64` in `docker-compose.yml`. That last step
makes the image **x86_64-only**.

## Networking: bridge by default, host overlay on Linux

The base `docker-compose.yml` uses plain **bridge networking with service-name DNS**, which works
identically on macOS and Linux. Services address each other by service name (`nest` →
`apex:8001`), so the cross-service URLs are overridden per service in the compose file rather than
relying on each `.env`'s `localhost:` values.

**Verified working on macOS** — all six HTTP services return healthy, agent-server registers with
LiveKit, and nest's integration prober reports `ok=6 fail=1` (only the Keycloak realm, see below).

For a Linux deploy, add the host-networking overlay:

```bash
docker compose -f docker-compose.yml -f docker-compose.host.yml up -d
```

This matters specifically for **LiveKit**: on bridge networking it advertises ICE candidates as its
container-private address (observed: `nodeIP: 172.24.0.7`), which a browser on another machine
cannot reach. Host networking removes the NAT hop so it advertises a real address. Everything else
works fine either way.

Host networking is **Linux-only** — on Docker Desktop it binds inside the VM and is unreachable from
macOS (verified). On macOS, use the base file, or run `livekit-local/run-livekit.sh` natively when
you need to test real interview media.

## Setting the public URLs (required for a real deploy)

Three values are baked into JavaScript served to the **browser**, so they must be the server's
public hostname — not `localhost`, since the browser isn't on the same machine as the container:

```bash
PUBLIC_API_BASE_URL=https://algojob.example.com \
PUBLIC_LIVEKIT_URL=wss://algojob.example.com:7880 \
docker compose up -d
```

These are injected at **container start**, not build time, so one image is portable across
environments — `docker/frontend-entry.sh` restores pristine copies of the built JS and rewrites the
placeholders on every boot. (Next.js inlines `NEXT_PUBLIC_*` at build time and they cannot
otherwise be changed at runtime.)

## Secrets

`.env` files are **mounted**, never baked into the image — `.dockerignore` excludes them from the
build context entirely. Each is mounted into the directory its service runs from, because every
service's `.env` loading is CWD-relative.

## Design notes / gotchas

- **One image, many containers.** Every service runs the same `algojob-stack:latest` with a
  different `command:` and `working_dir:`, so there's a single build but real per-container logs,
  restarts and isolation. Restart one with `docker compose restart <service>`, tail one with
  `docker compose logs -f <service>`.
- **Per-container env removes a real collision class.** Two were genuine: `PORT` (read by *both*
  nest and Next.js standalone — a shared value made the frontend fight nest for 5001) and
  `ENABLE_CRON_JOB` (apex `false`, personalized-learning `true`, and the latter **defaults to
  `true` when unset**, so it can't be omitted). Both are set explicitly per service.
- **Python venvs are not relocatable.** `uv sync` bakes an absolute shebang into every console
  script, so the venvs must be built at the same path they occupy at runtime (`/app/<svc>`).
  Building under `/build` and copying to `/app` produces `exec: ENOENT` for every entry point.
- **Never create `/app/.env`** in the image. Python's bare `load_dotenv()` walks *upward* from the
  CWD, so a file there would override every Python service's own config.
- **nest refuses to boot in production with placeholder secrets.** `validateConfig` rejects
  `change-me-in-production` for `LOCAL_AUTH_JWT_SECRET` / `SESSION_SECRET` /
  `PROVIDER_KEY_SECRET` / `API_KEY_ENCRYPTION_SECRET`. That guard is intentional: the compose
  defaults `NODE_ENV` to `development` so the stack runs locally, but **a real deploy must set
  real secrets in `algojob_nest/.env` and run `NEST_NODE_ENV=production`.**
- **supervisor must be ≥4.3.0** — 4.2.5 imports `pkg_resources`, which setuptools removed in v81,
  so it crash-loops on a modern base image.
- Image is ~3GB. Build on the target architecture, or cross-build with
  `docker buildx build --platform linux/amd64`.

## Local SQS (ElasticMQ) vs real AWS

apex and nest's `.env` files have their real AWS SQS values commented out just above the local
`SQS_ENDPOINT_URL`/`SQS_*_URL` overrides — swap the comments to point back at production queues if
you ever need to. `ENABLE_CRON_JOB` in apex's `.env` was also turned off locally (it fires paid LLM
question-generation on a schedule); run it on demand with
`./scripts/run_worker.sh cron --now` from `algoapex-microservice/`.
