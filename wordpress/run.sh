#!/usr/bin/with-contenv bashio
#!/bin/sh
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
webrootdocker=/var/www/localhost/htdocs/
phppath=/etc/php84/php.ini

# env["DB_HOST"] = "$DB_HOST"
# env["DB_USER"] = "$DB_USER"
# env["DB_PASS"] = "$DB_PASS"
# env["DB_NAME"] = "$DB_NAME"

installpath=/usr/html
phpini="default"

if [ ! -d $installpath ]; then
	echo "[i] Creating directories..."
	mkdir -p $installpath
	echo "[i] Fixing permissions..."
	chown -R nginx:nginx $installpath
else
	echo "[i] Fixing permissions..."
	chown -R nginx:nginx $installpath
fi

# php ini
echo "[i] php.ini..."
if [ $phpini = "get_file" ]; then
	cp $phppath /share/wp_php.ini
	echo "You have requestet a copy of the php.ini file. You will now find your copy at /share/wp_php.ini"
	echo "Addon will now be stopped. Please remove the config option and change it to the name of your new config file (for example /share/php.ini)"
	exit 1
fi
if [ $phpini != "default" ]; then
	if [ -f $phpini ]; then
		echo "Your custom php.ini at $phpini will be used."
		rm $phppath
		cp $phpini $phppath
	else
		echo "You have changed the php_ini variable, but the new file could not be found! Default php.ini file will be used instead."
	fi
fi

# phpmyadmin
if [ ! -d "$installpath/phpmyadmin" ]; then
	echo "[i] Install phpmyadmin..."
 	mkdir $installpath/phpmyadmin
 	curl -L -s "https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz" | tar zxvf - --strip 1 -C $installpath/phpmyadmin
	
 	sed -i "s@'configFile' =>.*@'configFile' => '/etc/phpmyadmin/config.inc.php',@"	$installpath/phpmyadmin/libraries/vendor_config.php
	
 	find $installpath/ -type f -name "*.md" -depth -exec rm -f {} \;
 	rm -f -r /tmp/* $installpath/phpmyadmin/setup $installpath/phpmyadmin/examples $installpath/phpmyadmin/test/ $installpath/phpmyadmin/po $installpath/phpmyadmin/composer.json $installpath/phpmyadmin/RELEASE-DATE-*

     echo "[i] phpmyadmin installed"
 else
     echo "[i] phpmyadmin already exists"
 fi


# start php-fpm
echo "[i] Start php-fpm..."
mkdir -p /usr/logs/php-fpm
php-fpm84

# install Wordpress
mkdir -p $installpath
chown -R nginx:nginx $installpath;

version='6.7.2';
sha1='ff727df89b694749e91e357dc2329fac620b3906';
echo "[i] Install Wordpress $version..."

curl -o wordpress.tar.gz -fL "https://wordpress.org/wordpress-$version.tar.gz";
echo "$sha1 *wordpress.tar.gz" | sha1sum -c -;

# upstream tarballs include ./wordpress/ so this gives us $installpath/wordpress
tar -xzf wordpress.tar.gz -C $installpath/;
rm wordpress.tar.gz;

echo "# BEGIN WordPress" >> $installpath/wordpress/.htaccess
echo "" >> $installpath/wordpress/.htaccess
echo "RewriteEngine On" >> $installpath/wordpress/.htaccess
echo "RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]" >> $installpath/wordpress/.htaccess
echo "RewriteBase /" >> $installpath/wordpress/.htaccess
echo "RewriteRule ^index\.php$ - [L]" >> $installpath/wordpress/.htaccess
echo "RewriteCond %{REQUEST_FILENAME} !-f" >> $installpath/wordpress/.htaccess
echo "RewriteCond %{REQUEST_FILENAME} !-d" >> $installpath/wordpress/.htaccess
echo "RewriteRule . /index.php [L]" >> $installpath/wordpress/.htaccess
echo "# END WordPress" >> $installpath/wordpress/.htaccess

chown -R nginx:nginx $installpath/wordpress;
chmod -R 755 $installpath/wordpress
chmod -R 755 $installpath/wordpress/wp-admin
chmod -R 755 $installpath/wordpress/wp-content
chmod -R 755 $installpath/wordpress/wp-includes

# pre-create wp-content (and single-level children) for folks who want to bind-mount themes, etc so permissions are pre-created properly instead of root:root
# wp-content/cache: https://github.com/docker-library/wordpress/issues/534#issuecomment-705733507
# if [ ! -d "$installpath/wp-content" ]; then
# 	mkdir  $installpath/wp-content;
# fi
# for dir in $installpath/wordpress/wp-content/*/ cache; do
# 	dir="$(basename "${dir%/}")";
# 	mkdir "wp-content/$dir";
# done;
# chown -R nginx:nginx wp-content;
# chmod -R 1777 wp-content

# start nginx
echo "[i] Start Nginx..."
mkdir -p /usr/logs/nginx
mkdir -p /tmp/nginx
chown nginx /tmp/nginx
nginx