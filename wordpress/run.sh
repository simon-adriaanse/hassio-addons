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

if [ ! -d /usr/html ]; then
	echo "[i] Creating directories..."
	mkdir -p /usr/html
	echo "[i] Fixing permissions..."
	chown -R nginx:nginx /usr/html
else
	echo "[i] Fixing permissions..."
	chown -R nginx:nginx /usr/html
fi

mv /index.html /usr/html/index.html

chown -R nginx:www-data /usr/html

# start php-fpm
echo "[i] Start php-fpm..."
mkdir -p /usr/logs/php-fpm
php-fpm84

# install Wordpress
mkdir -p /usr/src
version='6.7.2';
sha1='ff727df89b694749e91e357dc2329fac620b3906';
echo "[i] Install Wordpress $version..."

curl -o wordpress.tar.gz -fL "https://wordpress.org/wordpress-$version.tar.gz";
echo "$sha1 *wordpress.tar.gz" | sha1sum -c -;

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
tar -xzf wordpress.tar.gz -C /usr/src/;
rm wordpress.tar.gz;

echo "# BEGIN WordPress" >> /usr/src/wordpress/.htaccess
echo "" >> /usr/src/wordpress/.htaccess
echo "RewriteEngine On" >> /usr/src/wordpress/.htaccess
echo "RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]" >> /usr/src/wordpress/.htaccess
echo "RewriteBase /" >> /usr/src/wordpress/.htaccess
echo "RewriteRule ^index\.php$ - [L]" >> /usr/src/wordpress/.htaccess
echo "RewriteCond %{REQUEST_FILENAME} !-f" >> /usr/src/wordpress/.htaccess
echo "RewriteCond %{REQUEST_FILENAME} !-d" >> /usr/src/wordpress/.htaccess
echo "RewriteRule . /index.php [L]" >> /usr/src/wordpress/.htaccess
echo "# END WordPress" >> /usr/src/wordpress/.htaccess

chown -R nginx:www-data /usr/src/wordpress;
# pre-create wp-content (and single-level children) for folks who want to bind-mount themes, etc so permissions are pre-created properly instead of root:root
# wp-content/cache: https://github.com/docker-library/wordpress/issues/534#issuecomment-705733507

mkdir wp-content;
for dir in /usr/src/wordpress/wp-content/*/ cache; do
	dir="$(basename "${dir%/}")";
	mkdir "wp-content/$dir";
done;
chown -R nginx:www-data wp-content;
chmod -R 1777 wp-content



# start nginx
echo "[i] Start Nginx..."
mkdir -p /usr/logs/nginx
mkdir -p /tmp/nginx
chown nginx /tmp/nginx
nginx