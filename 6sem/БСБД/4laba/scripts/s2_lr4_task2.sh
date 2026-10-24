#!/bin/bash
# =============================================================================
# ЛР4, ЗАДАНИЕ 2 — ручной сценарий (НЕ запускается при ./run_docker.sh start)
# =============================================================================
# Использование:
#   ./scripts/s2_lr4_task2.sh backup    — шаг 1 ТЗ: pg_basebackup
#   ./scripts/s2_lr4_task2.sh before    — шаг 2: SQL «до аварии» + сохранение времени
#   ./scripts/s2_lr4_task2.sh disaster  — шаг 3: SQL «авария» (после паузы 1–2 мин)
#   ./scripts/s2_lr4_task2.sh status    — что сейчас в таблице и в recovery_target_time.txt
#
# Полный порядок для отчёта:
#   1) ./run_docker.sh start
#   2) ./scripts/s2_lr4_task2.sh backup
#   3) ./scripts/s2_lr4_task2.sh before
#   4) подождать 60–120 секунд (можно засечь таймер — скрин в отчёт)
#   5) ./scripts/s2_lr4_task2.sh disaster
# =============================================================================

set -euo pipefail

CONTAINER="${S2_LR4_CONTAINER:-dubbing_studio_postgres}"
DB="${S2_LR4_DB:-dubbing_studio}"
BACKUP_DIR="/var/lib/postgresql/backup/base"
PITR_DIR="/var/lib/postgresql/pitr"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
ok() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

need_container() {
    docker ps --format '{{.Names}}' | grep -qx "$CONTAINER" || err "Контейнер $CONTAINER не запущен. Выполните: ./run_docker.sh start"
}

psql_exec() {
    docker exec "$CONTAINER" psql -U postgres -d "$DB" "$@"
}

run_sql_file() {
    local local_file="$1"
    local remote="/tmp/$(basename "$local_file")"
    docker cp "$local_file" "${CONTAINER}:${remote}"
    psql_exec -f "$remote"
}

# Блок команды backup: создание базовой резервной копии через pg_basebackup
cmd_backup() {
    need_container
    info "Задание 2, п.1: pg_basebackup → ${BACKUP_DIR}"
    docker exec "$CONTAINER" sh -c "mkdir -p '${BACKUP_DIR}' '${PITR_DIR}'"
    # При data_checksums=on (задание 1) контрольные суммы страниц проверяются при чтении
    docker exec -u postgres "$CONTAINER" pg_basebackup \
        -D "$BACKUP_DIR" \
        -U postgres \
        -Fp -Xs -P \
        --checkpoint=fast
    ok "Бэкап создан. Для отчёта: docker exec $CONTAINER ls -la $BACKUP_DIR | head"
}

# Блок команды before: вставка «хороших» данных, сохранение времени до аварии
cmd_before() {
    need_container
    info "Задание 2, п.2: контрольная запись и recovery_target_time"
    run_sql_file "$PROJECT_ROOT/s2_lr4_02_before_disaster.sql"
    local target
    target=$(psql_exec -tAc "SELECT now();" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    docker exec "$CONTAINER" sh -c "mkdir -p '${PITR_DIR}' && printf '%s\n' '${target}' > '${PITR_DIR}/recovery_target_time.txt'"
    ok "Время сохранено в ${PITR_DIR}/recovery_target_time.txt"
    echo "    recovery_target_time = ${target}"
    warn "Подождите 1–2 минуты, затем: ./scripts/s2_lr4_task2.sh disaster"
}

# Блок команды disaster: удаление таблицы и вставка «плохих» данных (имитация аварии)
cmd_disaster() {
    need_container
    if ! docker exec "$CONTAINER" test -f "${PITR_DIR}/recovery_target_time.txt"; then
        err "Сначала выполните: ./scripts/s2_lr4_task2.sh before"
    fi
    info "Задание 2, п.3: имитация инцидента"
    run_sql_file "$PROJECT_ROOT/s2_lr4_02_disaster.sql"
    ok "Авария смоделирована. Для отчёта сделайте SELECT * FROM pitr_lab.important_data"
    warn "Далее задание 3: ./scripts/s2_lr4_task3.sh"
}

# Блок команды status: отображение сохранённого времени и текущего состояния таблицы
cmd_status() {
    need_container
    info "recovery_target_time.txt:"
    docker exec "$CONTAINER" cat "${PITR_DIR}/recovery_target_time.txt" 2>/dev/null || warn "файл ещё не создан (запустите before)"
    info "Текущие данные important_data:"
    psql_exec -c "SELECT * FROM pitr_lab.important_data;" 2>/dev/null || warn "таблица pitr_lab.important_data отсутствует"
}

usage() {
    cat <<EOF
ЛР4 — задание 2 (ручной запуск, не при init БД)

  ./scripts/s2_lr4_task2.sh backup     — pg_basebackup
  ./scripts/s2_lr4_task2.sh before     — данные «до аварии» + файл времени
  ./scripts/s2_lr4_task2.sh disaster   — DROP + «после аварии» (после паузы!)
  ./scripts/s2_lr4_task2.sh status     — проверка состояния

EOF
}

case "${1:-}" in
    backup)   cmd_backup ;;
    before)   cmd_before ;;
    disaster) cmd_disaster ;;
    status)   cmd_status ;;
    *)        usage; exit 1 ;;
esac
