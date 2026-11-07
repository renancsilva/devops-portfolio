#!/usr/bin/env bash
# Daily PostgreSQL backup with retention and optional off-site copy.
# Cron example (02:30 every day):
#   30 2 * * * /opt/app/scripts/backup.sh >> /var/log/app-backup.log 2>&1
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
: "${BACKUP_DIR:?BACKUP_DIR must be set in .env}"

mkdir -p "${BACKUP_DIR}"
file="${BACKUP_DIR}/db-$(date +%F_%H%M).sql.gz"

docker compose exec -T db pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" --no-owner | gzip > "${file}"

# Fail loudly if the dump is empty
if [ "$(gzip -cd "${file}" | head -c 100 | wc -c)" -lt 100 ]; then
  echo "Backup looks empty: ${file}" >&2
  exit 1
fi

# Keep only the last N days of dumps made by this script
find "${BACKUP_DIR}" -maxdepth 1 -name 'db-*.sql.gz' -mtime +"${BACKUP_RETENTION_DAYS}" -delete

if [ -n "${RCLONE_REMOTE:-}" ]; then
  rclone copy "${file}" "${RCLONE_REMOTE}"
fi
echo "$(date -Is) backup ok: ${file}"
