# Инструкция по развёртыванию ЛР2 в Docker

## Быстрый старт

### Вариант 1: Полная пересборка (рекомендуется для первого запуска)

```bash
# Остановить и удалить старый контейнер (если есть)
./run_docker.sh cleanup

# Запустить контейнер (автоматически выполнит ЛР1 и ЛР2)
./run_docker.sh start
```

При первом запуске Docker автоматически:
1. Создаст БД
2. Выполнит все скрипты ЛР1 (01-11)
3. Выполнит все скрипты ЛР2 (12-16)

### Вариант 2: Если контейнер уже запущен

Если вы уже запустили контейнер с ЛР1, можно добавить ЛР2:

```bash
# Инициализация ЛР2 на существующем контейнере
./run_docker.sh init-lr2
```

---

## Проверка работы ЛР2

### 1. Проверка тестов

```bash
# Запуск всех тестов ЛР2 (10+ кейсов)
./run_docker.sh test-lr2
```

### 2. Тест производительности

```bash
# Тест CHECK vs триггер на 10,000 строк
./run_docker.sh test-lr2-performance
```

### 3. Просмотр журнала вызовов

```bash
# Показать последние 20 вызовов функций
./run_docker.sh show-lr2-log
```

### 4. Подключение к БД

```bash
# Интерактивное подключение
./run_docker.sh connect
```

Затем в psql:

```sql
-- Проверка функций
\df app.*contract*
\df app.*session*

-- Просмотр журнала вызовов
SET ROLE auditor;
SELECT * FROM audit.function_calls ORDER BY call_time DESC LIMIT 10;

-- Тест производительности
SELECT * FROM app.test_performance_check_vs_trigger(10000);
```

---

## Структура выполнения в Docker

При запуске контейнера скрипты выполняются в следующем порядке:

**ЛР1:**
- `00_extensions_stub.sql` - расширения
- `01_schemas.sql` - схемы
- `02_tables.sql` - таблицы
- `03_ref_data.sql` - справочные данные
- `04_roles.sql` - роли
- `05_privileges.sql` - привилегии
- `06_default_privs.sql` - DEFAULT PRIVILEGES
- `07_audit.sql` - аудит подключений
- `08_test_data.sql` - тестовые данные
- `09_rls.sql` - RLS и политики
- `10_audit_triggers_and_tests.sql` - триггеры аудита
- `11_final_verify.sql` - финальная проверка

**ЛР2:**
- `12_lr2_function_calls_log.sql` - таблица журнала вызовов
- `13_lr2_security_definer_functions.sql` - SECURITY DEFINER-функции
- `14_lr2_check_vs_trigger.sql` - CHECK vs триггер
- `15_lr2_tests.sql` - тесты прав доступа
- `16_lr2_demo_function_log.sql` - демонстрация журнала

---

## Примечания

### Вывод сообщений в скриптах

Некоторые скрипты используют команды `\echo` для вывода сообщений. При автоматическом выполнении в Docker эти сообщения могут не отображаться (это нормально). Для просмотра вывода:

1. Используйте интерактивный режим:
   ```bash
   ./run_docker.sh connect
   # Затем в psql: \i lr2_04_tests.sql
   ```

2. Или просматривайте логи:
   ```bash
   ./run_docker.sh logs
   ```

Сама логика выполнения скриптов не зависит от `\echo` - все SQL команды выполняются корректно.

## Устранение проблем

### Проблема: ЛР2 не выполнилась автоматически

**Решение:**

```bash
# Проверить статус контейнера
./run_docker.sh status

# Инициализировать ЛР2 вручную
./run_docker.sh init-lr2
```

### Проблема: Ошибки при выполнении скриптов

**Решение:**

```bash
# Просмотр логов
./run_docker.sh logs

# Пересоздать контейнер с нуля
./run_docker.sh cleanup
./run_docker.sh start
```

### Проблема: Функции не найдены

**Решение:**

```bash
# Проверить, что ЛР2 инициализирована
./run_docker.sh connect

# В psql:
\df app.*

# Если функций нет, выполнить:
./run_docker.sh init-lr2
```

---

## Примеры использования

### Пример 1: Создание контракта через SECURITY DEFINER-функцию

```bash
./run_docker.sh connect
```

```sql
SET ROLE studio_manager;

SELECT app.create_contract(
    p_project_id := 1,
    p_actor_id := 1,
    p_contract_number := 'TEST-DOCKER-001',
    p_role_description := 'Тестовый контракт из Docker',
    p_salary_amount := 40000.00
);

-- Проверить журнал
SET ROLE auditor;
SELECT * FROM audit.function_calls 
WHERE function_name = 'create_contract' 
ORDER BY call_time DESC 
LIMIT 1;
```

### Пример 2: Тест производительности

```bash
./run_docker.sh connect
```

```sql
SELECT * FROM app.test_performance_check_vs_trigger(10000);
```

### Пример 3: Просмотр всех вызовов функций

```bash
./run_docker.sh show-lr2-log
```

Или в psql:

```sql
SET ROLE auditor;
SELECT 
    call_time,
    function_name,
    caller_username,
    success,
    execution_time_ms
FROM audit.function_calls
ORDER BY call_time DESC;
```

---

## Полезные команды

```bash
# Показать все доступные команды
./run_docker.sh help

# Статус контейнера
./run_docker.sh status

# Логи контейнера
./run_docker.sh logs

# Остановить контейнер
./run_docker.sh stop

# Перезапустить контейнер
./run_docker.sh restart

# Полная очистка (удалить все данные)
./run_docker.sh cleanup
```

---

## Автор

Бутаков Н.М.
Лабораторная работа №2 по БСБД
