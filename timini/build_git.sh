#!/bin/sh
# docker run \
#   --rm \
#   -it \
#   --name builder \
#   --privileged \
#   -v /workspaces/hassio-addons/timini:/data \
#   -v /var/run/docker.sock:/var/run/docker.sock:ro \
#   ghcr.io/home-assistant/amd64-builder \
#     -t /data \
#     --all \
#     --test \
#     -i timini-{arch} \
#     -d local


docker run \
  --rm \
  --privileged \
  -it \
  --name hassio_builder \
  -v /mnt/supervisor/addons/local/timini:/data \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ghcr.io/home-assistant/amd64-builder:latest \
    --target /data \
    --test \
    --all \
    --image timini \
    -d local

