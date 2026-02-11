#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"
EXAMPLE_ENV_FILE="${ROOT_DIR}/.env.example"
INIT_SQL="${ROOT_DIR}/db/init/01_init.sql"

if [[ ! -f "${ENV_FILE}" ]]; then
  cp "${EXAMPLE_ENV_FILE}" "${ENV_FILE}"
fi

# shellcheck disable=SC1090
set -a
source "${ENV_FILE}"
set +a

POSTGRES_DB="${POSTGRES_DB:-AVATEL}"
POSTGRES_USER="${POSTGRES_USER:-turyelectro}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-turyelectro123}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y postgresql postgresql-client

# In constrained environments services may not auto-start.
if command -v systemctl >/dev/null 2>&1; then
  systemctl start postgresql >/dev/null 2>&1 || true
fi

if command -v pg_lsclusters >/dev/null 2>&1; then
  CLUSTER="$(pg_lsclusters --no-header | awk 'NR==1 {print $1 " " $2}')"
  if [[ -n "${CLUSTER}" ]]; then
    pg_ctlcluster ${CLUSTER} start >/dev/null 2>&1 || true
  fi
fi

sudo -u postgres psql -v ON_ERROR_STOP=1 <<SQL
DO
\$\$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${POSTGRES_USER}') THEN
    CREATE ROLE ${POSTGRES_USER} LOGIN PASSWORD '${POSTGRES_PASSWORD}';
  ELSE
    ALTER ROLE ${POSTGRES_USER} WITH LOGIN PASSWORD '${POSTGRES_PASSWORD}';
  END IF;
END
\$\$;
SQL

if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${POSTGRES_DB}'" | grep -q 1; then
  sudo -u postgres createdb -O "${POSTGRES_USER}" "${POSTGRES_DB}"
fi

sudo -u postgres psql -d "${POSTGRES_DB}" -f "${INIT_SQL}"
sudo -u postgres psql -d "${POSTGRES_DB}" -c "ALTER DATABASE \"${POSTGRES_DB}\" OWNER TO \"${POSTGRES_USER}\";"


sudo -u postgres psql -d "${POSTGRES_DB}" -v ON_ERROR_STOP=1 <<SQL
GRANT USAGE ON SCHEMA public TO "${POSTGRES_USER}";
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "${POSTGRES_USER}";
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "${POSTGRES_USER}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO "${POSTGRES_USER}";
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO "${POSTGRES_USER}";
SQL

if [[ "${POSTGRES_PORT}" != "5432" ]]; then
  PG_VER="$(ls /etc/postgresql | head -n1)"
  PG_CONF="/etc/postgresql/${PG_VER}/main/postgresql.conf"
  sed -i "s/^#\?port = .*/port = ${POSTGRES_PORT}/" "${PG_CONF}"
  if command -v systemctl >/dev/null 2>&1; then
    systemctl restart postgresql >/dev/null 2>&1 || true
  fi
  pg_ctlcluster "${PG_VER}" main restart >/dev/null 2>&1 || true
fi

echo "PostgreSQL nativo configurado."
echo "Base de datos: ${POSTGRES_DB}"
echo "Usuario: ${POSTGRES_USER}"
echo "Puerto: ${POSTGRES_PORT}"
