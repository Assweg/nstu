# Исправления в лабораторных работах

## Исправления в ЛР3

### Проблема
При выполнении `lr3_01_segment_model.sql` возникала ошибка:
```
ERROR: column "segment_id" of relation "audio_archives" contains null values
```

### Причина
В таблице `app.audio_archives` были записи, которые не имели связанных записей в `app.recording_sessions`, поэтому `segment_id` оставался NULL.

### Решение
Добавлена обработка записей без `segment_id` - для них устанавливается значение по умолчанию (сегмент 1) перед установкой NOT NULL:

```sql
-- Если остались записи без segment_id, устанавливаем значение по умолчанию (сегмент 1)
UPDATE app.audio_archives
SET segment_id = 1
WHERE segment_id IS NULL;
```

## Исправления в ЛР4

### Проблема
При выполнении `lr4_01_views.sql` возникала ошибка:
```
ERROR: column a.segment_id does not exist
```

### Причина
Представление `app.actors_statistics_view` пыталось использовать `segment_id` из таблицы `app.actors`, но если ЛР3 не была выполнена полностью, эта колонка могла отсутствовать.

### Решение
Добавлена проверка наличия колонки `segment_id` перед созданием VIEW:

```sql
-- Проверяем наличие segment_id в actors перед созданием VIEW
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'app' AND table_name = 'actors' AND column_name = 'segment_id'
    ) THEN
        RAISE EXCEPTION 'Колонка segment_id не найдена в app.actors. Сначала выполните ЛР3 (lr3_01_segment_model.sql)';
    END IF;
END $$;
```

## Новые скрипты

### `run_all_labs.sh`
Скрипт для автоматического запуска всех лабораторных работ по порядку:
- Проверяет/запускает Docker контейнер
- Проверяет выполнение каждой ЛР
- Выполняет недостающие ЛР в правильном порядке
- Показывает статус выполнения

**Использование:**
```bash
bash run_all_labs.sh
```

### Обновлён `lr2_run_all.sh`
Скрипт обновлён для работы через Docker (как `lr3_run_all.sh` и `lr4_run_all.sh`).

## Порядок выполнения лабораторных работ

1. **ЛР1** - Выполняется автоматически при первом запуске Docker (`./run_docker.sh start`)
2. **ЛР2** - `bash lr2_run_all.sh` или `./run_docker.sh init-lr2`
3. **ЛР3** - `bash lr3_run_all.sh`
4. **ЛР4** - `bash lr4_run_all.sh`
5. **Все ЛР** - `bash run_all_labs.sh`

## Рекомендации

1. Всегда выполняйте лабораторные работы по порядку (ЛР1 → ЛР2 → ЛР3 → ЛР4)
2. Используйте `run_all_labs.sh` для полной инициализации всех ЛР
3. При ошибках проверяйте логи выполнения скриптов
4. Убедитесь, что Docker контейнер запущен перед выполнением скриптов

