FROM ghcr.io/hassio-addons/base:18.0.3

RUN apk add --no-cache python3

COPY files/ /app/www
COPY run.sh /run.sh
RUN chmod +x /run.sh


# ARG BUILD_FROM
# FROM $BUILD_FROM
# FROM ghcr.io/hassio-addons/base:18.0.3

# ENV LANG=C.UTF-8

# # Install Node.js and dependencies
# RUN apk add --no-cache \
#     nodejs \
#     npm \
#     python3 \
#     make \
#     g++ \
#     libstdc++

# # Copy app
# COPY files/ /app
# WORKDIR /app

# # Install app dependencies
# RUN npm install

# # Copy run script
# COPY run.sh /run.sh
# RUN chmod a+x /run.sh

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

# Expose the port your app runs on
EXPOSE 3000

# Start the app
# CMD ["node", "app.js"]
CMD [ "/run.sh" ]