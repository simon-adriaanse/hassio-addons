# Dev Container Setup Guide

This guide explains how to set up the development environment, run a local Home Assistant instance, and create a new addon.

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Visual Studio Code](https://code.visualstudio.com/)
- VS Code extension: **Dev Containers** (`ms-vscode-remote.remote-containers`)

---

## Running Home Assistant Locally

1. Open the **addon subfolder** (e.g. `forgejo/`) in VS Code — not the root of the repo.
2. VS Code will detect the `.devcontainer/devcontainer.json` and show a popup:
   > *"Reopen in Container"*

   Accept it. VS Code will build and start the dev container (this may take a few minutes the first time).

3. Once inside the container, open the Command Palette:
   - `Ctrl+Shift+P` (or click the search bar at the top)
   - Type **Run Task** and select it.

4. Select **Start Home Assistant** from the task list.

   This runs `supervisor_run` inside the container, which starts a full Home Assistant Supervisor instance.

5. Open your browser and go to:
   ```
   http://localhost:7123
   ```

   Complete the onboarding wizard to finish setup.

---

## Adding a New Addon

### 1. Set up the subfolder structure

Create a new folder in the root of the repo (e.g. `my-addon/`). Model it after an existing addon like `nginx/` or `forgejo/`. The minimum required structure is:

```
my-addon/
├── .devcontainer/
│   └── devcontainer.json       # Copy from an existing addon
├── .vscode/
│   └── tasks.json              # Copy from an existing addon
├── Dockerfile
├── config.json
└── run.sh
```

### 2. Configure `config.json`

Define your addon metadata, options schema, ports, etc. Example skeleton:

```json
{
  "name": "My Addon",
  "version": "1.0.0",
  "slug": "my-addon",
  "description": "Short description",
  "arch": ["aarch64", "amd64", "armhf", "armv7", "i386"],
  "init": false,
  "options": {},
  "schema": {}
}
```

> **Important:** When developing locally, **remove the `image` line** from `config.json` if it exists. If an `image` is specified, Home Assistant will pull it from the registry instead of building from your local `Dockerfile`.

### 3. Write `run.sh`

Start the script with the correct shebang so the Home Assistant bashio library is available:

```bash
#!/usr/bin/with-contenv bashio

# Read config options (must match keys defined in config.json schema)
my_option=$(bashio::config 'my_option')

bashio::log.info "Starting my addon..."
exec my-binary
```

> **Note:** Only call `bashio::config` for keys that are defined in your `config.json` schema. Calling it for undefined keys causes a fatal error at startup.

### 4. Write `Dockerfile`

Use the Home Assistant addons base image and strip Windows line endings from shell scripts:

```dockerfile
FROM ghcr.io/hassio-addons/base:17.2.1

RUN apk add --no-cache bash

COPY run.sh /
RUN sed -i 's/\r$//' /run.sh && chmod a+x /run.sh

CMD [ "/run.sh" ]
```

The `sed -i 's/\r$//'` line strips Windows-style CRLF line endings that would otherwise prevent Linux from finding `bashio` in the shebang.

### 5. Open the addon folder in VS Code

Open the **addon subfolder** specifically (not the repo root) so VS Code picks up the `.devcontainer` config and offers to reopen in the container.

### 6. Start Home Assistant and install the addon

1. Reopen in the dev container (accept the popup).
2. Run the **Start Home Assistant** task (`Ctrl+Shift+P` → Run Task).
3. Go to `http://localhost:7123` → **Settings** → **Add-ons** → **Add-on Store**.
4. Your local addon will appear under the local repository. Install and start it from there.

---

## Port Mapping

| Local port | Container port | Purpose               |
|------------|----------------|-----------------------|
| 7123       | 8123           | Home Assistant web UI |
| 7357       | 4357           | Supervisor debug port |
