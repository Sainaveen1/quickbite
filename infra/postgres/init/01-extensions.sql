CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid()
-- Phase 3: order shards (orders_shard_0 / orders_shard_1) get their own containers. See docs/PHASE0_CHECKLIST.md
