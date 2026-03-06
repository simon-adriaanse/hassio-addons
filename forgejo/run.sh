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
mkdir -p "${FORGEJO_DATA}/conf" \
         "${FORGEJO_DATA}/repositories" \
         "${FORGEJO_DATA}/data" \
         "${FORGEJO_DATA}/log" \
         "${FORGEJO_DATA}/ssh"

echo "[INFO] Setting permissions on Forgejo data directory..."
chown -R ${GIT_USER}:${GIT_USER} "${FORGEJO_DATA}"
mkdir -p /home/git/.ssh && chmod 700 /home/git/.ssh && chown -R git:git /home/git

# Generate SSH host keys if they don't exist (persisted so clients don't get host key warnings on restart)
if [ ! -f "${FORGEJO_DATA}/ssh/forgejo.ed25519" ]; then
    echo "[INFO] Generating SSH host keys..."
    ssh-keygen -t ed25519 -f "${FORGEJO_DATA}/ssh/forgejo.ed25519" -N "" -q
    ssh-keygen -t rsa -b 4096 -f "${FORGEJO_DATA}/ssh/forgejo.rsa" -N "" -q
    chown ${GIT_USER}:${GIT_USER} "${FORGEJO_DATA}/ssh/"*
fi

# Configure Forgejo via environment variables (FORGEJO__SECTION__KEY pattern)
export FORGEJO__server__HTTP_PORT=3000
export FORGEJO__server__SSH_PORT="${ssh_port}"
export FORGEJO__server__START_SSH_SERVER=true
export FORGEJO__server__SSH_LISTEN_HOST=0.0.0.0
export FORGEJO__server__SSH_LISTEN_PORT="${ssh_port}"
export FORGEJO__server__SSH_SERVER_HOST_KEYS="${FORGEJO_DATA}/ssh/forgejo.ed25519,${FORGEJO_DATA}/ssh/forgejo.rsa"
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
elif [ -n "${SUPERVISOR_TOKEN}" ]; then
    ingress_url=$(curl -s \
        -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
        http://supervisor/addons/self/info | jq -r '.data.ingress_url // ""')
    if [ -n "${ingress_url}" ]; then
        echo "[INFO] Configuring ingress URL: ${ingress_url}"
        export FORGEJO__server__ROOT_URL="${ingress_url}"
    fi
fi

echo "[INFO] Starting Forgejo..."
exec runuser -u ${GIT_USER} -- /usr/local/bin/forgejo web \
    --config "${FORGEJO_DATA}/conf/app.ini" \
    --work-path "${FORGEJO_DATA}"
