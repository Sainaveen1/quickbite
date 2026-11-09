# New Relic friction log (INTERNAL: don't publish)

Every time something about instrumenting QuickBite with New Relic is confusing, missing or slow, add a row. At the end of Phase 3 and Phase 5, turn the top items into short write-ups for the relevant product teams.

| Date | NR capability | What I tried | Expected | Actual | Time lost | Workaround | Suggested improvement | Severity (1–3) |
|---|---|---|---|---|---|---|---|---|
| 2026-11-XX | (example) Browser agent + Next.js App Router | Copy-paste snippet into root layout | Page views + Web Vitals in 5 min | … | … | … | … | 2 |

**Areas to probe** (hypotheses to test, not known gaps): tracing across Kafka in Node · Redpanda vs the Kafka integration · WebSocket visibility in Browser · React Native coverage (incl. Session Replay?) · per-turn voice/LLM latency breakdown · Next.js server-component tracing · ingest-cost controls for high-volume rider data · micro-frontend error attribution · Arm64 infra + k3s.
