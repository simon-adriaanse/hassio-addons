FROM ghcr.io/hassio-addons/base:17.2.1

# Set shell
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk add --no-cache bash curl less vim nginx ca-certificates git tzdata zip openssl openssl-dev ffmpeg \
    libmcrypt-dev zlib-dev gmp-dev \
    freetype-dev libjpeg-turbo-dev libpng-dev \
    php84 php84-fpm php84-json php84-zlib php84-xml php84-xmlwriter php84-simplexml php84-pdo php84-phar php84-openssl \
    php84-pdo_mysql php84-mysqli php84-session php84-imap \
    php84-gd php84-iconv php84-gmp php84-zip \
    php84-curl php84-opcache php84-ctype php84-apcu \
    php84-intl php84-bcmath php84-dom php84-mbstring php84-xmlreader mysql-client && \
    rm -rf /var/cache/apk/*

RUN apk --no-cache add mariadb-client

RUN sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php84/php.ini && \
    sed -i 's/expose_php = On/expose_php = Off/g' /etc/php84/php.ini && \
    sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/usr:\/bin\/bash/g" /etc/passwd && \
    sed -i "s/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/nginx:x:100:101:nginx:\/usr:\/bin\/bash/g" /etc/passwd- && \
    ln -s /sbin/php-fpm84 /sbin/php-fpm

# Copy nginx and php-fpm configuration files
COPY files/nginx.conf /etc/nginx/
COPY files/php-fpm.conf /etc/php84/

# Define the volume and set working directory
VOLUME ["/usr/html"]
WORKDIR /usr/html

# Copy data for the add-on
COPY run.sh /
RUN chmod a+x /run.sh

#musl-locales/php-locales
# RUN apk add --no-cache cmake make musl-dev gcc gettext-dev libintl
# RUN wget https://gitlab.com/rilian-la-te/musl-locales/-/archive/master/musl-locales-master.zip \
#     && unzip musl-locales-master.zip \
#     && cd musl-locales-master \
#     && cmake -DLOCALE_PROFILE=OFF -D CMAKE_INSTALL_PREFIX:PATH=/usr . && make && make install \
#     && cd .. && rm -r musl-locales-master

#Configure Logging
# RUN sed -i -r 's@Errorlog .*@Errorlog /dev/stderr@i' /etc/apache2/httpd.conf
# RUN echo "Transferlog /dev/stdout" >> /etc/apache2/httpd.conf

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Simon Adriaanse" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Simon Adriaanse" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}

COPY index.html /
RUN chmod a+x /index.html

# Expose ports
EXPOSE 8053

# Define the command to run when the container starts
CMD [ "/run.sh" ]