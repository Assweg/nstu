#!/bin/bash

# Скрипт для быстрого запуска всех скриптов ЛР2

DB_NAME="dubbing_studio"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

echo "====================================================="
echo "Запуск всех скриптов Лабораторной работы №2"
echo "====================================================="
echo ""

# Проверка подключения к БД
echo "Проверка подключения к БД..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Ошибка подключения к БД!"
    echo "Проверьте параметры подключения в скрипте"
    exit 1
fi
echo "✅ Подключение к БД успешно"
echo ""

# Выполнение скриптов по порядку
echo "1. Создание таблицы журнала вызовов..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f lr2_01_function_calls_log.sql
if [ $? -ne 0 ]; then
    echo "❌ Ошибка выполнения скрипта 1"
    exit 1
fi
echo "✅ Скрипт 1 выполнен"
echo ""

echo "2. Создание SECURITY DEFINER-функций..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f lr2_02_security_definer_functions.sql
if [ $? -ne 0 ]; then
    echo "❌ Ошибка выполнения скрипта 2"
    exit 1
fi
echo "✅ Скрипт 2 выполнен"
echo ""

echo "3. Сравнение CHECK vs триггер..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f lr2_03_check_vs_trigger.sql
if [ $? -ne 0 ]; then
    echo "❌ Ошибка выполнения скрипта 3"
    exit 1
fi
echo "✅ Скрипт 3 выполнен"
echo ""

echo "4. Тесты прав доступа..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f lr2_04_tests.sql
if [ $? -ne 0 ]; then
    echo "❌ Ошибка выполнения скрипта 4"
    exit 1
fi
echo "✅ Скрипт 4 выполнен"
echo ""

echo "5. Демонстрация журнала вызовов..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f lr2_05_demo_function_log.sql
if [ $? -ne 0 ]; then
    echo "❌ Ошибка выполнения скрипта 5"
    exit 1
fi
echo "✅ Скрипт 5 выполнен"
echo ""

echo "====================================================="
echo "✅ Все скрипты ЛР2 успешно выполнены!"
echo "====================================================="
echo ""
echo "Для запуска теста производительности выполните:"
echo "  psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f lr2_06_performance_test.sql"
echo ""
