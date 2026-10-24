#!/bin/bash

# Скрипт для управления Docker контейнером базы данных студии дубляжа

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Функция для проверки Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker не установлен. Установите Docker и попробуйте снова."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose не установлен. Установите Docker Compose и попробуйте снова."
        exit 1
    fi
}

# Подготовка каталога secrets для ЛР3 (вне БД, монтируется в контейнер)
ensure_lr3_secrets() {
    if [ -f "./scripts/ensure_lr3_secrets.sh" ]; then
        bash ./scripts/ensure_lr3_secrets.sh
    else
        print_warning "scripts/ensure_lr3_secrets.sh не найден — создайте каталог secrets/ вручную из secrets.example/"
    fi
}

# Функция для запуска контейнера
start_container() {
    print_message "Запуск контейнера базы данных студии дубляжа..."

    ensure_lr3_secrets
    
    # Собираем образ
    print_message "Сборка Docker образа..."
    docker-compose build
    
    # Запускаем контейнер
    print_message "Запуск контейнера..."
    docker-compose up -d
    
    # Ждём готовности
    print_message "Ожидание готовности базы данных..."
    sleep 10
    
    # Проверяем статус
    if docker-compose ps | grep -q "Up"; then
        print_success "Контейнер успешно запущен!"
        
        # Инициализируем базу данных
        print_message "Инициализация базы данных..."
        if [ -f "./init_database.sh" ]; then
            ./init_database.sh
            print_success "База данных инициализирована!"
        else
            print_warning "Скрипт инициализации не найден. Выполните инициализацию вручную."
        fi
        
        # Автоматически запускаем ЛР1 (семестр 2), если она ещё не применена
        init_s2_lr1_if_needed
        # Автоматически запускаем ЛР3 (семестр 2), если она ещё не применена
        init_s2_lr3_if_needed
        
        print_message "Подключение к БД:"
        print_message "  Host: localhost"
        print_message "  Port: 5432"
        print_message "  Database: dubbing_studio"
        print_message "  User: postgres"
        print_message "  Password: secure_password_123"
        print_message ""
        print_message "Команды для подключения:"
        print_message "  psql -h localhost -U postgres -d dubbing_studio"
        print_message "  docker exec -it dubbing_studio_postgres psql -U postgres -d dubbing_studio"
        print_message ""
        print_success "pgAdmin доступен по адресу: http://localhost:5050"
        print_message "  Email: admin@dubbing.studio"
        print_message "  Password: admin123"
        print_message "  (База данных уже настроена и готова к использованию)"
    else
        print_error "Ошибка запуска контейнера!"
        docker-compose logs
        exit 1
    fi
}

# Функция для остановки контейнера
stop_container() {
    print_message "Остановка контейнера..."
    docker-compose down
    print_success "Контейнер остановлен!"
}

# Функция для перезапуска контейнера
restart_container() {
    print_message "Перезапуск контейнера..."
    docker-compose down
    docker-compose up -d
    print_success "Контейнер перезапущен!"
}

# Функция для просмотра логов
view_logs() {
    print_message "Просмотр логов контейнера..."
    docker-compose logs -f
}

# Функция для подключения к БД
connect_db() {
    print_message "Подключение к базе данных..."
    docker exec -it dubbing_studio_postgres psql -U postgres -d dubbing_studio
}

