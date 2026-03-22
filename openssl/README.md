# Home Assistant Community Add-on: OpenSSL

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license) ![Project Maintenance][maintenance-shield] ![GitHub commit activity (branch)](https://img.shields.io/github/commit-activity/y/simon-adriaanse/hassio-addons/master)

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

Generate self-signed certificates for Homeassistant OS

## About 

This add-on uses OpenSSL to generate self-signed certificates and place them in the `/ssl` folder, making them accessible to other Home Assistant add-ons.

After starting the add-on, the following certificates will be created:

- `/ssl/key_openssl.pem`
- `/ssl/cert_openssl.pem`

If the certificates are about to expire, simply restart the add-on to generate new ones.

> **Warning:** Restarting the add-on will delete and overwrite any existing certificates with the names above.

🔗 [OpenSSL Documentation](https://www.openssl.org/docs/)

[![Buy me a coffee][buymeacoffee-shield]][buymeacoffee]

## Installation

[![CimarronNL Homeassistant Addons](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fsimon-adriaanse%2Fhassio-addons)

## Configuration

Configure the add-on via the **Configuration** tab in the Home Assistant add-on page.

### Options

```yaml
website_name: null
log_level: info
san:
  - homeassistant.local
  - 192.168.1.100
```

| Option | Description |
|---|---|
| `website_name` | The Common Name (CN) for the certificate (e.g. `homeassistant.local`). |
| `san` | *(Optional)* List of Subject Alternative Names. Accepts bare hostnames/IPs (auto-detected) or fully-qualified entries like `DNS:example.com` or `IP:192.168.1.1`. The CN is always included automatically. |
| `log_level` | Log verbosity level. Options: `trace`, `debug`, `info`, `notice`, `warning`, `error`, `fatal`. |

## Support

Got questions or problems?

You can [open an issue here][issue] on GitHub.
This software is tested on aarch64 & amd64.

## Authors & contributors

The original program is from the OpenSSL Project. For more information please visit this page: <https://www.openssl.org/>
The hassio addon is brought to you by [FaserF] and forked + maintained by [simon-adriaanse].

## License

MIT License

Copyright (c) 2019-2025 simon-adriaanse & The OpenSSL Project

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

[maintenance-shield]: https://img.shields.io/maintenance/yes/2025.svg
[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[FaserF]: https://github.com/FaserF/
[simon-adriaanse]: https://github.com/simon-adriaanse/
[issue]: https://github.com/simon-adriaanse/hassio-addons/issues
[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg
[buymeacoffee]: https://buymeacoffee.com/cimarronnl
