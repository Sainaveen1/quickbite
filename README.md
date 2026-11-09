# QuickBite

A real-time food and quick-commerce delivery platform with an AI voice ordering agent. I'm building it to go deep on distributed-systems design: event-driven microservices, sagas, sharding, live tracking, and observability with New Relic.

> **Status:** Phase 0 (setup). Live API: `https://<your-subdomain>.duckdns.org/health`

## Stack
- **Web:** Next.js (customer site), Module Federation portals (Phase 5)
- **Mobile:** Expo React Native rider app (Phase 4)
- **Backend:** NestJS (TypeScript), modular monolith → microservices
- **Data:** Postgres + PostGIS, Redis, Redpanda (Kafka API)
- **Infra:** Docker Compose → k3s · Caddy · GitHub Actions (arm64) · Oracle Cloud Always Free
- **Observability:** New Relic (Browser, Mobile, APM + OpenTelemetry, Infra, Service Levels)

## Repo layout
```
apps/
  api/                 NestJS API (Phase 0: /health)
  web/                 Next.js — create in week 1 (see docs/PHASE0_CHECKLIST.md)
packages/
  contracts/           Shared Zod schemas + types (web, mobile, backend)
infra/postgres/        Postgres 16 + PostGIS image (multi-arch)
deploy/                Production compose + Caddyfile for the VM
scripts/vm-setup.sh    One-time Oracle VM setup
docs/                  Phase checklists, ADRs
```

## Run locally
```bash
corepack enable            # gives you pnpm
cp .env.example .env
pnpm install
pnpm infra:up              # Postgres+PostGIS, Redis, Redpanda (+ console at :8080)
pnpm --filter @quickbite/api dev
curl localhost:3000/health
```

## Architecture decisions
See [`docs/adr`](docs/adr). Every significant choice gets an ADR.
