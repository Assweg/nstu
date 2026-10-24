#!/bin/bash
# =============================================================================
# ЛР4, ЗАДАНИЕ 3 — ручной PITR (НЕ запускается при ./run_docker.sh start)
# =============================================================================
# Запускать ТОЛЬКО после полного задания 2 (backup → before → пауза → disaster).
#
# Использование:
#   ./scripts/s2_lr4_task3.sh recover   — остановка, развёртывание base backup,
#                                           recovery.signal, restore_command
#   ./scripts/s2_lr4_task3.sh start       — поднять контейнер (идёт восстановление WAL)
#   ./scripts/s2_lr4_task3.sh verify      — проверка SQL (s2_lr4_03_pitr_verify.sql)
#   ./scripts/s2_lr4_task3.sh all        — recover + start + verify подряд
#
# Для отчёта удобно выполнять по шагам и делать скриншот после каждого.
# =============================================================================

set -euo pipefail

CONTAINER="${S2_LR4_CONTAINER:-dubbing_studio_postgres}"
DB="${S2_LR4_DB:-dubbing_studio}"
PITR_DIR="/var/lib/postgresql/pitr"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
ok() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

psql_exec() {
    docker exec "$CONTAINER" psql -U postgres -d "$DB" "$@"
}

# Блок команды recover: остановка БД, запуск скрипта подготовки PITR 
#(восстановление из бэкапа + настройка recovery)
cmd_recover() {
    if ! docker exec "$CONTAINER" test -f "${PITR_DIR}/recovery_target_time.txt" 2>/dev/null; then
        # контейнер может быть остановлен — проверим через run
        :
    fi
    info "Задание 3, п.1: остановка PostgreSQL (docker-compose stop)"
    docker-compose stop dubbing-studio-db

    info "Задание 3, п.2–3: PGDATA из base backup + recovery.signal + restore_command"
    docker compose run --rm --no-deps -u postgres dubbing-studio-db \
        /usr/local/bin/s2_lr4_pitr_recover.sh

    ok "PGDATA подготовлен. Для отчёта:"
    echo "  docker compose run --rm dubbing-studio-db cat /var/lib/postgresql/data/conf.d/99-pitr-recovery.conf"
    warn "Сервер ещё НЕ запущен. Далее: ./scripts/s2_lr4_task3.sh start"
}

cmd_start() {
    info "Задание 3, п.4: запуск PostgreSQL (режим recovery → promote)"
    docker-compose up -d dubbing-studio-db

    info "Ожидание окончания recovery (до 3 мин)..."
    local i
    for i in $(seq 1 90); do
        if docker exec "$CONTAINER" pg_isready -U postgres -d "$DB" >/dev/null 2>&1; then
            if psql_exec -tAc "SELECT pg_is_in_recovery();" 2>/dev/null | grep -q f; then
                ok "Сервер вышел из recovery (promote выполнен)"
                return 0
            fi
        fi
        sleep 2
    done
    err "Таймаут recovery. Смотрите: docker-compose logs dubbing-studio-db"
}

cmd_verify() {
    docker exec "$CONTAINER" pg_isready -U postgres -d "$DB" >/dev/null 2>&1 || err "БД не запущена. Сначала: ./scripts/s2_lr4_task3.sh start"

    info "Задание 3, п.4: проверка данных и логов"
    info "pg_is_in_recovery (должно быть f):"
    psql_exec -tAc "SELECT pg_is_in_recovery();"

    local remote="/tmp/s2_lr4_03_pitr_verify.sql"
    docker cp "$PROJECT_ROOT/s2_lr4_03_pitr_verify.sql" "${CONTAINER}:${remote}"
    psql_exec -f "$remote"

    ok "Проверка завершена. Скриншот для отчёта:"
    echo "  docker exec $CONTAINER psql -U postgres -d $DB -c \"SELECT * FROM pitr_lab.important_data;\""
}

cmd_all() {
    cmd_recover
    cmd_start
    cmd_verify
}

usage() {
    cat <<EOF
ЛР4 — задание 3 (ручной запуск)

  ./scripts/s2_lr4_task3.sh recover   — п.1–3 ТЗ: stop + подготовка PITR
  ./scripts/s2_lr4_task3.sh start     — п.4: запуск и ожидание promote
  ./scripts/s2_lr4_task3.sh verify    — п.4: проверка important_data
  ./scripts/s2_lr4_task3.sh all       — все шаги подряд

Перед recover обязательно завершите задание 2!

EOF
}

case "${1:-}" in
    recover) cmd_recover ;;
    start)   cmd_start ;;
    verify)  cmd_verify ;;
    all)     cmd_all ;;
    *)       usage; exit 1 ;;
esac
