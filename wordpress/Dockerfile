ARG BUILD_FROM=ghcr.io/hassio-addons/base:17.2.1
FROM ${BUILD_FROM}

RUN apk add --no-cache bash curl less vim nginx ca-certificates git tzdata zip \
    libmcrypt-dev zlib-dev gmp-dev \
    freetype-dev libjpeg-turbo-dev libpng-dev \
    php84-fpm php84-json php84-zlib php84-xml php84-xmlwriter php84-simplexml php84-pdo php84-phar php84-openssl \
    php84-pdo_mysql php84-mysqli php84-session \
    php84-gd php84-iconv php84-gmp php84-zip \
    php84-curl php84-opcache php84-ctype php84-apcu \
    php84-intl php84-bcmath php84-dom php84-mbstring php84-xmlreader mysql-client curl && \
    rm -rf /var/cache/apk/*

RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php84/php.ini && \
    sed -i 's/expose_php = On/expose_php = Off/g' /etc/php84/php.ini && \
    sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/usr:\/bin\/bash/g" /etc/passwd && \
    sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/usr:\/bin\/bash/g" /etc/passwd- && \
    ln -s /sbin/php-fpm7 /sbin/php-fpm

# Copy nginx and php-fpm configuration files
COPY files/nginx.conf /etc/nginx/
COPY files/php-fpm.conf /etc/php84/

# Install WP-CLI
RUN curl -o /usr/bin/wp-cli https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x /usr/bin/wp-cli && chown nginx:nginx /usr/bin/wp-cli

# Define the volume and set working directory
VOLUME ["/var/www/html"]
WORKDIR /var/www/html

# Copy data for the add-on
COPY run.sh /
RUN chmod a+x /run.sh

# Define the command to run when the container starts
CMD [ "/run.sh" ]