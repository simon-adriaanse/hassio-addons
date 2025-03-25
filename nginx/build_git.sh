#!/bin/sh
docker run \
  --rm \
  -it \
  --name builder \
  --privileged \
  -v /workspaces/hassio-addons/nginx:/data \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  ghcr.io/home-assistant/amd64-builder \
    -t /data \
    --all \
    --test \
    -i nginx-{arch} \
    -d local