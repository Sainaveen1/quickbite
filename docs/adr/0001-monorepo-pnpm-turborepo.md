# ADR-0001: Single monorepo with pnpm workspaces + Turborepo
- **Status:** Accepted (example: rewrite in your own words)
- **Date:** 2026-11-11

## Context
QuickBite will have a Next.js site, micro-frontend portals, an Expo app and ~9 NestJS services. They all need shared types and validation (Zod contracts), a design system and a Kafka client library. The team is one person, and CI minutes and build time matter.

## Options considered
1. **Polyrepo (one repo per service):** strong isolation, but cross-repo changes for every contract update and duplicated CI.
2. **Nx monorepo:** powerful generators and a dependency graph, but heavier and more opinionated.
3. **pnpm workspaces + Turborepo:** lightweight, fast installs, task caching, and close to plain npm scripts.

## Decision
pnpm workspaces + Turborepo. Shared code lives in `packages/*` and deployables in `apps/*`.

## Consequences
- Contract changes are atomic across web, mobile and backend in one PR.
- Each service still builds its own Docker image (`pnpm deploy`), so services stay independently deployable.
- Revisit if build times grow: Turborepo remote cache, or move to Nx for affected-only graph tooling.
