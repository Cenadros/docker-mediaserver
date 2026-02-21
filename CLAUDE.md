# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A Docker Compose-based home media server stack. All services are defined in a single `docker-compose.yml` and configured via `.env` (copy from `.env.example`).

## Commands

```bash
# Start all services
docker compose up -d

# Start specific service(s)
docker compose up -d sonarr radarr

# Stop all services
docker compose down

# View logs
docker compose logs -f <service>

# Pull latest images for all services
docker compose pull

# Check for image updates (custom script)
./check.sh
```

## Architecture

**Networking:** All services sit behind Traefik (v2.3) reverse proxy on port 80/443. A private subnet `10.2.0.0/24` connects DNS services (Unbound, AdGuard, WireGuard). Services are accessed via `<service>.DOMAIN_NAME` subdomains. Cloudflare handles DDNS and DNS record creation (via `cloudflare-ddns` and `cloudflare-companion`).

**Authentication:** Google OAuth via `traefik-forward-auth`. All Traefik-routed services use the `traefik-forward-auth` middleware. The `oauth` service has per-service rules that allow unauthenticated `/api` access for services that need it (Sonarr, Radarr, etc.) and allow all localhost access. Whitelisted emails are set via `MY_EMAIL`/`MY_EMAIL2`/`MY_EMAIL3`/`MY_EMAIL4` env vars.

**TLS:** Traefik obtains certificates via Let's Encrypt ACME with Cloudflare DNS challenge.

**Service groups:**
- **Media servers:** Plex (`:32400`), Jellyfin (`:8096`)
- **Media management:** Sonarr (TV, `:8989`), Radarr (movies, `:7879→7878`), Bazarr (subtitles, `:6767`), Decluttarr (auto-cleanup)
- **Indexers:** Jackett (`:9117`), Prowlarr (`:9696`), FlareSolverr (`:8191`)
- **Downloads:** qBittorrent (`:8988`)
- **Requests:** Jellyseerr (`:5055`)
- **Books:** Calibre (`:8082`), Calibre-Web (`:8093`)
- **DNS/VPN:** Unbound (`10.2.0.200`), AdGuard Home (`10.2.0.100`, `:5335`), WireGuard (`:51820/udp`)
- **Tools:** Portainer (`:9050`), VS Code Server (`:8443`), FileBrowser (`:8888`), Homarr dashboard (`:7575`), Vaultwarden (`:8092`)
- **Infra:** Watchtower (auto-updates), Cloudflare DDNS, Cloudflare Companion

**Config:** Each service stores its config in `./config/<service>/`. Media paths (MOVIES, TV, ANIME, BOOKS, DOWNLOADS, FILES, BLACKHOLE) are defined as env vars pointing to external directories.

## Key Conventions

- Port mappings sometimes differ from container internal ports (e.g., Radarr host `7879` → container `7878`, Calibre-Web host `8093` → container `8083`). Always check `docker-compose.yml` for actual mappings.
- All LinuxServer.io images use `PUID`/`PGID`/`TZ` environment variables.
- The `.env` file contains secrets and is gitignored. Use `.env.example` as reference.

