#!/bin/bash
# =============================================================================
# ЛР4, ЗАДАНИЕ 1 — archive_command (вызывается PostgreSQL автоматически)
# =============================================================================
# Настроено в docker-compose.yml. При start БД архивирует WAL сама.
# Формула: gzip | openssl enc -aes-256-cbc → /var/lib/postgresql/archive/%f.gz.enc
# Пароль: secrets/wal_archive_pass.txt (монтируется read-only)
# =============================================================================
set -euo pipefail

FNAME="${1:?}"
WALPATH="${2:?}"
ARCHIVE_DIR="${WAL_ARCHIVE_DIR:-/var/lib/postgresql/archive}"
OUT="${ARCHIVE_DIR}/${FNAME}.gz.enc"

if [ ! -r "$WALPATH" ]; then
    echo "s2_lr4_archive_wal: WAL not readable: $WALPATH" >&2
    exit 1
fi

PASS_FILE="${WAL_ARCHIVE_PASS_FILE:-/var/lib/postgresql/secrets/wal_archive_pass.txt}"
if [ -n "${WAL_ARCHIVE_PASS:-}" ]; then
    PASS="$WAL_ARCHIVE_PASS"
elif [ -r "$PASS_FILE" ]; then
    PASS="$(tr -d '\r\n' < "$PASS_FILE")"
else
    PASS="MySecretPassword"
fi

mkdir -p "$ARCHIVE_DIR"
gzip -c "$WALPATH" | openssl enc -aes-256-cbc -salt -pass "pass:${PASS}" -out "$OUT"
exit 0
