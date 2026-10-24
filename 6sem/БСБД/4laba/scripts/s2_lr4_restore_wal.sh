#!/bin/bash
# =============================================================================
# ЛР4, ЗАДАНИЕ 3 — restore_command (вызывается PostgreSQL при recovery)
# =============================================================================
# Обратно archive_command: openssl dec | gunzip → файл %p в pg_wal
# Путь к архиву: /var/lib/postgresql/archive/%f.gz.enc
# =============================================================================
set -euo pipefail

FNAME="${1:?}"
WALPATH="${2:?}"
ARCHIVE_DIR="${WAL_ARCHIVE_DIR:-/var/lib/postgresql/archive}"
IN="${ARCHIVE_DIR}/${FNAME}.gz.enc"

if [ ! -f "$IN" ]; then
    echo "s2_lr4_restore_wal: archive missing: $IN" >&2
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

mkdir -p "$(dirname "$WALPATH")"
openssl enc -d -aes-256-cbc -pass "pass:${PASS}" -in "$IN" | gunzip -c > "$WALPATH"
exit 0

