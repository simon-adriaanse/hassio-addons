FROM golang:1.25-alpine AS builder

RUN apk add --no-cache make gcc musl-dev git nodejs npm

RUN git clone https://codeberg.org/forgejo/forgejo.git /tmp/forgejo && \
    cd /tmp/forgejo && \
    make build && \
    find . -name "forgejo" -type f -executable 2>/dev/null && \
    ls -la

FROM ghcr.io/hassio-addons/base:17.2.1

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install dependencies
RUN apk add --no-cache bash curl git openssh su-exec tzdata

# Copy built binary from builder stage
COPY --from=builder /tmp/forgejo/forgejo /usr/local/bin/forgejo
RUN chmod +x /usr/local/bin/forgejo

# Create git user for Forgejo (UID/GID 1000)
RUN addgroup -S -g 1000 git && \
    adduser -S -u 1000 -G git -h /home/git -s /bin/bash git && \
    mkdir -p /home/git/.ssh && \
    chmod 700 /home/git/.ssh && \
    chown -R git:git /home/git

# Copy data for the add-on
COPY run.sh /
RUN sed -i 's/\r$//' /run.sh && chmod a+x /run.sh

# Build arguments
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

# Expose ports
EXPOSE 3000 22

# Define the command to run when the container starts
CMD [ "/run.sh" ]
