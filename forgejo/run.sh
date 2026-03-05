#!/usr/bin/with-contenv bashio

FORGEJO_DATA=/share/forgejo
GIT_USER=git

# Read configuration
domain=$(bashio::config 'domain')
ssh_port=$(bashio::config 'ssh_port')
ssl=$(bashio::config 'ssl')
certfile=$(bashio::config 'certfile')
keyfile=$(bashio::config 'keyfile')

# Create Forgejo data directories if they don't exist
if [ ! -d "${FORGEJO_DATA}" ]; then
    bashio::log.info "Creating Forgejo data directories..."
    mkdir -p "${FORGEJO_DATA}/conf"
    mkdir -p "${FORGEJO_DATA}/repositories"
    mkdir -p "${FORGEJO_DATA}/data"
    mkdir -p "${FORGEJO_DATA}/log"
fi

bashio::log.info "Setting permissions on Forgejo data directory..."
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

if bashio::config.has_value 'domain' && [ "${domain}" != "" ]; then
    bashio::log.info "Configuring domain: ${domain}"
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

bashio::log.info "Starting Forgejo..."
exec su-exec ${GIT_USER} /usr/local/bin/forgejo web \
    --config "${FORGEJO_DATA}/conf/app.ini" \
    --work-path "${FORGEJO_DATA}"
