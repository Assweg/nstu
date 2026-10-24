#!/bin/bash
# =============================================================================
# ЛР4, ЗАДАНИЕ 3 — подготовка PGDATA (п.2–3 ТЗ)
# =============================================================================
# Вызывается из: ./scripts/s2_lr4_task3.sh recover
# Не запускайте при ./run_docker.sh start — только вручную после задания 2.
#
# Делает:
#   1) Копию «сломанного» PGDATA в data_broken_<timestamp>
#   2) Очистку PGDATA и внешнего WAL
#   3) Развёртывание base backup из /var/lib/postgresql/backup/base
#   4) recovery.signal + conf.d/99-pitr-recovery.conf (restore_command, target_time, promote)
# =============================================================================
set -euo pipefail

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
WALDIR="${PGWALDIR:-/var/lib/postgresql/wal}"
BACKUP_DIR="${BACKUP_DIR:-/var/lib/postgresql/backup/base}"
PITR_DIR="${PITR_DIR:-/var/lib/postgresql/pitr}"
TARGET_FILE="${PITR_DIR}/recovery_target_time.txt"

if [ ! -f "$TARGET_FILE" ]; then
    echo "[ERROR] Не найден $TARGET_FILE (сначала выполните шаг «до аварии» задания 2)" >&2
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
    echo "[ERROR] Базовый бэкап пуст: $BACKUP_DIR" >&2
    exit 1
fi

TARGET_TIME="$(tr -d '\r\n' < "$TARGET_FILE")"
if [ -z "$TARGET_TIME" ]; then
    echo "[ERROR] Пустое recovery_target_time" >&2
    exit 1
fi

if [ -d "$WALDIR" ] && [ -n "$(ls -A "$WALDIR" 2>/dev/null || true)" ]; then
    echo "[INFO] Очистка внешнего WAL: $WALDIR"
    find "$WALDIR" -mindepth 1 -delete 2>/dev/null || rm -rf "${WALDIR:?}"/*
fi

if [ -d "$PGDATA" ] && [ -n "$(ls -A "$PGDATA" 2>/dev/null || true)" ]; then
    BROKEN="${PGDATA}_broken_$(date +%Y%m%d%H%M%S)"
    echo "[INFO] Сохранение снимка повреждённого кластера в $BROKEN"
    mkdir -p "$BROKEN"
    cp -a "${PGDATA}/." "${BROKEN}/"
    echo "[INFO] Очистка PGDATA"
    find "$PGDATA" -mindepth 1 -delete 2>/dev/null || rm -rf "${PGDATA:?}"/*
fi

# Развёртывание base backup из $BACKUP_DIR
mkdir -p "$PGDATA"
echo "[INFO] Развёртывание base backup из $BACKUP_DIR"
cp -a "${BACKUP_DIR}/." "${PGDATA}/"

touch "${PGDATA}/recovery.signal"

mkdir -p "${PGDATA}/conf.d"
cat > "${PGDATA}/conf.d/99-pitr-recovery.conf" <<EOF
# S2 LR4: point-in-time recovery из зашифрованных WAL-архивов
restore_command = '/usr/local/bin/s2_lr4_restore_wal.sh %f %p'
recovery_target_time = '${TARGET_TIME}'
recovery_target_action = 'promote'
EOF

if [ -f "${PGDATA}/postgresql.conf" ] && ! grep -qE "^[[:space:]]*include_dir[[:space:]]*=[[:space:]]*'conf.d'" "${PGDATA}/postgresql.conf"; then
    echo "include_dir = 'conf.d'" >> "${PGDATA}/postgresql.conf"
fi

chown -R postgres:postgres "$PGDATA" 2>/dev/null || true
echo "[INFO] recovery_target_time = ${TARGET_TIME}"
