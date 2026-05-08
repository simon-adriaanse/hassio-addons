# Immich - Home Assistant Add-on

High performance self-hosted photo and video management solution.

## Features

- Photo and video backup and browsing
- Automatic mobile device backup via the Immich app
- Face recognition and smart search (when machine learning is enabled)
- Shared albums
- PostgreSQL and Redis bundled — no external dependencies

## Configuration

| Option | Description |
|---|---|
| `log_level` | Logging verbosity: `verbose`, `debug`, `log`, `warn`, `error` |
| `machine_learning` | Enable AI features (face detection, smart search). Requires more RAM (~2 GB). |

## Data Storage

All data is persisted under `/share/immich/`:

| Path | Contents |
|---|---|
| `/share/immich/postgres/` | PostgreSQL database files |
| `/share/immich/upload/` | Uploaded photos and videos |
| `/share/immich/ml-cache/` | Downloaded machine learning models |
| `/share/immich/log/` | Service logs |

## Mobile App

Download the **Immich** app on iOS or Android and point it at your Home Assistant URL with the `/api` path, e.g. `https://your-ha-instance.duckdns.org/api/hassio_ingress/<token>`.

For direct access outside of the HA panel, expose port `2283` in the add-on network settings.

## Notes

- First startup takes longer as the database is initialized and migrations run.
- Machine learning models are downloaded on first use (~1–2 GB depending on enabled features).
- Immich version is pinned to the `release` tag of the official images. To upgrade, rebuild the add-on image.
