// Phase 1: add `require('newrelic')` as the FIRST line (or start with `node -r newrelic dist/main.js`)
// once the New Relic license key is in your .env.
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableShutdownHooks(); // graceful shutdown on SIGTERM (docker stop / redeploys)
  const port = Number(process.env.API_PORT ?? 3000);
  await app.listen(port, '0.0.0.0');
  console.log(`QuickBite API listening on :${port}`);
}
bootstrap();