# Функция для автоматической инициализации ЛР1 (семестр 2)
init_s2_lr1_if_needed() {
    print_message "Проверка инициализации ЛР1 (семестр 2)..."

    if ! docker-compose ps | grep -q "Up"; then
        print_error "Контейнер не запущен! Сначала запустите контейнер: $0 start"
        exit 1
    fi

    S2_READY=$(docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -t -c "
        SELECT COUNT(*)
        FROM information_schema.tables
        WHERE table_schema = 'app'
          AND table_name = 'orders_partitioned';
    " | tr -d ' ')

    if [ "$S2_READY" -ge 1 ]; then
        print_success "ЛР1 (семестр 2) уже инициализирована. Пропускаем повторный запуск."
        return 0
    fi

    if [ ! -f "./s2_lr1_00_init_all.sql" ] || [ ! -f "./s2_lr1_01_model_and_data.sql" ] || [ ! -f "./s2_lr1_02_partitioning.sql" ] || [ ! -f "./s2_lr1_03_metrics.sql" ] || [ ! -f "./s2_lr1_04_decisions.sql" ]; then
        print_warning "Не найдены все файлы ЛР1 семестра 2, автозапуск пропущен."
        return 0
    fi

    print_message "Запуск ЛР1 (семестр 2) внутри контейнера..."
    docker cp s2_lr1_01_model_and_data.sql dubbing_studio_postgres:/tmp/s2_lr1_01_model_and_data.sql
    docker cp s2_lr1_02_partitioning.sql dubbing_studio_postgres:/tmp/s2_lr1_02_partitioning.sql
    docker cp s2_lr1_03_metrics.sql dubbing_studio_postgres:/tmp/s2_lr1_03_metrics.sql
    docker cp s2_lr1_04_decisions.sql dubbing_studio_postgres:/tmp/s2_lr1_04_decisions.sql

    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr1_01_model_and_data.sql
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr1_02_partitioning.sql
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr1_03_metrics.sql
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr1_04_decisions.sql
    print_success "ЛР1 (семестр 2) успешно инициализирована."
}

# Функция для автоматической инициализации ЛР3 (семестр 2)
init_s2_lr3_if_needed() {
    print_message "Проверка инициализации ЛР3 (семестр 2)..."

    if ! docker-compose ps | grep -q "Up"; then
        print_error "Контейнер не запущен! Сначала запустите контейнер: $0 start"
        exit 1
    fi

    LR3_READY=$(docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -t -c "
        SELECT CASE
            WHEN EXISTS (
                SELECT 1
                FROM information_schema.columns
                WHERE table_schema = 'app'
                  AND table_name = 'actors'
                  AND column_name = 'passport_data_enc'
            )
            AND EXISTS (
                SELECT 1
                FROM pg_proc p
                JOIN pg_namespace n ON n.oid = p.pronamespace
                WHERE n.nspname = 'key_store'
                  AND p.proname = 'read_secret'
            )
            AND EXISTS (
                SELECT 1
                FROM key_store.crypto_materials
                WHERE key_name = 'lr3_sym_key'
                  AND key_value IS NULL
                  AND storage_location LIKE 'docker-secrets:%'
            )
            AND (
                SELECT COUNT(*)
                FROM pg_authid a
                JOIN pg_roles r ON r.oid = a.oid
                WHERE r.rolname IN ('studio_manager', 'voice_actor', 'security_auditor', 'app_owner_user')
                  AND a.rolpassword LIKE 'SCRAM-SHA-256%'
            ) = 4
            THEN 1 ELSE 0
        END;
    " | tr -d ' ')

    if [ "$LR3_READY" -eq 1 ]; then
        print_success "ЛР3 (семестр 2) уже инициализирована. Пропускаем повторный запуск."
        return 0
    fi

    if [ ! -f "./s2_lr3_01_password_encryption.sql" ] || [ ! -f "./s2_lr3_02_column_encryption.sql" ] || [ ! -f "./s2_lr3_03_key_management.sql" ] || [ ! -f "./s2_lr3_04_performance.sql" ] || [ ! -f "./s2_lr3_05_conclusions.sql" ]; then
        print_warning "Не найдены все файлы ЛР3 семестра 2, автозапуск пропущен."
        return 0
    fi

    ensure_lr3_secrets

    print_message "Запуск ЛР3 (семестр 2) внутри контейнера..."
    docker cp s2_lr3_01_password_encryption.sql dubbing_studio_postgres:/tmp/s2_lr3_01_password_encryption.sql
    docker cp s2_lr3_03_key_management.sql dubbing_studio_postgres:/tmp/s2_lr3_03_key_management.sql
    docker cp s2_lr3_02_column_encryption.sql dubbing_studio_postgres:/tmp/s2_lr3_02_column_encryption.sql
    docker cp s2_lr3_04_performance.sql dubbing_studio_postgres:/tmp/s2_lr3_04_performance.sql
    docker cp s2_lr3_05_conclusions.sql dubbing_studio_postgres:/tmp/s2_lr3_05_conclusions.sql

    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr3_01_password_encryption.sql
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr3_03_key_management.sql
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr3_02_column_encryption.sql
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr3_04_performance.sql
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/s2_lr3_05_conclusions.sql
    print_success "ЛР3 (семестр 2) успешно инициализирована."
}

# Функция для инициализации БД
init_database() {
    print_message "Инициализация базы данных..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Контейнер не запущен! Сначала запустите контейнер: $0 start"
        exit 1
    fi
    
    if [ -f "./init_database.sh" ]; then
        ./init_database.sh
        print_success "База данных инициализирована!"
        init_s2_lr1_if_needed
    else
        print_error "Скрипт инициализации не найден!"
        exit 1
    fi
}

# Функция для запуска тестов ролей
run_role_tests() {
    print_message "Запуск тестов ролей..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Контейнер не запущен! Сначала запустите контейнер: $0 start"
        exit 1
    fi
    
    if [ -f "./role_testing_scenarios.sql" ]; then
        # Копируем файл в контейнер
        docker cp role_testing_scenarios.sql dubbing_studio_postgres:/tmp/role_testing_scenarios.sql
        
        # Запускаем тесты
        docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/role_testing_scenarios.sql
        
        print_success "Тесты ролей выполнены!"
    else
        print_error "Файл role_testing_scenarios.sql не найден!"
        exit 1
    fi
}

# Функция для инициализации ЛР2
init_lr2() {
    print_message "Инициализация Лабораторной работы №2..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Контейнер не запущен! Сначала запустите контейнер: $0 start"
        exit 1
    fi
    
    if [ -f "./init_lr2.sh" ]; then
        ./init_lr2.sh
        print_success "Лабораторная работа №2 инициализирована!"
    else
        print_error "Скрипт init_lr2.sh не найден!"
        exit 1
    fi
}

# Функция для запуска тестов ЛР2
run_lr2_tests() {
    print_message "Запуск тестов ЛР2..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Контейнер не запущен! Сначала запустите контейнер: $0 start"
        exit 1
    fi
    
    # Проверяем, что функции ЛР2 созданы
    print_message "Проверка наличия функций ЛР2..."
    FUNCTION_COUNT=$(docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -t -c "
        SELECT COUNT(*) 
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'app'
          AND p.proname IN ('create_contract', 'update_contract_salary', 'register_recording_session')
          AND p.prosecdef = true;
    " | tr -d ' ')
    
    if [ "$FUNCTION_COUNT" -lt 3 ]; then
        print_warning "Функции ЛР2 не найдены! Инициализация ЛР2..."
        if [ -f "./init_lr2.sh" ]; then
            ./init_lr2.sh
        else
            print_error "Скрипт init_lr2.sh не найден! Выполните инициализацию вручную: $0 init-lr2"
            exit 1
        fi
    else
        print_success "Функции ЛР2 найдены ($FUNCTION_COUNT из 3)"
    fi
    
    if [ -f "./lr2_04_tests.sql" ]; then
        docker cp lr2_04_tests.sql dubbing_studio_postgres:/tmp/lr2_04_tests.sql
        docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/lr2_04_tests.sql
        print_success "Тесты ЛР2 выполнены!"
    else
        print_error "Файл lr2_04_tests.sql не найден!"
        exit 1
    fi
}

# Функция для теста производительности ЛР2
run_lr2_performance() {
    print_message "Запуск теста производительности ЛР2 (CHECK vs триггер)..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Контейнер не запущен! Сначала запустите контейнер: $0 start"
        exit 1
    fi
    
    if [ -f "./lr2_06_performance_test.sql" ]; then
        docker cp lr2_06_performance_test.sql dubbing_studio_postgres:/tmp/lr2_06_performance_test.sql
        docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -f /tmp/lr2_06_performance_test.sql
        print_success "Тест производительности выполнен!"
    else
        print_error "Файл lr2_06_performance_test.sql не найден!"
        exit 1
    fi
}

# Функция для демонстрации журнала вызовов ЛР2
show_lr2_log() {
    print_message "Просмотр журнала вызовов функций ЛР2..."
    
    if ! docker-compose ps | grep -q "Up"; then
        print_error "Контейнер не запущен! Сначала запустите контейнер: $0 start"
        exit 1
    fi
    
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -c "
        SET ROLE auditor;
        SELECT 
            call_id,
            call_time,
            function_schema || '.' || function_name as function_full_name,
            caller_username,
            success,
            execution_time_ms,
            error_message
        FROM audit.function_calls
        ORDER BY call_time DESC
        LIMIT 20;
    "
}

# Функция для проверки статуса
check_status() {
    print_message "Статус контейнера:"
    docker-compose ps
    
    if docker-compose ps | grep -q "Up"; then
        print_success "Контейнер работает!"
        
        # Проверяем подключение к БД
        print_message "Проверка подключения к БД..."
        if docker exec dubbing_studio_postgres pg_isready -U postgres -d dubbing_studio; then
            print_success "База данных готова к работе!"
        else
            print_warning "База данных ещё не готова, подождите немного..."
        fi
    else
        print_warning "Контейнер не запущен!"
    fi
}

# Функция для очистки
cleanup() {
    print_message "Очистка контейнера и данных..."
    docker-compose down -v
    docker system prune -f
    print_success "Очистка завершена!"
}

# Функция для показа справки
show_help() {
    echo "Управление Docker контейнером базы данных студии дубляжа"
    echo ""
    echo "Использование: $0 [команда]"
    echo ""
    echo "Команды:"
    echo "  start     - Запустить контейнер и инициализировать БД"
    echo "  stop      - Остановить контейнер"
    echo "  restart   - Перезапустить контейнер"
    echo "  status    - Показать статус контейнера"
    echo "  logs      - Показать логи контейнера"
    echo "  connect   - Подключиться к базе данных"
    echo "  init      - Инициализировать базу данных (если контейнер уже запущен)"
    echo "  init-s2-lr1 - Инициализировать ЛР1 семестра 2 (секционирование и метрики)"
    echo "  init-s2-lr3 - Инициализировать ЛР3 семестра 2 (шифрование данных)"
    echo "  init-lr2  - Инициализировать Лабораторную работу №2"
    echo "  test-roles - Запустить тесты ролей (role_testing_scenarios.sql)"
    echo "  test-lr2  - Запустить тесты ЛР2 (lr2_04_tests.sql)"
    echo "  test-lr2-performance - Запустить тест производительности ЛР2"
    echo "  show-lr2-log - Показать журнал вызовов функций ЛР2"
    echo "  pgadmin   - Открыть pgAdmin в браузере"
    echo "  cleanup   - Очистить контейнер и данные"
    echo "  help      - Показать эту справку"
    echo ""
    echo "pgAdmin:"
    echo "  URL: http://localhost:5050"
    echo "  Email: admin@dubbing.studio"
    echo "  Password: admin123"
    echo ""
    echo "Примеры:"
    echo "  $0 start"
    echo "  $0 connect"
    echo "  $0 logs"
}

# Основная логика
main() {
    check_docker
    
    case "${1:-help}" in
        start)
            start_container
            ;;
        stop)
            stop_container
            ;;
        restart)
            restart_container
            ;;
        status)
            check_status
            ;;
        logs)
            view_logs
            ;;
        connect)
            connect_db
            ;;
        init)
            init_database
            ;;
        init-s2-lr1)
            init_s2_lr1_if_needed
            ;;
        init-s2-lr3)
            init_s2_lr3_if_needed
            ;;
        test-roles)
            run_role_tests
            ;;
        init-lr2)
            init_lr2
            ;;
        test-lr2)
            run_lr2_tests
            ;;
        test-lr2-performance)
            run_lr2_performance
            ;;
        show-lr2-log)
            show_lr2_log
            ;;
        pgadmin)
            print_message "Открытие pgAdmin в браузере..."
            if command -v open &> /dev/null; then
                open http://localhost:5050
            elif command -v xdg-open &> /dev/null; then
                xdg-open http://localhost:5050
            else
                print_message "Откройте браузер и перейдите по адресу: http://localhost:5050"
                print_message "Email: admin@dubbing.studio"
                print_message "Password: admin123"
            fi
            ;;
        cleanup)
            cleanup
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Неизвестная команда: $1"
            show_help
            exit 1
            ;;
    esac
}

# Запуск
main "$@"
