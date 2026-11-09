// Shared contracts: one source of truth for Next.js, Expo and NestJS.
// Phase 1 adds auth/catalog/order schemas. Phase 2 adds Kafka event schemas (versioned).
import { z } from 'zod';

export const HealthResponse = z.object({
  status: z.literal('ok'),
  service: z.string(),
  version: z.string(),
  uptimeSeconds: z.number().int().nonnegative(),
});
export type HealthResponse = z.infer<typeof HealthResponse>;
