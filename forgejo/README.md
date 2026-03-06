# Home Assistant Add-on: Forgejo

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license) ![Project Maintenance][maintenance-shield] ![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/y/simon-adriaanse/hassio-addons/master)

## About

Self-hosted lightweight software forge. A community-managed Gitea fork.

🔗 [Nginx Documentation](https://nginx.org)

[![Buy me a coffee][buymeacoffee-shield]][buymeacoffee]

## Installation

1. Add this repository to your Home Assistant Add-on store.
2. Install the **Forgejo** add-on.
3. Configure the add-on (see options below).
4. Start the add-on.
5. Open the web UI via Ingress or at `http://<ha-ip>:3000`.
6. Complete the initial setup wizard on first launch.

## Configuration

| Option | Required | Description |
|--------|----------|-------------|
| `domain` | No | The public domain name for your Forgejo instance (e.g. `git.example.com`). Used to generate clone URLs. Leave empty to use the IP address. |
| `ssh_port` | Yes | The external SSH port for git operations. Default: `22`. |
| `ssl` | Yes | Enable HTTPS. Requires `certfile` and `keyfile`. Default: `false`. |
| `certfile` | No | SSL certificate file name from the `/ssl` directory. Default: `fullchain.pem`. |
| `keyfile` | No | SSL private key file name from the `/ssl` directory. Default: `privkey.pem`. |

## Data Storage

All Forgejo data (repositories, configuration, uploads) is stored in `/share/forgejo` and persists across add-on restarts and updates.

## Ports

| Port | Description |
|------|-------------|
| `3000/tcp` | Web interface (not required when using Ingress) |
| `22/tcp` | SSH for git push/pull operations |

## Notes

- On first start, Forgejo will present an installation wizard to configure the database, admin account, and other settings.
- The built-in SQLite3 database is used by default and requires no additional setup.
- For SSH git access, map port `22` in the add-on network settings.

## Support

Got questions or problems?

You can [open an issue here][issue] GitHub.
This software is tested on a Raspberry Pi 5 [aarch64] & ASUS TUF Laptop [amd64].

## Authors & contributors

The original program is from the Nginx Project. For more information please visit this page: <https://nginx.org>
The hassio addon is brought to you by [simon-adriaanse].

## License

MIT License

Copyright (c) 2019-2025 simon-adriaanse & The Nginx Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[maintenance-shield]: https://img.shields.io/maintenance/yes/2026.svg
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[simon-adriaanse]: https://github.com/simon-adriaanse/
[issue]: https://github.com/simon-adriaanse/hassio-addons/issues
[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg
[buymeacoffee]: https://buymeacoffee.com/cimarronnl
