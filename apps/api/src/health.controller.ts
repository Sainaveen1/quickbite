import { Controller, Get } from '@nestjs/common';

const startedAt = Date.now();

@Controller('health')
export class HealthController {
  // Liveness only for Phase 0. Phase 1: add a readiness check (Postgres + Redis ping).
  @Get()
  check() {
    return {
      status: 'ok',
      service: 'quickbite-api',
      version: process.env.GIT_SHA ?? 'dev',
      uptimeSeconds: Math.round((Date.now() - startedAt) / 1000),
    };
  }
}
