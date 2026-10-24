# Использование pgAdmin: Всё что в консоли, можно делать и здесь

## Да, всё что в консоли можно делать в pgAdmin!

pgAdmin предоставляет веб-интерфейс для работы с PostgreSQL, и через **Query Tool** можно выполнять любые SQL-команды и запросы, которые вы обычно выполняете в консоли через `psql`.

## Query Tool (Инструмент для SQL-запросов)

### Как открыть Query Tool:

1. **Способ 1**: Правой кнопкой на базе данных `dubbing_studio` → **"Query Tool"**
2. **Способ 2**: Правой кнопкой на любой таблице → **"Query Tool"**
3. **Способ 3**: Используйте иконку "Query Tool" на панели инструментов (иконка с символом ">" или "▶")

### Выполнение SQL-запросов:

1. В открывшемся окне Query Tool введите ваш SQL-запрос
2. Нажмите кнопку **"Execute/Refresh"** (F5) или иконку "▶" для выполнения
3. Результаты появятся в нижней панели

## Примеры: Консоль vs pgAdmin

### Пример 1: Просмотр таблиц

**В консоли:**
```bash
docker exec -it dubbing_studio_postgres psql -U postgres -d dubbing_studio -c "SELECT * FROM app.actors LIMIT 10;"
```

**В pgAdmin:**
1. Откройте Query Tool
2. Введите: `SELECT * FROM app.actors LIMIT 10;`
3. Нажмите Execute (F5)

### Пример 2: Просмотр журнала вызовов функций

**В консоли:**
```bash
docker exec dubbing_studio_postgres psql -U postgres -d dubbing_studio -c "SELECT * FROM audit.function_calls ORDER BY call_time DESC LIMIT 20;"
```

**В pgAdmin:**
1. Откройте Query Tool
2. Введите:
   ```sql
   SELECT * FROM audit.function_calls 
   ORDER BY call_time DESC 
   LIMIT 20;
   ```
3. Нажмите Execute (F5)

### Пример 3: Вызов SECURITY DEFINER-функции

**В консоли:**
```bash
docker exec -it dubbing_studio_postgres psql -U postgres -d dubbing_studio -c "SELECT app.create_contract(1, 1, 'TEST-001', 'Тест', 30000.00);"
```

**В pgAdmin:**
1. Откройте Query Tool
2. Введите:
   ```sql
   SELECT app.create_contract(
       1, 
       1, 
       'TEST-001', 
       'Тест', 
       30000.00
   );
   ```
3. Нажмите Execute (F5)

### Пример 4: Просмотр структуры таблицы

**В консоли:**
```bash
docker exec -it dubbing_studio_postgres psql -U postgres -d dubbing_studio -c "\d app.contracts"
```

**В pgAdmin:**
1. Разверните: **Servers** → **Dubbing Studio DB** → **Databases** → **dubbing_studio** → **Schemas** → **app** → **Tables**
2. Найдите таблицу **"contracts"**
3. Правой кнопкой → **"Properties"** или просто откройте таблицу
4. Или в Query Tool: `\d app.contracts` не работает, но можно использовать:
   ```sql
   SELECT column_name, data_type, is_nullable 
   FROM information_schema.columns 
   WHERE table_schema = 'app' AND table_name = 'contracts';
   ```

### Пример 5: Просмотр данных таблицы (визуально)

**В консоли:**
```bash
docker exec -it dubbing_studio_postgres psql -U postgres -d dubbing_studio -c "SELECT * FROM app.contracts;"
```

**В pgAdmin:**
1. Правой кнопкой на таблице **"contracts"** → **"View/Edit Data"** → **"All Rows"**
2. Или откройте Query Tool и выполните: `SELECT * FROM app.contracts;`

### Пример 6: Выполнение скрипта

**В консоли:**
```bash
docker exec -i dubbing_studio_postgres psql -U postgres -d dubbing_studio < script.sql
```

**В pgAdmin:**
1. Откройте Query Tool
2. Нажмите кнопку **"Open File"** (иконка папки)
3. Выберите ваш SQL-файл
4. Нажмите Execute (F5)

