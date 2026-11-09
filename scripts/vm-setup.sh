#!/usr/bin/env bash
# One-time setup for the Oracle Cloud Always Free Arm VM (Ubuntu 24.04, aarch64).
# Run ON THE VM as the default 'ubuntu' user:
#   DUCKDNS_SUBDOMAIN=yoursub DUCKDNS_TOKEN=xxxx bash vm-setup.sh
# Read it before running. It only uses official Ubuntu and Docker apt repositories.
set -euo pipefail

echo "==> System update + basics"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl gnupg fail2ban unattended-upgrades netfilter-persistent iptables-persistent

echo "==> Docker Engine + Compose plugin (official Docker apt repo)"
if ! command -v docker >/dev/null 2>&1; then
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker "$USER"
fi
# Keep container logs from filling the disk
echo '{ "log-driver": "json-file", "log-opts": { "max-size": "10m", "max-file": "3" } }' | sudo tee /etc/docker/daemon.json >/dev/null
sudo systemctl restart docker

echo "==> 2 GB swap (safety net for memory spikes)"
if ! swapon --show | grep -q /swapfile; then
  sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
  sudo mkswap /swapfile && sudo swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
fi

echo "==> Open 80/443 in the host firewall"
# Oracle's Ubuntu images ship iptables rules that REJECT everything except SSH.
# You ALSO need ingress rules for TCP 80 and 443 in the VCN Security List (OCI console).
for PORT in 80 443; do
  if ! sudo iptables -C INPUT -p tcp -m state --state NEW --dport "$PORT" -j ACCEPT 2>/dev/null; then
    REJECT_LINE=$(sudo iptables -L INPUT --line-numbers | awk '/REJECT/ {print $1; exit}')
    if [ -n "${REJECT_LINE:-}" ]; then
      sudo iptables -I INPUT "$REJECT_LINE" -p tcp -m state --state NEW --dport "$PORT" -j ACCEPT
    else
      sudo iptables -A INPUT -p tcp -m state --state NEW --dport "$PORT" -j ACCEPT
    fi
  fi
done
sudo netfilter-persistent save

echo "==> DuckDNS IP updater (every 30 min)"
if [ -n "${DUCKDNS_SUBDOMAIN:-}" ] && [ -n "${DUCKDNS_TOKEN:-}" ]; then
  mkdir -p ~/duckdns
  cat > ~/duckdns/update.sh <<SCRIPT
#!/usr/bin/env bash
curl -fsS "https://www.duckdns.org/update?domains=${DUCKDNS_SUBDOMAIN}&token=${DUCKDNS_TOKEN}&ip=" -o ~/duckdns/last.log
SCRIPT
  chmod 700 ~/duckdns/update.sh
  ( crontab -l 2>/dev/null | grep -v duckdns; echo "*/30 * * * * ~/duckdns/update.sh >/dev/null 2>&1" ) | crontab -
  ~/duckdns/update.sh && echo "DuckDNS: $(cat ~/duckdns/last.log)"
else
  echo "Skipping DuckDNS (set DUCKDNS_SUBDOMAIN and DUCKDNS_TOKEN to enable)"
fi

echo "==> App directory"
mkdir -p ~/quickbite/infra
if [ ! -f ~/quickbite/.env ]; then
  cat > ~/quickbite/.env <<ENV
API_DOMAIN=${DUCKDNS_SUBDOMAIN:-yoursub}.duckdns.org
GHCR_OWNER=your-github-username-lowercase
POSTGRES_USER=quickbite
POSTGRES_PASSWORD=$(openssl rand -hex 16)
POSTGRES_DB=quickbite
DATABASE_URL=postgres://quickbite:CHANGE_TO_POSTGRES_PASSWORD@postgres:5432/quickbite
REDIS_URL=redis://redis:6379
ENV
  chmod 600 ~/quickbite/.env
  echo "Created ~/quickbite/.env: edit GHCR_OWNER and copy POSTGRES_PASSWORD into DATABASE_URL."
fi

echo
echo "Done. Log out and back in (so the docker group applies), then check: docker run --rm hello-world"
