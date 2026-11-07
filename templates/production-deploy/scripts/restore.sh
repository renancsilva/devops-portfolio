#!/usr/bin/env bash
# Restore a backup made by backup.sh:
#   ./scripts/restore.sh /var/backups/app/db-2026-11-07_0230.sql.gz
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
[ -f "${1:-}" ] || { echo "usage: $0 <backup.sql.gz>"; exit 1; }
read -r -p "This will load the dump into database '${POSTGRES_DB}'. Type YES to continue: " ok
[ "$ok" = "YES" ] || exit 1
gzip -cd "$1" | docker compose exec -T db psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -v ON_ERROR_STOP=1
echo "Restore finished."
