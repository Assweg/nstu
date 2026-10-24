# Лабораторная работа №4

## Безопасные представления, аудит изменений и анализ производительности

### Цель
Обеспечить безопасный доступ через представления, организовать аудит изменений и проанализировать влияние RLS на производительность.

---

## Структура файлов

### 1. `lr4_01_views.sql` - Безопасные представления
- **Updatable VIEW с WITH CHECK OPTION:**
  - `app.projects_public_view` - неконфиденциальные поля проектов (исключает `client_contacts`, `budget`)
  - `app.contracts_public_view` - неконфиденциальные поля контрактов (исключает `salary_amount`, `terms`)
  - Поддержка INSERT/UPDATE/DELETE через INSTEAD OF триггеры
  - Проверка условий VIEW в триггерах (аналог WITH CHECK OPTION)

- **SECURITY BARRIER VIEW:**
  - `app.projects_statistics_view` - агрегированная статистика по проектам
  - `app.contracts_statistics_view` - агрегированная статистика по контрактам
  - `app.actors_statistics_view` - статистика по актёрам без персональных данных
  - `app.sessions_statistics_view` - статистика по сессиям записи
  - Предотвращает утечку данных через HAVING/подзапросы

### 2. `lr4_02_audit_triggers.sql` - История изменений
- **Таблица:** `audit.row_change_log`
  - Логирует: кто, что, когда изменил
  - Маскирование чувствительных полей:
    - `passport_data`, `tax_id` (актёры) - маскирование
    - `salary_amount`, `terms` (контракты) - хэширование
    - `client_contacts`, `budget` (проекты) - маскирование

- **Триггеры на критичных таблицах:**
  - `app.projects` - AFTER UPDATE/DELETE
  - `app.contracts` - AFTER UPDATE/DELETE
  - `app.actors` - AFTER UPDATE/DELETE

### 3. `lr4_03_tests.sql` - Тесты доступов (4 кейса)
1. **Попытка обхода WITH CHECK OPTION** - должна блокироваться
2. **Попытка получения деталей через SECURITY BARRIER VIEW** - должна возвращать только агрегаты
3. **Изменение строки** - проверка появления записи в `row_change_log`
4. **Попытка удаления строки не из своего сегмента** - ошибка RLS

### 4. `lr4_04_performance.sql` - Анализ производительности
- **EXPLAIN (ANALYZE, BUFFERS)** для типовых запросов:
  - Выборка проектов по `segment_id` и `status`
  - Выборка контрактов с JOIN к актёрам
  - Агрегирующий запрос по сессиям записи

- **Индексы для оптимизации RLS:**
  - `idx_projects_segment_status` ON `app.projects(segment_id, status)`
  - `idx_contracts_segment_actor` ON `app.contracts(segment_id, actor_id)`
  - `idx_sessions_segment_date` ON `app.recording_sessions(segment_id, session_date)`

- **Таблица результатов:** `audit.performance_analysis`

### 5. `lr4_05_backup_audit.sql` - Резервное копирование audit-логов
- **Функция:** `audit.backup_audit_logs(days_interval INT)`
  - Переносит записи старше N дней из `audit.row_change_log` в `audit.row_change_log_archive`
  - Удаляет перемещённые записи из основной таблицы
  - Возвращает статистику операции

- **Архивная таблица:** `audit.row_change_log_archive`
  - Сохраняет все поля оригинальной таблицы + `archived_at`

- **Функция статистики:** `audit.get_archive_statistics()`

---

## Запуск

### Автоматический запуск через Docker

```bash
./lr4_run_all.sh
```

Скрипт автоматически:
1. Проверяет/запускает Docker контейнер
2. Выполняет все SQL скрипты в правильном порядке
3. Запускает тесты

### Ручной запуск

```bash
# Убедитесь, что контейнер запущен
docker-compose up -d

# Выполните скрипты по порядку
docker exec -i dubbing_studio_postgres psql -U postgres -d dubbing_studio < lr4_01_views.sql
docker exec -i dubbing_studio_postgres psql -U postgres -d dubbing_studio < lr4_02_audit_triggers.sql
docker exec -i dubbing_studio_postgres psql -U postgres -d dubbing_studio < lr4_03_tests.sql
docker exec -i dubbing_studio_postgres psql -U postgres -d dubbing_studio < lr4_04_performance.sql
docker exec -i dubbing_studio_postgres psql -U postgres -d dubbing_studio < lr4_05_backup_audit.sql
```

---

## Использование

### Просмотр статистики производительности

```sql
SELECT * FROM audit.performance_analysis
ORDER BY analysis_time DESC;
```

### Резервное копирование audit-логов

```sql
-- Архивировать записи старше 30 дней
SELECT * FROM audit.backup_audit_logs(30);

-- Просмотр статистики архива
SELECT * FROM audit.get_archive_statistics();
```

### Просмотр логов изменений

```sql
-- Последние изменения
SELECT * FROM audit.row_change_log
ORDER BY change_time DESC
LIMIT 10;

-- Изменения по конкретной таблице
SELECT * FROM audit.row_change_log
WHERE table_name = 'projects'
ORDER BY change_time DESC;
```

### Использование безопасных представлений

```sql
-- Чтение через публичное представление
SELECT * FROM app.projects_public_view
WHERE segment_id = 1;

-- Вставка через представление (с проверкой WITH CHECK OPTION)
INSERT INTO app.projects_public_view (studio_id, segment_id, title, original_language, status)
VALUES (1, 1, 'New Project', 'en', 'draft');

-- Просмотр агрегированной статистики
SELECT * FROM app.projects_statistics_view;
SELECT * FROM app.contracts_statistics_view;
```

---

## Результаты

### Тесты доступов
- ✅ WITH CHECK OPTION блокирует обход ограничений
- ✅ SECURITY BARRIER VIEW возвращает только агрегаты
- ✅ Триггеры аудита логируют все изменения
- ✅ RLS блокирует операции с чужими сегментами

### Производительность
- Индексы оптимизируют условия политик RLS
- Результаты анализа сохраняются в `audit.performance_analysis`

### Аудит
- Все изменения в критичных таблицах логируются
- Чувствительные данные маскируются/хэшируются
- Старые записи автоматически архивируются

---

## Зависимости

ЛР4 требует выполнения ЛР1, ЛР2 и ЛР3:
- ЛР1: Схемы, таблицы, роли, RLS
- ЛР2: SECURITY DEFINER функции, журнал вызовов
- ЛР3: Сегментация данных, политики RLS с сегментами

---

## Примечания

1. **WITH CHECK OPTION:** В PostgreSQL WITH CHECK OPTION работает автоматически только для простых updatable VIEW. Для VIEW с INSTEAD OF триггерами проверка реализована вручную в триггерах.

2. **SECURITY BARRIER:** Предотвращает утечку данных через побочные каналы (HAVING, подзапросы), но не блокирует JOIN к исходным таблицам.

3. **Маскирование данных:** Чувствительные поля маскируются/хэшируются при записи в лог аудита для защиты конфиденциальной информации.

4. **Производительность RLS:** Индексы на `segment_id` критически важны для производительности политик RLS.

