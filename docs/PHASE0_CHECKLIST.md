# Phase 0: Setup checklist (Week 1, 9–15 Nov 2026, ~5.5 build hours)

**Done when:** every push to `main` builds an arm64 image, deploys it to your Oracle VM, and `https://<sub>.duckdns.org/health` returns `{"status":"ok"}`. The Next.js app should also be live on Vercel.

Use **your personal** GitHub, Oracle, Vercel, DuckDNS and API-key accounts only. Get your manager's written OK first: QuickBite is your personal project, you keep ownership and the public repo, and you're building it on the NR laptop as an instrumentation test app. Confirm that Docker and pushes to a personal GitHub are allowed on the corporate laptop.

---

## Mon: repo + local infra (60 min)
- [ ] Create a **public** GitHub repo `quickbite` on your personal account. Copy this starter kit in, then commit.
- [ ] Install Node 22 (`nvm install 22`), then `corepack enable`, then Docker Desktop (or Colima/OrbStack).
- [ ] `cp .env.example .env` → `pnpm install` (this creates `pnpm-lock.yaml`, which you **commit**: CI and Docker use `--frozen-lockfile`).
- [ ] `pnpm infra:up`. Check Postgres (`psql ... -c "select postgis_version();"`), Redis (`redis-cli ping`) and Redpanda console at http://localhost:8080.

## Wed: API + tests + CI (60 min)
- [ ] `pnpm --filter @quickbite/api dev` → `curl localhost:3000/health`.
- [ ] `pnpm test` passes (the health spec).
- [ ] Push → the **CI** workflow goes green on GitHub.
- [ ] Write **ADR-0001** (monorepo + pnpm + Turborepo). An example is already in `docs/adr/`. Edit it in your own words.

## Fri: Oracle Cloud account + VM (60 min)
- [ ] Sign up for Oracle Cloud Free Tier. **You** enter the card for verification. Pick home region **India South (Hyderabad)** or **India West (Mumbai)**. This can't be changed later.
- [ ] Billing → set a **budget alert at $1**.
- [ ] Create instance: **Ubuntu 24.04 (aarch64)**, shape **VM.Standard.A1.Flex, 2 OCPU / 12 GB** (the full Always Free allowance), boot volume ~100 GB, upload your SSH public key, and assign a public IP.
  - If you see "Out of host capacity", retry later or off-peak, or try another availability domain.
- [ ] Networking → VCN → Security List → add ingress rules for **TCP 80 and 443** from `0.0.0.0/0`.
- [ ] Create a DuckDNS subdomain (sign in with your personal account) and point it at the VM's public IP.

## Sat: VM setup + first manual deploy (90 min)
- [ ] `scp scripts/vm-setup.sh ubuntu@<ip>:~` → `ssh ubuntu@<ip>` → `DUCKDNS_SUBDOMAIN=<sub> DUCKDNS_TOKEN=<token> bash vm-setup.sh`
- [ ] Log out and back in → `docker run --rm hello-world`.
- [ ] Edit `~/quickbite/.env` (GHCR owner in lowercase; copy the generated Postgres password into `DATABASE_URL`).
- [ ] On your laptop, build once by hand to prove the image works:
      `docker buildx build --platform linux/arm64 -f apps/api/Dockerfile -t ghcr.io/<you>/quickbite-api:latest --push .`
      (log in first: `echo <PAT> | docker login ghcr.io -u <you> --password-stdin`, using a classic PAT with `write:packages`)
- [ ] On GitHub → your profile → Packages → `quickbite-api` → Package settings → **make it public** (so the VM can pull without credentials).
- [ ] In the same Package settings → **Manage Actions access** → add the `quickbite` repo with **Write** role. This is needed because you created the package by hand, and without it the Deploy workflow can't push.
- [ ] Copy `deploy/*` and `infra/postgres` to `~/quickbite` on the VM, then run `docker compose -f docker-compose.prod.yml --env-file .env up -d --build`.
- [ ] `curl https://<sub>.duckdns.org/health` should work over HTTPS. Caddy gets the certificate automatically on the first request.

## Sun: automate deploys + Next.js on Vercel (60 min)
- [ ] Create a **deploy-only** SSH key pair (`ssh-keygen -t ed25519 -f qb_deploy`) and add the `.pub` to the VM's `~/.ssh/authorized_keys`.
- [ ] GitHub repo → Settings → Environments → `production` → secrets: `VM_SSH_KEY` (private key), `VM_HOST` (IP), `VM_USER` (`ubuntu`), `API_DOMAIN` (`<sub>.duckdns.org`).
- [ ] Push a change to `apps/api` → the **Deploy** workflow builds the arm64 image, deploys it and smoke-tests `/health`.
- [ ] Create the web app:
      `pnpm create next-app@latest apps/web --ts --app --eslint --src-dir --use-pnpm --import-alias "@/*"`
      Rename its package to `@quickbite/web`, then commit.
- [ ] Vercel → import the repo → Root Directory `apps/web` → deploy. You get `quickbite-<you>.vercel.app`.
- [ ] Add one entry to `docs/NR_FRICTION_LOG.md` if anything about the NR account setup was confusing.

---

## Troubleshooting
- **HTTPS doesn't come up:** check the OCI Security List has 80/443, then `sudo iptables -L INPUT --line-numbers` (the ACCEPT rules must come *before* the REJECT line), and that DuckDNS resolves to the VM IP (`dig <sub>.duckdns.org`). Then `docker compose logs caddy`.
- **"exec format error":** the image was built for amd64. Build with `--platform linux/arm64`, or let the workflow (which runs on an arm64 runner) do it.
- **VM reclaimed as idle:** this only happens if CPU, network **and** memory all stay under 20% for 7 days. A running stack keeps memory above 20%.
- **Free-tier check:** in Billing → Cost Analysis, cost should stay at $0.00.
