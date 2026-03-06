#!/bin/bash
set -e

# Read configuration from /data/options.json (provided by HA Supervisor)
OPTIONS=/data/options.json
ssl=$(jq -r '.ssl // false' "${OPTIONS}")
certfile=$(jq -r '.certfile // "fullchain.pem"' "${OPTIONS}")
keyfile=$(jq -r '.keyfile // "privkey.pem"' "${OPTIONS}")
domain=$(jq -r '.domain // ""' "${OPTIONS}")
ssh_port=$(jq -r '.ssh_port // 22' "${OPTIONS}")

FORGEJO_DATA=/share/forgejo
GIT_USER=git

# Create Forgejo data directories if they don't exist
if [ ! -d "${FORGEJO_DATA}" ]; then
    echo "[INFO] Creating Forgejo data directories..."
    mkdir -p "${FORGEJO_DATA}/conf"
    mkdir -p "${FORGEJO_DATA}/repositories"
    mkdir -p "${FORGEJO_DATA}/data"
    mkdir -p "${FORGEJO_DATA}/log"
fi

echo "[INFO] Setting permissions on Forgejo data directory..."
chown -R ${GIT_USER}:${GIT_USER} "${FORGEJO_DATA}"

# Set up SSH authorized_keys for git user
if [ ! -d "/home/git/.ssh" ]; then
    mkdir -p /home/git/.ssh
    chmod 700 /home/git/.ssh
    chown -R git:git /home/git
fi

# Configure Forgejo via environment variables (FORGEJO__SECTION__KEY pattern)
export FORGEJO__server__HTTP_PORT=3000
export FORGEJO__server__SSH_PORT="${ssh_port}"
export FORGEJO__repository__ROOT="${FORGEJO_DATA}/repositories"
export FORGEJO__server__APP_DATA_PATH="${FORGEJO_DATA}/data"
export FORGEJO__log__ROOT_PATH="${FORGEJO_DATA}/log"

if [ -n "${domain}" ]; then
    echo "[INFO] Configuring domain: ${domain}"
    export FORGEJO__server__DOMAIN="${domain}"
    if [ "${ssl}" = "true" ]; then
        export FORGEJO__server__ROOT_URL="https://${domain}/"
        export FORGEJO__server__PROTOCOL=https
        export FORGEJO__server__CERT_FILE="/ssl/${certfile}"
        export FORGEJO__server__KEY_FILE="/ssl/${keyfile}"
    else
        export FORGEJO__server__ROOT_URL="http://${domain}:3000/"
    fi
fi

echo "[INFO] Starting Forgejo..."
exec su - ${GIT_USER} -c "/usr/local/bin/forgejo web \
    --config \"${FORGEJO_DATA}/conf/app.ini\" \
    --work-path \"${FORGEJO_DATA}\""
