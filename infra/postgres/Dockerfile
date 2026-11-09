# Postgres 16 + PostGIS, multi-arch (works on the Oracle Arm VM and on Intel/Apple laptops).
# The official postgres image already has the PGDG apt repo configured, which ships arm64 PostGIS packages.
FROM postgres:16-bookworm
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-16-postgis-3 postgresql-16-postgis-3-scripts \
 && rm -rf /var/lib/apt/lists/*
COPY init/ /docker-entrypoint-initdb.d/
