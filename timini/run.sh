#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

# if ! bashio::services.available 'mysql'; then
# 	echo "[E] Mysql Service not found..."
# 	bashio::log.fatal "Local database access should be provided by the MariaDB addon"
# 	bashio::exit.nok "Please ensure it is installed and started"
# fi

# cd /app || exit
# node app.js

cd /app/www || exit
python3 -m http.server 3000

