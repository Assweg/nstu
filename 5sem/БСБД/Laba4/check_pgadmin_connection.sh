#!/bin/bash

# Скрипт для проверки подключения pgAdmin к базе данных

set -e

echo "====================================================="
echo "  Проверка подключения pgAdmin к PostgreSQL"
echo "====================================================="
echo ""

# Проверка, что контейнеры запущены
echo "1. Проверка статуса контейнеров..."
if ! docker ps | grep -q "dubbing_studio_postgres"; then
    echo "❌ Контейнер PostgreSQL не запущен!"
    echo "   Запустите: docker-compose up -d"
    exit 1
fi

if ! docker ps | grep -q "dubbing_studio_pgadmin"; then
    echo "❌ Контейнер pgAdmin не запущен!"
    echo "   Запустите: docker-compose up -d"
    exit 1
fi

echo "✅ Оба контейнера запущены"
echo ""

# Проверка доступности PostgreSQL из контейнера pgAdmin
echo "2. Проверка доступности PostgreSQL из контейнера pgAdmin..."
if docker exec dubbing_studio_pgadmin ping -c 1 dubbing-studio-db > /dev/null 2>&1; then
    echo "✅ Сеть Docker работает: pgAdmin может достичь PostgreSQL"
else
    echo "❌ Проблема с сетью Docker"
    exit 1
fi
echo ""

# Проверка подключения к PostgreSQL
echo "3. Проверка подключения к PostgreSQL..."
if docker exec dubbing_studio_pgadmin sh -c "timeout 5 nc -z dubbing-studio-db 5432" > /dev/null 2>&1; then
    echo "✅ Порт 5432 доступен из контейнера pgAdmin"
else
    echo "❌ Порт 5432 недоступен"
    exit 1
fi
echo ""

# Проверка доступности pgAdmin через браузер
echo "4. Проверка доступности pgAdmin через HTTP..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5050 | grep -q "200\|302\|401"; then
    echo "✅ pgAdmin доступен по адресу http://localhost:5050"
else
    echo "⚠️  pgAdmin может быть недоступен. Проверьте: http://localhost:5050"
fi
echo ""

# Проверка подключения к БД через psql из контейнера pgAdmin (если установлен)
echo "5. Проверка подключения к базе данных..."
if docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -c "SELECT 1;" > /dev/null 2>&1; then
    echo "✅ База данных dubbing_studio доступна"
    
    # Показываем информацию о БД
    echo ""
    echo "Информация о базе данных:"
    docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -c "
        SELECT 
            'База данных' as info,
            current_database() as value
        UNION ALL
        SELECT 'Версия PostgreSQL', version()
        UNION ALL
        SELECT 'Количество таблиц в app', COUNT(*)::text
        FROM information_schema.tables 
        WHERE table_schema = 'app'
        UNION ALL
        SELECT 'Количество схем', COUNT(DISTINCT schema_name)::text
        FROM information_schema.schemata
        WHERE schema_name IN ('app', 'ref', 'audit', 'stg');
    " 2>/dev/null || echo "⚠️  Не удалось получить информацию о БД"
else
    echo "❌ Не удалось подключиться к базе данных"
    exit 1
fi
echo ""

# Итоговая информация
echo "====================================================="
echo "  Итоговая информация для подключения"
echo "====================================================="
echo ""
echo "🌐 pgAdmin доступен по адресу:"
echo "   http://localhost:5050"
echo ""
echo "📧 Учетные данные для входа в pgAdmin:"
echo "   Email:    admin@dubbing.studio"
echo "   Password: admin123"
echo ""
echo "🔌 Параметры подключения к серверу БД в pgAdmin:"
echo "   Host name/address: dubbing-studio-db"
echo "   Port:              5432"
echo "   Maintenance database: dubbing_studio"
echo "   Username:          postgres"
echo "   Password:          secure_password_123"
echo ""
echo "💡 Инструкция:"
echo "   1. Откройте http://localhost:5050 в браузере"
echo "   2. Войдите с учетными данными выше"
echo "   3. Правой кнопкой на 'Servers' → Register → Server"
echo "   4. Заполните параметры подключения (см. выше)"
echo "   5. Нажмите Save"
echo ""
echo "✅ Все проверки пройдены успешно!"
echo ""

