#!/usr/bin/with-contenv bashio
ssl=$(bashio::config 'ssl')
website_name=$(bashio::config 'website_name')
certfile=$(bashio::config 'certfile')
keyfile=$(bashio::config 'keyfile')
DocumentRoot=$(bashio::config 'document_root')
phpini=$(bashio::config 'php_ini')
username=$(bashio::config 'username')
password=$(bashio::config 'password')
default_conf=$(bashio::config 'default_conf')
default_ssl_conf=$(bashio::config 'default_ssl_conf')
webrootdocker=/www/html/
phppath=/etc/php84/php.ini

if [ "$phpini" = "get_file" ]; then
	cp $phppath /share/nginx_php.ini
	echo "[i] A copy of the php.ini file has been created at /share/nginx_php.ini."
	echo "    Please update the config option with your new file path (e.g., /share/php.ini) and restart."
	echo "    The addon will now stop."
	exit 1
fi

if bashio::config.has_value 'init_commands'; then
	echo "[i] Running custom init commands from init_commands"
	while read -r cmd; do
		eval "${cmd}" ||
			bashio::exit.nok "[ERROR] Failed executing init command: ${cmd}"
	done <<<"$(bashio::config 'init_commands')"
fi

if [ ! -d $webrootdocker ]; then
	mkdir -p $webrootdocker
fi
if [ ! -d "$DocumentRoot" ]; then
	echo "[ERROR] You haven't placed your website files in the specified folder $DocumentRoot. A default welcome page will be served"
	echo "        This can also be caused by folder privileges issue."

	cp /index.html $webrootdocker
	nginxrootdocker=$webrootdocker
else
	#Create Shortcut to shared html folder
	ln -s "$DocumentRoot" $webrootdocker
	nginxrootdocker=$DocumentRoot
fi

#Set rights to web folders and create user
if [ -d "$DocumentRoot" ]; then
	find "$DocumentRoot" -type d -exec chmod 771 {} \;
	if [ ! -z "$username" ] && [ ! -z "$password" ] && [ ! "$username" = "null" ] && [ ! "$password" = "null" ]; then
		adduser -S "$username" -G nginx
		echo "$username:$password" | chpasswd "$username"
		find $webrootdocker -type d -exec chown "$username":nginx -R {} \;
		find $webrootdocker -type f -exec chown "$username":nginx -R {} \;
	else
		echo "[ERROR] Username and/or password wasn't provided. Skipping account set up."
	fi
fi

if [ "$phpini" != "default" ]; then
	if [ -f "$phpini" ]; then
		echo "[i] Using custom php.ini: $phpini"
		rm $phppath
		cp "$phpini" $phppath
	else
		echo "[ERROR] Custom php.ini was specified, but file is not found: $phpini. Reverting to the default configuration."
	fi
fi

# if [ $ssl = "true" ] && [ $default_conf = "default" ]; then
# else
# 	echo "SSL is deactivated and/or you are using a custom config."
# fi

if [ "$default_conf" = "get_config" ]; then
 	if [ -f /etc/nginx/nginx.conf ]; then
 		cp /etc/nginx/nginx.conf /share/nginx.conf
 		echo "[i] You have requested a copy of the nginx config. You can now find it at /share/nginx.conf"
	else
 		echo "[ERROR] /etc/nginx/nginx.conf does not exist..."
 	fi
	echo "Exiting now..."
	exit 0
elif [ "$default_conf" = "default" ]; then
	echo "[i] Running on default nginx.conf"
	# sed "s|root /www/html|root $nginxrootdocker" /etc/nginx/nginx.conf

	mv /etc/nginx/nginx.conf /etc/nginx/nginx.bak

	awk -v nginxroot="root $nginxrootdocker" "{ \
			gsub(/root \/www\/html/, nginxroot); \
			print; \
		}" /etc/nginx/nginx.bak > /etc/nginx/nginx.conf

	cat /etc/nginx/nginx.conf
else
	echo "[i] Running on custom nginx.conf"
	if [ -f /etc/nginx/nginx.conf ]; then
		rm /etc/nginx/nginx.conf
	fi
	cp -rf "$default_conf" /etc/nginx/nginx.conf
fi

# if [[ ! $default_conf =~ ^(default|get_config)$ ]]; then
# 	if [ -f $default_conf ]; then
# 		if [ ! -d /etc/apache2/sites-enabled ]; then
# 			mkdir /etc/apache2/sites-enabled
# 		fi
# 		if [ -f /etc/apache2/sites-enabled/000-default.conf ]; then
# 			rm /etc/apache2/sites-enabled/000-default.conf
# 		fi
# 		cp -rf $default_conf /etc/apache2/sites-enabled/000-default.conf
# 		echo "Your custom apache config at $default_conf will be used."
# 	else
# 		echo "Cant find your custom 000-default.conf file $default_conf - be sure you have chosen the full path. Exiting now..."
# 		exit 1
# 	fi
# fi

# if [ "$default_ssl_conf" = "get_config" ]; then
# 	if [ -f /etc/apache2/httpd.conf ]; then
# 		cp /etc/apache2/sites-enabled/000-default-le-ssl.conf /share/000-default-le-ssl.conf
# 		echo "You have requested a copy of the apache2 ssl config. You can now find it at /share/000-default-le-ssl.conf ."
# 	fi
# 	echo "Exiting now..."
# 	exit 0
# fi

# if [ "$default_ssl_conf" != "default" ]; then
# 	if [ -f $default_ssl_conf ]; then
# 		if [ ! -d /etc/apache2/sites-enabled ]; then
# 			mkdir /etc/apache2/sites-enabled
# 		fi
# 		if [ -f /etc/apache2/sites-enabled/000-default-le-ssl.conf ]; then
# 			rm /etc/apache2/sites-enabled/000-default-le-ssl.conf
# 		fi
# 		cp -rf $default_ssl_conf /etc/apache2/sites-enabled/000-default-le-ssl.conf
# 		echo "Your custom apache config at $default_ssl_conf will be used."
# 	else
# 		echo "Cant find your custom 000-default-le-ssl.conf file $default_ssl_conf - be sure you have chosen the full path. Exiting now..."
# 		exit 1
# 	fi
# fi


# start php-fpm
echo "[i] Start php-fpm..."
mkdir -p /usr/logs/php-fpm
php-fpm84

mkdir /usr/lib/php84/modules/opcache

echo "Web root architecture:"
ls -l $webrootdocker

# start nginx
echo "[i] Start Nginx..."
if [ ! -d "/usr/logs/nginx" ]; then
	mkdir -p /usr/logs/nginx
fi
if [ ! -d "/tmp/nginx" ]; then
	mkdir -p /tmp/nginx
fi
chown nginx /tmp/nginx
nginx