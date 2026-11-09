# Build context = repo root:  docker build -f apps/api/Dockerfile .
FROM node:22-alpine AS build
RUN corepack enable
WORKDIR /repo
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm --filter @quickbite/api build
RUN pnpm --filter @quickbite/api deploy --prod /out

FROM node:22-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /out/ ./
ARG GIT_SHA=dev
ENV GIT_SHA=$GIT_SHA
USER node
EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=3s --retries=5 CMD wget -qO- http://127.0.0.1:3000/health || exit 1
CMD ["node", "dist/main.js"]
