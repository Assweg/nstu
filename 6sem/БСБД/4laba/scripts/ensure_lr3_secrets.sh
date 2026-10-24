#!/bin/bash
# Копирует шаблоны ключей в каталог secrets/ (не попадает в git), если файлов ещё нет.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_DIR="$PROJECT_ROOT/secrets"
EXAMPLE_DIR="$PROJECT_ROOT/secrets.example"

if [ ! -d "$EXAMPLE_DIR" ]; then
    echo "[ERROR] Не найден каталог secrets.example" >&2
    exit 1
fi

mkdir -p "$SECRETS_DIR"

for f in lr3_sym_key.txt lr3_master_kek.txt lr3_pgp_public.asc lr3_pgp_private.asc wal_archive_pass.txt; do
    if [ ! -f "$SECRETS_DIR/$f" ]; then
        cp "$EXAMPLE_DIR/$f" "$SECRETS_DIR/$f"
        chmod 600 "$SECRETS_DIR/$f"
        echo "[INFO] Создан $SECRETS_DIR/$f из шаблона"
    fi
done

chmod 700 "$SECRETS_DIR" 2>/dev/null || true