## Преимущества pgAdmin перед консолью

### 1. Визуальный просмотр данных
- Таблицы отображаются в удобном табличном виде
- Можно сортировать, фильтровать прямо в интерфейсе
- Не нужно писать SQL для простого просмотра данных

### 2. Визуальная структура базы данных
- Видно все схемы, таблицы, функции, индексы в дереве объектов
- Можно открыть свойства любого объекта одним кликом
- Легко навигироваться по структуре БД

### 3. Автодополнение
- Query Tool предлагает автодополнение для имен таблиц, колонок, функций
- Удобно для написания SQL-запросов

### 4. История запросов
- pgAdmin сохраняет историю выполненных запросов
- Можно вернуться к предыдущим запросам

### 5. Экспорт результатов
- Можно экспортировать результаты запросов в CSV, JSON, Excel и другие форматы
- Удобно для отчетов

### 6. Визуализация плана выполнения
- Можно посмотреть план выполнения запроса (Explain)
- Помогает оптимизировать запросы

### 7. Управление объектами через GUI
- Создание таблиц, функций, триггеров через интерфейс
- Не нужно писать весь SQL вручную

## Что можно делать в pgAdmin

### ✅ Выполнение SQL-запросов
- Любые SELECT, INSERT, UPDATE, DELETE
- Вызов функций
- Создание объектов (таблиц, функций, триггеров и т.д.)
- Управление пользователями и ролями

### ✅ Просмотр данных
- Просмотр таблиц в табличном виде
- Редактирование данных (если есть права)
- Фильтрация и сортировка данных

### ✅ Просмотр структуры БД
- Схемы, таблицы, колонки, индексы
- Функции, триггеры, представления
- Последовательности, типы данных

### ✅ Управление объектами
- Создание/изменение/удаление объектов через интерфейс
- Настройка прав доступа
- Управление индексами

### ✅ Анализ производительности
- Просмотр статистики по таблицам
- Анализ планов выполнения запросов
- Мониторинг активности БД

### ✅ Резервное копирование
- Backup и Restore через интерфейс
- Экспорт/импорт данных

## Примеры полезных запросов для pgAdmin

### Просмотр всех SECURITY DEFINER-функций:
```sql
SELECT 
    n.nspname as schema_name,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.prosecdef = true
  AND n.nspname = 'app'
ORDER BY p.proname;
```

### Статистика по журналу вызовов:
```sql
SELECT 
    function_name,
    COUNT(*) as total_calls,
    COUNT(*) FILTER (WHERE success = true) as successful,
    COUNT(*) FILTER (WHERE success = false) as failed,
    ROUND(AVG(execution_time_ms)::NUMERIC, 2) as avg_time_ms,
    ROUND(MIN(execution_time_ms)::NUMERIC, 2) as min_time_ms,
    ROUND(MAX(execution_time_ms)::NUMERIC, 2) as max_time_ms
FROM audit.function_calls
WHERE function_schema = 'app'
GROUP BY function_name
ORDER BY total_calls DESC;
```

### Просмотр всех таблиц с RLS:
```sql
SELECT 
    schemaname,
    tablename,
    rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname IN ('app', 'audit')
ORDER BY schemaname, tablename;
```

### Просмотр ролей и их привилегий:
```sql
SELECT 
    r.rolname,
    r.rolsuper,
    r.rolinherit,
    r.rolcreaterole,
    r.rolcreatedb,
    r.rolcanlogin
FROM pg_roles r
WHERE r.rolname NOT LIKE 'pg_%'
ORDER BY r.rolname;
```

## Итог

**Да, всё что вы делаете в консоли, можно делать в pgAdmin!**

- ✅ Все SQL-запросы работают точно так же
- ✅ Все функции можно вызывать
- ✅ Все данные можно просматривать
- ✅ Все операции можно выполнять

**Дополнительные возможности pgAdmin:**
- Визуальный интерфейс
- Удобный просмотр данных
- Автодополнение
- История запросов
- Экспорт результатов
- Управление объектами через GUI

pgAdmin — это полноценная альтернатива консоли `psql` с дополнительными удобствами веб-интерфейса!

