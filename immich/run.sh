#!/bin/bash
set -e

OPTIONS=/data/options.json
log_level=$(jq -r '.log_level // "log"' "${OPTIONS}")
machine_learning=$(jq -r '.machine_learning // true' "${OPTIONS}")

IMMICH_DATA=/share/immich
DB_DATA="${IMMICH_DATA}/postgres"
UPLOAD_DIR="${IMMICH_DATA}/upload"
ML_CACHE="${IMMICH_DATA}/ml-cache"
LOG_DIR="${IMMICH_DATA}/log"

DB_NAME="immich"
DB_USER="immich"
DB_PASS="immich"

# Detect postgres version
PG_VERSION=$(ls /usr/lib/postgresql/ | sort -V | tail -n1)
export PG_VERSION

# Create data directories
mkdir -p "${DB_DATA}" "${UPLOAD_DIR}" "${ML_CACHE}" "${LOG_DIR}"
chown -R postgres:postgres "${DB_DATA}"
chown -R node:node "${UPLOAD_DIR}" "${ML_CACHE}"

# Initialize postgres cluster if not already done
if [ ! -f "${DB_DATA}/PG_VERSION" ]; then
    echo "[INFO] Initializing PostgreSQL database cluster..."
    gosu postgres /usr/lib/postgresql/${PG_VERSION}/bin/initdb \
        -D "${DB_DATA}" \
        --encoding=UTF8 \
        --locale=C.UTF-8

    # Start postgres temporarily to create the immich database and user
    gosu postgres /usr/lib/postgresql/${PG_VERSION}/bin/pg_ctl \
        -D "${DB_DATA}" -l "${LOG_DIR}/postgres-init.log" start -w

    gosu postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASS}';"
    gosu postgres psql -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"
    gosu postgres psql -d "${DB_NAME}" -c "CREATE EXTENSION IF NOT EXISTS vector;"

    gosu postgres /usr/lib/postgresql/${PG_VERSION}/bin/pg_ctl \
        -D "${DB_DATA}" stop -w
    echo "[INFO] PostgreSQL initialized."
fi

# Set up supervisord environment
export IMMICH_ML_ENABLED="${machine_learning}"

# Export environment variables for immich-server
export NODE_ENV=production
export LOG_LEVEL="${log_level}"
export DB_HOSTNAME=127.0.0.1
export DB_PORT=5432
export DB_DATABASE_NAME="${DB_NAME}"
export DB_USERNAME="${DB_USER}"
export DB_PASSWORD="${DB_PASS}"
export REDIS_HOSTNAME=127.0.0.1
export REDIS_PORT=6379
export UPLOAD_LOCATION="${UPLOAD_DIR}"
export IMMICH_HOST=0.0.0.0
export IMMICH_PORT=2283

if [ "${machine_learning}" = "true" ]; then
    export IMMICH_MACHINE_LEARNING_URL="http://127.0.0.1:3003"
    export MACHINE_LEARNING_CACHE_FOLDER="${ML_CACHE}"
else
    export IMMICH_MACHINE_LEARNING_ENABLED=false
fi

# Pass ingress URL to immich if running under supervisor
if [ -n "${SUPERVISOR_TOKEN}" ]; then
    ingress_url=$(curl -s \
        -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
        http://supervisor/addons/self/info | jq -r '.data.ingress_url // ""')
    if [ -n "${ingress_url}" ]; then
        echo "[INFO] Configuring ingress URL: ${ingress_url}"
        export IMMICH_API_URL_EXTERNAL="${ingress_url}"
    fi
fi

echo "[INFO] Starting Immich services (log_level=${log_level}, machine_learning=${machine_learning})..."
exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
