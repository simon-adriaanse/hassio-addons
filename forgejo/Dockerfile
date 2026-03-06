FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl git jq openssh-server tzdata ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download Forgejo binary for the correct architecture
ARG BUILD_ARCH
RUN case "${BUILD_ARCH}" in \
        amd64)   FORGEJO_ARCH="amd64"  ;; \
        aarch64) FORGEJO_ARCH="arm64"  ;; \
        armhf)   FORGEJO_ARCH="arm-6"  ;; \
        armv7)   FORGEJO_ARCH="arm-7"  ;; \
        i386)    FORGEJO_ARCH="386"    ;; \
        *) echo "Unsupported arch: ${BUILD_ARCH}" && exit 1 ;; \
    esac && \
    curl -sSLf -o /usr/local/bin/forgejo \
        "https://codeberg.org/forgejo/forgejo/releases/download/v9.0.3/forgejo-9.0.3-linux-${FORGEJO_ARCH}" && \
    chmod +x /usr/local/bin/forgejo

# Create git user for Forgejo (UID/GID 1000)
RUN groupadd -g 1000 git && \
    useradd -m -u 1000 -g git -s /bin/bash git && \
    mkdir -p /home/git/.ssh && \
    chmod 700 /home/git/.ssh && \
    chown -R git:git /home/git

# Copy data for the add-on
COPY run.sh /
RUN chmod a+x /run.sh

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
