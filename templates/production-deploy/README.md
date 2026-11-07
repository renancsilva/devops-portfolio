# Production deploy template

A small, production-ready stack for a single Linux VPS: your app in Docker, PostgreSQL,
Nginx with free Let's Encrypt HTTPS, automatic certificate renewal, daily backups,
server hardening, CI/CD from GitHub and optional monitoring.

```
Users ──HTTPS──> Nginx (TLS, security headers) ──> app (Docker) ──> PostgreSQL (private network)
                    ▲                                                     │
              Certbot renews                                   backup.sh → local + off-site
```

## What's inside

| Path | Purpose |
|---|---|
| `docker-compose.yml` | app, PostgreSQL, Nginx, Certbot |
| `nginx/templates/default.conf.template` | HTTP→HTTPS redirect, TLS 1.2/1.3, HSTS and security headers, websocket support |
| `scripts/harden.sh` | UFW firewall, fail2ban, automatic security updates, SSH keys only |
| `scripts/init-ssl.sh` | first Let's Encrypt certificate (renewal is automatic afterwards) |
| `scripts/backup.sh` / `restore.sh` | compressed PostgreSQL dumps with retention and optional rclone off-site copy |
| `.github/workflows/deploy.yml` | deploy on push to `main`, then smoke test |
| `monitoring/` | Prometheus, node-exporter, cAdvisor, Grafana (localhost only) and basic alerts |
| `app/` | tiny example app so the stack runs immediately; replace it with yours |

## Quick start

```bash
# 1. On a fresh Ubuntu server (as root), after adding your SSH key
./scripts/harden.sh

# 2. Install Docker, then copy this folder to /opt/app
cp .env.example .env        # set DOMAIN, email and a strong DB password

# 3. Point your domain's A record to the server, then get HTTPS
./scripts/init-ssl.sh
docker compose up -d

# 4. Daily backups at 02:30
( crontab -l 2>/dev/null; echo "30 2 * * * /opt/app/scripts/backup.sh >> /var/log/app-backup.log 2>&1" ) | crontab -

# 5. Optional monitoring
docker compose -f docker-compose.yml -f monitoring/docker-compose.monitoring.yml up -d
```

## Design choices

- **Database never exposed:** PostgreSQL has no published port; only the app reaches it.
- **Only 80/443 open:** everything else stays inside Docker networks or on localhost.
- **Grafana on localhost:** reached through an SSH tunnel instead of the public internet.
- **Backups are checked:** the script fails if a dump comes out empty, and old dumps are pruned.
- **Boring, well-known tools:** easy for the next person to maintain.
