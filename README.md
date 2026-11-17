# NPM-Docker

The official [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager) image with a node security overlay. When a newer node patch of the same major is out than the one NPM ships, the build replaces NPM's node binary with it. Once upstream catches up, the overlay does nothing. This repo contains only the Dockerfile, the scripts and a build workflow. The upstream code is not forked.

| Image | Tags |
|---|---|
| `ghcr.io/jaytalge/nginx-proxy-manager` | `<version>` (e.g. `2.17.0`), `<minor>` (e.g. `2.17`), `latest` |

## Build

- Every day at 02:27 UTC the workflow takes the newest patch of the **last 3 minor lines** up to the newest GitHub release of NPM.
- A version is rebuilt when it is new or when a newer node patch is out (label `de.jason-talge.build-key` = `<version>/node-<node>`).
- Before pushing, the image is smoke-tested (API status `OK` on :81, nginx answers on :80, version from `/app/package.json`, node not older than the overlay).
- To build manually, use Actions → "Build image from upstream release" → Run workflow. You can enter a specific version and choose "force". A manual version build also moves its `<minor>` tag.
- `/etc/node-overlay` in the image records what the overlay did.

## Usage

```yaml
services:
  app:
    image: ghcr.io/jaytalge/nginx-proxy-manager:2.17   # patch updates via Watchtower, minor bumps by hand
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```
