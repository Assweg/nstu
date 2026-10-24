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

# Функция для запуска контейнера
start_container() {
    print_message "Запуск контейнера базы данных студии дубляжа..."
    
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
    echo "  test-roles - Запустить тесты ролей (role_testing_scenarios.sql)"
    echo "  cleanup   - Очистить контейнер и данные"
    echo "  help      - Показать эту справку"
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
        test-roles)
            run_role_tests
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
